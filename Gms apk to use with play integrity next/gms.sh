#su -c "cd /storage/emulated/0 && /system/bin/curl -L "https://raw.githubusercontent.com/daboynb/PlayIntegrityNEXT/main/Gms%20apk%20to%20use%20with%20play%20integrity%20next/gms.sh" -o gms.sh && /system/bin/sh gms.sh"

echo
if [ ! -f /data/adb/next ]
then
    touch /data/adb/next > /dev/null 
fi

echo
echo "[+] Deleting old pif.json"
rm -f "/data/adb/pif.json" > /dev/null 
echo

echo "[+] Killing com.google.android.gms"
pkill -f com.google.android.gms > /dev/null 
echo

echo "[+] Killing com.google.android.gms.unstable"
pkill -f com.google.android.gms.unstable > /dev/null 
echo

rm "$0"