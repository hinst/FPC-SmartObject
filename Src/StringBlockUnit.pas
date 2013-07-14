unit StringBlockUnit;

interface

uses
  SmartObjectUnit;

const
  StringStorageBlockLength = 3;

type
  PStringStorageBlock = ^TStringStorageBlock;

  { TStringStorageBlock }

  TStringStorageBlock = object
  protected
    procedure UnsafeAdd(const s: string);
  public
    Previous, Next: PStringStorageBlock;
    Strings: array[0..StringStorageBlockLength - 1] of string;
    Count: Byte;
    function Add(const s: string): Boolean;
  end;

  { TStringBlock }

  TStringBlock = class(TSmartObject)
  protected
    FHead, FTail: PStringStorageBlock;
    FTotalLength, FTotalCount: Cardinal;
    function CreateNewStorageBlock: PStringStorageBlock;
    function CreateNewStorageBlock(const s: string): PStringStorageBlock;
    procedure UpdateCounters(const s: string);
    procedure MoveString(var p: PChar; const s: string);
  public
    property Head: PStringStorageBlock read FHead;
    property Tail: PStringStorageBlock read FTail;
    property TotalLength: Cardinal read FTotalLength;
    procedure Add(const s: string);
    function ToString(const aSeparator: string): string;
    destructor Destroy; override;
  end;

implementation

{ TStringStorageBlock }

procedure TStringStorageBlock.UnsafeAdd(const s: string);
begin
  Strings[Count] := s;
  Inc(Count);
end;

function TStringStorageBlock.Add(const s: string): Boolean;
begin
  result := Count < StringStorageBlockLength;
  if
    result
  then
    UnsafeAdd(s);
end;

{ TStringBlock }

function TStringBlock.CreateNewStorageBlock: PStringStorageBlock;
begin
  New(result);
  result^.Count := 0;
  result^.Previous := nil;
  result^.Next := nil;
end;

function TStringBlock.CreateNewStorageBlock(const s: string): PStringStorageBlock;
begin
  result := CreateNewStorageBlock();
  result^.Add(s);
end;

procedure TStringBlock.UpdateCounters(const s: string);
begin
  Inc(FTotalLength, Length(s));
  Inc(FTotalCount);
end;

procedure TStringBlock.MoveString(var p: PChar; const s: string);
begin
  if
    s <> ''
  then
  begin
    Move(PChar(s)^, p^, Length(s));
    Inc(p, Length(s));
  end;
end;

procedure TStringBlock.Add(const s: string);
begin
  if
    nil = Tail
  then
  begin
    FTail := CreateNewStorageBlock;
    FHead := Tail;
  end;
  UpdateCounters(s);
  if
    Tail^.Add(s)
  then
    //okay
  else
  begin
    Tail^.Next := CreateNewStorageBlock(s);
    FTail := Tail^.Next;
  end;
end;

function TStringBlock.ToString(const aSeparator: string): string;
var
  current, next: PStringStorageBlock;
  position: PChar;
  i, n: Byte;
begin
  current := Head;
  SetLength(result, TotalLength + Length(aSeparator) * (FTotalCount - 1));
  position := PChar(result);
  while
    current <> nil
  do
  begin
    next := current^.Next;
    n := current^.Count - 1;
    for i := 0 to n do
    begin
      MoveString(position, current^.Strings[i]);
      if
        (i <> n) or (next <> nil)
      then
        MoveString(position, aSeparator);
    end;
    current := next;
  end;
  position^ := #0;
end;

destructor TStringBlock.Destroy;
var
  current, next: PStringStorageBlock;
begin
  current := Head;
  while
    current <> nil
  do
  begin
    next := current^.Next;
    Dispose(current);
    current := next;
  end;
  inherited Destroy;
end;

end.

