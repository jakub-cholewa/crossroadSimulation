-module(crossroad).
-compile(export_all).
-include("../include/wx.hrl").
-include("../include/records.hrl").

start(GuiPid) ->
  register(?MODULE, Pid=spawn(?MODULE, init, [GuiPid])),%register nadaje nazwe procesowi
  Pid.

start_link(GuiPid) ->
  register(?MODULE, Pid=spawn_link(?MODULE, init, [GuiPid])),
  Pid.

init(GuiPid) ->
  main_crossroad_loop({Cars = orddict:new()}, GuiPid).


main_crossroad_loop({Cars}, GuiPid) ->
  receive
    {die} -> exit(kill);

  %Dodawanie samochodu
  % (źródło -> shell: funkcja add_car/3)
    {Pid, MsgRef, {addCar, X, Y, Direction}} ->
      %Utworzenie nowej instacji samochodu
      CarPid = car:start_link(X, Y, Direction),
      %Dodanie pociągu do listy samochodow którą posiada skrzyzowanie
      NewCars = orddict:store(CarPid, {X, Y, Direction}, Cars),
      %Wysłanie odpowiedzi o sukcesie do procesu który wysłał wiadomość (funkcja add_train/2)
      Pid ! {MsgRef, ok},
      %Ponowne wywołanie pętli głównej programu stacji z nową listą(orddict) pociągów
      main_crossroad_loop({NewCars}, GuiPid)

  end.


add_car(X, Y, Direction) ->
  Ref = make_ref(),
  %Wysłanie wiadomośći do loop/1
  ?MODULE ! {self(), Ref, {addCar, X, Y, Direction}},
  receive
    {Ref, Msg} -> Msg,
      io:format("Dodano samochod x = ~p y = ~p kierunek = ~p~n", [X, Y, Direction])
  after 5000 ->
    {error, timeout}
  end.