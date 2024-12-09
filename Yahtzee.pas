unit Yahtzee;

var game_over := false;

type Dice = class
  val: integer;
  
  constructor();
  begin
    val := random(1, 6);
  end;
  
  procedure Roll();
  begin
    self.val := random(1, 6);
  end;
end;


type Player = class
  name: string;
  combination: array of Dice;

  constructor (name:string);
  begin
    self.name := name;
    self.combination := 
      |new Dice(), new Dice(), new Dice(), new Dice(), new Dice()|;
  end;
  
  procedure Roll();
  begin
    self.combination :=
      |new Dice(), new Dice(), new Dice(), new Dice(), new Dice()|;
  end;
  
  procedure Roll(selector: sequence of integer);
  begin
    for var i := 0 to self.combination.Length - 1 do begin
      if i in selector then begin
        self.combination[i] := new Dice();
      end;
    end;
  end;
  
  function DiceCombToIntArr(): array of integer;
  begin
    result := new integer [self.combination.length];
    for var i := 0 to self.combination.Length - 1 do begin
      result[i] := self.combination[i].val;
    end;
  end;
  
  function GetConfigurations(): array [,] of integer ;
  begin
    var comb := DiceCombToIntArr();
    result := new integer [2, 7];
    
    result[0, 0] := comb.CountOf(1) * 1; // ones
    result[0, 1] := comb.CountOf(2) * 2; // twos
    result[0, 2] := comb.CountOf(3) * 3; // threes
    result[0, 3] := comb.CountOf(4) * 4; // fours
    result[0, 4] := comb.CountOf(5) * 5; // fives
    result[0, 5] := comb.CountOf(6) * 6; // sixes
    
    for var i := 1 to 6 do begin
      if comb.CountOf(i) >= 3 then result[1, 0] := comb.Sum; // посл. из 3 одинак.
      if comb.CountOf(i) >= 4 then result[1, 1] := comb.sum; // посл. из 4 одинак.
      for var j := 1 to 6 do begin
        if (comb.CountOf(i) = 3) and (comb.CountOf(j) = 2) or
           (comb.CountOf(j) = 3) and (comb.CountOf(i) = 2) then
             result[1, 2] := 25; // full house
      end;
    end;
    
    var scomb := comb.Sorted.ToArray;
    var k := 0;
    for var i := 0 to scomb.Length - 2 do begin
      if scomb[i + 1] - scomb[i] = 1 then k += 1
      else k := 0;
      if k = 3 then result[1, 3] := 30; // малая посл-ть
      if k = 4 then result[1, 4] := 40; // большая посл-ть
    end;
    
    if comb.Distinct.ToArray.Length = 1 then result[1, 5] := 50; // yahtzee
    
    result[1, 6] := comb.Sum; // шанс
  end;
  
end;


function GetTable(players: array of player): array [,] of string;
begin
  result := new string [18, 1 + players.Length];
  result[0, 0] := 'Категория';
  result[1, 0] := '1-цы #1';
  result[2, 0] := '2-ки #2';
  result[3, 0] := '3-ки #3';
  result[4, 0] := '4-ки #4';
  result[5, 0] := '5-ки #5';
  result[6, 0] := '6-ки #6';
  result[7, 0] := 'Бонус ##';
  result[8, 0] := 'В. балл ##';
  result[9, 0] := '3 равных #7';
  result[10, 0] := '4 равных #8';
  result[11, 0] := 'Фул-хаус #9';
  result[12, 0] := 'М. посл. #10';
  result[13, 0] := 'Б. посл. #11';
  result[14, 0] := 'Yahtzee #12';
  result[15, 0] := 'Шанс #13';
  result[16, 0] := 'Н. балл ##';
  result[17, 0] := 'ИТОГО ##';
  for var i := 1 to players.Length do begin
    result[0, i] := players[i - 1].name;
  end;
  for var i := 1 to result.RowCount - 1 do begin
    for var j := 1 to result.ColCount - 1 do begin
      result[i, j] := '---';
    end;
  end;

end;


procedure TryTable(var table: array [,] of string; players: array of player; k: integer);
begin
  var j := k + 1;
  var up_ok := true;
  var bonus_check := 0;
  for var i := 1 to 6 do begin
    if table[i, j] = '---' then up_ok := false;
    if table[i, j] <> '---' then bonus_check += table[i, j].ToInteger;
  end;
  for var i := 1 to 6 do begin
    // println('!', i, j, table[i, j]);
    if table[i, j] = '---' then
      table[i, j] := players[0].GetConfigurations[0, i - 1].ToString + ' *';
  end;
  if up_ok and (bonus_check >= 63) then table[7, j] := '35';
  
  var up_sum := 0;
  if up_ok then begin
    for var i := 1 to 7 do begin
      up_sum += table[i, j].ToInteger;
    end;
    table[8, j] := up_sum.tostring;
  end;
  
  
  
  
  var down_ok := true;
  var down_sum := 0;
  for var i := 9 to 15 do begin
    if table[i, j] = '---' then down_ok := false;
  end;
  if down_ok then begin
    for var i := 9 to 15 do begin
      if table[i, j] <> '---' then down_sum += table[i, j].ToInteger;
    end;
    table[16, j] := down_sum.ToString;
  end;
  if down_ok and up_ok then table[17, j] := (up_sum + down_sum).ToString;
  
  for var i := 9 to 15 do begin
    if table[i, j] = '---' then
      table[i, j] := players[0].GetConfigurations[1, i - 9].ToString + ' *';
  end;
end;

procedure EndGameChecker(table: array [,] of string);
begin
  game_over := true;
  for var i := 1 to table.RowCount - 1 do begin
    for var j := 1 to table.ColCount - 2 do begin
      if table[i, j] = '---' then game_over := false; 
    end;
  end;
  if game_over then begin
    println();
    println();
    println('########################################');
    write('Таблица заполнена, игра подошла к концу. Подсчитываем ваши результаты');
    loop 10 do begin write('.'); sleep(200); end;
    var i0 := table.RowCount - 1;
    var rslt_list := new List<integer>; 
    var id_list := new List<integer>; 
    for var j := 1 to table.ColCount - 1 do begin
      rslt_list.Add(table[i0, j].ToInteger);
      id_list.Add(j);
    end;
    var max_score := integer.MinValue;
    var id_max_score := new List<integer>;
    for var i := 0 to rslt_list.Count - 1 do begin
      if rslt_list[i] >= max_score then max_Score := rslt_list[i];
      id_max_score.Add(i);
    end;
    println();
    println('Итоги! Победа у:');
    id_max_score.PrintLines(x -> table[0, x + 1]);
  end;
end;


begin end.