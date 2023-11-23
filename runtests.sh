expectedWorkers=$(cat /proc/cpuinfo | grep processor | wc -l)
USER=cfrase15

echo "----------- TEST 1 -----------"
echo "Starting server and workers!"

./msgServer.sh &

sleep 2

if [ -e "/tmp/server-$USER-inputfifo" ] ; then
    echo "PASS: Expected server FIFO exists!"
else
    echo "FAIL: Expected server FIFO does not exist!"
fi

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
echo "Passing each worker a sleep 1 command"

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

echo "----------- TEST 4 -----------"
echo "Passing each worker an ls command"

let "counter=0"
while [ $counter -ne $expectedWorkers ] 
do
    ./submitJob.sh 'ls' 
    let "counter=counter+1"
    sleep 0.1
done
sleep 3

let "counter=0"
let "numFinds=0"
while [ $counter -ne $expectedWorkers ]
do
    result=$(grep -ci 'msgServer.sh\|runtests.sh\|submitJob\|worker.sh' "/tmp/worker-$USER.${counter}.log")
    if [ $result -eq 4 ] ; then
        let "numFinds=numFinds+1"
    fi
    let "counter=counter+1"
done

if [ $numFinds -eq $expectedWorkers ] ; then
    echo "PASS: Expected number of ls command output found!"
else
    echo "FAIL: Expected number of ls command output not found!"
fi
sleep 1

echo "----------- TEST 5 -----------"
echo "Passing a bad command to a worker"

./submitJob.sh BCommand

result=$(grep -ci 'command not found' "/tmp/worker-$USER.0.log")

if [ $result -eq 1 ] ; then
    echo "PASS: Command was not executed and error message forwarded to logfile!"
else
    echo "FAIL: Command was executed or has no indication of error!"
fi
sleep 1

echo "----------- TEST 6 -----------"
echo "Passing a command with arguments"

./submitJob.sh "ls -l"
sleep 1

result=$(grep -ci 'total' "/tmp/worker-$USER.1.log")

if [ $result -eq 1 ] ; then
    echo "PASS: ls -l entries found in the log file!"
else
    echo "FAIL: ls -l entries not found in the log file!"
fi
sleep 1

echo "----------- TEST 7 -----------"
echo "Passing a pipe command"

./submitJob.sh "ls | wc -l"
sleep 1

result=$(grep -ci '4' "/tmp/worker-$USER.2.log")

if [ $result -eq 1 ] ; then
    echo "PASS: Piped command output found in the log file!"
else
    echo "FAIL: Piped command output not found in the log file!"
fi
sleep 1

echo "----------- TEST 8 -----------"
echo "Running status command"

./submitJob.sh -s
sleep 1

echo "----------- TEST 9 -----------"
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

echo "----------- TEST 10 -----------"
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
