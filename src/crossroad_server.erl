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
  Frame = wxFrame:new(Server, -1, "CrossroadSimulation", [{size,{1000,500}}]),
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
%%  Car_input = checkCarInput(),
%%  CrossroadPid = crossroad:start(self()),
%%  Car = car_generator:generate_cars(Car_input),
%%  Wx = make_window_for_manual_case(Server, Frame, Car_input),
%%  UserPid = car_generator:start_link_user(),
%%  loop3(Wx,CrossroadPid,UserPid).
  Wx = make_window_for_manual_case(Server, Frame),
  loop_for_manual_case(Wx).


make_window_for_manual_case(Server , Frame) ->
%%make_window_for_manual_case(Server , Frame, PlNo) ->
  End_Button = wxButton:new(Frame, 3, [{label, "End simulation"}, {pos, {500,50}}]),
  wxButton:connect(End_Button, command_button_clicked),
  Platform6 = [{6, wxStaticText:new(Frame, 0, "Peron 6", [{pos, {200, 350}}])}],
  Platform5 = [{5, wxStaticText:new(Frame, 0, "Peron 5", [{pos, {200, 300}}])}|Platform6],
  Platform4 = [{4, wxStaticText:new(Frame, 0, "Peron 4", [{pos, {200, 250}}])}|Platform5],
  Platform3 = [{3, wxStaticText:new(Frame, 0, "Peron 3", [{pos, {200, 200}}])}|Platform4],
  Platform2 = [{2, wxStaticText:new(Frame, 0, "Peron 2", [{pos, {200, 150}}])}|Platform3],
  Platform1 = [{1, wxStaticText:new(Frame, 0, "Peron 1", [{pos, {200, 100}}])}|Platform2],
  PlatformsView = Platform1,

  RequestsView = wxStaticText:new(Frame, 0, "Oczekujące", [{pos, {500, 350}}]),

  wxFrame:show(Frame),
  {Server, Frame}.
%%  {Server, Frame, End_Button, PlatformsView, RequestsView}.


loop_for_manual_case(Wx) ->
  {Server, Frame} = Wx,
  receive
    #wx{event=#wxClose{}} ->
      io:format("--closing window ~p-- ~n",[self()]),
      wxWindow:destroy(Frame),
      ok
  end.