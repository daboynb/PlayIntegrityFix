#!/system/bin/sh

# Run the fp command and then disable other modules 
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

# Disable other modules for testing incompatibility
list="$("$busybox_path" find /data/adb/modules/* -prune -type d)"
for module in $list; do
    touch "$module/disable"
done

rm /data/adb/modules/playintegrityfix/disable > /dev/null 2>/dev/null
rm /data/adb/modules/playcurl/disable > /dev/null 2>/dev/null
rm /data/adb/modules/zygisksu/disable > /dev/null 2>/dev/null

# Auto delete the script
rm "$0" > /dev/null 2>/dev/null

reboot >/dev/null 2>&1

echo "The phone should have rebooted by itself. If you are reading this, reboot manually!"