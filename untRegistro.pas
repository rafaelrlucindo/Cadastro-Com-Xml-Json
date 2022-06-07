unit untRegistro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, untClassCliente,
  Vcl.AppEvnts, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdServerIOHandler,
  IdSSL, IdSSLOpenSSL, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, Json, Data.DBXJSON, Vcl.ComCtrls,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP, IdMessage, IdAttachmentFile,
  rtti, TypInfo, Vcl.Imaging.GIFImg;

type
//  TThreadAtualizaBusca = class(TThread)
//    public
//      procedure execute; override;
//  end;

  TfrmRegistro = class(TForm)
    pnlTitulo: TPanel;
    ApplicationEvents1: TApplicationEvents;
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    IdSMTP1: TIdSMTP;
    pnlDados: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    edtNome: TEdit;
    edtIdentidade: TEdit;
    edtCpf: TEdit;
    edtTelefone: TEdit;
    edtEmail: TEdit;
    btnCancelar: TBitBtn;
    btnOk: TBitBtn;
    grpEndereco: TGroupBox;
    Label11: TLabel;
    Label10: TLabel;
    Label9: TLabel;
    Label8: TLabel;
    Label7: TLabel;
    Label6: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    imgLoading: TImage;
    edtNumero: TEdit;
    edtEstado: TEdit;
    edtCidade: TEdit;
    edtBairro: TEdit;
    edtCep: TEdit;
    edtLogradouro: TEdit;
    edtComplemento: TEdit;
    edtPais: TEdit;
    Label4: TLabel;
    pnlSendEmail: TPanel;
    imgSendEmail: TImage;
    Label14: TLabel;
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
    procedure edtCepExit(Sender: TObject);
  private
    { Private declarations }
    FArquivo : string;
    procedure enviarEmail(aEmail,  aArquivo:String);
  public
      constructor Create(AOwner: TComponent; aArquivo :String=''); reintroduce;

  end;

var
  frmRegistro: TfrmRegistro;

implementation

uses
  Xml.XMLIntf, Xml.XMLDoc, IdGlobal, IdMessageParts;

{$R *.dfm}

procedure TfrmRegistro.ApplicationEvents1Idle(Sender: TObject; var Done: Boolean);
begin
  if (edtNome.Text = '') or (edtIdentidade.Text = '') or (edtCpf.Text = '')
    or (edtTelefone.Text = '') or (edtEmail.Text = '') then
    btnOk.Enabled := False
  else
    btnOk.Enabled := True;
end;

procedure TfrmRegistro.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrClose;
end;

procedure TfrmRegistro.btnOkClick(Sender: TObject);
  var
    prop : TRttiProperty;
    context : TRttiContext;
    typ  : TRttiType;
    aComponente : TComponent;
begin
  try
    pnlDados.Visible := False;
    pnlSendEmail.Visible := True;

    context := TRttiContext.Create;
    typ  := context.GetType(TObject(TCliente.instancia).ClassInfo);

    TCliente.instancia;

    for prop in typ.GetProperties do
      begin
        if TEdit(FindComponent('edt' + prop.Name)) <> nil then
          begin
            aComponente := FindComponent('edt' + prop.Name);
            prop.SetValue(Pointer(TCliente.instancia), TEdit(aComponente).Text);
          end;
      end;

    TCliente.instancia.arquivo := FArquivo;
    TCliente.instancia.insere;

    if TCliente.instancia.email <> '' then
      try
        tthread.CreateAnonymousThread(procedure
          begin
            enviarEmail(TCliente.instancia.email, TCliente.instancia.email);

            tthread.Synchronize(tthread.Current, procedure
              begin
                Application.MessageBox('Cliente adicionado.', 'Adicionado', + MB_OK + MB_ICONINFORMATION);
                ModalResult := mrOk;
              end);
          end).Start;
      except
        // continua
      end;
  except
    pnlDados.Visible := True;
    pnlSendEmail.Visible := False;
  end;
end;

constructor TfrmRegistro.Create(AOwner: TComponent; aArquivo :String='');
begin
  inherited Create(AOwner);
  FArquivo := aArquivo;
end;

procedure TfrmRegistro.edtCepExit(Sender: TObject);
  var
    stRetorno : TStringStream;
begin
  if edtCep.Text <> '' then
    begin
      TThread.CreateAnonymousThread(procedure
        begin
          try
            tthread.Synchronize(TThread.Current, procedure
              begin
                frmRegistro.imgLoading.Visible := True;
              end);

            stRetorno := TStringStream.Create;
            stRetorno.Seek(0, 0);
            IdHTTP1.Get('https://viacep.com.br/ws/' + edtCep.Text + '/json/', stRetorno);

            TThread.Synchronize(TThread.Current, procedure
              begin
                if IdHTTP1.ResponseCode = 200 then
                  begin
                    frmRegistro.imgLoading.Visible := False;
                    frmRegistro.edtLogradouro.Text := UTF8ToString(TJsonObject.ParseJSONValue(stRetorno.DataString).FindValue('logradouro').Value);
                    frmRegistro.edtComplemento.Text := TJsonObject.ParseJSONValue(stRetorno.DataString).FindValue('complemento').Value;
                    frmRegistro.edtBairro.Text := TJsonObject.ParseJSONValue(stRetorno.DataString).FindValue('bairro').Value;
                    frmRegistro.edtCidade.Text := TJsonObject.ParseJSONValue(stRetorno.DataString).FindValue('localidade').Value;
                    frmRegistro.edtEstado.Text := TJsonObject.ParseJSONValue(stRetorno.DataString).FindValue('uf').Value;
                    frmRegistro.edtPais.Text := TJsonObject.ParseJSONValue(stRetorno.DataString).FindValue('pais').Value;
                    stRetorno.Free;
                  end;
              end);
          except
            frmRegistro.imgLoading.Visible := False;
            // continue
          end;
        end).start;

    end;
end;

procedure TfrmRegistro.enviarEmail(aEmail, aArquivo:String);
  var
    idSmtp: TIdSMTP;
    mensagem: TIdMessage;
    SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  idSmtp := TIdSMTP.Create(nil);
  mensagem := TIdMessage.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  try
    SSLHandler.MaxLineAction := tidMaxLineAction.maException;
    SSLHandler.SSLOptions.Method := sslvTLSv1;
    SSLHandler.SSLOptions.Mode := sslmUnassigned;
    SSLHandler.SSLOptions.VerifyMode := [];
    SSLHandler.SSLOptions.VerifyDepth := 0;

    idSmtp.IOHandler := SSLHandler;
    idSmtp.Host := 'smtp.gmail.com';
    idSmtp.Port := 587;
    idSmtp.Username := 'rafaelrlucindo@gmail.com';
    idSmtp.Password := 'moffownxvsjesfzl';
    idSmtp.UseTLS := utUseExplicitTLS;

    mensagem.From.Address := 'rafaelrlucindo@gmail.com';
    mensagem.Recipients.EmailAddresses := aEmail;
    mensagem.Subject := 'Novo cliente Cadastrado';
    mensagem.Body.Text := 'Novo cliente Cadastrado';
    TIdAttachmentFile.Create(mensagem.MessageParts, FArquivo);

    idSmtp.Connect;
    idSmtp.Send(mensagem);
    idSmtp.Disconnect;

  finally
    idSmtp.Free;
    mensagem.Free;
    SSLHandler.Free;
  end;
end;

procedure TfrmRegistro.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift = [] then
    case key of
      VK_RETURN : Perform(WM_NEXTDLGCTL, 0, 0);
      VK_F4 : btnOkClick(Sender);
      VK_F5 : btnCancelarClick(Sender);
    end;
end;

procedure TfrmRegistro.FormShow(Sender: TObject);
  var
    xml : IXMLDocument;
    nodePrincipal, nodeEndereco : IXMLNode;
begin
  (imgLoading.Picture.Graphic as TGIFImage).Animate := True;
  (imgSendEmail.Picture.Graphic as TGIFImage).Animate := True;

  if FArquivo <> '' then
    begin
      xml := TXMLDocument.Create(nil);
      xml.FileName := FArquivo;
      xml.Active := True;

      nodePrincipal := xml.DocumentElement.ChildNodes[0];
      edtNome.Text := nodePrincipal.ChildNodes.FindNode('nome').Text;
      edtIdentidade.Text := nodePrincipal.ChildNodes.FindNode('identidade').Text;
      edtCpf.Text := nodePrincipal.ChildNodes.FindNode('cpf').Text;
      edtTelefone.Text := nodePrincipal.ChildNodes.FindNode('telefone').Text;
      edtEmail.Text := nodePrincipal.ChildNodes.FindNode('email').Text;

      nodeEndereco :=  nodePrincipal.ChildNodes['ENDERECO'];
      edtLogradouro.Text := nodeEndereco.ChildNodes.FindNode('logradouro').Text;
      edtNumero.Text := nodeEndereco.ChildNodes.FindNode('numero').Text;
      edtComplemento.Text := nodeEndereco.ChildNodes.FindNode('complemento').Text;
      edtBairro.Text := nodeEndereco.ChildNodes.FindNode('bairro').Text;
      edtCidade.Text := nodeEndereco.ChildNodes.FindNode('cidade').Text;
      edtEstado.Text := nodeEndereco.ChildNodes.FindNode('estado').Text;
      edtPais.Text := nodeEndereco.ChildNodes.FindNode('pais').Text;
    end;

  edtNome.SetFocus;
end;

end.
