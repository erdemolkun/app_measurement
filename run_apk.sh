if ! type adb; then
    echo "adb not found"
    echo "check PATH"
    exit
fi

adbDevices="$(echo $(adb devices) | cut -d' ' -f5)"

if [ ! -z "$adbDevices" ]; then	
	echo "Device Attached"
else
	echo "Device Not Attached Exiting"
	exit
fi		

echo "---------------- Starting Tests   ---------------"

$(adb shell getprop ro.build.version.sdk > /tmp/aa) 
deviceSdkVersion=$(cat /tmp/aa|tr -d $'\r')

echo "Android SDK Version:$deviceSdkVersion"

START_ACTIVITY_PATH=$1
PACKAGE=$2
REPEAT_COUNT=$3

MIN_SDK_FOR_MEMORY=21
MIN_SDK=$(( MIN_SDK_FOR_MEMORY ))
SDK_VER=$((deviceSdkVersion))

SLEEP=.6

# Assign command parameter to sleep if available
if [ ! -z "$4" ]; then	
	SLEEP=$4	
fi


echo "Activity-> $1 | Package-> $2 | Times-> $3 | Sleep-> $SLEEP seconds"

logCatResult=""
successCount=0
totalDuration=0
totalPssMemory=0;

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
#sleep_now

for ((i=0;i<$REPEAT_COUNT;i++)); do
	echo
    start_app
    sleep_now
    #logCatResult="$(adb logcat -d -t 2000 | grep $START_ACTIVITY_PATH | grep 'ActivityTaskManager: Displayed')"
    logCatResult="$(adb logcat -d -t 2000 | grep ': Displayed')"
    #echo "LOGCAT RESULT : $logCatResult"
    
    if [ ! -z "$logCatResult" ]; then	
		#duration=$(echo $logCatResult|cut -d" " -f 18|cut -c2-|cut -d"m" -f1)
		duration=$(echo ${logCatResult##*:}|cut -d"m" -f1) # 1s200ms TODO parse this
		echo "Duration : $duration"
		
		j=0 
		parsedMs=0
		STR_ARRAY=(`echo $duration | tr "s" "\n"`)
		arrayLength=${#STR_ARRAY[@]}
		for x in "${STR_ARRAY[@]}"
		do

			if (( $j == 1 )) ; then
				millis=$(echo $x|cut -d"m" -f1) # extract integer from value with m (ex : 100ms)
				parsedMs=$((parsedMs+millis))

			elif (( $j == 0 )) ; then
		    	if(( $arrayLength == 1 )) ; then
		    		parsedMs=$((duration))
		    	elif (( $arrayLength == 2 )) ; then
		    		parsedMs=$((x*1000)) ## Converting seconds to millis
		    	fi	
			fi

			j=$((j+1))
			
		done
		
		duration=$((parsedMs))	
		totalDuration=$((totalDuration+duration))
		#echo "Parsed Duration : $duration totalDuration : $totalDuration parsedMs : $parsedMs\n"
		successCount=$((successCount+1))
		sleep_now

		if [ "$SDK_VER" -gt "$MIN_SDK" ]; then			
			totalPssMemoryInner="$(adb shell dumpsys meminfo com.turkcell.bip | grep 'TOTAL:'|cut -d':' -f2|cut -d'T' -f1)"
    	else
    		totalPssMemoryInner="$(adb shell dumpsys meminfo com.turkcell.bip | grep 'TOTAL' | tr -s ' '|cut -d ' ' -f 3)"
		fi
    	
    	#adb shell dumpsys meminfo com.turkcell.bip | grep 'TOTAL' | tr -s ' '|cut -d ' ' -f 3 # old devices
    	totalPssMemory=$((totalPssMemory+totalPssMemoryInner))
    	echo "Memory Used  : $totalPssMemoryInner"
	fi

	    
	#fi	
    sleep_now
    prevent_sleep
	kill_app
	sleep_now
done

echo "\n-------- RESULTS ---------\n"
echo "Average Memory Usage :  $((totalPssMemory/successCount))"
echo "Average Boot Duration :  $((totalDuration/successCount)) ms"
echo "Success Ratio :  $successCount/$REPEAT_COUNT"






