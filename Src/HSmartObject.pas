unit HSmartObject;

interface

uses
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
  public
    constructor Create;
    property Children: TSmartObjectSet read FChildren;
    procedure AddChild(const aObject: TSmartObject);
    procedure RemoveChild(const aObject: TSmartObject);
    procedure ChangeReferenceCount(const aDelta: Integer);
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

constructor TSmartObject.Create;
begin
  inherited Create;
  FChildren := TSmartObjectSet.Create;
  FReferenceCount := 0;
  FReferenceCountLocker := TCriticalSection.Create;
  GlobalSmartObjectSet.Insert(self);
end;

procedure TSmartObject.AddChild(const aObject: TSmartObject);
begin

end;

procedure TSmartObject.RemoveChild(const aObject: TSmartObject);
begin

end;

procedure TSmartObject.ChangeReferenceCount(const aDelta: Integer);
begin
  FReferenceCountLocker.Enter;
  FReferenceCount += aDelta;
  FReferenceCountLocker.Leave;
end;

destructor TSmartObject.Destroy;
begin
  FReferenceCountLocker.Free;
  GlobalSmartObjectSet.Delete(self);
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
  result := '';
  i := Min;
  if i <> nil then
  begin
    repeat
      o := i.Data;
      result += o.ClassName + LineEnding;
    until not i.Next;
    i.Free;
  end;
end;

procedure TSmartObjectSet.Insert(const aObject: TSmartObject);
begin
  FAddRemoveLock.Enter;
  self.Insert(aObject);
  FAddRemoveLock.Leave;
end;

procedure TSmartObjectSet.Delete(const aObject: TSmartObject);
begin
  FAddRemoveLock.Enter;
  self.Delete(aObject);
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
  GlobalSmartObjectSet := TSmartObjectSet.Create;
finalization
  GlobalSmartObjectSet.Free;
end.

