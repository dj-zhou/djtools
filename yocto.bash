#!/bin/bash 

# =============================================================================================
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

# =============================================================================================
# note: the arguments imx7 or raspberry-pi-4 are not serious names of the platfroms
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
    for i in {1..9} ; do
        partition=$DEV"${i}"
        if [ -b $partition ] ; then
            # check if mounted
            sudo mount | grep '^/' | grep -q $partition
            if [ $? -ne 1 ]; then # is mounted
                echo "to umount partition "$partition
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

# =============================================================================================
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

# =============================================================================================
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

# =============================================================================================
complete -F _yocto yocto
