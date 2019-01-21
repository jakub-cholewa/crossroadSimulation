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
  Server = wx:new(),
  Wx = make_window1(Server),
  main_window_loop(Wx).

make_window1(Server) ->
  Frame = wxFrame:new(Server, -1, "CrossroadSimulation", [{size,{800,600}}]),
  Auto_Button = wxButton:new(Frame, 1, [{label, "Start simulation"}, {pos, {300,70}}]),
  Manual_Button = wxButton:new(Frame, 2, [{label, "Manual simulation"}, {pos, {900,70}}]),

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
    #wx{id = 1, event=#wxCommand{type = command_button_clicked}} ->
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
  End_Button = wxButton:new(Frame, 3, [{label, "Koniec"}, {pos, {550,550}}]),
  N_Button = wxButton:new(Frame, 4, [{label, "N"}, {pos, {600,100}}, {size, {50,50}}]),
  E_Button = wxButton:new(Frame, 5, [{label, "E"}, {pos, {650,150}}, {size, {50,50}}]),
  S_Button = wxButton:new(Frame, 6, [{label, "S"}, {pos, {600,200}}, {size, {50,50}}]),
  W_Button = wxButton:new(Frame, 7, [{label, "W"}, {pos, {550,150}}, {size, {50,50}}]),
  wxButton:connect(End_Button, command_button_clicked),
  wxButton:connect(N_Button, command_button_clicked),
  wxButton:connect(E_Button, command_button_clicked),
  wxButton:connect(S_Button, command_button_clicked),
  wxButton:connect(W_Button, command_button_clicked),

  wxStaticText:new(Frame, 0, "Symulacja Skrzyżowania", [{pos, {600, 30}}]),
  MainLight = wxStaticText:new(Frame, 0, "Główne światło:", [{pos, {550, 400}}]),
  SubLight = wxStaticText:new(Frame, 0, "Poboczne światło: ", [{pos, {550, 450}}]),


  draw_crossroad(Frame),

  wxFrame:show(Frame),
  {Server, Frame, MainLight, SubLight}.
%%  {Server, Frame, End_Button, PlatformsView, RequestsView}.


loop_for_manual_case(Wx, CrossroadPid, UserPid) ->
  {_, Frame, MainLight, SubLight} = Wx,
  receive

    #wx{event=#wxClose{}} ->
      io:format("--closing window ~p-- ~n",[self()]),
      io:format("ZAMKNIETE"),
      UserPid ! {die},
      CrossroadPid ! {die},
      wxWindow:destroy(Frame),
      ok;

    #wx{id = 3, event=#wxCommand{type = command_button_clicked}} ->
      UserPid ! {die},
      CrossroadPid ! {die},
      io:format("ZAMKNIETE"),
      wxWindow:destroy(Frame);

    #wx{id = 4, event=#wxCommand{type = command_button_clicked}} ->
      crossroad:add_car(1, 3, 265, 100),
      loop_for_manual_case(Wx, CrossroadPid, UserPid);

    #wx{id = 5, event=#wxCommand{type = command_button_clicked}} ->
      crossroad:add_car(2, 4, 490, 265),
      loop_for_manual_case(Wx, CrossroadPid, UserPid);

    #wx{id = 6, event=#wxCommand{type = command_button_clicked}} ->
      crossroad:add_car(3, 1, 325, 490),
      loop_for_manual_case(Wx, CrossroadPid, UserPid);

    #wx{id = 7, event=#wxCommand{type = command_button_clicked}} ->
      crossroad:add_car(4, 2, 100, 320),
      loop_for_manual_case(Wx, CrossroadPid, UserPid);

    {Cars, newCarAdded} ->
      io:format("Odebrałem nowy samochód~n"),
      draw_cars(Cars, Frame),
      loop_for_manual_case(Wx, CrossroadPid, UserPid);

    {Cars, update} ->
      draw_crossroad(Frame),
      draw_cars(Cars, Frame),
      loop_for_manual_case(Wx, CrossroadPid, UserPid);

    {IsGreenOnMain, light_change} ->
      draw_lights(IsGreenOnMain, Frame, MainLight, SubLight),
      loop_for_manual_case(Wx, CrossroadPid, UserPid)
  end.


draw_crossroad(Frame) ->
  DrawContext = wxPaintDC:new(Frame),
  wxDC:drawRectangle(DrawContext, {100, 100}, {400, 400}),
  wxDC:drawLines(DrawContext, [{100, 250}, {250, 250}, {250,100}]),
  wxDC:drawLines(DrawContext, [{350, 100}, {350, 250}, {500,250}]),
  wxDC:drawLines(DrawContext, [{100, 350}, {250, 350}, {250,500}]),
  wxDC:drawLines(DrawContext, [{350, 500}, {350, 350}, {500,350}]),
  wxPaintDC:destroy(DrawContext).



draw_cars([{Pid, {Spawn, Direction, X, Y}} | Rest], Frame) ->
%%  io:format("Wyświetlam : X= ~p Y= ~p ~n", [X, Y]),
  DrawContext = wxPaintDC:new(Frame),
  wxDC:drawRectangle(DrawContext, {X, Y}, {10,10}),
  draw_cars(Rest, Frame);

draw_cars([], Frame) ->
  ok.

draw_lights(IsGreenOnMain, Frame, MainLight, SubLight) ->
  io:format("Zmieniam światlo~n"),
  DrawContext = wxPaintDC:new(Frame),
  if
    IsGreenOnMain =:= 1 ->
      wxDC:setTextForeground(DrawContext, {255,0,0}),
      wxDC:drawLabel(DrawContext, "O", {50,290,100,100}),
      wxDC:drawLabel(DrawContext, "O", {540,290,100,100}),
      wxDC:setTextForeground(DrawContext, {0,180,0}),
      wxDC:drawLabel(DrawContext, "O", {290,50,100,100}),
      wxDC:drawLabel(DrawContext, "O", {290,530,100,100}),


      wxStaticText:setLabel(MainLight,"Główne światło   : ZIELONE"),
      wxStaticText:setLabel(SubLight, "Poboczne światło : CZERWONE");
    true ->
      wxDC:setTextForeground(DrawContext, {0,180,0}),
      wxDC:drawLabel(DrawContext, "O", {50,290,100,100}),
      wxDC:drawLabel(DrawContext, "O", {540,290,100,100}),
      wxDC:setTextForeground(DrawContext, {255,0,0}),
      wxDC:drawLabel(DrawContext, "O", {290,50,100,100}),
      wxDC:drawLabel(DrawContext, "O", {290,530,100,100}),

      wxStaticText:setLabel(MainLight,"Główne światło   : CZERWONE"),
      wxStaticText:setLabel(SubLight, "Poboczne światło : ZIELONE")
  end.



