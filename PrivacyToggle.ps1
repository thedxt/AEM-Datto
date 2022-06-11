$key =  "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\CentraStage"
$value = "DisplayVersion"

$version = (Get-ItemProperty -Path $key -Name $value).$value

$path = "C:\Windows\System32\config\systemprofile\AppData\Local\CentraStage\CagService.exe_Url_nin2uaxj2lsg1o0rsz2amvmcciusvum4\"
$file = "\user.config"

$combo = "$($path)$($version)$($file)"

$xml = [xml](Get-Content "$($path)$($version)$($file)")
$node = $xml.configuration.usersettings."CentraStage.Cag.Core.Settings".setting | where {$_.Name -eq 'PrivacyMode'}

If ($node.value -eq 'False')
{
$node.value = 'True'
}
Else
{
$node.value = 'False'
}

$xml.Save($combo)

# Setup a scheduled task to restart the Cags service in 1 minute and then delete itself. If we restart Cags service here then the job will hang indefinately

# Set up action to run
$STAction = New-ScheduledTaskAction `
-Execute 'powershell.exe' `
-Argument "Restart-Service -Name 'Datto RMM'"

# Set up trigger to launch action
$STTrigger = New-ScheduledTaskTrigger `
-Once `
-At ((get-date).AddMinutes(1))

# Set up base task settings
$STSettings = New-ScheduledTaskSettingsSet `
-MultipleInstances IgnoreNew `
-AllowStartIfOnBatteries `
-DontStopIfGoingOnBatteries `
-Hidden `
-StartWhenAvailable

# Name of Scheduled Task
$STName = "Restart Cags Service"

# Create Scheduled Task
Register-ScheduledTask `
-Action $STAction `
-Trigger $STTrigger `
-Settings $STSettings `
-TaskName $STName `
-Description "Restarts the Cags service for RMM" `
-User "NT AUTHORITY\SYSTEM" `
-RunLevel Highest

# Get the Scheduled Task data and make some tweaks
$TargetTask = Get-ScheduledTask -TaskName $STName

# Set desired tweaks
#$TargetTask.Triggers[0].StartBoundary = [DateTime]::Now.ToString("yyyy-MM-dd'T'HH:mm:ss")
$TargetTask.Triggers[0].EndBoundary = [DateTime]::Now.AddMinutes(5).ToString("yyyy-MM-dd'T'HH:mm:ss")
$TargetTask.Settings.AllowHardTerminate = $True
$TargetTask.Settings.DeleteExpiredTaskAfter = 'PT0S'
$TargetTask.Settings.ExecutionTimeLimit = 'PT1H'
$TargetTask.Settings.volatile = $False

# Save tweaks to the Scheduled Task
$TargetTask | Set-ScheduledTask
