-module(car).
-compile(export_all).
-include("../include/wx.hrl").


%Funkcje udostępniane na zewnątrz. Crossroad używa ich do stworzenia instancji samochodu
start(Position, Direction, X, Y) ->
  spawn(?MODULE, init, [self(), Position, Direction, X, Y]).

start_link(Position, Direction, X, Y) ->
  spawn_link(?MODULE, init, [self(), Position, Direction, X, Y]).

init(Creator, Position, Direction, X, Y) ->
  done.

