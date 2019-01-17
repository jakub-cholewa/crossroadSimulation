-module(car).
-compile(export_all).
-include("../include/wx.hrl").


%Funkcje udostępniane na zewnątrz. Crossroad używa ich do stworzenia instancji samochodu
start(Position, Direction, X, Y, GuiPid) ->
  spawn(?MODULE, init, [self(), Position, Direction, X, Y, GuiPid]).

start_link(Position, Direction, X, Y, GuiPid) ->
  spawn_link(?MODULE, init, [self(), Position, Direction, X, Y, GuiPid]).

init(Creator, Position, Direction, X, Y, GuiPid) ->
  car_lifecycle_loop(Position, Direction, X, Y, GuiPid).

car_lifecycle_loop(Position, Direction, X, Y, GuiPid) ->

  io:format("coord of car: X = ~p, Y = ~p~n", [X, Y]),

  timer:sleep(100),

  GuiPid ! {self(), X, Y, moved},

  if
    Direction =:= 1 -> car_lifecycle_loop(Position, Direction, X, Y+1, GuiPid);
    Direction =:= 2 -> car_lifecycle_loop(Position, Direction, X+1, Y, GuiPid);
    Direction =:= 3 -> car_lifecycle_loop(Position, Direction, X, Y-1, GuiPid);
    Direction =:= 3 -> car_lifecycle_loop(Position, Direction, X-1, Y, GuiPid)
  end.


