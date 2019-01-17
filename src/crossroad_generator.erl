-module(crossroad_generator).
-compile(export_all).
-include("../include/wx.hrl").


%% USER input

start_link_user() ->
  io:format("Spawn for user input~n"),
  spawn_link(?MODULE, init_user, []).

init_user() ->
  io:format("generator: Init user~n"),
  loop_user().


loop_user() ->
  Position = read_start_position(),
  Direction = read_direction(),
  {X, Y} = get_coordinates(Position),

  receive
    {die} -> exit(simulationStopped)
  after 1 ->
    make_car(Position, Direction, X, Y),
    loop_user()
  end.

make_car(Position, Direction, X, Y) ->
  crossroad:add_car(Position, Direction, X, Y).

read_start_position() ->
  {Type, List} = io:fread("Car spawn position(N=1, E=2, S=3, W=4): ", "~d"),
  case {Type, List} of
    {error, _} -> io:format("Enter a number~n"),
      read_start_position();
    {ok, [Position]} when not is_integer(Position) -> io:format("Enter an integer~n"),
      read_start_position();
    {ok, [Position]} when Position < 1 -> io:format("Enter a correct number for direction~n"),
      read_start_position();
    {ok, [Position]} when Position > 4 -> io:format("Enter a correct number for direction~n"),
      read_start_position();
    {ok, [Position]} -> Position
  end.

read_direction() ->
  {Type, List} = io:fread("Car direction(N=1, E=2, S=3, W=4): ", "~d"),
  case {Type, List} of
    {error, _} -> io:format("Enter a number~n"),
      read_direction();
    {ok, [Direction]} when not is_integer(Direction) -> io:format("Enter an integer~n"),
      read_direction();
    {ok, [Direction]} when Direction < 1 -> io:format("Enter a correct number for direction~n"),
      read_direction();
    {ok, [Direction]} when Direction > 4 -> io:format("Enter a correct number for direction~n"),
      read_direction();
    {ok, [Direction]} -> Direction
  end.

get_coordinates(Position) ->
  if
    Position =:= 1 -> {225, 100};
    Position =:= 2 -> {500, 275};
    Position =:= 3 -> {325, 500};
    Position =:= 4 -> {100, 375}
  end.


%%read_coordinate_X() ->
%%  {Type, List} = io:fread("Car coordinate X: ", "~d"),
%%  case {Type, List} of
%%    {error, _} -> io:format("Enter a number~n"),
%%      read_coordinate_X();
%%    {ok, [X]} when not is_integer(X) -> io:format("Enter an integer~n"),
%%      read_coordinate_X();
%%    {ok, [X]} when X < 1 -> io:format("Enter a correct number~n"),
%%      read_coordinate_X();
%%    {ok, [X]} -> X
%%  end.
%%
%%read_coordinate_Y() ->
%%  {Type, List} = io:fread("Car coordinate Y: ", "~d"),
%%  case {Type, List}of
%%    {error, _} -> io:format("Enter a number~n"),
%%      read_coordinate_Y();
%%    {ok, [Y]} when not is_integer(Y) -> io:format("Enter an integer~n"),
%%      read_coordinate_Y();
%%    {ok, [Y]} when Y < 1 -> io:format("Enter a correct number~n"),
%%      read_coordinate_Y();
%%    {ok, [Y]} -> Y
%%  end.