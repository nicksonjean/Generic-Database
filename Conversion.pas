unit Conversion;

{$WARNINGS OFF}
{$HINTS OFF}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.RTLConsts,
  System.Variants,
  System.RegularExpressions,
  Data.DB;

{$REGION 'TConvert'}
type
  TConvert = record
  private
    { Private declarations }
  public
    { Public declarations }
    function StringReplaceExt(const S: string; OldPattern, NewPattern: array of string; Flags: TReplaceFlags): string;
    function ExtractStringBetweenDelims(Input: String; Delim1, Delim2: String): String;
    function EscapeStr(const UnescapedStr: string): string;
{$HINTS OFF}
{$WARNINGS OFF}
    function GetFieldTypeForValue(Field: TField): string;
{$HINTS ON}
{$WARNINGS ON}
    function VarToStr(Value : Variant) : String;
    function ToTag(const Input, Column: String): String;
    function isNumeric(const Input: String) : Boolean;
    function isDecimal(const Input: String) : Boolean;
  end;
{$ENDREGION}

var
  Convert: TConvert;

implementation

{ TConvert }

{$REGION 'TConvert'}
function TConvert.StringReplaceExt(const S: string; OldPattern, NewPattern: array of string; Flags: TReplaceFlags): string;
var
  i: integer;
begin
  Assert(Length(OldPattern) = (Length(NewPattern)));
  Result := S;
  for i := Low(OldPattern) to High(OldPattern) do
  begin
    Result := StringReplace(Result, OldPattern[i], NewPattern[i], Flags);
  end;
end;

function TConvert.ExtractStringBetweenDelims(Input: String; Delim1, Delim2: String): String;
var
  Pattern: String;
  RegEx: TRegEx;
  Match: TMatch;
begin
  Result := '';
  Pattern := Format('%s(.*?)%s', [Delim1, Delim2]);
  RegEx := TRegEx.Create(Pattern);
  Match := RegEx.Match(Input);
  if Match.Success and (Match.Groups.Count > 1) then
    Result := Match.Groups[1].Value;
end;

function TConvert.EscapeStr(const UnescapedStr: string): string;
begin
  Result := Self.StringReplaceExt(UnescapedStr, ['\', #34, #0, #10, #13, #26, ';'], ['\\', '\'#34, '\0', '\n', '\r', '\Z', '\;'], [rfReplaceAll]);
end;

function TConvert.GetFieldTypeForValue(Field: TField): string;
var
  FmtSet: TFormatSettings;
  I: integer;
  I64: int64;
  D: double;
  Cur: currency;
  DT: TDateTime;
begin
  if Field.IsNull then
    if (Field.DataType = ftDate) then
      Result := '0000-00-00'
    else
      Result := 'NULL'
  else
  begin
    case Field.DataType of
      ftSmallint, ftWord, ftInteger:
        begin
          I := Field.AsInteger;
          Result := IntToStr(i);
          Result := StringReplace(Result, #0, '', [rfReplaceAll]);
        end;
      ftLargeint:
        begin
          I64 := TLargeintField(Field).AsLargeInt;
          Result := IntToStr(i64);
        end;
      ftFloat:
        begin
          D := Field.AsFloat;
          FmtSet.DecimalSeparator := '.';
          Result := FloatToStr(D, FmtSet);
        end;
      ftBCD:
        begin
          Cur := Field.AsCurrency;
          FmtSet.DecimalSeparator := '.';
          Result := CurrToStr(Cur, FmtSet);
        end;
      ftFMTBcd:
        begin
          Result := Field.AsString;
          if FormatSettings.DecimalSeparator <> '.' then
            Result := StringReplace(Result, FormatSettings.DecimalSeparator, '.', []);
        end;
      ftBoolean:
        begin
          Result := BoolToStr(Field.AsBoolean, False);
        end;
      ftDate:
        begin
          DT := Field.AsDateTime;
          FmtSet.DateSeparator := '-';
          Result := QuotedStr(FormatDateTime('yyyy-mm-dd', DT, FmtSet));
        end;
      ftTime:
        begin
          DT := Field.AsDateTime;
          FmtSet.TimeSeparator := ':';
          Result := QuotedStr(FormatDateTime('hh:nn:ss', DT, FmtSet));
        end;
      ftDateTime:
        begin
          DT := Field.AsDateTime;
          FmtSet.DateSeparator := '-';
          FmtSet.TimeSeparator := ':';
          Result := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', DT, FmtSet));
        end;
    else
      Result := QuotedStr(Self.EscapeStr(Field.Value));
    end;
  end;
end;

function TConvert.VarToStr(Value: Variant): String;
begin
  case TVarData(Value).VType of
    varWord,
    varShortInt,
    varSmallInt,
    varInteger :
      Result := IntToStr(Value);
    varInt64 :
      Result := UIntToStr(Value);
    varSingle,
    varDouble,
    varCurrency :
      Result := FloatToStr(Value);
    varDate :
      Result := QuotedStr(FormatDateTime('yyyy-mm-dd', Value));
    varBoolean :
      if Value then
        Result := 'True'
      else
        Result := 'False';
    varString,
    varUString :
      if Self.isNumeric(Value) or Self.isDecimal(Value) then
        Result := Value
      else
        Result := QuotedStr(Value);
    else
      Result := QuotedStr(Value);
  end;
end;

function TConvert.ToTag(const Input, Column: String): String;
begin
  Result := Self.ExtractStringBetweenDelims(Input, '<' + Column + '>', '</' + Column + '>');
end;

function TConvert.isNumeric(const Input: String) : Boolean;
begin
  Result := TRegEx.IsMatch(Input, '^\-?\d{1,}$');
end;

function TConvert.isDecimal(const Input: String) : Boolean;
begin
  Result := TRegEx.IsMatch(Input, '^\s*[-+]?[0-9]*\.?[0-9]+\s*$');
end;
{$ENDREGION}

{$WARNINGS ON}
{$HINTS ON}

end.