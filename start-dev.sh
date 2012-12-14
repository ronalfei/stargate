#!/bin/sh
erl -boot start_sasl -sname stargate@localhost -pa ebin -pa deps/*/ebin -s stargate -s reloader +K true -setcookie sg \
    -eval "io:format(\"* Eventsource: http://localhost:8080/eventsource~n~n\")."
