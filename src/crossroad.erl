-module(crossroad).
-compile(export_all).
-include("../include/wx.hrl").



%%main_crossroad_loop({Cars}, GuiPid) ->
%%  receive
%%    {die} -> exit(kill);
%%
%%
%%  %Dodawanie samochodu
%%  % (źródło -> shell: funkcja add_train/2)
%%    {Pid, MsgRef, {addCar, X, Y}} ->
%%      %Utworzenie nowej instacji pociągu
%%      CarPid = car:start_link(),
%%      %Dodanie pociągu do listy pociągów którą posiada stacja
%%      NewCars = orddict:store({X, Y}, Cars),
%%      %Wysłanie odpowiedzi o sukcesie do procesu który wysłał wiadomość (funkcja add_train/2)
%%      Pid ! {MsgRef, ok},
%%      %Ponowne wywołanie pętli głównej programu stacji z nową listą(orddict) pociągów
%%      main_crossroad_loop({NewCars}, GuiPid)
%%
%%  end.

start(GuiPid) ->
  register(?MODULE, Pid=spawn(?MODULE, init, [GuiPid])),
  Pid.

start_link(GuiPid) ->
  register(?MODULE, Pid=spawn_link(?MODULE, init, [GuiPid])),
  Pid.

%%init(GuiPid) ->
%%  main_crossorad_loop({Cars = orddict:new()}, GuiPid).





add_car(X, Y) ->
  Ref = make_ref(),
  %Wysłanie wiadomośći do loop/1
  ?MODULE ! {self(), Ref, {addCar, X, Y}},
  receive
    {Ref, Msg} -> Msg,
      io:format("Dodano pojazd na współrzędnych: [~p ~p] ~n", [X, Y])
  after 5000 ->
    {error, timeout}
  end.