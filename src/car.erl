-module(car).
-compile(export_all).
-include("../include/wx.hrl").
-include("../include/records.hrl").



%Funkcje udostępniane na zewnątrz. Crossroad używa ich do stworzenia instancji samochodu
start(Position, Direction) ->
  spawn(?MODULE, init, [self(), Position, Direction]).

start_link(Position, Direction) ->
  spawn_link(?MODULE, init, [self(), Position, Direction]).

init(Creator, Position, Direction) ->
  done.

