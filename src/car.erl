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

  CrossPid ! {self(), X, Y, moved},

  check_for_border(X, Y, Direction, CrossPid),

  check_lights(Position, Direction, X, Y, GuiPid, CrossPid),

  if
    Direction =:= 1 -> move_car_n(Position, Direction, X, Y, GuiPid, CrossPid);
    Direction =:= 2 -> move_car_e(Position, Direction, X, Y, GuiPid, CrossPid);
    Direction =:= 3 -> move_car_s(Position, Direction, X, Y, GuiPid, CrossPid);
    Direction =:= 4 -> move_car_w(Position, Direction, X, Y, GuiPid, CrossPid)
  end.



move_car_n(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X, Y-1, Direction, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X, Y-1, GuiPid, CrossPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.

move_car_e(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X+1, Y, Direction, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X+1, Y, GuiPid, CrossPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.

move_car_s(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X, Y+1, Direction, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X, Y+1, GuiPid, CrossPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.

move_car_w(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X-1, Y, Direction, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X-1, Y, GuiPid, CrossPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.


check_lights(Position, Direction, 265, 250, GuiPid, CrossPid) ->
  check_light(Position, Direction, 265, 250, GuiPid, CrossPid);
check_lights(Position, Direction, 340, 265, GuiPid, CrossPid) ->
  check_light(Position, Direction, 340, 265, GuiPid, CrossPid);
check_lights(Position, Direction, 325, 340, GuiPid, CrossPid) ->
  check_light(Position, Direction, 325, 340, GuiPid, CrossPid);
check_lights(Position, Direction, 250, 320, GuiPid, CrossPid) ->
  check_light(Position, Direction, 250, 320, GuiPid, CrossPid);
check_lights(_,_,_,_,_,_) -> ok.

check_light(Position, Direction, X, Y, GuiPid, CrossPid) ->
  CrossPid ! {self(), X, Y, getLight},
  receive
    {CrossPid, green, n} -> car_lifecycle_loop(Position, Direction, X, Y+1, GuiPid, CrossPid);
    {CrossPid, green, e} -> car_lifecycle_loop(Position, Direction, X-1, Y, GuiPid, CrossPid);
    {CrossPid, green, s} -> car_lifecycle_loop(Position, Direction, X, Y-1, GuiPid, CrossPid);
    {CrossPid, green, w} -> car_lifecycle_loop(Position, Direction, X+1, Y, GuiPid, CrossPid);
    {CrossPid, red, _} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
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
