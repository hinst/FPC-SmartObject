program Test_001;

uses
  SmartObjectUnit;

var
  obj: TSmartObject;

begin
  obj := TSmartObject.Create;
  obj.Acquire;
  WriteLN(obj.ReferenceCount);
  obj.Release;
end.

