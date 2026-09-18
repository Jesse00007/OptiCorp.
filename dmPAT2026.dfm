object dmPAT2026_1: TdmPAT2026_1
  Height = 480
  Width = 640
  object conPAT2026: TADOConnection
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=E:\Je' +
      'sse Abache PAT 2026\databases\PAT_db.mdb;Mode=ReadWrite;Persist ' +
      'Security Info=False;Jet OLEDB:System database="";Jet OLEDB:Regis' +
      'try Path="";Jet OLEDB:Database Password="";Jet OLEDB:Engine Type' +
      '=5;Jet OLEDB:Database Locking Mode=1;Jet OLEDB:Global Partial Bu' +
      'lk Ops=2;Jet OLEDB:Global Bulk Transactions=1;Jet OLEDB:New Data' +
      'base Password="";Jet OLEDB:Create System Database=False;Jet OLED' +
      'B:Encrypt Database=False;Jet OLEDB:Don'#39't Copy Locale on Compact=' +
      'False;Jet OLEDB:Compact Without Replica Repair=False;Jet OLEDB:S' +
      'FP=False'
    LoginPrompt = False
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 24
    Top = 16
  end
  object tblBrands: TADOTable
    Connection = conPAT2026
    CursorType = ctStatic
    TableName = 'tblBrands'
    Left = 24
    Top = 88
  end
  object tblWardrobes: TADOTable
    Connection = conPAT2026
    CursorType = ctStatic
    TableName = 'tblWardrobes'
    Left = 264
    Top = 88
  end
  object tblUsers: TADOTable
    Connection = conPAT2026
    CursorType = ctStatic
    TableName = 'tblUsers'
    Left = 208
    Top = 88
  end
  object tblOrders: TADOTable
    Connection = conPAT2026
    CursorType = ctStatic
    TableName = 'tblOrders'
    Left = 320
    Top = 88
  end
  object tblTrucks: TADOTable
    Connection = conPAT2026
    CursorType = ctStatic
    TableName = 'tblTrucks'
    Left = 144
    Top = 88
  end
  object tblInventory: TADOTable
    Connection = conPAT2026
    CursorType = ctStatic
    TableName = 'tblInventory'
    Left = 376
    Top = 88
  end
  object tblWarehouses: TADOTable
    Connection = conPAT2026
    CursorType = ctStatic
    TableName = 'tblWarehouses'
    Left = 88
    Top = 88
  end
  object qryMain: TADOQuery
    Connection = conPAT2026
    Parameters = <>
    Left = 24
    Top = 168
  end
  object dsBrands: TDataSource
    DataSet = tblBrands
    Left = 24
    Top = 264
  end
  object dsTrucks: TDataSource
    DataSet = tblTrucks
    Left = 128
    Top = 264
  end
  object dsWarehouses: TDataSource
    DataSet = tblWarehouses
    Left = 80
    Top = 264
  end
  object dsUsers: TDataSource
    DataSet = tblUsers
    Left = 176
    Top = 264
  end
  object dsWardrobe: TDataSource
    DataSet = tblWardrobes
    Left = 224
    Top = 264
  end
  object dsOrders: TDataSource
    DataSet = tblOrders
    Left = 272
    Top = 264
  end
  object dsInventory: TDataSource
    DataSet = tblInventory
    Left = 320
    Top = 264
  end
  object dsMain: TDataSource
    DataSet = qryMain
    Left = 72
    Top = 168
  end
  object qryWardrobe: TADOQuery
    Connection = conPAT2026
    Parameters = <>
    Left = 128
    Top = 168
  end
  object dsQWardrobes: TDataSource
    DataSet = qryWardrobe
    Left = 168
    Top = 168
  end
  object qryShop: TADOQuery
    Connection = conPAT2026
    Parameters = <>
    Left = 224
    Top = 168
  end
  object dsShop: TDataSource
    DataSet = qryShop
    Left = 272
    Top = 176
  end
end
