unit SmartStringUnit;

interface

const
  StringStorageBlockLength = 6;

type
  PStringStorageBlock = ^TStringStorageBlock;

  { TStringStorageBlock }

  TStringStorageBlock = object
  public
    Previous, Next: PStringStorageBlock;
    Strings: array[0..StringStorageBlockLength - 1] of string;
    Count: Byte;
    function Add(const s: string): Boolean;
  end;

  { TStringStorage }

  TStringStorage = class
  protected
    FLeft, FRight: PStringStorageBlock;
    function CreateNewStorabeBlock: PStringStorageBlock;
  public
    property Left: PStringStorageBlock read FLeft;
    property Right: PStringStorageBlock read FRight;
    procedure Append(const s: string);
  end;

implementation

{ TStringStorageBlock }

function TStringStorageBlock.Add(const s: string): Boolean;
begin
  result := Count < StringStorageBlockLength;
  if
    result
  then
  begin
    Strings[Count] := s;
    Inc(Count);
  end;
end;

{ TStringStorage }

function TStringStorage.CreateNewStorabeBlock: PStringStorageBlock;
begin
  New(result);
  result^.Count := 0;
end;

procedure TStringStorage.Append(const s: string);
begin
  if
    nil = Right
  then
  begin
    FRight := CreateNewStorabeBlock;
    FRight^.Next := nil;
    FRight^.Previous := nil;
  end;
end;

end.

