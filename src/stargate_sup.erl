-module(stargate_sup).
-behaviour(supervisor).
-include("lager.hrl").

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	%NLPAgent = ranch:child_spec(nlp_agent, 24, ranch_tcp, [{port, 8601}], raw_tcp_handler, [{pool, {"nlp", 6}}]),
	%VSDAAgent = ranch:child_spec(vsda_agent, 24, ranch_tcp, [{port, 8605}], raw_tcp_handler, [{pool, "vsda"}]),
	%Echo = ranch:child_spec(echo, 24, ranch_tcp, [{port, 8606}], echo_handler, []),
	%RiakAgent = ranch:child_spec(riak_agent, 24, ranch_tcp, [{port, 8602}], raw_tcp_handler, [{pool, "riak"}]),
	%SwooleAgent = ranch:child_spec(swoole_agent, 24, ranch_tcp, [{port, 8604}], raw_tcp_handler, [{pool, "swoole"}]),
    PoolAgent = load_ranch_spec(),

	PoolSup = {pool_sup,
                    {pool_sup, start_link, []},
                    permanent, 5000, supervisor, [pool_sup]
               },
	Procs = [ PoolSup | PoolAgent],
	{ok, {{one_for_one, 1, 5}, Procs}}.


load_ranch_spec() ->
    {ok, PoolList} = config:load(),
    RanchSpecs = [ ranch:child_spec(X, 24, ranch_tcp, [{port,Y}], H, [{pool, {atom_to_list(X), length(Z)}}])
            ||{X, {listen,Y}, {handler, H}, Z} <- PoolList],
    lager:info("RanchSpecs:~p", [RanchSpecs]),
    RanchSpecs.
