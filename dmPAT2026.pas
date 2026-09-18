unit dmPAT2026;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB;

type
  TdmPAT2026_1 = class(TDataModule)
    conPAT2026: TADOConnection;
    tblBrands: TADOTable;
    tblWardrobes: TADOTable;
    tblUsers: TADOTable;
    tblOrders: TADOTable;
    tblTrucks: TADOTable;
    tblInventory: TADOTable;
    tblWarehouses: TADOTable;
    qryMain: TADOQuery;
    dsBrands: TDataSource;
    dsTrucks: TDataSource;
    dsWarehouses: TDataSource;
    dsUsers: TDataSource;
    dsWardrobe: TDataSource;
    dsOrders: TDataSource;
    dsInventory: TDataSource;
    dsMain: TDataSource;
    qryWardrobe: TADOQuery;
    dsQWardrobes: TDataSource;
    qryShop: TADOQuery;
    dsShop: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmPAT2026_1: TdmPAT2026_1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

end.
