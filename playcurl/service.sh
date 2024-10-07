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

log="/storage/emulated/0/playcurl_service.log"

# Function to check if boot is completed
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 1
done

# Ping Google 3 times
ping -c 3 google.com > /dev/null 2>&1

# Check if the ping was successful
if [ $? -eq 0 ]; then
    echo "Internet connection is available" > "$log"
    # Continue with the rest of the script here
else
    echo "No internet connection" > "$log"
    exit 1
fi

# Proceeding with further tasks after both requirements are met
echo "Both boot process and internet connection are ready. Proceeding with further actions..." > "$log"

while true; do

    ################################################################### Download pif
    echo "[+] Downloading the pif.json"

    # Temp file to capture errors
    if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
        if [ -d /data/adb/modules/tricky_store ]; then
            # Download osmosis.json
            if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/osmosis.json > /dev/null 2> "$log"; then
                echo "[+] Successfully downloaded osmosis.json."
            else
                echo "[-] Failed to download osmosis.json."
                echo "Error: $(cat $log)"
            fi
        else
            # If tricky_store does not exist, download device_osmosis.json
            if /system/bin/curl -o /data/adb/modules/playintegrityfix/custom.pif.json https://raw.githubusercontent.com/daboynb/autojson/main/device_osmosis.json > /dev/null 2> "$log"; then
                echo "[+] Successfully downloaded device_osmosis.json."
            else
                echo "[-] Failed to download device_osmosis.json."
                echo "Error: $(cat $log)"
            fi
        fi
    else
        # Download chiteroman.json
        if /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/main/chiteroman.json" -o /data/adb/pif.json > /dev/null 2> "$log"; then
            echo "[+] Successfully downloaded chiteroman.json."
        else
            echo "[-] Failed to download chiteroman.json."
            echo "Error: $(cat $log)"
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
        killall com.google.android.gms
        killall com.google.android.gms.unstable
    fi
    ###################################################################

    ################################################################### 
    # Sleep for 3 seconds after the echo
    sleep 3

    # Check interval
    filepath="/data/adb/modules/playcurlNEXT/seconds.txt"
    time_interval=$(cat "$filepath")

    sleep "$time_interval" 

done
