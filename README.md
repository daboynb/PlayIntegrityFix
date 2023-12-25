If you wanna help me

<a href="https://www.buymeacoffee.com/daboynb" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

# Play integrity fix

# Download from 
https://github.com/daboynb/PlayIntegrityNEXT/releases/tag/Release

# Why this fork?
It downloads the fingerprint automatically.

# Instructions

1) Download the zip
2) Download the apk
3) Install the apk and grant root permissions ( if you are unable to install the apk use 
https://play.google.com/store/apps/details?id=com.aefyr.sai )
4) Flash the zip and reboot

When the fingerprint will be banned, you will only need to open the app and then check for Play Integrity Attestation. The module will download the new playIntegrityFix.json. 

# ATTENTION
Sometimes, you may need to double-check for Play Integrity Attestation if the new playIntegrityFix.json was just downloaded.
It can happen if you use apps like Yasnac. Currently, I have not encountered this bug using the Google Play developer check.


# support
if you need support contact http://t.me/furdiburd or join to the new group https://t.me/playfixnext

# Demonstration
https://github.com/daboynb/PlayIntegrityNEXT/assets/106079917/2f5b8376-aa3e-4be1-91d7-5f003ac72499


# What does the APK do

    [ -e /data/adb/pif.json ] && (echo "rm"; rm /data/adb/pif.json) || echo "no"

    sleep 04 && if pgrep -f com.google.android.gms > /dev/null; then pkill -f com.google.android.gms; else echo "Process is not running."; fi && if pgrep -f com.google.android.gms.unstable > /dev/null; then pkill -f com.google.android.gms.unstable; else echo "Process is not running."; fi

The apk was made with tasker, this is the profile:

https://github.com/daboynb/PlayIntegrityNEXT/blob/main/Gms.tsk.xml

https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm

https://play.google.com/store/apps/details?id=net.dinglisch.android.appfactory
