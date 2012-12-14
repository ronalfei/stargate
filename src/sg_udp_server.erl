-module(sg_udp_server).
-include("stargate.hrl").
-behaviour(gen_server).

-compile(export_all).

-export([
    start_link/0,
    stop/0
]).

%% Internal exports - gen_server callbacks
-export([init/1,
     handle_call/3,
     handle_cast/2,
     handle_info/2,
     terminate/2,
     code_change/3
    ]).

-record(state, {host, port=?UDP_SERVER_PORT, socket}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
    gen_server:cast(stop).

%%
init([]) ->
	{ok, Socket} = gen_udp:open(?UDP_SERVER_PORT, ?UDP_SERVER_OPTION),
    State = #state{socket=Socket},
    {ok, State}.

handle_call(preadv, _From, State) ->
	{reply, {error, "fail to get preadv curry"}, State};

handle_call(status, _From, State) ->
	Info = <<"you call status">>,
    {reply, Info, State}.

handle_cast(close, State) ->
    Socket = State#state.socket,
	gen_udp:close(Socket),
    {noreply, State};


handle_cast(stop, State) ->
    {stop, normal, State}.


handle_info(Info, State) ->
	lager:debug("udp server received: ~p", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.



%%------------------------test-----------------------------

send_test()->
	{ok, Usocket} = gen_udp:open(10000, [binary]),
	lager:info("open a clien udp socket:~p", [Usocket]),
	Ret = gen_udp:send(Usocket, "127.0.0.1", 9999, <<"fuck this">>),
	lager:info("send msg to udp server over , Result is :~p", [Ret]),
	gen_udp:close(Usocket),
	ok.






