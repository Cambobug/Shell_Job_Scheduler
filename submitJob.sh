#! /bin/bash

USER=cfrase15
serverPipe=/tmp/server-$USER-inputfifo

if [ $# -eq 0 ]; then
    echo "submitJob: Job not given!"  
    exit 1
fi

if [ ! -p $serverPipe ] ; then 
    echo "Server pipe doesnt exist"
    exit 0
fi

if [ "$1" == '-x' ] ; then
    echo 'shutdown' > $serverPipe
elif [ "$1" == '-s' ] ; then
    echo 'status' > $serverPipe
else
    echo  "$@" > $serverPipe
fi