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
  LightPid = light:start_link(self()),
  main_crossroad_loop({Cars = orddict:new()}, GuiPid, 1).

main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain) ->
  receive
    {die} -> exit(kill);

  %Dodawanie samochodu
  % (źródło -> shell: funkcja add_car/2)
    {CrossPid, MsgRef, {addCar, Position, Direction, X, Y}} ->
      %Utworzenie nowej instacji samochodu
      CarPid = car:start_link(Position, Direction, X, Y, GuiPid, self()),
      %Dodanie samochodu do listy samochodow którą posiada skrzyzowanie
      NewCars = orddict:store(CarPid, {Position, Direction, X, Y}, Cars),
      io:format("Lista samochodow: ~p~n", [NewCars]),
      %Wysłanie odpowiedzi o sukcesie do procesu który wysłał wiadomość (funkcja add_car/2)
      CrossPid ! {MsgRef, ok},
      % wyslanie informacji do gui o nowym samochodzie
      GuiPid ! {NewCars, newCarAdded},
      %Ponowne wywołanie pętli głównej programu stacji z nową listą(orddict) pociągów
      main_crossroad_loop({NewCars}, GuiPid, IsGreenOnMain);

    % samochód się poruszył
    {CarPid, X, Y, moved} ->
      UpdatedCars = orddict:update(CarPid, fun ({Position, Direction, _, _}) -> {Position, Direction, X, Y} end, Cars),
      GuiPid ! {UpdatedCars, update},
      main_crossroad_loop({UpdatedCars}, GuiPid, IsGreenOnMain);

    % sprawdzanie czy samochód może się ruszyć
    {CarPid, X, Y, getinfo} ->

%%      orddict:map(
%%        fun(Pid, {Position, Direction, A, B}) ->
%%          io:format([Pid]),
%%          io:format([CarPid]),
%%          if
%%            Pid /= CarPid ->
%%              io:format("buka2~n"),
%%              if
%%                [A, B] =:= [X, Y] -> CarPid ! {self(), stop},
%%                  main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
%%                true -> CarPid ! {self(), ok},
%%                  main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain)
%%              end
%%          end
%%        end, Cars);


      FoundCar = orddict:find(CarPid, Cars),
      {ok, {Position, Direction, A, B}} = FoundCar,
      if
        [A, B] =:= [X, Y] -> CarPid ! {self(), stop},
          main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
        true -> CarPid ! {self(), ok},
          main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain)
      end;


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
%%                      main_crossroad_loop({Cars}, GuiPid);
%%                    true -> CarPid ! {self(), ok},
%%                      io:format("buak1"),
%%                      main_crossroad_loop({Cars}, GuiPid)
%%                  end;
%%                true -> CarPid ! {self(), ok},
%%                  io:format("buak2"),
%%                  main_crossroad_loop({Cars}, GuiPid)
%%              end;
%%            true -> CarPid ! {self(), ok},
%%              io:format("buak3"),
%%              main_crossroad_loop({Cars}, GuiPid)
%%          end;
%%        true -> CarPid ! {self(), ok},
%%          io:format("buak4"),
%%          main_crossroad_loop({Cars}, GuiPid)
%%      end;

    % zmiana koloru światła
    {NIsGreenOnMain, light_change} ->
      GuiPid ! {NIsGreenOnMain, light_change},
      main_crossroad_loop({Cars}, GuiPid, NIsGreenOnMain);

    {CarPid, X, Y, getLight} ->
      if
        IsGreenOnMain =:= 1 ->
          if
            [X, Y] =:= [265, 250] -> CarPid ! {self(), green};
            [X, Y] =:= [340, 265] -> CarPid ! {self(), red};
            [X, Y] =:= [325, 340] -> CarPid ! {self(), green};
            [X, Y] =:= [250, 320] -> CarPid ! {self(), red}
          end;
        true ->
          if
            [X, Y] =:= [265, 250] -> CarPid ! {self(), red};
            [X, Y] =:= [340, 265] -> CarPid ! {self(), green};
            [X, Y] =:= [325, 340] -> CarPid ! {self(), red};
            [X, Y] =:= [250, 320] -> CarPid ! {self(), green}
          end
      end

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

