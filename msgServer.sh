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
    $(./worker.sh $counter)
    $counter=$(( $counter + 1 ))
    echo "Created worker ${counter}"
done

currWorker=0
while [ $terminate != 0 ]
do
    sleep 3
    if read line ; then

        if [ "$line" == 'shutdown' ] ; then
            exit 0
        elif [ "$line" == 'status' ] ; then
            echo $workers
            echo "test"
        else
            echo $line > /tmp/worker-$USER-$currWorker-inputfifo
            $currWorker=$(( $currWorker + 1 ))

            if [ $currWorker -eq $workers ] ; then
                $currWorker=$(( $currWorker - 8 ))
            fi

        fi

    fi
done </tmp/server-$USER-inputfifo
