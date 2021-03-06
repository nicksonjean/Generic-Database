unit FMX.ListView.Extension;

interface

uses
  System.Types,
  FMX.ListView,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  System.Classes,
  System.SysUtils,
  FMX.Types,
  FMX.Controls,
  System.UITypes;

type
  TMultiDetailAppearanceNames = class
  public const
    ListItem = 'MultiDetailItem';
    ListItemCheck = ListItem + 'ShowCheck';
    ListItemDelete = ListItem + 'Delete';
    Detail1 = 'det1';
    Detail2 = 'det2';
    Detail3 = 'det3';
    Detail4 = 'det4';
  end;

implementation

uses
  System.Math,
  System.Rtti;

type
  TMultiDetailItemAppearance = class(TPresetItemObjects)
  public const
    cTextMarginAccessory = 8;
    cDefaultImagePlaceOffsetX = -3;
    cDefaultImageTextPlaceOffsetX = 4;
    cDefaultHeight = 80;
    cDefaultImageWidth = 65;
    cDefaultImageHeight = 65;
  private
    FMultiDetail1: TTextObjectAppearance;
    FMultiDetail2: TTextObjectAppearance;
    FMultiDetail3: TTextObjectAppearance;
    FMultiDetail4: TTextObjectAppearance;
    procedure SetMultiDetail1(const Value: TTextObjectAppearance);
    procedure SetMultiDetail2(const Value: TTextObjectAppearance);
    procedure SetMultiDetail3(const Value: TTextObjectAppearance);
    procedure SetMultiDetail4(const Value: TTextObjectAppearance);
  protected
    function DefaultHeight: Integer; override;
    procedure UpdateSizes(const FinalSize: TSizeF); override;
    function GetGroupClass: TPresetItemObjects.TGroupClass; override;
    procedure SetObjectData(const AListViewItem: TListViewItem; const AIndex: string; const AValue: TValue; var AHandled: Boolean); override;
  public
    constructor Create(const Owner: TControl); override;
    destructor Destroy; override;
  published
    property Image;
    property MultiDetail1: TTextObjectAppearance read FMultiDetail1 write SetMultiDetail1;
    property MultiDetail2: TTextObjectAppearance read FMultiDetail2 write SetMultiDetail2;
    property MultiDetail3: TTextObjectAppearance read FMultiDetail3 write SetMultiDetail3;
    property MultiDetail4: TTextObjectAppearance read FMultiDetail4 write SetMultiDetail4;
    property Accessory;
  end;

  TMultiDetailDeleteAppearance = class(TMultiDetailItemAppearance)
  private const
    cDefaultGlyph = TGlyphButtonType.Delete;
  public
    constructor Create(const Owner: TControl); override;
  published
    property GlyphButton;
  end;

  TMultiDetailShowCheckAppearance = class(TMultiDetailItemAppearance)
  private const
    cDefaultGlyph = TGlyphButtonType.Checkbox;
  public
    constructor Create(const Owner: TControl); override;
  published
    property GlyphButton;
  end;


const
  cMultiDetail1Member = 'Detail1';
  cMultiDetail2Member = 'Detail2';
  cMultiDetail3Member = 'Detail3';
  cMultiDetail4Member = 'Detail4';


constructor TMultiDetailItemAppearance.Create(const Owner: TControl);
begin
  inherited;
  Accessory.DefaultValues.AccessoryType := TAccessoryType.More;
  Accessory.DefaultValues.Visible := False; // True;
  Accessory.RestoreDefaults;
  Text.DefaultValues.VertAlign := TListItemAlign.Trailing;
  Text.DefaultValues.TextVertAlign := TTextAlign.Leading;
  Text.DefaultValues.Height := 76;
  Text.DefaultValues.Visible := True;
  Text.RestoreDefaults;

  FMultiDetail1 := TTextObjectAppearance.Create;
  FMultiDetail1.Name := TMultiDetailAppearanceNames.Detail1;
  FMultiDetail1.DefaultValues.Assign(Text.DefaultValues);
  FMultiDetail1.DefaultValues.Height := 56;
  FMultiDetail1.DefaultValues.IsDetailText := True;
  FMultiDetail1.RestoreDefaults;
  FMultiDetail1.OnChange := Self.ItemPropertyChange;
  FMultiDetail1.Owner := Self;

  FMultiDetail2 := TTextObjectAppearance.Create;
  FMultiDetail2.Name := TMultiDetailAppearanceNames.Detail2;
  FMultiDetail2.DefaultValues.Assign(FMultiDetail1.DefaultValues);
  FMultiDetail2.DefaultValues.Height := 38;
  FMultiDetail2.RestoreDefaults;
  FMultiDetail2.OnChange := Self.ItemPropertyChange;
  FMultiDetail2.Owner := Self;

  FMultiDetail3 := TTextObjectAppearance.Create;
  FMultiDetail3.Name := TMultiDetailAppearanceNames.Detail3;
  FMultiDetail3.DefaultValues.Assign(FMultiDetail2.DefaultValues);
  FMultiDetail3.DefaultValues.Height := 20;
  FMultiDetail3.RestoreDefaults;
  FMultiDetail3.OnChange := Self.ItemPropertyChange;
  FMultiDetail3.Owner := Self;

  FMultiDetail4 := TTextObjectAppearance.Create;
  FMultiDetail4.Name := TMultiDetailAppearanceNames.Detail4;
  FMultiDetail4.DefaultValues.Assign(FMultiDetail3.DefaultValues);
  FMultiDetail4.DefaultValues.TextAlign := TTextAlign.Center;
  FMultiDetail4.DefaultValues.TextVertAlign := TTextAlign.Center;
  FMultiDetail4.DefaultValues.Align := TListItemAlign.Center;
  FMultiDetail4.DefaultValues.VertAlign := TListItemAlign.Center;
  FMultiDetail4.DefaultValues.Height := 20;
  FMultiDetail4.RestoreDefaults;
  FMultiDetail4.OnChange := Self.ItemPropertyChange;
  FMultiDetail4.Owner := Self;
  FMultiDetail4.Visible := False;

  FMultiDetail1.DataMembers := TObjectAppearance.TDataMembers.Create(TObjectAppearance.TDataMember.Create(cMultiDetail1Member, Format('Data["%s"]', [TMultiDetailAppearanceNames.Detail1])));
  FMultiDetail2.DataMembers := TObjectAppearance.TDataMembers.Create(TObjectAppearance.TDataMember.Create(cMultiDetail2Member, Format('Data["%s"]', [TMultiDetailAppearanceNames.Detail2])));
  FMultiDetail3.DataMembers := TObjectAppearance.TDataMembers.Create(TObjectAppearance.TDataMember.Create(cMultiDetail3Member, Format('Data["%s"]', [TMultiDetailAppearanceNames.Detail3])));
  FMultiDetail4.DataMembers := TObjectAppearance.TDataMembers.Create(TObjectAppearance.TDataMember.Create(cMultiDetail4Member, Format('Data["%s"]', [TMultiDetailAppearanceNames.Detail4])));

  Image.DefaultValues.Width := cDefaultImageWidth;
  Image.DefaultValues.Height := cDefaultImageHeight;
  Image.RestoreDefaults;

  GlyphButton.DefaultValues.VertAlign := TListItemAlign.Center;
  GlyphButton.RestoreDefaults;

  AddObject(Text, True);
  AddObject(MultiDetail1, True);
  AddObject(MultiDetail2, True);
  AddObject(MultiDetail3, True);
  AddObject(MultiDetail4, True);
  AddObject(Image, True);
  AddObject(Accessory, True);
  AddObject(GlyphButton, IsItemEdit);
end;

constructor TMultiDetailDeleteAppearance.Create(const Owner: TControl);
begin
  inherited;
  GlyphButton.DefaultValues.ButtonType := cDefaultGlyph;
  GlyphButton.DefaultValues.Visible := True;
  GlyphButton.RestoreDefaults;
end;

constructor TMultiDetailShowCheckAppearance.Create(const Owner: TControl);
begin
  inherited;
  GlyphButton.DefaultValues.ButtonType := cDefaultGlyph;
  GlyphButton.DefaultValues.Visible := True;
  GlyphButton.RestoreDefaults;
end;

function TMultiDetailItemAppearance.DefaultHeight: Integer;
begin
  Result := cDefaultHeight;
end;

destructor TMultiDetailItemAppearance.Destroy;
begin
  FMultiDetail1.Free;
  FMultiDetail2.Free;
  FMultiDetail3.Free;
  FMultiDetail4.Free;
  inherited;
end;

procedure TMultiDetailItemAppearance.SetMultiDetail1(const Value: TTextObjectAppearance);
begin
  FMultiDetail1.Assign(Value);
end;

procedure TMultiDetailItemAppearance.SetMultiDetail2(const Value: TTextObjectAppearance);
begin
  FMultiDetail2.Assign(Value);
end;

procedure TMultiDetailItemAppearance.SetMultiDetail3(const Value: TTextObjectAppearance);
begin
  FMultiDetail3.Assign(Value);
end;

procedure TMultiDetailItemAppearance.SetMultiDetail4(const Value: TTextObjectAppearance);
begin
  FMultiDetail4.Assign(Value);
end;

procedure TMultiDetailItemAppearance.SetObjectData(const AListViewItem: TListViewItem; const AIndex: string; const AValue: TValue; var AHandled: Boolean);
begin
  inherited;

end;

function TMultiDetailItemAppearance.GetGroupClass: TPresetItemObjects.TGroupClass;
begin
  Result := TMultiDetailItemAppearance;
end;

procedure TMultiDetailItemAppearance.UpdateSizes(const FinalSize: TSizeF);
var
  LInternalWidth: Single;
  LImagePlaceOffset: Single;
  LImageTextPlaceOffset: Single;
begin
  BeginUpdate;
  try
    inherited;
    if Image.ActualWidth = 0 then
    begin
      LImagePlaceOffset := 0;
      LImageTextPlaceOffset := 0;
    end
    else
    begin
      LImagePlaceOffset := cDefaultImagePlaceOffsetX;
      LImageTextPlaceOffset := cDefaultImageTextPlaceOffsetX;
    end;
    Image.InternalPlaceOffset.X := GlyphButton.ActualWidth + LImagePlaceOffset;
    if Image.ActualWidth > 0 then
      Text.InternalPlaceOffset.X := Image.ActualPlaceOffset.X +  Image.ActualWidth + LImageTextPlaceOffset
    else
      Text.InternalPlaceOffset.X := 0 + GlyphButton.ActualWidth;
    MultiDetail1.InternalPlaceOffset.X := Text.InternalPlaceOffset.X;
    MultiDetail2.InternalPlaceOffset.X := Text.InternalPlaceOffset.X;
    MultiDetail3.InternalPlaceOffset.X := Text.InternalPlaceOffset.X;
    MultiDetail4.InternalPlaceOffset.X := Text.InternalPlaceOffset.X;
    LInternalWidth := FinalSize.Width - Text.ActualPlaceOffset.X - Accessory.ActualWidth;
    if Accessory.ActualWidth > 0 then
      LInternalWidth := LInternalWidth - cTextMarginAccessory;
    Text.InternalWidth := Max(1, LInternalWidth);
    MultiDetail1.InternalWidth := Text.InternalWidth;
    MultiDetail2.InternalWidth := Text.InternalWidth;
    MultiDetail3.InternalWidth := Text.InternalWidth;
    MultiDetail4.InternalWidth := Text.InternalWidth;
  finally
    EndUpdate;
  end;

end;

type
  TOption = TRegisterAppearanceOption;
const
  sThisUnit = 'FMX.ListView.Extension';
initialization
  TAppearancesRegistry.RegisterAppearance(TMultiDetailItemAppearance, TMultiDetailAppearanceNames.ListItem, [TRegisterAppearanceOption.Item], sThisUnit);
  TAppearancesRegistry.RegisterAppearance(TMultiDetailDeleteAppearance, TMultiDetailAppearanceNames.ListItemDelete, [TRegisterAppearanceOption.ItemEdit], sThisUnit);
  TAppearancesRegistry.RegisterAppearance(TMultiDetailShowCheckAppearance, TMultiDetailAppearanceNames.ListItemCheck, [TRegisterAppearanceOption.ItemEdit], sThisUnit);
finalization
  TAppearancesRegistry.UnregisterAppearances(TArray<TItemAppearanceObjectsClass>.Create(TMultiDetailItemAppearance, TMultiDetailDeleteAppearance,TMultiDetailShowCheckAppearance));
end.
