unit clsOrders;

interface

uses
  System.SysUtils;

type
  TOrder = class
  private
    fOrderID     : string;
    fRecipient   : string;
    fItemID      : string;
    fItemName    : string;
    fOrderDate   : string;
    fQuantity    : Integer;
    fStatus      : string;
    fWarehouse   : string;
    fCity        : string;
  public
    constructor Create(aOrderID, aRecipient, aItemID, aItemName,
      aOrderDate: string; aQuantity: Integer; aStatus: string);

    // ── Getters (one per private attribute) ────────────────
    function getOrderID              : string;
    function getRecipient            : string;
    function getItemID               : string;
    function getItemName             : string;
    function getOrderDate            : string;
    function getQuantity             : Integer;
    function getStatus               : string;
    function getDestinationWarehouse : string;
    function getDestinationCity      : string;

    // ── Setters (only for fields that change after creation) ─
    procedure setStatus(aStatus: string);
    procedure setQuantity(aQuantity: Integer);
    procedure setDestinationWarehouse(sWarehouse: string);
    procedure setDestinationCity(sCity: string);

    // ── Extra behaviour ────────────────────────────────────
    function toString : string; reintroduce;
    function isDelivered : Boolean;
  end;

implementation

// ============================================================
//  Constructor — copies the supplied values into the object.
//  'inherited Create' runs TObject's constructor first, which
//  is what actually allocates the object in memory.
// ============================================================
constructor TOrder.Create(aOrderID, aRecipient, aItemID, aItemName,
  aOrderDate: string; aQuantity: Integer; aStatus: string);
begin
  inherited Create;
  fOrderID        := aOrderID;
  fRecipient      := aRecipient;
  fItemID         := aItemID;
  fItemName       := aItemName;
  fOrderDate      := aOrderDate;
  fQuantity       := aQuantity;
  fStatus         := aStatus;
  fWarehouse      := '';
  fCity           := '';
end;

// ── Getters ─────────────────────────────────────────────────
function TOrder.getOrderID: string;
begin
  Result := fOrderID;
end;

function TOrder.getRecipient: string;
begin
  Result := fRecipient;
end;

function TOrder.getDestinationCity: string;
begin
  result := fCity;
end;

function TOrder.getDestinationWarehouse: string;
begin
  result := fWarehouse;
end;

function TOrder.getItemID: string;
begin
  Result := fItemID;
end;

function TOrder.getItemName: string;
begin
  Result := fItemName;
end;

function TOrder.getOrderDate: string;
begin
  Result := fOrderDate;
end;

function TOrder.getQuantity: Integer;
begin
  Result := fQuantity;
end;

function TOrder.getStatus: string;
begin
  Result := fStatus;
end;

// ── Setters ─────────────────────────────────────────────────
procedure TOrder.setStatus(aStatus: string);
begin
  fStatus := aStatus;
end;

procedure TOrder.setDestinationCity(sCity: string);
begin
  fCity := sCity;
end;

procedure TOrder.setDestinationWarehouse(sWarehouse: string);
begin
  fWarehouse := sWarehouse;
end;

procedure TOrder.setQuantity(aQuantity: Integer);
begin
  fQuantity := aQuantity;
end;

// ── toString: a formatted line for receipts / manifests ─────
function TOrder.toString: string;
begin
  Result := fOrderID + ' | ' + fItemName +
            ' (x' + IntToStr(fQuantity) + ')' +
            ' | ' + fRecipient +
            ' | ' + fStatus;
end;

// ── isDelivered: keeps status checks out of the main code ───
function TOrder.isDelivered: Boolean;
begin
  Result := (fStatus = 'Delivered');
end;

end.
