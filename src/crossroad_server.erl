-module(crossroad_server).
-compile(export_all).
-include("../include/wx.hrl").



%idz kursorem do x,y
print({gotoxy, X, Y}) ->
  io:format("\e[~p;~pH", [Y,X]);
%na pozycji x, y wydrukuj msg
print({printxy, X, Y, Msg}) ->
  io:format("\e[~p;~pH~p", [Y,X,Msg]);
%wyczysc ekran
print({clear}) ->
  io:format("\e[2J", []).

printxy({X,Y,Msg}) ->
  io:format("\e[~p;~pH~p~n",[Y,X,Msg]).


init() ->
  print({clear}),
  print({printxy, 10, 3, '+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+'}),
  print({printxy, 10, 4, '|S|t|a|c|j|a| |k|o|l|e|j|o|w|a|'}),
  print({printxy, 10, 5, '+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+'}),
  print({printxy, 6, 8, "station_server:auto(): TRYB AUTOMATYCZNY"}),
  print({printxy, 6, 10, "station_server:user(): TRYB UZYTKOWNIKA"}),
  print({gotoxy, 10, 13}),
  io:format("\n",[]).
%%  Server = wx:new(),
%%  Wx = make_window1(Server),
%%  loop1(Wx).




