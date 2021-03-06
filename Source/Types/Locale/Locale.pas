﻿{
  Locale Class.
  ------------------------------------------------------------------------------
  Objetivo : Obter as Configuração de Locale do Windows em Delphi.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  Co-Autor : Wellington Fonseca
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

  https://stackoverflow.com/questions/11469844/getting-locale-format-for-windows
  https://stackoverflow.com/questions/44039283/delphi-decimal-separator-issue
}

unit Locale;

interface

uses
  System.SysUtils,
  Winapi.Windows
  ;

type
  TLocale = class
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    { Protected declarations }
    class function GetWindowsLocale(LCTYPE: LCTYPE): String;
  end;

implementation

{ TFetchLocale }

class function TLocale.GetWindowsLocale(LCTYPE: LCTYPE): String;
var
  Buffer: PChar;
  Size: Integer;
begin
  Size := GetLocaleInfo(LOCALE_USER_DEFAULT, LCTYPE, nil, 0);
  GetMem(Buffer, Size);
  try
    GetLocaleInfo(LOCALE_USER_DEFAULT, LCTYPE, Buffer, Size);
    Result := String(Buffer);
  finally
    FreeMem(Buffer);
  end;
end;

end.