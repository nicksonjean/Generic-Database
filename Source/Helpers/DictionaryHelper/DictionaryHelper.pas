﻿  { Classe para Facilitar a Manipulação de TDictionary }

unit DictionaryHelper;

interface

uses
  SysUtils,
  Generics.Collections,
  System.Rtti;

  { Classe para Facilitar a Manipulação de TDictionary }
type
  TDictionaryHelper<Key, Value> = class(TDictionary<Key, Value>)
  public
    constructor Create(const Values: TArray<Variant>);
    class function P(const K: Key; const V: Value): TPair<Key, Value>;
    class function Make(Init: TArray<TPair<Key, Value>>): TDictionary<Key, Value>; overload;
    class function Make(KeyArray: TArray<Key>; ValueArray: TArray<Value>): TDictionary<Key, Value>; overload;
  end;

implementation

{ TDictionaryHelper<Key, Value> }

constructor TDictionaryHelper<Key, Value>.Create(const Values: TArray<Variant>);
var
  I: Integer;
  K, V: TValue;
  KT: Key;
  VT: Value;
begin
  inherited Create(Length(values) div 2);
  I := Low(Values);
  while I <= High(Values)  do
  begin
    K := TValue.FromVariant(Values[I]);
    V := TValue.FromVariant(Values[I + 1]);
    KT := K.AsType<Key>;
    VT := V.AsType<Value>;
    Add(KT, VT);
    Inc(I, 2);
  end;
end;

class function TDictionaryHelper<Key, Value>.Make(Init: TArray<TPair<Key, Value>>): TDictionary<Key, Value>;
var
  P: TPair<Key, Value>;
begin
  Result := TDictionary<Key, Value>.Create;
  for P in init do
    Result.AddOrSetValue(P.Key, P.Value);
end;

class function TDictionaryHelper<Key, Value>.Make(KeyArray: TArray<Key>; ValueArray: TArray<Value>): TDictionary<Key, Value>;
var
  I: Integer;
begin
  if Length(KeyArray) <> Length(ValueArray) then
    raise Exception.Create('O número de chaves não corresponde ao número de valores.');
  Result := TDictionary<Key, Value>.Create;
  for I := 0 to High(KeyArray) do
    Result.AddOrSetValue(KeyArray[I], ValueArray[I]);
end;

class function TDictionaryHelper<Key, Value>.P(const K: Key; const V: Value): TPair<Key, Value>;
begin
  Result := TPair<Key, Value>.Create(K, V);
end;

end.