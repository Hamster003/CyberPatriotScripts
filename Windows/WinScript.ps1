<#
Nathan Jacobson 2024
With a lot of help from google and the powershell docs
#>

param([switch]$Elevated)

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

####Functions####
function RegEdit {
    If (-NOT (Test-Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
      }  
      # Now set the value
      New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -Force
}


Clear-Host

Write-Output "        _______ _____  __          ___           _                      _____           _       _   "
Write-Output "     /\|__   __/ ____| \ \        / (_)         | |                    / ____|         (_)     | |  "
Write-Output "    /  \  | | | |       \ \  /\  / / _ _ __   __| | _____      _____  | (___   ___ _ __ _ _ __ | |_ "
Write-Output "   / /\ \ | | | |        \ \/  \/ / | | '_ \ / _` |/ _ \ \ /\ / / __|  \___ \ / __| '__| | '_ \| __|"
Write-Output "  / ____ \| | | |____     \  /\  /  | | | | | (_| | (_) \ V  V /\__ \  ____) | (__| |  | | |_) | |_ "
Write-Output " /_/    \_\_|  \_____|     \/  \/   |_|_| |_|\__,_|\___/ \_/\_/ |___/ |_____/ \___|_|  |_| .__/ \__|"
Write-Output "                                                                                         | |        "
Write-Output "                                                                                         |_|        "

$ProgressPreference = "SilentlyContinue" #Hides Istall-Module output
$ErrorActionPreference = 'SilentlyContinue' #Hides errors

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) > $null
# ^Installs Chocolaty for software installs

Install-Module -Name PSWindowsUpdate #Installs the PWSH Windows Update Package so that updates can be done in the script
Install-Module -Name SecurityPolicy #Installs a PWSH module that allows for the editing on the Local security policy
Install-Module -Name AuditPolicy #Installs a PWSH module that allows for the editing on the GPO

$ProgressPreference = "Continue"
$ErrorActionPreference = "Continue"

############################################### Function ################################################

function Get-MenuSelect {

    Clear-Host

    Write-Output "1-User Managment          2-Password Policy"
    Write-Output "3-Firewall                4-System Tool"
    Write-Output "5-Updates                 99-Exit"
    Write-Output " "
    $selection = Read-Host "Make a selection"

}

function Get-User {

    Write-Output "Not yet added"
    
    Pause
}

function Get-Firewall {
    
    Set-NetFirewallProfile -Enabled True #Enables Firewall

    Pause
}

function Get-Password {

    #Password policy

    $defminpswdage = 10
    $minpswdage = Read-Host "Enter Minimum Password Age. Default is 10 Days"
    if (!$minpswdage -eq "") {$defminpswdage = $minpswdage}

    $defmaxpswdage = 10
    $maxpswdage = Read-Host "Enter Maximum Password Age. Default is 60 Days"
    if (!$maxpswdage -eq "") {$defmaxpswdage = $maxpswdage}

    $defuniquwpswd = 10
    $uniquwpswd = Read-Host "Enter Password History. Default is 3 passwords"
    if (!$uniquwpswd -eq "") {$defuniquwpswd = $uniquwpswd}

    net accounts /minpwage:$minpswdage #Min password age   default 10 days
    net accounts /maxpwage:$maxpswdage #Max password age   default 60 days
    net accounts /uniquepw:$uniquwpswd #passwords remembered for history   default 3 

    Pause
}

function Get-Update {
    
    Get-WindowsUpdate -AcceptAll -Install #Gets and installs windows updates
    
    Pause
}

function Close-Program {
    
    Write-Output "Removing Installed Modules"

    $ProgressPreference = "SilentlyContinue" #Hides Istall-Module output
    $ErrorActionPreference = 'SilentlyContinue' #Hides errors

    Uninstall-Module PSWindowsUpdate #Removes the PWSH update module
    Uninstall-Module SecurityPolicy #Removes the PWSH local security policy module
    Uninstall-Module AuditPolicy #Removes the PWSH GPO editing module
    &$PSScriptRoot/RemoveChoco.ps1 #Removes Chocolaty

    $ProgressPreference = "Continue"
    $ErrorActionPreference = "Continue"

    Clear-Host
    $restart = Read-Host "Would you like to restart [Y/N]"
    if ($restart = "Y") {
        Write-Output "Restarting..."
        Start-Sleep -Seconds 1
        Restart-Computer
    }else{
        Write-Output "Exiting..."
        Start-Sleep -Seconds 1
        exit
    }
    
    Pause
}

function Get-SystemTool {

    Write-Output "Checking System Files"
    sfc /scannow #Checks System Files

    Pause
}

############################################## MAIN SCRIPT ##############################################

Get-MenuSelect

if ($selection -eq 1) {
    Get-User
}elseif ($selection -eq 2) {
    Get-Password
}elseif ($selection -eq 3) {
    Get-Firewall
}elseif ($selection -eq 4) {
    Get-SystemTool
}elseif ($selection -eq 5) {
    Get-Update
}elseif ($selection -eq 6) {
    Get-MenuSelect
}elseif ($selection -eq 7) {
    Get-MenuSelect
}elseif ($selection -eq 8) {
    Get-MenuSelect
}elseif ($selection -eq 99) {
    Close-Program
}else {
    Get-MenuSelect
}

<# Switch ($selection)
{
    1 {; Break}
    2 {Get-Password Pause; Break}
    3 {Get-Firewall Pause; Break}
    4 {Get-SystemTool Pause; Break}
    5 {Get-Update Pause; Break}
<#     6 {; Break}
    7 {; Break}
    8 {; Break} #>
 #   99 {Close-Program Pause; Break}
#}

Get-MenuSelect #>