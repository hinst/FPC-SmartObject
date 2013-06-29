program Test_002;

uses
  HSmartObject;

procedure WriteList;
begin
  WriteLN(GetGlobalSmartObjectSet.ToDebugText);
end;

var
  a, b: TSmartObject;

begin
  WriteList;
  a := TSmartObject.Create;
  a.DebugName := 'a';
  WriteList;
  b := TSmartObject.Create;
  b.DebugName := 'b';
  WriteList;
  a.AddChild(b);
  WriteList;
  {
  a.RemoveChild(b);
  WriteLN('b removed...');
  }
  WriteList;
  a.Free;
  WriteList;
end.

