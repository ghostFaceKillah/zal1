program connect6;

const 
  N = 's';
  M = 'S';

type
  state = (playing, x_wins, o_wins , just_started, just_end, draw);
  input_status = (good, start, bad, empty);
  direction = (nwse, nesw, horizontal, vertical, ending);
  table = array['a'..N,'A'..M] of char;
  player = (X,O);

var
  input_string : string;
  game_table : table;
  game_state : state;
  input_is : input_status;
  now_playing : player;
  move_successful : boolean;
   
function is_in_range(const input_string:string; is_start:boolean):boolean; 
  var
    resu : boolean;
  begin
    resu := true;
    if (input_string[1]>'S') or
       (input_string[1]<'A') or
       (input_string[2]>'s') or
       (input_string[2]<'a') then resu := false;
    if not(is_start) and resu then if (input_string[3]>'S') or
                                      (input_string[3]<'A') or
                                      (input_string[4]>'s') or
                                      (input_string[4]<'a') then resu := false;
    is_in_range := resu;
  end;                  

function input_analyser(const input_string:string):input_status;
  begin
    if length(input_string) = 0 then 
      input_analyser := empty
    else if (length(input_string) = 4) and is_in_range(input_string, false) then
      input_analyser := good
    else if (length(input_string) = 2) and is_in_range(input_string, true) then
      input_analyser := start
    else 
      input_analyser := bad;
  end;

procedure init_table(var game_table:table);
  var
    i,j : char;
  begin
    for i := 'a' to N do
      for j := 'A' to M do
        game_table[i,j] := '.';
  end;

procedure show_table(game_table:table; now_playing:player; game_state:state);
  var
    i,j : char;
    k : integer;
  begin
    for k := 1 to 38 do write('-');
    writeln('+');
    for i := N downto 'a' do begin 
      write(i, game_table[i,'A']);
      for j := 'B' to M do
        write(' ', game_table[i,j]);
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
      writeln('wygral X')
    else if game_state = o_wins then
      writeln('wygral O')
    else if game_state = draw then
      writeln('remis');
  end;

procedure switch_player(var now_playing:player);
  begin 
    if now_playing = X then now_playing := O else now_playing := X;
  end;

procedure insert_value(i:integer; input_string:string; now_playing:player; 
                      var game_table:table);
  begin
    if now_playing = X then
      game_table[input_string[i+1], input_string[i]] := 'X'
    else
      game_table[input_string[i+1], input_string[i]] := 'O'
  end;
  
function make_move(this_move_is:input_status; now_playing:player;
                   input_string:string; var game_table:table): boolean;
                   // WARNING : side effects in a func
  var
    resu : boolean;
  begin
    if this_move_is = start then begin
      if  game_table[input_string[2], input_string[1]] = '.' then begin
        insert_value(1, input_string, now_playing, game_table);
        resu := true;
      end else resu := false;
    end
    else begin
      if  (game_table[input_string[2], input_string[1]] = '.') and
          (game_table[input_string[4], input_string[3]] = '.') and
          ((input_string[4] <> input_string[2]) or
            (input_string[1] <> input_string[3])) then begin
        insert_value(1, input_string, now_playing, game_table);
        insert_value(3, input_string, now_playing, game_table);
        resu := true;
      end else resu := false;
    end;
    make_move := resu;
  end;

procedure horizontal_indices (var i,j:char; var finished, new_line:boolean);
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

procedure nw_diagonal_indices (var i, j:char; var finished, new_line:boolean);
  // please observe that elements on a given diagonal have same sum for example 
  // the sum of distance from a to C and a are same as sum of distance to B and b to a
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
          if (ord(i) + ord(j)) >= (ord('s') + ord('A')) then begin 
            // we are on the upside of diagonal
            j := chr( ord(i) + 2 - ord('a') + ord('A') );
            i := 's';
          end
          else begin 
            // we are on the downside of the diagonal
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

procedure ne_diagonal_indices (var i, j:char; var finished, new_line:boolean);
  begin
    if (i = 'z') and (j = 'z') then begin
      new_line := true;
      finished := false;
      i := 's';    
      j := 'A';
    end 
    else begin
      dec(i);
      dec(j);
      if (i < 'a') or (j < 'A') then begin
        if (ord(i) - ord(j) - 1) <= (ord('a') - ord('S') + 2) then
          finished := true
        else begin
          finished := false;
          new_line := true;
          if (ord(i) - ord(j)) > (ord('a') - ord('A')) then begin 
            // upside of the diagonal
            j := chr(ord('A') +  ord('s') - ord(i) )  ;
            i := 's';
          end
          else begin 
            i := chr( ord('s') - 2 -  ord(j) + ord('A'));
            j := 'S';
            // we are on the downside of the diagonal
          end;
        end;
      end
      else begin
        new_line := false;
        finished := false;
      end;
    end;
  end;

procedure get_next_index (iter_func_num:direction;
                          var i, j:char; var finished, new_line:boolean);
  begin
    case iter_func_num of
    nwse : nw_diagonal_indices (i, j, finished, new_line);
    nesw : ne_diagonal_indices (i, j, finished, new_line);
    vertical : vertical_indices(i,j,finished, new_line);
    horizontal : horizontal_indices(i,j,finished, new_line);
    end;
  end;

function next(current:direction) : direction;
  begin
    case current of
      nwse : next := nesw;
      nesw : next := vertical;
      vertical : next := horizontal;
      horizontal : next := ending;
    end;
  end;

function did_someone_win(game_table:table):state;
  // naiive approach as 4 directions * 19 rows * 19 cols =~ 1600 only lookups
  var
    i,j : char;
    resu_state : state;
    finished : boolean;
    just_looked_at : char;
    new_line : boolean;
    counter : integer;
    iter_func : direction;
  begin
    resu_state := playing;
    finished := false;
    iter_func := nwse;
    new_line := true;
    while (iter_func <> ending) and (resu_state = playing) do begin
      i := 'z';
      j := 'z';  // this means we want to get beginning indices
      get_next_index(iter_func, i, j, finished, new_line);
      while (resu_state = playing) and not(finished) do begin
        if new_line then begin
          just_looked_at := '.'; 
          counter := 1;
        end;
        if game_table[i,j] = just_looked_at then begin
          inc(counter);
        end
        else 
          counter := 1;
        just_looked_at := game_table[i,j];
        if counter >= 6 then 
          if just_looked_at = 'X' then
            resu_state := x_wins
          else if just_looked_at = 'O' then
            resu_state := o_wins;
        get_next_index(iter_func, i, j, finished, new_line);
      end;
      iter_func := next(iter_func);
      // standard inc is ok with normal compilation and 
      // throws exceptions when using fpc -Ciort -vw -gl
      // and _this_makes_me_a_sad_panda
    end;
    did_someone_win := resu_state;
  end;

function is_draw(game_table:table):state;
  var
    i,j:char;
    resu:state;
  begin
    resu := draw;
    i := 'a';
    while (i <= N) and (resu = draw) do begin
      j := 'A';
      while (j <= M) and (resu = draw) do begin
        if game_table[i,j] = ',' then 
          resu := playing;
        inc(j);
      end;
      inc(i);
    end;
    is_draw := playing;
  end;

begin 
  init_table(game_table);
  game_state := just_started;
  now_playing := X;
  show_table(game_table, now_playing, game_state);
  while (game_state = playing) or (game_state = just_started) do begin
    readln(input_string);
    input_is := input_analyser(input_string);
    if input_is = empty then
      game_state := just_end
    else if ((input_is = start) and (game_state = just_started)) or
            ((input_is = good) and (game_state = playing)) then begin
      move_successful := make_move(input_is, now_playing, input_string,
                                   game_table);
      if move_successful then begin
        switch_player(now_playing);
        game_state := did_someone_win(game_table);
        if game_state = playing then 
          game_state := is_draw(game_table);
      end
    end;
      if not(game_state = just_end) then
        show_table(game_table, now_playing, game_state);
  end; 
end.
