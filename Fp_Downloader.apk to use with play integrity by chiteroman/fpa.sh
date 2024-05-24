#!/system/bin/sh

# Run the fp command and then check with SPIC
/system/bin/fp

# Detect busybox
busybox_path=""

# Find busybox
for busybox in $(find /data/adb -name busybox -type f -size +1M)
do
    if [ "$($busybox | grep 'BusyBox')" ];then
        busybox_path="$busybox"
        break
    fi
done

# Variables for the apk
spic="com.henrikherzig.playintegritychecker"
local_apk_path="/data/local/tmp/spic-v1.4.0.apk"

if $busybox_path wget --no-check-certificate -q -O- ipinfo.io | grep 'CN' > /dev/null 2>&1; then
    apk_url="https://mirror.ghproxy.com/https://github.com/herzhenr/spic-android/releases/download/v1.4.0/spic-v1.4.0.apk"
else
    apk_url="https://github.com/herzhenr/spic-android/releases/download/v1.4.0/spic-v1.4.0.apk"
fi

# Check if SPIC app is already installed
if pm list packages | "$busybox_path" grep "$spic" >/dev/null 2>&1; then
    echo ""
    echo "The SPIC app is already installed!"
    echo ""
else
    echo "Downloading SPIC app..."
    $busybox_path wget --no-check-certificate -q -O $local_apk_path "$apk_url" >/dev/null 2>&1

    echo "Installing SPIC app..."
    pm install "$local_apk_path"
    rm "$local_apk_path" >/dev/null 2>&1
fi

# Kill the spic app
killall $spic >/dev/null 2>&1

# Start the automation
echo "The SPIC app will open in 3 seconds... DO NOT TOUCH ANYTHING!"
echo "It will be closed automatically!"
echo ""
sleep 3

# Launch the app
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

# Variables for log
STORAGE_DIR="/storage/emulated/0"
xml="${STORAGE_DIR}/testresult.xml"

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
    echo "All is ok, enjoy!"
    exit
fi

# If no integrity run the fpd command as last chance
integrities=("NO_INTEGRITY" "MEETS_BASIC_INTEGRITY")

for meets in $integrities; do
    if "$busybox_path" grep -q "$meets" "$xml"; then
        echo "$meets detected."
        break
    fi
done

if [ "$meets" = "NO_INTEGRITY" ] || [ "$meets" = "MEETS_BASIC_INTEGRITY" ]; then
    echo "Running the fpd command, the phone will reboot!"
    rm $xml >/dev/null 2>&1
    rm $resultlog >/dev/null 2>&1
    /system/bin/fpd
fi