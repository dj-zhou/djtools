#!/bin/bash

# =============================================================================
function _yocto_help()
{
    cat << EOM

------------------------------------  yocto -----------------------------------
   Author      : Dingjiang Zhou
   Email       : zhoudingjiang@gmail.com
   Create Date : June 8th, 2020
-------------------------------------------------------------------------------

  The yocto toolset is to make the Yocto related commands simpler, supported
  commands:
     clone   -- to clone some common used repos
     flash   -- to flash the image into SD card
     install -- to install Yocto related software

EOM
}

# =============================================================================
function _yocto_install_dependencies()
{
    sudo apt-get install -y autoconf
    sudo apt-get install -y automake
    sudo apt-get install -y bmap-tools
    sudo apt-get install -y bsdmainutils
    sudo apt-get install -y build-essential
    sudo apt-get install -y chrpath
    sudo apt-get install -y coreutils
    sudo apt-get install -y cpio
    sudo apt-get install -y curl
    sudo apt-get install -y dblatex
    sudo apt-get install -y debianutils
    sudo apt-get install -y desktop-file-utils
    sudo apt-get install -y diffstat
    sudo apt-get install -y docbook-utils
    sudo apt-get install -y dosfstools
    sudo apt-get install -y dos2unix # added due to any error report when bitbake
    sudo apt-get install -y fop
    sudo apt-get install -y gawk
    sudo apt-get install -y gcc
    sudo apt-get install -y gcc-multilib
    sudo apt-get install -y git-core
    sudo apt-get install -y gnupg
    sudo apt-get install -y groff
    sudo apt-get install -y g++
    sudo apt-get install -y iputils-ping
    sudo apt-get install -y libegl1-mesa
    sudo apt-get install -y libgl1-mesa-dev
    sudo apt-get install -y libglib2.0-dev
    sudo apt-get install -y libglu1-mesa-dev
    sudo apt-get install -y libsdl1.2-dev
    sudo apt-get install -y libstdc++-5-dev # unavailable on Ubuntu 20.04
    sudo apt-get install -y libtool
    sudo apt-get install -y libx11-dev
    sudo apt-get install -y libxml-parser-perl
    sudo apt-get install -y make
    sudo apt-get install -y mtools
    sudo apt-get install -y parted
    sudo apt-get install -y pylint3
    sudo apt-get install -y python
    sudo apt-get install -y python-git # unavailable on Ubuntu 20.04
    sudo apt-get install -y python-gtk2
    sudo apt-get install -y python-pysqlite2
    sudo apt-get install -y python3
    sudo apt-get install -y python3-git
    sudo apt-get install -y python3-jinja2
    sudo apt-get install -y python3-pexpect
    sudo apt-get install -y python3-pip
    sudo apt-get install -y screen
    sudo apt-get install -y sed
    sudo apt-get install -y socat
    sudo apt-get install -y subversion
    sudo apt-get install -y texi2html
    sudo apt-get install -y texinfo
    sudo apt-get install -y unzip
    sudo apt-get install -y wget
    sudo apt-get install -y xmlto
    sudo apt-get install -y xsltproc
    sudo apt-get install -y xterm
    sudo apt-get install -y xz-utils

    # dependencies needed for building documents
    sudo apt-get install -y fonts-liberation
    sudo apt-get install -y libfreetype6-dev
    sudo apt-get install -y libjpeg8-dev
    sudo apt-get install -y python3-dev
    sudo apt-get install -y python3-sphinx
    sudo apt-get install -y texlive-fonts-recommended
    sudo apt-get install -y texlive-latex-extra
    sudo apt-get install -y zlib1g-dev
    sudo pip3 install reportlab sphinxcontrib-blockdiag

    # SD card flash tools
    sudo apt-get install -y bmap-tools
}

# =============================================================================
# note: the arguments imx7 or raspberry-pi-4 are not serious names of the platforms
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

# this function only runs in the build directory.
# The build directory can be of any name, but it's content looks very similar:
# .
# ├── bitbake-cookerdaemon.log
# ├── cache
# ├── conf
# ├── downloads
# ├── sstate-cache
# └── tmp

# =============================================================================
function _yocto_check_is_a_build_directory()
{
    # this only check the current directory/path
    if [ ! -d "conf" ] ; then
        echo "false"
        return
    fi
    if [ ! -f "conf/local.conf" ] ; then
        echo "false"
        return
    fi
    if [ ! -f "conf/bblayers.conf" ] ; then
        echo "false"
        return
    fi
    if [ ! -d "tmp" ] ; then
        echo "false"
        return
    fi
    if [ ! -d "tmp/deploy/images" ] ; then
        echo "false"
        return
    fi
    if [ ! -d "sstate-cache" ] ; then
        echo "false"
        return
    fi
    echo "true"
    return
}

# it can also be MACHINE ??= "xxxx", MACHINE ??= 'xxxx'
# it can also be MACHINE ?= "xxxx", MACHINE ?= 'xxxx'
function _yocto_find_MACHINE()
{
    MACHINE=$(grep '^MACHINE = ' conf/local.conf | awk '{print $3 }' | sed 's/"//g' | sed "s/'//g")
    if [ ! -z $MACHINE ] ; then
        echo $MACHINE
        return
    fi
    MACHINE=$(grep '^MACHINE ?= ' conf/local.conf | awk '{print $3 }' | sed 's/"//g' | sed "s/'//g")
    if [ ! -z $MACHINE ] ; then
        echo $MACHINE
        return
    fi
    MACHINE=$(grep '^MACHINE ??= ' conf/local.conf | awk '{print $3 }' | sed 's/"//g' | sed "s/'//g")
    if [ ! -z $MACHINE ] ; then
        echo $MACHINE
        return
    fi
    echo " " # not found
    return
}

# =============================================================================
function _yocto_find_tmp_folder()
{
    TMPDIR=$(grep '^TMPDIR =' conf/local.conf | awk '{ print $3 }' | sed 's/"//g' | sed "s/'//g")
    if [ ! -z $TMPDIR ] ; then
        echo $TMPDIR
        return
    fi
    TMPDIR=$(grep '^TMPDIR ?=' conf/local.conf | awk '{ print $3 }' | sed 's/"//g' | sed "s/'//g")
    if [ ! -z $TMPDIR ] ; then
        echo $TMPDIR
        return
    fi
    TMPDIR=$(grep '^TMPDIR ??=' conf/local.conf | awk '{ print $3 }' | sed 's/"//g' | sed "s/'//g")
    if [ ! -z $TMPDIR ] ; then
        echo $TMPDIR
        return
    fi
    echo " " # not found
    return
}

# =============================================================================
function _yocto_find_block_device()
{
    dev_to_check=$1
    # echo "dev_to_check = "$dev_to_check
    if [ -b $dev_to_check ] ; then
        echo $dev_to_check
        return
    fi
    if [ -b /dev/${dev_to_check} ] ; then
        echo "/dev/${dev_to_check}"
        return
    fi
    echo " " # not found

}

# =============================================================================
function _yocto_prepare_sd_card()
{
    sd_card=$1

    # umount all partitions: /dev/sda1; /dev/sda2; /dev/sda3; etc
    for i in {1..9} ; do
        partition=$sd_card"${i}"
        if [ -b $partition ] ; then
            # check if mounted
            sudo mount | grep '^/' | grep -q $partition
            if [ $? -ne 1 ] ; then # is mounted
                echo " umount partition:" $partition
                sleep 1 # just make it noticable
                sudo umount $partition
            else
                echo " partition: $partition not mounted."
            fi
        fi
    done
    # umount all partitions: /dev/mmcblk0p1; /dev/mmcblk0p2; etc
    for i in {1..9} ; do
        partition=$sd_card"p${i}"
        if [ -b $partition ] ; then
            # check if mounted
            sudo mount | grep '^/' | grep -q $partition
            if [ $? -ne 1 ] ; then # is mounted
                echo " umount partition:" $partition
                sleep 1 # just make it noticable
                sudo umount $partition
            else
                echo " partition: $partition not mounted."
            fi
        fi
    done
    sudo chmod 666 $sd_card
    echo -e "\n"
}

# =============================================================================
function _yocto_flash_wic_gz_OLD() # $MACHINE $TMPDIR $DEV $wic_gz_file
{
    MACHINE=$1
    TMPDIR=$2
    DEV=$3
    wic_gz_file=$4

    # find the image file ------------------
    if [ -z $wic_gz_file ] ; then
        potential_images=$(ls $TMPDIR/deploy/images/$MACHINE/ | grep wic.gz)
        potential_images=$(echo $potential_images | awk '{ print $2 }' )
        IMAGE=$TMPDIR/deploy/images/$MACHINE/$potential_images
        bmap_file=$(echo $IMAGE | sed "s/wic.gz/wic.bmap/g" )
    else
        IMAGE=$wic_gz_file
        bmap_file=$(echo $wic_gz_file | sed "s/wic.gz/wic.bmap/g" )
    fi
    
    # if it is a symbolic file, find the real file ------------------
    if [ -L $IMAGE ] ; then
        IMAGE=$(readlink -f $IMAGE)
    fi
    # if file does not exist, exit ------------------
    if [ ! -f $IMAGE ] ; then
        echo -e "\n image file not found! exit!!"
        return
    fi

    # file size ------------------
    fz_byte=$(stat -c %s $IMAGE)
    fz_kbyte=$((fz_byte/1024))
    fz_mbyte=$((fz_kbyte/1024))
    if [ $fz_kbyte = '0' ] ;  then
        echo -e "   IMAGE: $IMAGE\n    size: $fz_byte bytes\n"
    elif [ $fz_mbyte = '0' ] ;  then
        echo -e "   IMAGE: $IMAGE\n    size: $fz_kbyte KiB\n"
    else
        echo -e "   IMAGE: $IMAGE\n    size: $fz_mbyte MiB\n"
    fi    
}

# if it is a symbolic file, find the real file ------------------
# if [ -L $IMAGE ] ; then
#     IMAGE=$(readlink -f $IMAGE)
# fi
# =============================================================================
function _yocto_flash_wic_gz() # $platform $DEV $wic_gz_file
{
    platform=$1
    DEV=$2
    wic_gz_file=$3
    if [ ! -f $wic_gz_file ] ; then
        echo -e "\n ${RED} wic.gz file not found, exit.${NOC}\n"
        return
    fi
    # if it is a symbolic file ----------
    if [ -L $wic_gz_file ] ; then
        wic_gz_file=$(readlink -f $wic_gz_file)
    fi

    bmap_file=$(echo $wic_gz_file | sed "s/wic.gz/wic.bmap/g" )
    # prepare the SD card, umount, chmod 666, etc ------------
    _display_section
    _yocto_prepare_sd_card $DEV

    _display_section
    echo -e "\n start to flash to: ${GRN}$platform${NOC}"
    file_size=$(stat -c %s $wic_gz_file)
    echo -e " file size: ${GRN}$(_size_calculate $file_size false)${NOC}"
    
    # finally, flash to the SD card ------------------
    if [[ -f $bmap_file ]] ; then
        # the following command need to use a *.wic.bmap file in the same path
        # of the wic.gz file
        echo -e "\n bmap file found."
        echo -e " oe-run-native bmap-tools-native bmaptool copy $wic_gz_file $DEV\n"
        _press_enter_to_continue
        oe-run-native bmap-tools-native bmaptool copy $wic_gz_file $DEV
    else
        echo -e "\n bmap file ${RED}NOT${NOC} found."
        echo  -e " sudo bmaptool copy -nobmap $wic_gz_file $DEV\n"
        _press_enter_to_continue
        sudo bmaptool copy --nobmap $wic_gz_file $DEV
    fi
}

# =============================================================================
# $1 must be the platform
# $2 mut be the device
# $3 to all others, can be -f and other options
function _yocto_flash()
{
    # argument check -------------------
    if [ $# -le 1 ] ; then
        echo -e "\n usage:\n   yocto flash <platform> /dev/sdx"
        echo -e "      or \n   yocto flash <platform> sdx"
        echo -e "      or \n   yocto flash <platform> sdx -f [filename].wic.gz"
        echo " use \"lsblk\" to find what is the sdx"
        return
    fi

    platform=$1
    dev_str=$2

    # check the block device  ---------
    _display_section
    DEV=$(_yocto_find_block_device $dev_str)
    if [ -z $DEV ] ; then
        echo -e "\n block device $dev_str not found, exit!!"
        echo -e " you can use command \"lsblk\" to find it.\n"
        return
    fi
    echo -e "     DEV: ${GRN}$DEV${NOC}, $(_disk_size $DEV false)."

    # if -f option is used, flash directly -----------
    if [[ $(_if_option_exist -f $@) = "true" ]] ; then
        wic_gz_file=$(_find_argument_after_option -f $3 $4 $5 $6 $7 $8)
        _yocto_flash_wic_gz $platform $DEV $wic_gz_file
        return
    fi
    
    # otherwise, need to find the wic.gz file from the build directory -------
    # must be in a build folder --------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ] ; then
        echo -e "\n ${RED}not in a valid bitbake build directory, exit!!${NOC}\n"
        return
    fi

    # find MACHINE ----------------
    MACHINE=$(_yocto_find_MACHINE)
    if [ -z $MACHINE ] ; then
        echo -e "\n ${RED} MACHINE not found, exit!!${NOC}"
        echo -e " you may need to update the _yocto_find_MACHINE() function.\n"
        return
    fi
    echo -e " MACHINE: ${GRN}$MACHINE${NOC}"

    # find tmp/ folder ---------------
    TMPDIR=$(_yocto_find_tmp_folder)
    if [ -z $TMPDIR ] ; then
        if [ -d "tmp" ] ; then
            TMPDIR="tmp"
        fi
    fi
    echo -e "  TMPDIR: ${GRN}$TMPDIR${NOC}"

    # flash to the sd card depends on the platform -------
    case $platform in

        'imx7-cl-som' | 'imx6ullevk' )
            potential_images=$(ls $TMPDIR/deploy/images/$MACHINE/ | grep wic.gz)
            potential_images=$(echo $potential_images | awk '{ print $2 }' )
            wic_gz_file=$TMPDIR/deploy/images/$MACHINE/$potential_images
            # why this need internet??
            _yocto_flash_wic_gz $platform $DEV $wic_gz_file
            ;;

        'raspberry-pi-4')
            echo -e "\n ${RED}aspberry-pi-4: todo${NOC}"
            ;;

        *)
            echo -e "\n ${RED}platform not implemented: todo${NOC}"
            ;;
    esac
}

# =============================================================================
function _yocto_list_machines()
{
    echo -e "ls */conf/machine/*.conf\n"
    ls -l */conf/machine/*.conf
}

# =============================================================================
function _yocto_list_images
{
    echo -e "ls */recipes*/images*/*.bb\n"
    ls -l */recipes*/images*/*.bb
}

# =============================================================================
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
        _yocto_flash $2 $3 $4 $5 $6 $7 $8 $9 ${10}
        return
    fi
    # ------------------------------
    if [ $1 = 'install' ] ; then
        if [ $# = 1 ] ; then
            _yocto_help
            return
        fi
        if [ $2 = 'dependencies' ] ; then
            _yocto_install_dependencies $3 $4 $5 $6 $7
            return
        fi
        echo -e "\n yocto install: $2 command not supported\n"
        return
    fi
    # ------------------------------
    if [ $1 = 'list' ] ; then
        if [ $# = 1 ] ; then
            _yocto_help
            return
        fi
        if [ $2 = 'machines' ] ; then
            _yocto_list_machines
            return
        fi
        if [ $2 = 'images' ] ; then
            _yocto_list_images
            return
        fi
        echo -e "\n yocto list: $2 command not supported\n"
        return
    fi
    echo -e '\n yocto : "'$1 '"command not supported\n'
    _yocto_help

    # ------------------------------
    cd $current_folder
    unset current_folder
}

# =============================================================================
function _yocto()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        clone
        flash
        install
        list
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    ACTIONS[clone]+="poky meta-openembedded meta-raspberrypi meta-rpi64 "
    ACTIONS[poky]=" "
    ACTIONS[meta-openembedded]=" "
    ACTIONS[meta-raspberrypi]=" "
    ACTIONS[meta-rpi64]=" "
    target_board="imx7-cl-som imx6ullevk raspberry-pi-4 "
    ACTIONS[flash]="$target_board"
    target_card="sda sdb sdc sdd sde sdf sdg "
    target_card+="/dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg "
    for i in $target_board ; do
        ACTIONS[$i]="$target_card "
    done
    for i in $target_card ; do
        ACTIONS[$i]=" "
    done
    ACTIONS[install]+="dependencies "
    ACTIONS[dependencies]=" "
    ACTIONS[list]+="machines images "
    ACTIONS[machines]+=" "
    ACTIONS[images]+=" "

    # smart tab-completion ----------------
    wic_gz_files="$(ls . | grep wic.gz)"
    ACTIONS[-f]="$wic_gz_files "
    for i in $wic_gz_files ; do
        ACTIONS[$i]=" "
    done
    
    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================
complete -F _yocto yocto
