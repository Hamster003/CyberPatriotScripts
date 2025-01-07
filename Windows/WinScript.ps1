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

###Input box function (https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/)###
function Read-MultiLineInputBoxDialog([string]$Message, [string]$WindowTitle, [string]$DefaultText)
{

    
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms

    # Create the Label.
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Size(10,10)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.AutoSize = $true
    $label.Text = $Message

    # Create the TextBox used to capture the user's text.
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Size(10,40)
    $textBox.Size = New-Object System.Drawing.Size(575,200)
    $textBox.AcceptsReturn = $true
    $textBox.AcceptsTab = $false
    $textBox.Multiline = $true
    $textBox.ScrollBars = 'Both'
    $textBox.Text = $DefaultText

    # Create the OK button.
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Size(415,250)
    $okButton.Size = New-Object System.Drawing.Size(75,25)
    $okButton.Text = "OK"
    $okButton.Add_Click({ $form.Tag = $textBox.Text; $form.Close() })

    # Create the Cancel button.
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Size(510,250)
    $cancelButton.Size = New-Object System.Drawing.Size(75,25)
    $cancelButton.Text = "Cancel"
    $cancelButton.Add_Click({ $form.Tag = $null; $form.Close() })

    # Create the form.
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $WindowTitle
    $form.Size = New-Object System.Drawing.Size(610,320)
    $form.FormBorderStyle = 'FixedSingle'
    $form.StartPosition = "CenterScreen"
    $form.AutoSizeMode = 'GrowAndShrink'
    $form.Topmost = $True
    $form.AcceptButton = $okButton
    $form.CancelButton = $cancelButton
    $form.ShowInTaskbar = $true

    # Add all of the controls to the form.
    $form.Controls.Add($label)
    $form.Controls.Add($textBox)
    $form.Controls.Add($okButton)
    $form.Controls.Add($cancelButton)

    # Initialize and show the form.
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() > $null  # Trash the text of the button that was clicked.

    # Return the text that the user entered.
    return $form.Tag
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

$ProgressPreference = "SilentlyContinue" #Hides Install-Module output
$ErrorActionPreference = 'SilentlyContinue' #Hides errors 

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) > $null
# ^Installs Chocolaty for software installs

Install-Module -Name PSWindowsUpdate -AcceptAll #Installs the PWSH Windows Update Package so that updates can be done in the script
Install-Module -Name SecurityPolicy -AcceptAll #Installs a PWSH module that allows for the editing on the Local security policy
Install-Module -Name AuditPolicy -AcceptAll #Installs a PWSH module that allows for the editing on the GPO
Install-Module -Name PSParseHTML -AcceptAll #Installs a PWSH module that allows for conversion of html to txt for Read Me parsing

winget install -e --id Python.Python.3.11 #Installs Python

$ProgressPreference = "Continue"
$ErrorActionPreference = "Continue"

$UserName = Read-Host "Enter your user name here"

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

<#
function Get-User {

    Clear-Host

    Write-Output "1-Add User               2-Remove User"
    Write-Output "3-Add Admin              4-Remove Admin"
    Write-Output "5-Set Password           6-Audit Users from list DONT USE"
    Write-Output "99-Exit"
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
    }elseif ($usrselection -eq 6) {
        Set-UserList
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

    $UserAdminAdd = Read-Host "Enter the User you want to give admin"
    Add-LocalGroupMember -Group "Administrators" -Member $UserAdminAdd
    
    Start-Sleep -Seconds 1
    Get-User
}

function Remove-Group {
    
    Clear-Host

    $UserAdminRM = Read-Host "Enter the User you want to remove admin from"
    Remove-LocalGroupMember -Group "Administrators" -Member $UserAdminRM
    
    Start-Sleep -Seconds 1
    Get-User
}
###Set-UserList#########################################################################################################################################################
function Set-UserAllowed{

    Remove-LocalGroupMember -Group "AuthAdmin" -Member $UserName
    Remove-LocalGroupMember -Group "Administrators" -Member "AuthAdmin"
    Add-LocalGroupMember -Group "Administrators" -Member "AuthAdmin"

    New-LocalGroup -Name "AccountsToRemove"

    # Define the name of the local group you want to add users to
    $AccountsToRM = "AccountsToRemove"

    # Get the list of all local users
        $allUsers = Get-LocalUser

    # Get the list of local administrators
    $AccountsToKeep = Get-LocalGroup -Name "Auth"
    $AuthUserAccount = Get-LocalGroupMember -Group $AccountsToKeep | Where-Object { $_.ObjectClass -eq "User" }

    # Extract the names of admin users for quick lookup
    $AuthUserNames = $AuthUserAccount | Select-Object -ExpandProperty Name

    foreach ($user in $allUsers) {
        # Check if the user is not an administrator
        if ($AuthUserNames -notcontains $user.Name) {
            # Add the user to the target group
            Add-LocalGroupMember -Group $AccountsToRM -Member $user.Name
        }
    }


    # Get the list of all members in the local group
    $groupMembers = Get-LocalGroupMember -Group $AccountsToRM

    foreach ($member in $groupMembers) {
        # Check if the member is a user (not a group or other type of account)
        if ($member.ObjectClass -eq "User") {
            # Delete the local user
            Remove-LocalUser -Name $member.Name
        }
    }


    Remove-LocalGroup -Name "AuthAdmin"
    Remove-LocalGroup -Name "AuthUser"
    Remove-LocalGroup -Name "Auth"

}

function Get-AuthAdmin {
    $AuthAdminList = Read-MultiLineInputBoxDialog -Message "Please enter Authorized Admins" -WindowTitle "ADMIN" -DefaultText "Paste here "
        if ($null -eq $AuthAdminList) {
            Write-Host "You Canceled"
            Get-AuthAdmin
        }else{ 

            $AuthAdminList | Out-File -FilePath "$PSScriptRoot\AdminList.txt"

            $fileContent = Get-Content -Path "$PSScriptRoot\AdminList.txt"
            New-LocalGroup -Name "AuthAdmin"
            foreach ($line in $fileContent) {
            # Process each line
            Add-LocalGroupMember -Group "AuthAdmin" -Member $line
            Add-LocalGroupMember -Group "Auth" -Member $line
            }
            
         Set-UserAllowed
        }
}

function Get-AuthUser {
    $AuthUserList = Read-MultiLineInputBoxDialog -Message "Please enter Authorized Users" -WindowTitle "USER" -DefaultText "Paste here "
    if ($null -eq $AuthUserList) {
        Write-Host "You Canceled"
        Get-AuthUser
    }else{ 

        $AuthUserList | Out-File -FilePath "$PSScriptRoot\UserList.txt"

        $fileContent = Get-Content -Path "$PSScriptRoot\UserList.txt"
        New-LocalGroup -Name "AuthUser"
        New-LocalGroup -Name "Auth"
        foreach ($line in $fileContent) {
        # Process each line
        Add-LocalGroupMember -Group "AuthUser" -Member $line
        Add-LocalGroupMember -Group "Auth" -Member $line
        }

        Get-AuthAdmin
    }
}
function Set-UserList {

    Clear-Host

    Get-AuthUser


    Start-Sleep -Seconds 1
    Get-MenuSelect
}




#>

###Get-Firewall############################################################################################################################################################
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
    $selsoftware = Read-Host "Make a selection"
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

Get-User {
#-----------------------------------------------------
# User Shit!!!
#-----------------------------------------------------

    # Function to get a Yes/No response
    Function Get-YesNo($prompt) {
        do {
            $response = Read-Host "$prompt (Y/N)"
        } until ($response -match '^[YyNn]$')
        return $response.ToUpper()
    }

    # Function to automatically set a secure password for a user
    Function Set-SecurePassword($username) {
        $Password = ConvertTo-SecureString -String "CyberPatri0t!?@" -AsPlainText -Force
        $user = Get-LocalUser -Name $username
        try {
            $user | Set-LocalUser -Password $Password
        } catch {
            Write-Host "Failed to set password for user '$username'. Error: $($_.Exception.Message)"
        }
    }

    # Function to remove unauthorized users
    Function Remove-UnauthorizedUser($username) {
        if ($username -in @("DefaultAccount", "WDAGUtilityAccount", "Administrator")) {
            Write-Host "Skipping removal of system account '$username'."
            return
        }
        try {
            Remove-LocalUser -Name $username -ErrorAction Stop
            Write-Host "User '$username' has been removed successfully."
        } catch {
            Write-Host "Failed to remove user '$username'. Error: $($_.Exception.Message)"
        }
    }

    # Function to create a group and add users to the group
    Function Manage-Group($groupName, $groupMembers) {
        $group = Get-LocalGroup -Name $groupName -ErrorAction SilentlyContinue
        if ($group) {
            Write-Host "Group '$groupName' already exists."
            $editGroup = Get-YesNo "Do you want to edit the users within the group?"
            if ($editGroup -eq "Y") {
                Write-Host "Removing all users from the group '$groupName'..."
                Get-LocalGroupMember -Group $groupName | ForEach-Object {
                    Remove-LocalGroupMember -Group $groupName -Member $_.Name
                }
                Write-Host "Adding specified users to the group '$groupName'..."
                foreach ($user in $groupMembers) {
                    try {
                        Add-LocalGroupMember -Group $groupName -Member $user -ErrorAction Stop
                    } catch {
                        Write-Host "Failed to add user '$user' to group '$groupName'. Error: $($_.Exception.Message)"
                    }
                }
            }
        } else {
            Write-Host "Creating group '$groupName'..."
            try {
                New-LocalGroup -Name $groupName -ErrorAction Stop
                Write-Host "Adding specified users to the group '$groupName'..."
                foreach ($user in $groupMembers) {
                    Add-LocalGroupMember -Group $groupName -Member $user -ErrorAction Stop
                }
            } catch {
                Write-Host "Failed to create group '$groupName'. Error: $($_.Exception.Message)"
            }
        }
    }



    # Manage local user accounts if needed
    $ManageUsers = Get-YesNo "Do you need to manage local user accounts?"

    If ($ManageUsers -eq "Y") {
        Write-Host "Managing local user accounts..."

        # Prompt for authorized users
        $AuthorizedUsers = (Read-Host "Enter authorized user account names, separated by commas (e.g., User1,User2)").Split(',').Trim()

        # Get all local users excluding built-in accounts
        $LocalUsers = Get-LocalUser | Where-Object { $_.Name -ne "Administrator" -and $_.Name -ne "Guest" }

        # Set secure passwords for authorized users
        $AuthorizedUsers = $AuthorizedUsers | Sort-Object
        $LocalUsers = $LocalUsers | Sort-Object Name

        foreach ($User in $LocalUsers) {
            if ($User.Name -in $AuthorizedUsers) {
                Write-Host "User '$($User.Name)' is authorized. Setting a secure password..."
                Set-SecurePassword -username $User.Name
            } else {
                Write-Host "User '$($User.Name)' is not authorized. Removing..."
                Remove-UnauthorizedUser -username $User.Name
            }
        }

        # Prompt for authorized admin accounts
        Write-Host "Configuring Administrators group membership..."
        $AuthorizedAdmins = (Read-Host "Enter authorized admin account names, separated by commas (e.g., Admin1,Admin2)").Split(',').Trim()

        # Get current Administrators group members
        $AdministratorsGroup = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name

        # Remove unauthorized admins
        foreach ($admin in $AdministratorsGroup) {
            if ($admin -notin $AuthorizedAdmins -and $admin -ne "Administrator") {
                Write-Host "Removing unauthorized admin account: $admin"
                try {
                    Remove-LocalGroupMember -Group "Administrators" -Member $admin -ErrorAction Stop
                } catch {
                    Write-Host "Failed to remove admin account '$admin'. Error: $($_.Exception.Message)"
                }
            }
        }

        # Ensure authorized admins are in the Administrators group
        foreach ($admin in $AuthorizedAdmins) {
            if ($AdministratorsGroup -notcontains $admin) {
                Write-Host "Adding user '$admin' to the Administrators group."
                try {
                    Add-LocalGroupMember -Group "Administrators" -Member $admin -ErrorAction Stop
                } catch {
                    Write-Host "Failed to add user '$admin' to Administrators group. Error: $($_.Exception.Message)"
                }
            }
        }

        # Ensure authorized users are not administrators if not specified
        foreach ($User in $AuthorizedUsers) {
            if ($User -notin $AuthorizedAdmins -and $AdministratorsGroup -contains $User) {
                Write-Host "Removing user '$User' from the Administrators group."
                try {
                    Remove-LocalGroupMember -Group "Administrators" -Member $User -ErrorAction Stop
                } catch {
                    Write-Host "Failed to remove user '$User' from Administrators group. Error: $($_.Exception.Message)"
                }
            }
        }

        # Disable the Guest account
        $GuestAccount = Get-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
        If ($GuestAccount -and -not $GuestAccount.Enabled) {
            Write-Host "Disabling Guest account..."
            Disable-LocalUser -Name "Guest"
        }

        # Define the group name
        $groupName = Read-Host "Enter the group name"

        # Check if the group already exists
        $groupExists = Get-LocalGroup -Name $groupName -ErrorAction SilentlyContinue

        if ($groupExists) {
            # If the group already exists, ask if the user wants to remove all existing users
            $removeUsers = Get-YesNo "The group '$groupName' already exists. Do you want to remove all users and replace them with new users?"

            if ($removeUsers -eq 'Y') {
                # Remove all users from the group
                Get-LocalGroupMember -Group $groupName | ForEach-Object {
                    Remove-LocalGroupMember -Group $groupName -Member $_.Name
                }
            }
        } else {
            # Create a new group if it doesn't exist
            New-LocalGroup -Name $groupName
        }

        # Ask for users to add to the group
        $userNames = (Read-Host "Enter the usernames to add to the group (comma-separated)").Split(',').Trim() | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

        # Add each user to the group
        foreach ($user in $userNames) {
            Add-LocalGroupMember -Group $groupName -Member $user -ErrorAction SilentlyContinue
        }

        Write-Host "Users have been added to the group '$groupName'."
    } else {
        Write-Host "Skipping local user account management."
    }

    }
############################################## MAIN SCRIPT ##############################################

Get-MenuSelect


Write-Output "Removing programs..."
Pause

$ProgressPreference = "SilentlyContinue" #Hides Install-Module output
$ErrorActionPreference = 'SilentlyContinue' #Hides errors 

winget uninstall --id Python.Python.3.11
Remove-Module -Name PSWindowsUpdate -AcceptAll
Remove-Module -Name SecurityPolicy -AcceptAll
Remove-Module -Name AuditPolicy -AcceptAll
Remove-Module -Name PSParseHTML -AcceptAll 

$ChocoRMPath="$PSScriptRoot\WinScript.ps1" #Sets path variable to the location of the Choco RM script
&$ChocoRMPath #Runs Choco RM script

$ProgressPreference = "Continue"
$ErrorActionPreference = "Continue"