#!/bin/bash

# ===========================================================================================
function _dj_udev_help()
{
    _dj_help
    echo "--------------------- dj udev ----------------------"
    echo " Second level commands:"
    echo "   uvc-video-capture - to assign static device name to the UVC"
    echo "                       video capture device"
    echo "   MORE IS COMMING"
    echo "-----------------------------------------------------"
    echo " "
}

# ===========================================================================================
function _dj_udev_uvc_video_capture()
{
    echo " "
    echo " udev rule setup to /etc/udev/rule.d/"
    echo " "
    if [ $# -eq 0 ] ; then
        _dj_udev_help
        return
    fi
    rule_file=/etc/udev/rules.d/uvc-video-capture.rules
    sudo rm -f $rule_file
    echo 'SUBSYSTEMS=="usb", KERNEL=="video[0-99]*", ACTION=="add", ATTRS{idVendor}=="18ec", ATTRS{idProduct}=="5555", ATTRS{product}=="USB2.0 PC CAMERA", MODE="666", SYMLINK+="uvc/videoCapture", GROUP="dialout"' | sudo tee -a $rule_file
    sudo service udev restart
}
