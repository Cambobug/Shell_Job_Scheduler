#! /bin/bash

USER=cfrase15
serverPipe=/tmp/server-$USER-inputfifo

if [ $# == 0 ] ; then # checks if the worker was given its number
    echo "Worker not given number"  
    exit 0
fi

logFile="/tmp/worker-$USER.$1.log"

echo "Worker $1 initiated!" > $logFile
terminate=1
jobsCompleted=0
while [ $terminate != 0 ]
do
    sleep 0.1
    if read -r line < /tmp/worker-$USER-$1-inputfifo ; then
        if [ "$line" == 'shutdown' ] ; then
            echo "Worker $1 exiting" >> $logFile
            rm /tmp/worker-$USER-$1-inputfifo
            let "terminate=0"
        else
            echo "----------- Job ${jobsCompleted} -----------" >> $logFile
            echo "Worker $1 running ${line}" >> $logFile
            eval "$line" >> $logFile
            let "jobsCompleted=jobsCompleted+1"
            echo "SPEC@$1" >> $serverPipe
        fi
    fi
done