unit customers_u;

// ============================================================
// OptiCorp PAT 2026 - CONSUMER INTERFACE
//
// Outfit recommendation applies three factors in order of
// strictness:
// 1. FORMALITY - a hard filter (in the band or not at all)
// 2. WARMTH    - a target derived from the live temperature
// 3. COLOUR    - a tiebreaker between valid outfits
// ============================================================

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, dmPAT2026,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, System.JSON, clsGarment, Vcl.Samples.Spin,
  Vcl.Imaging.pngimage;

type
  TfrmCustomers = class(TForm)
    pgcUser: TPageControl;
    tbsCustomer: TTabSheet;
    tbsWardrobe: TTabSheet;
    tbsWallet: TTabSheet;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    tbsShop: TTabSheet;
    Image4: TImage;
    RichEdit1: TRichEdit;
    btnWardrobes: TButton;
    btnWallet: TButton;
    btnShop: TButton;
    pgcWardrobes: TPageControl;
    tbsGeneral: TTabSheet;
    tbsEvent: TTabSheet;
    btnClean: TButton;
    btnMaintain: TButton;
    btnDiscard: TButton;
    dbgUserWardrobe: TDBGrid;
    lblWardrobeHeading: TLabel;
    imgWard: TImage;
    chkClean: TCheckBox;
    radDiscard: TRadioGroup;
    DBGrid1: TDBGrid;
    imgOuter: TImage;
    imgBottom: TImage;
    imgTop: TImage;
    imgShoes: TImage;
    Label1: TLabel;
    FormalityScore: TComboBox;
    redWardDisplay: TRichEdit;
    btnWeather: TButton;
    btnChk: TButton;
    btnGenOutfit: TButton;
    btnFinalise: TButton;
    edtBalance: TEdit;
    edtDeposit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    btnDeposit: TButton;
    RESTRequest: TRESTRequest;
    RESTClient: TRESTClient;
    RESTResponse: TRESTResponse;
    dbgShop: TDBGrid;
    Label4: TLabel;
    sedFS: TSpinEdit;
    sedWarmth: TSpinEdit;
    edtPrice: TEdit;
    lblFS: TLabel;
    lblWarmth: TLabel;
    lblPrice: TLabel;
    btnPurchase: TButton;
    btnLOGOUT: TButton;
    Image5: TImage;
    Image11: TImage;
    Image12: TImage;
    imgInfo: TImage;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCleanClick(Sender: TObject);
    procedure dbgUserWardrobeCellClick(Column: TColumn);
    procedure btnMaintainClick(Sender: TObject);
    procedure btnDiscardClick(Sender: TObject);
    procedure btnWeatherClick(Sender: TObject);
    procedure pgcWardrobesChange(Sender: TObject);
    procedure btnGenOutfitClick(Sender: TObject);
    procedure btnDepositClick(Sender: TObject);
    procedure btnChkClick(Sender: TObject);
    procedure btnFinaliseClick(Sender: TObject);
    procedure dbgShopCellClick(Column: TColumn);
    procedure btnPurchaseClick(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure btnLOGOUTClick(Sender: TObject);
    procedure Image5Click(Sender: TObject);
    procedure Image11Click(Sender: TObject);
    procedure Image12Click(Sender: TObject);
    procedure btnWardrobesClick(Sender: TObject);
    procedure btnWalletClick(Sender: TObject);
    procedure btnShopClick(Sender: TObject);
    procedure pgcUserChanging(Sender: TObject; var AllowChange: Boolean);
    procedure imgInfoClick(Sender: TObject);
  private
    { Private declarations }
    FAllowTabChange: boolean;

    LTemp: double;
    bWeatherFetched: boolean;
    arrGarments: array of TGarment; // OWNS the objects
    arrTops: array of TTop; // reference only - never freed here
    arrOuterwear: array of TOuterwear;
    arrBottoms: array of TBottom;
    arrShoes: array of TShoes;
    arrOutfits: array [0 .. 3] of TGarment;
    bOutfitHasOuter: boolean;

    procedure SetColWidth(dbg: TDBGrid; const fieldName: string;
      width: Integer);
    procedure ApplyGridFont(dbg: TDBGrid);
    procedure FormatGrids;
    procedure LoadWardrobeObjects;
    procedure ClearGarments;
    procedure ClearCategoryArrays;
    procedure RefreshBalance;
    function CurrentBudget: double;
    function HasEnoughFunds(sID: string; rCost: double): boolean;
    procedure SortOnFormality(formality_range: Integer);
    function ChosenFormality: Integer;
    function NeedOuterwear(temp: double): boolean;
    function WarmthTarget(temp: double): Integer;
    function WarmthPenalty(target, total: Integer): Integer;
    function AccentsToPoints(iAccents: Integer): Integer;
    function MatchScore(miss, colour_adjustment: Integer): Integer;
    function IsValidAmount(const s: string; out r: double): boolean;
    procedure ShowGarmentImage(g: TGarment; img: TImage);
    procedure GoToTab(iPage: integer);
  public
    { Public declarations }
    userID: string;
  end;

var
  frmCustomers: TfrmCustomers;

const
  clean_cost = 10.50;
  maintenance_cost = 20.00;
  discard_cost = 40.00;
  api_key = 'd219ef6a17d6182c1576af9e1f4418f8';
  min_deposit = 50.00;
  max_deposit = 10000.00;
  default_temp = 20.0; // used if the API cannot be reached
  no_score = -999999; // beaten by any real score

implementation

{$R *.dfm}
// ============================================================
// OBJECT MANAGEMENT
// ============================================================

// arrGarments owns every object. The four category arrays hold
// REFERENCES to the same objects, so they must never be freed
// twice - clearing them only drops the references.
procedure TfrmCustomers.ClearGarments;
var
  i: Integer;
begin
  ClearCategoryArrays;
  for i := 0 to High(arrGarments) do
    arrGarments[i].Free;
  SetLength(arrGarments, 0);
end;

procedure TfrmCustomers.ClearCategoryArrays;
begin
  SetLength(arrTops, 0);
  SetLength(arrBottoms, 0);
  SetLength(arrShoes, 0);
  SetLength(arrOuterwear, 0);
end;

// Read the wardrobe query and build one object per row, of the
// correct class for its category.
procedure TfrmCustomers.LoadWardrobeObjects;
var
  g: TGarment;
  sCat: string;
begin
  ClearGarments;

  with dmPAT2026_1 do
  begin
    qryWardrobe.First;
    while not qryWardrobe.Eof do
    begin
      sCat := qryWardrobe.FieldByName('Category').AsString;
      g := nil;

      if sCat = 'Top' then
        g := TTop.Create(qryWardrobe.FieldByName('ItemID').AsString,
          qryWardrobe.FieldByName('Item_Name').AsString,
          qryWardrobe.FieldByName('BrandID').AsString,
          qryWardrobe.FieldByName('Color_Family').AsString,
          qryWardrobe.FieldByName('Formality_Score').AsInteger,
          qryWardrobe.FieldByName('Warmth_Rating').AsInteger, sCat,
          qryWardrobe.FieldByName('Is_Clean').AsBoolean)

      else if sCat = 'Bottom' then
        g := TBottom.Create(qryWardrobe.FieldByName('ItemID').AsString,
          qryWardrobe.FieldByName('Item_Name').AsString,
          qryWardrobe.FieldByName('BrandID').AsString,
          qryWardrobe.FieldByName('Color_Family').AsString,
          qryWardrobe.FieldByName('Formality_Score').AsInteger,
          qryWardrobe.FieldByName('Warmth_Rating').AsInteger, sCat,
          qryWardrobe.FieldByName('Is_Clean').AsBoolean)

      else if sCat = 'Shoes' then
        g := TShoes.Create(qryWardrobe.FieldByName('ItemID').AsString,
          qryWardrobe.FieldByName('Item_Name').AsString,
          qryWardrobe.FieldByName('BrandID').AsString,
          qryWardrobe.FieldByName('Color_Family').AsString,
          qryWardrobe.FieldByName('Formality_Score').AsInteger,
          qryWardrobe.FieldByName('Warmth_Rating').AsInteger, sCat,
          qryWardrobe.FieldByName('Is_Clean').AsBoolean)

      else if sCat = 'Outerwear' then
        g := TOuterwear.Create(qryWardrobe.FieldByName('ItemID').AsString,
          qryWardrobe.FieldByName('Item_Name').AsString,
          qryWardrobe.FieldByName('BrandID').AsString,
          qryWardrobe.FieldByName('Color_Family').AsString,
          qryWardrobe.FieldByName('Formality_Score').AsInteger,
          qryWardrobe.FieldByName('Warmth_Rating').AsInteger, sCat,
          qryWardrobe.FieldByName('Is_Clean').AsBoolean);

      // grow FIRST, then write into the new last slot
      if g <> nil then
      begin
        SetLength(arrGarments, Length(arrGarments) + 1);
        arrGarments[High(arrGarments)] := g;
      end;

      qryWardrobe.Next;
    end;
    qryWardrobe.First;
  end;
end;

// ============================================================
// MONEY
// ============================================================

// Locate is used instead of a manual loop: it cannot run off the
// end, and it does not depend on the cursor's starting position.
function TfrmCustomers.CurrentBudget: double;
begin
  result := 0;
  with dmPAT2026_1 do
    if tblUsers.Locate('UserID', userID, []) then
      result := tblUsers.FieldByName('Budget').AsFloat;
end;

procedure TfrmCustomers.DBGrid1CellClick(Column: TColumn);
begin
  with dmPAT2026_1 do
  begin
    if qryWardrobe['Category'] = 'Outerwear' then
    begin
      if qryWardrobe.FieldByName('Is_Clean').AsBoolean then
      begin
        imgOuter.Picture.LoadFromFile('clothes\' + qryWardrobe['ItemID'] + '.jpg');
        arrOutfits[3] := TOuterwear.Create(qryWardrobe.FieldByName('ItemID')
          .AsString, qryWardrobe.FieldByName('Item_Name').AsString,
          qryWardrobe.FieldByName('BrandID').AsString,
          qryWardrobe.FieldByName('Color_Family').AsString,
          qryWardrobe.FieldByName('Formality_Score').AsInteger,
          qryWardrobe.FieldByName('Warmth_Rating').AsInteger,
          qryWardrobe.FieldByName('Category').AsString,
          qryWardrobe.FieldByName('Is_Clean').AsBoolean);
      end
      else
      begin
        showmessage
          ('This clothing item is dirty and cannot be worn in your outfit. Select another or wash the item.');
        exit;
      end;
    end;

    if qryWardrobe['Category'] = 'Top' then
    begin
      if qryWardrobe.FieldByName('Is_Clean').AsBoolean then
      begin
        imgTop.Picture.LoadFromFile('clothes\' + qryWardrobe['ItemID'] + '.jpg');
        arrOutfits[0] := TTop.Create(qryWardrobe.FieldByName('ItemID')
          .AsString, qryWardrobe.FieldByName('Item_Name').AsString,
          qryWardrobe.FieldByName('BrandID').AsString,
          qryWardrobe.FieldByName('Color_Family').AsString,
          qryWardrobe.FieldByName('Formality_Score').AsInteger,
          qryWardrobe.FieldByName('Warmth_Rating').AsInteger,
          qryWardrobe.FieldByName('Category').AsString,
          qryWardrobe.FieldByName('Is_Clean').AsBoolean);
      end
      else
      begin
        showmessage
          ('This clothing item is dirty and cannot be worn in your outfit. Select another or wash the item.');
        exit;
      end;
    end;

    if qryWardrobe['Category'] = 'Shoes' then
    begin
      if qryWardrobe.FieldByName('Is_Clean').AsBoolean then
      begin
        imgShoes.Picture.LoadFromFile('clothes\' + qryWardrobe['ItemID'] + '.jpg');
        arrOutfits[2] := TShoes.Create(qryWardrobe.FieldByName('ItemID')
          .AsString, qryWardrobe.FieldByName('Item_Name').AsString,
          qryWardrobe.FieldByName('BrandID').AsString,
          qryWardrobe.FieldByName('Color_Family').AsString,
          qryWardrobe.FieldByName('Formality_Score').AsInteger,
          qryWardrobe.FieldByName('Warmth_Rating').AsInteger,
          qryWardrobe.FieldByName('Category').AsString,
          qryWardrobe.FieldByName('Is_Clean').AsBoolean);
      end
      else
      begin
        showmessage
          ('This clothing item is dirty and cannot be worn in your outfit. Select another or wash the item.');
        exit;
      end;
    end;

    if qryWardrobe['Category'] = 'Bottom' then
    begin
      if qryWardrobe.FieldByName('Is_Clean').AsBoolean then
      begin
        imgBottom.Picture.LoadFromFile('clothes\' + qryWardrobe['ItemID'] + '.jpg');
        arrOutfits[1] := TBottom.Create(qryWardrobe.FieldByName('ItemID')
          .AsString, qryWardrobe.FieldByName('Item_Name').AsString,
          qryWardrobe.FieldByName('BrandID').AsString,
          qryWardrobe.FieldByName('Color_Family').AsString,
          qryWardrobe.FieldByName('Formality_Score').AsInteger,
          qryWardrobe.FieldByName('Warmth_Rating').AsInteger,
          qryWardrobe.FieldByName('Category').AsString,
          qryWardrobe.FieldByName('Is_Clean').AsBoolean);
      end
      else
      begin
        showmessage
          ('This clothing item is dirty and cannot be worn in your outfit. Select another or wash the item.');
        exit;
      end;
    end;
  end;
end;

function TfrmCustomers.HasEnoughFunds(sID: string; rCost: double): boolean;
var
  rBudget: double;
begin
  rBudget := 0;
  with dmPAT2026_1 do
    if tblUsers.Locate('UserID', sID, []) then
      rBudget := tblUsers.FieldByName('Budget').AsFloat;

  result := (rBudget >= rCost); // '>=' so an exact balance still works
end;

procedure TfrmCustomers.Image11Click(Sender: TObject);
begin
  GoToTab(0);
end;

procedure TfrmCustomers.Image12Click(Sender: TObject);
begin
  GoToTab(0);
end;

procedure TfrmCustomers.Image5Click(Sender: TObject);
begin
  GoToTab(0);
end;

procedure TfrmCustomers.RefreshBalance;
begin
  edtBalance.Text := 'R' + floattostrf(CurrentBudget, ffFixed, 10, 2);
end;

// ============================================================
// THE THREE FACTORS - HELPERS
// ============================================================

function TfrmCustomers.ChosenFormality: Integer;
begin
  // ItemIndex is 0-based; the bands are 1-based. -1 (nothing
  // selected) falls through to 0, which the caller checks.
  result := FormalityScore.ItemIndex + 1;
end;

function TfrmCustomers.NeedOuterwear(temp: double): boolean;
begin
  result := (temp <= 18);
end;

// FACTOR 2: temperature -> the warmth an outfit should total.
// Inverse and linear. 0 C -> 30, 20 C -> 18, 35 C -> 9.
function TfrmCustomers.WarmthTarget(temp: double): Integer;
var
  rTarget: double;
begin
  rTarget := 30 - (temp * 0.6);

  // Clamp to what a wardrobe can actually reach, so the
  // algorithm never aims at an impossible number.
  if rTarget < 6 then
    rTarget := 6;
  if rTarget > 32 then
    rTarget := 32;

  result := Round(rTarget);
end;

// How far outside the +/-4 tolerance band, converted to points.
function TfrmCustomers.WarmthPenalty(target, total: Integer): Integer;
var
  iLow, iHigh, miss: Integer;
begin
  iLow := target - 4;
  iHigh := target + 4;

  if total < iLow then
    miss := iLow - total
  else if total > iHigh then
    miss := total - iHigh
  else
    miss := 0;

  result := miss * 5;
end;

// FACTOR 3: one accent colour against neutrals is ideal.
function TfrmCustomers.AccentsToPoints(iAccents: Integer): Integer;
begin
  case iAccents of
    0:
      result := 6; // all neutral - safe, a little plain
    1:
      result := 10; // one focal point - best balance
    2:
      result := -8; // two colours competing
  else
    result := -25; // three or more clash
  end;
end;

// Colour's swing is small next to warmth's, which is what keeps
// the hierarchy: colour can never outvote the weather.
function TfrmCustomers.MatchScore(miss, colour_adjustment: Integer): Integer;
begin
  result := 100 - miss + colour_adjustment;
end;

// FACTOR 1: a hard filter. Items outside the band, or dirty, are
// never considered. The category arrays are cleared first so that
// repeated clicks do not accumulate.
procedure TfrmCustomers.SortOnFormality(formality_range: Integer);
var
  iLow, iHigh, i: Integer;
begin
  ClearCategoryArrays;

  case formality_range of
    1:
      begin
        iLow := 1;
        iHigh := 3;
      end;
    2:
      begin
        iLow := 4;
        iHigh := 7;
      end;
    3:
      begin
        iLow := 8;
        iHigh := 10;
      end;
  else
    begin
      iLow := 1;
      iHigh := 10;
    end; // never leave them unset
  end;

  for i := 0 to High(arrGarments) do
    if arrGarments[i].InBand(iLow, iHigh) and arrGarments[i].getClean then
    begin
      if arrGarments[i].getCategory = 'Top' then
      begin
        SetLength(arrTops, Length(arrTops) + 1);
        arrTops[High(arrTops)] := arrGarments[i] as TTop;
      end
      else if arrGarments[i].getCategory = 'Bottom' then
      begin
        SetLength(arrBottoms, Length(arrBottoms) + 1);
        arrBottoms[High(arrBottoms)] := arrGarments[i] as TBottom;
      end
      else if arrGarments[i].getCategory = 'Shoes' then
      begin
        SetLength(arrShoes, Length(arrShoes) + 1);
        arrShoes[High(arrShoes)] := arrGarments[i] as TShoes;
      end
      else if arrGarments[i].getCategory = 'Outerwear' then
      begin
        SetLength(arrOuterwear, Length(arrOuterwear) + 1);
        arrOuterwear[High(arrOuterwear)] := arrGarments[i] as TOuterwear;
      end;
    end;
end;

// ============================================================
// GENERATE OUTFIT
// ============================================================

procedure TfrmCustomers.ShowGarmentImage(g: TGarment; img: TImage);
var
  sPath: string;
begin
  if g = nil then
    img.Visible := false
  else
  begin
    sPath := ExtractFilePath(Application.ExeName) + 'clothes\' +
      g.getItemID + '.jpg';

    if FileExists(sPath) then
    begin
      img.Picture.LoadFromFile(sPath);
      img.Stretch := true;
      img.Proportional := true;
      img.Center := true;
      img.Visible := true;
    end
    else
      img.Visible := false;
  end;
end;

procedure TfrmCustomers.btnGenOutfitClick(Sender: TObject);
var
  formality, target, best_score: Integer;
  tops, bottoms, shoes, outerwear: Integer;
  iAccents, warmth_total, score: Integer;
  sMissing: string;
  bOuter: boolean;
begin
  formality := ChosenFormality;

  if formality = 0 then
    showmessage('Please choose a dress code before generating an outfit.')
  else if not bWeatherFetched then
    showmessage('Please fetch the current weather first, so the outfit ' +
      'can be matched to today''s temperature.')
  else
  begin
    SortOnFormality(formality);
    target := WarmthTarget(LTemp);
    bOuter := NeedOuterwear(LTemp);

    // -- report every empty category at once, not one at a time
    sMissing := '';
    if Length(arrTops) = 0 then
      sMissing := sMissing + 'tops, ';
    if Length(arrBottoms) = 0 then
      sMissing := sMissing + 'bottoms, ';
    if Length(arrShoes) = 0 then
      sMissing := sMissing + 'shoes, ';
    if bOuter and (Length(arrOuterwear) = 0) then
      sMissing := sMissing + 'outerwear, ';

    if sMissing <> '' then
      showmessage('No clean ' + sMissing + 'available in this dress code.' +
        #13#10 + 'Clean or buy items before generating an outfit.')
    else
    begin
      best_score := no_score;
      arrOutfits[0] := nil;
      arrOutfits[1] := nil;
      arrOutfits[2] := nil;
      arrOutfits[3] := nil;
      bOutfitHasOuter := bOuter;

      if bOuter then
      begin
        // ---- four nested loops: outerwear is required --------
        for tops := 0 to High(arrTops) do
          for bottoms := 0 to High(arrBottoms) do
            for shoes := 0 to High(arrShoes) do
              for outerwear := 0 to High(arrOuterwear) do
              begin
                // reset per OUTFIT, not per category
                iAccents := 0;

                warmth_total := arrTops[tops].getWarmth + arrBottoms[bottoms]
                  .getWarmth + arrShoes[shoes].getWarmth + arrOuterwear
                  [outerwear].getWarmth;

                if not arrTops[tops].IsNeutral then
                  inc(iAccents);
                if not arrBottoms[bottoms].IsNeutral then
                  inc(iAccents);
                if not arrShoes[shoes].IsNeutral then
                  inc(iAccents);
                if not arrOuterwear[outerwear].IsNeutral then
                  inc(iAccents);

                score := MatchScore(WarmthPenalty(target, warmth_total),
                  AccentsToPoints(iAccents));

                if score > best_score then
                begin
                  best_score := score;
                  arrOutfits[0] := arrTops[tops];
                  arrOutfits[1] := arrBottoms[bottoms];
                  arrOutfits[2] := arrShoes[shoes];
                  arrOutfits[3] := arrOuterwear[outerwear];
                end;
              end;
      end
      else
      begin
        // ---- three nested loops: no outerwear ---------------
        for tops := 0 to High(arrTops) do
          for bottoms := 0 to High(arrBottoms) do
            for shoes := 0 to High(arrShoes) do
            begin
              iAccents := 0;

              warmth_total := arrTops[tops].getWarmth + arrBottoms[bottoms]
                .getWarmth + arrShoes[shoes].getWarmth;

              if not arrTops[tops].IsNeutral then
                inc(iAccents);
              if not arrBottoms[bottoms].IsNeutral then
                inc(iAccents);
              if not arrShoes[shoes].IsNeutral then
                inc(iAccents);

              score := MatchScore(WarmthPenalty(target, warmth_total),
                AccentsToPoints(iAccents));

              if score > best_score then
              begin
                best_score := score;
                arrOutfits[0] := arrTops[tops];
                arrOutfits[1] := arrBottoms[bottoms];
                arrOutfits[2] := arrShoes[shoes];
                arrOutfits[3] := nil;
              end;
            end;
      end;

      // -- display -------------------------------------------
      ShowGarmentImage(arrOutfits[0], imgTop); // top
      ShowGarmentImage(arrOutfits[1], imgBottom); // bottom
      ShowGarmentImage(arrOutfits[2], imgShoes); // shoes
      ShowGarmentImage(arrOutfits[3], imgOuter); // outerwear (nil hides it)

      warmth_total := arrOutfits[0].getWarmth + arrOutfits[1].getWarmth +
        arrOutfits[2].getWarmth;
      if arrOutfits[3] <> nil then
        warmth_total := warmth_total + arrOutfits[3].getWarmth;

      redWardDisplay.Lines.Clear;
      redWardDisplay.Lines.Add('=========================================');
      redWardDisplay.Lines.Add('        RECOMMENDED OUTFIT');
      redWardDisplay.Lines.Add('=========================================');
      redWardDisplay.Lines.Add('Dress code   : ' + FormalityScore.Text);
      redWardDisplay.Lines.Add('Temperature  : ' + floattostrf(LTemp, ffFixed, 10,
        1) + ' C');
      redWardDisplay.Lines.Add('Warmth target: ' + inttostr(target) + '  (' +
        inttostr(target - 4) + '-' + inttostr(target + 4) + ')');
      redWardDisplay.Lines.Add('-----------------------------------------');
      redWardDisplay.Lines.Add(arrOutfits[0].toString);
      redWardDisplay.Lines.Add(arrOutfits[1].toString);
      redWardDisplay.Lines.Add(arrOutfits[2].toString);
      if arrOutfits[3] <> nil then
        redWardDisplay.Lines.Add(arrOutfits[3].toString)
      else
        redWardDisplay.Lines.Add('OUTERWEAR: not needed at this temperature');
      redWardDisplay.Lines.Add('-----------------------------------------');
      redWardDisplay.Lines.Add('Outfit warmth: ' + inttostr(warmth_total));
      redWardDisplay.Lines.Add('MATCH SCORE  : ' + inttostr(best_score) + ' / 110');
    end;
  end;
end;

procedure TfrmCustomers.btnLOGOUTClick(Sender: TObject);
begin
  frmCustomers.close;
end;

// ============================================================
// CHECK OUTFIT
// Runs the same three factors on the outfit currently shown.
// ============================================================

procedure TfrmCustomers.btnChkClick(Sender: TObject);
var
  iLow, iHigh, target, total, iAccents, score, i: Integer;
  bInBand, bClean: boolean;
begin
  if arrOutfits[0] = nil then
    showmessage('Generate an outfit first, or select one to check.')
  else
  begin
    case ChosenFormality of
      1:
        begin
          iLow := 1;
          iHigh := 3;
        end;
      2:
        begin
          iLow := 4;
          iHigh := 7;
        end;
      3:
        begin
          iLow := 8;
          iHigh := 10;
        end;
    else
      begin
        iLow := 1;
        iHigh := 10;
      end;
    end;

    target := WarmthTarget(LTemp);
    total := 0;
    iAccents := 0;
    bInBand := true;
    bClean := true;

    redWardDisplay.Lines.Clear;
    redWardDisplay.Lines.Add('=========================================');
    redWardDisplay.Lines.Add('      OUTFIT COMPATIBILITY CHECK');
    redWardDisplay.Lines.Add('=========================================');

    for i := 0 to 3 do
      if arrOutfits[i] <> nil then
      begin
        total := total + arrOutfits[i].getWarmth;

        if not arrOutfits[i].IsNeutral then
          inc(iAccents);

        if not arrOutfits[i].InBand(iLow, iHigh) then
        begin
          redWardDisplay.Lines.Add('X ' + arrOutfits[i].getItemName +
            ' is formality ' + inttostr(arrOutfits[i].getFormality) +
            ' - outside ' + inttostr(iLow) + '-' + inttostr(iHigh));
          bInBand := false;
        end;

        if not arrOutfits[i].getClean then
        begin
          redWardDisplay.Lines.Add('X ' + arrOutfits[i].getItemName +
            ' is in the wash.');
          bClean := false;
        end;
      end;

    if bInBand then
      redWardDisplay.Lines.Add('OK - every piece suits a ' + FormalityScore.Text +
        ' event.');
    if bClean then
      redWardDisplay.Lines.Add('OK - every piece is clean.');

    redWardDisplay.Lines.Add('-----------------------------------------');
    redWardDisplay.Lines.Add('Warmth : ' + inttostr(total) + '  (target ' +
      inttostr(target - 4) + '-' + inttostr(target + 4) + ')');

    if WarmthPenalty(target, total) = 0 then
      redWardDisplay.Lines.Add('   OK - suited to ' + floattostrf(LTemp, ffFixed, 10,
        1) + ' C.')
    else if total < target then
      redWardDisplay.Lines.Add('   X Too light - you will feel cold.')
    else
      redWardDisplay.Lines.Add('   X Too warm - you will overheat.');

    redWardDisplay.Lines.Add('Accents: ' + inttostr(iAccents));
    if iAccents <= 1 then
      redWardDisplay.Lines.Add('   OK - well balanced.')
    else
      redWardDisplay.Lines.Add('   X Too many accent colours.');

    score := MatchScore(WarmthPenalty(target, total),
      AccentsToPoints(iAccents));

    redWardDisplay.Lines.Add('-----------------------------------------');
    redWardDisplay.Lines.Add('MATCH SCORE : ' + inttostr(score) + ' / 110');

    if not bInBand then
      redWardDisplay.Lines.Add('VERDICT     : Wrong dress code.')
    else if score >= 95 then
      redWardDisplay.Lines.Add('VERDICT     : Excellent choice.')
    else if score >= 75 then
      redWardDisplay.Lines.Add('VERDICT     : Good, with minor issues.')
    else
      redWardDisplay.Lines.Add('VERDICT     : Poor match.');
  end;
end;

// ============================================================
// FINALISE (wear it)
// Marks every piece of the shown outfit as worn: Times_Worn
// goes up by one and the item becomes dirty.
// ============================================================

procedure TfrmCustomers.btnFinaliseClick(Sender: TObject);
var
  i, iCount: Integer;
begin
  if arrOutfits[0] = nil then
    showmessage('Generate an outfit before finalising it.')
  else if MessageDlg('Wear this outfit today?' + #13#10 +
    'Each piece will be marked as worn and will need cleaning.', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    iCount := 0;

    with dmPAT2026_1 do
      try
        for i := 0 to 3 do
          if arrOutfits[i] <> nil then
          begin
            if qryMain.Active then
              qryMain.Close;

            qryMain.SQL.Text :=
              'UPDATE tblWardrobes SET Times_Worn = Times_Worn + 1, ' +
              'Is_Clean = :pClean WHERE UserID = :pUserID AND ItemID = :pItemID';
            qryMain.Parameters.ParamByName('pClean').Value := false;
            qryMain.Parameters.ParamByName('pUserID').Value := userID;
            qryMain.Parameters.ParamByName('pItemID').Value :=
              arrOutfits[i].getItemID;
            qryMain.ExecSQL;
            inc(iCount);
          end;

        qryWardrobe.Close;
        qryWardrobe.Open;
        LoadWardrobeObjects; // objects must match the database

        showmessage(inttostr(iCount) + ' item(s) marked as worn. ' +
          'Remember to clean them before wearing again.');

        arrOutfits[0] := nil;
        arrOutfits[1] := nil;
        arrOutfits[2] := nil;
        arrOutfits[3] := nil;

        imgOuter.Picture := nil;
        imgBottom.Picture := nil;
        imgTop.Picture := nil;
        imgShoes.Picture := nil;
      except
        on E: Exception do
          showmessage('The outfit could not be finalised.' + #13#10 +
            'Database error: ' + E.Message);
      end;
  end;
end;

// ============================================================
// WARDROBE ACTIONS
// ============================================================

procedure TfrmCustomers.btnCleanClick(Sender: TObject);
begin
  with dmPAT2026_1 do
    if (not qryWardrobe.Active) or qryWardrobe.IsEmpty then
      showmessage('Please select an item from your wardrobe.')
    else if qryWardrobe.FieldByName('Is_Clean').AsBoolean then
      showmessage('That item is already clean.')
    else if not HasEnoughFunds(userID, clean_cost) then
      showmessage('You do not have enough funds to clean this item. ' +
        'Deposit more money in order to wash it.')
    else if MessageDlg('Clean this item? A cost of R' + floattostrf(clean_cost,
      ffFixed, 10, 2) + ' will be charged.', mtConfirmation, [mbYes, mbNo], 0) = mrYes
    then
      try
        // One UPDATE only. Editing the query AND running an UPDATE
        // would apply the change twice.
        if qryMain.Active then
          qryMain.Close;
        qryMain.SQL.Text := 'UPDATE tblWardrobes SET Is_Clean = :pValue ' +
          'WHERE UserID = :pUserID AND ItemID = :pItemID';
        qryMain.Parameters.ParamByName('pValue').Value := true;
        qryMain.Parameters.ParamByName('pUserID').Value := userID;
        qryMain.Parameters.ParamByName('pItemID').Value :=
          qryWardrobe.FieldByName('ItemID').AsString;
        qryMain.ExecSQL;

        qryMain.SQL.Text := 'UPDATE tblUsers SET Budget = Budget - :pValue ' +
          'WHERE UserID = :pUserID';
        qryMain.Parameters.ParamByName('pValue').Value := clean_cost;
        qryMain.Parameters.ParamByName('pUserID').Value := userID;
        qryMain.ExecSQL;

        tblUsers.Close;
        tblUsers.Open;
        qryWardrobe.Close;
        qryWardrobe.Open;
        LoadWardrobeObjects;
        RefreshBalance;
        showmessage('Item cleaned. R' + floattostrf(clean_cost, ffFixed, 10, 2)
          + ' charged.');
      except
        on E: Exception do
          showmessage('The item could not be cleaned.' + #13#10 + E.Message);
      end;
end;

procedure TfrmCustomers.btnMaintainClick(Sender: TObject);
begin
  with dmPAT2026_1 do
    if (not qryWardrobe.Active) or qryWardrobe.IsEmpty then
      showmessage('Please select an item from your wardrobe.')
    else if not HasEnoughFunds(userID, maintenance_cost) then
      showmessage('You do not have enough funds to maintain this item.')
    else if MessageDlg('Maintain this item? A cost of R' +
      floattostrf(maintenance_cost, ffFixed, 10, 2) + ' will be charged.',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      try
        if qryMain.Active then
          qryMain.Close;

        // Times_Worn - 3 inside the database, and clamped at 0 by
        // the second statement so it can never go negative.
        qryMain.SQL.Text := 'UPDATE tblWardrobes SET Times_Worn = ' +
          'Times_Worn - :pValue WHERE UserID = :pUserID AND ItemID = :pItemID '
          + 'AND Times_Worn >= :pValue2';
        qryMain.Parameters.ParamByName('pValue').Value := 3;
        qryMain.Parameters.ParamByName('pUserID').Value := userID;
        qryMain.Parameters.ParamByName('pItemID').Value :=
          qryWardrobe.FieldByName('ItemID').AsString;
        qryMain.Parameters.ParamByName('pValue2').Value := 3;
        qryMain.ExecSQL;

        qryMain.SQL.Text := 'UPDATE tblWardrobes SET Times_Worn = 0 ' +
          'WHERE UserID = :pUserID AND ItemID = :pItemID AND Times_Worn < :pMin';
        qryMain.Parameters.ParamByName('pUserID').Value := userID;
        qryMain.Parameters.ParamByName('pItemID').Value :=
          qryWardrobe.FieldByName('ItemID').AsString;
        qryMain.Parameters.ParamByName('pMin').Value := 3;
        qryMain.ExecSQL;

        qryMain.SQL.Text := 'UPDATE tblUsers SET Budget = Budget - :pValue ' +
          'WHERE UserID = :pUserID';
        qryMain.Parameters.ParamByName('pValue').Value := maintenance_cost;
        qryMain.Parameters.ParamByName('pUserID').Value := userID;
        qryMain.ExecSQL;

        tblUsers.Close;
        tblUsers.Open;
        qryWardrobe.Close;
        qryWardrobe.Open;
        LoadWardrobeObjects;
        RefreshBalance;
        showmessage('Item maintained. R' + floattostrf(maintenance_cost,
          ffFixed, 10, 2) + ' charged.');
      except
        on E: Exception do
          showmessage('The item could not be maintained.' + #13#10 + E.Message);
      end;
end;

procedure TfrmCustomers.btnDepositClick(Sender: TObject);
var
  rAmount, rOldBudget, rNewBudget: double;
  bCanDeposit: boolean;
begin
  bCanDeposit := true;
  rAmount := 0;

  if Trim(edtDeposit.Text) = '' then
  begin
    showmessage('Please enter an amount to deposit.');
    edtDeposit.SetFocus;
    bCanDeposit := false;
  end
  else if not IsValidAmount(edtDeposit.Text, rAmount) then
  begin
    showmessage('"' + edtDeposit.Text + '" is not a valid amount.' + #13#10 +
      'Enter digits only, for example 250 or 250.50');
    edtDeposit.SetFocus;
    edtDeposit.SelectAll;
    bCanDeposit := false;
  end
  else if rAmount <= 0 then
  begin
    showmessage('The deposit must be greater than R0.00.');
    edtDeposit.SetFocus;
    edtDeposit.SelectAll;
    bCanDeposit := false;
  end
  else if rAmount < min_deposit then
  begin
    showmessage('The minimum deposit is R' + floattostrf(min_deposit, ffFixed,
      10, 2) + '.');
    edtDeposit.SetFocus;
    edtDeposit.SelectAll;
    bCanDeposit := false;
  end
  else if rAmount > max_deposit then
  begin
    showmessage('The maximum single deposit is R' + floattostrf(max_deposit,
      ffFixed, 10, 2) + '.' + #13#10 + 'Please check the amount you entered.');
    edtDeposit.SetFocus;
    edtDeposit.SelectAll;
    bCanDeposit := false;
  end
  // Two decimal places at most: 250.567 is not a money value.
  else if Abs(rAmount * 100 - Round(rAmount * 100)) > 0.001 then
  begin
    showmessage('Enter at most two decimal places, for example 250.50');
    edtDeposit.SetFocus;
    edtDeposit.SelectAll;
    bCanDeposit := false;
  end;

  if bCanDeposit and (userID = '') then
  begin
    showmessage('No user is signed in. Please log in again.');
    bCanDeposit := false;
  end;

  if bCanDeposit then
    if MessageDlg('Deposit R' + floattostrf(rAmount, ffFixed, 10, 2) +
      ' into your OptiCorp wallet?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes
    then
      bCanDeposit := false;

  if bCanDeposit then
    with dmPAT2026_1 do
      try
        rOldBudget := CurrentBudget;

        if qryMain.Active then
          qryMain.Close;

        // The arithmetic happens INSIDE the database, so no stale
        // value read into Delphi can be written back.
        qryMain.SQL.Text := 'UPDATE tblUsers SET Budget = Budget + :pValue ' +
          'WHERE UserID = :pUserID';
        qryMain.Parameters.ParamByName('pValue').Value := rAmount;
        qryMain.Parameters.ParamByName('pUserID').Value := userID;
        qryMain.ExecSQL;

        tblUsers.Close;
        tblUsers.Open;
        rNewBudget := CurrentBudget;
        RefreshBalance;

        showmessage('R' + floattostrf(rAmount, ffFixed, 10, 2) +
          ' deposited successfully.' + #13#10 + 'Previous balance : R' +
          floattostrf(rOldBudget, ffFixed, 10, 2) + #13#10 +
          'New balance      : R' + floattostrf(rNewBudget, ffFixed, 10, 2));

        edtDeposit.Clear;
        edtDeposit.SetFocus;
      except
        on E: Exception do
          showmessage('The deposit could not be completed.' + #13#10 +
            'Database error: ' + E.Message);
      end;
end;

procedure TfrmCustomers.btnDiscardClick(Sender: TObject);
var
  sItemID, sItemName: string;
begin
  with dmPAT2026_1 do
    if (not qryWardrobe.Active) or qryWardrobe.IsEmpty then
      showmessage('Please select an item from your wardrobe.')
    else if radDiscard.ItemIndex = -1 then
      showmessage('Please choose a method of discarding the item.')
    else if not HasEnoughFunds(userID, discard_cost) then
      showmessage('You do not have enough funds to discard this item.')
    else
    begin
      sItemID := qryWardrobe.FieldByName('ItemID').AsString;
      sItemName := qryWardrobe.FieldByName('Item_Name').AsString;

      if MessageDlg('Permanently discard ' + sItemName + '?' + #13#10 +
        'A cost of R' + floattostrf(discard_cost, ffFixed, 10, 2) +
        ' will be charged. This cannot be undone.', mtWarning, [mbYes, mbNo], 0)
        = mrYes then
        try
          if qryMain.Active then
            qryMain.Close;
          qryMain.SQL.Text := 'DELETE FROM tblWardrobes ' +
            'WHERE UserID = :pUserID AND ItemID = :pItemID';
          qryMain.Parameters.ParamByName('pUserID').Value := userID;
          qryMain.Parameters.ParamByName('pItemID').Value := sItemID;
          qryMain.ExecSQL;

          // discard_cost, not maintenance_cost
          qryMain.SQL.Text := 'UPDATE tblUsers SET Budget = Budget - :pValue ' +
            'WHERE UserID = :pUserID';
          qryMain.Parameters.ParamByName('pValue').Value := discard_cost;
          qryMain.Parameters.ParamByName('pUserID').Value := userID;
          qryMain.ExecSQL;

          tblUsers.Close;
          tblUsers.Open;
          qryWardrobe.Close;
          qryWardrobe.Open;
          qryShop.Close;
          qryShop.Open;
          LoadWardrobeObjects;
          RefreshBalance;
          showmessage(sItemName + ' discarded.');
        except
          on E: Exception do
            showmessage('The item could not be discarded.' + #13#10 +
              E.Message);
        end;
    end;
end;

procedure TfrmCustomers.dbgUserWardrobeCellClick(Column: TColumn);
var
  sPath: string;
begin
  with dmPAT2026_1 do
    if qryWardrobe.Active and (not qryWardrobe.IsEmpty) then
    begin
      chkClean.Checked := qryWardrobe.FieldByName('Is_Clean').AsBoolean;

      // ExtractFilePath already ends in a backslash
      sPath := ExtractFilePath(Application.ExeName) + 'clothes\' +
        qryWardrobe.FieldByName('ItemID').AsString + '.jpg';

      if FileExists(sPath) then
      begin
        imgWard.Picture.LoadFromFile(sPath);
        imgWard.Visible := true;
      end
      else
        imgWard.Visible := false;
    end;
end;

// ============================================================
// SHOP
// ============================================================

procedure TfrmCustomers.dbgShopCellClick(Column: TColumn);
begin
  with dmPAT2026_1 do
    if qryShop.Active and (not qryShop.IsEmpty) then
    begin
      sedFS.Value := qryShop.FieldByName('Formality_Score').AsInteger;
      sedWarmth.Value := qryShop.FieldByName('Warmth_Rating').AsInteger;
      edtPrice.Text := 'R' + floattostrf(qryShop.FieldByName('Price').AsFloat,
        ffFixed, 10, 2);
    end;
end;

procedure TfrmCustomers.btnPurchaseClick(Sender: TObject);
var
  rPrice: double;
  sItemID, sItemName, sNewWardrobeID: string;
  iNext: Integer;
begin
  with dmPAT2026_1 do
    if (not qryShop.Active) or qryShop.IsEmpty then
      showmessage('Please select an item to purchase.')
    else
    begin
      sItemID := qryShop.FieldByName('ItemID').AsString;
      sItemName := qryShop.FieldByName('Item_Name').AsString;
      rPrice := qryShop.FieldByName('Price').AsFloat;

      if not HasEnoughFunds(userID, rPrice) then
        showmessage('You cannot afford ' + sItemName + '.' + #13#10 + 'Price R'
          + floattostrf(rPrice, ffFixed, 10, 2) + ', balance R' +
          floattostrf(CurrentBudget, ffFixed, 10, 2) + '.')
      else if MessageDlg('Purchase ' + sItemName + ' for R' +
        floattostrf(rPrice, ffFixed, 10, 2) + '?', mtConfirmation,
        [mbYes, mbNo], 0) = mrYes then
        try
          // -- next wardrobe number for this consumer ------------
          if qryMain.Active then
            qryMain.Close;
          qryMain.SQL.Text := 'SELECT COUNT(*) AS Total FROM tblWardrobes ' +
            'WHERE UserID = :pUserID';
          qryMain.Parameters.ParamByName('pUserID').Value := userID;
          qryMain.Open;
          iNext := qryMain.FieldByName('Total').AsInteger + 1;
          qryMain.Close;

          // UserID is CON-101-CPT, so characters 5..7 are the number
          sNewWardrobeID := 'WD-' + Copy(userID, 5, 3) + '-' +
            formatfloat('00', iNext);

          qryMain.SQL.Text :=
            'INSERT INTO tblWardrobes (WardrobeID, UserID, ItemID, ' +
            'Purchase_Date, Times_Worn, Is_Clean) VALUES ' +
            '(:pWID, :pUserID, :pItemID, :pDate, :pWorn, :pClean)';
          qryMain.Parameters.ParamByName('pWID').Value := sNewWardrobeID;
          qryMain.Parameters.ParamByName('pUserID').Value := userID;
          qryMain.Parameters.ParamByName('pItemID').Value := sItemID;
          qryMain.Parameters.ParamByName('pDate').Value := Date;
          qryMain.Parameters.ParamByName('pWorn').Value := 0;
          qryMain.Parameters.ParamByName('pClean').Value := true;
          qryMain.ExecSQL;

          // -- pay for it, and take one off the shelf ------------
          qryMain.SQL.Text := 'UPDATE tblUsers SET Budget = Budget - :pValue ' +
            'WHERE UserID = :pUserID';
          qryMain.Parameters.ParamByName('pValue').Value := rPrice;
          qryMain.Parameters.ParamByName('pUserID').Value := userID;
          qryMain.ExecSQL;

          qryMain.SQL.Text := 'UPDATE tblInventory SET Quantity_Stock = ' +
            'Quantity_Stock - 1 WHERE ItemID = :pItemID AND Quantity_Stock > 0';
          qryMain.Parameters.ParamByName('pItemID').Value := sItemID;
          qryMain.ExecSQL;

          tblUsers.Close;
          tblUsers.Open;
          tblInventory.Close;
          tblInventory.Open;
          qryWardrobe.Close;
          qryWardrobe.Open;
          qryShop.Close;
          qryShop.Open;
          LoadWardrobeObjects;
          RefreshBalance;

          showmessage(sItemName + ' purchased and added to your wardrobe.');
        except
          on E: Exception do
            showmessage('The purchase could not be completed.' + #13#10 +
              E.Message);
        end;
    end;
end;

procedure TfrmCustomers.btnShopClick(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcUser.ActivePageIndex := 3;
  finally
    FAllowTabChange := False;
  end;
end;

procedure TfrmCustomers.btnWalletClick(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcUser.ActivePageIndex := 2;
  finally
    FAllowTabChange := False;
  end;
end;

procedure TfrmCustomers.btnWardrobesClick(Sender: TObject);
begin
  FAllowTabChange := True;

  try
    pgcUser.ActivePageIndex := 1;
  finally
    FAllowTabChange := False;
  end;
end;

// ============================================================
// WALLET
// ============================================================

// gives the user info on their wardrobe
procedure TfrmCustomers.imgInfoClick(Sender: TObject);
var rTotalCost: real;
    iDirty, iItems: integer;
begin
  with dmPAT2026_1 do
  begin
    qryMain.SQL.Text := 'SELECT SUM(tblInventory.Price) AS Total FROM' +
                        ' tblInventory, tblWardrobes WHERE tblWardrobes.UserID =' +
                        ' :pUser AND tblInventory.ItemID = tblWardrobes.ItemID';
    qryMain.Parameters.ParamByName('pUser').Value := userid;
    qryMain.Open;
    rTotalCost := qryMain.FieldByName('Total').AsFloat;

    qryMain.Close;

    qryMain.SQL.Text := 'SELECT COUNT(*) AS Total FROM' +
                        ' tblWardrobes WHERE UserID = :pUser AND Is_Clean = False';
    qryMain.Parameters.ParamByName('pUser').Value := userid;
    qryMain.Open;
    iDirty := qryMain.FieldByName('Total').AsInteger;

    qryMain.Close;

    qryMain.SQL.Text := 'SELECT COUNT(*) AS Total FROM' +
                        ' tblWardrobes WHERE UserID = :pUser';
    qryMain.Parameters.ParamByName('pUser').Value := userid;
    qryMain.Open;
    iItems := qryMain.FieldByName('Total').AsInteger;
  end;

  showmessage('WARDROBE INFO' + #13 + 'WARDROBE VALUE:  ' + floattostrf(rTotalCost, ffcurrency, 10, 2)
              + #13 + inttostr(iDirty) + ' out of ' + inttostr(iItems) + ' is clean');
end;

function TfrmCustomers.IsValidAmount(const s: string; out r: double): boolean;
var
  sClean: string;
  i: Integer;
begin
  // Strip a leading R and any spaces, so 'R 250.00' still works
  sClean := '';
  for i := 1 to Length(s) do
    if not CharInSet(s[i], ['R', 'r', ' ']) then
      sClean := sClean + s[i];

  sClean := Trim(sClean);

  // TryStrToFloat never raises - it returns False on bad input
  result := TryStrToFloat(sClean, r);
  if not result then
    r := 0;
end;

// ============================================================
// WEATHER
// ============================================================

procedure TfrmCustomers.btnWeatherClick(Sender: TObject);
var
  LJsonObj, LMainObj, LWindObject: TJSONObject;
  LWeatherArray: TJSONArray;
  LMinTemp, LMaxTemp, LHumidity, LFeelsLike, LWindSpeed: double;
  LDesc, scity: string;
begin
  scity := '';
  with dmPAT2026_1 do
    if tblUsers.Locate('UserID', userID, []) then
      scity := tblUsers.FieldByName('City').AsString;

  if scity = '' then
  begin
    showmessage('Your city could not be found, so the weather cannot ' +
      'be fetched. A default of ' + floattostrf(default_temp, ffFixed, 10, 1) +
      ' C will be used.');
    LTemp := default_temp;
    bWeatherFetched := true;
  end
  else
  begin
    RESTClient.BaseURL := 'https://api.openweathermap.org/data/2.5/weather';
    RESTRequest.Params.Clear;
    RESTRequest.AddParameter('q', scity + ',ZA');
    RESTRequest.AddParameter('appid', api_key);
    RESTRequest.AddParameter('units', 'metric');

    try
      RESTRequest.Execute;

      if RESTResponse.StatusCode = 200 then
      begin
        LJsonObj := RESTResponse.JSONValue as TJSONObject;
        LMainObj := LJsonObj.GetValue('main') as TJSONObject;
        LTemp := LMainObj.GetValue('temp').Value.ToDouble;
        LMinTemp := LMainObj.GetValue('temp_min').Value.ToDouble;
        LMaxTemp := LMainObj.GetValue('temp_max').Value.ToDouble;
        LHumidity := LMainObj.GetValue('humidity').Value.ToDouble;
        LFeelsLike := LMainObj.GetValue('feels_like').Value.ToDouble;

        LWeatherArray := LJsonObj.GetValue('weather') as TJSONArray;
        LDesc := (LWeatherArray.Items[0] as TJSONObject).GetValue('main').Value
          + ', ' + (LWeatherArray.Items[0] as TJSONObject)
          .GetValue('description').Value;

        LWindObject := LJsonObj.GetValue('wind') as TJSONObject;
        LWindSpeed := LWindObject.GetValue('speed').Value.ToDouble;

        bWeatherFetched := true;

        redWardDisplay.Lines.Clear;
        redWardDisplay.Lines.Add('=========================================');
        redWardDisplay.Lines.Add('   CURRENT WEATHER - ' + UpperCase(scity));
        redWardDisplay.Lines.Add('=========================================');
        redWardDisplay.Lines.Add('Temperature : ' + floattostrf(LTemp, ffFixed, 10,
          1) + ' C');
        redWardDisplay.Lines.Add('Feels like  : ' + floattostrf(LFeelsLike, ffFixed,
          10, 1) + ' C');
        redWardDisplay.Lines.Add('Range       : ' + floattostrf(LMinTemp, ffFixed,
          10, 1) + ' - ' + floattostrf(LMaxTemp, ffFixed, 10, 1) + ' C');
        redWardDisplay.Lines.Add('Conditions  : ' + LDesc);
        redWardDisplay.Lines.Add('Humidity    : ' + floattostrf(LHumidity, ffFixed,
          10, 0) + ' %');
        redWardDisplay.Lines.Add('Wind        : ' + floattostrf(LWindSpeed, ffFixed,
          10, 1) + ' m/s');
        redWardDisplay.Lines.Add('-----------------------------------------');
        redWardDisplay.Lines.Add('Warmth target for an outfit today: ' +
          inttostr(WarmthTarget(LTemp)));

        if NeedOuterwear(LTemp) then
          redWardDisplay.Lines.Add('Outerwear will be included.')
        else
          redWardDisplay.Lines.Add('Outerwear is not needed today.');
      end
      else
      begin
        LTemp := default_temp;
        bWeatherFetched := true;
        redWardDisplay.Lines.Add('Weather unavailable (' + RESTResponse.StatusText +
          ', code ' + inttostr(RESTResponse.StatusCode) + ').');
        redWardDisplay.Lines.Add('Using a default of ' + floattostrf(default_temp,
          ffFixed, 10, 1) + ' C.');
      end;
    except
      on E: Exception do
      begin
        LTemp := default_temp;
        bWeatherFetched := true;
        showmessage('The weather service could not be reached.' + #13#10 +
          'A default of ' + floattostrf(default_temp, ffFixed, 10, 1) +
          ' C will be used.' + #13#10 + E.Message);
      end;
    end;
  end;
end;

// ============================================================
// FORM SETUP / TEARDOWN
// ============================================================

procedure TfrmCustomers.FormActivate(Sender: TObject);
begin
  {tbsCustomer.TabVisible := false;
  tbsWardrobe.TabVisible := false;
  tbsWallet.TabVisible := false;
  tbsShop.TabVisible := false;}

  pgcUser.ActivePageIndex := 0;

  FormatSettings.DecimalSeparator := '.';
  bWeatherFetched := false;
  LTemp := default_temp;

  with dmPAT2026_1 do
  begin
    // 'if not Active then Open' - Open on an already-open dataset
    // raises, and FormActivate fires on every focus change.
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

    // -- the consumer's own wardrobe -------------------------
    if qryWardrobe.Active then
      qryWardrobe.Close;
    qryWardrobe.SQL.Text :=
      'SELECT tblInventory.ItemID, tblInventory.Item_Name, ' +
      '       tblInventory.BrandID, tblInventory.Color_Family, ' +
      '       tblInventory.Formality_Score, tblInventory.Warmth_Rating, ' +
      '       tblInventory.Category, tblWardrobes.Is_Clean, ' +
      '       tblWardrobes.Times_Worn, tblWardrobes.WardrobeID ' +
      'FROM tblInventory, tblWardrobes ' +
      'WHERE tblInventory.ItemID = tblWardrobes.ItemID ' +
      '  AND tblWardrobes.UserID = :pUser';
    qryWardrobe.Parameters.ParamByName('pUser').Value := userID;
    qryWardrobe.Open;

    LoadWardrobeObjects;

    // -- the shop: everything the consumer does NOT own ------
    // A subquery is required. 'ItemID <> ItemID' across two
    // tables would pair every item with every other row.
    if qryShop.Active then
      qryShop.Close;
    qryShop.SQL.Text := 'SELECT ItemID, Item_Name, BrandID, Color_Family, ' +
      '       Formality_Score, Warmth_Rating, Category, Price, ' +
      '       Quantity_Stock ' + 'FROM tblInventory ' +
      'WHERE Quantity_Stock > 0 ' + '  AND ItemID NOT IN ' +
      '      (SELECT ItemID FROM tblWardrobes WHERE UserID = :pUser)';
    qryShop.Parameters.ParamByName('pUser').Value := userID;
    qryShop.Open;
  end;

  FormatGrids;
  RefreshBalance;

  //Image6.Visible := false;
  //Image7.Visible := false;
  //Image8.Visible := false;
  //Image9.Visible := false;
  //Image10.Visible := false;
end;

// Every object must be freed, or the form leaks its wardrobe.
procedure TfrmCustomers.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ClearGarments;
end;

procedure TfrmCustomers.GoToTab(iPage: integer);
begin
  fAllowTabChange := true;
  try
    pgcUser.ActivePageIndex := iPage;
  finally
    fAllowTabChange := false;   // always restored, even on error
  end;
end;

procedure TfrmCustomers.FormatGrids;
begin
  ApplyGridFont(dbgUserWardrobe);
  SetColWidth(dbgUserWardrobe, 'WardrobeID', 90); // WD-101-02
  SetColWidth(dbgUserWardrobe, 'ItemID', 130); // BOT-BLU-URB-02
  SetColWidth(dbgUserWardrobe, 'Item_Name', 175); // Slim Tapered Jeans
  SetColWidth(dbgUserWardrobe, 'BrandID', 55); // LVS
  SetColWidth(dbgUserWardrobe, 'Category', 80); // Outerwear
  SetColWidth(dbgUserWardrobe, 'Color_Family', 70); // Orange
  SetColWidth(dbgUserWardrobe, 'Formality_Score', 105); // 10
  SetColWidth(dbgUserWardrobe, 'Warmth_Rating', 95); // 10
  SetColWidth(dbgUserWardrobe, 'Times_Worn', 80); // 25
  SetColWidth(dbgUserWardrobe, 'Is_Clean', 70); // True / False

  ApplyGridFont(dbgShop);
  SetColWidth(dbgShop, 'ItemID', 130);
  SetColWidth(dbgShop, 'Item_Name', 175);
  SetColWidth(dbgShop, 'BrandID', 55);
  SetColWidth(dbgShop, 'Category', 80);
  SetColWidth(dbgShop, 'Color_Family', 70);
  SetColWidth(dbgShop, 'Formality_Score', 105);
  SetColWidth(dbgShop, 'Warmth_Rating', 95);
  SetColWidth(dbgShop, 'Price', 85); // 35000.00
  SetColWidth(dbgShop, 'Quantity_Stock', 95); // 150
end;

procedure TfrmCustomers.pgcUserChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange := FAllowTabChange;
end;

procedure TfrmCustomers.pgcWardrobesChange(Sender: TObject);
var
  bEvent: boolean;
begin
  // The event tab is index 1; the general wardrobe is index 0.
  bEvent := (pgcWardrobes.ActivePageIndex = 1);

  btnWeather.Enabled := bEvent;
  btnChk.Enabled := bEvent;
  btnGenOutfit.Enabled := bEvent;
  btnFinalise.Enabled := bEvent;
  FormalityScore.Enabled := bEvent;
end;

procedure TfrmCustomers.SetColWidth(dbg: TDBGrid; const fieldName: string;
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

procedure TfrmCustomers.ApplyGridFont(dbg: TDBGrid);
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
