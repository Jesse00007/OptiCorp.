unit clsGarment;

interface

uses
  System.SysUtils;

type
  TGarment = class
    private
      fItemID     : string;
      fItemName   : string;
      fBrandID    : string;
      fColour     : string;
      fFormality  : integer;
      fWarmth     : integer;
      fCategory   : string;
      fClean      : boolean;

    public
      constructor Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);

      function getItemID    : string;
      function getItemName  : string;
      function getBrandID   : string;
      function getColour    : string;
      function getFormality : integer;
      function getWarmth    : integer;
      function getCategory  : string;
      function getClean     : boolean;

      function IsNeutral                          : boolean;
      function InBand(iLow, iHigh: integer)       : boolean;
      function ImagePath                          : string;
      function toString                           : string; reintroduce; virtual;
  end;

  TTop = class(TGarment)
  public
    constructor Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);
    function toString : string; override;
  end;

  TBottom = class(TGarment)
  public
    constructor Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);
    function toString : string; override;
  end;

  TShoes = class(TGarment)
  public
    constructor Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);
    function toString : string; override;
  end;

  TOuterwear = class(TGarment)
  public
    constructor Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);
    function toString : string; override;
  end;

implementation

{ TOuterwear }

constructor TOuterwear.Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);
begin
  inherited Create(aItemID, aItemName, aBrandID, aColour, aFormality, aWarmth, aCategory, aClean);
  //fCategory := 'Outerwear';
end;

function TOuterwear.toString: string;
begin
  result := 'Outerwear      : ' + inherited toString;
end;

{ TShoes }

constructor TShoes.Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);
begin
  inherited Create(aItemID, aItemName, aBrandID, aColour, aFormality, aWarmth, aCategory, aClean);
  //fCategory := 'Shoes';
end;

function TShoes.toString: string;
begin
  result := 'Shoes      : ' + inherited toString;
end;

{ TGarment }

constructor TGarment.Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);
begin
  inherited Create;
  fItemID := aItemID;
  fItemName := aItemName;
  fBrandID := aBrandID;
  fColour := aColour;
  fFormality := aFormality;
  fWarmth := aWarmth;
  fClean := aClean;
  fCategory := aCategory;
end;

function TGarment.getBrandID: string;
begin
  result := fBrandID;
end;

function TGarment.getCategory: string;
begin
  result := fCategory;
end;

function TGarment.getClean: boolean;
begin
  result := fClean;
end;

function TGarment.getColour: string;
begin
  result := fColour;
end;

function TGarment.getFormality: integer;
begin
  result := fFormality;
end;

function TGarment.getItemID: string;
begin
  result := fItemID;
end;

function TGarment.getItemName: string;
begin
  result := fItemName;
end;

function TGarment.getWarmth: integer;
begin
  result := fWarmth;
end;

function TGarment.ImagePath: string;
begin
  result := 'delphi\Win32\Debug\clothes\' + fItemID + '.jpg';
end;

function TGarment.InBand(iLow, iHigh: integer): boolean;
begin
  result := (fFormality >= iLow) and (fFormality <= iHigh);
end;

function TGarment.IsNeutral: boolean;
begin
  Result := (fColour = 'Black') or (fColour = 'Brown') or (fColour = 'Grey') or (fColour = 'White');
end;

function TGarment.toString: string;
begin
  result := fItemName + ' (' + fColour + ', warmth ' + inttostr(fWarmth) +
    ', formality ' + inttostr(fFormality) + ')';
end;

{ TBottom }

constructor TBottom.Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);
begin
  inherited Create(aItemID, aItemName, aBrandID, aColour, aFormality, aWarmth, aCategory, aClean);
  //fCategory := 'Bottom';
end;

function TBottom.toString: string;
begin
  result := 'Bottom     : ' + inherited toString;
end;

{ TTop }

constructor TTop.Create(aItemID, aItemName, aBrandID, aColour: string; aFormality, aWarmth: integer; aCategory: string; aClean: boolean);
begin
  inherited Create(aItemID, aItemName, aBrandID, aColour, aFormality, aWarmth, aCategory, aClean);
  //fCategory := 'Top';
end;

function TTop.toString: string;
begin
  result := 'Top     : ' + inherited toString;
end;

end.
