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

{$INCLUDE ..\ormbr.inc}

unit ormbr.rest.json;

interface

uses
  Generics.Collections,
  ormbr.json;

type
  TORMBrJson = class
  private
    class var
    FJSONObject: TJSONObjectORMBr;
  public
    class constructor Create;
    class destructor Destroy;
    class function ObjectToJsonString(AObject: TObject;
      AOptions: TORMBrJsonOptions = [joDateIsUTC, joDateFormatISO8601]): string;
    class function JsonToObject<T: class, constructor>(const AJson: string;
      AOptions: TORMBrJsonOptions = [joDateIsUTC, joDateFormatISO8601]): T; overload;
    class function JsonToObject<T: class>(AObject: T; const AJson: string): Boolean; overload;
    class function JsonToObjectList<T: class, constructor>(const AJson: string): TObjectList<T>;
  end;

implementation

{ TJson }

class constructor TORMBrJson.Create;
begin
  FJSONObject := TJSONObjectORMBr.Create;
end;

class destructor TORMBrJson.Destroy;
begin
  FJSONObject.Free;
  inherited;
end;

class function TORMBrJson.JsonToObject<T>(AObject: T;
  const AJson: string): Boolean;
begin
  Result := FJSONObject.JSONToObject(TObject(AObject), AJson);
end;

class function TORMBrJson.JsonToObject<T>(const AJson: string;
  AOptions: TORMBrJsonOptions): T;
begin
  Result := FJSONObject.JSONToObject<T>(AJson);
end;

class function TORMBrJson.ObjectToJsonString(AObject: TObject;
  AOptions: TORMBrJsonOptions): string;
begin
  Result := FJSONObject.ObjectToJSON(AObject);
end;

class function TORMBrJson.JsonToObjectList<T>(const AJson: string): TObjectList<T>;
begin
  Result := FJSONObject.JSONToObjectList<T>(AJson);
end;

end.
