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

  CrossPid ! {self(), X, Y, moved},

  check_for_border(X, Y, Direction),

%%  io:format("coord of car: X = ~p, Y = ~p~n", [X, Y]),

%%  if
%%    X =:= 1 -> move_car_n(Position, Direction, X, Y, GuiPid, CrossPid);
%%    X =:= 2 -> move_car_e(Position, Direction, X, Y, GuiPid, CrossPid);
%%    Y =:= 3 -> move_car_s(Position, Direction, X, Y, GuiPid, CrossPid);
%%    Y =:= 4 -> move_car_w(Position, Direction, X, Y, GuiPid, CrossPid)
%%  end,

%%  if
%%    [X, Y] =:= [265, 250] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid);
%%    [X, Y] =:= [340, 265] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid);
%%    [X, Y] =:= [325, 340] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid);
%%    [X, Y] =:= [250, 320] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid)
%%  end,


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
    {LightPid, green} -> ok;
    {LightPid, red} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid)
  end.

% północ
check_for_border(_, 105, 1) -> exit(out_of_map);
check_for_border(_,_,_) -> ok.
