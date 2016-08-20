-module(pool_sup).
-behaviour(supervisor).
-include("lager.hrl").

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    PoolSpecs = load_specs(),
	{ok, {{one_for_one, 10, 10}, PoolSpecs}}.





%%============== intenal functions======================

load_specs() ->
	{ok, PoolList} = config:load(),
    SpecPools = [ poolboy_spec(X, Z, length(Z), []) || 
        {X, _, _, Z} <- PoolList],
    lists:flatten(SpecPools).


poolboy_spec(_Name, [], _Number, Result) ->
    Result;

poolboy_spec(NameString, [H|T], Number, Result) ->
    Name = list_to_atom(atom_to_list(NameString)++"_"++integer_to_list(Number)),
    {SizeArgs, WorkerArgs} = H,
    PoolArgs = [{name, {local, Name}},                                                               
                    {worker_module, connection}] ++ SizeArgs,                                          
    Spec = poolboy:child_spec(Name, PoolArgs, WorkerArgs),
    lager:debug("poolboy_spec:~p", [Spec]),
    poolboy_spec(NameString, T, Number-1, [Spec|Result]).

    

