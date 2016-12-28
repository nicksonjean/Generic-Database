unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Rtti,
  System.Bindings.Outputs,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Bind.Editors,
  FMX.Grid.Style,
  FMX.ScrollBox,
  FMX.Grid,
  FMX.Bind.DBEngExt,
  FMX.Bind.Grid,
  FMX.ExtCtrls, FMX.ListBox, Data.DbxSqlite, Data.FMTBcd, Datasnap.Provider,
  Datasnap.DBClient, Data.DB, Data.SqlExpr, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.Bind.EngExt, Data.Bind.Components, Data.Bind.DBScope,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.Layouts;

type
  TForm1 = class(TForm)
    ButSQLite: TButton;
    ButMySQL: TButton;
    ButPostgreSQL: TButton;
    ButFirebird: TButton;
    ComboBox1: TComboBox;
    DataSetProvider1: TDataSetProvider;
    TabControl1: TTabControl;
    TabSQLite: TTabItem;
    GridSQLite: TGrid;
    TabFirebird: TTabItem;
    GridFirebird: TGrid;
    TabMySQL: TTabItem;
    GridMySQL: TGrid;
    TabPostgreSQL: TTabItem;
    GridPostgreSQL: TGrid;
    ClientDataSet1: TClientDataSet;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    LinkPropertyToFieldIndex: TLinkPropertyToField;
    ListBox1: TListBox;
    LinkListControlToField2: TLinkListControlToField;
    LinkPropertyToFieldIndex2: TLinkPropertyToField;
    procedure ButSQLiteClick(Sender: TObject);
    procedure ButMySQLClick(Sender: TObject);
    procedure ButPostgreSQLClick(Sender: TObject);
    procedure ButFirebirdClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses SQLConnection;

procedure TForm1.ButSQLiteClick(Sender: TObject);
var
  DBSQLite : TConnection;
  Query: TQueryBuilder;
  SQL: TQuery;
begin
  DBSQLite := TConnection.Create;
  //DBSQLite := TConnectionClass.GetInstance();
  try
    DBSQLite.Driver := SQLITE;
    DBSQLite.Database :=
    {$IFDEF MSWINDOWS}
      ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';
    {$ELSE}
      TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE');
    {$ENDIF}

    if not DBSQLite.GetInstance.Connection.Connected then
      DBSQLite.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT * FROM logradouro');
      SQL.toGrid(GridSQLite);
      //ShowMessage(SQL.Query.RecordCount.ToString);
    finally
      SQL.Free;
    end;

  finally
    DBSQLite.Free;
  end;
end;

procedure TForm1.ButFirebirdClick(Sender: TObject);
var
  DBFirebird : TConnection;
  Query: TQueryBuilder;
  SQL: TQuery;
begin
  DBFirebird := TConnection.Create;
  //DBFirebird := TConnectionClass.GetInstance();
  try
    DBFirebird.Driver := FIREBIRD;
    DBFirebird.Host := '127.0.0.1';
    DBFirebird.Port := 3050;
    DBFirebird.Database :=
    {$IFDEF MSWINDOWS}
      ExtractFilePath(ParamStr(0)) + 'DB.FDB';
    {$ELSE}
      TPath.Combine(TPath.GetDocumentsPath, 'DB.FDB');
    {$ENDIF}
    DBFirebird.Username := 'SYSDBA';
    DBFirebird.Password := 'masterkey';

    if not DBFirebird.GetInstance.Connection.Connected then
      DBFirebird.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT * FROM "card_sector"');
      SQL.toGrid(GridFirebird);
      //ShowMessage(SQL.Query.RecordCount.ToString);
    finally
      SQL.Free;
    end;

  finally
    DBFirebird.Free;
  end;
end;

procedure TForm1.ButMySQLClick(Sender: TObject);
var
  DBMySQL : TConnection;
  Query: TQueryBuilder;
  SQL: TQuery;
begin
  DBMySQL := TConnection.Create;
  //DBMySQL := TConnectionClass.GetInstance();
  try
    DBMySQL.Driver := MYSQL;
    DBMySQL.Host := '127.0.0.1';
    DBMySQL.Port := 3306;
    DBMySQL.Database := 'demodev';
    DBMySQL.Username := 'demo';
    DBMySQL.Password := 'masterkey';

    if not DBMySQL.GetInstance.Connection.Connected then
      DBMySQL.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT * FROM estado');
      SQL.toGrid(GridMySQL);
      //ShowMessage(SQL.Query.RecordCount.ToString);
    finally
      SQL.Free;
    end;

  finally
    DBMySQL.Free;
  end;
end;

procedure TForm1.ButPostgreSQLClick(Sender: TObject);
var
  DBPostgreSQL : TConnection;
  Query: TQueryBuilder;
  SQL: TQuery;
begin
  DBPostgreSQL := TConnection.Create;
  //DBPostgreSQL := TConnectionClass.GetInstance();
  try
    DBPostgreSQL.Driver := POSTGRES;
    DBPostgreSQL.Host := '127.0.0.1';
    DBPostgreSQL.Port := 5432;
    DBPostgreSQL.Database := 'postgres';
    DBPostgreSQL.Schema := 'demodev';
    DBPostgreSQL.Username := 'postgres';
    DBPostgreSQL.Password := 'masterkey';

    if not DBPostgreSQL.GetInstance.Connection.Connected then
      DBPostgreSQL.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT * FROM demodev.cidade');
      SQL.toGrid(GridPostgreSQL);
      //ShowMessage(SQL.Query.RecordCount.ToString);
    finally
      SQL.Free;
    end;

  finally
    DBPostgreSQL.Free;
  end;
end;

end.
