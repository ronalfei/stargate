#!/bin/sh
NAME="stargate"
screen -dmS $NAME
screen -S $NAME -X screen erl -sname stargate@localhost -pa ebin -pa deps/*/ebin -s stargate -s reloader +K true -setcookie stargate\
    -eval "io:format(\"* Eventsource: http://localhost:8080/eventsource~n~n\"). "
