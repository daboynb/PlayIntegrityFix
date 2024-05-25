# Error on < Android 8.
if [ "$API" -lt 26 ]; then
    abort "- !!! You can't use this module on Android < 8.0"
fi

# safetynet-fix module is obsolete and it's incompatible with PIF.
if [ -d /data/adb/modules/safetynet-fix ]; then
    rm -rf /data/adb/modules/safetynet-fix
    rm -f /data/adb/SNFix.dex
    ui_print "! safetynet-fix module will be removed. Do NOT install it again along PIF."
fi

# MagiskHidePropsConf module is obsolete in Android 8+ but it shouldn't give issues.
if [ -d /data/adb/modules/MagiskHidePropsConf ]; then
    ui_print "! WARNING, MagiskHidePropsConf module may cause issues with PIF."
fi

# Remove xiaomi.eu apps

if [ -d "/product/app/XiaomiEUInject" ]; then
    
    directory="$MODPATH/product/app/XiaomiEUInject"
    
    [ -d "$directory" ] || mkdir -p "$directory"
    
    touch "$directory/.replace"
    
    ui_print "- XiaomiEUInject app removed."
fi

if [ -d "/product/app/XiaomiEUInject-Stub" ]; then
    
    directory="$MODPATH/product/app/XiaomiEUInject-Stub"
    
    [ -d "$directory" ] || mkdir -p "$directory"
    
    touch "$directory/.replace"
    
    ui_print "- XiaomiEUInject-Stub app removed."
fi

su -c "pm disable eu.xiaomi.module.inject" > /dev/null

# Remove EliteRoms app

if [ -d "/system/app/XInjectModule" ]; then
    
    directory="$MODPATH/system/app/XInjectModule"
    
    [ -d "$directory" ] || mkdir -p "$directory"
    
    touch "$directory/.replace"
    
    ui_print "- XInjectModule app removed."
fi

if [ -d "/system/app/EliteDevelopmentModule" ]; then
    
    directory="$MODPATH/system/app/EliteDevelopmentModule"
    
    [ -d "$directory" ] || mkdir -p "$directory"
    
    touch "$directory/.replace"
    
    ui_print "- EliteDevelopmentModule app removed."
fi

# curl

set_perm $MODPATH/system/bin/gms root root 0777
mv -f $MODPATH/system/bin/$ABI/curl $MODPATH/system/bin
set_perm $MODPATH/system/bin/curl root root 777