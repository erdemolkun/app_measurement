
echo "------------------ Starting Tests   ---------------"
echo "\n\nActivity-> $1 | Package-> $2 | Times-> $3\n"

START_ACTIVITY_PATH=$1
PACKAGE=$2
REPEAT_COUNT=$3

SLEEP=1

logCatResult=""
successCount=0

prevent_sleep() {
  adb shell input keyevent 82
}

sleep_now(){
	#echo "Sleeping $SLEEP seconds"
	sleep $SLEEP
}

kill_app(){
	#echo "\nKilling package $2"
	adb shell am force-stop $PACKAGE
}

start_app(){
	adb shell am start -n $START_ACTIVITY_PATH
}

prevent_sleep
kill_app
sleep_now

for ((i=0;i<$REPEAT_COUNT;i++)); do
    start_app
    logCatResult="$(adb logcat -d -t 2000 | grep 'ActivityManager: Displayed')"
    echo "RESULT : $logCatResult\n"

if [ ! -z "$logCatResult" ]
then
	#TODO get time from $logCatResult
	successCount=$((successCount+1))    
fi	

    sleep_now
    prevent_sleep
	kill_app
	sleep_now
done

echo "\nSuccess Ratio :  $successCount/$REPEAT_COUNT\n"





