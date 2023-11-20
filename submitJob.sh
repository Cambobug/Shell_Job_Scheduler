#! /bin/bash

USER=cfrase15
serverPipe=/tmp/server-$USER-inputfifo

if [ $# -eq 0 ]; then
    echo "submitJob: Job not given!"  
    exit 1
fi

if [ ! -p /tmp/server-$USER-inputfifo ] ; then 
    echo "Server pipe doesnt exist"
    exit 1
fi

echo Gay

if [ "$1" == '-x' ] ; then
    echo 1
    echo 'shutdown' > "$serverPipe"`
elif [ "$1" == '-s' ] ; then
    echo 2
    echo 'status' > "$serverPipe"
else
    echo 3
    echo "$@"
    echo  "$@" > "$serverPipe"
fi