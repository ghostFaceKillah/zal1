program connect6;

const 
  N = 's';
  M = 'S';

type
  input_status = (good,good_start,bad,empty);
  table = array['a'..N,'A'..M] of char;

var
         napis : string;
       plansza : table;
      end_game : boolean;
  just_started : boolean;
      input_is : input_status;
   
function is_valid(const napis:string; is_start:boolean):boolean; 
  var
    resu:boolean;
  begin
    resu := true;
    if (napis[1]>'S') or
       (napis[1]<'A') or
       (napis[2]>'s') or
       (napis[2]<'a') then resu := false;
    if not(is_start) and resu then if (napis[3]>'S') or
                                      (napis[3]<'A') or
                                      (napis[4]>'s') or
                                      (napis[4]<'a') then resu := false;
    is_valid := resu;
  end;                  

function input_analyser(const napis:string):input_status;
  begin
    if length(napis) = 0 then 
      input_analyser := empty
    else if (length(napis) = 4) and is_valid(napis, false) then
      input_analyser := good
    else if (length(napis) = 2) and is_valid(napis, true) then
      input_analyser := good_start
    else 
      input_analyser := bad;
  end;

procedure init_table(var plansza:table);
  var
    i,j:char;
  begin
    for i := 'a' to N do
      for j := 'A' to M do
        plansza[i,j] := '.';
  end;

procedure showTable(plansza:table);
  var
    i,j:char;
    k:integer;
  begin
    for k := 1 to 38 do write('-');
    writeln('+');

    for i := N downto 'a' do begin 
      write(i, plansza[i,'A']);
      for j := 'B' to M do
        write(' ', plansza[i,j]);
      writeln('|')
    end;

    for j := 'A' to M do write(' ',j);
    writeln('|');
  end;

// procedure makeMove(this_move_is:input_status, player:gracz, napis:string; var plansza:tablica);

// procedure switchPlayer(now_playing:player);


begin 
  
  init_table(plansza);
  showTable(plansza);
  end_game := false;
  just_started := true;

  while not(end_game) do begin
    readln(napis);
    input_is := input_analyser(napis);
    if input_is = empty then
      end_game := true
    else if ((input_is = good_start) and just_started) or
            ((input_is = good) and not(just_started)) then begin
      // makeMove(input_is, x, napis, plansza);
      showTable(plansza);
      if input_is = good_start then 
        just_started := false;
    end
    else
      showTable(plansza);
  end;
end.
