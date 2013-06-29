unit HSmartObject;

{$Define HSmartObjectDebugOutputEnabled}

interface

uses
  SysUtils,
  syncobjs,
  gset, gutil;

type

  TSmartObjectSet = class;

  { TSmartObject }

  TSmartObject = class
  protected
    FChildren: TSmartObjectSet;
    FReferenceCount: Integer;
    FReferenceCountLocker: TCriticalSection;
    FDebugName: ansistring;
    procedure ToDebugOutput(const s: string);
    procedure DereferenceChildren;
  public
    property Children: TSmartObjectSet read FChildren;
    property ReferenceCount: Integer read FReferenceCount;
    property DebugName: string read FDebugName write FDebugName;
      // constructor
    constructor Create;
    procedure AddChild(const aObject: TSmartObject);
    procedure RemoveChild(const aObject: TSmartObject);
    procedure ChangeReferenceCount(const aDelta: Integer);
    function ToDebugString: ansistring;
      // destructor
    destructor Destroy; override;
  end;

  { TCustomSmartObjectSetComparator }

  TCustomSmartObjectSetComparator = class
  public
    class function c(a, b: TSmartObject): Boolean;
  end;

  TCustomSmartObjectSet = specialize TSet<TSmartObject, TCustomSmartObjectSetComparator>;

  { TSmartObjectSet }

  TSmartObjectSet = class(TCustomSmartObjectSet)
  protected
    FAddRemoveLock: TCriticalSection;
  public
    constructor Create;
    function ToDebugText: string;
    procedure Insert(const aObject: TSmartObject); reintroduce;
    procedure Delete(const aObject: TSmartObject); reintroduce;
    destructor Destroy; override;
  end;

function GetGlobalSmartObjectSet: TSmartObjectSet;

implementation

var
  GlobalSmartObjectSet: TSmartObjectSet;

{ TSmartObject }

procedure TSmartObject.ToDebugOutput(const s: string);
begin
  {$IfDef HSmartObjectDebugOutputEnabled}
  WriteLN('TSmartObject: ', s);
  {$EndIf}
end;

procedure TSmartObject.DereferenceChildren;
var
  i: TSmartObjectSet.TIterator;
  current: TSmartObject;
begin
  i := Children.Min;
  if
    i <> nil
  then
  repeat
    current := i.Data;
    current.ChangeReferenceCount(-1);
    if
      0 = current.ReferenceCount
    then
      current.Free;
  until not i.Next;
end;

constructor TSmartObject.Create;
begin
  inherited Create;
  FChildren := TSmartObjectSet.Create;
  FReferenceCount := 0;
  FReferenceCountLocker := TCriticalSection.Create;
  FDebugName := '';
  GlobalSmartObjectSet.Insert(self);
end;

procedure TSmartObject.AddChild(const aObject: TSmartObject);
begin
  Children.Insert(aObject);
  aObject.ChangeReferenceCount(1);
end;

procedure TSmartObject.RemoveChild(const aObject: TSmartObject);
begin
  if
    FChildren.Find(aObject) <> nil
  then
  begin
    FChildren.Delete(aObject);
    aObject.ChangeReferenceCount(-1);
    if
      0 = aObject.ReferenceCount
    then
      aObject.Free;
  end;
end;

procedure TSmartObject.ChangeReferenceCount(const aDelta: Integer);
begin
  FReferenceCountLocker.Enter;
  FReferenceCount += aDelta;
  FReferenceCountLocker.Leave;
end;

function TSmartObject.ToDebugString: ansistring;
begin
  if
    self <> nil
  then
    result := ClassName + ' "' + DebugName + '"' + ' ref.cnt: ' + IntToStr(ReferenceCount)
  else
    result := 'nil instance';
end;

destructor TSmartObject.Destroy;
begin
  GlobalSmartObjectSet.Delete(self);
  FReferenceCountLocker.Free;
  DereferenceChildren;
  Children.Free;
  inherited Destroy;
end;

{ TCustomSmartObjectSetComparator }

class function TCustomSmartObjectSetComparator.c(a, b: TSmartObject): Boolean;
begin
  result := PtrUInt(a) < PtrUInt(b);
end;

{ TSmartObjectSet }

constructor TSmartObjectSet.Create;
begin
  inherited Create;
  FAddRemoveLock := TCriticalSection.Create;
end;

function TSmartObjectSet.ToDebugText: string;
var
  i: TSmartObjectSet.TIterator;
  o: TSmartObject;
begin
  result := 'Smart object list (' + IntToStr(self.Size) + ' items total):' + LineEnding;
  i := Min;
  if i <> nil then
  begin
    repeat
      o := i.Data;
      result += o.ToDebugString + LineEnding;
    until not i.Next;
    i.Free;
  end;
end;

procedure TSmartObjectSet.Insert(const aObject: TSmartObject);
begin
  FAddRemoveLock.Enter;
  inherited Insert(aObject);
  FAddRemoveLock.Leave;
end;

procedure TSmartObjectSet.Delete(const aObject: TSmartObject);
begin
  FAddRemoveLock.Enter;
  inherited Delete(aObject);
  FAddRemoveLock.Leave;
end;

destructor TSmartObjectSet.Destroy;
begin
  FAddRemoveLock.Free;
  inherited Destroy;
end;

function GetGlobalSmartObjectSet: TSmartObjectSet;
begin
  result := GlobalSmartObjectSet;
end;

initialization
  GlobalSmartObjectSet := TSmartObjectSet.Create();
finalization
  GlobalSmartObjectSet.Free;
end.

