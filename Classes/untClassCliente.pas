unit untClassCliente;

interface

uses
  untEntidadeGenerica, untEntidadeAtributos, System.Classes, untDaoGenerico, Xml.XMLDoc,
  system.IOUtils, forms, System.SysUtils, system.StrUtils;

type
  [NodePrincipal('CLIENTES')]
  [NodePai('CLIENTE')]
  [NodeFilho('ENDERECO')]

  TCliente = class(TEntidadeGenerica)
    private
      FNome : string;
      FIdentidade : String;
      FCpf : string;
      FTelefone : string;
      FEmail : String;
      //FEndereco: TEndereco;


      { endereco }
      FLogradouro: String;
      Fbairro: String;
      FCep: String;
      FNumero: String;
      FComplemento: String;
      Fcidade: String;
      Fpais: String;
      FEstado: String;

      class var FArquivo: String;

      class var FInstancia : TCliente;
      { endereco }

      procedure setNome(aValue:String);
      procedure setIdentidade(aValue:String);
      procedure setCpf(aValue:String);
      procedure setTelefone(aValue:String);
      procedure setEmail(aValue:String);

      procedure setbairro(const Value: String);
      procedure setCep(const Value: String);
      procedure setcidade(const Value: String);
      procedure setComplemento(const Value: String);
      procedure setEstado(const Value: String);
      procedure setLogradouro(const Value: String);
      procedure setNumero(const Value: String);
      procedure setpais(const Value: String);


      class function getInstancia: TCliente; static;
      class procedure setInstancia(const Value: TCliente); static;

    public
      constructor Create(aArquivo : String);

      //[FieldName('NOME')]
      [FieldName('CLIENTE')]
      property nome : String read FNome write setNome;

//      [FieldName('IDENTIDADE')]
      [FieldName('CLIENTE')]
      property identidade : String read FIdentidade write setIdentidade;

//      [FieldName('CPF')]
      [FieldName('CLIENTE')]
      property cpf : String read FCpf write setCpf;

//      [FieldName('TELEFONE')]
      [FieldName('CLIENTE')]
      property telefone : String read FTelefone write setTelefone;

//      [FieldName('EMAIL')]
      [FieldName('CLIENTE')]
      property email : String read FEmail write setEmail;



      { **** endereco **** }
      [FieldName('ENDERECO')]
      property cep : String read FCep write setCep;

      [FieldName('ENDERECO')]
      property logradouro : String read FLogradouro write setLogradouro;

      [FieldName('ENDERECO')]
      property numero : String read FNumero write setNumero;

      [FieldName('ENDERECO')]
      property complemento : String read FComplemento write setComplemento;

      [FieldName('ENDERECO')]
      property bairro : String read Fbairro write setbairro;

      [FieldName('ENDERECO')]
      property cidade : String read Fcidade write setcidade;

      [FieldName('ENDERECO')]
      property estado : String read FEstado write setEstado;

      [FieldName('ENDERECO')]
      property pais : String read Fpais write setpais;

      class function insere:String;

      class property instancia : TCliente read getInstancia write setInstancia;
      class property arquivo : string read FArquivo write FArquivo;
  end;

implementation

uses
  System.Rtti, System.TypInfo;

{ TCliente }

constructor TCliente.Create(aArquivo : String);
begin
  inherited Create;
  FArquivo := aArquivo;
end;

class function TCliente.getInstancia: TCliente;
begin
  if FInstancia = nil then
    FInstancia := TCliente.Create('');

  Result := FInstancia;
end;

class function TCliente.insere:String;
begin
  TDaoGenerico.instancia.iniciaXml;
  TDaoGenerico.instancia.insere(FInstancia, False);
  TDaoGenerico.instancia.arquivo := FInstancia.FArquivo;
  TDaoGenerico.instancia.finalizaXml;
  Result := TDaoGenerico.instancia.arquivo;
end;

procedure TCliente.setbairro(const Value: String);
begin
  Fbairro := Value;
end;

procedure TCliente.setCep(const Value: String);
begin
  FCep := Value;
end;

procedure TCliente.setcidade(const Value: String);
begin
  Fcidade := Value;
end;

procedure TCliente.setComplemento(const Value: String);
begin
  FComplemento := Value;
end;

procedure TCliente.setCpf(aValue: String);
begin
  FCpf := aValue;
end;

procedure TCliente.setEmail(aValue: String);
begin
  FEmail := aValue;
end;

procedure TCliente.setEstado(const Value: String);
begin
  FEstado := Value;
end;

//procedure TCliente.setEndereco(const Value: TEndereco);
//begin
//  FEndereco := Value;
//end;

procedure TCliente.setIdentidade(aValue: String);
begin
  FIdentidade := aValue;
end;

class procedure TCliente.setInstancia(const Value: TCliente);
begin
  FInstancia := Value;
end;

procedure TCliente.setLogradouro(const Value: String);
begin
  FLogradouro := Value;
end;

procedure TCliente.setNome(aValue: String);
begin
  FNome := aValue;
end;

procedure TCliente.setNumero(const Value: String);
begin
  FNumero := Value;
end;

procedure TCliente.setpais(const Value: String);
begin
  Fpais := Value;
end;

procedure TCliente.setTelefone(aValue: String);
begin
  FTelefone := aValue;
end;

end.
