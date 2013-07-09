program StringBlockStorageTestProject;

uses
  StringBlockUnit;

var
  s: TStringBlock;

begin
  s := TStringBlock.Create;
  s.Append('FFFUUU');
  s.Append('bubble');
  s.Append('_apple');
  s.Append('.grape.');
  s.Append('.grape.');
  s.Append('.grape.');
  s.Append('.grape.');
  s.Append('.grape.');
  s.Append('.grape.');
  s.Append('.grape.');
  s.Append('.grape.');
  s.Append('.grape.');
  s.Append('.BANANA.');
  WriteLN(s.ToString);
  s.Free;
end.

