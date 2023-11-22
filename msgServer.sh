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
workerArray=()
while [ $counter -ne $workers ]  #populates 
do
    . worker.sh $counter &
    workerArray[$counter]=0
    let "counter=counter+1"
    
done
echo "Initialized ${workers} workers!"

IFS="@"
currWorker=0
commandQueue=()
while [ $terminate != 0 ]
do
    #echo "Read FIFO"
    sleep 0.1
    if read -r line  ; then
        echo $line
        read -ra splits <<< "$line"
        if [ "${splits[0]}" == 'SPEC' ] ; then #special command
            echo "  in SPEC"
            if [ "${splits[1]}" == 'shutdown' ] ; then #shutdown
                echo "      in shutdown"
                let "terminate=0"
                let "counter=0"
                while [ $counter -ne $workers ] 
                do
                    echo "kill me"
                    echo "shutdown" > /tmp/worker-$USER-$counter-inputfifo &
                    let "counter=counter+1"
                done
                echo "          shudowns sent"

                procTerm=0
                while [ $procTerm -ne $workers ] # loop checks the FIFO until it finds the workers exit 
                do  
                    if read -r line  ; then
                        read -ra splits <<< "$line"
                        if [ "${splits[0]}" == 'SPEC' ] ; then
                            if [ "${splits[1]}" == 'exit' ] ; then
                                echo "Proc Exited"
                                let "procTerm=procTerm+1"
                            fi
                        fi
                    fi
                done < /tmp/server-$USER-inputfifo

            elif [ "${splits[1]}" == 'status' ] ; then #status
                echo $workers
                echo "test"
            else # process must be done, handle number
                procNum="${splits[1]}"
                workerArray["${splits[1]}"]=0

                if [ "${workerArray[$currWorker]}" -eq 0 ] ; then #if the current worker is available to 
                    echo "${commandQueue[0]}" > /tmp/worker-$USER-$currWorker-inputfifo
                    workerArray[$currWorker]=1
                    let "currWorker=currWorker+1"

                    if [ $currWorker -eq $workers ] ; then
                        let "currWorker=currWorker-8"
                    fi
                    commandQueue=("${commandQueue[@]:1}")
                fi
                
            fi

        elif [ "${splits[0]}" == 'CMD' ] ; then #command
            echo $currWorker "${workerArray[$currworker]}"
            commandQueue+=("${splits[1]}") #places a command in the queue

            if [ "${workerArray[$currWorker]}" -eq 0 ] ; then #if the current worker is available to 
                echo "${commandQueue[0]}" > /tmp/worker-$USER-$currWorker-inputfifo
                let "workerArray[$currWorker]=1"
                let "currWorker=currWorker+1"

                if [ $currWorker -eq $workers ] ; then
                    let "currWorker=currWorker-8"
                fi
                commandQueue=("${commandQueue[@]:1}")
            fi
            
        fi
    fi
done < /tmp/server-$USER-inputfifo

rm /tmp/server-$USER-inputfifo
