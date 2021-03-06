{
  &String.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a cria��o de matrizes php-like em Delphi.
  Suporta 1 Tipo de Matriz Associativa Unidimensional Baseada em TStringList;
  Suporta 2 Tipos de Matrizes Associativas Unidimensionais Baseadas em TDicionary;
  Suporte 2 Tipos de Matrizes Associativas Multidimensional Baseadas em TDicionary;
  1 - Matriz de Strings Herdada de TStringList;
  2 - Matriz de Variants Herdada de TDictionary<Variant, Variant>
  3 - Matriz de Fields Herdade de TDictionay<Variant, TField>
  4 - Matriz de Matrizes Herdada de TDicionary<TDictionay<Variant, Variant>>
  5 - Matriz de Matrizes Herdada de TDicionary<TDictionay<Variant, TField>>
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  ------------------------------------------------------------------------------
  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la
  sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a vers�o 3.29 da Licen�a, ou (a seu crit�rio)
  qualquer vers�o posterior.
  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM
  NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU
  ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor
  do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)
  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto
  com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,
  no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Voc� tamb�m pode obter uma copia da licen�a em:
  http://www.opensource.org/licenses/lgpl-license.php

https://stackoverflow.com/questions/14274089/incompatible-char-and-widechar-in-delphi
https://github.com/eversonturossi/delphi-exemplo-sistema/blob/master/Fonte%20PAF-ECF-TEF_/Aplicativo_Gerencial/Biblioteca/UBarsa.~pas
https://stackoverflow.com/questions/4070094/create-a-constant-array-of-strings
https://stackoverflow.com/questions/1872503/how-to-assign-a-multiline-string-value-without-quoting-each-line
https://stackoverflow.com/questions/246969/is-it-possible-do-declare-a-constant-array-that-includes-another-constant-array
https://stackoverflow.com/questions/17460378/possible-to-concatenate-constant-array-of-string
https://stackoverflow.com/questions/30156172/how-to-concatenate-array-of-string-elements-into-a-string
https://stackoverflow.com/questions/17460378/possible-to-concatenate-constant-array-of-string?noredirect=1&lq=1

https://stackoverflow.com/questions/33780081/delphi-tstringlist-get-strings-as-a-quoted-comma-delimited-string
}

unit &String;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Generics.Collections,
  System.RegularExpressions,
  System.RTLConsts,
  System.Variants,
  System.Rtti,
  Data.DB,
  REST.JSON;

const
  EMPTYCHAR : Char = #0; //EmptyStr para Char
  TAB : Char = #10; //<TAB>
  ENTER : Char = #13; //<ENTER>
  SQUOTE : Char = #39; //'
  DQUOTE : Char = #34; //"
  COMMA : Char = #44; //,
  COLON : Char = #58; //:
  LTAG : Char = #60; //<
  EQUAL : Char = #61; //=
  RTAG : Char = #62; //>
  LCURLYBRACKET : Char = #123; //{
  RCURLYBRACKET : Char = #125; //}
  LSQUAREBRACKET : Char = #91; //[
  RSQUAREBRACKET : Char = #93; //]
  PIPE : Char = #124; //|
  CBAR : Char = #92; //\
  SSPACE : Char = #32; //\s
  CTAG : String = '</';
  DSPACE : String = '  '; //\s\s
  EOL : String = #13#10; //\r\n
  XML : String = '<?xml version="1.0" encoding="UTF-8"?>';
  NUL : String = 'null';
  NULER : String = '\b(\w*null|NULL\w*)\b';
  SYMBOLS = '[-()\"#\/@;:<>{}`+=~|?!@#$%^&*a-zA-Z\s]';
  NUMERIC : String = '^\-?\d{1,}$';
  DECIMAL : String = '^\d*[\,\.]?\d*$';

type
  TString = class
  private
    { Private declarations }
  public
    { Public declarations }
    class function OnlyAlpha(Text: String): String; static;
    class function OnlyValues(Text: String): String; static;
    class function OnlyNumeric(Text: String): String; static;
    class function OnlyAlphaNumeric(Text: String): String; static;
    class function IsNull(Text: String): Boolean;
    class function IsNumeric(Text: String): Boolean;
    class function IsDecimal(Text: String): Boolean;
    class function EscapeStrings(Text: String): String;
    class function FromTags(Input, Column: String): String;
    class function IsUTF8(const Text: AnsiString): boolean; static;
    class function IsAnsi(const AString: String): Boolean; static;
    class function IndentTag(Input, Replace : String): String;
    class function RemoveLastComma(Input : String): String;
    class function RemoveLastCommaEOL(Input : String): String;
    class function RemoveLastEOL(Input : String): String;
    class function RemoveSpecialChars(Text : String): String;
    class function ExtractStringBetweenDelimiters(Input: String; Delim1, Delim2: String): String;
    class function StringReplace(Text: String; OldPattern, NewPattern: TArray<String>; Flags: TReplaceFlags): String;
    class function StrArrayJoin(const StringArray: array of string; const Separator: string) : string;
    class function JoinStrings(const s: array of string; Delimiter: Char): string;
    class function Quote(Text : String; Quote: String = #39): String;
  end;

implementation

{ TString }

class function TString.OnlyAlpha(Text: String): String;
begin
  Result := Trim(TRegEx.Replace(Text, '[^\w]', ''));
end;

class function TString.OnlyValues(Text: String): String;
begin
  Result := Trim(TRegEx.Replace(Text, Symbols, ''));
end;

class function TString.Quote(Text : String; Quote: String = #39): String;
begin
  Result := Quote + Text + Quote;
end;

class function TString.OnlyNumeric(Text: String): String;
begin
  Result := Trim(TRegEx.Replace(Text, '[^\d]', ''));
end;

class function TString.OnlyAlphaNumeric(Text: String): String;
begin
  Result := Trim(TRegEx.Replace(Text, '[^\d\w]', ''));
end;

class function TString.IsNull(Text: String): Boolean;
begin
  Result := TRegEx.IsMatch(Text, NULER);
end;

class function TString.IsNumeric(Text: String): Boolean;
begin
  Result := TRegEx.IsMatch(Text, NUMERIC);
end;

class function TString.IsDecimal(Text: String): Boolean;
begin
  Result := TRegEx.IsMatch(Text, DECIMAL);
end;

{ TStringHelper }

class function TString.EscapeStrings(Text: string): string;
begin
  Result := Self.StringReplace(Text, [CBar, DQuote, NULL, TAB, ENTER], [CBAR+CBAR, CBAR+DQUOTE, EmptyStr, '\r', '\n'], [rfReplaceAll]);
end;

class function TString.StringReplace(Text: string; OldPattern, NewPattern: TArray<String>; Flags: TReplaceFlags): string;
var
  I: Integer;
begin
  Assert(Length(OldPattern) = (Length(NewPattern)));
  Result := Text;
  for I := Low(OldPattern) to High(OldPattern) do
    Result := System.SysUtils.StringReplace(Result, OldPattern[I], NewPattern[I], Flags);
end;

class function TString.ExtractStringBetweenDelimiters(Input: String; Delim1, Delim2: String): String;
var
  aPos, bPos: Integer;
begin
  result := '';
  aPos := Pos(Delim1, Input);
  if aPos > 0 then begin
    bPos := PosEx(Delim2, Input, aPos + Length(Delim1));
    if bPos > 0 then begin
      result := Copy(Input, aPos + Length(Delim1), bPos - (aPos + Length(Delim1)));
    end;
  end;
end;

class function TString.IsUTF8(const Text : AnsiString): Boolean;
begin
  Result := (Text <> '') and (UTF8ToString(Text) <> '');
end;

class function TString.IsAnsi(const AString: String): Boolean;
var
  tempansi : AnsiString;
  temp : String;
begin
  tempansi := AnsiString(AString);
  temp := String(tempansi);
  Result := temp = AString;
end;

class function TString.IndentTag(Input, Replace: String): String;
var
  Regex: TRegEx;
begin
  Regex := TRegEx.Create('^([^<]*)<(.*)', [roMultiLine]);
  Result := Regex.Replace(Input, '$1' + Replace + '<$2');
end;

class function TString.FromTags(Input, Column: String): String;
begin
  Result := Self.ExtractStringBetweenDelimiters(Input, LTAG + Column + RTAG, CTAG + Column + LTAG);
end;

class function TString.RemoveLastComma(Input: String): String;
begin
  if Input[Length(Input)-2] = Comma then
    System.Delete(Input, Length(Input)-2, 1)
  else
    System.Delete(Input, Length(Input), 1);
  Result := Input;
end;

class function TString.RemoveLastCommaEOL(Input: String): String;
begin
  if Input[Length(Input)-2] = Comma then
    System.Delete(Input, Length(Input)-2, 3)
  else
    System.Delete(Input, Length(Input)-1, 2);
  Result := Input;
end;

class function TString.RemoveLastEOL(Input: String): String;
begin
  if Input[Length(Input)-1] = EOL then
    System.Delete(Input, Length(Input)-1, 2);
  Result := Input;
end;

class function TString.RemoveSpecialChars(Text : String): String;
begin
  Result := Self.StringReplace(Text, [TAB, ENTER, EOL], [EmptyStr, EmptyStr, EmptyStr], [rfReplaceAll]);
end;

class function TString.StrArrayJoin(const StringArray: array of string; const Separator: string) : string;
var
  i : Integer;
begin
  Result := '';
  for i := low(StringArray) to high(StringArray) do
    Result := Result + StringArray[i] + Separator;
  Delete(Result, Length(Result), 1);
end;

class function TString.JoinStrings(const s: array of string; Delimiter: Char): string;
var
  i, c: Integer;
  p: PChar;
begin
  c := 0;
  for i := 0 to High(s) do
    Inc(c, Length(s[i]));
  SetLength(Result, c + High(s));
  p := PChar(Result);
  for i := 0 to High(s) do begin
    if i > 0 then begin
      p^ := Delimiter;
      Inc(p);
    end;
    Move(PChar(s[i])^, p^, SizeOf(Char)*Length(s[i]));
    Inc(p, Length(s[i]));
  end;
end;

end.
