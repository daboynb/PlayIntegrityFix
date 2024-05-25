#!/system/bin/sh

# Run the fp command and then disable other modules 
/system/bin/fp

# Detect busybox
busybox_path=""

if [ -f "/data/adb/magisk/busybox" ]; then
    busybox_path="/data/adb/magisk/busybox"
elif [ -f "/data/adb/ksu/bin/busybox" ]; then
    busybox_path="/data/adb/ksu/bin/busybox"
elif [ -f "/data/adb/ap/bin/busybox" ]; then
    busybox_path="/data/adb/ap/bin/busybox"
fi

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