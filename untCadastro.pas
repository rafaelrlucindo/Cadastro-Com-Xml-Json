unit untCadastro;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
  XMLDoc, untClassCliente, untEntidadeAtributos, untEntidadeGenerica, untDaoGenerico, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Imaging.pngimage, Xml.XMLIntf,
  System.Rtti, system.IOUtils, untClassUtils, untRegistro, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP, TypInfo, system.UITypes;

type
  TfrmCadastro = class(TForm)
    dbgClientes: TDBGrid;
    cdsClientes: TFDMemTable;
    dsClientes: TDataSource;
    cdsClientesNOME: TStringField;
    cdsClientesIDENTIDADE: TStringField;
    cdsClientesCPF: TStringField;
    cdsClientesTELEFONE: TStringField;
    cdsClientesEMAIL: TStringField;
    Panel1: TPanel;
    cdsClientesCAMINHO_XML: TStringField;
    Panel3: TPanel;
    imgNovo: TImage;
    imgEditar: TImage;
    imgExcluir: TImage;
    imgSair: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    shpSelecionado: TShape;
    procedure imgNovoClick(Sender: TObject);
    procedure imgEditarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dbgClientesDblClick(Sender: TObject);
    procedure imgSairClick(Sender: TObject);
    procedure imgExcluirClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure dbgClientesDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
  private
    { Private declarations }
    procedure carregaLista;
  public
    { Public declarations }
  end;

var
  frmCadastro: TfrmCadastro;

implementation

{$R *.dfm}

procedure TfrmCadastro.carregaLista;
  var
    xml1 : iXMLDocument;
    nodePrincipal : IXMLNode;
begin
  if not cdsClientes.Active then
    cdsClientes.Active := true
  else
    cdsClientes.EmptyDataSet;

  if TDirectory.Exists(TAplicativo.instancia.DiretorioXml) then
    begin
      for var strArquivo in TDirectory.GetFiles(TAplicativo.instancia.DiretorioXml) do
        begin
          xml1 := TXMLDocument.Create(nil);
          xml1.FileName := strArquivo;
          xml1.Active := True;

          nodePrincipal := xml1.DocumentElement.ChildNodes[0];
          nodePrincipal.ChildNodes.FindNode('nome').Text;

          cdsClientes.Append;
          cdsClientes.FieldByName('NOME').AsString := nodePrincipal.ChildNodes.FindNode('nome').Text;
          cdsClientes.FieldByName('IDENTIDADE').AsString := nodePrincipal.ChildNodes.FindNode('identidade').Text;
          cdsClientes.FieldByName('CPF').AsString := nodePrincipal.ChildNodes.FindNode('cpf').Text;
          cdsClientes.FieldByName('TELEFONE').AsString := nodePrincipal.ChildNodes.FindNode('telefone').Text;
          cdsClientes.FieldByName('EMAIL').AsString := nodePrincipal.ChildNodes.FindNode('email').Text;
          cdsClientes.FieldByName('CAMINHO_XML').AsString := strArquivo;
          cdsClientes.Post;
          xml1.Active := False;
        end;
    end;
end;

procedure TfrmCadastro.dbgClientesDblClick(Sender: TObject);
begin
  imgEditarClick(Sender);
end;

procedure TfrmCadastro.dbgClientesDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if gdSelected in state then
    begin
      dbgClientes.Canvas.Brush.Color := shpSelecionado.Brush.Color;
      dbgClientes.Canvas.Font.Color := clWhite;
      dbgClientes.Canvas.Font.Style := [TFontStyle.fsBold];
      dbgClientes.Canvas.FillRect(Rect);
      dbgClientes.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end
  else
    begin
      dbgClientes.Canvas.Brush.Color := $00DB9834;
      dbgClientes.Canvas.Font.Color := clBlack;
      dbgClientes.Canvas.Font.Style := [];
      dbgClientes.Canvas.FillRect(Rect);
      dbgClientes.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    end;
end;

procedure TfrmCadastro.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift = [] then
    case key of
      VK_F2 : imgNovoClick(Sender);
      VK_F3 : imgEditarClick(Sender);
      VK_F4 : imgExcluirClick(Sender);
      VK_ESCAPE : imgSairClick(Sender);
    end;
end;

procedure TfrmCadastro.FormShow(Sender: TObject);
begin
  carregaLista;
end;

procedure TfrmCadastro.imgNovoClick(Sender: TObject);
begin
  frmRegistro := TfrmRegistro.Create(Self, '');

  with frmRegistro do
    try
      ShowModal;

      if ModalResult = mrOk then
        carregaLista;
    finally
      Free;
    end;
end;

procedure TfrmCadastro.imgSairClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmCadastro.imgEditarClick(Sender: TObject);
begin
  if not cdsClientes.IsEmpty then
    begin
      frmRegistro := TfrmRegistro.Create(Self, cdsClientes.FieldByName('CAMINHO_XML').AsString);

      with frmRegistro do
        try
          ShowModal;

          if ModalResult = mrOk then
            carregaLista;
        finally
          Free;
        end;
    end;
end;

procedure TfrmCadastro.imgExcluirClick(Sender: TObject);
begin
  if Application.MessageBox('Deseja excluir?', 'Exclusão', MB_YESNO + MB_ICONQUESTION) = 6 then
    begin
      TFile.Delete(cdsClientes.FieldByName('CAMINHO_XML').AsString);
      carregaLista;

      Application.MessageBox('Cliente deletado!', 'Deletado', +MB_OK +MB_ICONQUESTION);
    end
  else
    ShowMessage('Ação cancelada');
end;

end.

