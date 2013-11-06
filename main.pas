program connect6;

type
  input_status = (good,bad,empty);

var
  napis : string;
  
function input_analyser(const napis:string ) : input_status;
  begin
    if length(napis) = 0 then 
      input_analyser := empty
    else if length(napis) <> 4 then
      input_analyser := bad
    else begin
      if napis[

    end;
  end;

begin 
   while true do begin
    readln(napis);
    writeln(napis[1]);
    writeln(input_analyser(napis));
  end;
end.
