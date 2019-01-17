-module(car).
-compile(export_all).
-include("../include/wx.hrl").


%Funkcje udostępniane na zewnątrz. Crossroad używa ich do stworzenia instancji samochodu
start(Position, Direction, X, Y, GuiPid, CrossPid) ->
  spawn(?MODULE, init, [self(), Position, Direction, X, Y, GuiPid, CrossPid]).

start_link(Position, Direction, X, Y, GuiPid, CrossPid) ->
  spawn_link(?MODULE, init, [self(), Position, Direction, X, Y, GuiPid, CrossPid]).

init(Creator, Position, Direction, X, Y, GuiPid, CrossPid) ->
  car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid).

car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid) ->

  io:format("coord of car: X = ~p, Y = ~p~n", [X, Y]),

  timer:sleep(100),

  GuiPid ! {self(), X, Y, moved},
  CrossPid ! {self(), X, Y, Position, Direction, moved},


  if
    Direction =:= 1 -> move_car_n(Position, Direction, X, Y, GuiPid, CrossPid);
    Direction =:= 2 -> car_lifecycle_loop(Position, Direction, X+5, Y, GuiPid, CrossPid);
    Direction =:= 3 -> car_lifecycle_loop(Position, Direction, X, Y-5, GuiPid, CrossPid);
    Direction =:= 3 -> car_lifecycle_loop(Position, Direction, X-5, Y, GuiPid, CrossPid)
  end.


move_car_n(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X, Y+5, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X, Y+5, GuiPid, CrossPid)
  after 30 ->
    car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.



