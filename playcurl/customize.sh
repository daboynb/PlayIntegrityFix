# Set permissions
set_perm $MODPATH/system/bin/fp root root 0777
set_perm $MODPATH/system/bin/fpd root root 0777
set_perm $MODPATH/system/bin/fpa root root 0777
set_perm $MODPATH/system/bin/fpt root root 0777
mv -f $MODPATH/system/bin/$ABI/curl $MODPATH/system/bin
set_perm $MODPATH/system/bin/curl root root 777

echo ""
ui_print "You can edit /data/adb/modules/playcurl/seconds.txt"
ui_print "to specify the seconds between each check"
ui_print "and then reboot to apply."
echo ""
ui_print "The default value is 1800 (30 mins)"

# Possible configurations in seconds:

# 5 minutes
# 300

# 15 minutes
# 900

# 30 minutes
# 1800

# 45 minutes
# 2700

# 1 hour
# 3600

# 3 hours
# 10800

# 6 hours
# 21600

# 9 hours
# 32400

# 12 hours
# 43200

# 18 hours
# 64800

# 24 hours
# 86400 