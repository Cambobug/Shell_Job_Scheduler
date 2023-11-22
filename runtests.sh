
expectedWorkers=$(cat /proc/cpuinfo | grep processor | wc -l)
let "expectedWorkers=expectedWorkers-1"
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

echo "----------- TEST 3 -----------"