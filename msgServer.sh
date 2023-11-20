#! /bin/bash

workers=$(cat /proc/cpuinfo | grep processor | wc -l)
USER=cfrase15
terminate=1

if [ ! -p /tmp/server-$USER-inputfifo ] ; then 
    mkfifo /tmp/server-$USER-inputfifo
else
    rm /tmp/server-$USER-inputfifo
    mkfifo /tmp/server-$USER-inputfifo
fi

counter=0
while [ $counter -ne $workers ] 
do
    . worker.sh $counter &
    let "counter=counter+1"
done
echo "Initialized ${workers} workers!"

currWorker=0
while [ $terminate != 0 ]
do
    echo "Read FIFO"
    sleep 2
    if read line ; then

        if [ "$line" == 'shutdown' ] ; then
            let "terminate=0"
            let "counter=0"
            while [ $counter -ne $workers ] 
            do
                echo "shutdown" > /tmp/worker-$USER-$counter-inputfifo
                let "counter=counter+1"
            done
        elif [ "$line" == 'status' ] ; then
            echo $workers
            echo "test"
        else
            echo $line > /tmp/worker-$USER-$currWorker-inputfifo
            let "currWorker=currWorker+1"

            if [ $currWorker -eq $workers ] ; then
                let "currWorker=currWorker-8"
            fi

        fi

    fi
done </tmp/server-$USER-inputfifo

rm /tmp/server-$USER-inputfifo
