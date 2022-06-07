unit untClassUtils;

interface

uses
  db, rtti, untEntidadeAtributos, TypInfo, System.SysUtils,
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Generics.Collections, Vcl.StdCtrls, Vcl.ExtCtrls,
  Winapi.Windows, Winapi.Messages, System.Variants,
  Vcl.ComCtrls,  StrUtils, Xml.XMLDoc, Xml.XMLIntf,
  system.IOUtils;

type
  TAplicativo = class
    private
      class var FInstancia : TAplicativo;
      class var FDiretorioXml : String;

      class function getInstancia: TAplicativo; static;
      class procedure setInstancia(const Value: TAplicativo); static;

    public
      procedure AfterConstruction; override;
      procedure BeforeDestruction; override;

      class property DiretorioXml : string read FDiretorioXml write FDiretorioXml;
      class property instancia : TAplicativo read getInstancia write setInstancia;
  end;

implementation

{ TAplicativo }

procedure TAplicativo.AfterConstruction;
begin
  inherited;

  FDiretorioXml := TPath.Combine(ExtractFilePath(Application.ExeName), 'Xml');

  if not DirectoryExists(FDiretorioXml) then
    TDirectory.CreateDirectory(FDiretorioXml);
end;

procedure TAplicativo.BeforeDestruction;
begin
  inherited;
end;

class function TAplicativo.getInstancia: TAplicativo;
begin
  if FInstancia = nil then
    FInstancia := TAplicativo.Create;

  Result := FInstancia;
end;

class procedure TAplicativo.setInstancia(const Value: TAplicativo);
begin
  FInstancia := Value;
end;

end.
