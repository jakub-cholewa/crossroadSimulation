-module(car_generator).
-compile(export_all).
-include("../include/wx.hrl").

%Funkcje udostępniane na zewnątrz. Crossroad używa ich do stworzenia instancji samochodu
start(CrossPid) ->
  spawn(?MODULE, init, [self(), CrossPid]).

start_link(CrossPid) ->
  spawn_link(?MODULE, init, [self(), CrossPid]).

init(Creator, CrossPid) ->
  car_lifecycle_loop(CrossPid).

car_lifecycle_loop(CrossPid) ->
  Position = crypto:rand_uniform(1,4),
  {X, Y, Direction} = generate_coords(Position),
  crossroad:add_car(Position, Direction, X, Y),
  timer:sleep(2500),
  car_lifecycle_loop(CrossPid).


% -> {X, Y, Direction}
generate_coords(1) -> {265, 100, 3};
generate_coords(2) -> {490, 265, 4};
generate_coords(3) -> {325, 490, 1};
generate_coords(4) -> {100, 320, 2}.
