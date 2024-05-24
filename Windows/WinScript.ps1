<#
Nathan Jacobson 2024
With a lot of help from google and the powershell docs
#>

param([switch]$Elevated)
Write-Output "Cyber Patriot Windows Script"
Start-Sleep -s 2

#Checks to see if script is run as admin, if not the elevates
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# ^Installs Chocolaty for software installs
Pause

Install-Module -Name PSWindowsUpdate #Installs the Powershell Windows Update Package so that updates can be done in the script
