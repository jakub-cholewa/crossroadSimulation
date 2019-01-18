-module(crossroad).
-compile(export_all).
-include("../include/wx.hrl").

start(GuiPid) ->
  register(?MODULE, CrossPid=spawn(?MODULE, init, [GuiPid])),%register nadaje nazwe procesowi
  CrossPid.

start_link(GuiPid) ->
  register(?MODULE, CrossPid=spawn_link(?MODULE, init, [GuiPid])),
  CrossPid.

init(GuiPid) ->
  LightPid = light:start(self()),
  main_crossroad_loop({Cars = orddict:new()}, GuiPid, LightPid).

main_crossroad_loop({Cars}, GuiPid, LightPid) ->
  receive
    {die} -> exit(kill);

  %Dodawanie samochodu
  % (źródło -> shell: funkcja add_car/2)
    {CrossPid, MsgRef, {addCar, Position, Direction, X, Y}} ->
      %Utworzenie nowej instacji samochodu
      CarPid = car:start_link(Position, Direction, X, Y, GuiPid, self(), LightPid),
      %Dodanie samochodu do listy samochodow którą posiada skrzyzowanie
      NewCars = orddict:store(CarPid, {Position, Direction, X, Y}, Cars),
      io:format("Lista samochodow: ~p~n", [NewCars]),
      %Wysłanie odpowiedzi o sukcesie do procesu który wysłał wiadomość (funkcja add_car/2)
      CrossPid ! {MsgRef, ok},
      % wyslanie informacji do gui o nowym samochodzie
      GuiPid ! {NewCars, newCarAdded},
      %Ponowne wywołanie pętli głównej programu stacji z nową listą(orddict) pociągów
      main_crossroad_loop({NewCars}, GuiPid, LightPid);

    % samochód się poruszył
    {CarPid, X, Y, moved} ->
      UpdatedCars = orddict:update(CarPid, fun ({Position, Direction, _, _}) -> {Position, Direction, X, Y} end, Cars),
      GuiPid ! {UpdatedCars, update},
      main_crossroad_loop({UpdatedCars}, GuiPid, LightPid);

    % sprawdzanie czy samochód może się ruszyć
    {CarPid, X, Y, getinfo} ->
      FoundCar = orddict:find(CarPid, Cars),
      {ok, {Position, Direction, A, B}} = FoundCar,
      if
        [A, B] =:= [X, Y] -> CarPid ! {self(), stop},
          main_crossroad_loop({Cars}, GuiPid, LightPid);
        true -> CarPid ! {self(), ok},
          main_crossroad_loop({Cars}, GuiPid, LightPid)
      end
%%      if
%%        X-1 < A ->
%%          if
%%            A < X+11 ->
%%              if
%%                Y-1 < B ->
%%                  if
%%                    B < Y+11 ->
%%                      CarPid ! {self(), stop},
%%                      io:format("buak buu"),
%%                      main_crossroad_loop({Cars}, GuiPid, LightPid);
%%                    true -> CarPid ! {self(), ok},
%%                      io:format("buak1"),
%%                      main_crossroad_loop({Cars}, GuiPid, LightPid)
%%                  end;
%%                true -> CarPid ! {self(), ok},
%%                  io:format("buak2"),
%%                  main_crossroad_loop({Cars}, GuiPid, LightPid)
%%              end;
%%            true -> CarPid ! {self(), ok},
%%              io:format("buak3"),
%%              main_crossroad_loop({Cars}, GuiPid, LightPid)
%%          end;
%%        true -> CarPid ! {self(), ok},
%%          io:format("buak4"),
%%          main_crossroad_loop({Cars}, GuiPid, LightPid)
%%      end

%%    % zmiana koloru światła
%%      {IsGreenOnMain, light_change} ->


end.

add_car(Position, Direction, X, Y) ->
  Ref = make_ref(),
  %Wysłanie wiadomośći do loop/1
  ?MODULE ! {self(), Ref, {addCar, Position, Direction, X, Y}},
  receive
    {Ref, Msg} -> Msg,
      io:format("Dodano pojazd na pozycji: ~p, pojedzie w kierunku: ~p~n", [Position, Direction])
  after 5000 ->
    {error, timeout}
  end.

