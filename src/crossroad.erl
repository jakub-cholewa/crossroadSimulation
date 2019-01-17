-module(crossroad).
-compile(export_all).
-include("../include/wx.hrl").

start(GuiPid) ->
  register(?MODULE, CrossPid=spawn(?MODULE, init, [GuiPid])),%register nadaje nazwe procesowi
  CrossPid.

start_link(GuiPid) ->
  register(?MODULE, CrossPid=spawn_link(?MODULE, init, [GuiPid])),
  CrossPid.

init(GuiPid) ->
  main_crossroad_loop({Cars = orddict:new()}, GuiPid).

main_crossroad_loop({Cars}, GuiPid) ->
  receive
    {die} -> exit(kill);

  %Dodawanie samochodu
  % (źródło -> shell: funkcja add_car/2)
    {CrossPid, MsgRef, {addCar, Position, Direction, X, Y}} ->
      %Utworzenie nowej instacji samochodu
      CarPid = car:start_link(Position, Direction, X, Y, GuiPid, CrossPid),
      %Dodanie samochodu do listy samochodow którą posiada skrzyzowanie
      NewCars = orddict:store(CarPid, {Position, Direction, X, Y}, Cars),
      io:format("Lista samochodow: ~p~n", [NewCars]),
      %Wysłanie odpowiedzi o sukcesie do procesu który wysłał wiadomość (funkcja add_car/2)
      CrossPid ! {MsgRef, ok},
      % wyslanie informacji do gui o nowym samochodzie
      GuiPid ! {NewCars, newCarAdded},
      %Ponowne wywołanie pętli głównej programu stacji z nową listą(orddict) pociągów
      main_crossroad_loop({NewCars}, GuiPid);

    {CarPid, X, Y, getinfo} ->
      if
        check_if_move_is_possible(X, Y, Cars) =:= true ->
          CarPid ! {self(), ok};
        true -> CarPid ! {self(), wait}
      end




end.

add_car(Position, Direction, X, Y) ->
  Ref = make_ref(),
  %Wysłanie wiadomośći do loop/1
  ?MODULE ! {self(), Ref, {addCar, Position, Direction, X, Y}},
  receive
    {Ref, Msg} -> Msg,
      io:format("Dodano pojazd na pozycji: ~p, pojedzie w kierunku: ~p~n", [Position, Direction])
  after 5000 ->
    {error, timeout}
  end.

check_if_move_is_possible(X, Y, Cars) ->
