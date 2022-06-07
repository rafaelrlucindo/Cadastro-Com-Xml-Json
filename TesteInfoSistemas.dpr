program TesteInfoSistemas;

uses
  FastMM4,
  Vcl.Forms,
  untCadastro in 'untCadastro.pas' {frmCadastro},
  untClassCliente in 'Classes\untClassCliente.pas',
  untDaoGenerico in 'Classes\untDaoGenerico.pas',
  untEntidadeAtributos in 'Classes\untEntidadeAtributos.pas',
  untEntidadeGenerica in 'Classes\untEntidadeGenerica.pas',
  untClassUtils in 'Classes\untClassUtils.pas',
  untRegistro in 'untRegistro.pas' {frmRegistro};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmCadastro, frmCadastro);
  Application.Run;
  TAplicativo.instancia.Free;
end.


