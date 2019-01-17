-module(crossroad_generator).
-compile(export_all).
-include("../include/wx.hrl").



%% USER input
make_cars(X, Y) ->
  crossroad:add_car(X, Y).