#!/bin/bash 

# ===============================================================================
function _yocto_help()
{
    echo " "
    echo "---------------------  yocto ------------------------"
    echo " Author      : Dingjiang Zhou"
    echo " Email       : zhoudingjiang@gmail.com "
    echo " Create Date : June 8th, 2020 "
    echo "-----------------------------------------------------"
    echo " "
    echo " TODO"
    echo " "
}

# ===============================================================================
# note: the arguments imx7 or raspberry-pi-4 are not serious names of the platfroms
# original scripts for imx7-cl-som:
# sudo umount /dev/sda1
# sudo umount /dev/sda2
# sudo chmod 666 /dev/sda
# cd ~/yocto-cl-com-imx7/build/
# oe-run-native bmap-tools-native bmaptool copy tmp/deploy/images/imx7-cl-som/flexbot2-image-imx7-cl-som.wic.gz /dev/sda
# the above works only for the case when a USB-SD card reader is used:
# sda           8:0    1   3.6G  0 disk 
# ├─sda1        8:1    1  24.2M  0 part /media/robot/boot
# └─sda2        8:2    1 573.8M  0 part /media/robot/root
# if the native SD card reader is used, I see:
# mmcblk0     179:0    0   3.6G  0 disk 
# ├─mmcblk0p1 179:1    0    30M  0 part /media/robot/boot
# └─mmcblk0p2 179:2    0   2.6G  0 part /media/robot/root


function _yocto_flash()
{
    # argument check -------------------
    if [ $# -le 1 ] ; then
        echo -e "usage:\n   yocto flash <platform> /dev/sdx"
        echo "      or \n   yocto flash <platform> sdx"
        echo " use lsblk to find what is the sdx"
        return
    fi
    _display_section
    echo -e "yocto flash to SD card\r\n"

    # must be in a build folder --------------
    current_path=$(pwd | xargs -n1 basename)
    build_folder=`basename "$current_path"`
    if [ ! $build_folder = 'build' ]; then
        echo "not in a build folder, exit."
        echo 'you should use "source poky/oe-init-build-env" to enter the build folder'
        return
    fi
    
    # find the machine and tmp/ folder ---------------
    MACHINE=$(grep '^MACHINE = ' conf/local.conf | awk '{print $3 }' | sed 's/"//g')
    echo " MACHINE:" $MACHINE
    OETMP=$(grep '^TMPDIR' conf/local.conf | awk '{ print $3 }' | sed 's/"//g')
    if [ -z "$OETMP" ]; then
        if [ -d "tmp" ]; then
            OETMP="tmp"
        fi
    fi

    echo "  TMPDIR:" $OETMP
    # check the block device  ---------
    if [ -b ${2} ] ; then
        DEV=${2}
    else
        DEV=/dev/${2}
    fi
    
    if [ ! -b $DEV ] ; then
        echo "block device "$DEV" not found, use lsblk to find it. exit!"
        return
    fi

    # umount all partitions: /dev/sda1; /dev/sda2; /dev/sda3; etc -------------
    #                   or /dev/mmcblk0p1; /dev/mmcblk0p2; etc
    for i in {1..9} ; do
        partition=$DEV"${i}"
        if [ -b $partition ] ; then
            # check if mounted
            sudo mount | grep '^/' | grep -q $partition
            if [ $? -ne 1 ]; then # is mounted
                echo "to umount partition "$partition
                sleep 4 # just make it noticable
                sudo umount $partition
            fi
        fi
    done
    for i in {1..9} ; do
        partition=$DEV"p${i}"
        if [ -b $partition ] ; then
            # check if mounted
            sudo mount | grep '^/' | grep -q $partition
            if [ $? -ne 1 ]; then # is mounted
                echo "to umount partition "$partition
                sleep 4 # just make it noticable
                sudo umount $partition
            fi
        fi
    done
    _display_section
    echo " "
    
    # flash to SD card, depending on the platform
    if [ $1 = 'cl-som-imx7' ] ;  then
        sudo chmod 666 $DEV
        # find the image file ------------------
        IMAGE=$OETMP/deploy/images/$MACHINE/*-$MACHINE.wic.gz
        if [ ! -f $IMAGE ] ; then
            echo "image file not found! exit!!"
        fi
        echo -e "   IMAGE:" $IMAGE
        _display_section
        echo " "
        oe-run-native bmap-tools-native bmaptool copy $IMAGE $DEV
        return
    fi
    if [ $1 = 'raspberry-pi-4' ] ; then
        echo "TODO"
        return
    fi
    echo "yocto flash: platform not supported. exit!"
    return
}

# ===============================================================================
function yocto()
{
    current_folder=${PWD}

    # ------------------------------
    if [ $# -eq 0 ] ; then
        _yocto_help
        return
    fi

    # ------------------------------
    if [ $1 = 'clone' ] ; then
        dj clone github $2 $3 $4 $5 $6 $7 $8
        return
    fi

    # ------------------------------
    if [ $1 = 'flash' ] ; then
        _yocto_flash $2 $3 $4 $5 $6 $7 $8
        return
    fi
    echo -e '\r\nyocto : "'$1 '"command not supported\r\n'
    _yocto_help

    # ------------------------------
    cd $current_folder
    unset current_folder
}

# ===============================================================================
function _yocto()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        clone
        flash
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ---------------------------------------------------------------------------------
    ACTIONS[clone]+="poky meta-openembedded meta-raspberrypi meta-rpi64 "
    ACTIONS[poky]=" "
    ACTIONS[meta-openembedded]=" "
    ACTIONS[meta-raspberrypi]=" "
    ACTIONS[meta-rpi64]=" "
    ACTIONS[flash]="cl-som-imx7 raspberry-pi-4 "
    ACTIONS[cl-som-imx7]=" "
    ACTIONS[raspberry-pi-4]=" "
    
    # ---------------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# ===============================================================================
complete -F _yocto yocto
