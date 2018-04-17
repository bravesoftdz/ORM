{
      ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi

                   Copyright (c) 2016, Isaque Pinheiro
                          All rights reserved.

                    GNU Lesser General Public License
                      Vers�o 3, 29 de junho de 2007

       Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
       A todos � permitido copiar e distribuir c�pias deste documento de
       licen�a, mas mud�-lo n�o � permitido.

       Esta vers�o da GNU Lesser General Public License incorpora
       os termos e condi��es da vers�o 3 da GNU General Public License
       Licen�a, complementado pelas permiss�es adicionais listadas no
       arquivo LICENSE na pasta principal.
}

{ @abstract(ORMBr Framework.)
  @created(20 Jul 2016)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @author(Skype : ispinheiro)
  @abstract(Website : http://www.ormbr.com.br)
  @abstract(Telagram : https://t.me/ormbr)

  ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi.
}

unit ormbr.objects.manager;

interface

uses
  DB,
  Rtti,
  Types,
  Classes,
  SysUtils,
  Variants,
  Generics.Collections,
  /// ormbr
  ormbr.criteria,
  ormbr.types.mapping,
  ormbr.mapping.classes,
  ormbr.command.factory,
  ormbr.factory.interfaces,
  ormbr.mapping.explorer,
  ormbr.objects.manager.abstract,
  ormbr.mapping.explorerstrategy;

type
  TObjectManager<M: class, constructor> = class sealed(TObjectManagerAbstract<M>)
  private
    FOwner: TObject;
    FObjectInternal: M;
    procedure FillAssociation(AObject: M);
  protected
    FConnection: IDBConnection;
    /// <summary>
    /// F�brica de comandos a serem executados
    /// </summary>
    FDMLCommandFactory: TDMLCommandFactoryAbstract;
    /// <summary>
    /// Controle de pagina��o vindo do banco de dados
    /// </summary>
    FPageSize: Integer;
    procedure ExecuteOneToOne(AObject: TObject; AProperty: TRttiProperty;
      AAssociation: TAssociationMapping); override;
    procedure ExecuteOneToMany(AObject: TObject; AProperty: TRttiProperty;
      AAssociation: TAssociationMapping); override;
    function FindSQLInternal(const ASQL: String): TObjectList<M>; override;
  public
    constructor Create(const AOwner: TObject; const AConnection: IDBConnection;
      const APageSize: Integer); override;
    destructor Destroy; override;
    procedure InsertInternal(const AObject: M); override;
    procedure UpdateInternal(const AObject: TObject; const AModifiedFields: TList<string>); override;
    procedure DeleteInternal(const AObject: M); override;
    procedure NextPacketList(const AObjectList: TObjectList<M>); override;
    function SelectInternalAll: IDBResultSet; override;
    function SelectInternalID(const AID: Variant): IDBResultSet; override;
    function SelectInternal(const ASQL: String): IDBResultSet; override;
    function SelectInternalWhere(const AWhere: string; const AOrderBy: string): string; override;
    function GetDMLCommand: string; override;
    function Find: TObjectList<M>; overload; override;
    function Find(const AID: Variant): M; overload; override;
    function FindWhere(const AWhere: string; const AOrderBy: string): TObjectList<M>; override;
    function ExistSequence: Boolean; override;
    function NextPacket: IDBResultSet; override;
  end;

implementation

uses
  ormbr.objectset.bind,
  ormbr.types.database,
  ormbr.objects.helper,
  ormbr.mapping.attributes,
  ormbr.mapping.rttiutils,
  ormbr.session.abstract,
  ormbr.rtti.helper;

{ TObjectManager<M> }

constructor TObjectManager<M>.Create(const AOwner: TObject; const AConnection: IDBConnection;
  const APageSize: Integer);
begin
  FOwner := AOwner;
  FPageSize := APageSize;
  if not (AOwner is TSessionAbstract<M>) then
    raise Exception.Create('O Object Manager n�o deve ser inst�nciada diretamente, use as classes TSessionObject<M> ou TSessionDataSet<M>');

  FConnection := AConnection;
  FExplorer := TMappingExplorer.GetInstance;
  FObjectInternal := M.Create;
  /// <summary>
  /// Fabrica de comandos SQL
  /// </summary>
  FDMLCommandFactory := TDMLCommandFactory.Create(FObjectInternal,
                                                  AConnection,
                                                  AConnection.GetDriverName);
end;

destructor TObjectManager<M>.Destroy;
begin
  FExplorer := nil;
  FDMLCommandFactory.Free;
  FObjectInternal.Free;
  inherited;
end;

procedure TObjectManager<M>.DeleteInternal(const AObject: M);
begin
  FDMLCommandFactory.GeneratorDelete(AObject);
end;

function TObjectManager<M>.SelectInternalAll: IDBResultSet;
begin
  Result := FDMLCommandFactory.GeneratorSelectAll(M, FPageSize);
end;

function TObjectManager<M>.SelectInternalID(const AID: Variant): IDBResultSet;
begin
  Result := FDMLCommandFactory.GeneratorSelectID(M, AID);
end;

function TObjectManager<M>.SelectInternalWhere(const AWhere: string;
  const AOrderBy: string): string;
begin
  Result := FDMLCommandFactory.GeneratorSelectWhere(M, AWhere, AOrderBy, FPageSize);
end;

procedure TObjectManager<M>.FillAssociation(AObject: M);
var
  LAssociationList: TAssociationMappingList;
  LAssociation: TAssociationMapping;
begin
  LAssociationList := FExplorer.GetMappingAssociation(AObject.ClassType);
  if LAssociationList <> nil then
  begin
    for LAssociation in LAssociationList do
    begin
       if LAssociation.Multiplicity in [OneToOne, ManyToOne] then
          ExecuteOneToOne(AObject, LAssociation.PropertyRtti, LAssociation)
       else
       if LAssociation.Multiplicity in [OneToMany, ManyToMany] then
          ExecuteOneToMany(AObject, LAssociation.PropertyRtti, LAssociation);
    end;
  end;
end;

procedure TObjectManager<M>.ExecuteOneToOne(AObject: TObject; AProperty: TRttiProperty;
  AAssociation: TAssociationMapping);
var
 LResultSet: IDBResultSet;
begin
  LResultSet := FDMLCommandFactory.GeneratorSelectOneToOne(AObject,
                                                           AProperty.PropertyType.AsInstance.MetaclassType,
                                                           AAssociation);
  try
    while LResultSet.NotEof do
    begin
      TBindObject.GetInstance.SetFieldToProperty(LResultSet,
                                                 AProperty.GetNullableValue(AObject).AsObject,
                                                 AAssociation);
    end;
  finally
    LResultSet.Close;
  end;
end;

procedure TObjectManager<M>.ExecuteOneToMany(AObject: TObject; AProperty: TRttiProperty;
  AAssociation: TAssociationMapping);
var
  LPropertyType: TRttiType;
  LPropertyObject: TObject;
  LResultSet: IDBResultSet;
begin
  LPropertyType := AProperty.PropertyType;
  LPropertyType := AProperty.GetTypeValue(LPropertyType);
  LResultSet := FDMLCommandFactory.GeneratorSelectOneToMany(AObject,
                                                            LPropertyType.AsInstance.MetaclassType,
                                                            AAssociation);
  try
    while LResultSet.NotEof do
    begin
      /// <summary>
      /// Instancia o objeto da lista
      /// </summary>
      LPropertyObject := LPropertyType.AsInstance.MetaclassType.Create;
      /// <summary>
      /// Preenche o objeto com os dados do ResultSet
      /// </summary>
      TBindObject.GetInstance.SetFieldToProperty(LResultSet, LPropertyObject, AAssociation);
      /// <summary>
      /// Adiciona o objeto a lista
      /// </summary>
      TRttiSingleton.GetInstance.MethodCall(AProperty.GetNullableValue(AObject).AsObject,'Add',[LPropertyObject]);
    end;
  finally
    LResultSet.Close;
  end;
end;

function TObjectManager<M>.ExistSequence: Boolean;
begin
  Result := FDMLCommandFactory.ExistSequence;
end;

function TObjectManager<M>.GetDMLCommand: string;
begin
  Result := FDMLCommandFactory.GetDMLCommand;
end;

function TObjectManager<M>.NextPacket: IDBResultSet;
begin
  Result := FDMLCommandFactory.GeneratorNextPacket;
  if Result.FetchingAll then
    FFetchingRecords := True;
end;

procedure TObjectManager<M>.NextPacketList(const AObjectList: TObjectList<M>);
var
 LResultSet: IDBResultSet;
begin
  LResultSet := NextPacket;
  try
    while LResultSet.NotEof do
    begin
      AObjectList.Add(M.Create);
      TBindObject.GetInstance.SetFieldToProperty(LResultSet, TObject(AObjectList.Last));
      /// <summary>
      /// Alimenta registros das associa��es existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(AObjectList.Last);
    end;
  finally
    /// <summary>
    /// Fecha o DataSet interno para limpar os dados dele da mem�ria.
    /// </summary>
    LResultSet.Close;
  end;
end;

function TObjectManager<M>.SelectInternal(const ASQL: String): IDBResultSet;
begin
  Result := FDMLCommandFactory.GeneratorSelect(ASQL, FPageSize);
end;

procedure TObjectManager<M>.UpdateInternal(const AObject: TObject; const AModifiedFields: TList<string>);
begin
  FDMLCommandFactory.GeneratorUpdate(AObject, AModifiedFields);
end;

procedure TObjectManager<M>.InsertInternal(const AObject: M);
begin
  FDMLCommandFactory.GeneratorInsert(AObject);
end;

function TObjectManager<M>.FindSQLInternal(const ASQL: String): TObjectList<M>;
var
 LResultSet: IDBResultSet;
begin
  Result := TObjectList<M>.Create;
  if ASQL = '' then
    LResultSet := SelectInternalAll
  else
    LResultSet := SelectInternal(ASQL);
  try
    while LResultSet.NotEof do
    begin
      TBindObject.GetInstance.SetFieldToProperty(LResultSet, TObject(Result.Items[Result.Add(M.Create)]));
      /// <summary>
      /// Alimenta registros das associa��es existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(Result.Items[Result.Count -1]);
    end;
  finally
    LResultSet.Close;
  end;
end;

function TObjectManager<M>.Find: TObjectList<M>;
begin
  Result := FindSQLInternal('');
end;

function TObjectManager<M>.Find(const AID: Variant): M;
var
 LResultSet: IDBResultSet;
begin
  LResultSet := SelectInternalID(AID);
  try
    if LResultSet.RecordCount = 1 then
    begin
      Result := M.Create;
      TBindObject.GetInstance.SetFieldToProperty(LResultSet, TObject(Result));
      /// <summary>
      /// Alimenta registros das associa��es existentes 1:1 ou 1:N
      /// </summary>
      FillAssociation(Result);
    end
    else
      Result := nil;
  finally
    /// <summary>
    /// Fecha o DataSet interno para limpar os dados dele da mem�ria.
    /// </summary>
    LResultSet.Close;
  end;
end;

function TObjectManager<M>.FindWhere(const AWhere: string;
  const AOrderBy: string): TObjectList<M>;
begin
  Result := FindSQLInternal(SelectInternalWhere(AWhere, AOrderBy));
end;

end.

