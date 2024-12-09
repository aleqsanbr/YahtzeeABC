##  uses Yahtzee; 
println('YAHTZEE GAME');
var playerscnt := readlninteger('Сколько игроков будут играть (1-6)? >>>');
if (playerscnt <= 0) or (playerscnt >= 7) then begin
  println('Недопустимое количество игроков.');
  exit();
end;

var maxname := '**************';

var players := new Player [playerscnt];
//println('ВАЖНО! ReadString некорректно работает. Поэтому использую ReadInteger');
for var i := 0 to playerscnt - 1 do begin
  //var name := readinteger('Введите имя >>>').tostring;
  var name := readlnstring('Введите имя >>>');
  players[i] := new Player(name); // readstring не работает, пропускает первого игрока
  if name.length > maxname.length then maxname := name;
end;

println();
println('Добро пожаловать! Вот начальный счет:');
println();
var ScoreTable := GetTable(players)[:,:];
ScoreTable.Println(maxname.Length);



println();

var k := 0;
var action := 0;
while game_over <> true do begin
  if game_over = true then break;
  action := 0;
  println('##### Ход игрока', players[k mod playerscnt].name);
  write('      ', players[k mod playerscnt].name, ', ваши кубики: ');
  players[k mod playerscnt].DiceCombToIntArr.Print;
  println();
  var temp_ScoreTable := ScoreTable[:,:];
  TryTable(temp_ScoreTable, |players[k mod playerscnt]|, k mod playerscnt);
  println();
  temp_ScoreTable.Println(maxname.Length);
  println();
  
  var rollcnt := 1;
  
  var startplayermessage := false;
  
  while (action not in |1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 666666, 66666600|) and (game_over <> true) do begin
    
    if startplayermessage then begin
    
    println();
    write('      ', players[k mod playerscnt].name, ', ваши кубики: ');
    players[k mod playerscnt].DiceCombToIntArr.Print;
    println();
    temp_ScoreTable := ScoreTable[:,:];
    TryTable(temp_ScoreTable, |players[k mod playerscnt]|, k mod playerscnt);
    println();
    temp_ScoreTable.Println(maxname.Length);
    println();
    
    end;
    
    startplayermessage := true;
    
    println('Возможные комбинации помечены звездочками. Записать или перекинуть? Введите номер около #, куда записать значение, или же 666, чтобы перекинуть.');
    action := readinteger('      Ввод >>>');
    if action = 666 then begin
      if rollcnt > 2 then println('У вас закончились крутки.');
      while rollcnt <= 2 do begin
        writeln('Перебрасываем кубики (перброска ', rollcnt, ' из 2). Перебросить все или только некоторые?');
        var rollaction := readinteger('      Ввод (1 для всех; 2, чтобы выбрать; любое другое число, чтобы отменить) >>>');
        if rollaction = 1 then begin
          players[k mod playerscnt].Roll();
          write('      ', players[k mod playerscnt].name, ', ваши кубики: ');
          players[k mod playerscnt].DiceCombToIntArr.Print;
          println;
        end
        else if rollaction = 2 then begin
          print('Необходимо выбрать кубики, которые хотите перебросить. Вводите номера (нумерация 1-5), 0 - чтобы завершить ввод >>>');
          var choose_dice := integer.MaxValue;
          var selector_dices := new list<integer>;
          while choose_dice <> 0 do begin
            choose_dice := readinteger();
            if choose_dice = 0 then break;
            selector_dices.Add(choose_dice - 1);
            if selector_dices.Count >= 5 then break;
          end;
          println();
          players[k mod playerscnt].Roll(selector_dices);
          write('      ', players[k mod playerscnt].name, ', ваши кубики: ');
          players[k mod playerscnt].DiceCombToIntArr.Print;
          println;
        end
        else break;
        rollcnt += 1;
      end; 
    end;
    
    if action in |1, 2, 3, 4, 5, 6| then begin
      if ScoreTable[action, k mod playerscnt + 1] = '---' then
        ScoreTable[action, k mod playerscnt + 1] := temp_ScoreTable[action, k mod playerscnt + 1][:^2]
      else begin
        println('      !! Нельзя сюда записать !!');
        k -= 1;
      end;
    end;
    
    if action in |7, 8, 9, 10, 11, 12, 13| then begin
      if ScoreTable[action + 2, k mod playerscnt + 1] = '---' then
        ScoreTable[action + 2, k mod playerscnt + 1] := temp_ScoreTable[action + 2, k mod playerscnt + 1][:^2]
      else begin
        println('      !! Нельзя сюда записать !!');
        k -= 1;
      end;
    end;
    
    if action = 666666 then begin
      println('Запускаю чит-код проверки бонуса'.ToUpper);
      foreach var i in |1, 2, 3, 4, 5, 6| do begin
        ScoreTable[i, k mod playerscnt + 1] := (i * 5).ToString;
      end;
    end;
    
    if action = 66666600 then begin
      println('Запускаю чит-код заполнения нижней части'.ToUpper);
      foreach var i in |7, 8, 9, 10, 11, 12, 13| do begin
        ScoreTable[i + 2, k mod playerscnt + 1] := (100).ToString;
      end;
    end;
    
    temp_ScoreTable := ScoreTable[:,:];
    TryTable(temp_ScoreTable, |players[k mod playerscnt]|, k mod playerscnt);
    
    ScoreTable[7, k mod playerscnt + 1] := temp_ScoreTable[7, k mod playerscnt + 1];
    ScoreTable[8, k mod playerscnt + 1] := temp_ScoreTable[8, k mod playerscnt + 1];
    ScoreTable[16, k mod playerscnt + 1] := temp_ScoreTable[16, k mod playerscnt + 1];
    ScoreTable[17, k mod playerscnt + 1] := temp_ScoreTable[17, k mod playerscnt + 1];
    
  end;
  
  
  
  println();
  
  
  
  
  
  k += 1;
  foreach var p in players do p.Roll;
  sleep(1000);
  
  EndGameChecker(ScoreTable);
end;

var eeee := readinteger;




//