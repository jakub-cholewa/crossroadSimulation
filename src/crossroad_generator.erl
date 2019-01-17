-module(crossroad_generator).
-compile(export_all).
-include("../include/wx.hrl").
-include("../include/records.hrl").



%% USER input

start_link_user() ->
  io:format("Spawn for user input~n"),
  spawn_link(?MODULE, init_user, []).

init_user() ->
  io:format("generator: Init user~n"),
  loop_user().


loop_user() ->
  X = read_coordinate_X(),
  Y = read_coordinate_Y(),
  Direction = read_direction(),

  receive
    {die} -> exit(simulationStopped)
  after 1 ->
    make_car(X, Y, Direction),
    loop_user()
  end.

make_car(X, Y, Direction) ->
  crossroad:add_car(X, Y, Direction).

read_coordinate_X() ->
  {Type, List} = io:fread("Car coordinate X: ", "~d"),
  case {Type, List} of
    {error, _} -> io:format("Enter a number~n"),
      read_coordinate_X();
    {ok, [X]} when not is_integer(X) -> io:format("Enter an integer~n"),
      read_coordinate_X();
    {ok, [X]} when X < 1 -> io:format("Enter a correct number~n"),
      read_coordinate_X();
    {ok, [X]} -> X
  end.

read_coordinate_Y() ->
  {Type, List} = io:fread("Car coordinate Y: ", "~d"),
  case {Type, List}of
    {error, _} -> io:format("Enter a number~n"),
      read_coordinate_Y();
    {ok, [Y]} when not is_integer(Y) -> io:format("Enter an integer~n"),
      read_coordinate_Y();
    {ok, [Y]} when Y < 1 -> io:format("Enter a correct number~n"),
      read_coordinate_Y();
    {ok, [Y]} -> Y
  end.

read_direction() ->
  {Type, List} = io:fread("Car direction(N=1, E=2, S=3, W=4): ", "~d"),
  case {Type, List} of
    {error, _} -> io:format("Enter a number~n"),
      read_coordinate_Y();
    {ok, [Direction]} when not is_integer(Direction) -> io:format("Enter an integer~n"),
      read_coordinate_Y();
    {ok, [Direction]} when Direction < 1 -> io:format("Enter a correct number for direction~n"),
      read_coordinate_Y();
    {ok, [Direction]} when Direction > 3 -> io:format("Enter a correct number for direction~n"),
      read_coordinate_Y();
    {ok, [Direction]} -> Direction
  end.