-module(config).
-include("lager.hrl").

-export([load/0]).

load() ->
	{ok, Config} = file:consult("./etc/pool.config"),
	lager:info("pool config :~p", [Config]),
	{ok, Config}.


