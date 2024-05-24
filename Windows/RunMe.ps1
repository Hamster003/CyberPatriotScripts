Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force #Alows Powershell to run Scripts
$Path="$PSScriptRoot\WinScript.ps1" #Sets path variable to the location of the Windows script
&$Path #Runs Windows script