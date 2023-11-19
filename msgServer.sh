#! /bin/bash
USER=cfrase15
terminate=1
if [ ! -p /tmp/server-$USER-inputfifo ] ; then 
    mkfifo /tmp/server-$USER-inputfifo
fi

while [ $terminate != 0 ]
do
    if read line; then
        echo $line
        # terminate=0
    fi
done </tmp/server-$USER-inputfifo
