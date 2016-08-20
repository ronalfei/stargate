-include("../lager.hrl").
-module(echo_handler).
-export([start_link/4]).
-export([init/4]).

start_link(Ref, USocket, Transport, Opts) ->
    Pid = spawn_link(?MODULE, init, [Ref, USocket, Transport, Opts]),
    {ok, Pid}.

init(Ref, USocket, Transport, Opts) ->
	lager:debug("ranch init opts ~p ", [Opts]),
    ok = ranch:accept_ack(Ref),
    loop(USocket, Transport).

loop(USocket, Transport) ->
    case Transport:recv(USocket, 0, 5000) of
        {ok, _Body} ->
            Pid = poolboy:checkout(nlp),
			Transport:send(USocket, <<"ok">>),
            if 
                Pid =:= full -> ok;
                true -> 
                    poolboy:checkin(nlp, Pid)
            end,
            loop(USocket, Transport);
        _Any ->
			lager:debug("receive any: ~p", [_Any]),
            ok = Transport:close(USocket)
    end.
