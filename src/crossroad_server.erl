-module(crossroad_server).
-compile(export_all).
-include("../include/wx.hrl").

%idz kursorem do x,y
print({gotoxy, X, Y}) ->
  io:format("\e[~p;~pH", [Y,X]);
%na pozycji x, y wydrukuj msg
print({printxy, X, Y, Msg}) ->
  io:format("\e[~p;~pH~p", [Y,X,Msg]);
%wyczysc ekran
print({clear}) ->
  io:format("\e[2J", []).

printxy({X,Y,Msg}) ->
  io:format("\e[~p;~pH~p~n",[Y,X,Msg]).



%% MAIN view
init() ->
  print({clear}),
  print({printxy, 10, 3, '---------------------'}),
  print({printxy, 10, 4, '|CrossroadSimulation|'}),
  print({printxy, 10, 5, '---------------------'}),
  print({printxy, 6, 8, "crossroad_server:auto(): TRYB AUTOMATYCZNY"}),
  print({printxy, 6, 10, "crossroad_server:user(): TRYB UZYTKOWNIKA"}),
  print({gotoxy, 10, 13}),
  io:format("\n",[]),
  Server = wx:new(),
  Wx = make_window1(Server),
  main_window_loop(Wx).

make_window1(Server) ->
  Frame = wxFrame:new(Server, -1, "CrossroadSimulation", [{size,{1280,720}}]),
  Auto_Button = wxButton:new(Frame, 1, [{label, "Auto simulation"}, {pos, {300,70}}]),
  Manual_Button = wxButton:new(Frame, 2, [{label, "Manual simulation"}, {pos, {700,70}}]),

  wxFrame:createStatusBar(Frame),
  wxFrame:show(Frame),

  wxFrame:connect(Frame, close_window),
  wxButton:connect(Auto_Button, command_button_clicked),
  wxButton:connect(Manual_Button, command_button_clicked),
  % {Server, Frame, End_Button, Time_Text, ClientsR, ClientsS}.
  {Server, Frame, Auto_Button, Manual_Button}.

main_window_loop(Wx) ->
  {Server, Frame, Auto_Button, Manual_Button} = Wx,
  receive
    #wx{event=#wxClose{}} ->
      io:format("--closing window ~p-- ~n",[self()]),
      wxWindow:destroy(Frame),
      ok;
%%    #wx{id = 1, event=#wxCommand{type = command_button_clicked}} ->
%%      wxWindow:destroy(Auto_Button),
%%      wxWindow:destroy(Manual_Button),
%%      init2(Server,Frame);
%%
    #wx{id = 2, event=#wxCommand{type = command_button_clicked}} ->
      wxWindow:destroy(Auto_Button),
      wxWindow:destroy(Manual_Button),
      user(Server, Frame)

  end.



%% USER view
user(Server, Frame) ->
%%  CarsAmount = checkCarInput(),
  CrossroadPid = crossroad:start(self()),
  Wx = make_window_for_manual_case(Server, Frame),
%%  Wx = make_window_for_manual_case(Server, Frame, CarsAmount),
  UserPid = crossroad_generator:start_link_user(),
  loop_for_manual_case(Wx, CrossroadPid, UserPid).

checkCarInput() ->
  {Type, List} = io:fread("Enter a number of cars you want to add (1-3): ", "~d"),
  case {Type, List} of
    {error,_} -> io:format("Enter a number~n"),
      checkCarInput();
    {ok, [Num]} when Num > 3 -> io:format("Enter a number less than 4~n"),
      checkCarInput();
    {ok, [Num]} when not is_integer(Num) -> io:format("Enter an integer~n"),
      checkCarInput();
    {ok, [Num]} when Num < 1 -> io:format("Enter a number more than 0~n"),
      checkCarInput();
    {ok, [Num]} -> Num
  end.

make_window_for_manual_case(Server , Frame) ->
%%make_window_for_manual_case(Server , Frame, PlNo) ->
  End_Button = wxButton:new(Frame, 3, [{label, "End simulation"}, {pos, {500,50}}]),
  wxButton:connect(End_Button, command_button_clicked),


  draw_crossroad(Frame),

%%  RequestsView = wxStaticText:new(Frame, 0, "Oczekujące", [{pos, {500, 350}}]),

  wxFrame:show(Frame),
  {Server, Frame}.
%%  {Server, Frame, End_Button, PlatformsView, RequestsView}.


loop_for_manual_case(Wx, CrossroadPid, UserPid) ->
  {_, Frame} = Wx,
  receive

    #wx{event=#wxClose{}} ->
      io:format("--closing window ~p-- ~n",[self()]),
      io:format("ZAMKNIETE"),
      UserPid ! {die},
      CrossroadPid ! {die},
      wxWindow:destroy(Frame),
      ok
  end.



draw_crossroad(Frame) ->
  DrawContext = wxPaintDC:new(Frame),
  wxDC:drawRectangle(DrawContext, {100, 100}, {400, 400}),
  wxDC:drawLines(DrawContext, [{100, 250}, {250, 250}, {250,100}]),
  wxDC:drawLines(DrawContext, [{350, 100}, {350, 250}, {500,250}]),
  wxDC:drawLines(DrawContext, [{100, 350}, {250, 350}, {250,500}]),
  wxDC:drawLines(DrawContext, [{350, 500}, {350, 350}, {500,350}]),
  wxPaintDC:destroy(DrawContext).