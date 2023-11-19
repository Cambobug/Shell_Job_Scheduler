#! /bin/bash

USER=cfrase15
serverPipe=/tmp/server-$USER-inputfifo

if [$# < 2] ; then # checks if the worker was given its number
    echo "Worker not given number"  
    exit 0
fi

logFile="/tmp/worker-$USER.${$1}.log"

if [ ! -p $logFile] ; then
    touch $logFile # creates log file for worker
else
    > $logFile #empties log file, redirects nothin in
fi

# checks if the fifo pipe exists, creates it if not
if [ ! -p /tmp/server-$USER-inputfifo ] ; then 
    mkfifo /tmp/worker-$USER-$1-inputfifo
fi

terminate=1

while [$terminate != 0]
do
    

done