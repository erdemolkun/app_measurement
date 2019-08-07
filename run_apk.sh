#!/bin/bash
usage() { echo "Usage: $0 [-s <com.package.name/activity] [-c <count ex : 5>]" 1>&2; exit 1; }

while getopts ":s:c:" o; do
    case "${o}" in
        s)
            s=${OPTARG}
            #((s == 45 || s == 90)) || usage
            ;;
        c)
            c=${OPTARG}
            #((s == 45 || s == 90)) || usage
            ;;
        p)
            p=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${s}" ]; then
    usage
fi

echo "s = ${s}"
echo "p = ${p}"
echo "c = ${c}"

START_ACTIVITY_PATH=${s}

if [ ! -z "${p}" ]; then
	echo "${p}"
    PACKAGE=${p}
else
	#echo "xxxx s: ${s}"
	PACKAGE="$(echo ${s} | cut -d "/" -f 1)"
fi

REPEAT_COUNT=2

if [ ! -z "${c}" ]; then
    REPEAT_COUNT=${c}
    REPEAT_COUNT=$((REPEAT_COUNT))
fi


# Default sleep value
SLEEP_DURATION=1

# Assign command parameter to sleep if available
if [ ! -z "$1" ]; then	
	SLEEP_DURATION="$1" 	
fi

echo "PACKAGE : $PACKAGE"
echo "REPEAT_COUNT : $REPEAT_COUNT"
echo "SLEEP_DURATION : $SLEEP_DURATION"

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


MIN_SDK_FOR_MEMORY=21
MIN_SDK=$(( MIN_SDK_FOR_MEMORY ))
SDK_VER=$((deviceSdkVersion))


logCatResult=""
successCount=0
totalDuration=0
totalPssMemory=0;

prevent_sleep() {
  adb shell input keyevent 82
}

sleep_now(){
	#echo "Sleeping $SLEEP_DURATION seconds"
	sleep $((SLEEP_DURATION))
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
		for item in "${STR_ARRAY[@]}"
		do

			if (( $j == 1 )) ; then
				millis=$(echo $item|cut -d"m" -f1) # extract integer from value with m (ex : 100ms)
				parsedMs=$((parsedMs+millis))

			elif (( $j == 0 )) ; then
		    	if(( $arrayLength == 1 )) ; then
		    		parsedMs=$((duration))
		    	elif (( $arrayLength == 2 )) ; then
		    		parsedMs=$((item*1000)) ## Converting seconds to millis
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
			totalPssMemoryInner="$(adb shell dumpsys meminfo $PACKAGE | grep 'TOTAL:'|cut -d':' -f2|cut -d'T' -f1)"
    	else
    		totalPssMemoryInner="$(adb shell dumpsys meminfo $PACKAGE | grep 'TOTAL' | tr -s ' '|cut -d ' ' -f 3)"
		fi
    	
    	#adb shell dumpsys meminfo com.turkcell.bip | grep 'TOTAL' | tr -s ' '|cut -d ' ' -f 3 # old devices
    	totalPssMemory=$((totalPssMemory+totalPssMemoryInner))
    	echo "Memory Used  : $totalPssMemoryInner"
	fi

	    
	#fi	
    prevent_sleep
	kill_app
	sleep_now
done

echo
echo "-------- RESULTS ---------"
echo
echo "PACKAGE   : $PACKAGE"
echo "VERSION   : "$(adb shell dumpsys package $PACKAGE | grep versionName | cut -d "=" -f 2)
echo "DEVICE    : "$(adb shell getprop ro.product.manufacturer)" "$(adb shell getprop ro.product.model)

if((successCount<=0)); then
	echo "Insufficent Result Count !!!"
else
	echo "Average Memory Usage :  $((totalPssMemory/successCount))"
	echo "Average Boot Duration :  $((totalDuration/successCount)) ms"
	echo "Success Ratio :  $successCount/$REPEAT_COUNT"
	echo
fi

