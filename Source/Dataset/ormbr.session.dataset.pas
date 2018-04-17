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

  ORM Brasil � um ORM simples e descomplicado para quem utiliza Delphi.
}

unit ormbr.session.dataset;

interface

uses
  DB,
  Rtti,
  TypInfo,
  Classes,
  Variants,
  SysUtils,
  Generics.Collections,
  /// orm
  ormbr.mapping.classes,
  ormbr.mapping.explorerstrategy,
  ormbr.objects.manager,
  ormbr.objects.manager.abstract,
  ormbr.session.abstract,
  ormbr.dataset.base.adapter,
  ormbr.factory.interfaces;

type
  /// <summary>
  /// M - Sess�o DataSet
  /// </summary>
  TSessionDataSet<M: class, constructor> = class(TSessionAbstract<M>)
  private
    FOwner: TDataSetBaseAdapter<M>;
    procedure PopularDataSet(const ADBResultSet: IDBResultSet);
  protected
    FManager: TObjectManagerAbstract<M>;
    FConnection: IDBConnection;
  public
    constructor Create(const AOwner: TDataSetBaseAdapter<M>;
      const AConnection: IDBConnection; const APageSize: Integer = -1); overload;
    destructor Destroy; override;
    procedure Insert(const AObject: M); override;
    procedure Update(const AObject: M; const AKey: string); override;
    procedure Delete(const AObject: M); override;
    procedure NextPacket(const AObjectList: TObjectList<M>); overload; override;
    procedure OpenID(const AID: Variant); override;
    procedure OpenSQL(const ASQL: string); override;
    procedure OpenWhere(const AWhere: string; const AOrderBy: string = ''); override;
    procedure NextPacket; overload; override;
    procedure RefreshRecord(const AColumnName: string); override;
    procedure ModifyFieldsCompare(const AKey: string; const AObjectSource, AObjectUpdate: TObject); override;
    function Find: TObjectList<M>; overload; override;
    function Find(const AID: Integer): M; overload; override;
    function Find(const AID: string): M; overload; override;
    function FindWhere(const AWhere: string; const AOrderBy: string): TObjectList<M>; override;
    function ExistSequence: Boolean; override;
    function ModifiedFields: TDictionary<string, TList<string>>; override;
    function DeleteList: TObjectList<M>; override;
    function Explorer: IMappingExplorerStrategy;
    function Manager: TObjectManagerAbstract<M>;
  end;

implementation

uses
  ormbr.dataset.bind;

{ TSessionDataSet<M> }

constructor TSessionDataSet<M>.Create(const AOwner: TDataSetBaseAdapter<M>;
  const AConnection: IDBConnection; const APageSize: Integer);
begin
  inherited Create(APageSize);
  FOwner := AOwner;
  FConnection := AConnection;
  FManager := TObjectManager<M>.Create(Self, AConnection, APageSize);
end;

procedure TSessionDataSet<M>.OpenID(const AID: Variant);
var
  LDBResultSet: IDBResultSet;
begin
  FManager.FetchingRecords := False;
  LDBResultSet := FManager.SelectInternalID(AID);
  /// <summary>
  /// Popula o DataSet em mem�ria com os registros retornardos no comando SQL
  /// </summary>
  PopularDataSet(LDBResultSet);
end;

procedure TSessionDataSet<M>.OpenSQL(const ASQL: string);
var
  LDBResultSet: IDBResultSet;
begin
  FManager.FetchingRecords := False;
  if ASQL = '' then
    LDBResultSet := FManager.SelectInternalAll
  else
    LDBResultSet := FManager.SelectInternal(ASQL);
  /// <summary>
  /// Popula o DataSet em mem�ria com os registros retornardos no comando SQL
  /// </summary>
  PopularDataSet(LDBResultSet);
end;

procedure TSessionDataSet<M>.OpenWhere(const AWhere: string; const AOrderBy: string);
begin
  OpenSQL(FManager.SelectInternalWhere(AWhere, AOrderBy));
end;

procedure TSessionDataSet<M>.PopularDataSet(const ADBResultSet: IDBResultSet);
begin
//           FOrmDataSet.Locate(KeyFiels, KeyValues, Options);
//          { TODO -oISAQUE : Procurar forma de verificar se o registro n�o j� est� em mem�ria
//                            pela chave primaria }
  while ADBResultSet.NotEof do
  begin
     FOwner.FOrmDataSet.Append;
     TBindDataSet.GetInstance.SetFieldToField(ADBResultSet, FOwner.FOrmDataSet);
     FOwner.FOrmDataSet.Fields[0].AsInteger := -1;
     FOwner.FOrmDataSet.Post;
  end;
  ADBResultSet.Close;
end;

procedure TSessionDataSet<M>.RefreshRecord(const AColumnName: string);
var
  LDBResultSet: IDBResultSet;
begin
  inherited;
  LDBResultSet := FManager.SelectInternalID(FOwner.FOrmDataSet.FieldByName(AColumnName).AsInteger);
  /// Atualiza dados no DataSet
  while LDBResultSet.NotEof do
  begin
    FOwner.FOrmDataSet.Edit;
    TBindDataSet.GetInstance.SetFieldToField(LDBResultSet, FOwner.FOrmDataSet);
    FOwner.FOrmDataSet.Post;
  end;
end;

procedure TSessionDataSet<M>.Delete(const AObject: M);
begin
  inherited;
  FManager.DeleteInternal(AObject);
end;

procedure TSessionDataSet<M>.Update(const AObject: M; const AKey: string);
begin
  inherited;
  FManager.UpdateInternal(AObject, FModifiedFields.Items[AKey]);
end;

destructor TSessionDataSet<M>.Destroy;
begin
  FManager.Free;
  inherited;
end;

function TSessionDataSet<M>.ExistSequence: Boolean;
begin
  Result := FManager.ExistSequence;
end;

function TSessionDataSet<M>.Find(const AID: Integer): M;
begin
  inherited;
  Result := FManager.Find(AID);
end;

function TSessionDataSet<M>.Find(const AID: string): M;
begin
  inherited;
  Result := FManager.Find(AID);
end;

function TSessionDataSet<M>.Find: TObjectList<M>;
begin
  inherited;
  Result := FManager.Find;
end;

function TSessionDataSet<M>.FindWhere(const AWhere: string;
  const AOrderBy: string): TObjectList<M>;
begin
  Result := FManager.FindWhere(AWhere, AOrderby);
end;

procedure TSessionDataSet<M>.Insert(const AObject: M);
begin
  inherited;
  FManager.InsertInternal(AObject);
end;

function TSessionDataSet<M>.Manager: TObjectManagerAbstract<M>;
begin
  Result := FManager;
end;

procedure TSessionDataSet<M>.ModifyFieldsCompare(const AKey: string;
  const AObjectSource, AObjectUpdate: TObject);
begin
  inherited ModifyFieldsCompare(AKey, AObjectSource, AObjectUpdate);
end;

procedure TSessionDataSet<M>.NextPacket(const AObjectList: TObjectList<M>);
begin
  if not FManager.FetchingRecords then
    FManager.NextPacketList(AObjectList);
end;

procedure TSessionDataSet<M>.NextPacket;
var
  LDBResultSet: IDBResultSet;
begin
  if not FManager.FetchingRecords then
  begin
    LDBResultSet := FManager.NextPacket;
    /// <summary>
    /// Popula o DataSet em mem�ria com os registros retornardos no comando SQL
    /// </summary>
    PopularDataSet(LDBResultSet);
  end;
end;

function TSessionDataSet<M>.ModifiedFields: TDictionary<string, TList<string>>;
begin
  Result := inherited ModifiedFields;
end;

function TSessionDataSet<M>.DeleteList: TObjectList<M>;
begin
  Result := inherited DeleteList;
end;

function TSessionDataSet<M>.Explorer: IMappingExplorerStrategy;
begin
  Result := inherited Explorer;
end;

end.
