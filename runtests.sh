expectedWorkers=$(cat /proc/cpuinfo | grep processor | wc -l)
USER=cfrase15

echo "----------- TEST 1 -----------"
echo "Starting server and workers!"

./msgServer.sh &

sleep 2

counter=0
filesFound=0
while [ $counter -ne $expectedWorkers ] 
do
    if [ -e "/tmp/worker-$USER-${counter}-inputfifo" ] ; then
        let "filesFound=filesFound+1"
    fi
    let "counter=counter+1"
done

if [ $filesFound -eq $expectedWorkers ] ; then
    echo "PASS: Expected number of workers exist!"
else
    echo "FAIL: Expected number of workers do not exist!"
fi
sleep 1

echo "----------- TEST 2 -----------"
echo "Checking for log files!"

let "counter=0"
let "filesFound=0"
while [ $counter -ne $expectedWorkers ] 
do
    if [ -e "/tmp/worker-$USER.${counter}.log" ] ; then
        let "filesFound=filesFound+1"
    fi
    let "counter=counter+1"
done

if [ $filesFound -eq $expectedWorkers ] ; then
    echo "PASS: Expected number of log files exist!"
else
    echo "FAIL: Expected number of log files do not exist!"
fi
sleep 1

echo "----------- TEST 3 -----------"
echo "Passing each worker a sleep 10 command"

let "counter=0"
while [ $counter -ne $expectedWorkers ] 
do
    ./submitJob.sh 'sleep 1' 
    let "counter=counter+1"
    sleep 0.1
done

sleep 3

let "counter=0"
numFinds=0
while [ $counter -ne $expectedWorkers ]
do
    result=$(grep -ci "sleep 1" "/tmp/worker-$USER.${counter}.log")
    let "numFinds=numFinds+result"
    let "counter=counter+1"
done

if [ $numFinds -eq $expectedWorkers ] ; then
    echo "PASS: Expected number of sleep commands found exist!"
else
    echo "FAIL: Expected number of sleep commands not found!"
fi
sleep 1

echo "----------- TEST Y -----------"
echo "Running status command"

./submitJob.sh -s
sleep 1

echo "----------- TEST X -----------"
echo "Sending shutdown command"

./submitJob.sh -x

sleep 2

if [ ! -e "/tmp/server-$USER-inputfifo" ] ; then 
    echo "PASS: Server pipe has been removed!"
else
    echo "FAIL: Server pipe has not been removed!"
fi

let "counter=0"
let "filesFound=0"
while [ $counter -ne $expectedWorkers ] 
do
    if [ -e "/tmp/worker-$USER-${counter}-inputfifo" ] ; then
        let "filesFound=filesFound+1"
    fi
    let "counter=counter+1"
done

if [ $filesFound -eq 0 ] ; then
    echo "PASS: Worker pipes have been removed!"
else
    echo "FAIL: Worker pipes have not been all removed!"
fi
sleep 1

echo "----------- TEST Z -----------"
echo "Checking existence of log files"

let "counter=0"
let "filesFound=0"
while [ $counter -ne $expectedWorkers ] 
do
    if [ -e "/tmp/worker-$USER.${counter}.log" ] ; then
        let "filesFound=filesFound+1"
    fi
    let "counter=counter+1"
done

if [ $filesFound -eq $expectedWorkers ] ; then
    echo "PASS: Worker log files still exist!"
else
    echo "FAIL: Worker log files cannot be found!"
fi
