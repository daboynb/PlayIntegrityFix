#!/system/bin/sh

echo "Put all your JSON files into /storage/emulated/0/pif_to_test."
echo "The good JSON files will be moved to /storage/emulated/0/pif_ok."

sleep 04

# Detect busybox
busybox_path=""

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
fi

# Function to kill gms processes
cls_gms(){
    package_names=("com.google.android.gms" "com.google.android.gms.unstable")

    echo "[+] Killing some apps"

    for package in "${package_names[@]}"; do
        pkill -f "${package}" > /dev/null
    done
}

# Main function
main() {

    # Variables for the apk
    spic="com.henrikherzig.playintegritychecker"
    local_apk_path="/data/local/tmp/spic-v1.4.0.apk"
    apk_url="https://github.com/herzhenr/spic-android/releases/download/v1.4.0/spic-v1.4.0.apk"

    # Check if SPIC app is already installed
    if pm list packages | "$busybox_path" grep "$spic" >/dev/null 2>&1; then
        echo ""
        echo "The SPIC app is already installed!"
        echo ""
    else
        echo "Downloading SPIC app..."
        /system/bin/curl -L "$apk_url" -o "$local_apk_path" >/dev/null 2>&1

        echo "Installing SPIC app..."
        pm install "$local_apk_path"
        rm "$local_apk_path" >/dev/null 2>&1
    fi

    # Variables for log
    TEST_DIR="/storage/emulated/0"
    INPUT_DIR="$TEST_DIR/pif_to_test"
    OUTPUT_DIR="$TEST_DIR/pif_ok"

    # Iterate over JSON files
    for json_file in "$INPUT_DIR"/*.json; do
        xml="$TEST_DIR/testresult.xml"

        # Copy JSON file to /data/adb/pif.json
        cp "$json_file" /data/adb/pif.json

        # Kill the spic app
        killall $spic >/dev/null 2>&1

        # Start the automation
        echo "The SPIC app will open in 3 seconds... DO NOT TOUCH ANYTHING!"
        echo "It will be closed automatically!"
        echo ""
        sleep 3

        # Launch the app
        cls_gms
        am start -n $spic/$spic.MainActivity >/dev/null 2>&1
        sleep 4

        # Use input to start a check
        input keyevent KEYCODE_DPAD_UP
        sleep 1
        input keyevent KEYCODE_DPAD_UP
        sleep 1
        input keyevent KEYCODE_DPAD_UP
        sleep 1
        input keyevent KEYCODE_ENTER
        sleep 7

        # Ensure output directory exists
        mkdir -p "$OUTPUT_DIR"

        # Dump the current app result
        uiautomator dump "$xml" >/dev/null 2>&1

        # Kill the app again
        killall $spic >/dev/null 2>&1

        # Check if the app hit the maximum request per day
        spic_error="TOO_MANY_REQUESTS" 
        if "$busybox_path" grep -q "$spic_error" "$xml"; then
            echo ""
            echo "$spic_error detected."
            echo ""
            echo "The app hit the maximum API request per day!"
            exit
        fi

        # Check if passing DEVICE INTEGRITY
        SPIC_MEETS_DEVICE_INTEGRITY="MEETS_DEVICE_INTEGRITY" 
        if "$busybox_path" grep -q "$SPIC_MEETS_DEVICE_INTEGRITY" "$xml"; then
            echo ""
            echo "$SPIC_MEETS_DEVICE_INTEGRITY detected."
            echo ""
            echo "Pif.json is ok, moving to $OUTPUT_DIR"
            mv "$json_file" "$OUTPUT_DIR/"
        fi

        # If no integrity
        integrities=("NO_INTEGRITY" "MEETS_BASIC_INTEGRITY")

        for meets in "${integrities[@]}"; do
            if "$busybox_path" grep -q "$meets" "$xml"; then
                echo "$meets detected."
                break
            fi
        done

        if [ "$meets" = "NO_INTEGRITY" ] || [ "$meets" = "MEETS_BASIC_INTEGRITY" ]; then
            echo "Pif.json is not good!"
            rm "$xml" 
            rm "$json_file"
        fi
    done
}

# Execute main function
main