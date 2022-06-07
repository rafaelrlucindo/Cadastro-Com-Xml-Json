unit untDaoGenerico;

interface

uses
  db, untEntidadeAtributos, rtti, TypInfo, System.SysUtils,
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Generics.Collections, Vcl.StdCtrls, Vcl.ExtCtrls,
  Winapi.Windows, Winapi.Messages, System.Variants,
  Vcl.ComCtrls,  StrUtils, Xml.XMLDoc, Xml.XMLIntf,
  system.IOUtils, untClassUtils;

type
  TDaoGenerico = class

    private
      class var FInstancia: TDaoGenerico;
      class var FArquivo : string;
      class var FXml : TXmlDocument;
      class var FXmlString : string;
      class var FTagAbertas : String;

      class function getNodePrincipal<T: class>(Objeto: T):string;
      class function getNodePai<T: class>(Objeto: T):string;
      class function getInstancia: TDaoGenerico; static;
      class procedure setInstancia(const Value: TDaoGenerico); static;

    public
      class property arquivo : string read FArquivo write FArquivo;
      class function insere<T: class>(Objeto: T; aFecharNode:Boolean):integer;
      class function iniciaXml:String;
      class function finalizaXml: String;
      class procedure addTag(aValor:String);
      class property instancia : TDaoGenerico read getInstancia write setInstancia;
    end;

implementation

{ TDaoGenerico }
class function TDaoGenerico.getInstancia: TDaoGenerico;
begin
  if FInstancia = nil then
    FInstancia := TDaoGenerico.Create;

  Result := FInstancia;
end;

class function TDaoGenerico.getNodePai<T>(Objeto: T): string;
  var
    contexto : TRttiContext;
    typObjeto : TRttiType;
    Atributo : TCustomAttribute;
begin
  contexto := TRttiContext.Create;
  typObjeto := contexto.GetType(TObject(Objeto).ClassInfo);

  for Atributo in typObjeto.GetAttributes do
    if Atributo is NodePai then
      Exit(NodePai(Atributo).name);
end;

class function TDaoGenerico.getNodePrincipal<T>(Objeto: T): string;
  var
    contexto : TRttiContext;
    typObjeto : TRttiType;
    Atributo : TCustomAttribute;
begin
  contexto := TRttiContext.Create;
  typObjeto := contexto.GetType(TObject(Objeto).ClassInfo);

  for Atributo in typObjeto.GetAttributes do
    if Atributo is NodePrincipal then
      Exit(NodePrincipal(Atributo).name);
end;

class procedure TDaoGenerico.addTag(aValor: String);
begin
  FXmlString := FXmlString + '<' + aValor + '>';
  FTagAbertas := FTagAbertas + aValor + ',';
end;

class function TDaoGenerico.finalizaXml: String;
begin
  FXmlString := FXmlString + '</ENDERECO>';
  FXmlString := FXmlString + '</CLIENTE>';
  FXmlString := FXmlString + '</CLIENTES>';

  FXML.LoadFromXML(FXmlString);

  if FArquivo <> '' then
    begin
      FXml.SaveToFile(FArquivo);
    end
  else
    begin
      var strArqTemp : String;
      strArqTemp :=
        TPath.Combine(
          TAplicativo.instancia.DiretorioXml,
          FormatDateTime('ddmmyy', Date) + '_' + FormatDateTime('hhmmss', time) + '.xml'
        );

      FXml.SaveToFile(strArqTemp);
      FArquivo := strArqTemp;
    end;
end;

class function TDaoGenerico.iniciaXml: String;
begin
  if FXml = nil then
    FXml := TXMLDocument.Create(nil);

  FXml.Active := True;
  FXmlString := '';
  FTagAbertas := '';
end;

class function TDaoGenerico.insere<T>(Objeto: T; aFecharNode:Boolean): integer;
  var
    contexto : TRttiContext;
    typObjeto : TRttiType;
    prop : TRttiProperty;
    atributo : TCustomAttribute;
    blnAbrir : Boolean;
begin
  contexto := TRttiContext.Create;
  typObjeto :=  contexto.GetType(TObject(Objeto).ClassInfo);

  addTag(getNodePrincipal(Objeto));
  addTag(getNodePai(Objeto));

  for prop in typObjeto.GetProperties do
    begin
      for atributo in prop.GetAttributes do
        begin
          if (Pos(FieldName(atributo).name, FTagAbertas) = 0) and ( not blnAbrir ) then
            begin
              blnAbrir := True;
              addTag(FieldName(atributo).name);
            end
          else
            begin
              FXmlString := FXmlString +  '<' + prop.Name + '>' + prop.GetValue(TObject(Objeto)).AsVariant + '</' + prop.Name + '>'
            end;
        end;
    end;
end;

class procedure TDaoGenerico.setInstancia(const Value: TDaoGenerico);
begin

end;

end.
