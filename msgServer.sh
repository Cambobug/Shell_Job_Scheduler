#! /bin/bash

workers=$(cat /proc/cpuinfo | grep processor | wc -l)
USER=cfrase15
terminate=1

if [ -e /tmp/server-$USER-inputfifo ] ; then
    rm "/tmp/server-$USER-inputfifo"
    mkfifo "/tmp/server-$USER-inputfifo"
fi

if [ ! -p /tmp/server-$USER-inputfifo ] ; then 
    mkfifo "/tmp/server-$USER-inputfifo" 
fi

counter=0
workerArray=()
while [ $counter -ne $workers ]  #populates 
do
    # checks if the fifo pipe exists, creates it if not
    if [ ! -p "/tmp/worker-$USER-${counter}-inputfifo" ] ; then 
        mkfifo "/tmp/worker-$USER-${counter}-inputfifo"
    fi

    . worker.sh $counter &
    workerArray[$counter]=0
    let "counter=counter+1"
done
echo "Initialized ${workers} workers!"

IFS="@"
currWorker=0
tasksCompleted=0
commandQueue=()
while [ $terminate != 0 ]
do
    sleep 0.1
    if read -r line < /tmp/server-$USER-inputfifo ; then
        read -ra splits <<< "$line"
        if [ "${splits[0]}" == 'SPEC' ] ; then #special command

            if [ "${splits[1]}" == 'shutdown' ] ; then #shutdown
                let "terminate=0"
                let "counter=0"
                while [ $counter -ne $workers ] 
                do
                    sleep 0.1
                    echo "shutdown" > "/tmp/worker-$USER-${counter}-inputfifo" &
                    let "counter=counter+1"
                done
                rm /tmp/server-$USER-inputfifo

            elif [ "${splits[1]}" == 'status' ] ; then #status
                echo "Number of workers: $workers"
                echo "Number of completed tasks: $tasksCompleted"
            else # process must be done, handle number
                procNum="${splits[1]}"
                workerArray["${splits[1]}"]=0
                let "tasksCompleted=tasksCompleted+1"
            fi

        elif [ "${splits[0]}" == 'CMD' ] ; then #command
            #echo "Worker $currWorker attempting ${splits[1]}!"
            commandQueue+=("${splits[1]}") #places a command in the queue

            if [ "${workerArray[$currWorker]}" -eq 0 ] ; then #if the current worker is available to 
                echo "${commandQueue[0]}" >> /tmp/worker-$USER-$currWorker-inputfifo
                let "workerArray[$currWorker]=1"
                let "currWorker=currWorker+1"

                if [ $currWorker -eq $workers ] ; then
                    let "currWorker=currWorker-8"
                fi
                commandQueue=("${commandQueue[@]:1}")
            fi
        fi
    fi
done
