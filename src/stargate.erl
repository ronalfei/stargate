-module(stargate).
-behaviour(application).

-export([start/0, start/2, stop/1]).

-export([log/1]).

start() ->
	application:start(crypto),
	%application:start(public_key),
	%application:start(ssl),
	lager:start(),
	application:start(?MODULE),
	ok.

start(_Type, _Args) ->
	%下面这行启动监听的方式放到了stargate_sup中,使得ranch内嵌到stargate的应用中
	%也可以打开这里，去掉stargate_sup中的这部分代码，行为一样，监控树的层次不一样
	%application:start(ranch),
	%{ok, _} = ranch:start_listener(sg_tcp_server, 4, ranch_tcp, [{port, 8888}], sg_tcp_protocol, []),
	%----------------------------------------------------------------------------
	stargate_sup:start_link().

stop(_State) ->
	ok.




%%----------------------
log(debug) ->
    lager:set_loglevel(lager_console_backend, debug);
log(info) ->
    lager:set_loglevel(lager_console_backend, info);
log(warning) ->
    lager:set_loglevel(lager_console_backend, warning);
log(error) ->
    lager:set_loglevel(lager_console_backend, error).
