unit dispatchers_u;

// ============================================================
//  OptiCorp PAT 2026 - DISPATCHER INTERFACE
//  ----------------------------------------------------------
//  WHAT THIS FORM DOES
//  A dispatcher loads pending orders onto a vehicle, checks the
//  load against that vehicle's weight and volume capacity, then
//  calculates the delivery route and sends the vehicle out.
//
//  THE TWO ALGORITHMS
//  * Dijkstra finds the shortest path from one depot to every
//    other depot across the road network.
//  * Nearest neighbour sits on top of it and decides the ORDER
//    the depots are visited in. Dijkstra is re-run from each new
//    position, because distances measured from the hub go stale
//    the moment the vehicle leaves it.
//
//  THE DELIVERY MODEL
//  A fixed circuit: the vehicle calls at every depot. A depot
//  with orders is a DELIVERY. A depot without orders is a STOCK
//  RUN (a backhaul) where the vehicle collects 50 units of that
//  depot's brand instead of travelling the leg empty.
// ============================================================

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, dmPAT2026,
  Vcl.Buttons, clsOrders, Vcl.Imaging.pngimage;

const
  iDEPOTS    = 6;                 // depots taking part in routing
  rINF: real = 9999999999999.0;   // 'no road'. Typed, so every
                                  // comparison is real-to-real.
  iSTOCK_RUN = 50;                // units collected at a stock-run depot

type
  TGraph     = array [0 .. iDEPOTS - 1, 0 .. iDEPOTS - 1] of real;
  TDistances = array [0 .. iDEPOTS - 1] of real;
  TPrevious  = array [0 .. iDEPOTS - 1] of integer;
  TVisited   = array [0 .. iDEPOTS - 1] of boolean;

  TfrmDispatchers = class(TForm)
    pgcDispatcher: TPageControl;
    tbsDispatcher: TTabSheet;
    tbsLoadCalc: TTabSheet;
    tbsRouting: TTabSheet;
    tbsDelivery: TTabSheet;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    RichEdit1: TRichEdit;
    btnLoadCalc: TButton;
    btnRouting: TButton;
    dbgTrucks_Dispatch: TDBGrid;
    dbgOrders_Dispatch: TDBGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    lblCalcTruckVolume: TLabel;
    lblCalcTruckWeight: TLabel;
    lblMaxVolume: TLabel;
    lblMaxWeight: TLabel;
    lblTotDistance: TLabel;
    btnVerifyLoad: TButton;
    btnAdd: TButton;
    btnOptimise: TButton;
    btnMap: TButton;
    btnDispatchFleet: TButton;
    btnSelectVehicle: TButton;
    btnUndo: TButton;
    btnProceed: TButton;
    btnLogOut: TButton;
    btnCompleteDelivery: TButton;
    chkAvailable: TCheckBox;
    strgridGraph: TStringGrid;
    redRoutes: TRichEdit;
    redDelivery: TRichEdit;
    pnlMap: TPanel;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddClick(Sender: TObject);
    procedure dbgOrders_DispatchCellClick(Column: TColumn);
    procedure dbgTrucks_DispatchCellClick(Column: TColumn);
    procedure btnLoadCalcClick(Sender: TObject);
    procedure btnRoutingClick(Sender: TObject);
    procedure btnSelectVehicleClick(Sender: TObject);
    procedure btnVerifyLoadClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure btnProceedClick(Sender: TObject);
    procedure btnMapClick(Sender: TObject);
    procedure btnOptimiseClick(Sender: TObject);
    procedure btnDispatchFleetClick(Sender: TObject);
    procedure btnLogOutClick(Sender: TObject);
    procedure Image6Click(Sender: TObject);
    procedure Image7Click(Sender: TObject);
    procedure Image8Click(Sender: TObject);
    procedure pgcDispatcherChanging(Sender: TObject; var AllowChange: Boolean);
    procedure btnCompleteDeliveryClick(Sender: TObject);
  private
    { Private declarations }
    // -- interface state --------------------------------------
    bAllowTabChange: boolean;   // tabs may only be changed in code
    imgMap: TImage;             // created at runtime by btnMap

    // -- the current load -------------------------------------
    arrOrders: array of TOrder; // OWNS these objects - must be freed
    rTotalWeight: real;         // running kg on the vehicle
    rTotalVolume: real;         // running litres on the vehicle
    sVehicle: string;           // VehicleID chosen by the dispatcher
    sSelItemID: string;
    iTest: integer;         // ItemID of the grid row last clicked

    // -- the road network -------------------------------------
    arrGraph: TGraph;                                  // adjacency matrix
    arrDepot: array [0 .. iDEPOTS - 1] of string;      // WarehouseID per index
    arrDepotBrand: array [0 .. iDEPOTS - 1] of string; // BrandID per index
    arrXCoord: array [0 .. iDEPOTS - 1] of integer;
    arrYCoord: array [0 .. iDEPOTS - 1] of integer;
    iLoaded: integer;                                  // depots actually found

    // -- the finalised route ----------------------------------
    arrRouteOrder: array [0 .. iDEPOTS - 1] of integer; // depot per stop
    iRouteLen: integer;         // number of stops stored
    rRouteTotal: real;          // total distance of the route
    bMapReady: boolean;         // BuildMap has run
    bRouteReady: boolean;       // a complete route exists

    procedure LoadWarehouses;
    function IsDepot(sID: string): boolean;
    procedure AddRoad(sFrom, sTo: string);
    function IndexOf(sID: string): integer;
    procedure BuildMap;
    function Distance(iFrom, iTo: integer): real;
    function GetMinDistance(const arrDist: TDistances;
      const arrVisited: TVisited): integer;
    function Dijkstra(const arrMap: TGraph; iSource: integer;
      out arrPrev: TPrevious): TDistances;
    function PathToString(const arrPrev: TPrevious; iTarget: integer): string;
    function StopNumberOf(const sWarehouse: string): integer;
    function OrdersForDepot(const sWarehouse: string): integer;
    procedure CollectStock(const sBrandID: string; out iItems: integer);
    procedure ShowGraphGrid;
    procedure WriteManifest;
    procedure SetColWidth(dbg: TDBGrid; const sFieldName: string;
      iWidth: integer);
    procedure ApplyGridFont(dbg: TDBGrid);
    procedure GetOrderLoad(const sOrderID: string; out rWeight, rVolume: real);
    function OrderAlreadyLoaded(const sOrderID: string): boolean;
    procedure RefreshLoadLabels;
    procedure ClearLoadedOrders;
    function CityToWarehouse(sCity: string): string;
    procedure GoToTab(iPage: integer);
  public
    { Public declarations }
  end;

var
  frmDispatchers: TfrmDispatchers;

implementation

{$R *.dfm}

// ============================================================
//                       NAVIGATION
//  pgcDispatcherChanging blocks the user from clicking tabs
//  directly, so the workflow can only advance through buttons.
//  GoToTab lifts that block for exactly one switch.
// ============================================================

procedure TfrmDispatchers.GoToTab(iPage: integer);
begin
  bAllowTabChange := true;
  try
    pgcDispatcher.ActivePageIndex := iPage;
  finally
    bAllowTabChange := false;   // always restored, even on error
  end;
end;

procedure TfrmDispatchers.pgcDispatcherChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange := bAllowTabChange;
end;

procedure TfrmDispatchers.btnLoadCalcClick(Sender: TObject);
begin
  GoToTab(1);
end;

procedure TfrmDispatchers.btnRoutingClick(Sender: TObject);
begin
  GoToTab(2);
end;

// The three back-arrow images all return to the dashboard.
procedure TfrmDispatchers.Image6Click(Sender: TObject);
begin
  GoToTab(0);
end;

procedure TfrmDispatchers.Image7Click(Sender: TObject);
begin
  GoToTab(0);
end;

procedure TfrmDispatchers.Image8Click(Sender: TObject);
begin
  GoToTab(0);
end;

procedure TfrmDispatchers.btnLogOutClick(Sender: TObject);
begin
  Close;
  redRoutes.Clear;
  redDelivery.Clear;
end;

// ============================================================
//                   GRAPH CONSTRUCTION
// ============================================================

// Only these six warehouses take part in delivery routing. The
// other six are inbound stock locations with no roads, so
// excluding them stops them appearing as unreachable nodes.
function TfrmDispatchers.IsDepot(sID: string): boolean;
begin
  result := (sID = 'WH-OPT-HQ') or (sID = 'WH-URB-01') or (sID = 'WH-NFB-01')
    or (sID = 'WH-PLO-01') or (sID = 'WH-TIM-01') or (sID = 'WH-ZAR-01');
end;

// Reads the depot rows into the parallel arrays. The index a
// depot receives depends on the order Access returns rows, which
// is why every later lookup goes through IndexOf rather than
// assuming a position.
procedure TfrmDispatchers.LoadWarehouses;
begin
  iLoaded := 0;

  with dmPAT2026_1 do
  begin
    if not tblWarehouses.Active then
      tblWarehouses.Open;

    tblWarehouses.First;
    while not tblWarehouses.Eof do
    begin
      if IsDepot(tblWarehouses['WarehouseID']) and (iLoaded < iDEPOTS) then
      begin
        arrDepot[iLoaded]      := tblWarehouses['WarehouseID'];
        arrDepotBrand[iLoaded] := tblWarehouses['BrandID'];
        arrXCoord[iLoaded]     := tblWarehouses['X_Coordinates'];
        arrYCoord[iLoaded]     := tblWarehouses['Y_Coordinates'];
        inc(iLoaded);
      end;
      tblWarehouses.Next;
    end;
  end;
end;

// WarehouseID -> array index, or -1 if not found.
// Flag-controlled: the loop ends through its own condition once
// a match is found, so no Break is needed.
function TfrmDispatchers.IndexOf(sID: string): integer;
var
  i: integer;
  bFound: boolean;
begin
  result := -1;
  bFound := false;
  i := 0;

  while (i < iLoaded) and (not bFound) do
  begin
    if arrDepot[i] = sID then
    begin
      result := i;
      bFound := true;
    end
    else
      inc(i);      // only advance when there was no match
  end;
end;

// Straight-line distance from the two depots' coordinates.
// Weights are DERIVED, never stored, so changing a coordinate in
// Access automatically re-costs every road that touches it.
function TfrmDispatchers.Distance(iFrom, iTo: integer): real;
begin
  result := Sqrt(Sqr(arrXCoord[iFrom] - arrXCoord[iTo]) +
                 Sqr(arrYCoord[iFrom] - arrYCoord[iTo]));
end;

// Roads are two-way, so BOTH arrGraph[i,j] and arrGraph[j,i] are
// written. Writing only one creates a one-way road, which is
// invisible when routing from the hub but strands the vehicle
// the moment it arrives.
procedure TfrmDispatchers.AddRoad(sFrom, sTo: string);
var
  iFrom, iTo: integer;
begin
  iFrom := IndexOf(sFrom);
  iTo   := IndexOf(sTo);

  if (iFrom = -1) or (iTo = -1) then
    showmessage('Road not created: ' + sFrom + ' <-> ' + sTo +
      ' (warehouse not found).')
  else
  begin
    arrGraph[iFrom, iTo] := Distance(iFrom, iTo);
    arrGraph[iTo, iFrom] := arrGraph[iFrom, iTo];
  end;
end;

procedure TfrmDispatchers.BuildMap;
var
  i, j: integer;
begin
  // Every pair starts with NO road. rINF is the sentinel, never
  // 0, because 0 is a legitimate weight - the distance from a
  // node to itself.
  for i := 0 to iDEPOTS - 1 do
    for j := 0 to iDEPOTS - 1 do
      if i = j then
        arrGraph[i, j] := 0
      else
        arrGraph[i, j] := rINF;

  // Seven roads, modelled on the real national routes. WHICH
  // pairs are joined is a design decision: a fully connected
  // graph would make Dijkstra pointless, because a direct edge
  // is always shorter than any path through a third node.
  AddRoad('WH-OPT-HQ', 'WH-URB-01');   // N1  Hub       <-> Bloemfontein   168
  AddRoad('WH-OPT-HQ', 'WH-NFB-01');   // N4  Hub       <-> Nelspruit      189
  AddRoad('WH-OPT-HQ', 'WH-ZAR-01');   // N1  Hub       <-> Cape Town      495
  AddRoad('WH-NFB-01', 'WH-URB-01');   //     Nelspruit <-> Bloemfontein   334
  AddRoad('WH-NFB-01', 'WH-PLO-01');   //     Nelspruit <-> Durban         306
  AddRoad('WH-PLO-01', 'WH-URB-01');   // N3  Durban    <-> Bloemfontein   273
  AddRoad('WH-URB-01', 'WH-TIM-01');   // N9  Bloem     <-> Port Elizabeth 245

  // Optional N2 coastal link. Enabling it cuts the best circuit
  // from 1920 to 1247 units.
  // AddRoad('WH-TIM-01', 'WH-ZAR-01'); // N2 Port Eliz <-> Cape Town      234

  bMapReady := true;
end;

// ============================================================
//                        DIJKSTRA
// ============================================================

// SELECT step: of the depots not yet finalised, which is closest?
// '<' not '<=' - with '<=' an unreachable depot sitting at rINF
// would still be chosen, and -1 could never be returned.
function TfrmDispatchers.GetMinDistance(const arrDist: TDistances;
  const arrVisited: TVisited): integer;
var
  rMin: real;
  iMinIndex, i: integer;
begin
  rMin := rINF;
  iMinIndex := -1;

  for i := 0 to iDEPOTS - 1 do
    if (not arrVisited[i]) and (arrDist[i] < rMin) then
    begin
      rMin := arrDist[i];
      iMinIndex := i;
    end;

  result := iMinIndex;
end;

// Shortest path from iSource to every depot.
//   arrDist    - best distance known so far
//   arrVisited - depots whose distance is final
//   arrPrev    - who improved each depot, so the PATH can be
//                rebuilt afterwards. Distance alone cannot do it.
function TfrmDispatchers.Dijkstra(const arrMap: TGraph; iSource: integer;
  out arrPrev: TPrevious): TDistances;
var
  arrVisited: TVisited;
  arrDist: TDistances;
  i, iCount, u, v: integer;
  bMore: boolean;
begin
  // Everything starts infinitely far away. Starting at 0 would
  // mean no real route could ever beat it.
  for i := 0 to iDEPOTS - 1 do
  begin
    arrDist[i]    := rINF;
    arrVisited[i] := false;
    arrPrev[i]    := -1;
  end;

  arrDist[iSource] := 0;
  iCount := 0;
  bMore  := true;

  // One pass finalises one depot. bMore ends the loop through
  // its own condition when nothing reachable is left.
  while (iCount <= iDEPOTS - 2) and bMore do
  begin
    u := GetMinDistance(arrDist, arrVisited);

    if u = -1 then
      bMore := false                    // everything left is unreachable
    else
    begin
      arrVisited[u] := true;            // u's distance is now final

      // RELAX: is reaching v THROUGH u cheaper than v's best?
      for v := 0 to iDEPOTS - 1 do
        if (not arrVisited[v]) and (arrMap[u, v] < rINF) and
           (arrDist[u] < rINF) and
           (arrDist[u] + arrMap[u, v] < arrDist[v]) then
        begin
          arrDist[v] := arrDist[u] + arrMap[u, v];
          arrPrev[v] := u;              // record who improved it
        end;
    end;

    inc(iCount);
  end;

  result := arrDist;
end;

// Walks arrPrev backwards to turn a distance into a readable
// path such as 'WH-OPT-HQ -> WH-URB-01 -> WH-TIM-01'.
function TfrmDispatchers.PathToString(const arrPrev: TPrevious;
  iTarget: integer): string;
var
  j: integer;
begin
  result := arrDepot[iTarget];
  j := iTarget;

  while arrPrev[j] <> -1 do
  begin
    j := arrPrev[j];
    result := arrDepot[j] + ' -> ' + result;
  end;
end;

// Which stop number is this depot on the finalised route?
// 0 means it is not on the route at all.
function TfrmDispatchers.StopNumberOf(const sWarehouse: string): integer;
var
  k: integer;
  bFound: boolean;
begin
  result := 0;
  bFound := false;
  k := 0;

  while (k < iRouteLen) and (not bFound) do
  begin
    if arrDepot[arrRouteOrder[k]] = sWarehouse then
    begin
      result := k + 1;      // stops are numbered from 1
      bFound := true;
    end
    else
      inc(k);
  end;
end;

// How many loaded orders are bound for this depot?
// Zero means the call there is a stock run, not a delivery.
function TfrmDispatchers.OrdersForDepot(const sWarehouse: string): integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to High(arrOrders) do
    if arrOrders[i].getWarehouse = sWarehouse then
      inc(result);
end;

// ============================================================
//                       STOCK RUN
//  A depot with no deliveries is not a wasted leg: the vehicle
//  collects 50 units of every item belonging to that depot's
//  brand, so it never travels back empty.
// ============================================================
procedure TfrmDispatchers.CollectStock(const sBrandID: string;
  out iItems: integer);
begin
  iItems := 0;

  with dmPAT2026_1 do
  begin
    // Count the item lines first, purely for the report
    if qryMain.Active then
      qryMain.Close;
    qryMain.SQL.Text :=
      'SELECT ItemID FROM tblInventory WHERE BrandID = :pBrand';
    qryMain.Parameters.ParamByName('pBrand').Value := sBrandID;
    qryMain.Open;
    iItems := qryMain.RecordCount;
    qryMain.Close;

    // One set-based UPDATE: the arithmetic happens INSIDE the
    // database, so no stale value read into Delphi can be
    // written back over another change.
    qryMain.SQL.Text :=
      'UPDATE tblInventory SET Quantity_Stock = Quantity_Stock + :pQty ' +
      'WHERE BrandID = :pBrand';
    qryMain.Parameters.ParamByName('pQty').Value   := iSTOCK_RUN;
    qryMain.Parameters.ParamByName('pBrand').Value := sBrandID;
    qryMain.ExecSQL;
  end;
end;

// ============================================================
//                  CALCULATE THE ROUTE
//  Nearest neighbour built on Dijkstra. Dijkstra is re-run from
//  each new position, because 'how far is Cape Town' has a
//  different answer once the vehicle has left the hub.
// ============================================================

procedure TfrmDispatchers.btnOptimiseClick(Sender: TObject);
var
  arrDist: TDistances;
  arrPrev: TPrevious;
  arrVisited: TVisited;
  iCurrent, iBest, i, k, iOrders: integer;
  rMin: real;
  bMore: boolean;
begin
  if not bMapReady then
    showmessage('Please press Proceed first to build the delivery map.')
  else
  begin
    iCurrent := IndexOf('WH-OPT-HQ');

    if iCurrent = -1 then
      showmessage('The national hub could not be found in tblWarehouses.')
    else
    begin
      redRoutes.Clear;
      redRoutes.Lines.Add('=================================================');
      redRoutes.Lines.Add('     OPTICORP DELIVERY ROUTE CALCULATION');
      redRoutes.Lines.Add('=================================================');
      redRoutes.Lines.Add('Vehicle    : ' + sVehicle);
      redRoutes.Lines.Add('Origin     : ' + arrDepot[iCurrent] + '  (' +
        inttostr(arrXCoord[iCurrent]) + ', ' +
        inttostr(arrYCoord[iCurrent]) + ')');
      redRoutes.Lines.Add('Algorithm  : Dijkstra + nearest neighbour');
      redRoutes.Lines.Add('-------------------------------------------------');
      redRoutes.Lines.Add('');

      for i := 0 to iDEPOTS - 1 do
        arrVisited[i] := false;
      arrVisited[iCurrent] := true;   // the hub is the origin, not a stop

      rRouteTotal := 0;
      iRouteLen   := 0;
      bMore       := true;
      i           := 1;

      // One pass per remaining depot.
      while (i <= iDEPOTS - 1) and bMore do
      begin
        // Distances FROM WHERE THE VEHICLE IS NOW - this is the
        // whole reason Dijkstra runs inside the loop.
        arrDist := Dijkstra(arrGraph, iCurrent, arrPrev);

        // Scan only the depots, and only the unvisited ones.
        rMin  := rINF;
        iBest := -1;
        for k := 0 to iDEPOTS - 1 do
          if (not arrVisited[k]) and (arrDist[k] < rMin) then
          begin
            rMin  := arrDist[k];
            iBest := k;
          end;

        if iBest = -1 then
        begin
          redRoutes.Lines.Add('*** Remaining depots are unreachable ***');
          bMore := false;
        end
        else
        begin
          rRouteTotal := rRouteTotal + rMin;
          arrRouteOrder[iRouteLen] := iBest;   // store the finalised route
          inc(iRouteLen);

          iOrders := OrdersForDepot(arrDepot[iBest]);

          redRoutes.Lines.Add('STOP ' + inttostr(iRouteLen) + ': ' +
            arrDepot[iBest]);
          redRoutes.Lines.Add('   Route     : ' +
            PathToString(arrPrev, iBest));
          redRoutes.Lines.Add('   Leg       : ' +
            floattostrf(rMin, fffixed, 10, 1) + ' km');
          redRoutes.Lines.Add('   Running   : ' +
            floattostrf(rRouteTotal, fffixed, 10, 1) + ' km');

          if iOrders > 0 then
            redRoutes.Lines.Add('   Purpose   : DELIVERY (' +
              inttostr(iOrders) + ' order(s))')
          else
            redRoutes.Lines.Add('   Purpose   : STOCK RUN - collect ' +
              inttostr(iSTOCK_RUN) + ' units of ' + arrDepotBrand[iBest]);

          redRoutes.Lines.Add('');

          arrVisited[iBest] := true;
          iCurrent := iBest;   // the vehicle has MOVED. Without this
                               // line the next pass would measure
                               // from the hub all over again.
          inc(i);
        end;
      end;

      redRoutes.Lines.Add('-------------------------------------------------');
      redRoutes.Lines.Add('TOTAL ROUTE DISTANCE : ' +
        floattostrf(rRouteTotal, fffixed, 10, 1) + ' km');
      redRoutes.Lines.Add('STOPS                : ' + inttostr(iRouteLen));
      redRoutes.Lines.Add('=================================================');
      redRoutes.Lines.Add('Nearest neighbour is a heuristic: it gives an');
      redRoutes.Lines.Add('efficient route, not a guaranteed optimum.');

      lblTotDistance.Caption := 'Total: ' +
        floattostrf(rRouteTotal, fffixed, 10, 1) + ' km';

      // Only a route covering every depot may be dispatched.
      bRouteReady := (iRouteLen = iDEPOTS - 1);
    end;
  end;
end;

// ============================================================
//                    CONFIRM DISPATCH
//  Nothing is written to the database until the dispatcher
//  confirms here, so the route may be recalculated freely
//  without side effects.
// ============================================================

procedure TfrmDispatchers.btnDispatchFleetClick(Sender: TObject);
var
  i, k, iSeq, iUpdated, iSkipped, iStockStops, iItems: integer;
  sWarehouse: string;
  bCanDispatch: boolean;
begin
  bCanDispatch := true;

  if sVehicle = '' then
  begin
    showmessage('Please select a vehicle first.');
    bCanDispatch := false;
  end
  else if Length(arrOrders) = 0 then
  begin
    showmessage('There are no orders loaded on this vehicle.');
    bCanDispatch := false;
  end
  else if not bRouteReady then
  begin
    showmessage('Please calculate the delivery route before dispatching.');
    bCanDispatch := false;
  end
  else if MessageDlg('Dispatch ' + sVehicle + ' with ' +
    inttostr(Length(arrOrders)) + ' order(s)?' + #13#10 +
    'Orders will be marked On Route and stock runs will be recorded.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    bCanDispatch := false;

  if bCanDispatch then
  begin
    iUpdated    := 0;
    iSkipped    := 0;
    iStockStops := 0;

    with dmPAT2026_1 do
    try
      // ---- 1. stamp every loaded order --------------------
      for i := 0 to High(arrOrders) do
      begin
        sWarehouse := arrOrders[i].getWarehouse;
        iSeq := StopNumberOf(sWarehouse);

        // if/else rather than Continue, so the loop keeps a
        // single exit point
        if iSeq = 0 then
          inc(iSkipped)
        else
        begin
          if qryMain.Active then
            qryMain.Close;

          // Parameterised: an apostrophe in any value cannot
          // break the statement, and injection is impossible
          qryMain.SQL.Text :=
            'UPDATE tblOrders SET VehicleID = :pVehicle, ' +
            'Delivery_Sequence = :pSeq, Status = :pStatus ' +
            'WHERE OrderID = :pID';
          qryMain.Parameters.ParamByName('pVehicle').Value := sVehicle;
          qryMain.Parameters.ParamByName('pSeq').Value     := iSeq;
          qryMain.Parameters.ParamByName('pStatus').Value  := 'On Route';
          qryMain.Parameters.ParamByName('pID').Value :=
            arrOrders[i].getOrderID;
          qryMain.ExecSQL;

          arrOrders[i].setStatus('On Route');  // keep the object in step
          inc(iUpdated);
        end;
      end;

      // ---- 2. stock runs at depots with no deliveries ------
      for k := 0 to iRouteLen - 1 do
        if OrdersForDepot(arrDepot[arrRouteOrder[k]]) = 0 then
        begin
          CollectStock(arrDepotBrand[arrRouteOrder[k]], iItems);
          inc(iStockStops);
          redRoutes.Lines.Add('STOCK RUN: ' + arrDepot[arrRouteOrder[k]] +
            ' - ' + inttostr(iItems) + ' item line(s) of ' +
            arrDepotBrand[arrRouteOrder[k]] + ' increased by ' +
            inttostr(iSTOCK_RUN) + '.');
        end;

      // ---- 3. take the vehicle off the available fleet -----
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text :=
        'UPDATE tblTrucks SET Status = :pStatus WHERE VehicleID = :pVehicle';
      qryMain.Parameters.ParamByName('pStatus').Value  := 'On Route';
      qryMain.Parameters.ParamByName('pVehicle').Value := sVehicle;
      qryMain.ExecSQL;

      WriteManifest;

      // ---- 4. re-read, or the grids show stale data --------
      tblOrders.Close;    tblOrders.Open;
      tblTrucks.Close;    tblTrucks.Open;
      tblInventory.Close; tblInventory.Open;

      if iSkipped > 0 then
        showmessage(inttostr(iSkipped) + ' order(s) had a destination that ' +
          'is not on the route and were not dispatched.');

      showmessage(inttostr(iUpdated) + ' order(s) dispatched on ' + sVehicle +
        '.' + #13#10 + inttostr(iStockStops) + ' stock run(s) recorded.' +
        #13#10 + 'Manifest written.');

      // ---- 5. reset the form for the next dispatch ---------
      ClearLoadedOrders;
      rTotalWeight := 0;
      rTotalVolume := 0;
      //sVehicle     := '';
      bRouteReady  := false;
      Panel4.Caption := '';
      Panel4.Color   := clBtnFace;
      btnProceed.Visible := false;
      RefreshLoadLabels;

      // Only advance once the dispatch has actually succeeded
      GoToTab(3);
    except
      on E: Exception do
        showmessage('The dispatch could not be completed.' + #13#10 +
          'Database error: ' + E.Message);
    end;
  end;
end;

// ============================================================
//                       MANIFEST.TXT
//  One file per dispatch, named after the vehicle and the time,
//  so separate runs are never overwritten.
// ============================================================
procedure TfrmDispatchers.WriteManifest;
var
  tfManifest: TextFile;
  sPath: string;
  k, i, iOrders: integer;
begin
  sPath := ExtractFilePath(Application.ExeName) + 'Manifest_' + sVehicle +
    '_' + FormatDateTime('yyyymmdd_hhnn', Now) + '.txt';

  AssignFile(tfManifest, sPath);
  try
    Rewrite(tfManifest);
    WriteLn(tfManifest, '=================================================');
    WriteLn(tfManifest, '      OPTICORP OFFICIAL DISPATCH MANIFEST');
    WriteLn(tfManifest, '=================================================');
    WriteLn(tfManifest, 'Vehicle    : ' + sVehicle);
    WriteLn(tfManifest, 'Date       : ' +
      FormatDateTime('yyyy/mm/dd hh:nn', Now));
    WriteLn(tfManifest, 'Origin     : WH-OPT-HQ (National Hub)');
    WriteLn(tfManifest, 'Total load : ' +
      floattostrf(rTotalWeight, fffixed, 10, 2) + ' kg / ' +
      floattostrf(rTotalVolume, fffixed, 10, 2) + ' l');
    WriteLn(tfManifest, 'Distance   : ' +
      floattostrf(rRouteTotal, fffixed, 10, 1) + ' km');
    WriteLn(tfManifest, '-------------------------------------------------');

    for k := 0 to iRouteLen - 1 do
    begin
      iOrders := OrdersForDepot(arrDepot[arrRouteOrder[k]]);

      WriteLn(tfManifest, '');
      WriteLn(tfManifest, 'STOP ' + inttostr(k + 1) + ': ' +
        arrDepot[arrRouteOrder[k]]);

      if iOrders = 0 then
      begin
        WriteLn(tfManifest,
          '   *** STOCK RUN - no deliveries at this depot ***');
        WriteLn(tfManifest, '   Collect ' + inttostr(iSTOCK_RUN) +
          ' units of brand ' + arrDepotBrand[arrRouteOrder[k]]);
      end
      else
        for i := 0 to High(arrOrders) do
          if arrOrders[i].getWarehouse = arrDepot[arrRouteOrder[k]] then
            WriteLn(tfManifest, '   ' + arrOrders[i].getOrderID + '  x' +
              inttostr(arrOrders[i].getQuantity) + '  ' +
              arrOrders[i].getItemName + '  (' + arrOrders[i].getCity + ')');
    end;

    WriteLn(tfManifest, '');
    WriteLn(tfManifest, '-------------------------------------------------');
    WriteLn(tfManifest, 'Orders on board : ' + inttostr(Length(arrOrders)));
    WriteLn(tfManifest, '=================================================');
  finally
    CloseFile(tfManifest);   // always closes, even if writing fails
  end;
end;

// ============================================================
//                    LOAD CALCULATOR
// ============================================================

// Weight and Volume live in tblInventory, not on the order, so
// they are looked up here from the passed-in OrderID rather than
// from wherever the grid cursor happens to be sitting.
procedure TfrmDispatchers.GetOrderLoad(const sOrderID: string;
  out rWeight, rVolume: real);
var
  iQty: integer;
begin
  rWeight := 0;
  rVolume := 0;

  with dmPAT2026_1 do
    if tblOrders.Locate('OrderID', sOrderID, []) then
    begin
      iQty := tblOrders['Quantity'];

      if tblInventory.Locate('ItemID', tblOrders['ItemID'], []) then
      begin
        rWeight := tblInventory['Weight'] * iQty;
        rVolume := tblInventory['Volume'] * iQty;
      end;
    end;
end;

// The result itself acts as the flag, so the loop stops as soon
// as a match is found without needing Exit.
function TfrmDispatchers.OrderAlreadyLoaded(const sOrderID: string): boolean;
var
  i: integer;
begin
  result := false;
  i := 0;

  while (i <= High(arrOrders)) and (not result) do
  begin
    if arrOrders[i].getOrderID = sOrderID then
      result := true
    else
      inc(i);
  end;
end;

// The bridge between a customer and the map: customers have a
// city, the map has coordinates. Every city maps to the depot
// that serves it. The final else guarantees a valid depot is
// always returned - an empty string here would break IndexOf.
function TfrmDispatchers.CityToWarehouse(sCity: string): string;
begin
  if sCity = 'Pretoria' then
    result := 'WH-OPT-HQ'
  else if sCity = 'Johannesburg' then
    result := 'WH-OPT-HQ'
  else if sCity = 'Durban' then
    result := 'WH-PLO-01'
  else if sCity = 'Nelspruit' then
    result := 'WH-NFB-01'
  else if sCity = 'Cape Town' then
    result := 'WH-ZAR-01'
  else if sCity = 'Port Elizabeth' then
    result := 'WH-TIM-01'
  else if sCity = 'Bloemfontein' then
    result := 'WH-URB-01'
  else
    result := 'WH-OPT-HQ';
end;

// arrOrders holds REFERENCES to objects on the heap. Dropping
// the references alone would leak the objects, so each is freed
// first and only then is the array emptied.
procedure TfrmDispatchers.ClearLoadedOrders;
var
  i: integer;
begin
  for i := 0 to High(arrOrders) do
    arrOrders[i].Free;
  SetLength(arrOrders, 0);
end;

procedure TfrmDispatchers.RefreshLoadLabels;
begin
  lblCalcTruckWeight.Caption := 'Calculated Truck Weight: ' +
    floattostrf(rTotalWeight, fffixed, 10, 2) + ' kg';
  lblCalcTruckVolume.Caption := 'Calculated Truck Volume: ' +
    floattostrf(rTotalVolume, fffixed, 10, 2) + ' l';
end;

procedure TfrmDispatchers.btnAddClick(Sender: TObject);
var
  objNewOrder: TOrder;
  sOrderID, sItemName: string;
  rW, rV: real;
  bCanAdd: boolean;
begin
  sOrderID := dmPAT2026_1.tblOrders['OrderID'];
  bCanAdd  := true;

  // -- guard 1: only pending orders may be loaded -----------
  with dmPAT2026_1 do
    if tblOrders['Status'] <> 'Pending' then
    begin
      if tblOrders['Status'] = 'On Route' then
        showmessage('This Order cannot be added to the vehicle because it ' +
          'is already out for delivery.')
      else
        showmessage('This Order cannot be added to the vehicle because it ' +
          'has already been delivered.');
      bCanAdd := false;
    end;

  // -- guard 2: the same order may not be loaded twice ------
  if bCanAdd and OrderAlreadyLoaded(sOrderID) then
  begin
    showmessage('Order ' + sOrderID +
      ' has already been added to this vehicle.');
    bCanAdd := false;
  end;

  if bCanAdd then
  begin
    sItemName := '';
    with dmPAT2026_1 do
      if tblInventory.Locate('ItemID', tblOrders['ItemID'], []) then
        sItemName := tblInventory['Item_Name'];

    with dmPAT2026_1 do
      objNewOrder := TOrder.Create(tblOrders['OrderID'], tblOrders['UserID'],
        tblOrders['ItemID'], sItemName, VarToStr(tblOrders['Order_Date']),
        tblOrders['Quantity'], tblOrders['Status']);

    // Grow the array FIRST, then write into the new last slot.
    // Writing before growing would be out of bounds.
    SetLength(arrOrders, Length(arrOrders) + 1);
    arrOrders[High(arrOrders)] := objNewOrder;

    GetOrderLoad(sOrderID, rW, rV);
    rTotalWeight := rTotalWeight + rW;
    rTotalVolume := rTotalVolume + rV;

    bRouteReady := false;   // the load changed, so any route is stale
    RefreshLoadLabels;
  end;
end;

procedure TfrmDispatchers.btnCompleteDeliveryClick(Sender: TObject);
const
  iLINE_DELAY = 500;      // milliseconds between manifest lines
  iSTOP_PAUSE = 1500;      // longer pause when a STOP line appears
var
  tfManifest: TextFile;
  sLine, sManifestPath: string;
  iDelivered, iDelay: integer;
  bCanComplete: boolean;
begin
  sManifestPath := ExtractFilePath(Application.ExeName) + 'Manifest_' + sVehicle +
    '_' + FormatDateTime('yyyymmdd_hhnn', Now) + '.txt';
  bCanComplete := true;

  // -- guard 1: has anything actually been dispatched? ------
  if sVehicle = '' then
  begin
    showmessage('No vehicle is currently out on delivery.');
    bCanComplete := false;
  end
  // -- guard 2: the manifest must still exist ---------------
  else if not FileExists(sManifestPath) then
  begin
    showmessage('The manifest for this run could not be found:' + #13#10 +
      sManifestPath);
    bCanComplete := false;
  end
  else if MessageDlg('Begin the delivery run for ' + sVehicle +
    '?' + #13#10 + 'The manifest will be read out stop by stop.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    bCanComplete := false;

  if bCanComplete then
  begin
    // ======================================================
    //  1. REPLAY THE MANIFEST
    // ======================================================
    redDelivery.Clear;
    btnCompleteDelivery.Enabled := false;   // stop a second click
    Screen.Cursor := crHourGlass;           // mid-run

    AssignFile(tfManifest, sManifestPath);
    try
      Reset(tfManifest);

      while not Eof(tfManifest) do
      begin
        ReadLn(tfManifest, sLine);
        redDelivery.Lines.Add(sLine);

        // Keep the newest line in view as the box fills up
        redDelivery.SelStart := Length(redDelivery.Text);
        redDelivery.Perform(EM_SCROLLCARET, 0, 0);

        // A stop line is the interesting one, so it lingers
        if Pos('STOP', sLine) = 1 then
          iDelay := iSTOP_PAUSE
        else
          iDelay := iLINE_DELAY;

        // ProcessMessages BEFORE the sleep, so the line is
        // painted first and the pause is seen after it
        Application.ProcessMessages;
        Sleep(iDelay);
      end;
    finally
      CloseFile(tfManifest);                // always closes
      Screen.Cursor := crDefault;
      btnCompleteDelivery.Enabled := true;
    end;

    redDelivery.Lines.Add('');
    redDelivery.Lines.Add('*** ALL STOPS COMPLETED ***');
    Application.ProcessMessages;
    Sleep(600);

    // ======================================================
    //  2. WRITE THE RESULT BACK TO THE DATABASE
    // ======================================================
    iDelivered := 0;

    with dmPAT2026_1 do
    try
      // -- how many orders are about to change? -------------
      if qryMain.Active then
        qryMain.Close;
      qryMain.SQL.Text :=
        'SELECT OrderID FROM tblOrders ' +
        'WHERE VehicleID = :pVehicle AND Status = :pStatus';
      qryMain.Parameters.ParamByName('pVehicle').Value := sVehicle;
      qryMain.Parameters.ParamByName('pStatus').Value  := 'On Route';
      qryMain.Open;
      iDelivered := qryMain.RecordCount;
      qryMain.Close;

      // -- every On Route order on this vehicle is delivered --
      //  One set-based UPDATE rather than a loop: the database
      //  changes them all in a single statement.
      qryMain.SQL.Text :=
        'UPDATE tblOrders SET Status = :pNew ' +
        'WHERE VehicleID = :pVehicle AND Status = :pOld';
      qryMain.Parameters.ParamByName('pNew').Value     := 'Delivered';
      qryMain.Parameters.ParamByName('pVehicle').Value := sVehicle;
      qryMain.Parameters.ParamByName('pOld').Value     := 'On Route';
      qryMain.ExecSQL;

      // -- the vehicle rejoins the available fleet ----------
      qryMain.SQL.Text :=
        'UPDATE tblTrucks SET Status = :pStatus WHERE VehicleID = :pVehicle';
      qryMain.Parameters.ParamByName('pStatus').Value  := 'Available';
      qryMain.Parameters.ParamByName('pVehicle').Value := sVehicle;
      qryMain.ExecSQL;

      // -- re-read, or the grids keep showing On Route ------
      tblOrders.Close;  tblOrders.Open;
      tblTrucks.Close;  tblTrucks.Open;

      redDelivery.Lines.Add('');
      redDelivery.Lines.Add('-------------------------------------------------');
      redDelivery.Lines.Add('Orders delivered : ' + inttostr(iDelivered));
      redDelivery.Lines.Add('Vehicle ' + sVehicle +
        ' is back at the hub and Available.');
      redDelivery.Lines.Add('=================================================');

      showmessage('Delivery run complete.' + #13#10 +
        inttostr(iDelivered) + ' order(s) marked as Delivered.' + #13#10 +
        sVehicle + ' is now Available.');

      // -- the run is over, so clear its record -------------
      sVehicle := '';
      sManifestPath    := '';
    except
      on E: Exception do
        showmessage('The delivery could not be completed.' + #13#10 +
          'Database error: ' + E.Message);
    end;
  end;

end;

// Removes the LAST order added - a stack pop. Working from the
// stored list rather than the grid means the correct order is
// removed even if the dispatcher has clicked elsewhere since.
procedure TfrmDispatchers.btnUndoClick(Sender: TObject);
var
  objLastOrder: TOrder;
  sLastID: string;
  rW, rV: real;
begin
  if Length(arrOrders) = 0 then
    showmessage('There are no orders to remove.')
  else
  begin
    objLastOrder := arrOrders[High(arrOrders)];
    sLastID := objLastOrder.getOrderID;

    GetOrderLoad(sLastID, rW, rV);
    rTotalWeight := rTotalWeight - rW;
    rTotalVolume := rTotalVolume - rV;

    // Guard against floating-point drift leaving a tiny negative
    if rTotalWeight < 0 then
      rTotalWeight := 0;
    if rTotalVolume < 0 then
      rTotalVolume := 0;

    // (1) destroy the heap object, THEN (2) drop the slot.
    // Shrinking first would lose the only reference to it.
    objLastOrder.Free;
    SetLength(arrOrders, Length(arrOrders) - 1);

    bRouteReady := false;
    RefreshLoadLabels;
    showmessage('Removed order ' + sLastID + ' from the load.');
  end;
end;

procedure TfrmDispatchers.btnSelectVehicleClick(Sender: TObject);
begin
  with dmPAT2026_1 do
    if tblTrucks['Status'] = 'Available' then
    begin
      sVehicle := tblTrucks['VehicleID'];
      showmessage('Vehicle ' + sVehicle + ' selected.');
    end
    else
      showmessage('This vehicle isn''t available');
end;

// Capacity check: the accumulated load must fit inside BOTH the
// weight and the volume limit of the chosen vehicle.
procedure TfrmDispatchers.btnVerifyLoadClick(Sender: TObject);
var
  rMaxWeight, rMaxVolume: real;
  bCanCheck: boolean;
begin
  bCanCheck := true;

  if sVehicle = '' then
  begin
    showmessage('Please select a vehicle!');
    bCanCheck := false;
  end
  else if (rTotalWeight = 0) and (rTotalVolume = 0) then
  begin
    showmessage('Vehicles cannot be empty! Please select orders to go out ' +
      'on delivery.');
    bCanCheck := false;
  end;

  if bCanCheck then
    with dmPAT2026_1 do
      if not tblTrucks.Locate('VehicleID', sVehicle, []) then
        showmessage('Selected vehicle could not be found.')
      else
      begin
        rMaxWeight := tblTrucks['Max_Weight'];
        rMaxVolume := tblTrucks['Max_Volume'];

        // '<=' so a vehicle may be filled exactly to capacity
        if (rTotalWeight <= rMaxWeight) and (rTotalVolume <= rMaxVolume) then
        begin
          showmessage('The order(s) are being processed. Details will be ' +
            'confirmed as soon as possible.');
          Panel4.Caption := 'Successful';
          Panel4.Color := clGreen;
          btnProceed.Visible := true;
        end
        else
        begin
          showmessage('Load error encountered: the load exceeds the ' +
            'vehicle''s capacity. Please remove orders and try again.');
          Panel4.Caption := 'Unsuccessful';
          Panel4.Color := clRed;
          btnProceed.Visible := false;
        end;
      end;
end;

// ============================================================
//        PROCEED - resolve destinations and build the map
// ============================================================
procedure TfrmDispatchers.btnProceedClick(Sender: TObject);
var
  iRow: integer;
  sCity, sWarehouse: string;
begin
  if Length(arrOrders) = 0 then
    showmessage('There are no orders loaded.')
  else
  begin
    // Chain: order -> customer -> city -> destination depot
    for iRow := 0 to High(arrOrders) do
    begin
      sCity := '';        // reset each pass, so a failed Locate
                          // cannot reuse the previous order's city
      if dmPAT2026_1.tblUsers.Locate('UserID',
        arrOrders[iRow].getRecipient, []) then
        sCity := dmPAT2026_1.tblUsers.FieldByName('City').AsString;

      sWarehouse := CityToWarehouse(sCity);

      arrOrders[iRow].setCity(sCity);
      arrOrders[iRow].setWarehouse(sWarehouse);
    end;

    LoadWarehouses;   // MUST run before BuildMap: AddRoad resolves
    BuildMap;         // IDs to indices, which LoadWarehouses assigns

    if iLoaded < iDEPOTS then
      showmessage('Warning: only ' + inttostr(iLoaded) + ' of ' +
        inttostr(iDEPOTS) + ' depots were found in tblWarehouses.');

    ShowGraphGrid;
    bRouteReady := false;
    GoToTab(2);
  end;
end;

// Displays the adjacency matrix. The matrix should be SYMMETRIC:
// if cell [2,4] and cell [4,2] ever differ, a road was written
// in one direction only.
procedure TfrmDispatchers.ShowGraphGrid;
var
  i, j: integer;
begin
  // One extra row and column for the headers
  strgridGraph.ColCount  := iDEPOTS + 1;
  strgridGraph.RowCount  := iDEPOTS + 1;
  strgridGraph.FixedCols := 1;
  strgridGraph.FixedRows := 1;
  strgridGraph.Cells[0, 0] := 'FROM \ TO';

  for i := 0 to iDEPOTS - 1 do
  begin
    strgridGraph.Cells[i + 1, 0] := arrDepot[i];   // across the top
    strgridGraph.Cells[0, i + 1] := arrDepot[i];   // down the side
  end;

  // arrGraph[i,j] belongs in cell [j+1, i+1] because of the
  // header offset
  for i := 0 to iDEPOTS - 1 do
    for j := 0 to iDEPOTS - 1 do
      if i = j then
        strgridGraph.Cells[j + 1, i + 1] := '0'
      else if arrGraph[i, j] >= rINF then
        strgridGraph.Cells[j + 1, i + 1] := '-'   // a dash reads better
      else                                        // than 9999999999999
        strgridGraph.Cells[j + 1, i + 1] :=
          floattostrf(arrGraph[i, j], fffixed, 10, 1);

  strgridGraph.ColWidths[0] := 95;
  for i := 1 to iDEPOTS do
    strgridGraph.ColWidths[i] := 80;
  strgridGraph.Font.Name := 'JetBrains Mono';
  strgridGraph.Font.Size := 9;
end;

// ============================================================
//                     GRIDS AND IMAGES
// ============================================================

procedure TfrmDispatchers.btnMapClick(Sender: TObject);
var
  sPath: string;
begin
  if iTest = 2 then
    iTest := 0;

  inc(iTest);

  case iTest of
    1: pnlMap.Visible := True;
    2: pnlMap.Visible := False;
  end;

  // A toggle: if the map already exists, clicking removes it.
  if assigned(imgMap) then
    freeandnil(imgMap)
  else
  begin
    sPath := ExtractFilePath(Application.ExeName) + 'Map.jpg';
                        //"E:\Jesse Abache PAT 2026\delphi\Win32\Debug\Map.jpg"
    if not FileExists(sPath) then
      showmessage('Map.jpg was not found in.')
    else
    begin
      imgMap := TImage.Create(pnlMap);
      imgMap.Parent       := pnlMap;
      imgMap.Height       := 376;
      imgMap.Left         := 3;
      imgMap.Top          := 48;
      imgMap.Width        := 510;
      imgMap.Stretch      := true;
      //imgMap.Proportional := true;   // keeps the aspect ratio
      imgMap.Picture.LoadFromFile(sPath);
      imgMap.BringToFront;
      imgMap.Align := alClient;
    end;
  end;
end;

procedure TfrmDispatchers.dbgOrders_DispatchCellClick(Column: TColumn);
begin
  with dmPAT2026_1 do
    sSelItemID := tblOrders['ItemID'];
end;

procedure TfrmDispatchers.dbgTrucks_DispatchCellClick(Column: TColumn);
begin
  with dmPAT2026_1 do
  begin
    lblMaxWeight.Caption := 'Truck Max Weight: ' +
      floattostrf(tblTrucks['Max_Weight'], fffixed, 10, 2) + ' kg';
    lblMaxVolume.Caption := 'Truck Max Volume: ' +
      floattostrf(tblTrucks['Max_Volume'], fffixed, 10, 2) + ' l';
    chkAvailable.Checked := (tblTrucks['Status'] = 'Available');
  end;
end;

procedure TfrmDispatchers.SetColWidth(dbg: TDBGrid; const sFieldName: string;
  iWidth: integer);
var
  i, iCheck: integer;
begin
  i := -1;
  iCheck := 0;

  // iCheck ends the loop once the column is found - no Break
  while (i < dbg.Columns.Count - 1) and (iCheck = 0) do
  begin
    inc(i);
    if SameText(dbg.Columns[i].FieldName, sFieldName) then
    begin
      dbg.Columns[i].Width := iWidth;
      iCheck := 1;
    end;
  end;
end;

// The dataset must be OPEN before this runs, or Columns.Count is
// 0 and the loop does nothing.
procedure TfrmDispatchers.ApplyGridFont(dbg: TDBGrid);
var
  i: integer;
begin
  dbg.Font.Name  := 'JetBrains Mono';
  dbg.Font.Style := [fsItalic];
  dbg.Font.Size  := 9;

  for i := 0 to dbg.Columns.Count - 1 do
  begin
    dbg.Columns[i].Font.Name  := 'JetBrains Mono';
    dbg.Columns[i].Font.Style := [fsItalic];
    dbg.Columns[i].Font.Size  := 9;
  end;
end;

// ============================================================
//                  FORM SETUP AND TEARDOWN
// ============================================================

procedure TfrmDispatchers.FormActivate(Sender: TObject);
begin
  GoToTab(0);
  chkAvailable.Enabled := false;   // display only, never edited
  sVehicle := '';

  // 'if not Active then Open'. Calling Open on an already-open
  // dataset raises, and FormActivate fires every time the form
  // regains focus.
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

  // -- grid formatting: widths sized to the longest value ----
  ApplyGridFont(dbgOrders_Dispatch);
  SetColWidth(dbgOrders_Dispatch, 'OrderID', 105);            // ORD-2026-030
  SetColWidth(dbgOrders_Dispatch, 'UserID', 95);              // CON-109-NLP
  SetColWidth(dbgOrders_Dispatch, 'ItemID', 130);             // SHU-BLK-TIM-01
  SetColWidth(dbgOrders_Dispatch, 'VehicleID', 95);           // VEH-HVR-01
  SetColWidth(dbgOrders_Dispatch, 'Order_Date', 100);         // 02/21/26
  SetColWidth(dbgOrders_Dispatch, 'Delivery_Sequence', 130);
  SetColWidth(dbgOrders_Dispatch, 'Status', 75);              // On Route
  SetColWidth(dbgOrders_Dispatch, 'Quantity', 65);            // 15

  ApplyGridFont(dbgTrucks_Dispatch);
  SetColWidth(dbgTrucks_Dispatch, 'VehicleID', 95);           // VEH-HVR-01
  SetColWidth(dbgTrucks_Dispatch, 'Vehicle_Reg', 90);         // GP 987-654
  SetColWidth(dbgTrucks_Dispatch, 'Vehicle_Type', 135);       // Sprinter Van
  SetColWidth(dbgTrucks_Dispatch, 'Status', 80);              // Maintenance
  SetColWidth(dbgTrucks_Dispatch, 'Max_Weight', 85);          // 8500
  SetColWidth(dbgTrucks_Dispatch, 'Max_Volume', 85);          // 60000

  // -- reset every piece of load and route state -------------
  ClearLoadedOrders;
  rTotalWeight := 0;
  rTotalVolume := 0;
  iRouteLen    := 0;
  rRouteTotal  := 0;
  bMapReady    := false;
  bRouteReady  := false;
  btnProceed.Visible := false;
  RefreshLoadLabels;

  iTest := 0;
end;

// Without this the form leaks every TOrder it created.
procedure TfrmDispatchers.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ClearLoadedOrders;
end;

end.
