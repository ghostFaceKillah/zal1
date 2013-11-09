program test_gen;

var
  i,j : integer;

begin
  randomize;
  j := random(19);
  write(chr(j + 65 ));
  j := random(19);
  writeln(chr(j + 97 ));
  for i := 1 to 10000-1 do begin
    j := random(19);
    write(chr(j + 65 ));
    j := random(19);
    write(chr(j + 97 ));
    j := random(19);
    write(chr(j + 65 ));
    j := random(19);
    writeln(chr(j + 97 ));
  end;
end.
