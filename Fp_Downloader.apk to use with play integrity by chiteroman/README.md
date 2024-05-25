If you wanna help me

<a href="https://www.buymeacoffee.com/daboynb" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

# Instructions

• Download playcurl.zip [HERE](https://github.com/daboynb/PlayIntegrityNEXT/releases/download/playcurl/playcurl.zip) and play integrity fix module (by chiteroman) [HERE](https://github.com/chiteroman/PlayIntegrityFix/releases/latest)

 Flash both modules and reboot your device.

• Wait five minutes, you can check the current progress on the log /storage/emulated/0/run_fp.log.

• When finished, use the SPIC app to verify Play Integrity or the Play Store Checker.

The module checks automatically if the fingerprint has been banned every 30 minutes. You can set your preferred time in seconds inside "/data/adb/modules/playcurl/seconds.txt".

If you don't want the auto-update feature, you can simply delete the file "/data/adb/modules/playcurl/service.sh".

# Binaries

        - fp -> Downloads a working FP and fixes errors in the setup.
        - fpd -> Runs the 'fp' command and then disables all other modules to test incompatibility.
        - fpa -> Runs the 'fp' command and then checks for device integrity; if not met, it runs the 'fpd' command.
        - fpt -> Checks multiple JSON files.

# Instructions for fpt

        - Put all your JSON files into /storage/emulated/0/pif_to_test.
        - Open Termux.
        - Type 'su' and then 'fpt'. All the good JSON files will be moved to /storage/emulated/0/pif_ok.

# Support
Telegram :

CHANNEL https://t.me/PifNEXT

PM http://t.me/furdiburd 

GROUP https://t.me/playfixnext