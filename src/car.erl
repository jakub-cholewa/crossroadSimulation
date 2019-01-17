-module(car).
-compile(export_all).
-include("../include/wx.hrl").
-include("../include/records.hrl").



%Funkcje udostępniane na zewnątrz. Crossroad używa ich do stworzenia instancji samochodu
start(X, Y, Direction) ->
  spawn(?MODULE, init, [self(), X, Y, Direction]).

start_link(X, Y, Direction) ->
  spawn_link(?MODULE, init, [self(), X, Y, Direction]).

init(Creator, X, Y, Direction) ->
  done.

