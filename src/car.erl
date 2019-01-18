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

  timer:sleep(50),

%%  io:format("coord of car: X = ~p, Y = ~p~n", [X, Y]),

  if
    [X, Y] =:= [265, 250] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid);
    [X, Y] =:= [340, 265] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid);
    [X, Y] =:= [325, 340] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid);
    [X, Y] =:= [250, 320] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid);
    true -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end,

  CrossPid ! {self(), X, Y, moved},

  check_for_border(X, Y, Direction, CrossPid),


  if
%%    Direction =:= 1 -> car_lifecycle_loop(Position, Direction, X, Y-5, GuiPid, CrossPid);
%%    Direction =:= 2 -> car_lifecycle_loop(Position, Direction, X+5, Y, GuiPid, CrossPid);
%%    Direction =:= 3 -> car_lifecycle_loop(Position, Direction, X, Y+5, GuiPid, CrossPid);
%%    Direction =:= 4 -> car_lifecycle_loop(Position, Direction, X-5, Y, GuiPid, CrossPid)
    Direction =:= 1 -> move_car_n(Position, Direction, X, Y, GuiPid, CrossPid);
    Direction =:= 2 -> move_car_e(Position, Direction, X, Y, GuiPid, CrossPid);
    Direction =:= 3 -> move_car_s(Position, Direction, X, Y, GuiPid, CrossPid);
    Direction =:= 4 -> move_car_w(Position, Direction, X, Y, GuiPid, CrossPid)
  end.


move_car_n(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X, Y-1, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X, Y-1, GuiPid, CrossPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.

move_car_e(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X+1, Y, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X+1, Y, GuiPid, CrossPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.

move_car_s(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X, Y+1, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X, Y+1, GuiPid, CrossPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.

move_car_w(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X-1, Y, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X-1, Y, GuiPid, CrossPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.


check_light(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X, Y, getLight},
  receive
    {CrossPid, green} -> ok;
    {CrossPid, red} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.

% północ
check_for_border(_, 100, 1, CrossPid) ->
  CrossPid ! {self(), dead},
  timer:sleep(5000);
% wschód
check_for_border(490, _, 2, CrossPid) ->
  CrossPid ! {self(), dead},
  timer:sleep(5000);
% południe
check_for_border(_, 490, 3, CrossPid) ->
  CrossPid ! {self(), dead},
  timer:sleep(5000);
% zachód
check_for_border(100,_, 4, CrossPid) ->
  CrossPid ! {self(), dead},
  timer:sleep(5000);
check_for_border(_,_,_,_) -> ok.
