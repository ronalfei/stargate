%% Feel free to use, reuse and abuse the code in this file.

-module(stargate_sup).
-behaviour(supervisor).

-export([start_link/0]). %% API.
-export([init/1]). %% supervisor.

-define(SUPERVISOR, ?MODULE).

%% API.

-spec start_link() -> {ok, Pid::pid()}.
start_link() ->
	supervisor:start_link({local, ?SUPERVISOR}, ?MODULE, []).

%% supervisor.

init([]) ->
	
	Strategy = {one_for_one, 10, 10}, 
	Procs = [
				%-----not need tcp server because this tcp server have started by ranch------------
				%{sg_tcp_server, {sg_tcp_server, start_link, []}, permanent, 5000, worker, dynamic},
				%----------------------------------------------------------------------------------

				{ranch_sup, {ranch_sup, start_link, []}, permanent, 5000, supervisor, [ranch_sup]},
				ranch:child_spec(sg_tcp_server, 4, ranch_tcp, [{port, 8888}], sg_tcp_protocol, []),
				{sg_udp_server, {sg_udp_server, start_link, []}, permanent, 5000, worker, dynamic}
			],
	{ok, 
		{
			Strategy,
			Procs
		}
	}.
