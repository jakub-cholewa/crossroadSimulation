-module(light).
-compile(export_all).
-include("../include/wx.hrl").

start(CrossPid) ->
  spawn(?MODULE, init, [CrossPid]).

start_link(CrossPid) ->
  spawn_link(?MODULE, init, [CrossPid]).

init(CrossPid) ->
  light_lifecycle_loop(1, CrossPid).

light_lifecycle_loop(IsGreenOnMain, CrossPid) ->
  CrossPid ! {IsGreenOnMain*(-1), light_change_to_yellow},
  timer:sleep(1000),
  CrossPid ! {IsGreenOnMain*(-1), light_change_to_red_green},
  timer:sleep(3000),
  light_lifecycle_loop(IsGreenOnMain*(-1), CrossPid).
