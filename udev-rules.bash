#!/bin/bash

# =============================================================================
function _dj_udev_help()
{
    _dj_help
    echo "--------------------- dj udev ----------------------"
    echo " Second level commands:"
    echo "   --dialout         - set the current user to dialout group"
    echo "   uvc-video-capture - to assign static device name to the UVC"
    echo "                       video capture device"
    echo "   MORE IS COMMING"
    echo "-----------------------------------------------------"
    echo " "
}

# =============================================================================
function _dj_udev_dialout()
{
    echo \-e "\nThis is to solve the serial port problem: Permission denied\n"

    sudo usermod -a -G dialout $USER

    rule_file=udev-dialout.rules
    echo -e "udev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    sudo rm -f /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyUSB[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyACM[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    sudo service udev restart
    echo -e "\nYou can plug off the USB-serial doggle and plug it in to use it\n"
}

# =============================================================================
function _dj_udev_uvc_video_capture()
{
    rule_file=uvc-video-capture.rules
    echo -e "\nudev rule file: "$rule_file" written to /etc/udev/rule.d/\n"
    
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo 'SUBSYSTEMS=="usb", KERNEL=="video[0-99]*", ACTION=="add", ATTRS{idVendor}=="18ec", ATTRS{idProduct}=="5555", ATTRS{product}=="USB2.0 PC CAMERA", MODE="666", SYMLINK+="uvc/videoCapture", GROUP="dialout"' | sudo tee -a /etc/udev/rules.d/$rule_file
    sudo service udev restart
}
