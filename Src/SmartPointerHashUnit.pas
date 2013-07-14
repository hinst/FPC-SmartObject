unit SmartPointerHashUnit;

{$OverflowChecks OFF}

interface

function hash(const aPointer: Pointer): PtrUInt;

implementation

function hash(const aPointer: Pointer): PtrUInt;
begin
  result := PtrUInt(aPointer);
  result := (not result) + (result shl 15);
  result := result xor (result shr 12);
  result := result + (result shl 2);
  result := result xor (result shr 4);
  result := result * 2057;
  result := result xor (result shr 16);
end;

end.

