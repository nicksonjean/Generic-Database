﻿{
  Connector.
  ------------------------------------------------------------------------------
  Objetivo : Conectar o Objeto TQuery aos Componentes TGrid, TStringGrid,
  TListBox, TListView, TComboBox e TComboEdit.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  ------------------------------------------------------------------------------
  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la
  sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versão 3.29 da Licença, ou (a seu critério)
  qualquer versão posterior.
  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU
  ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor
  do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)
  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto
  com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,
  no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Você também pode obter uma copia da licença em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit Connector;

interface

{ Carrega a Interface Padrão }
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
  System.Types,
  System.UITypes,

  FMX.Consts,
  FMX.Types,
    FMX.Dialogs,
    FMX.Forms,
  FMX.Grid,
  FMX.ComboEdit,
  FMX.ListBox,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.SearchBox,
  FMX.StdCtrls,

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

  FMX.ListView.Extension,
  FMX.ListView.Helper,
  FMX.ListBox.Helper,
  FMX.StringGrid.Helper,
  FMX.Grid.Helper,

  EventDriven,
  SQLConnection
  ;

type
  TValueObject = class(TObject)
  strict private
    FValue: TValue;
  public
    constructor Create(const aValue: TValue);
    property Value: TValue read FValue;
  end;

  { Classe TConnector Herdade de TQuery }
type
  TConnector = class(TQuery)
  private
    { Private declarations }
    FQuery: TQuery;
    {$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
    function ToClientDataSet(Query: TQuery): TClientDataSet;
    {$ENDIF}
    {$IF DEFINED(FireDACLib)}
    function ToFDMemTable(Query: TQuery): TFDMemTable;
    {$ENDIF}
    procedure ToFillList(AOwner: TComponent; IndexField, ValueField: String; SelectedIndex : Integer = -1);
    procedure ToMultiList(AOwner: TComponent; IndexField, ValueField: String; Detail1Fields: TArray<String> = []; SelectedIndex : Integer = -1);
  public
    { Public declarations }
    constructor Create(Query: TQuery);
    destructor Destroy; override;
    procedure ToGrid(AOwner: TComponent; SelectedIndex : Integer = -1);
    procedure ToCombo(AOwner: TComponent; IndexField, ValueField: String; SelectedIndex : Integer = -1);
    procedure ToListBox(AOwner: TComponent; IndexField, ValueField: String; SelectedIndex : Integer = -1);
    procedure ToListView(AOwner: TComponent; IndexField, ValueField: String; Detail1Fields: TArray<String> = []; SelectedIndex : Integer = -1);
  end;

implementation

{ TValueObject }

constructor TValueObject.Create(const aValue: TValue);
begin
  FValue := aValue;
end;

{ TConnector }

constructor TConnector.Create(Query : TQuery);
begin
  inherited Create;

  Self.FQuery := Query;
end;

destructor TConnector.Destroy;
begin

  inherited;
end;

{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
function TConnector.ToClientDataSet(Query: TQuery): TClientDataSet;
var
  DataSetProvider : TDataSetProvider;
  ClientDataSet : TClientDataSet;
begin
  DataSetProvider := TDataSetProvider.Create(Query.Query);
  DataSetProvider.DataSet := Query.Query;

  ClientDataSet := TClientDataSet.Create(DataSetProvider);
  ClientDataSet.Data := DataSetProvider.Data;
  ClientDataSet.Active := True;

  ClientDataSet.First;
  while not ClientDataSet.Eof do begin
    ClientDataSet.Edit;
    ClientDataSet.Post;
    ClientDataSet.Next;
  end;
  ClientDataSet.Last;

  Result := ClientDataSet;
end;
{$ENDIF}

{$IF DEFINED(FireDACLib)}
function TConnector.ToFDMemTable(Query: TQuery): TFDMemTable;
var
  FDMemTable : TFDMemTable;
begin
  FDMemTable := TFDMemTable.Create(Query.Query);

  Query.Query.FetchOptions.Unidirectional := False;
  Query.Query.Open;
  Query.Query.FetchAll;

  FDMemTable.Data := Query.Query.Data;
  FDMemTable.First;
  while not FDMemTable.Eof do begin
    FDMemTable.Edit;
    FDMemTable.Post;
    FDMemTable.Next;
  end;
  FDMemTable.Last;

  Result := FDMemTable;
end;
{$ENDIF}

procedure TConnector.ToFillList(AOwner: TComponent; IndexField, ValueField: String; SelectedIndex : Integer = -1);
var
  I: Integer;
  Items : TStringList;
  MemTableOrClientDataSet : {$I CNC.Type.inc};
begin
  Application.ProcessMessages;

{
  TODO -oNickson Jeanmerson -cProgrammer :
  1) Adicionar Suporte a Proriedade AlternatingColors via Helper com o Método OpenPopup para o Component ComboBox e ComboEdit;
}

  if (AOwner is TComboEdit) and (TComboEdit(AOwner) <> nil) and (TComboEdit(AOwner).Items.Count > 0) then
    TComboEdit(AOwner).Items.Clear
  else if (AOwner is TComboBox) and (TComboBox(AOwner) <> nil) and (TComboBox(AOwner).Items.Count > 0) then
    TComboBox(AOwner).Items.Clear
  else if (AOwner is TListBox) and (TListBox(AOwner) <> nil) and (TListBox(AOwner).Items.Count > 0) then
  begin
    TListBox(AOwner).Items.Clear;
    TListBox(AOwner).EmptyFilter;
  end;

{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
  MemTableOrClientDataSet := Self.ToClientDataSet(Self.FQuery);
{$ENDIF}
{$IF DEFINED(FireDACLib)}
  MemTableOrClientDataSet := Self.ToFDMemTable(Self.FQuery);
{$ENDIF}

  if MemTableOrClientDataSet.RecordCount > 0 then
  begin
    Items := TStringList.Create(True);

    MemTableOrClientDataSet.First;
    while not(MemTableOrClientDataSet.Eof) do
    begin
      Items.Add(MemTableOrClientDataSet.FieldByName(ValueField).AsString + '=' + MemTableOrClientDataSet.FieldByName(IndexField).AsString);
      MemTableOrClientDataSet.Next;
    end;
    MemTableOrClientDataSet.Last;

    for I := 0 to Items.Count - 1 do
    begin
      Items.Objects[I] := TValueObject.Create(Items.ValueFromIndex[I]);
      Items.Strings[I] := Items.Names[I];
    end;

    if AOwner Is TComboEdit then
    begin
      TComboEdit(AOwner).Items.BeginUpdate;
      TComboEdit(AOwner).Items := Items;
      TComboEdit(AOwner).ItemIndex := SelectedIndex;
      TComboEdit(AOwner).Items.EndUpdate;
    end
    else if AOwner Is TComboBox then
    begin
      TComboBox(AOwner).Items.BeginUpdate;
      TComboBox(AOwner).Items := Items;
      TComboBox(AOwner).ItemIndex := SelectedIndex;
      TComboBox(AOwner).Items.EndUpdate;
    end
    else if AOwner Is TListBox then
    begin
      TListBox(AOwner).AlternatingRowBackground := True;
      TListBox(AOwner).Items.BeginUpdate;
      TListBox(AOwner).Items := Items;
      TListBox(AOwner).ItemIndex := SelectedIndex;
      TListBox(AOwner).Items.EndUpdate;
    end;

    Items.Destroy;

    MemTableOrClientDataSet.Destroy;
  end;

end;

procedure TConnector.ToMultiList(AOwner: TComponent; IndexField, ValueField: String; Detail1Fields: TArray<String> = []; SelectedIndex : Integer = -1);
var
  Item: TListViewItem;
  MemTableOrClientDataSet : {$I CNC.Type.inc};
begin
  Application.ProcessMessages;

  TListView(AOwner).ItemAppearanceClassName := 'TMultiDetailItemAppearance';
  TListView(AOwner).ItemEditAppearanceClassName := 'TMultiDetailDeleteAppearance';

  if (AOwner is TListView) and (TListView(AOwner) <> nil) and (TListView(AOwner).Items.Count > 0) then
  begin
    TListView(AOwner).Items.Clear;
    TListView(AOwner).EmptyFilter;
  end;

  TListView(AOwner).BeginUpdate;
  try

    if FQuery.Query.RecordCount > 0 then
    begin
{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
      MemTableOrClientDataSet := Self.ToClientDataSet(Self.FQuery);
{$ENDIF}
{$IF DEFINED(FireDACLib)}
      MemTableOrClientDataSet := Self.ToFDMemTable(Self.FQuery);
{$ENDIF}

      MemTableOrClientDataSet.First;
      while not(MemTableOrClientDataSet.Eof) do
      begin
        TListView(AOwner).AlternatingColors := True;

        Item := TListView(AOwner).Items.Add;
        Item.Index := MemTableOrClientDataSet.FieldByName(IndexField).AsInteger;
        Item.Text := MemTableOrClientDataSet.FieldByName(ValueField).AsString;
        if Length(Detail1Fields) > 0 then
        begin
          if Length(Detail1Fields) = 1 then
          begin
            if Detail1Fields[0] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail1] := MemTableOrClientDataSet.FieldByName(Detail1Fields[0]).AsString;
          end;
          if Length(Detail1Fields) = 2 then
          begin
            if Detail1Fields[0] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail1] := MemTableOrClientDataSet.FieldByName(Detail1Fields[0]).AsString;
            if Detail1Fields[1] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail2] := MemTableOrClientDataSet.FieldByName(Detail1Fields[1]).AsString;
          end;
          if Length(Detail1Fields) = 3 then
          begin
            if Detail1Fields[0] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail1] := MemTableOrClientDataSet.FieldByName(Detail1Fields[0]).AsString;
            if Detail1Fields[1] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail2] := MemTableOrClientDataSet.FieldByName(Detail1Fields[1]).AsString;
            if Detail1Fields[2] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail3] := MemTableOrClientDataSet.FieldByName(Detail1Fields[2]).AsString;
          end;
        end;

{ TODO -oNickson Jeanmerson -cProgrammer :
  1) Adicionar Suporte à Imagens via Blog com TImage/TBitmap e ImageString em Base64;
  2) Adicionar Suporte à Accessory; }

        //Item.BitmapRef := ImageRAD.Bitmap;
        MemTableOrClientDataSet.Next;
      end;
      MemTableOrClientDataSet.Last;

      if SelectedIndex <> 0 then
        TListView(AOwner).ItemIndex := SelectedIndex;

      MemTableOrClientDataSet.Destroy;
    end;

  finally
    TListView(AOwner).EndUpdate;
  end;

end;

procedure TConnector.ToGrid(AOwner: TComponent; SelectedIndex : Integer = -1);
var
  I : Integer;
  Column : TColumn;
  MemTableOrClientDataSet : {$I CNC.Type.inc};
begin
  Application.ProcessMessages;

  if (AOwner is TStringGrid) and (TStringGrid(AOwner) <> nil) then
    TStringGrid(AOwner).ClearColumns
  else if (AOwner is TGrid) and (TGrid(AOwner) <> nil) then
    TGrid(AOwner).ClearColumns;

  if AOwner Is TStringGrid then
  begin

    if FQuery.Query.RecordCount > 0 then
    begin

      TStringGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
      TStringGrid(AOwner).RowCount := Self.FQuery.Query.RecordCount;

      for I := 0 to Self.FQuery.Query.FieldCount - 1 do
      begin
        Column := TColumn.Create(Self.FQuery.Query);
        Column.Header := Self.FQuery.Query.Fields[I].FieldName;
        Column.Tag := I;
        Column.Parent := TStringGrid(AOwner);
      end;

{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
      MemTableOrClientDataSet := Self.ToClientDataSet(Self.FQuery);
{$ENDIF}
{$IF DEFINED(FireDACLib)}
      MemTableOrClientDataSet := Self.ToFDMemTable(Self.FQuery);
{$ENDIF}

      MemTableOrClientDataSet.First;
      while not MemTableOrClientDataSet.Eof do
      begin
        for I := 0 to MemTableOrClientDataSet.FieldCount - 1 do
          TStringGrid(AOwner).Cells[I, MemTableOrClientDataSet.RecNo - 1] := MemTableOrClientDataSet.Fields[I].AsString;
        MemTableOrClientDataSet.Next;
      end;
      MemTableOrClientDataSet.Last;

    end;

    {
    TStringGrid(AOwner).BeginUpdate;
    for I := 0 to TStringGrid(AOwner).ColumnCount - 1 do
      TStringGrid(AOwner).AutoSizeColumns(I);
    TStringGrid(AOwner).EndUpdate;
    }

    TStringGrid(AOwner).Selected := SelectedIndex;
    TStringGrid(AOwner).ColumnIndex := SelectedIndex;

    if SelectedIndex <> -1 then
    begin
      TStringGrid(AOwner).Row := SelectedIndex;
      TStringGrid(AOwner).Col := 0;
    end;

  end;

  if AOwner Is TGrid then
  begin

    if FQuery.Query.RecordCount > 0 then
    begin

      TGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
      TGrid(AOwner).RowCount := Self.FQuery.Query.RecordCount;

      for I := 0 to Self.FQuery.Query.FieldCount - 1 do
      begin
        Column := TColumn.Create(Self.FQuery.Query);
        Column.Header := Self.FQuery.Query.FieldDefs[I].Name;
        Column.Tag := I;
        Column.Data := Self.FQuery.Query.Fields[I].AsString;
        TGrid(AOwner).AddObject(Column);
      end;

{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
      MemTableOrClientDataSet := Self.ToClientDataSet(Self.FQuery);
{$ENDIF}
{$IF DEFINED(FireDACLib)}
      MemTableOrClientDataSet := Self.ToFDMemTable(Self.FQuery);
{$ENDIF}

      TGrid(AOwner).OnGetValue := DelegateOnGetValueEvent(
        TGrid(AOwner),
        procedure(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue)
        begin
          MemTableOrClientDataSet.First;
          MemTableOrClientDataSet.MoveBy(ARow);
          Value := MemTableOrClientDataSet.Fields[ACol].Text;
        end
      );

      {
      TGrid(AOwner).BeginUpdate;
      for I := 0 to TGrid(AOwner).ColumnCount - 1 do
        TGrid(AOwner).AutoSizeColumns(I);
      TGrid(AOwner).EndUpdate;
      }

      TGrid(AOwner).Selected := SelectedIndex;
      TGrid(AOwner).ColumnIndex := SelectedIndex;

      if SelectedIndex <> -1 then
      begin
        TGrid(AOwner).Row := SelectedIndex;
        TGrid(AOwner).Col := 0;
      end;

    end;

  end;

end;

procedure TConnector.ToCombo(AOwner: TComponent; IndexField, ValueField: String; SelectedIndex : Integer = -1);
begin
  Self.ToFillList(AOwner, IndexField, ValueField, SelectedIndex);
end;

procedure TConnector.ToListBox(AOwner: TComponent; IndexField, ValueField: String; SelectedIndex : Integer = -1);
begin
  Self.ToFillList(AOwner, IndexField, ValueField, SelectedIndex);
end;

procedure TConnector.ToListView(AOwner: TComponent; IndexField, ValueField: String; Detail1Fields: TArray<String> = []; SelectedIndex : Integer = -1);
begin
  Self.ToMultiList(AOwner, IndexField, ValueField, Detail1Fields, SelectedIndex);
end;

end.