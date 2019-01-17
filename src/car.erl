-module(car).
-compile(export_all).
-include("../include/wx.hrl").


%Funkcje udostępniane na zewnątrz. Crossroad używa ich do stworzenia instancji samochodu
start(Position, Direction, X, Y) ->
  spawn(?MODULE, init, [self(), Position, Direction, X, Y]).

start_link(Position, Direction, X, Y) ->
  spawn_link(?MODULE, init, [self(), Position, Direction, X, Y]).

init(Creator, Position, Direction, X, Y) ->
  car_lifecycle_loop(Direction, X, Y).

car_lifecycle_loop(Direction, X, Y) ->

  io:format("coord of car: X = ~p, Y = ~p~n", [X, Y]),

  timer:sleep(100),

  if
    Direction =:= 1 -> car_lifecycle_loop(Direction, X, Y+1);
    Direction =:= 2 -> car_lifecycle_loop(Direction, X+1, Y);
    Direction =:= 3 -> car_lifecycle_loop(Direction, X, Y-1);
    Direction =:= 3 -> car_lifecycle_loop(Direction, X-1, Y)
  end.


