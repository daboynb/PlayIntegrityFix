#!/system/bin/sh

#################################### functions
# Detect busybox
busybox_path=""

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
fi

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
    failure_count=0

    while [ $failure_count -lt 3 ]; do
        if ping -c1 www.gstatic.com > /dev/null 2>&1; then
            return 0
        else
            failure_count=$((failure_count + 1))
        fi
        sleep 1
    done

    return 1
}

check_pif_diff() {
    # Check if pif.json exists
    if [ -e /data/adb/pif.json ]; then
        pif_file="/data/adb/pif.json"
        /system/bin/curl -o /data/adb/remote_pif.json https://raw.githubusercontent.com/daboynb/autojson/main/chiteroman.json
    else
        pif_file="/data/adb/modules/playintegrityfix/custom.pif.json"
        /system/bin/curl -o /data/adb/remote_pif.json https://raw.githubusercontent.com/daboynb/autojson/main/osmosis.json
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