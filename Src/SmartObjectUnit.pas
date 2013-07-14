unit SmartObjectUnit;

{$Define HSmartObjectDebugOutputEnabled}

interface

uses
  SysUtils,
  syncobjs,
  gset, gutil;

type

  { TSmartObject }

  TSmartObject = class
  protected
    FReferenceCount: Integer;
    FReferenceCountLocker: TCriticalSection;
    FName: string;
    procedure AutoCreateReferenceCountLocker;
    function GetReferenceCount: Integer;
  public
    property ReferenceCount: Integer read GetReferenceCount;
    property Name: string read FName write FName;
      // constructor
    constructor Create; virtual;
    procedure ChangeReferenceCount(const aDelta: Integer);
    procedure Acquire;
    procedure Release;
    function ToDebugString: string;
      // destructor
    destructor Destroy; override;
  end;

implementation

{ TSmartObject }

procedure TSmartObject.AutoCreateReferenceCountLocker;
begin
  if
    nil = FReferenceCountLocker
  then
    FReferenceCountLocker := TCriticalSection.Create;
end;

function TSmartObject.GetReferenceCount: Integer;
begin
  AutoCreateReferenceCountLocker;
  FReferenceCountLocker.Enter;
  result := FReferenceCount;
  FReferenceCountLocker.Leave;
end;

constructor TSmartObject.Create;
begin
  inherited Create;
  FReferenceCount := 0;
  FReferenceCountLocker := nil;
  FName := '';
end;

procedure TSmartObject.ChangeReferenceCount(const aDelta: Integer);
begin
  AutoCreateReferenceCountLocker;
  FReferenceCountLocker.Enter;
  FReferenceCount += aDelta;
  FReferenceCountLocker.Leave;
end;

procedure TSmartObject.Acquire;
begin
  ChangeReferenceCount(1);
end;

procedure TSmartObject.Release;
begin
  if
    self <> nil
  then
  begin
    ChangeReferenceCount(-1);
    if ReferenceCount <= 0 then
      Free;
  end;
end;

function TSmartObject.ToDebugString: string;
begin
  if
    self <> nil
  then
    result := ClassName + ' "' + Name + '"' + ' ref.cnt: ' + IntToStr(ReferenceCount)
  else
    result := 'nil instance';
end;

destructor TSmartObject.Destroy;
begin
  FReferenceCountLocker.Free;
  inherited Destroy;
end;

end.

