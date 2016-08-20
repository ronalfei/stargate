#!/bin/sh
ROOT=`pwd`
EBIN=$ROOT"/ebin"
erl -sname stargate@localhost -pa $EBIN -pa $ROOT/deps/*/ebin -s stargate_app -s reloader \
	-boot start_sasl \
	-sbt db \
     +K true -P 134217727 -Q 134217727 -env  ERL_MAX_PORTS 1024000 -setcookie stargate \
	 +S 12:12 +A 1024 \
     -config $ROOT/_rel/stargate_release/releases/1/sys.config \
     -eval "io:format(\"* stargate service already started !~n~n\")."
