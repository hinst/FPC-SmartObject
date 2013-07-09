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
  s.Append('11');
  s.Append('22');
  s.Append('33');
  s.Append('44');
  WriteLN(s.ToString(''));
  WriteLN(s.ToString('-'));
  s.Free;
end.

