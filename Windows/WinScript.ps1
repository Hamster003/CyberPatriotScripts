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
Install-Module -Name PSParseHTML #Installs a PWSH module that allows for conversion of html to txt for Read Me parsing

$ProgressPreference = "Continue"
$ErrorActionPreference = "Continue"

############################################### Function ################################################

function Get-MenuSelect {

    Clear-Host

    Write-Output "1-User Managment          2-Password Policy"
    Write-Output "3-Firewall                4-System Tool"
    Write-Output "5-Updates                 6-Software"
    Write-Output "99-Exit                   "
    Write-Output " "
    $selection = Read-Host "Make a selection"

    if ($selection -eq 1) {
        Get-User
        Pause
    }elseif ($selection -eq 2) {
        Get-Password
        Pause
    }elseif ($selection -eq 3) {
        Get-Firewall
        Pause
    }elseif ($selection -eq 4) {
        Get-SystemTool
        Pause
    }elseif ($selection -eq 5) {
        Get-Update
        Pause
    }elseif ($selection -eq 6) {
        Get-Software
        Pause
    }elseif ($selection -eq 7) {
        Get-MenuSelect
        Pause
    }elseif ($selection -eq 8) {
        Get-MenuSelect
        Pause
    }elseif ($selection -eq 99) {
        Close-Program
        Pause
    }else {
        Get-MenuSelect
    }

}

function Get-User {

    Clear-Host

    Write-Output "1-Add User               2-Remove User"
    Write-Output "3-Add Admin              4-Remove Admin"
    Write-Output "5-Set Password           99-Exit"
    Write-Output " "
    $usrselection = Read-Host "Make a selection"
    
    if ($usrselection -eq 1) {
        Add-User
        Pause
    }elseif ($usrselection -eq 2) {
        Remove-User
        Pause
    }elseif ($usrselection -eq 3) {
        Add-Group
        Pause
    }elseif ($usrselection -eq 4) {
        Remove-Group
        Pause
    }elseif ($usrselection -eq 5) {
        Set-UserPassword
        Pause
    }elseif ($usrselection -eq 99) {
        Get-MenuSelect
        Pause
    }else {
        Get-User
    }

}

function Set-UserPassword {
    
    Clear-Host

    $UserNamePS = Read-Host "Enter the Username of the account to update the password of"
    $Password = "Cyb3rP@triot!"
    $UserAccountPS = Get-LocalUser -Name $UserNamePS
    $UserAccountPS | Set-LocalUser -Password $Password
    Write-Output "The password is "$Password
    
    Start-Sleep -Seconds 1
    Get-User
}

function Remove-User {
    
    Clear-Host

    $UserNameRM = Read-Host "Enter the Username of the account you want to remove"
    $UserNameRMConfirm = Read-Host "Are you sure you want to remove "$UserNameRM" [Y/N]"
    if ($UserNameRMConfirm -eq "Y") {
        Remove-LocalUser -Name $UserNameRM
    }else {
        Remove-User
    }
    
    Start-Sleep -Seconds 1
    Get-User
}

function Add-User {
    
    Clear-Host

    $UserNameAdd = Read-Host "Enter the Username of the account you want to add"
    New-LocalUser -Name $UserNameAdd  -Password "Cyb3rP@triot!"
    Write-Output "User "$UserNameAdd" added"
    
    Start-Sleep -Seconds 1
    Get-User
}

function Add-Group {
    
    Clear-Host

    $UserAdminAdd = "Enter the User you want to give admin"
    Add-LocalGroupMember -Group "Administrators" -Member $UserAdminAdd
    
    Start-Sleep -Seconds 1
    Get-User
}

function Remove-Group {
    
    Clear-Host

    $UserAdminRM = "Enter the User you want to remove admin from"
    Remove-LocalGroupMember -Group "Administrators" -Member $UserAdminRM
    
    Start-Sleep -Seconds 1
    Get-User
}


function Get-Firewall {
    
    Clear-Host

    Set-NetFirewallProfile -Enabled True #Enables Firewall

    Start-Sleep -Seconds 1
    Get-MenuSelect
}

function Get-Password {

    Clear-Host

    #Password policy

    $defminpswdage = 10
    $minpswdage = Read-Host "Enter Minimum Password Age. Default is "$defminpswdage" Days"
    if (!$minpswdage -eq "") {$defminpswdage = $minpswdage}

    $defmaxpswdage = 60
    $maxpswdage = Read-Host "Enter Maximum Password Age. Default is "$defmaxpswdage" Days"
    if (!$maxpswdage -eq "") {$defmaxpswdage = $maxpswdage}

    $defuniquwpswd = 3
    $uniquwpswd = Read-Host "Enter Password History. Default is "$defuniquwpswd" passwords"
    if (!$uniquwpswd -eq "") {$defuniquwpswd = $uniquwpswd}

    $defminpswdlen = 8
    $uniquwpswd = Read-Host "Enter Password Length. Default is "$defminpswdlen" characters"
    if (!$minpswdlen -eq "") {$defminpswdlen = $minpswdlen}

    net accounts /minpwage:$minpswdage #Min password age   default 10 days
    net accounts /maxpwage:$maxpswdage #Max password age   default 60 days
    net accounts /uniquepw:$uniquwpswd #passwords remembered for history   default 3 
    net accounts /minpwlen:$minpswdlen #Min password length   default 8
     #Turns Complexity Requirement On

    Start-Sleep -Seconds 1
    Get-MenuSelect
}

function Get-Update {
    
    Clear-Host

    Get-WindowsUpdate -AcceptAll -Install #Gets and installs windows updates
    
    Start-Sleep -Seconds 1
    Get-MenuSelect
}

function Get-SystemTool {

    Clear-Host

    Write-Output "Checking System Files"
    sfc /scannow #Checks System Files

    Get-MenuSelect
}

function Get-Software {
    
    Clear-Host

    Write-Output "Enter way you want to install software. "
    Write-Output "1-Chocolaty                     2-WinGet"
    Write-Output "3-EXE                           99-Exit"
    if ($selsoftware -eq 1) {
        Get-SoftwareChoco
        Pause
    }elseif ($selsoftware -eq 2) {
        Get-SoftwareWinGet
        Pause
    }elseif ($selsoftware -eq 3) {
        Write-Output "Come back to script once you're done installing software. "
        Pause
    }elseif ($selsoftware -eq 99) {
        Get-MenuSelect
    }else {
        Get-Software
    }
    
}
function Get-SoftwareChoco {
    
    Clear-Host

    Write-Output "Enter software to download with Chocolaty. "
    $software = Read-Host "Please enter each software with comma's between them with no spaces. "

    choco -y $software
    
    
}

function Close-Program {
    
    Clear-Host

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
    if ($restart -eq "Y") {
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

    Get-MenuSelect
}

############################################## MAIN SCRIPT ##############################################

Get-MenuSelect