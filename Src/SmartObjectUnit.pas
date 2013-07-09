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
    function GetReferenceCount: Integer;
  public
    property ReferenceCount: Integer read GetReferenceCount;
    property Name: string read FName write FName;
      // constructor
    constructor Create;
    procedure ChangeReferenceCount(const aDelta: Integer);
    procedure Acquire;
    procedure Release;
    function ToDebugString: string;
      // destructor
    destructor Destroy; override;
  end;

implementation

{ TSmartObject }

function TSmartObject.GetReferenceCount: Integer;
begin
  FReferenceCountLocker.Enter;
  result := FReferenceCount;
  FReferenceCountLocker.Leave;
end;

constructor TSmartObject.Create;
begin
  inherited Create;
  FReferenceCount := 0;
  FReferenceCountLocker := TCriticalSection.Create;
  FName := '';
end;

procedure TSmartObject.ChangeReferenceCount(const aDelta: Integer);
begin
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
  ChangeReferenceCount(-1);
  if ReferenceCount <= 0 then
    Free;
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

