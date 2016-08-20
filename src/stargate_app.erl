-module(stargate_app).
-behaviour(application).

-export([start/0, start/2, log/1]).
-export([stop/1]).

start() -> 
	application:start(stargate).

start(_Type, _Args) ->
	lager:start(),
    application:start(sasl),
    application:start(crypto),
    application:start(ranch),
    application:start(poolboy),
	stargate_sup:start_link().

stop(_State) ->
	ok.


log(Level) ->
	lager:set_loglevel(lager_console_backend, Level).
