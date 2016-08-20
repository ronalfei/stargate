-include("../lager.hrl").
-module(raw_tcp_handler).
-export([start_link/4]).
-export([init/4]).

start_link(Ref, USocket, Transport, Opts) ->
    Pid = spawn_link(?MODULE, init, [Ref, USocket, Transport, Opts]),
    {ok, Pid}.

init(Ref, USocket, Transport, Opts) ->
	lager:debug("ranch init opts ~p ", [Opts]),
    ok = ranch:accept_ack(Ref),
    loop(USocket, Transport, Opts).

loop(USocket, Transport, Opts) ->
    case Transport:recv(USocket, 0, 5000) of
        {ok, Body} ->
            PoolName = poolname(Opts),
            ConnectionPid = poolboy:checkout(PoolName),
			if
				ConnectionPid =:= full ->
					%lager:warning("full"),
					Transport:send(USocket, <<"full">>);
            		%ok = Transport:close(USocket);
				true ->
					connection:ready(ConnectionPid, USocket, Transport),
					connection:send(ConnectionPid, Body),
            		loop(USocket, Transport, PoolName, ConnectionPid)
			end;
        _Any ->
			lager:debug("client port ~p receive any: ~p", [USocket, _Any]),
            ok = Transport:close(USocket)
    end.


loop(USocket, Transport, PoolName, ConnectionPid) ->
 	case Transport:recv(USocket, 0, 5000) of
		{ok, Body} ->
lager:notice(" ~p receive second body from user client.  length: ~p" ,[USocket, erlang:byte_size(Body)]),
			connection:send(ConnectionPid, Body),
			loop(USocket, Transport, PoolName, ConnectionPid);
        {error, Error} ->
			lager:debug("receive Error from user client ~p : ~p", [USocket, Error]),
            ok = Transport:close(USocket),
			connection:free(ConnectionPid),
			poolboy:checkin(PoolName, ConnectionPid);
		_Any ->
			lager:debug("receive _Any from user client ~p : ~s", [USocket, _Any]),
            ok = Transport:close(USocket),
			connection:free(ConnectionPid),
			poolboy:checkin(PoolName, ConnectionPid)
	end.




poolname(Opts) ->
	Pool = proplists:get_value(pool, Opts),
    PoolName = case Pool of
        {Name, 1} ->
            list_to_atom(Name++"_1");
        {Name, Number} ->
            list_to_atom(Name++"_"++integer_to_list(random(Number)));
        Name -> list_to_atom(Name)
    end,
lager:debug("poolname:~p", [PoolName]),
    PoolName.

random(Number) ->
    UniqNum = erlang:unique_integer([positive]),
    (UniqNum rem Number)+1.
