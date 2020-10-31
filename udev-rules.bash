#!/bin/bash

# =============================================================================
function _dj_udev_help()
{
    _dj_help
    echo -e "\n --------------------- dj udev ----------------------"
    echo    " Second level commands:"
    echo    "   --dialout         - set the current user to dialout group"
    echo    "   uvc-video-capture - to assign static device name to the UVC"
    echo    "                       video capture device"
    echo    "   MORE IS COMMING"
    echo -e "-----------------------------------------------------\n"
}

# =============================================================================
function _dj_udev_dialout()
{
    echo \-e "\n This is to solve the serial port problem: Permission denied\n"

    sudo usermod -a -G dialout $USER

    rule_file=udev-dialout.rules
    echo -e "udev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    sudo rm -f /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyUSB[0-99]*",MODE="0666"' \
    | sudo tee -a /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyACM[0-99]*",MODE="0666"' \
    | sudo tee -a /etc/udev/rules.d/$rule_file

    sudo service udev restart
}

# =============================================================================
function _dj_udev_uvc_video_capture()
{
    rule_file=uvc-video-capture.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo -e "\n udev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    # finally ----------------
    string="SUBSYSTEMS==\"usb\", "
    string="${string}KERNEL==\"video[0-99]*\", "
    string="${string}ACTION==\"add\", "
    string="${string}ATTRS{idVendor}==\"18ec\", "
    string="${string}ATTRS{idProduct}==\"5555\", "
    # string="${string}ATTRS{manufacturer}==\"One Third Tech.\", " # do not delete
    string="${string}ATTRS{product}==\"USB2.0 PC CAMERA\", "
    string="${string}MODE=\"666\", "
    string="${string}SYMLINK+=\"uvc/video-cap\", "
    string="${string}GROUP=\"dialout\""
    echo "${string}" | sudo tee -a /etc/udev/rules.d/$rule_file

    sudo service udev restart
}

# =============================================================================
# the One Third Debugger contains a USB to serial port chip: FT232RL
function _dj_udev_one_third_console()
{
    rule_file=one-third-console.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo -e "\n udev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    # finally ----------------
    string="SUBSYSTEMS==\"usb\", "
    string="${string}KERNEL==\"ttyUSB[0-99]*\", "
    string="${string}ACTION==\"add\", "
    string="${string}ATTRS{idVendor}==\"0403\", "
    string="${string}ATTRS{idProduct}==\"6001\", "
    string="${string}ATTRS{manufacturer}==\"One Third Technologies\", "
    string="${string}ATTRS{product}==\"Console\", "
    string="${string}MODE=\"666\", "
    string="${string}SYMLINK+=\"one-third/console\", "
    string="${string}GROUP=\"dialout\""
    echo "${string}" | sudo tee -a /etc/udev/rules.d/$rule_file

    sudo service udev restart

    echo -e "\n if /dev/one-third/console can not be completed by tab,"
    echo -e "   you can edit the file ${GRN}/usr/share/bash-completion/completions/screen${NOC}"
    echo -e "     add the term \"/dev/one-third/* to the line"
    echo -e "        /dev/serial/by-id/* /dev/ttyUSB* /dev/ttyACM* 2>/dev/null)\" \n"
    echo -e "   or you can copy settings/screen-tab-completion as "
    echo -e "      /usr/share/bash-completion/completions/screen\n"
}

# =============================================================================
function _dj_udev_stlink_v2_1()
{
    rule_file=st-link-v2-1.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo -e "\n udev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    # finally ----------------
    string="SUBSYSTEMS==\"usb\", "
    string="${string}KERNEL==\"ttyACM[0-99]*\", "
    string="${string}ACTION==\"add\", "
    string="${string}ATTRS{idVendor}==\"0483\", "
    string="${string}ATTRS{idProduct}==\"3752\", "
    string="${string}ATTRS{manufacturer}==\"STMicroelectronics\", "
    string="${string}ATTRS{product}==\"STM32 STLink\", "
    string="${string}MODE=\"666\", "
    string="${string}SYMLINK+=\"st-link/vcp\", "
    string="${string}GROUP=\"dialout\""
    echo "${string}" | sudo tee -a /etc/udev/rules.d/$rule_file

    sudo service udev restart

    echo -e "\n if /dev/st-link/vcp can not be completed by tab,"
    echo -e "   you can edit the file ${GRN}/usr/share/bash-completion/completions/screen${NOC}"
    echo -e "     add the term \"/dev/one-third/* to the line"
    echo -e "        /dev/serial/by-id/* /dev/ttyUSB* /dev/ttyACM* 2>/dev/null)\" \n"
    echo -e "   or you can copy settings/screen-tab-completion as "
    echo -e "      /usr/share/bash-completion/completions/screen\n"
}

# =============================================================================
function _dj_udevadm()
{
    udevadm info -a -n $1
}
