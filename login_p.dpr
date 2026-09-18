program login_p;

uses
  Vcl.Forms,
  login_u in 'login_u.pas' {frmLogin},
  admins_u in 'admins_u.pas' {frmAdmin},
  customers_u in 'customers_u.pas' {frmCustomers},
  dispatchers_u in 'dispatchers_u.pas' {frmDispatchers},
  Vcl.Themes,
  Vcl.Styles,
  dmPAT2026 in 'dmPAT2026.pas' {dmPAT2026_1: TDataModule},
  validation_u in 'validation_u.pas',
  clsOrders in 'clsOrders.pas',
  clsGarment in 'clsGarment.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Aqua Light Slate');
  Application.CreateForm(TdmPAT2026_1, dmPAT2026_1);
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmAdmin, frmAdmin);
  Application.CreateForm(TfrmCustomers, frmCustomers);
  Application.CreateForm(TfrmDispatchers, frmDispatchers);
  Application.Run;
end.
