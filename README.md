# AEM-Datto
Datto RMM formerly known as Autotak Endpoint Managment (AEM)

## PrivacyToggle.ps1
Privacy Toggle is PowerShell script that was created to easily toggle the privacy mode setting for Datto RMM/AEM. You can always turn on privacy mode but turning it off wasn't very easy. The script will check and see if Privacy mode is on and turn it off. If privacy mode is off it will turn it on. No end user action needed. The script can be ran directly on the system or you can add it as a script component and run it as a job against a mulitple devices or a single one.

### Issues
* AEM/Datto will say that the job is running even after it's toggled the privacy mode setting
* If the GUI on the endpoint is open it will still work but may result in a .net error being displayed
