﻿unit FMX.StringGrid.Helper;

interface

{$I CNC.Default.inc}

uses
  System.SysUtils,
  System.IOUtils,
  System.StrUtils,
  System.DateUtils,
  System.Classes,
  System.Math,
  System.SyncObjs,
  System.Threading,
  System.Generics.Collections,
  System.RTLConsts,
  System.Variants,
  System.JSON,
  System.RTTI,
  System.TypInfo,
  System.Types,
  System.UITypes,
  FMX.Grid,
  FMX.Controls,
  FMX.Graphics,

  Data.DB,

{$IFDEF FireDACLib}
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
{$ENDIF}
{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
  Datasnap.Provider,
  Datasnap.DBClient,
  Data.FMTBcd,
  Data.SqlExpr,
{$ENDIF}
{$IFDEF ZeOSLib}
  ZAbstractConnection,
  ZConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
{$ENDIF}

  EventDriven;

type
  TStringGridHelper = class helper for TStringGrid
  private
    class var FData : {$I CNC.Type.inc};
    function GetData : {$I CNC.Type.inc};
    procedure SetData(Data : {$I CNC.Type.inc});
    procedure DoFillData(Data: {$I CNC.Type.inc});
    class var FAutoSizeColumns: Boolean;
    function GetAutoSizeColumns : Boolean;
    procedure SetAutoSizeColumns(Value : Boolean);
    procedure DoAutoSizeColumns;
  public
    procedure RemoveRows(RowIndex, RCount: Integer);
    procedure Clear;
    property FillData: {$I CNC.Type.inc} read GetData write SetData;
    property AutoSizeColumns: Boolean read GetAutoSizeColumns write SetAutoSizeColumns default false;
  end;

implementation

{ TStringGridHelper }

procedure TStringGridHelper.DoAutoSizeColumns;
var
  W: Integer;
  WMax: Single;
  SizeMax: Single;
  Column : Integer;
begin
  SizeMax := Self.Width;
  for Column := 0 to Self.ColumnCount-1 do
  begin
    if Self.ColumnByIndex(Column).Width > 0 then
    begin
      WMax := Round(Canvas.TextWidth(Self.ColumnByIndex(Column).Header));
      FData.First;
      while not FData.Eof do
      begin
        W := Round(Canvas.TextWidth(FData.Fields[Column].AsString));
        if W > WMax then
          WMax := W;
        if WMax > SizeMax then
        begin
          Self.ColumnByIndex(Column).Width := SizeMax + 10;
          Break;
        end;
        Self.ColumnByIndex(Column).Width := WMax + 10;
        FData.Next;
      end;
      FData.Last;
    end;
  end;
end;

procedure TStringGridHelper.DoFillData(Data: {$I CNC.Type.inc});
var
  I : Integer;
  Column : TColumn;
begin
  Self.RowCount := Data.RecordCount;

  for I := 0 to Data.FieldCount - 1 do
  begin
    Column := TColumn.Create(nil);
    Column.Header := Data.Fields[I].FieldName;
    Column.Tag := I;
    Column.Parent := Self;
  end;

  Data.First;
  while not Data.Eof do
  begin
    for I := 0 to Data.FieldCount - 1 do
      Self.Cells[I, Data.RecNo - 1] := Data.Fields[I].AsString;
    Data.Next;
  end;
  Data.Last;
end;

procedure TStringGridHelper.SetData(Data: {$I CNC.Type.inc});
begin
  FData := Data;
  Self.DoFillData(Data);
end;

function TStringGridHelper.GetData: {$I CNC.Type.inc};
begin
  Result := FData;
end;

function TStringGridHelper.GetAutoSizeColumns: Boolean;
begin
  Result := FAutoSizeColumns;
end;

procedure TStringGridHelper.SetAutoSizeColumns(Value: Boolean);
begin
  FAutoSizeColumns := Value;
  if FAutoSizeColumns = True then
    Self.DoAutoSizeColumns;
end;

procedure TStringGridHelper.Clear;
var
  I: Integer;
begin
  for I := 0 to RowCount - 1 do
    RemoveRows(0, RowCount);
  ClearColumns;
end;

procedure TStringGridHelper.RemoveRows(RowIndex, RCount: Integer);
var
  I, J: Integer;
begin
  for I := RCount to RowCount - 1 do
    for J := 0 to ColumnCount - 1 do
      Cells[J, I] := Cells[J, I + 1];
  RowCount := RowCount - RCount;
end;

end.
