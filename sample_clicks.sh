
PACKAGE=$1

print_current_memory(){
		
	totalPssMemoryInner1="$(adb shell dumpsys meminfo $PACKAGE | grep 'TOTAL:'|cut -d':' -f2|cut -d'T' -f1)"
    echo "Memory Used After $1 : $totalPssMemoryInner1"
}

sleep_now(){
	sleep 2
}


adb shell input tap 1000 2200 # Oyunlar
sleep_now
	
print_current_memory "Profile"

# adb shell input tap 600 2200 # Keşfet
adb shell input tap 300 2200 # Oyunlar
sleep_now
	
print_current_memory "Calls"


adb shell input tap 800 2200 # Oyunlar
sleep_now
	
print_current_memory "Games"


