
################################################################### Check if booted
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    echo "Waiting for boot to complete..."
    sleep 1
done
###################################################################

################################################################### Busybox
# Detect busybox
busybox_path=""

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
fi
###################################################################

################################################################### Check for internet
# Start time for the ping duration (3 minutes)
end_time=$((SECONDS + 180))  # 180 seconds (3 minutes)

while true; do
    # Ping gstatic once
    ping -c 1 gstatic.com > /dev/null 2>&1

    # Check if the ping was successful
    if [ $? -eq 0 ]; then
        echo "Ping successful: Internet connection is available."
        break  # Exit the loop if the ping is successful
    else
        echo "Ping failed: No internet connection."
    fi

    # Check if the time has exceeded 3 minutes
    if [ "$SECONDS" -ge 180 ]; then
        echo "Exceeded 3 minutes of pinging without success."
        break  # Exit if it has been 3 minutes
    fi

    sleep 5  # Wait for 5 seconds before the next ping
done
###################################################################

################################################################### While 
while true; do

    ################################################################### Download pif
    log="/storage/emulated/0/playcurl_service.log"
    rm -f "$log"
    echo "Starting...." > "$log"
    if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
        if [ -d /data/adb/modules/tricky_store ]; then
            # Download osmosis.json
            if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/osmosis.json; then
                current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_date_time [+] Successfully downloaded osmosis.json." >> "$log"
            else
                current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_date_time [-] Failed to download osmosis.json." >> "$log"
            fi
        else
            if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/device_osmosis.json; then
                current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_date_time [+] Successfully downloaded device_osmosis.json." >> "$log"
            else
                current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
                echo "$current_date_time [-] Failed to download device_osmosis.json." >> "$log"
            fi
        fi
    else
        if /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/main/chiteroman.json" -o /data/adb/pif.json; then
            current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
            echo "$current_date_time [+] Successfully downloaded chiteroman.json." >> "$log"
        else
            current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
            echo "$current_date_time [-] Failed to download chiteroman.json." >> "$log"
        fi
    fi

    ###################################################################

    ################################################################### Check unsigned rom
    # Check the keys of /system/etc/security/otacerts.zip
    get_keys=$("$busybox_path" unzip -l /system/etc/security/otacerts.zip)

if echo "$get_keys" | "$busybox_path" grep -q test; then
        # Check for the presence of migrate.sh and use the appropriate file path
        if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
            $busybox_path sed -i 's/"spoofSignature": *0/"spoofSignature": 1/g' /data/adb/modules/playintegrityfix/custom.pif.json
        else
            $busybox_path sed -i 's/"spoofSignature": *"false"/"spoofSignature": "true"/g' /data/adb/pif.json
        fi

        # Kill GMS processes
        echo "Killing GMS processes..." >> "$log"
        killall com.google.android.gms
        killall com.google.android.gms.unstable
    fi
    ###################################################################

    ################################################################### Check interval
    filepath="/data/adb/modules/playcurl/seconds.txt"
    if [ -f "$filepath" ]; then
        current_date_time=$(date +"%Y-%m-%d %H:%M:%S")
        time_interval=$(cat "$filepath")
        echo "$current_date_time Read time interval from $filepath: $time_interval seconds" >> "$log"
        sleep "$time_interval"
    else
        echo "$current_date_time [-] $filepath not found, sleeping for default 300 seconds..." >> "$log"
        sleep 300
    fi
done
###################################################################