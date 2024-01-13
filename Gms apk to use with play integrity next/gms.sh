su -c '[ -f /data/adb/pif.json ] && rm "/data/adb/pif.json" || echo "Continue"'
su -c '{
  if pgrep -f com.google.android.gms > /dev/null; then
    pkill -f com.google.android.gms
    echo "com.google.android.gms process killed."
  else
    echo "com.google.android.gms process is not running."
  fi
}'

su -c '{
  if pgrep -f com.google.android.gms.unstable > /dev/null; then
    pkill -f com.google.android.gms.unstable
    echo "com.google.android.gms.unstable process killed."
  else
    echo "com.google.android.gms.unstable process is not running, no need to kill."
  fi
}'