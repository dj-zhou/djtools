#!/bin/bash

# =============================================================================
function _dj_udev_help() {
    _dj_help
    cat <<eom
    --------------------- dj udev ----------------------
    Second level commands:
       --dialout         - set the current user to dialout group
       --show            - ls udev rule files in /etc/udev/rules.d
       ft4232h           - setup the udev rule for the customized FT4232H by 
                           One Third Technologies
       logitech-f710     - setup the udev rule for the LogiTech F710 game pad
       stlink-v2.1       - setup the udev rule for ST-Link V2.1 debugger
       one-third-console - setup the udev rule for the customized console by
                           One Third Technologies, use FT232RL
       uvc-video-capture - setup the udev rule for the UVC
                           video capture device"
       MORE IS COMMING
    -------------------------------------------------------
eom
}

# =============================================================================
function _dj_udevadm_help() {
    _dj_help
    cat <<eom
    --------------------- dj udevadm ----------------------
    used to grab information of a device, for example:
    $  dj udevadm /dev/ttyUSB0
    -------------------------------------------------------
eom
}

# =============================================================================
function _dj_udev_dialout() {
    echo \-e "\n This is to solve the serial port problem: Permission denied\n"

    sudo usermod -a -G dialout $USER

    rule_file=udev-dialout.rules
    echo -e "udev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    sudo rm -f /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyUSB*",MODE="0666"' |
        sudo tee -a /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyACM*",MODE="0666"' |
        sudo tee -a /etc/udev/rules.d/$rule_file

    sudo service udev restart
}

# =============================================================================
function _dj_udev_show() {
    cur_dir=${PWD}

    cd /etc/udev/rules.d/
    pwd
    tree

    cd $cur_dir
}

# =============================================================================
function _dj_udev_uvc_video_capture() {
    rule_file=uvc-video-capture.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo -e "\nudev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    # finally ----------------
    string="SUBSYSTEMS==\"usb\", "
    string="${string}KERNEL==\"video*\", "
    string="${string}ACTION==\"add\", "
    string="${string}ATTRS{idVendor}==\"18ec\", "
    string="${string}ATTRS{idProduct}==\"5555\", "
    string="${string}ATTRS{product}==\"USB2.0 PC CAMERA\", "
    string="${string}MODE=\"666\", "
    string="${string}SYMLINK+=\"uvc/video-cap\", "
    string="${string}GROUP=\"dialout\""
    echo "${string}" | sudo tee -a /etc/udev/rules.d/$rule_file

    sudo service udev restart
}

# =============================================================================
function _dj_udev_logitech_f710() {
    rule_file=logitech-f710-x.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo -e "\nudev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    string="SUBSYSTEMS==\"usb\", "
    string="${string}KERNEL==\"js*\", "
    string="${string}ACTION==\"add\", "
    string="${string}ATTRS{idVendor}==\"046d\", "
    string="${string}ATTRS{idProduct}==\"c21f\", "
    string="${string}ATTRS{manufacturer}==\"Logitech\", "
    string="${string}MODE=\"666\", "
    string="${string}SYMLINK+=\"joy/f710\", "
    string="${string}GROUP=\"dialout\""
    echo "${string}" | sudo tee -a /etc/udev/rules.d/$rule_file

    sudo service udev restart

    # the joystick can change its property -----------------------
    rule_file=logitech-f710-d.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo -e "\nudev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    string="SUBSYSTEMS==\"usb\", "
    string="${string}KERNEL==\"js*\", "
    string="${string}ACTION==\"add\", "
    string="${string}ATTRS{idVendor}==\"046d\", "
    string="${string}ATTRS{idProduct}==\"c219\", "
    string="${string}ATTRS{manufacturer}==\"Logitech\", "
    string="${string}MODE=\"666\", "
    string="${string}SYMLINK+=\"joy/f710\", "
    string="${string}GROUP=\"dialout\""
    echo "${string}" | sudo tee -a /etc/udev/rules.d/$rule_file

    sudo service udev restart
}

# =============================================================================
# the One Third Debugger contains a USB to serial port chip: FT232RL
function _dj_udev_one_third_console() {
    rule_file=one-third-console.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo -e "\nudev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    # finally ----------------
    string="SUBSYSTEMS==\"usb\", "
    string="${string}KERNEL==\"ttyUSB*\", "
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

    echo -e "\nif /dev/one-third/console can not be completed by tab,"
    echo -e "   you can edit the file ${GRN}/usr/share/bash-completion/completions/screen${NOC}"
    echo -e "   add the term \"/dev/one-third/* to the line"
    echo -e "        /dev/serial/by-id/* /dev/ttyUSB* /dev/ttyACM* 2>/dev/null)\" \n"
    echo -e "   or you can copy settings/screen-tab-completion as "
    echo -e "      /usr/share/bash-completion/completions/screen\n"
}

# =============================================================================
# the One Third Debugger contains a USB to serial port chip: FT232RL
# need to manually configure the chip from FT_Prog on Windows, set:
#         product: Comm+Console
#    manufacturer: One Third Technologies
# try this: ls -l /dev/serial/by-id/
function _dj_udev_ft4232h() {
    rule_file=ft4232h-serial.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo -e "\nudev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    string="SUBSYSTEMS==\"usb\", ENV{.LOCAL_serial}=\"\$attr{serial}\"\n"
    string="${string}SUBSYSTEMS==\"usb\", ENV{.LOCAL_ifNum}=\"\$attr{bInterfaceNumber}\"\n"
    # finally ----------------
    for i in 0 1 2 3; do
        string="${string}SUBSYSTEMS==\"usb\", "
        string="${string}KERNEL==\"ttyUSB*\", "
        string="${string}ACTION==\"add\", "
        string="${string}ATTRS{idVendor}==\"0403\", "
        string="${string}ATTRS{idProduct}==\"6011\", "
        string="${string}ENV{.LOCAL_ifNum}==\"0${i}\", "
        string="${string}ATTRS{manufacturer}==\"One Third Technologies\", "
        string="${string}ATTRS{product}==\"Comm+Console\", "
        string="${string}MODE=\"666\", "
        string="${string}SYMLINK+=\"ft4232h/serial${i}\", "
        string="${string}GROUP=\"dialout\"\n"
    done

    echo -e "${string}" | sudo tee -a /etc/udev/rules.d/$rule_file
    sudo service udev restart
}

# =============================================================================
function _dj_udev_stlink_v2_1() {
    rule_file=st-link-v2-1.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo -e "\nudev rule file: "$rule_file" written to /etc/udev/rule.d/\n"

    # finally ----------------
    string="SUBSYSTEMS==\"usb\", "
    string="${string}KERNEL==\"ttyACM*\", "
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

    echo -e "\nif /dev/st-link/vcp can not be completed by tab,"
    echo -e "   you can edit the file ${GRN}/usr/share/bash-completion/completions/screen${NOC}"
    echo -e "   add the term \"/dev/one-third/* to the line"
    echo -e "        /dev/serial/by-id/* /dev/ttyUSB* /dev/ttyACM* 2>/dev/null)\" \n"
    echo -e "   or you can copy settings/screen-tab-completion as "
    echo -e "      /usr/share/bash-completion/completions/screen\n"
}

# =============================================================================
function _dj_udevadm() {
    udevadm info -a -n $1
}

# =============================================================================
function _dj_udev() {
    # --------------------------
    if [ $1 = '--dialout' ]; then
        _dj_udev_dialout $2 $3 $4
        return
    fi
    # --------------------------
    if [ $1 = '--show' ]; then
        _dj_udev_show
        return
    fi
    # --------------------------
    if [ $1 = 'logitech-f710' ]; then
        _dj_udev_logitech_f710 $2 $3 $4
        return
    fi
    # --------------------------
    if [ $1 = 'one-third-console' ]; then
        _dj_udev_one_third_console $2 $3 $4
        return
    fi
    # --------------------------
    if [ $1 = 'ft4232h' ]; then
        _dj_udev_ft4232h
        return
    fi
    # --------------------------
    if [ $1 = 'uvc-video-capture' ]; then
        _dj_udev_uvc_video_capture $2 $3 $4
        return
    fi
    # --------------------------
    if [ $1 = 'stlink-v2.1' ]; then
        _dj_udev_stlink_v2_1 $2 $3 $4
        return
    fi
    _dj_udev_help
    return
}
