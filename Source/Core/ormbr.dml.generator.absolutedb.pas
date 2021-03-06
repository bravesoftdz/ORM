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

unit ormbr.dml.generator.absolutedb;

interface

uses
  SysUtils,
  StrUtils,
  Rtti,
  ormbr.dml.generator,
  ormbr.mapping.classes,
  ormbr.mapping.explorer,
  ormbr.factory.interfaces,
  ormbr.driver.register,
  ormbr.types.database,
  ormbr.dml.commands,
  ormbr.criteria;

type
  /// <summary>
  /// Classe de banco de dados Firebird
  /// </summary>
  TDMLGeneratorAbsoluteDB = class(TDMLGeneratorAbstract)
  protected
    function GetGeneratorSelect(ACriteria: ICriteria): string; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    function GeneratorSelectAll(AClass: TClass; APageSize: Integer; AID: Variant): string; override;
    function GeneratorSequenceCurrentValue(AObject: TObject; ACommandInsert: TDMLCommandInsert): Int64; override;
    function GeneratorSequenceNextValue(AObject: TObject; ACommandInsert: TDMLCommandInsert): Int64; override;
  end;

implementation

{ TDMLGeneratorAbsoluteDB }

constructor TDMLGeneratorAbsoluteDB.Create;
begin
  inherited;
  FDateFormat := 'dd/MM/yyyy';
  FTimeFormat := 'HH:MM:SS';
end;

destructor TDMLGeneratorAbsoluteDB.Destroy;
begin

  inherited;
end;

function TDMLGeneratorAbsoluteDB.GetGeneratorSelect(ACriteria: ICriteria): string;
begin
  inherited;
  ACriteria.AST.Select.Columns.Columns[0].Name := 'TOP %s, %s ' + ACriteria.AST.Select.Columns.Columns[0].Name;
  Result := ACriteria.AsString;
end;

function TDMLGeneratorAbsoluteDB.GeneratorSelectAll(AClass: TClass;
  APageSize: Integer; AID: Variant): string;
var
  oCriteria: ICriteria;
begin
  oCriteria := GetCriteriaSelect(AClass, AID);
  if APageSize > -1 then
     Result := GetGeneratorSelect(oCriteria)
  else
     Result := oCriteria.AsString;
end;

function TDMLGeneratorAbsoluteDB.GeneratorSequenceCurrentValue(AObject: TObject;
  ACommandInsert: TDMLCommandInsert): Int64;
begin
  Result := ExecuteSequence(Format('SELECT LASTAUTOINC(%s, %s) FROM %s', [ACommandInsert.Table.Name,
                                                                          ACommandInsert.Table.Name,
                                                                          ACommandInsert.Table.Name]));
end;

function TDMLGeneratorAbsoluteDB.GeneratorSequenceNextValue(AObject: TObject;
  ACommandInsert: TDMLCommandInsert): Int64;
begin
  Result := GeneratorSequenceCurrentValue(AObject, ACommandInsert) + ACommandInsert.Sequence.Increment;
end;

initialization
  TDriverRegister.RegisterDriver(dnAbsoluteDB, TDMLGeneratorAbsoluteDB.Create);

end.
