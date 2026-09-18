unit login_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, admins_u, customers_u, dispatchers_u,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Imaging.jpeg, Vcl.ExtCtrls, Vcl.Mask,
  dmPAT2026, validation_u;

type
  TfrmLogin = class(TForm)
    pgcOne: TPageControl;
    tbsWelcome: TTabSheet;
    tbsLogin: TTabSheet;
    tbsNewConsumer: TTabSheet;
    imgWelcome: TImage;
    imgBackground1: TImage;
    Image1: TImage;
    btnLogin: TButton;
    btnNewC: TButton;
    lbdtUsername: TLabeledEdit;
    lbdtPassword1: TLabeledEdit;
    btnEnter1: TButton;
    btnBack1: TButton;
    lbdtName: TLabeledEdit;
    lbdtSurname: TLabeledEdit;
    lbdtUsername1: TLabeledEdit;
    lbdtPassword: TLabeledEdit;
    btnRegister: TButton;
    btnBack2: TButton;
    radCity: TRadioGroup;
    btnTesterPrefill_A: TButton;
    btnTesterPrefill_D: TButton;
    btnTesterPrefill_C: TButton;
    procedure btnLoginClick(Sender: TObject);
    procedure btnNewCClick(Sender: TObject);
    procedure btnBack1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    //procedure Button1Click(Sender: TObject);
    procedure btnEnter1Click(Sender: TObject);
    procedure btnBack2Click(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure pgcOneChanging(Sender: TObject; var AllowChange: Boolean);
    procedure btnTesterPrefill_AClick(Sender: TObject);
    procedure btnTesterPrefill_DClick(Sender: TObject);
    procedure btnTesterPrefill_CClick(Sender: TObject);
  private
    { Private declarations }
    user: string;
    FAllowTabChange: Boolean;
    procedure GoToTab(iPage: integer);
    function NextConsumerID(const sCityCode: string): string;
    procedure ClearLoginFields;
    procedure ClearRegisterFields;
    //procedure Button1Click(Sender: TObject);
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;
  // frmAdmin: TfrmAdmin;
  // frmDispatchers: TfrmDispatchers;
  // frmCustomers: TfrmCustomers;

implementation

{$R *.dfm}

procedure TfrmLogin.btnBack1Click(Sender: TObject);
begin
  GoToTab(0);
  ClearLoginFields;
end;

procedure TfrmLogin.btnBack2Click(Sender: TObject);
begin
  GoToTab(0);
  ClearRegisterFields
end;

procedure TfrmLogin.btnEnter1Click(Sender: TObject);
var
  iLoop: integer;
  bIsUser: boolean;
  sUsername, sPassword, sRole, sUserID, sFullName: string;
begin
  sUsername := lbdtUsername.Text;
  sPassword := lbdtPassword1.Text;

  bIsUser := False;

  if sUsername = '' then
    showmessage('Please enter your username.')
  else if sPassword = '' then
    showmessage('Please enter your password.')
  else
  begin
    with dmPAT2026_1 do
    try
      // A parameterised query replaces the record-by-record
      // loop: the database finds the row, and an apostrophe in
      // a username cannot break the statement.
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text :=
        'SELECT UserID, User_Name, User_Surname, Role FROM tblUsers ' +
        'WHERE Username = :pUser AND Password = :pPass';
      qryMain.Parameters.ParamByName('pUser').Value := sUsername;
      qryMain.Parameters.ParamByName('pPass').Value := sPassword;
      qryMain.Open;

      if qryMain.RecordCount > 0 then
      begin
        bIsUser   := True;
        sUserID   := qryMain.FieldByName('UserID').AsString;
        sRole     := qryMain.FieldByName('Role').AsString;
        sFullName := qryMain.FieldByName('User_Name').AsString + ' ' +
                     qryMain.FieldByName('User_Surname').AsString;
      end;

      qryMain.Close;
    except
      on E: Exception do
        showmessage('The login could not be checked.' + #13#10 + E.Message);
    end;

    if bIsUser then
    begin
      showmessage('Welcome back ' + sFullName);


      if sRole = 'Admin' then
      begin
        frmAdmin.ShowModal;
      end
      else if sRole = 'Consumer' then
      begin
        frmCustomers.userID := sUserID;
        frmCustomers.ShowModal;
      end
      else if sRole = 'Dispatcher' then
      begin
        frmDispatchers.ShowModal;
      end
      else
        showmessage('Your account has an unrecognised role (' + sRole +
          '). Please contact an administrator.');


      ClearLoginFields;
      GoToTab(0);
    end
    else if MessageDlg('Those details do not match an account. ' +
      'Would you like to create one?', mtConfirmation, [mbYes, mbNo], 0)
      = mrYes then
    begin
      ClearLoginFields;
      GoToTab(2);
    end
    else
      ClearLoginFields;
  end;

  end;


procedure TfrmLogin.btnLoginClick(Sender: TObject);
begin
  GoToTab(1);
end;

procedure TfrmLogin.btnNewCClick(Sender: TObject);
begin
  GoToTab(2);
end;

procedure TfrmLogin.btnRegisterClick(Sender: TObject);
var
  sName_u, sSurname, sUsername, sPassword, sCity, sCity_code: string;
  iInc_for_id: integer;
  iLoop: integer;
begin
  case radCity.ItemIndex of
    -1:
      begin
        showmessage('You must select a city!');
        exit;
      end;
    0:
      sCity_code := 'PTA';
    1:
      sCity_code := 'JHB';
    2:
      sCity_code := 'CPT';
    3:
      sCity_code := 'PLZ';
    4:
      sCity_code := 'DBN';
    5:
      sCity_code := 'NLP';
    6:
      sCity_code := 'BFN';
  end;

  if ((validateStr(lbdtName.Text) = True) AND (presence(lbdtName.Text) = True))
    and ((validateStr(lbdtSurname.Text) = True) AND
    (presence(lbdtSurname.Text) = True)) AND
    ((validateusername(lbdtUsername1.Text) = True) AND
    (presence(lbdtUsername1.Text) = True) AND
    ((validatePassword(lbdtPassword.Text) = True) AND
    (presence(lbdtPassword.Text) = True))) then
  begin
    sname_u := lbdtName.Text;
    ssurname := lbdtSurname.Text;
    susername := lbdtUsername1.Text;
    spassword := lbdtPassword.Text;
    scity := radCity.items[radCity.ItemIndex];
  end
  else
  begin
    showmessage('Invalid input. Please try again.');
    exit;
  end;

  with dmPAT2026_1 do
  begin
    qryMain.SQL.Text := 'select * from tblUsers where Username = ' +
      quotedstr(susername) + ' OR Password = ' + quotedstr(spassword);
    qryMain.Open;

    if qryMain.RecordCount = 0 then
    begin
      tblUsers.Open;
      tblUsers.Last;
      tblUsers.Insert;

      tblUsers['UserID'] := NextConsumerID(scity);
      tblUsers['Username'] := susername;
      tblUsers['User_Name'] := sname_u;
      tblUsers['User_surname'] := ssurname;
      tblUsers['City'] := scity;
      tblUsers['Password'] := spassword;
      tblUsers['Budget'] := 0.00;
      tblUsers['Role'] := 'Consumer';

      tblUsers.Post;
      tblUsers.Close;

      showmessage('Account succesfully create! Welcome to Opticorp, ' + sname_u + ' ' + ssurname);
      frmCustomers.ShowModal;
      GoToTab(0);
      ClearRegisterFields;
    end;
  end;
end;

procedure TfrmLogin.btnTesterPrefill_AClick(Sender: TObject);
begin
  lbdtUsername.Text := 'sys_vharrison';
  lbdtPassword1.text := 'vH@rr1s0n!X';
end;

procedure TfrmLogin.btnTesterPrefill_CClick(Sender: TObject);
begin
  lbdtUsername.Text := 'j.smith_88';
  lbdtPassword1.text := 'J@yS_88L0g';
end;

procedure TfrmLogin.btnTesterPrefill_DClick(Sender: TObject);
begin
  lbdtUsername.Text := 'dsp_cape';
  lbdtPassword1.text := 'CptLog!stics9';
end;


procedure TfrmLogin.ClearLoginFields;
begin
  lbdtUsername.Clear;
  lbdtPassword1.Clear;
end;

procedure TfrmLogin.ClearRegisterFields;
begin
  lbdtName.Clear;
  lbdtSurname.Clear;
  lbdtUsername1.Clear;
  lbdtPassword.Clear;
  radCity.ItemIndex := -1;
end;

procedure TfrmLogin.FormActivate(Sender: TObject);
begin
  {tbsWelcome.TabVisible := False;
  tbsLogin.TabVisible := False;
  tbsNewConsumer.TabVisible := False;}

  pgcOne.ActivePageIndex := 0;

  with dmPAT2026_1 do
  begin
    tblBrands.Active := True;
    tblBrands.Open;
    tblBrands.First;

    tblWardrobes.Active := True;
    tblWardrobes.Open;
    tblWardrobes.First;

    tblUsers.Active := True;
    tblUsers.Open;
    tblUsers.First;

    tblOrders.Active := True;
    tblOrders.Open;
    tblOrders.First;

    tblTrucks.Active := True;
    tblTrucks.Open;
    tblTrucks.First;

    tblInventory.Active := True;
    tblInventory.Open;
    tblInventory.First;

    tblWarehouses.Active := True;
    tblWarehouses.Open;
    tblWarehouses.First;
  end;

end;

procedure TfrmLogin.GoToTab(iPage: integer);
begin
  fAllowTabChange := True;
  try
    pgcOne.ActivePageIndex := iPage;
  finally
    fAllowTabChange := False;     // always restored, even on error
  end;
end;

function TfrmLogin.NextConsumerID(const sCityCode: string): string;
var
  iHighest, iThis, iCode: integer;
  sNum: string;
begin
  iHighest := 100;          // so the first generated ID is 101

  with dmPAT2026_1 do
  try
    if qryMain.Active then
      qryMain.Close;
    qryMain.SQL.Text := 'SELECT UserID FROM tblUsers WHERE UserID LIKE :pPre';
    qryMain.Parameters.ParamByName('pPre').Value := 'CON-%';
    qryMain.Open;

    while not qryMain.Eof do
    begin
      sNum := Copy(qryMain.FieldByName('UserID').AsString, 5, 3);

      Val(sNum, iThis, iCode);
      if (iCode = 0) and (iThis > iHighest) then
        iHighest := iThis;
      qryMain.Next;
    end;
  finally
    if qryMain.Active then
      qryMain.Close;
  end;

  result := 'CON-' + IntToStr(iHighest + 1) + '-' + sCityCode;
end;

procedure TfrmLogin.pgcOneChanging(Sender: TObject; var AllowChange: Boolean);
begin
   AllowChange := FAllowTabChange;
end;

end.
