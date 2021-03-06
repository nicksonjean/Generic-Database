unit FMX.ListView.Helper;

interface

uses
  System.SysUtils,
  System.UITypes,
  FMX.ListView.Types,
  FMX.ListView,
  FMX.SearchBox;

type
  TListViewHelper = class helper for TListView
  public
    procedure EmptyFilter;
  end;

type
  TCustomListViewHelper = class helper for TCustomListView
  public
    function FindCaption(const Name, ObjID: string): Boolean;
    function FindItemByValue(const Value: String): Integer;
    function FindItemByName(const Name, ObjID: String): Integer;
    function FindItemByNameValue(const Name, ObjID, ObjValue: String): String;
    function CountItemByName(const Name, ObjID: String): Integer;
  end;

implementation

{ TListViewHelper }

procedure TListViewHelper.EmptyFilter;
var
  SearchEdit: TSearchBox;
  I: Integer;
begin
  SearchEdit := nil;
  for I := 0 to Self.ComponentCount - 1 do
  begin
    if (Self.Components[I] is TSearchBox) then
    begin
      SearchEdit := Self.Components[I] as TSearchBox;
      break;
    end;
  end;
  if (SearchEdit <> nil) then
    SearchEdit.Text := '';
end;

{ TCustomListViewHelper }

function TCustomListViewHelper.FindCaption(const Name, ObjID: String): Boolean;
var
  I: Integer;
begin
  Result := false;
  for I := 0 to Pred(Items.Count) do
  begin
    Result := CompareText(TListItemText(Items[I].Objects.FindDrawable(ObjID)).Text, Name) = 0;
    if Result then
      exit;
  end;
end;

function TCustomListViewHelper.FindItemByValue(const Value: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Pred(Items.Count) do
  begin
    if Self.Items.AppearanceItem[I].Text = Value then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TCustomListViewHelper.FindItemByName(const Name, ObjID: String): Integer;
var
  I: Integer;
  Text: String;
begin
  Result := -1;
  for I := 0 to Pred(Items.Count) do
  begin
    Text := TListItemText(Items[I].Objects.FindDrawable(ObjID)).Text;
    if Text = Name then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TCustomListViewHelper.CountItemByName(const Name, ObjID: String): Integer;
var
  I, E: Integer;
  Text: String;
begin
  Result := 0;
  E := Result;
  for I := 0 to Pred(Items.Count) do
  begin
    Text := TListItemText(Items[I].Objects.FindDrawable(ObjID)).Text;
    if Text = Name then
      Inc(E);
  end;
  Result := E;
end;

function TCustomListViewHelper.FindItemByNameValue(const Name, ObjID, ObjValue: String): String;
var
  I: Integer;
  Text: String;
begin
  Result := '';
  for I := 0 to Pred(Items.Count) do
  begin
    Text := TListItemText(Items[I].Objects.FindDrawable(ObjID)).Text;
    if Text = Name then
    begin
      Result := TListItemText(Items[I].Objects.FindDrawable(ObjValue)).Text;
      Break;
    end;
  end;
end;

end.
