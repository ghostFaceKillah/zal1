program connect6;

uses
  sysUtils;

const 
  N = 's';
  M = 'S';

type
  state = ( playing, x_wins, o_wins , just_started,  just_end, draw);
  input_status = (good,start,bad,empty);
  table = array['a'..N,'A'..M] of char;
  player = (X,O);

var
  napis : string;
  plansza : table;
  game_state : state;
  input_is : input_status;
  now_playing : player;
  move_successful : boolean;
   
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
      input_analyser := start
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

procedure showTable(plansza:table; now_playing:player; game_state:state);
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
    if game_state = just_started then
      writeln('gracz X') 
    else if game_state = playing then
      writeln('gracz ', now_playing)
    else if game_state = draw then
      writeln('gracz ', now_playing)
    else if game_state = x_wins then
      writeln('wygral x')
    else if game_state = o_wins then
      writeln('wygral O')
    else if game_state = draw then
      writeln('remis');
  end;

procedure switch_player(var now_playing:player);
  begin 
    if now_playing = X then now_playing := O else now_playing := X;
  end;

procedure insertValue(i:integer; napis:string; now_playing:player; var plansza:table);
  begin
    if now_playing = X then
      plansza[napis[i+1], napis[i]] := 'X'
    else
      plansza[napis[i+1], napis[i]] := 'O'
  end;
  
function make_move(this_move_is:input_status; now_playing:player;
                   napis:string; var plansza:table): boolean;
  var
    resu : boolean;
  begin
    if this_move_is = start then begin
      if  plansza[napis[2], napis[1]] = '.' then begin
        insertValue(1, napis, now_playing, plansza);
        resu := true;
      end else resu := false;
    end
    else begin
      if  (plansza[napis[2], napis[1]] = '.') and
          (plansza[napis[4], napis[3]] = '.') and
          ((napis[4] <> napis[2]) or (napis[1] <> napis[3])) then begin
        insertValue(1, napis, now_playing, plansza);
        insertValue(3, napis, now_playing, plansza);
        resu := true;
      end else resu := false;
    end;
    make_move := resu;
  end;

procedure horizontal_indices (var i, j:char; var finished, new_line:boolean);
  begin
    finished := false;
    if (i = 'z') and (j = 'z') then begin
      i := 'a'; 
      j := 'A';
      new_line := true;
    end else begin
      inc(j);
      if j > 'S' then begin
        inc(i);
        if i > 's' then 
          finished := true
        else begin
          new_line := true;
          j := 'A'
        end;
      end
      else
        new_line := false;
    end;
  end;

procedure vertical_indices (var i, j:char; var finished, new_line:boolean);
  begin
    finished := false;
    if (i = 'z') and (j = 'z') then begin
      i := 'a'; 
      j := 'A';
      new_line := true;
    end else begin
      inc(i);
      if i > 's' then begin
        inc(j);
        if j > 'S' then 
          finished := true
        else begin
          new_line := true;
          i := 'a'
        end;
      end
      else
        new_line := false;
    end;
  end;

procedure ne_diagonal_indices (var i, j:char; var finished, new_line:boolean);
  begin
    if (i = 'z') and (j = 'z') then begin
      new_line := true;
      finished := false;
      i := 'f';    
      j := 'A';
    end 
    else begin
      dec(i);
      inc(j);
      if (i < 'a') or (j > 'S') then begin
        if (ord(i) + ord(j) + 1) > ( ord('s') + ord('P')) then
          finished := true
        else begin
          finished := false;
          new_line := true;
          if (ord(i) + ord(j)) >= (ord('s') + ord('A')) then begin // we are on the upside of diagonal
            j := chr( ord(i) + 2 - ord('a') + ord('A') );
            i := 's';
          end
          else begin  // we are on the downside of the diagonal
            i := chr( ord(i) + ord(j)  + 1 - ord('A') );
            j := 'A';
          end;
        end;
      end
      else begin
        new_line := false;
        finished := false;
      end;
    end;
  end;

function new_game_state(plansza:table):state;
 // podejscie naiwne - wykonujemy tylko 4* 19^2 =~ 1600 operacji, więc dla
 // komputera nie jest to dużo
  var
    i,j : char;
    resu_state : state;
    finished : boolean;
    just_looked_at : char;
    new_line : boolean;
    counter : integer;
    k : integer;
  begin
    resu_state := playing;
    finished := false;
    k := 1;
    while (k <= 3) and (resu_state = playing) do begin
      i := 'z';
      j := 'z';  // this means we want to get beginning indices
      new_line := true;
      case k of                        /// get first index of this indexing
        1 : horizontal_indices(i,j,finished, new_line);
        2 : vertical_indices(i,j,finished, new_line);
        3 : ne_diagonal_indices (i, j, finished, new_line);
      end;
      while (resu_state = playing) and not(finished) do begin
        if new_line then begin
          just_looked_at := '.'; 
          counter := 1;
        end;
        if plansza[i,j] = just_looked_at then begin
          inc(counter);
        end
        else 
          counter := 1;
        just_looked_at := plansza[i,j];
        if counter >= 6 then 
          if just_looked_at = 'X' then
            resu_state := x_wins
          else if just_looked_at = 'O' then
            resu_state := o_wins;
        case k of  // get next index of this iteration style
          1 : horizontal_indices(i,j,finished, new_line);
          2 : vertical_indices(i,j,finished, new_line);
          3 : ne_diagonal_indices (i, j, finished, new_line);
        end;
      end;
      inc(k);
    end;
    new_game_state := resu_state;
  end;

begin 
   
  init_table(plansza);
  game_state := just_started;
  now_playing := X;
  showTable(plansza, now_playing, game_state);

  // state = ( playing, x_wins, y_wins , just_started,  just_end, draw); 

  while (game_state = playing) or (game_state = just_started) do begin
    readln(napis);
    input_is := input_analyser(napis);
    if input_is = empty then
      game_state := just_end
    else if ((input_is = start) and (game_state = just_started)) or
            ((input_is = good) and (game_state = playing)) then begin
      move_successful := make_move(input_is, now_playing, napis, plansza);
      if move_successful then begin
        game_state := new_game_state(plansza);
        switch_player(now_playing);
      end
    end;
      showTable(plansza, now_playing, game_state);
  end; 
end.
