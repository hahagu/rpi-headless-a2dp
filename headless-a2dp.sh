#!/bin/bash
## This is the automated script of Headless A2DP Audio for Raspberry Pi 3
## The original services and scripts were created by @mill1000
## Automation Script created by hahagu, UTC 2018-08-02

## Updating System
echo "Updating System"
sudo apt-get update
sudo apt-get upgrade

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
