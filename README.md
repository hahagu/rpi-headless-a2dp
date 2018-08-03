# Headless A2DP Automated Script for Raspberry Pi 3
This is an automated installation script automating the process of [this post](https://gist.github.com/mill1000/74c7473ee3b4a5b13f6325e9994ff84c) by @mill1000

## Usage
In your rpi3 terminal, or via ssh

`git clone https://github.com/hahagu/rpi-headless-a2dp.git && cd rpi-headless-a2dp`

`chmod +x headless-a2dp.sh`

`./headless-a2dp.sh`

This will automatically install all the dependencies and enable the services.

## FAQ
<b>How do I change the device name?</b>

The device name is managed by the hostname of the device. Change the hostname to change your device's bluetooth name.


<b>Why can I connect more than 1 device? Is this a bug?</b>

Currently, the bluez-alsa by @Arkq handles the connections in this way. There is not a way to change this behavior in my knowledge.
