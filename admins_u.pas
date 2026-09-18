unit admins_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, dmPAT2026,
  Vcl.Mask, Vcl.Samples.Spin, validation_u, math, Vcl.Imaging.pngimage;

type
  TfrmAdmin = class(TForm)
    pgcAdmin: TPageControl;
    tbsAdmin: TTabSheet;
    tbsUsers: TTabSheet;
    tbsBrands: TTabSheet;
    tbsWarehouses: TTabSheet;
    Image1: TImage;
    RichEdit1: TRichEdit;
    btnUsers: TButton;
    btnBrands: TButton;
    btnInventory: TButton;
    btnTrucks: TButton;
    btnWarehouses: TButton;
    tbsInventory: TTabSheet;
    tbsTrucks: TTabSheet;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Panel1: TPanel;
    dbgUsers_Admin: TDBGrid;
    lbdtUserID: TLabeledEdit;
    lbdtUsername: TLabeledEdit;
    lbdtName: TLabeledEdit;
    lbdtSurname: TLabeledEdit;
    lbdtCity: TLabeledEdit;
    lbdtPassword: TLabeledEdit;
    lbdtBudget: TLabeledEdit;
    lbdtRole: TLabeledEdit;
    btnUserEdit: TButton;
    btnUserDelete: TButton;
    dbgBrands_Admin: TDBGrid;
    Panel2: TPanel;
    btnBrandAdd: TButton;
    lbdtBrandID: TLabeledEdit;
    lbdtBrandName: TLabeledEdit;
    lbdtBrandEmail: TLabeledEdit;
    btnWarehouseAdd: TButton;
    dbgWarehouses_Admin: TDBGrid;
    Panel3: TPanel;
    lbdtWarehouseID: TLabeledEdit;
    lbdtWBrandID: TLabeledEdit;
    lbdtLocName: TLabeledEdit;
    lbdtXCoord: TLabeledEdit;
    lbdtYCoord: TLabeledEdit;
    btnInventoryAdd: TButton;
    dbgInventory_Admin: TDBGrid;
    Panel4: TPanel;
    lbdtItemID: TLabeledEdit;
    lbdtIBrandID: TLabeledEdit;
    lbdtItemName: TLabeledEdit;
    lbdtCat: TLabeledEdit;
    lbdtColour: TLabeledEdit;
    lbdtPrice: TLabeledEdit;
    sedFormality: TSpinEdit;
    sedVol: TSpinEdit;
    sedWeight: TSpinEdit;
    sedWarmth: TSpinEdit;
    sedStock: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    btnInventoryEdit: TButton;
    btnTruckAdd: TButton;
    dbgTrucks_Admin: TDBGrid;
    Panel5: TPanel;
    lbdtVehicleID: TLabeledEdit;
    lbdtReg: TLabeledEdit;
    lbdtVehType: TLabeledEdit;
    lbdtStatus: TLabeledEdit;
    sedMaxW: TSpinEdit;
    sedMaxV: TSpinEdit;
    Label6: TLabel;
    Label7: TLabel;
    btnHandleRequests: TButton;
    redRequest: TRichEdit;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    procedure FormActivate(Sender: TObject);
    // -- navigation --
    procedure btnUsersClick(Sender: TObject);
    procedure btnBrandsClick(Sender: TObject);
    procedure btnInventoryClick(Sender: TObject);
    procedure btnTrucksClick(Sender: TObject);
    procedure btnWarehousesClick(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure Image8Click(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    // -- requests --
    procedure btnHandleRequestsClick(Sender: TObject);
    // -- users --
    procedure dbgUsers_AdminCellClick(Column: TColumn);
    procedure btnUserEditClick(Sender: TObject); // USERS      - EDIT
    procedure btnUserDeleteClick(Sender: TObject); // USERS      - DELETE
    // -- brands --
    procedure dbgBrands_AdminCellClick(Column: TColumn);
    procedure btnBrandAddClick(Sender: TObject); // BRANDS     - ADD
    // -- warehouses --
    procedure dbgWarehouses_AdminCellClick(Column: TColumn);
    procedure Button5Click(Sender: TObject); // WAREHOUSES - ADD
    // -- inventory --
    procedure dbgInventory_AdminCellClick(Column: TColumn);
    procedure btnInventoryAddClick(Sender: TObject); // INVENTORY  - ADD
    procedure btnInventoryEditClick(Sender: TObject); // INVENTORY  - EDIT
    // -- trucks --
    procedure dbgTrucks_AdminCellClick(Column: TColumn);
    procedure btnTruckAddClick(Sender: TObject);
    procedure pgcAdminChanging(Sender: TObject; var AllowChange: Boolean); // TRUCKS     - ADD
  private
    { Private declarations }
    FAllowTabChange: boolean;

    bRandomised: boolean;
    sSelUserID, sSelBrandID, sSelWarehouseID: string;
    sSelItemID, sSelVehicleID: string;

    procedure SetColWidth(dbg: TDBGrid; const fieldName: string;
      width: Integer);
    procedure ApplyGridFont(dbg: TDBGrid);

    // -- validation (named Is... so they cannot clash with validation_u) --
    function IsAlphaSpace(const s: string): boolean;
    function IsValidID(const s: string): boolean;
    function IsValidEmail(const s: string): boolean;
    function IsValidUsername(const s: string): boolean;
    function IsValidPassword(const s: string): boolean;
    function IsValidReal(const s: string; out r: double): boolean;
    function IsValidCity(const s: string): boolean;
    function IsValidRole(const s: string): boolean;
    function IsValidStatus(const s: string): boolean;

    // -- database helpers --
    function RecordExists(const sTable, sField, sValue: string): boolean;
    function DuplicateElsewhere(const sField, sValue, sIgnoreUserID
      : string): boolean;
    function CountAdmins: Integer;
    function UserHasOpenOrders(const sUserID: string): boolean;
    procedure RefreshTable(tbl: TDataSet);

    // -- ui helpers --
    procedure ClearUserFields;
    procedure ClearBrandFields;
    procedure ClearWarehouseFields;
    procedure ClearInventoryFields;
    procedure ClearTruckFields;
  public
    { Public declarations }
  end;

var
  frmAdmin: TfrmAdmin;

implementation

{$R *.dfm}
// ============================================================
// VALIDATION
// 'presence' comes from validation_u. The rest live here so
// they cannot clash with anything already in that unit - move
// them across later if you prefer them centralised.
// ============================================================

// Letters, spaces, hyphens and apostrophes.
// Accepts 'van der Merwe', 'O''Brien', 'Anne-Marie'.
function TfrmAdmin.IsAlphaSpace(const s: string): boolean;
var
  i: Integer;
begin
  Result := false;
  if Trim(s) = '' then
    exit;
  for i := 1 to Length(s) do
    if not CharInSet(s[i], ['a' .. 'z', 'A' .. 'Z', ' ', '-', '''']) then
      exit;
  Result := true;
end;

// Uppercase letters, digits and hyphens only (WH-OPT-HQ, ADI)
function TfrmAdmin.IsValidID(const s: string): boolean;
var
  i: Integer;
begin
  Result := false;
  if Trim(s) = '' then
    exit;
  for i := 1 to Length(s) do
    if not CharInSet(s[i], ['A' .. 'Z', '0' .. '9', '-']) then
      exit;
  Result := true;
end;

// '@' not first or last, a '.' after the '@', and no spaces
function TfrmAdmin.IsValidEmail(const s: string): boolean;
var
  iAt, iDot: Integer;
begin
  Result := false;
  if Pos(' ', s) > 0 then
    exit;
  iAt := Pos('@', s);
  if (iAt < 2) or (iAt = Length(s)) then
    exit;
  iDot := Pos('.', Copy(s, iAt, Length(s)));
  if iDot < 2 then
    exit;
  Result := true;
end;

// Min 3 chars; letters, digits, underscore and full stop; no spaces
function TfrmAdmin.IsValidUsername(const s: string): boolean;
var
  i: Integer;
  flag: boolean;
begin
  Result := false;
  if Length(Trim(s)) < 3 then
    exit;

  i := 0;
  flag := false;

  while (i < length(s)) AND (flag = false) do
  begin
    inc(i);
    if not CharInSet(s[i], ['a' .. 'z', 'A' .. 'Z', '0' .. '9', '_', '.']) then
      flag := true;
  end;
  Result := true;
end;

procedure TfrmAdmin.pgcAdminChanging(Sender: TObject; var AllowChange: Boolean);
begin
  AllowChange := FAllowTabChange;
end;

// 8-4 rule: at least 8 characters and all four character types
function TfrmAdmin.IsValidPassword(const s: string): boolean;
var
  i: Integer;
  bUp, bLo, bDig, bSpec: boolean;
begin
  Result := false;
  if Length(s) < 8 then
    exit;

  bUp := false;
  bLo := false;
  bDig := false;
  bSpec := false;

  for i := 1 to Length(s) do
  begin
    if s[i] = ' ' then
      exit; // no spaces in passwords
    if CharInSet(s[i], ['A' .. 'Z']) then
      bUp := true
    else if CharInSet(s[i], ['a' .. 'z']) then
      bLo := true
    else if CharInSet(s[i], ['0' .. '9']) then
      bDig := true
    else
      bSpec := true;
  end;

  Result := bUp and bLo and bDig and bSpec;
end;

// Numeric check that can never raise. Strips R and spaces first,
// so a Budget shown as 'R12 500,00' still converts.
function TfrmAdmin.IsValidReal(const s: string; out r: double): boolean;
var
  sClean: string;
  i: Integer;
begin
  r := 0;
  sClean := '';
  for i := 1 to Length(s) do
    if not CharInSet(s[i], ['R', 'r', ' ']) then
      sClean := sClean + s[i];

  sClean := Trim(sClean);
  if sClean = '' then
    sClean := '0';

  Result := TryStrToFloat(sClean, r);
  if Result and (r < 0) then
    Result := false; // no negative amounts
end;

function TfrmAdmin.IsValidCity(const s: string): boolean;
begin
  Result := (s = 'Pretoria') or (s = 'Johannesburg') or (s = 'Cape Town') or
    (s = 'Durban') or (s = 'Port Elizabeth') or (s = 'Nelspruit') or
    (s = 'Bloemfontein');
end;

function TfrmAdmin.IsValidRole(const s: string): boolean;
begin
  Result := (s = 'Admin') or (s = 'Dispatcher') or (s = 'Consumer');
end;

function TfrmAdmin.IsValidStatus(const s: string): boolean;
begin
  Result := (s = 'Available') or (s = 'On Route') or (s = 'Maintenance');
end;

// ============================================================
// DATABASE HELPERS
// ============================================================

// Generic parameterised existence check.
// Table and field names are supplied by this unit only, never by
// the user, so building them into the string is safe.
function TfrmAdmin.RecordExists(const sTable, sField, sValue: string): boolean;
begin
  Result := false;
  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text := 'SELECT ' + sField + ' FROM ' + sTable + ' WHERE ' +
        sField + ' = :pVal';
      qryMain.Parameters.ParamByName('pVal').Value := sValue;
      qryMain.Open;
      Result := qryMain.RecordCount > 0;
    finally
      if qryMain.Active then
        qryMain.Close;
    end;
end;

// Is this value used by SOME OTHER user? Used when editing, so a
// record cannot clash with itself.
function TfrmAdmin.DuplicateElsewhere(const sField, sValue,
  sIgnoreUserID: string): boolean;
begin
  Result := false;
  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text := 'SELECT UserID FROM tblUsers WHERE ' + sField +
        ' = :pVal AND UserID <> :pID';
      qryMain.Parameters.ParamByName('pVal').Value := sValue;
      qryMain.Parameters.ParamByName('pID').Value := sIgnoreUserID;
      qryMain.Open;
      Result := qryMain.RecordCount > 0;
    finally
      if qryMain.Active then
        qryMain.Close;
    end;
end;

function TfrmAdmin.CountAdmins: Integer;
begin
  Result := 0;
  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text :=
        'SELECT COUNT(*) AS AdminCount FROM tblUsers WHERE Role = :pRole';
      qryMain.Parameters.ParamByName('pRole').Value := 'Admin';
      qryMain.Open;
      if not qryMain.Eof then
        Result := qryMain.FieldByName('AdminCount').AsInteger;
    finally
      if qryMain.Active then
        qryMain.Close;
    end;
end;

function TfrmAdmin.UserHasOpenOrders(const sUserID: string): boolean;
begin
  Result := false;
  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text := 'SELECT OrderID FROM tblOrders ' +
        'WHERE UserID = :pID AND Status <> :pStatus';
      qryMain.Parameters.ParamByName('pID').Value := sUserID;
      qryMain.Parameters.ParamByName('pStatus').Value := 'Delivered';
      qryMain.Open;
      Result := qryMain.RecordCount > 0;
    finally
      if qryMain.Active then
        qryMain.Close;
    end;
end;

procedure TfrmAdmin.RefreshTable(tbl: TDataSet);
begin
  if tbl.Active then
    tbl.Close;
  tbl.Open;
end;

// ============================================================
// CLEAR-FIELD HELPERS
// ============================================================

procedure TfrmAdmin.ClearUserFields;
begin
  sSelUserID := '';
  lbdtUserID.Clear;
  lbdtUsername.Clear;
  lbdtName.Clear;
  lbdtSurname.Clear;
  lbdtCity.Clear;
  lbdtPassword.Clear;
  lbdtBudget.Text := '0.00';
  lbdtRole.Clear;
  lbdtUserID.ReadOnly := true; // primary key is never hand-edited
  btnUserEdit.Enabled := false;
  btnUserDelete.Enabled := false;
end;

procedure TfrmAdmin.ClearBrandFields;
begin
  sSelBrandID := '';
  lbdtBrandID.Clear;
  lbdtBrandName.Clear;
  lbdtBrandEmail.Clear;
end;

procedure TfrmAdmin.ClearWarehouseFields;
begin
  sSelWarehouseID := '';
  lbdtWarehouseID.Clear; // WarehouseID
  lbdtWBrandID.Clear; // BrandID
  lbdtLocName.Clear; // Location Name
  lbdtXCoord.Clear; // X-Coordinate
  lbdtYCoord.Clear; // Y-Coordinate
end;

procedure TfrmAdmin.ClearInventoryFields;
begin
  sSelItemID := '';
  lbdtItemID.Clear; // ItemID
  lbdtIBrandID.Clear; // BrandID
  lbdtItemName.Clear; // Item Name
  lbdtCat.Clear; // Category
  lbdtColour.Clear; // Colour Family
  lbdtPrice.Clear; // Price
  sedWarmth.Value := 1; // Warmth Rating
  sedFormality.Value := 1; // Formality Score
  sedWeight.Value := 1; // Weight
  sedVol.Value := 1; // Volume
  sedStock.Value := 0; // Quantity Stock
  btnInventoryEdit.Enabled := false;
end;

procedure TfrmAdmin.ClearTruckFields;
begin
  sSelVehicleID := '';
  lbdtVehicleID.Clear; // VehicleID
  lbdtReg.Clear; // Registration
  lbdtVehType.Clear; // Vehicle Type
  lbdtStatus.Clear; // Status
  sedMaxW.Value := 0; // Max Weight
  sedMaxV.Value := 0; // Max Volume
end;

// ============================================================
// FORM ACTIVATE
// ============================================================

procedure TfrmAdmin.FormActivate(Sender: TObject);
begin
  tbsAdmin.TabVisible := false;
  tbsUsers.TabVisible := false;
  tbsBrands.TabVisible := false;
  tbsWarehouses.TabVisible := false;
  tbsInventory.TabVisible := false;
  tbsTrucks.TabVisible := false;

  pgcAdmin.ActivePageIndex := 0;
  // Seed the random generator once per session
  if not bRandomised then
  begin
    Randomize;
    bRandomised := true;
  end;

  // 'if not Active then Open' - calling Open on an already-open
  // dataset raises an exception, and FormActivate fires every time
  // this form regains focus.
  with dmPAT2026_1 do
  begin
    if not tblBrands.Active then
      tblBrands.Open;
    if not tblWardrobes.Active then
      tblWardrobes.Open;
    if not tblUsers.Active then
      tblUsers.Open;
    if not tblOrders.Active then
      tblOrders.Open;
    if not tblTrucks.Active then
      tblTrucks.Open;
    if not tblInventory.Active then
      tblInventory.Open;
    if not tblWarehouses.Active then
      tblWarehouses.Open;
  end;

  ApplyGridFont(dbgUsers_Admin);
  SetColWidth(dbgUsers_Admin, 'Budget', 85); // was 'Bugdet' - field is Budget
  SetColWidth(dbgUsers_Admin, 'UserID', 95); // CON-109-NLP
  SetColWidth(dbgUsers_Admin, 'Username', 115); // dsp_gauteng2
  SetColWidth(dbgUsers_Admin, 'User_Name', 80); // Michelle
  SetColWidth(dbgUsers_Admin, 'User_Surname', 95); // van der Merwe
  SetColWidth(dbgUsers_Admin, 'City', 95); // Johannesburg
  SetColWidth(dbgUsers_Admin, 'Password', 120); // CptLog!stics9
  SetColWidth(dbgUsers_Admin, 'Role', 80);

  ApplyGridFont(dbgBrands_Admin);
  SetColWidth(dbgBrands_Admin, 'BrandID', 55); // ADI
  SetColWidth(dbgBrands_Admin, 'Brand_Name', 120); // The North Face
  SetColWidth(dbgBrands_Admin, 'Contact_Email', 190);

  ApplyGridFont(dbgInventory_Admin);
  SetColWidth(dbgInventory_Admin, 'ItemID', 130); // SHU-BLK-TIM-01
  SetColWidth(dbgInventory_Admin, 'BrandID', 55); // TIM
  SetColWidth(dbgInventory_Admin, 'Item_Name', 175); // Premium Waterproof Boots
  SetColWidth(dbgInventory_Admin, 'Category', 80); // Outerwear
  SetColWidth(dbgInventory_Admin, 'Color_Family', 70); // Orange
  SetColWidth(dbgInventory_Admin, 'Price', 80); // 35000.0000
  SetColWidth(dbgInventory_Admin, 'Quantity_Stock', 95); // 150
  SetColWidth(dbgInventory_Admin, 'Warmth_Rating', 95); // 10
  SetColWidth(dbgInventory_Admin, 'Formality_Score', 105); // 10
  SetColWidth(dbgInventory_Admin, 'Weight', 60); // 2.2
  SetColWidth(dbgInventory_Admin, 'Volume', 60);

  ApplyGridFont(dbgTrucks_Admin);
  SetColWidth(dbgTrucks_Admin, 'VehicleID', 95); // VEH-HVR-01
  SetColWidth(dbgTrucks_Admin, 'Vehicle_Reg', 90); // GP 987-654
  SetColWidth(dbgTrucks_Admin, 'Vehicle_Type', 135); // Sprinter Panel Van
  SetColWidth(dbgTrucks_Admin, 'Status', 80); // Maintenance
  SetColWidth(dbgTrucks_Admin, 'Max_Weight', 85); // 8500
  SetColWidth(dbgTrucks_Admin, 'Max_Volume', 85); // 60000

  ApplyGridFont(dbgWarehouses_Admin);
  SetColWidth(dbgWarehouses_Admin, 'WarehouseID', 95); // WH-OPT-HQ
  SetColWidth(dbgWarehouses_Admin, 'BrandID', 55); // OPT
  SetColWidth(dbgWarehouses_Admin, 'Location_Name', 185);
  // OptiCorp Central Mega-Hub
  SetColWidth(dbgWarehouses_Admin, 'X_Coordinates', 90); // 500
  SetColWidth(dbgWarehouses_Admin, 'Y_Coordinates', 90); // 500

  ClearUserFields;
  ClearBrandFields;
  ClearWarehouseFields;
  ClearInventoryFields;
  ClearTruckFields;

  redRequest.Clear;
end;

// ============================================================
// NAVIGATION
// Named tab sheets instead of ActivePageIndex numbers - if the
// tabs are ever reordered, named pages still go to the right one.
// ============================================================

procedure TfrmAdmin.btnUsersClick(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsUsers;
  finally
    FAllowTabChange := False;
  end;

  ClearUserFields;
end;

procedure TfrmAdmin.btnBrandsClick(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsBrands;
  finally
    FAllowTabChange := False;
  end;

  ClearBrandFields;
end;

procedure TfrmAdmin.btnWarehousesClick(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsWarehouses;
  finally
    FAllowTabChange := False;
  end;

  ClearWarehouseFields;
end;

procedure TfrmAdmin.btnInventoryClick(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsInventory;
  finally
    FAllowTabChange := False;
  end;

  ClearInventoryFields;
end;

procedure TfrmAdmin.btnTrucksClick(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsTrucks;
  finally
    FAllowTabChange := False;
  end;

  ClearTruckFields;
end;

procedure TfrmAdmin.Image7Click(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsAdmin;
  finally
    FAllowTabChange := False;
  end;

end;

procedure TfrmAdmin.Image8Click(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsAdmin;
  finally
    FAllowTabChange := False;
  end;

end;

procedure TfrmAdmin.Image9Click(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsAdmin;
  finally
    FAllowTabChange := False;
  end;

end;

procedure TfrmAdmin.Image10Click(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsAdmin;
  finally
    FAllowTabChange := False;
  end;

end;

procedure TfrmAdmin.Image11Click(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcAdmin.ActivePage := tbsAdmin;
  finally
    FAllowTabChange := False;
  end;

end;

// ============================================================
// HANDLE REQUESTS
// ============================================================

procedure TfrmAdmin.btnHandleRequestsClick(Sender: TObject);
var
  iRandomRequest: Integer;
  sFilePath, sLine: string;
  tf: TextFile;
  iHandle, iOther, i: integer;
begin
  iRandomRequest := RandomRange(1, 101); // 1..100
  sFilePath := ExtractFilePath(Application.ExeName) + 'requests\Request #' +
    IntToStr(iRandomRequest) + '.txt';

  // Guard: Reset on a missing file raises an unhandled EInOutError
  if not FileExists(sFilePath) then
  begin
    ShowMessage('Request file not found:' + #13#10 + sFilePath);
    exit;
  end;

  redRequest.Clear; // never stack requests

  AssignFile(tf, sFilePath);
  try
    Reset(tf);
    while not Eof(tf) do
    begin
      ReadLn(tf, sLine);
      redRequest.Lines.Add(sLine);
    end;
  finally
    CloseFile(tf); // always closes
  end;

  redRequest.Visible := true;

  iHandle := MessageDlg('Would you like to handle this request?', mtConfirmation, mbYESNO, 0);

  if iHandle = 6 then
  begin
    for i := 0 to redRequest.Lines.Count -1 do
      begin
        if pos('USERNAME', uppercase(redRequest.Lines[i])) > 0 then                 //pos('', uppercase(redRequest.Lines[i])) > 0
        begin
          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsUsers;
          finally
            FAllowTabChange := False;
          end;

          ClearUserFields;

          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsAdmin;
          finally
            FAllowTabChange := False;
          end;
          redRequest.Visible := false;
        end
        else if pos('BRAND', uppercase(redRequest.Lines[i])) > 0 then
        begin
          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsBrands;
          finally
            FAllowTabChange := False;
          end;

          ClearUserFields;

          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsAdmin;
          finally
            FAllowTabChange := False;
          end;
          redRequest.Visible := false;
        end
        else if pos('ITEM ID', uppercase(redRequest.Lines[i])) > 0 then
        begin
          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsInventory;
          finally
            FAllowTabChange := False;
          end;

          ClearUserFields;

          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsAdmin;
          finally
            FAllowTabChange := False;
          end;
          redRequest.Visible := false;
        end
        else if pos('VEHICLE ID', uppercase(redRequest.Lines[i])) > 0 then
        begin
          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsTrucks;
          finally
            FAllowTabChange := False;
          end;

          ClearUserFields;

          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsAdmin;
          finally
            FAllowTabChange := False;
          end;
          redRequest.Visible := false;
        end
        else if pos('WAREHOUSE', uppercase(redRequest.Lines[i])) > 0 then
        begin
          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsWarehouses;
          finally
            FAllowTabChange := False;
          end;

          ClearUserFields;

          FAllowTabChange := True;

          try
            pgcAdmin.ActivePage := tbsAdmin;
          finally
            FAllowTabChange := False;
          end;
          redRequest.Visible := false;
        end;
      end;
  end
  else
  begin
    iOther := messagedlg('Would you you like to handle ANOTHER request?', mtConfirmation, mbYesNo, 0);

    if iOther = 6 then
    btnHandleRequests.Click
    else redRequest.Visible := false;
  end;
end;

// ============================================================
// USERS
// ============================================================

procedure TfrmAdmin.dbgUsers_AdminCellClick(Column: TColumn);
begin
  with dmPAT2026_1 do
  begin
    if (not tblUsers.Active) or tblUsers.IsEmpty then
      exit;

    sSelUserID := tblUsers.FieldByName('UserID').AsString;

    lbdtUserID.Text := sSelUserID;
    lbdtUsername.Text := tblUsers.FieldByName('Username').AsString;
    lbdtName.Text := tblUsers.FieldByName('User_Name').AsString;
    lbdtSurname.Text := tblUsers.FieldByName('User_Surname').AsString;
    lbdtCity.Text := tblUsers.FieldByName('City').AsString;
    lbdtPassword.Text := tblUsers.FieldByName('Password').AsString;
    // Field is 'Budget'. Plain 0.00 format so it converts back cleanly.
    lbdtBudget.Text := FormatFloat('0.00',
      tblUsers.FieldByName('Budget').AsFloat);
    lbdtRole.Text := tblUsers.FieldByName('Role').AsString;
  end;

  btnUserEdit.Enabled := true;
  btnUserDelete.Enabled := true;
end;

// ---- USERS: EDIT ----
procedure TfrmAdmin.btnUserEditClick(Sender: TObject);
var
  sUser, sName, sSurname, sCity, sPass, sRole: string;
  rBudget: double;
begin
  if sSelUserID = '' then
  begin
    ShowMessage('Please select a user from the grid first.');
    exit;
  end;

  sUser := Trim(lbdtUsername.Text);
  sName := Trim(lbdtName.Text);
  sSurname := Trim(lbdtSurname.Text);
  sCity := Trim(lbdtCity.Text);
  sPass := lbdtPassword.Text;
  sRole := Trim(lbdtRole.Text);

  // ---- presence checks (first failure only, so no message storm) ----
  if not presence(sName) then
  begin
    ShowMessage('Name cannot be empty.');
    lbdtName.SetFocus;
    exit;
  end;
  if not presence(sSurname) then
  begin
    ShowMessage('Surname cannot be empty.');
    lbdtSurname.SetFocus;
    exit;
  end;
  if not presence(sUser) then
  begin
    ShowMessage('Username cannot be empty.');
    lbdtUsername.SetFocus;
    exit;
  end;
  if not presence(sPass) then
  begin
    ShowMessage('Password cannot be empty.');
    lbdtPassword.SetFocus;
    exit;
  end;

  // ---- format / type checks ----
  if not IsAlphaSpace(sName) then
  begin
    ShowMessage
      ('Name may only contain letters, spaces, hyphens and apostrophes.');
    lbdtName.SetFocus;
    exit;
  end;
  if not IsAlphaSpace(sSurname) then
  begin
    ShowMessage
      ('Surname may only contain letters, spaces, hyphens and apostrophes.');
    lbdtSurname.SetFocus;
    exit;
  end;
  if not IsValidUsername(sUser) then
  begin
    ShowMessage('Invalid username.' + #13#10 +
      'At least 3 characters. Letters, digits, underscores and full ' +
      'stops only. No spaces.');
    lbdtUsername.SetFocus;
    exit;
  end;
  if not IsValidPassword(sPass) then
  begin
    ShowMessage('Password does not meet the 8-4 rule.' + #13#10 +
      'Minimum 8 characters with at least one uppercase letter, one ' +
      'lowercase letter, one digit and one special character.');
    lbdtPassword.SetFocus;
    exit;
  end;
  if not IsValidCity(sCity) then
  begin
    ShowMessage('Invalid city.' + #13#10 +
      'Must be one of: Pretoria, Johannesburg, Cape Town, Durban, ' +
      'Port Elizabeth, Nelspruit, Bloemfontein.');
    lbdtCity.SetFocus;
    exit;
  end;
  if not IsValidRole(sRole) then
  begin
    ShowMessage('Invalid role. Must be Admin, Dispatcher or Consumer.');
    lbdtRole.SetFocus;
    exit;
  end;
  if not IsValidReal(lbdtBudget.Text, rBudget) then
  begin
    ShowMessage('Budget must be a valid amount of 0.00 or more.');
    lbdtBudget.SetFocus;
    exit;
  end;

  // ---- duplicate check that EXCLUDES this user's own record ----
  // (the old query matched the record being edited, so it could
  // never succeed)
  if DuplicateElsewhere('Username', sUser, sSelUserID) then
  begin
    ShowMessage('That username already belongs to another user.');
    lbdtUsername.SetFocus;
    exit;
  end;

  // ---- guard: never demote the last remaining admin ----
  if (sRole <> 'Admin') and (Copy(sSelUserID, 1, 3) = 'ADM') and
    (CountAdmins <= 1) then
  begin
    ShowMessage('This is the only Admin account. Its role cannot be ' +
      'changed or the system would be left with no administrator.');
    exit;
  end;

  if MessageDlg('Update user ' + sSelUserID + '?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then
    exit;

  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text :=
        'UPDATE tblUsers SET Username = :pUser, User_Name = :pName, ' +
        'User_Surname = :pSurname, City = :pCity, Password = :pPass, ' +
        'Role = :pRole, Budget = :pBudget WHERE UserID = :pID';
      qryMain.Parameters.ParamByName('pUser').Value := sUser;
      qryMain.Parameters.ParamByName('pName').Value := sName;
      qryMain.Parameters.ParamByName('pSurname').Value := sSurname;
      qryMain.Parameters.ParamByName('pCity').Value := sCity;
      qryMain.Parameters.ParamByName('pPass').Value := sPass;
      qryMain.Parameters.ParamByName('pRole').Value := sRole;
      qryMain.Parameters.ParamByName('pBudget').Value := rBudget;
      qryMain.Parameters.ParamByName('pID').Value := sSelUserID;
      qryMain.ExecSQL;

      RefreshTable(tblUsers);
      ShowMessage('User ' + sSelUserID + ' updated successfully.');
      ClearUserFields;
    except
      on E: Exception do
        ShowMessage('The user could not be updated.' + #13#10 +
          'Database error: ' + E.Message);
    end;
end;

// ---- USERS: DELETE ----
procedure TfrmAdmin.btnUserDeleteClick(Sender: TObject);
begin
  if sSelUserID = '' then
  begin
    ShowMessage('Please select a user from the grid first.');
    exit;
  end;

  // Guard 1: the system must always keep at least one admin
  if (Copy(sSelUserID, 1, 3) = 'ADM') and (CountAdmins <= 1) then
  begin
    ShowMessage('This is the only Admin account and cannot be deleted.');
    exit;
  end;

  // Guard 2: never orphan live orders
  if UserHasOpenOrders(sSelUserID) then
  begin
    ShowMessage('This user has orders that are not yet Delivered.' + #13#10 +
      'Resolve those orders before deleting the account.');
    exit;
  end;

  // Guard 3: explicit confirmation
  if MessageDlg('Permanently delete user ' + sSelUserID + '?' + #13#10 +
    'This cannot be undone.', mtWarning, [mbYes, mbNo], 0) <> mrYes then
    exit;

  with dmPAT2026_1 do
    try
      // Dependent wardrobe rows first, so nothing is orphaned
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text := 'DELETE FROM tblWardrobes WHERE UserID = :pID';
      qryMain.Parameters.ParamByName('pID').Value := sSelUserID;
      qryMain.ExecSQL;

      qryMain.SQL.Text := 'DELETE FROM tblUsers WHERE UserID = :pID';
      qryMain.Parameters.ParamByName('pID').Value := sSelUserID;
      qryMain.ExecSQL;

      RefreshTable(tblUsers);
      ShowMessage('User ' + sSelUserID + ' deleted.');
      ClearUserFields;
    except
      on E: Exception do
        ShowMessage('The user could not be deleted.' + #13#10 +
          'Database error: ' + E.Message);
    end;
end;

// ============================================================
// BRANDS
// ============================================================

procedure TfrmAdmin.dbgBrands_AdminCellClick(Column: TColumn);
begin
  with dmPAT2026_1 do
  begin
    if (not tblBrands.Active) or tblBrands.IsEmpty then
      exit;
    sSelBrandID := tblBrands.FieldByName('BrandID').AsString;
    lbdtBrandID.Text := sSelBrandID;
    lbdtBrandName.Text := tblBrands.FieldByName('Brand_Name').AsString;
    lbdtBrandEmail.Text := tblBrands.FieldByName('Contact_Email').AsString;
  end;
end;

// ---- BRANDS: ADD ----
procedure TfrmAdmin.btnBrandAddClick(Sender: TObject);
var
  sID, sName, sEmail: string;
begin
  sID := UpperCase(Trim(lbdtBrandID.Text));
  sName := Trim(lbdtBrandName.Text);
  sEmail := Trim(lbdtBrandEmail.Text);

  if not presence(sID) then
  begin
    ShowMessage('Brand ID cannot be empty.');
    lbdtBrandID.SetFocus;
    exit;
  end;
  if Length(sID) <> 3 then
  begin
    ShowMessage('Brand ID must be exactly 3 characters (e.g. ADI).');
    lbdtBrandID.SetFocus;
    exit;
  end;
  if not IsValidID(sID) then
  begin
    ShowMessage('Brand ID must be uppercase letters only (e.g. ADI).');
    lbdtBrandID.SetFocus;
    exit;
  end;
  if not presence(sName) then
  begin
    ShowMessage('Brand name cannot be empty.');
    lbdtBrandName.SetFocus;
    exit;
  end;
  if not presence(sEmail) then
  begin
    ShowMessage('Contact email cannot be empty.');
    lbdtBrandEmail.SetFocus;
    exit;
  end;
  if not IsValidEmail(sEmail) then
  begin
    ShowMessage('Invalid email address.' + #13#10 +
      'It must contain ''@'' and a domain, e.g. supply@brand.co.za');
    lbdtBrandEmail.SetFocus;
    exit;
  end;

  if RecordExists('tblBrands', 'BrandID', sID) then
  begin
    ShowMessage('A brand with ID ' + sID + ' already exists.');
    lbdtBrandID.SetFocus;
    exit;
  end;
  if RecordExists('tblBrands', 'Brand_Name', sName) then
  begin
    ShowMessage('A brand named ' + sName + ' already exists.');
    lbdtBrandName.SetFocus;
    exit;
  end;

  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text :=
        'INSERT INTO tblBrands (BrandID, Brand_Name, Contact_Email) ' +
        'VALUES (:pID, :pName, :pEmail)';
      qryMain.Parameters.ParamByName('pID').Value := sID;
      qryMain.Parameters.ParamByName('pName').Value := sName;
      qryMain.Parameters.ParamByName('pEmail').Value := sEmail;
      qryMain.ExecSQL;

      RefreshTable(tblBrands);
      ShowMessage(sName +
        ' has successfully been added and they are now a part of OptiCorp.');
      ClearBrandFields;
    except
      on E: Exception do
        ShowMessage('The brand could not be added.' + #13#10 +
          'Database error: ' + E.Message);
    end;
end;

// ============================================================
// WAREHOUSES
// ============================================================

procedure TfrmAdmin.dbgWarehouses_AdminCellClick(Column: TColumn);
begin
  with dmPAT2026_1 do
  begin
    if (not tblWarehouses.Active) or tblWarehouses.IsEmpty then
      exit;
    sSelWarehouseID := tblWarehouses.FieldByName('WarehouseID').AsString;
    lbdtWarehouseID.Text := sSelWarehouseID;
    lbdtWBrandID.Text := tblWarehouses.FieldByName('BrandID').AsString;
    lbdtLocName.Text := tblWarehouses.FieldByName('Location_Name').AsString;
    lbdtXCoord.Text := tblWarehouses.FieldByName('X_Coordinates').AsString;
    lbdtYCoord.Text := tblWarehouses.FieldByName('Y_Coordinates').AsString;
  end;
end;

// ---- WAREHOUSES: ADD ----
procedure TfrmAdmin.Button5Click(Sender: TObject);
var
  sID, sBrand, sLoc: string;
  rX, rY: double;
begin
  sID := UpperCase(Trim(lbdtWarehouseID.Text));
  sBrand := UpperCase(Trim(lbdtWBrandID.Text));
  sLoc := Trim(lbdtLocName.Text);

  if not presence(sID) then
  begin
    ShowMessage('Warehouse ID cannot be empty.');
    lbdtWarehouseID.SetFocus;
    exit;
  end;
  if not IsValidID(sID) then
  begin
    ShowMessage('Warehouse ID may contain uppercase letters, digits and ' +
      'hyphens only (e.g. WH-OPT-HQ).');
    lbdtWarehouseID.SetFocus;
    exit;
  end;
  if not presence(sBrand) then
  begin
    ShowMessage('Brand ID cannot be empty.');
    lbdtWBrandID.SetFocus;
    exit;
  end;
  if not presence(sLoc) then
  begin
    ShowMessage('Location name cannot be empty.');
    lbdtLocName.SetFocus;
    exit;
  end;
  if not IsValidReal(lbdtXCoord.Text, rX) then
  begin
    ShowMessage('X-coordinate must be a valid number of 0 or more.');
    lbdtXCoord.SetFocus;
    exit;
  end;
  if not IsValidReal(lbdtYCoord.Text, rY) then
  begin
    ShowMessage('Y-coordinate must be a valid number of 0 or more.');
    lbdtYCoord.SetFocus;
    exit;
  end;
  if (rX > 1000) or (rY > 1000) then
  begin
    ShowMessage('Coordinates must fall within the 0-1000 map grid.');
    lbdtXCoord.SetFocus;
    exit;
  end;

  // Referential integrity: the brand must exist first
  if not RecordExists('tblBrands', 'BrandID', sBrand) then
  begin
    ShowMessage('Brand ' + sBrand + ' does not exist. Add the brand first.');
    lbdtWBrandID.SetFocus;
    exit;
  end;
  if RecordExists('tblWarehouses', 'WarehouseID', sID) then
  begin
    ShowMessage('A warehouse with ID ' + sID + ' already exists.');
    lbdtWarehouseID.SetFocus;
    exit;
  end;

  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text := 'INSERT INTO tblWarehouses ' +
        '(WarehouseID, BrandID, Location_Name, X_Coordinates, Y_Coordinates) ' +
        'VALUES (:pID, :pBrand, :pLoc, :pX, :pY)';
      qryMain.Parameters.ParamByName('pID').Value := sID;
      qryMain.Parameters.ParamByName('pBrand').Value := sBrand;
      qryMain.Parameters.ParamByName('pLoc').Value := sLoc;
      qryMain.Parameters.ParamByName('pX').Value := Round(rX);
      qryMain.Parameters.ParamByName('pY').Value := Round(rY);
      qryMain.ExecSQL;

      RefreshTable(tblWarehouses);
      ShowMessage('Warehouse ' + sID + ' registered successfully.');
      ClearWarehouseFields;
    except
      on E: Exception do
        ShowMessage('The warehouse could not be added.' + #13#10 +
          'Database error: ' + E.Message);
    end;
end;

// ============================================================
// INVENTORY
// ============================================================

procedure TfrmAdmin.dbgInventory_AdminCellClick(Column: TColumn);
begin
  with dmPAT2026_1 do
  begin
    if (not tblInventory.Active) or tblInventory.IsEmpty then
      exit;

    sSelItemID := tblInventory.FieldByName('ItemID').AsString;
    lbdtItemID.Text := sSelItemID;
    lbdtIBrandID.Text := tblInventory.FieldByName('BrandID').AsString;
    lbdtItemName.Text := tblInventory.FieldByName('Item_Name').AsString;
    lbdtCat.Text := tblInventory.FieldByName('Category').AsString;
    lbdtColour.Text := tblInventory.FieldByName('Color_Family').AsString;
    lbdtPrice.Text := FormatFloat('0.00',
      tblInventory.FieldByName('Price').AsFloat);

    sedWarmth.Value := tblInventory.FieldByName('Warmth_Rating').AsInteger;
    sedFormality.Value := tblInventory.FieldByName('Formality_Score').AsInteger;
    // NOTE: TSpinEdit is integer-only, so a 0.85 kg weight rounds to 1.
    sedWeight.Value := Round(tblInventory.FieldByName('Weight').AsFloat);
    sedVol.Value := Round(tblInventory.FieldByName('Volume').AsFloat);
    sedStock.Value := tblInventory.FieldByName('Quantity_Stock').AsInteger;
  end;

  btnInventoryEdit.Enabled := true;
end;

// ---- INVENTORY: ADD ----
procedure TfrmAdmin.btnInventoryAddClick(Sender: TObject);
var
  sID, sBrand, sName, sCat, sColour: string;
  rPrice: double;
begin
  sID := UpperCase(Trim(lbdtItemID.Text));
  sBrand := UpperCase(Trim(lbdtIBrandID.Text));
  sName := Trim(lbdtItemName.Text);
  sCat := Trim(lbdtCat.Text);
  sColour := Trim(lbdtColour.Text);

  if not presence(sID) then
  begin
    ShowMessage('Item ID cannot be empty.');
    lbdtItemID.SetFocus;
    exit;
  end;
  if not IsValidID(sID) then
  begin
    ShowMessage('Item ID may contain uppercase letters, digits and hyphens ' +
      'only (e.g. SHU-BLK-TIM-01).');
    lbdtItemID.SetFocus;
    exit;
  end;
  if not presence(sBrand) then
  begin
    ShowMessage('Brand ID cannot be empty.');
    lbdtIBrandID.SetFocus;
    exit;
  end;
  if not presence(sName) then
  begin
    ShowMessage('Item name cannot be empty.');
    lbdtItemName.SetFocus;
    exit;
  end;
  if not presence(sCat) then
  begin
    ShowMessage('Category cannot be empty.');
    lbdtCat.SetFocus;
    exit;
  end;
  if not presence(sColour) then
  begin
    ShowMessage('Colour family cannot be empty.');
    lbdtColour.SetFocus;
    exit;
  end;
  if not IsValidReal(lbdtPrice.Text, rPrice) then
  begin
    ShowMessage('Price must be a valid amount of 0.00 or more.');
    lbdtPrice.SetFocus;
    exit;
  end;

  // Range checks
  if (sedWarmth.Value < 1) or (sedWarmth.Value > 10) then
  begin
    ShowMessage('Warmth rating must be between 1 and 10.');
    sedWarmth.SetFocus;
    exit;
  end;
  if (sedFormality.Value < 1) or (sedFormality.Value > 10) then
  begin
    ShowMessage('Formality score must be between 1 and 10.');
    sedFormality.SetFocus;
    exit;
  end;
  if sedWeight.Value <= 0 then
  begin
    ShowMessage('Weight must be greater than 0.');
    sedWeight.SetFocus;
    exit;
  end;
  if sedVol.Value <= 0 then
  begin
    ShowMessage('Volume must be greater than 0.');
    sedVol.SetFocus;
    exit;
  end;
  if sedStock.Value < 0 then
  begin
    ShowMessage('Stock quantity cannot be negative.');
    sedStock.SetFocus;
    exit;
  end;

  if not RecordExists('tblBrands', 'BrandID', sBrand) then
  begin
    ShowMessage('Brand ' + sBrand + ' does not exist. Add the brand first.');
    lbdtIBrandID.SetFocus;
    exit;
  end;
  if RecordExists('tblInventory', 'ItemID', sID) then
  begin
    ShowMessage('An item with ID ' + sID + ' already exists.');
    lbdtItemID.SetFocus;
    exit;
  end;

  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text :=
        'INSERT INTO tblInventory (ItemID, BrandID, Item_Name, Category, ' +
        'Color_Family, Price, Quantity_Stock, Warmth_Rating, ' +
        'Formality_Score, Weight, Volume) VALUES ' +
        '(:pID, :pBrand, :pName, :pCat, :pColour, :pPrice, :pStock, ' +
        ':pWarmth, :pFormality, :pWeight, :pVolume)';
      qryMain.Parameters.ParamByName('pID').Value := sID;
      qryMain.Parameters.ParamByName('pBrand').Value := sBrand;
      qryMain.Parameters.ParamByName('pName').Value := sName;
      qryMain.Parameters.ParamByName('pCat').Value := sCat;
      qryMain.Parameters.ParamByName('pColour').Value := sColour;
      qryMain.Parameters.ParamByName('pPrice').Value := rPrice;
      qryMain.Parameters.ParamByName('pStock').Value := sedStock.Value;
      qryMain.Parameters.ParamByName('pWarmth').Value := sedWarmth.Value;
      qryMain.Parameters.ParamByName('pFormality').Value := sedFormality.Value;
      qryMain.Parameters.ParamByName('pWeight').Value := sedWeight.Value;
      qryMain.Parameters.ParamByName('pVolume').Value := sedVol.Value;
      qryMain.ExecSQL;

      RefreshTable(tblInventory);
      ShowMessage('Item ' + sName + ' (' + sID + ') added successfully.');
      ClearInventoryFields;
    except
      on E: Exception do
        ShowMessage('The item could not be added.' + #13#10 + 'Database error: '
          + E.Message);
    end;
end;

// ---- INVENTORY: EDIT  (the PAT's BtnUpdateStock) ----
procedure TfrmAdmin.btnInventoryEditClick(Sender: TObject);
var
  rPrice: double;
begin
  if sSelItemID = '' then
  begin
    ShowMessage('Please select an item from the grid first.');
    exit;
  end;

  if not presence(lbdtItemName.Text) then
  begin
    ShowMessage('Item name cannot be empty.');
    lbdtItemName.SetFocus;
    exit;
  end;
  if not IsValidReal(lbdtPrice.Text, rPrice) then
  begin
    ShowMessage('Price must be a valid amount of 0.00 or more.');
    lbdtPrice.SetFocus;
    exit;
  end;
  if (sedWarmth.Value < 1) or (sedWarmth.Value > 10) then
  begin
    ShowMessage('Warmth rating must be between 1 and 10.');
    sedWarmth.SetFocus;
    exit;
  end;
  if (sedFormality.Value < 1) or (sedFormality.Value > 10) then
  begin
    ShowMessage('Formality score must be between 1 and 10.');
    sedFormality.SetFocus;
    exit;
  end;
  if sedStock.Value < 0 then
  begin
    ShowMessage('Stock quantity cannot be negative.');
    sedStock.SetFocus;
    exit;
  end;

  if MessageDlg('Update item ' + sSelItemID + '?', mtConfirmation,
    [mbYes, mbNo], 0) <> mrYes then
    exit;

  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text :=
        'UPDATE tblInventory SET Item_Name = :pName, Category = :pCat, ' +
        'Color_Family = :pColour, Price = :pPrice, ' +
        'Quantity_Stock = :pStock, Warmth_Rating = :pWarmth, ' +
        'Formality_Score = :pFormality, Weight = :pWeight, ' +
        'Volume = :pVolume WHERE ItemID = :pID';
      qryMain.Parameters.ParamByName('pName').Value := Trim(lbdtItemName.Text);
      qryMain.Parameters.ParamByName('pCat').Value := Trim(lbdtCat.Text);
      qryMain.Parameters.ParamByName('pColour').Value :=
        Trim(lbdtColour.Text);
      qryMain.Parameters.ParamByName('pPrice').Value := rPrice;
      qryMain.Parameters.ParamByName('pStock').Value := sedStock.Value;
      qryMain.Parameters.ParamByName('pWarmth').Value := sedWarmth.Value;
      qryMain.Parameters.ParamByName('pFormality').Value := sedFormality.Value;
      qryMain.Parameters.ParamByName('pWeight').Value := sedWeight.Value;
      qryMain.Parameters.ParamByName('pVolume').Value := sedVol.Value;
      qryMain.Parameters.ParamByName('pID').Value := sSelItemID;
      qryMain.ExecSQL;

      RefreshTable(tblInventory);
      ShowMessage('Item ' + sSelItemID + ' updated successfully.');
      ClearInventoryFields;
    except
      on E: Exception do
        ShowMessage('The item could not be updated.' + #13#10 +
          'Database error: ' + E.Message);
    end;
end;

// ============================================================
// TRUCKS
// SpinEdit6 = Max Weight    SpinEdit7 = Max Volume
// ============================================================

procedure TfrmAdmin.dbgTrucks_AdminCellClick(Column: TColumn);
begin
  with dmPAT2026_1 do
  begin
    if (not tblTrucks.Active) or tblTrucks.IsEmpty then
      exit;
    sSelVehicleID := tblTrucks.FieldByName('VehicleID').AsString;
    lbdtVehicleID.Text := sSelVehicleID;
    lbdtReg.Text := tblTrucks.FieldByName('Vehicle_Reg').AsString;
    lbdtVehType.Text := tblTrucks.FieldByName('Vehicle_Type').AsString;
    lbdtStatus.Text := tblTrucks.FieldByName('Status').AsString;
    sedMaxW.Value := Round(tblTrucks.FieldByName('Max_Weight').AsFloat);
    sedMaxV.Value := Round(tblTrucks.FieldByName('Max_Volume').AsFloat);
  end;
end;

// ---- TRUCKS: ADD ----
procedure TfrmAdmin.btnTruckAddClick(Sender: TObject);
var
  sID, sReg, sType, sStatus: string;
begin
  sID := UpperCase(Trim(lbdtVehicleID.Text));
  sReg := UpperCase(Trim(lbdtReg.Text));
  sType := Trim(lbdtVehType.Text);
  sStatus := Trim(lbdtStatus.Text);

  if not presence(sID) then
  begin
    ShowMessage('Vehicle ID cannot be empty.');
    lbdtVehicleID.SetFocus;
    exit;
  end;
  if not IsValidID(sID) then
  begin
    ShowMessage('Vehicle ID may contain uppercase letters, digits and ' +
      'hyphens only (e.g. VEH-TRK-01).');
    lbdtVehicleID.SetFocus;
    exit;
  end;
  if not presence(sReg) then
  begin
    ShowMessage('Registration cannot be empty.');
    lbdtReg.SetFocus;
    exit;
  end;
  if not presence(sType) then
  begin
    ShowMessage('Vehicle type cannot be empty.');
    lbdtVehType.SetFocus;
    exit;
  end;
  if not IsValidStatus(sStatus) then
  begin
    ShowMessage('Status must be Available, On Route or Maintenance.');
    lbdtStatus.SetFocus;
    exit;
  end;
  if sedMaxW.Value <= 0 then
  begin
    ShowMessage('Max weight must be greater than 0 kg.');
    sedMaxW.SetFocus;
    exit;
  end;
  if sedMaxV.Value <= 0 then
  begin
    ShowMessage('Max volume must be greater than 0 litres.');
    sedMaxV.SetFocus;
    exit;
  end;

  if RecordExists('tblTrucks', 'VehicleID', sID) then
  begin
    ShowMessage('A vehicle with ID ' + sID + ' already exists.');
    lbdtVehicleID.SetFocus;
    exit;
  end;
  if RecordExists('tblTrucks', 'Vehicle_Reg', sReg) then
  begin
    ShowMessage('Registration ' + sReg + ' is already on the fleet.');
    lbdtReg.SetFocus;
    exit;
  end;

  with dmPAT2026_1 do
    try
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text :=
        'INSERT INTO tblTrucks (VehicleID, Vehicle_Reg, Vehicle_Type, ' +
        'Status, Max_Weight, Max_Volume) VALUES ' +
        '(:pID, :pReg, :pType, :pStatus, :pWeight, :pVolume)';
      qryMain.Parameters.ParamByName('pID').Value := sID;
      qryMain.Parameters.ParamByName('pReg').Value := sReg;
      qryMain.Parameters.ParamByName('pType').Value := sType;
      qryMain.Parameters.ParamByName('pStatus').Value := sStatus;
      qryMain.Parameters.ParamByName('pWeight').Value := sedMaxW.Value;
      qryMain.Parameters.ParamByName('pVolume').Value := sedMaxV.Value;
      qryMain.ExecSQL;

      RefreshTable(tblTrucks);
      ShowMessage('Vehicle ' + sID + ' added to the fleet.');
      ClearTruckFields;
    except
      on E: Exception do
        ShowMessage('The vehicle could not be added.' + #13#10 +
          'Database error: ' + E.Message);
    end;
end;

// ============================================================
// GRID FORMATTING
// ============================================================

procedure TfrmAdmin.SetColWidth(dbg: TDBGrid; const fieldName: string;
  width: Integer);
var
  i, check: Integer;
begin
  i := -1;
  check := 0;

  while (i < dbg.Columns.Count - 1) and (check = 0) do
  begin
    inc(i);
    if SameText(dbg.Columns[i].fieldName, fieldName) then
    begin
      dbg.Columns[i].width := width;
      check := 1;
    end;
  end;
end;

procedure TfrmAdmin.ApplyGridFont(dbg: TDBGrid);
var
  i: Integer;
begin
  dbg.Font.Name := 'JetBrains Mono';
  dbg.Font.Style := [fsItalic];
  dbg.Font.Size := 9;

  for i := 0 to dbg.Columns.Count - 1 do
  begin
    dbg.Columns[i].Font.Name := 'JetBrains Mono';
    dbg.Columns[i].Font.Style := [fsItalic];
    dbg.Columns[i].Font.Size := 9;
  end;
end;

end.
