program connect6;

const 
  N = 'a';
  N_END = 's';
  M = 'A';
  M_END = 'S';
  GET_FIRST_INDEX = '*';
  NOTHING = '.';         // this is in the array if nothing is there
  EVERYTHING = NOTHING;  // for Zen purposes only

type
  state = (playing, x_wins, o_wins , just_started, just_end, draw);
  input_status = (good, start, bad, empty);
  direction = (nwse, nesw, horizontal, vertical, ending);
  table = array[N..N_END,M..M_END] of char;
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
    if (input_string[1]>M_END) or
       (input_string[1]<M) or
       (input_string[2]>N_END) or
       (input_string[2]<N) then resu := false;
    if not(is_start) and resu then if (input_string[3]>M_END) or
                                      (input_string[3]<M) or
                                      (input_string[4]>N_END) or
                                      (input_string[4]<N) then resu := false;
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
    for i := N to N_END do
      for j := M to M_END do
        game_table[i,j] := NOTHING;
  end;

procedure show_table(game_table:table; now_playing:player; game_state:state);
  var
    i,j : char;
    k : integer;
  begin
    for k := 1 to 38 do write('-');
    writeln('+');
    for i := N_END downto N do begin 
      write(i, game_table[i,M]);
      for j := chr(ord(M)+1) to M_END do
        write(' ', game_table[i,j]);
      writeln('|')
    end;
    for j := M to M_END do write(' ',j);
    writeln('|');
    if game_state = just_started then
      writeln('gracz X') 
    else if game_state = playing then
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
  // WARNING : side effects in a func - we are changing game_table.
  // make_move gets an input string in a valid format and tries to
  // make a move based on it. returns true only if it was a valid move
  var
    resu : boolean;
  begin
    if this_move_is = start then begin
      if  game_table[input_string[2], input_string[1]] = NOTHING then begin
        insert_value(1, input_string, now_playing, game_table);
        resu := true;
      end else resu := false;
    end
    else begin
      if  (game_table[input_string[2], input_string[1]] = NOTHING) and
          (game_table[input_string[4], input_string[3]] = NOTHING) and
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
  // this takes current indices and returns new indices pair when looking
  // for winning 6 streak in horizontal lines
  begin
    finished := false;
    if (i = GET_FIRST_INDEX) and (j = GET_FIRST_INDEX) then begin
      i := N; 
      j := M;
      new_line := true;
    end else begin
      inc(j);
      if j > M_END then begin
        inc(i);
        if i > N_END then 
          finished := true
        else begin
          new_line := true;
          j := M
        end;
      end
      else
        new_line := false;
    end;
  end;

procedure vertical_indices (var i, j:char; var finished, new_line:boolean);
  // this iterates indices while looking for vertical winning 6 streak
  begin
    finished := false;
    if (i = GET_FIRST_INDEX) and (j = GET_FIRST_INDEX) then begin
      i := N; 
      j := M;
      new_line := true;
    end else begin
      inc(i);
      if i > N_END then begin
        inc(j);
        if j > M_END then 
          finished := true
        else begin
          new_line := true;
          i := N
        end;
      end
      else
        new_line := false;
    end;
  end;

procedure nw_diagonal_indices (var i, j:char; var finished, new_line:boolean);
  // this iterates indices while looking for (nw->se)-diagonal winning 6 streak
  // please observe that elements on a given diagonal line have same ord sum
  // ex. ord('a') + ord('C') = ord('b') + ord('B')
  begin
    if (i = GET_FIRST_INDEX) and (j = GET_FIRST_INDEX) then begin
      new_line := true;
      finished := false;
      i := chr(ord(N)+ 5);  // we skip some beginning lines shorter than 6
      j := M;
    end 
    else begin
      dec(i);
      inc(j);
      if (i < N) or (j > M_END) then begin
        if (ord(i) + ord(j) + 1) > (ord(N_END) + ord(M_END)-2) then
          finished := true
        else begin
          finished := false;
          new_line := true;
          if (ord(i) + ord(j)) >= (ord(N_END) + ord(M)) then begin 
            // we are on the upside of diagonal
            j := chr( ord(i) + 2 - ord(N) + ord(M) );
            i := N_END;
          end
          else begin 
            // we are on the downside of the diagonal
            i := chr( ord(i) + ord(j)  + 1 - ord(M) );
            j := M;
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
  // elements on a given antidiagonal line have same difference of ord
  begin
    if (i = GET_FIRST_INDEX) and (j = GET_FIRST_INDEX) then begin
      new_line := true;
      finished := false;
      i := N_END;    
      j := M;
    end 
    else begin
      dec(i);
      dec(j);
      if (i < N) or (j < M) then begin
        if (ord(i) - ord(j) - 1) <= (ord(N) - ord(M_END) + 2) then
          finished := true
        else begin
          finished := false;
          new_line := true;
          if (ord(i) - ord(j)) > (ord(N) - ord(M)) then begin 
            // upside of the antidiagonal
            j := chr(ord(M) +  ord(N_END) - ord(i) )  ;
            i := N_END;
          end
          else begin 
            i := chr( ord(N_END) - 2 -  ord(j) + ord(M));
            j := M_END;
            // we are on the downside of the antidiagonal
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
  // enables us to as-if-pass an iterator function as a parameter
  // to get next index using given iterator function
  // in lieu of lambda expressions
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
      ending : next := ending;
    end;
  end;

function did_someone_win(game_table:table):state;
  // we look for winning 6 streak in all 4 directions  \ / - | 
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
      i := GET_FIRST_INDEX;
      j := GET_FIRST_INDEX; 
      get_next_index(iter_func, i, j, finished, new_line);
      while (resu_state = playing) and not(finished) do begin
        if new_line then begin
          just_looked_at := NOTHING; 
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
      // throws exceptions due to possible range error
      // when using fpc -Ciort -vw -gl
      // and _this_makes_me_a_sad_panda_
    end;
    did_someone_win := resu_state;
  end;

function is_draw(game_table:table):state;
  var
    i,j:char;
    resu:state;
  begin
    resu := draw;
    i := N;
    while (i <= N_END) and (resu = draw) do begin
      j := M;
      while (j <= M_END) and (resu = draw) do begin
        if game_table[i,j] = NOTHING then 
          resu := playing;
        inc(j);
      end;
      inc(i);
    end;
    is_draw := resu;
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
