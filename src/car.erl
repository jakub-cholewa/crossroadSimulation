-module(car).
-compile(export_all).
-include("../include/wx.hrl").


%Funkcje udostępniane na zewnątrz. Crossroad używa ich do stworzenia instancji samochodu
start(Position, Direction, X, Y, GuiPid, CrossPid, LightPid) ->
  spawn(?MODULE, init, [self(), Position, Direction, X, Y, GuiPid, CrossPid, LightPid]).

start_link(Position, Direction, X, Y, GuiPid, CrossPid, LightPid) ->
  spawn_link(?MODULE, init, [self(), Position, Direction, X, Y, GuiPid, CrossPid, LightPid]).

init(Creator, Position, Direction, X, Y, GuiPid, CrossPid, LightPid) ->
  car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid, LightPid).

car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid, LightPid) ->

  timer:sleep(300),

  CrossPid ! {self(), X, Y, moved},


  if
    [X, Y] =:= [265, 250] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid, LightPid);
    [X, Y] =:= [340, 265] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid, LightPid);
    [X, Y] =:= [325, 340] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid, LightPid);
    [X, Y] =:= [250, 320] -> check_light(Position, Direction, X, Y, GuiPid, CrossPid, LightPid)
  end,


  if
%%    Direction =:= 1 -> car_lifecycle_loop(Position, Direction, X, Y-5, GuiPid, CrossPid, LightPid);
%%    Direction =:= 2 -> car_lifecycle_loop(Position, Direction, X+5, Y, GuiPid, CrossPid, LightPid);
%%    Direction =:= 3 -> car_lifecycle_loop(Position, Direction, X, Y+5, GuiPid, CrossPid, LightPid);
%%    Direction =:= 4 -> car_lifecycle_loop(Position, Direction, X-5, Y, GuiPid, CrossPid, LightPid)
    Direction =:= 1 -> move_car_n(Position, Direction, X, Y, GuiPid, CrossPid, LightPid);
    Direction =:= 2 -> move_car_e(Position, Direction, X, Y, GuiPid, CrossPid, LightPid);
    Direction =:= 3 -> move_car_s(Position, Direction, X, Y, GuiPid, CrossPid, LightPid);
    Direction =:= 4 -> move_car_w(Position, Direction, X, Y, GuiPid, CrossPid, LightPid)
  end.


move_car_n(Position, Direction, X, Y, GuiPid, CrossPid, LightPid) ->
  CrossPid ! {self(), X, Y-5, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X, Y-5, GuiPid, CrossPid, LightPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid, LightPid)
  end.

move_car_e(Position, Direction, X, Y, GuiPid, CrossPid, LightPid) ->
  CrossPid ! {self(), X+5, Y, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X+5, Y, GuiPid, CrossPid, LightPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid, LightPid)
  end.

move_car_s(Position, Direction, X, Y, GuiPid, CrossPid, LightPid) ->
  CrossPid ! {self(), X, Y+5, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X, Y+5, GuiPid, CrossPid, LightPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid, LightPid)
  end.

move_car_w(Position, Direction, X, Y, GuiPid, CrossPid, LightPid) ->
  CrossPid ! {self(), X-5, Y, getinfo},
  receive
    {CrossPid, ok} -> car_lifecycle_loop(Position, Direction, X-5, Y, GuiPid, CrossPid, LightPid);
    {CrossPid, stop} -> car_lifecycle_loop(Position, Direction, X, Y, GuiPid, CrossPid, LightPid)
  end.


check_light(Position, Direction, X, Y, GuiPid, CrossPid, LightPid) ->
  LightPid ! {self(), X, Y, getLight},
  receive
    {LightPid, green} -> ok;
    {LightPid, red} -> car_lifecycle_loop(Position, Direction, X-5, Y, GuiPid, CrossPid, LightPid)
  end.
