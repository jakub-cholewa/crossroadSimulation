-module(light).
-compile(export_all).
-include("../include/wx.hrl").

start(CrossPid) ->
  spawn(?MODULE, init, [CrossPid]).

start_link(CrossPid) ->
  spawn_link(?MODULE, init, [self(), CrossPid]).

init(CrossPid) ->
  light_lifecycle_loop(1, CrossPid).

light_lifecycle_loop(IsGreenOnMain, CrossPid) ->



  receive
    {die} -> exit(kill);

    {CarPid, X, Y, getLight} -> {self(), green}

  end,


  light_lifecycle_loop(IsGreenOnMain*(-1), CrossPid).
