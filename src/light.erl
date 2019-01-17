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
  sleep(5000),
  CrossPid ! {IsGreenOnMain*(-1), light_change},
  light_lifecycle_loop(IsGreenOnMain*(-1), CrossPid).
