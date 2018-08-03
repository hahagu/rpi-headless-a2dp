#!/bin/bash
## This is the automated script of Headless A2DP Audio for Raspberry Pi 3
## The original services and scripts were created by @mill1000
## Automation Script created by hahagu, UTC 2018-08-02

## Updating System
echo "Updating System"
sudo apt-get update
sudo apt-get upgrade -y

## Set Name and etc
echo "Disable Integrated Bluetooth?"
echo "This is recommended due to bugs with the integrated wifi."
echo "Please use a dongle if you want to disable this."
read -p "Disable? (y/n) " btansw
case ${btansw:0:1} in
    y|Y )
        ## Disable Bluetooth
        echo "Disabling Internal Bluetooth"
        printf "\n# Disable onboard Bluetooth\ndtoverlay=pi3-disable-bt" >> /boot/config.txt
        sudo systemctl disable hciuart.service
    ;;
    * )
        echo "Skipping.."
    ;;
esac

printf "\n"
echo "Update BlueZ to 5.50?"
echo "This will resolve the stuttering issue when onboard wifi is used."
read -p "Update? (y/n) " bluezansw
case ${bluezansw:0:1} in
    y|Y )
        ## Updating from source
        echo "Installing Prerequisites"
        sudo apt install libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev -y
        echo "Downloading Source"
        wget http://www.kernel.org/pub/linux/bluetooth/bluez-5.50.tar.xz
        echo "Extracting Source"
        tar xvf bluez-5.50.tar.xz
        cd bluez-5.50
        echo "Configuring"
        ./configure --prefix=/usr --mandir=/usr/share/man --sysconfdir=/etc --localstatedir=/var --enable-experimental 
        echo "Compiling"
        make -j4
        echo "Installing"
        sudo make install
        sudo adduser pi bluetooth
        echo "Cleaning"
        rm -rf ./bluez-5.50*
    ;;
    * )
        echo "Skipping.."
    ;;
esac

printf "\n"
echo "Device Name? Currently $(hostname) "
read btname
read -p "Do you want to set the name as $btname? (y/n) " nameansw
case ${nameansw:0:1} in
    y|Y )
        ## Change Hostname
        echo "Changing Hostname"
        sudo sed -i 's/$(hostname)/$btname/g' /etc/hosts
        sudo sed -i 's/$(hostname)/$btname/g' /etc/hostname
        sudo hostname $btname
        sudo service networking restart
    ;;
    * )
        echo "Skipping.."
    ;;
esac

## Installing Dependencies
echo "Installing Dependencies"
sudo apt-get install bluealsa python-dbus

## Make Bluetooth Discoverable
echo "Making Bluetooth Discoverable"
sudo sed -i 's/#DiscoverableTimeout = 0/DiscoverableTimeout = 0/g' /etc/bluetooth/main.conf
echo -e 'power on \ndiscoverable on \nquit' | sudo bluetoothctl

## Create Services
echo "Creating Services"
wget https://gist.github.com/hahagu/f633ad07014ded3c3833203a77a213c4/raw/ef68cb99020dc754459d1a0b14726a23be4233ed/a2dp-agent
sudo mv a2dp-agent /usr/local/bin
sudo chmod +x /usr/local/bin/a2dp-agent

wget https://gist.github.com/hahagu/f633ad07014ded3c3833203a77a213c4/raw/ef68cb99020dc754459d1a0b14726a23be4233ed/bt-agent-a2dp.service
sudo mv bt-agent-a2dp.service /etc/systemd/system
sudo systemctl enable bt-agent-a2dp.service

wget https://gist.github.com/hahagu/f633ad07014ded3c3833203a77a213c4/raw/ef68cb99020dc754459d1a0b14726a23be4233ed/a2dp-playback.service
sudo mv a2dp-playback.service /etc/systemd/system
sudo systemctl enable a2dp-playback.service

sudo sed -i -e '$i \# Make Bluetooth Discoverable\necho -e "discoverable on \\nquit" | sudo bluetoothctl\n' /etc/rc.local

## Reboot
echo "Rebooting in 5 seconds.."
sleep 5
sudo reboot
