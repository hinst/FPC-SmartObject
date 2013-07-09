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
  public
    property Head: PStringStorageBlock read FHead;
    property Tail: PStringStorageBlock read FTail;
    property TotalLength: Cardinal read FTotalLength;
    procedure Append(const s: string);
    function ToString: string;
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

procedure TStringBlock.Append(const s: string);
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

function TStringBlock.ToString: string;
var
  current: PStringStorageBlock;
  position: PChar;
  s: string;
  i: Byte;
begin
  current := Head;
  WriteLN(FTotalCount);
  SetLength(result, TotalLength);
  position := PChar(result);
  while
    current <> nil
  do
  begin
    for i := 0 to current^.Count - 1 do
    begin
      s := current^.Strings[i];
      Move(PChar(s)^, position^, Length(s));
      Inc(position, Length(s));
    end;
    current := current^.Next;
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

