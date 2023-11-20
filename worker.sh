#! /bin/bash

USER=cfrase15
serverPipe=/tmp/server-$USER-inputfifo

if [ $# == 0 ] ; then # checks if the worker was given its number
    echo "Worker not given number"  
    exit 0
fi

logFile="/tmp/worker-$USER.$1.log"

if [ ! -p $logFile ] ; then
    touch $logFile # creates log file for worker
else
    > $logFile #empties log file, redirects nothin in
fi

# checks if the fifo pipe exists, creates it if not
if [ ! -p /tmp/worker-$USER-$1-inputfifo ] ; then 
    mkfifo /tmp/worker-$USER-$1-inputfifo
fi

terminate=1
jobsCompleted=0
while [ $terminate != 0 ]
do
    sleep 1
    if read line ; then
        if [ "$line" == 'shutdown' ] ; then
            let "terminate=0"
        else
            echo "----------- Job ${jobsCompleted} -----------"
            exec $line > $logFile
            echo "Worker $1 running ${line}"
            echo "Done@$1" > $serverPipe
        fi
    fi

done </tmp/worker-$USER-$1-inputfifo

rm /tmp/worker-$USER-$1-inputfifo