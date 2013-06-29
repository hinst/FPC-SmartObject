program Test_001;

uses
  HSmartObject;

var
  obj: TSmartObject;

begin
  WriteLN(GetGlobalSmartObjectSet.ToDebugText);
  obj := TSmartObject.Create;
  WriteLN(GetGlobalSmartObjectSet.ToDebugText);
  obj.Free;
  WriteLN(GetGlobalSmartObjectSet.ToDebugText);
end.

