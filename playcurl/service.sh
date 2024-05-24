#!/system/bin/sh

#################################### functions
# Detect busybox
busybox_path=""

# Find busybox
for busybox in $(find /data/adb -name busybox -type f -size +1M)
do
    if [ "$($busybox | grep 'BusyBox')" ];then
        busybox_path="$busybox"
    fi
done

# Check if boot completed
check_boot_completed() {
    if [ "$(getprop sys.boot_completed)" = "1" ]; then
        echo "Boot process completed"
        return 0
    else
        echo "Boot process not completed."
        return 1
    fi
}

# Check if internet is working
check_network_reachable() {
    count=0
    while [ $count -lt 3 ]; do
        if ping -c1 www.gstatic.com > /dev/null 2>&1; then
            count=$((count + 1))
        else
            count=0
        fi
        sleep 1
    done
    return 0
}

check_pif_diff() {
    # Download the fp
    if $busybox_path wget --no-check-certificate -q -O- ipinfo.io | grep 'CN' > /dev/null 2>&1; then
        $busybox_path wget --no-check-certificate -q -O /data/adb/remote_pif.json https://mirror.ghproxy.com/https://raw.githubusercontent.com/daboynb/autojson/main/pif.json
    else
        $busybox_path wget --no-check-certificate -q -O /data/adb/remote_pif.json https://raw.githubusercontent.com/daboynb/autojson/main/pif.json
    fi
    
    # Check if pif.json exists
    if [ -e /data/adb/pif.json ]; then
        pif_file="/data/adb/pif.json"
    else
        pif_file="/data/adb/modules/playintegrityfix/custom.pif.json"
    fi


    # Check the diff
    if "$busybox_path" diff /data/adb/remote_pif.json "$pif_file"; then
        
        # Get date and time
        current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$current_date_time" > /storage/emulated/0/check_fp.log

        # Get check interval
        echo "Time interval : $time_interval" >> /storage/emulated/0/check_fp.log
        
        echo "The fp is still the same as the one on github." >> /storage/emulated/0/check_fp.log
        echo "Please note: after a ban, the new fp will be pulled after 1 hour." >> /storage/emulated/0/check_fp.log
    else
        # Get date and time
        current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$current_date_time" > /storage/emulated/0/run_fp.log

        # Get check interval
        echo "Time interval : $time_interval" >> /storage/emulated/0/run_fp.log

        /system/bin/fp >> /storage/emulated/0/run_fp.log
    fi

    # Clean up
    rm /data/adb/remote_pif.json
}
####################################

# Loop until the boot process is completed
until check_boot_completed; do
    echo "Waiting for boot process to complete..."
    sleep 05
done

# Check interval
filepath="/data/adb/modules/playcurl/seconds.txt"
time_interval=$(cat "$filepath")

# Check if the fp got banned every 30 minutes 
while true; do
    if check_network_reachable; then
        check_pif_diff
    fi
    sleep "$time_interval" 
done