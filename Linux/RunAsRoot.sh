#!/bin/bash

if [ $(id -u) -ne 0 ] #Checks to see if the User ID is 0 (Root) if no it exits the script
  then echo Please run this script as root or using sudo!
  exit
fi

echo "This script is designed for Ubuntu with a SystemD init process and may not work on other Distros"

echo "Time for updates"
apt update && apt upgrade

select () {
echo "Choose an option "
echo "1-User Managment    2-Password Policy"
echo "3-Firewall          4-Updates"
echo "5-Software          99-Exit"
echo " "
read mainselec

if [$mainselec -eq 1]
    then usermanage
elif [$mainselec -eq 2]
    then passpolicy
elif [$mainselec -eq 3]
    then firewall
elif [$mainselec -eq 4]
    then update
elif [$mainselec -eq 5]
    then software
elif [$mainselec -eq 99]
    then echo "Goodbye"
    exit
else []
    then select
}
usermanage () {

}

passpolicy () {
echo "copying old files as a backup"
mkdir ./pam.d
cp /etc/login.defs ./login.defs
cp /etc/pam.d/common-auth ./pam.d/common-auth


}

firewall () {

}

update () {

}

software () {

}