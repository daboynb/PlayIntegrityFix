#!/system/bin/sh

################################################################### Declare vars
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

################################################################### Check for pre-requisites
# Check for kdrag0n/safetynet-fix
if [ -d "/data/adb/modules/safetynet-fix" ]; then
    echo "The safetynet-fix module is incompatible with pif, remove it and reboot the phone to proceed"
    rm "$0"
    exit 1
fi

# Check for MagiskHidePropsConfig
if [ -d "/data/adb/modules/MagiskHidePropsConf" ]; then
    echo "The MagiskHidePropsConfig module may cause issues with pif, remove it and reboot the phone to proceed"
    rm "$0"
    exit 1
fi

# Check for FrameworkPatcherGo
if [ -d "/data/adb/modules/FrameworkPatcherGo" ]; then
    echo "The FrameworkPatcherGo module is incompatible with pif, remove it and reboot the phone to proceed"
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
###################################################################

###################################################################
# Download pif.json
echo "[+] Downloading the pif.json"
if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
    /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/main/osmosis.json" -o /data/adb/modules/playintegrityfix/custom.pif.json > /dev/null 2>&1 || /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/main/osmosis.json" -o /data/adb/modules/playintegrityfix/custom.pif.json
else
    /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/main/chiteroman.json" -o /data/adb/pif.json > /dev/null 2>&1 || /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/autojson/main/chiteroman.json" -o /data/adb/pif.json
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
# Execute su twice workaround https://www.reddit.com/r/LineageOS/comments/8txt08/comment/e7eak5g/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
su -c "su -c 'pm trim-caches 999G' > /dev/null 2>&1"
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

# Check the keys of /system/etc/security/otacerts.zip
get_keys=$("$busybox_path" unzip -l /system/etc/security/otacerts.zip)

if echo "$get_keys" | "$busybox_path" grep -q release; then
    echo ""
    echo "[+] Your keys are release-keys" 
fi
if echo "$get_keys" | "$busybox_path" grep -q test; then
    echo ""
    echo "[-] Your keys are test-keys."
    echo "Setting custom props"
    
    # Check for the presence of migrate.sh and use the appropriate file path
    if [ -f /data/adb/modules/playintegrityfix/migrate.sh ]; then
        $busybox_path sed -i 's/"spoofSignature": *0/"spoofSignature": 1/g' /data/adb/modules/playintegrityfix/custom.pif.json
    else
        $busybox_path sed -i 's/"spoofSignature": *"false"/"spoofSignature": "true"/g' /data/adb/pif.json
    fi

    echo "[+] The 'spoofSignature' flag has been set to true"

    # Kill GMS processes
    package_names=("com.google.android.gms" "com.google.android.gms.unstable")

    for package in "${package_names[@]}"; do
        pkill -f "${package}" > /dev/null 2>&1
    done
fi
echo ""
echo "If you are using pif + ts and you're getting only device integrity on the osmosi's fork switch to chiteroman"
echo ""
echo "Remember, the wallet can take up to 24 hours to work again!"
echo ""
echo "If you receive the 'device is not certified' message on the Play Store and you are passing device integrity, go to Settings, then Apps, find the Play Store, and tap on Uninstall Updates."
echo ""
echo "Never clear Play Store data when using pif, or you'll end up with an 'Unable to connect' error."
echo ""
echo "Do not put anything on the denylist other than the necessary apps."
echo ""
echo "Avoid putting things like Google Services Framework or Play Services on it."
echo ""
echo "That can cause problems like not passing integrity."
echo ""


# Auto delete the script
rm "$0" > /dev/null 2>/dev/null
###################################################################
