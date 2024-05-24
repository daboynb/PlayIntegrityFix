#!/system/bin/sh

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

# Check for kdrag0n/safetynet-fix
if [ -d "/data/adb/modules/safetynet-fix" ]; then
    echo "The safetynet-fix module is incompatible with pif, remove it and reboot the phone to proceed"
    rm "$0"
    exit 1
fi

# Check for MagiskHidePropsConfig
if [ -d "/data/adb/modules/MagiskHidePropsConf" ]; then
    echo "The MagiskHidePropsConfig module is incompatible with pif, remove it and reboot the phone to proceed"
    rm "$0"
    exit 1
fi

# Check for playintegrityfix
if [ -d "/data/adb/modules/playintegrityfix" ]; then
    :
else
    echo "You need Play Integrity Fix module!"
    rm "$0"
    exit 1
fi

# Check for zygisk if the user is using ksu
if [ "$busybox_path" = "/data/adb/ap/bin/busybox" ]; then
  if [ -d "/data/adb/modules/zygisksu" ]; then
    :
  else
    echo "You need zygisk!"
    rm "$0"
    exit 1
  fi
fi

# Check for zygisk if the user is using apatch
if [ "$busybox_path" = "/data/adb/ksu/bin/busybox" ]; then
  if [ -d "/data/adb/modules/zygisksu" ]; then
    :
  else
    echo "You need zygisk!"
    rm "$0"
    exit 1
  fi
fi

# Delete outdated pif.json
echo "[+] Deleting old pif.json"
file_paths=(
    "/data/adb/pif.json"
    "/data/adb/modules/playintegrityfix/pif.json"
    "/data/adb/modules/playintegrityfix/custom.pif.json"
)

for file_path in "${file_paths[@]}"; do
    if [ -f "$file_path" ]; then
        rm -f "$file_path" > /dev/null
    fi
done
echo

# Disable problematic packages, miui eu, EvoX, lineage, PixelOS, Eliterom
apk_names=("eu.xiaomi.module.inject" "com.goolag.pif" "com.lineageos.pif" "co.aospa.android.certifiedprops.overlay" "com.elitedevelopment.module")
echo "[+] Check if inject apks are present"

for apk in "${apk_names[@]}"; do
    pm uninstall "$apk" > /dev/null 2>&1
    if ! pm list packages -d | "$busybox_path" grep "$apk" > /dev/null; then
        if pm disable "$apk" > /dev/null 2>&1; then
            echo "[+] The ${apk} apk is now disabled. YOU NEED TO REBOOT OR YOU WON'T BE ABLE TO PASS DEVICE INTEGRITY!"
        fi
    fi
done
echo

# Download pif.json
echo "[+] Downloading the pif.json"

if /system/bin/curl -sL ipinfo.io | grep 'CN' > /dev/null 2>&1; then
    proxy="https://mirror.ghproxy.com/"
else
    proxy=""
fi

if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
    /system/bin/curl -L "${proxy}https://raw.githubusercontent.com/daboynb/autojson/main/pif.json" -o /data/adb/modules/playintegrityfix/custom.pif.json > /dev/null 2>&1 || /system/bin/curl -L "${proxy}https://raw.githubusercontent.com/daboynb/autojson/main/pif.json" -o /data/adb/modules/playintegrityfix/custom.pif.json
else
    /system/bin/curl -L "${proxy}https://raw.githubusercontent.com/daboynb/autojson/main/pif.json" -o /data/adb/pif.json > /dev/null 2>&1 || /system/bin/curl -L "${proxy}https://raw.githubusercontent.com/daboynb/autojson/main/pif.json" -o /data/adb/pif.json
fi
echo 

# Kill gms processes and wallet
package_names=("com.google.android.gms" "com.google.android.gms.unstable" "com.google.android.apps.walletnfcrel")

echo "[+] Killing some apps"

for package in "${package_names[@]}"; do
    pkill -f "${package}" > /dev/null
done
echo

# Clear the cache of all apps
echo "[+] Clearing cache"
pm trim-caches 999G 
echo

# Check if the pif is present
if [ -f /data/adb/pif.json ] || [ -f /data/adb/modules/playintegrityfix/custom.pif.json ]; then
    echo "[+] Pif.json downloaded successfully"
else
    echo "[+] Pif.json is not present, something went wrong."
fi

# Check if the kernel name is banned, banned kernels names from https://xdaforums.com/t/module-play-integrity-fix-safetynet-fix.4607985/post-89308909 and telegram
get_kernel_name=$(uname -r)
banned_names=("aicp" "arter97" "blu_spark" "cm" "crdroid" "cyanogenmod" "deathly" "eas" "elementalx" "elite" "franco" "lineage" "lineageos" "noble" "optimus" "slimroms" "sultan")

for keyword in "${banned_names[@]}"; do
    if echo "$get_kernel_name" | "$busybox_path" grep -iq "$keyword"; then
        echo
        echo "[-] Your kernel name \"$keyword\" is banned. If you are passing device integrity you can ignore this mesage, otherwise that's probably the cause. "
    fi
done

echo ""
echo "Remember, wallet can take up to 24 hrs to work again!"
echo ""
echo "If you receive the device is not certified message on the Play Store and you are passing device integrity, go to Settings, then Apps, find the Play Store, and tap on Uninstall Updates."
echo ""

# Auto delete the script
rm "$0" > /dev/null 2>/dev/null