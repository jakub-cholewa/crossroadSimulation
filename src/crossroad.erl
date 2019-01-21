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
      CarPid = car:start(Position, Direction, X, Y, GuiPid, self()),
      %Dodanie samochodu do listy samochodow którą posiada skrzyzowanie
      NewCars = orddict:store(CarPid, {Position, Direction, X, Y}, Cars),
      io:format("Lista samochodow: ~p~n", [NewCars]),
      %Wysłanie odpowiedzi o sukcesie do procesu który wysłał wiadomość (funkcja add_car/2)
      CrossPid ! {MsgRef, ok},
      % wyslanie informacji do gui o nowym samochodzie
      GuiPid ! {NewCars, newCarAdded},
      %Ponowne wywołanie pętli głównej programu stacji z nową listą(orddict) pociągów
      main_crossroad_loop({NewCars}, GuiPid, IsGreenOnMain);

    % samochód wyjechał poza obszar
    {CarPid, dead} ->
      UpdatedCars = orddict:erase(CarPid,Cars),
      GuiPid ! {UpdatedCars, update},
      exit(CarPid, out_of_border),
      main_crossroad_loop({UpdatedCars}, GuiPid, IsGreenOnMain);

    % samochód się poruszył
    {CarPid, X, Y, moved} ->
      UpdatedCars = orddict:update(CarPid, fun ({Position, Direction, _, _}) -> {Position, Direction, X, Y} end, Cars),
      GuiPid ! {UpdatedCars, update},
      main_crossroad_loop({UpdatedCars}, GuiPid, IsGreenOnMain);

    % sprawdzanie czy samochód może się ruszyć
    {CarPid, X, Y, Position, Direction, getinfo} ->
      UpdatedCars = orddict:erase(CarPid, Cars),
      CarPidsKeys = orddict:fetch_keys(UpdatedCars),
      check_collision(CarPid, CarPidsKeys, UpdatedCars, X, Y, Position, Direction, Cars, GuiPid, IsGreenOnMain);


    % zmiana koloru światła
    {NIsGreenOnMain, light_change} ->
      GuiPid ! {NIsGreenOnMain, light_change},
      main_crossroad_loop({Cars}, GuiPid, NIsGreenOnMain);

    {CarPid, X, Y, getLight} ->
      ligts_color(CarPid, X, Y, IsGreenOnMain),
      main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain)
  end.


ligts_color(CarPid, 265, 250, 1) -> io:format("zielone n~n"), CarPid ! {self(), green, n};
ligts_color(CarPid, 340, 265, 1) -> io:format("czerwone e~n"),CarPid ! {self(), red, e};
ligts_color(CarPid, 325, 340, 1) -> io:format("zielone s~n"),CarPid ! {self(), green, s};
ligts_color(CarPid, 250, 320, 1) -> io:format("czerwone w~n"),CarPid ! {self(), red, w};
ligts_color(CarPid, 265, 250, -1) -> io:format("czerwone n~n"),CarPid ! {self(), red, n};
ligts_color(CarPid, 340, 265, -1) -> io:format("zielone e~n"),CarPid ! {self(), green, e};
ligts_color(CarPid, 325, 340, -1) -> io:format("czerwone s~n"),CarPid ! {self(), red, s};
ligts_color(CarPid, 250, 320, -1) -> io:format("zielone w~n"),CarPid ! {self(), green, w};
ligts_color(_, _ , _ , _) -> io:format("nic"),ok.


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

check_collision(CarPid, CarPidsKeys, UpdatedCars, X, Y, Position, 1, Cars, GuiPid, IsGreenOnMain) ->
  Empty = orddict:is_empty(UpdatedCars),
  if
    Empty =:= true -> CarPid ! { self(), ok},
      main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
    true ->
      LastPid = lists:last(CarPidsKeys),
      FoundCar = orddict:find(LastPid, UpdatedCars),
      {ok, {PositionC, _, _, B}} = FoundCar,
      if
        PositionC =:= Position ->
          if
            Y-11 < B ->
              if
                B < Y+1 ->
                  CarPid ! {self(), stop},
                  main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
                true ->
                  DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
                  DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
                  check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, Position, 1, Cars, GuiPid, IsGreenOnMain)
              end;
            true ->
              DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
              DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
              check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, Position, 1, Cars, GuiPid, IsGreenOnMain)
          end;
        true ->
          DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
          DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
          check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, Position, 1, Cars, GuiPid, IsGreenOnMain)
      end
  end;
check_collision(CarPid, CarPidsKeys, UpdatedCars, X, Y, Position, 2, Cars, GuiPid, IsGreenOnMain) ->
  Empty = orddict:is_empty(UpdatedCars),
  if
    Empty =:= true -> CarPid ! { self(), ok},
      main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
    true ->
      LastPid = lists:last(CarPidsKeys),
      FoundCar = orddict:find(LastPid, UpdatedCars),
      {ok, {PositionC, _, A, _}} = FoundCar,
      if
        PositionC =:= Position ->
          if
            X-1 < A ->
              if
                A < X+11 ->
                  CarPid ! {self(), stop},
                  main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
                true ->
                  DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
                  DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
                  check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, 2, Position, Cars, GuiPid, IsGreenOnMain)
              end;
            true ->
              DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
              DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
              check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, 2, Position, Cars, GuiPid, IsGreenOnMain)
          end;
        true ->
          DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
          DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
          check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, Position, 2, Cars, GuiPid, IsGreenOnMain)
      end
  end;
check_collision(CarPid, CarPidsKeys, UpdatedCars, X, Y, Position, 3, Cars, GuiPid, IsGreenOnMain) ->
  Empty = orddict:is_empty(UpdatedCars),
  if
    Empty =:= true -> CarPid ! { self(), ok},
      main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
    true ->
      LastPid = lists:last(CarPidsKeys),
      FoundCar = orddict:find(LastPid, UpdatedCars),
      {ok, {PositionC, _, _, B}} = FoundCar,
      if
        PositionC =:= Position ->
          if
            Y-1 < B ->
              if
                B < Y+11 ->
                  CarPid ! {self(), stop},
                  main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
                true ->
                  DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
                  DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
                  check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, Position, 3, Cars, GuiPid, IsGreenOnMain)
              end;
            true ->
              DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
              DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
              check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, Position, 3, Cars, GuiPid, IsGreenOnMain)
          end;
        true ->
          DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
          DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
          check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, Position, 3, Cars, GuiPid, IsGreenOnMain)
      end
  end;
check_collision(CarPid, CarPidsKeys, UpdatedCars, X, Y, Position, 4, Cars, GuiPid, IsGreenOnMain) ->
  Empty = orddict:is_empty(UpdatedCars),
  if
    Empty =:= true -> CarPid ! { self(), ok},
      main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
    true ->
      LastPid = lists:last(CarPidsKeys),
      FoundCar = orddict:find(LastPid, UpdatedCars),
      {ok, {PositionC, _, A, _}} = FoundCar,
      if
        PositionC =:= Position ->
          if
            X-11 < A ->
              if
                A < X+1 ->
                  CarPid ! {self(), stop},
                  main_crossroad_loop({Cars}, GuiPid, IsGreenOnMain);
                true ->
                  DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
                  DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
                  check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, 4, Position, Cars, GuiPid, IsGreenOnMain)
              end;
            true ->
              DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
              DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
              check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, 4, Position, Cars, GuiPid, IsGreenOnMain)
          end;
        true ->
          DeletedLastCar = orddict:erase(LastPid, UpdatedCars),
          DeletedLastPidKey = lists:delete(LastPid, CarPidsKeys),
          check_collision(CarPid, DeletedLastPidKey, DeletedLastCar, X, Y, Position, 4, Cars, GuiPid, IsGreenOnMain)
      end
  end.
