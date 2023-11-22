#! /bin/bash

USER=cfrase15
serverPipe=/tmp/server-$USER-inputfifo

if [ $# -eq 0 ]; then
    echo "submitJob: Job not given!"  
    exit 1
fi

if [ ! -p "$serverPipe" ] ; then 
    echo "Server pipe doesnt exist"
    exit 1
fi

if [ "$1" == '-x' ] ; then
    echo 'SPEC@shutdown' > "$serverPipe"
elif [ "$1" == '-s' ] ; then
    echo 'SPEC@status' > "$serverPipe"
else
    echo  "CMD@$@" > "$serverPipe"
fi