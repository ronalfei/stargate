-include("lager.hrl").
-module(connection).
-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([start_link/1, ready/3, send/2, free/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-record(state, {socket, status='idle', client,  transport, args}). % status = [idle | run]

%%-----------------API functions---------------------
start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

ready(Pid, Client, Transport) ->
	gen_server:call(Pid, {ready, Client, Transport}).

send(Pid, Pack) ->
	gen_server:cast(Pid, {send, Pack}).

free(Pid) ->
	gen_server:call(Pid, {free}).
	

%%-----------------callback functions--------------
init(Args) ->
	lager:debug("pool args:~p", [Args]),
    process_flag(trap_exit, true),
	{ok, Socket} = connect(Args),
    {ok, #state{socket=Socket, args=Args}}.

handle_call({'ready', Client, Transport}, _From, State) ->
	State1 = #state{status=run, client=Client, transport=Transport, args=State#state.args, socket=State#state.socket},
lager:debug("connection pid ~p ready, state ~p", [self(), State1]),
	{reply, <<"ready">>, State1};

handle_call({'free'}, _From, State) ->
	State1 = #state{status=idle, client=undefined, transport=undefined, args=State#state.args, socket=State#state.socket},
lager:debug("connection pid ~p state ~p free from ~p", [self(), State1, _From]),
	{reply, <<"free">>, State1};

handle_call(_Request, _From, State) ->
    {reply, nomatchfunc, State}.

handle_cast({'send', Pack}, State) ->
	Socket = State#state.socket,
lager:notice("send to connection process ~p , state:~p, packlength: ~p ", [self(), State, erlang:byte_size(Pack) ]),
	Ret = gen_tcp:send(Socket, Pack),
lager:debug("send over! send result : ~p, State:~p", [Ret, State]),
	{noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({'tcp', _Socket, Data}, State) ->
	Client = State#state.client,
	case erlang:is_port(Client) of 
		true ->
			Transport = State#state.transport,
			lager:debug("connection pid ~p connection socket ~p transport send to client ~p", [self(), State#state.socket, Client]),
			%lager:debug("data is ~p", [Data]),
		    Ret =Transport:send(Client, Data),
			lager:debug("connection pid ~p connection socket ~p transport send to client ~p result:~p", [self(), State#state.socket, Client, Ret] );
		false ->
			lager:warning("connection pid ~p connection socket ~p receive data:~s, but no user Client ~p here", [self(), State#state.socket, Data, Client]),
			false
	end,
    {noreply, State};


handle_info({tcp_closed, Port}, State) ->
	lager:info("connection pid ~p receive tcp closed from connection port ~p", [self(), Port]),
	gen_tcp:close(Port),
	{ok, Socket} = connect(State#state.args),
	lager:info("connection pid ~p connect ~p ok", [self(), State#state.args]),
	State1 = #state{status = State#state.status
					, client = State#state.client
					, transport = State#state.transport
					, args = State#state.args
					, socket = Socket},
    {noreply, State1};
	%{stop, normal, State};


handle_info({reconnect}, State) ->
	{ok, Socket} = connect(State#state.args),
	lager:warning("connection pid ~p reconnect ~p ,Socket ~p", [self(), State#state.args, Socket]),
	State1 = #state{status = State#state.status
					, client = State#state.client
					, transport = State#state.transport
					, args = State#state.args
					, socket = Socket},
    {noreply, State1};
	%{stop, normal, State};



handle_info(_Info, State) ->
	lager:warning("connection pid ~p receive something ~p , state~p", [self(), _Info, State]),
    {noreply, State}.

terminate(_Reason, #state{socket=_Socket}) ->
    %gen_tcp:close(Socket),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%=============internal function ==============
connect(Args) ->
    Hostname = proplists:get_value(host, Args),
    Port     = proplists:get_value(port, Args),
	Options	 = [{active, true}, {keepalive, true}],
	Timeout  = 5000,  % 5 seconds
    case gen_tcp:connect(Hostname, Port, Options, Timeout) of
        {ok, Socket} -> {ok, Socket};
        _ ->
            erlang:send_after(2000, self(), {reconnect}),
            {ok, nil}
    end.
