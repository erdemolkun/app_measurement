
echo "------------------ Starting Tests   ---------------"
echo "\n\nActivity-> $1 | Package-> $2 | Times-> $3\n"

START_ACTIVITY_PATH=$1
PACKAGE=$2
REPEAT_COUNT=$3

SLEEP=3

logCatResult=""
successCount=0
totalDuration=0

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
    echo "LOGCAT RESULT : $logCatResult"

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
	fi

	    
	#fi	
    sleep_now
    prevent_sleep
	kill_app
	sleep_now
done

echo "Average Boot Duration :  $((totalDuration/successCount)) ms"
echo "Success Ratio :  $successCount/$REPEAT_COUNT\n"





