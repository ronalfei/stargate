-module(stargate_app).
-behaviour(application).

-export([start/0, start/2, log/1]).
-export([stop/1]).

start() -> 
	application:start(stargate).

start(_Type, _Args) ->
	ok = lager:start(),
    ok = ensure_application_start(sasl),
    ok = ensure_application_start(crypto),
    ok = ensure_application_start(ranch),
	stargate_sup:start_link().

stop(_State) ->
	ok.


log(Level) ->
	lager:set_loglevel(lager_console_backend, Level).


ensure_application_start(App) ->
    case application:start(App) of 
        ok -> ok;
        {error,{already_started,sasl}} -> ok;
        _Any -> io:format("application ~p start error: ~p", [App, _Any]), error
    end.
