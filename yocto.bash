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
function _yocto_find_image_name()
{
    current_folder=${PWD}

    # must be a valid buid directory ------------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ] ; then
        # echo -e "\n ${PRP}_yocto_find_image_name${NOC}:"
        # echo -e "    not in a valid bitbake build directory, exit!!\n"
        return
    fi
    # find tmp/ folder ---------------
    TMPDIR=$(_yocto_find_tmp_folder)
    if [ -z $TMPDIR ] ; then
        if [ -d "tmp" ] ; then
            TMPDIR="tmp"
        fi
    fi

    MACHINE=$(_yocto_find_MACHINE)
    if [ -z $MACHINE ] ; then
        # echo -e "\n ${PRP}_yocto_find_image_name${NOC}:"
        # echo -e "    MACHINE not found, exit!!\n"
        return
    fi

    cd $TMPDIR/deploy/images/$MACHINE
    find_wic_gz=$(ls | grep wic.gz)
    # echo $find_wic_gz
    if [[ ! -z $find_wic_gz ]] ; then
        wic_gz_file=$(echo $find_wic_gz | awk '{print $1}')
    fi
    # echo $wic_gz_file

    image_name=${wic_gz_file%"-$MACHINE"*}
    echo $image_name
    cd $current_folder
}

# =============================================================================
function _yocto_install_sdk_plain()
{
    # must be a valid buid directory ------------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ] ; then
        echo -e "\n ${PRP}yocto install sdk${NOC}:"
        echo -e "    not in a valid bitbake build directory, exit!!\n"
        return
    fi
    # find tmp/ folder ---------------
    TMPDIR=$(_yocto_find_tmp_folder)
    if [ -z $TMPDIR ] ; then
        if [ -d "tmp" ] ; then
            TMPDIR="tmp"
        fi
    fi

    # check if there is a sdk/ folder --------------
    if [ ! -d $TMPDIR/deploy/sdk ] ; then
        echo -e "\n ${PRP}yocto install sdk${NOC}:"
        echo -e "    no SDK folder found, exit!!"
        echo -e "    run: \"bitbake -c populate_sdk <image>\" to build a SDK.\n"
        return
    fi
    
    # there should be only one sh file, and that is the SDK source
    sdk_source=$(ls $TMPDIR/deploy/sdk | grep host.manifest | sed 's/host.manifest/sh/g')
    echo " sdk_source : "$sdk_source

    # the SDK should be put into folder ~/.<image>-sdk
    # find the image name and MACHINE ---------
    image_name=$(_yocto_find_image_name)
    machine=$(_yocto_find_MACHINE)
    sdk_folder=$HOME/.$image_name-$machine-oesdk/

    # remove the existing sdk folder ---------
    if [ -d $sdk_folder ] ; then
        sudo rm $sdk_folder -r
    fi
    unset LD_LIBRARY_PATH # this is important, why? not sure yet.
    ./$TMPDIR/deploy/sdk/$sdk_source -d $sdk_folder
}

# =============================================================================
# note: the arguments imx7 or raspberry-pi-4 are not serious names of the machines
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
    echo "true"
    return
}

# =============================================================================
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
                echo -e " umount partition:" ${GRN}$partition${NOC}
                sleep 1 # just make it noticable
                sudo umount $partition
            else
                echo -e "        partition: ${GRN}$partition${NOC} not mounted"
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
                echo -e " umount partition:" ${GRN}$partition${NOC}
                sleep 1 # just make it noticable
                sudo umount $partition
            else
                echo -e "        partition: ${GRN}$partition${NOC} not mounted"
            fi
        fi
    done
    sudo chmod 666 $sd_card
}

# =============================================================================
function _yocto_flash_wic_gz() # $machine $DEV $wic_gz_file
{
    machine=$1
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
    TMPDIR=$(_yocto_find_tmp_folder)
    if [ -z $TMPDIR ] ; then
        if [ -d "tmp" ] ; then
            TMPDIR="tmp"
        fi
    fi
    # machine=$(_yocto_find_MACHINE)
    wic_gz_file_name=$(echo $wic_gz_file | sed "s|${PWD}||g" )
    wic_gz_file_name=$(echo $wic_gz_file_name | sed "s|/${TMPDIR}/deploy/images/${machine}/||g" )
    echo -e "       image file: ${GRN}$wic_gz_file_name${NOC}"
    file_size=$(stat -c %s $wic_gz_file)
    echo -e "       image size: ${GRN}$(_size_calculate $file_size false)${NOC}"
    # stat -c %y djtools.bash
    build_time=$(stat -c %y $wic_gz_file)
    build_time=${build_time%"."*}
    echo -e "       build time: ${GRN}$build_time${NOC}"

    # finally, flash to the SD card ------------------
    if [[ -f $bmap_file ]] ; then
        # the following command need to use a *.wic.bmap file in the same path
        # of the wic.gz file
        echo -e "\n bmap file found, run command:"
        echo -e " oe-run-native bmap-tools-native bmaptool copy <image> $DEV\n"
        _press_enter_or_wait_s_continue 10
        oe-run-native bmap-tools-native bmaptool copy $wic_gz_file $DEV
    else
        echo -e "\n bmap file ${YLW}NOT${NOC} found, run command:"
        echo  -e " sudo bmaptool copy -nobmap $wic_gz_file $DEV\n"
        _press_enter_or_wait_s_continue 10
        sudo bmaptool copy --nobmap $wic_gz_file $DEV
    fi
}

# =============================================================================
# $1 must be the machine
# $2 mut be the device
# $3 to all others, can be -f and other options
function _yocto_flash()
{
    # argument check -------------------
    if [ $# -le 1 ] ; then
        echo -e "\n usage:\n   yocto flash <machine> /dev/sdx"
        echo -e "      or \n   yocto flash <machine> sdx"
        echo -e "      or \n   yocto flash <machine> sdx -f [filename].wic.gz"
        echo " use \"lsblk\" to find what is the sdx"
        return
    fi

    machine=$1
    dev_str=$2

    # check the block device  ---------
    _display_section
    DEV=$(_yocto_find_block_device $dev_str)
    if [ -z $DEV ] ; then
        echo -e "\n block device $dev_str not found, exit!!"
        echo -e " you can use command \"lsblk\" to find it.\n"
        return
    fi
    echo -e "          SD card: ${GRN}$DEV${NOC}"
    echo -e "             size: ${GRN}$(_disk_size $DEV false)${NOC}"

    # if -f option is used, flash directly -----------
    if [[ $(_if_option_exist -f $@) = "true" ]] ; then
        wic_gz_file=$(_find_argument_after_option -f $3 $4 $5 $6 $7 $8)
        _yocto_flash_wic_gz $machine $DEV $wic_gz_file
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
    echo -e "          MACHINE: ${GRN}$MACHINE${NOC}"

    # find tmp/ folder ---------------
    TMPDIR=$(_yocto_find_tmp_folder)
    if [ -z $TMPDIR ] ; then
        if [ -d "tmp" ] ; then
            TMPDIR="tmp"
        fi
    fi
    echo -e "           TMPDIR: ${GRN}$TMPDIR${NOC}"

    # flash to the sd card depends on the machine -------
    case $machine in

        'imx7-cl-som' | 'imx6ullevk' | 'wandboard' )
            potential_images=$(ls $TMPDIR/deploy/images/$MACHINE/ | grep wic.gz)
            potential_images=$(echo $potential_images | awk '{ print $2 }' )
            wic_gz_file=$TMPDIR/deploy/images/$MACHINE/$potential_images
            # why this need internet??
            _yocto_flash_wic_gz $machine $DEV $wic_gz_file
            ;;

        'raspberry-pi-4')
            echo -e "\n ${RED}aspberry-pi-4: todo${NOC}"
            ;;

        *)
            echo -e "\n ${RED}machine not implemented: todo${NOC}"
            ;;
    esac
}

# =============================================================================
function _yocto_list_machines()
{
    echo -e "\nls */conf/machine/*.conf\n"
    ls -l */conf/machine/*.conf 2>/dev/null
    ls -l */*/conf/machine/*.conf 2>/dev/null
    ls -l */*/*/conf/machine/*.conf 2>/dev/null
    ls -l */*/*/*/conf/machine/*.conf 2>/dev/null
}

# =============================================================================
function _yocto_list_images
{
    echo -e "\n ls */recipes*/images*/*.bb\n"
    ls -l */recipes*/images*/*.bb 2>/dev/null
    ls -l */*/recipes*/images*/*.bb 2>/dev/null
    ls -l */*/*/recipes*/images*/*.bb 2>/dev/null
    ls -l */*/*/*/recipes*/images*/*.bb  2>/dev/null
}

# =============================================================================
function _yocto_reset_env_variables()
{
    source ~/.bashrc
    unset ARCH
    unset GDB
    unset OPENSSL_CONF
    unset CONFIG_SITE
    unset SDKTARGETSYSROOT
    unset CFLAGS
    unset M4
    unset KCFLAGS
    unset OECORE_ACLOCAL_OPTS
    unset CC
    unset READELF
    unset OECORE_DISTRO_VERSION
    unset OECORE_SDK_VERSION
    unset PKG_CONFIG_SYSROOT_DIR
    unset CXXFLAGS
    unset STRIP
    unset OBJCOPY
    unset CONFIGURE_FLAGS
    unset OECORE_NATIVE_SYSROOT
    unset RANLIB
    unset OBJDUMP
    unset AS
    unset AR
    unset TARGET_PREFIX
    unset MM
    unset CXX
    unset OECORE_TARGET_OS
    unset OECORE_TARGET_ARCH
    unset OECORE_TARGET_SYSROOT
    unset CROSS_COMPILE
    unset OE_CMAKE_TOOLCHAIN_FILE
    unset CPPFLAGS
    unset LDFLAGS
    unset OE_CMAKE_FIND_LIBRARY_CUSTOM_LIB_SUFFIX
    unset PATH
    unset OECORE_BASELIB
    unset PKG_CONFIG_PATH
    unset CPP
    unset LD

    # not very sure about this operation
    export PATH=${HOME}/.local/bin
    export PATH=$PATH:${HOME}/.local/bin
    export PATH=$PATH:/usr/local/sbin
    export PATH=$PATH:/usr/local/bin
    export PATH=$PATH:/usr/sbin
    export PATH=$PATH:/usr/bin
    export PATH=$PATH:/sbin
    export PATH=$PATH:/bin
    export PATH=$PATH:/usr/games
    export PATH=$PATH:/usr/local/games
    export PATH=$PATH:/snap/bin

}

# =============================================================================
function _yocto_build_use_sdk() # sdk_folder
{
    current_folder=${PWD}

    sdk_path="${HOME}/$1-oesdk"
    sdk_env_set=$(ls $sdk_path | grep environment)

    if [ -n "$2" ] && [ $2 = '--conti' ] ; then
        # contains _bsdk folder
        if [ -d _bsdk ] ; then
            cd _bsdk
            unset LD_LIBRARY_PATH
            source $sdk_path/$sdk_env_set
            ninja
            echo -e "\n ${PRP}yocto build -use-sdk${NOC}"
            echo -e "    with \"--conti\" option: contains _bsdk/ folder"
            echo -e "    sdk location:$sdk_path\n"
            cd $current_folder
            _yocto_reset_env_variables
            return
        fi

        # just in the _bsdk/ folder
        folder_name=`basename "${PWD}"`
        if [ $folder_name = "_bsdk" ] ; then
            unset LD_LIBRARY_PATH
            source $sdk_path/$sdk_env_set
            ninja
            echo -e "\n ${PRP}yocto build -use-sdk${NOC}"
            echo -e "    with \"--conti\" option: in _bsdk/ folder"
            echo -e "    sdk location:$sdk_path\n"
            _yocto_reset_env_variables
            return
        fi
        
        # if the current path is ~/xx/_bsdk/yy/zz --------
        if [[ "$current_folder" = *"_bsdk"* ]] ; then
            sdk_build_path=${current_folder%"_bsdk"*}
            sdk_build_path=$sdk_build_path"_bsdk"
            cd $sdk_build_path
            unset LD_LIBRARY_PATH
            source $sdk_path/$sdk_env_set
            ninja
            cd $current_folder
            echo -e "\n ${PRP}yocto build -use-sdk${NOC}"
            echo -e "    with \"--conti\" option: in _bsdk/ sub-folder"
            echo -e "    sdk location:$sdk_path\n"
            _yocto_reset_env_variables
            return
        fi
        echo -e "\n ${PRP}yocto build -use-sdk${NOC}"
        echo -e "    not in _bsdk/ or its sub folder, no build, exit!!\n"
        _yocto_reset_env_variables
        return
    fi

    # ------------------------------------------------------------------
    # ------------------------------------------------------------------
    # fresh build starts below

    # source the environment variables --------------------
    unset LD_LIBRARY_PATH
    source $sdk_path/$sdk_env_set

    folder_name=`basename "${PWD}"`

    # if the curent folder contains the _bsdk folder, then
    # rm _bsdk -r 
    # meson build && cd build && ninja
    if [ -d _bsdk ] ; then
        echo "containes a _bsdk folder"
        rm _bsdk/ -rf
        meson . _bsdk -Db_sanitize=none
        cd _bsdk
        ninja
        echo -e "\n ${PRP}yocto build -use-sdk${NOC}"
        echo -e "    fresh build, contains _bsdk/ folder."
        echo -e "    sdk location:$sdk_path\n"
        cd $current_folder
    
    # if the curent folder is $fb2_sdk_build_folder/, then
    elif [ $folder_name = "_bsdk" ] ; then
        echo "inside a _bsdk folder"
        cd ../
        rm _bsdk/ -rf
        meson . _bsdk -Db_sanitize=none
        cd _bsdk
        ninja
        echo -e "\n ${PRP}yocto build -use-sdk${NOC}"
        echo -e "    fresh build, in _bsdk/ folder."
        echo -e "    sdk location:$sdk_path\n"

    # if in a subfolder of _bsdk/
    elif [[ "$current_folder" = *"_bsdk"* ]] ; then
        sdk_build_parent_path=${current_folder%"_bsdk"*}
        cd $sdk_build_parent_path
        rm _bsdk/ -rf
        meson . _bsdk -Db_sanitize=none
        cd _bsdk
        ninja
        echo -e "\n ${PRP}yocto build -use-sdk${NOC}"
        echo -e "    fresh build, in _bsdk/ sub-folder."
        echo -e "    sdk location:$sdk_path\n"
        cd $current_folder

    # if the current folder does not contain a _bsdk/ folder,then
    # check if there is a meson.build file, then build
    elif [ -f meson.build ] ; then
        meson . _bsdk -Db_sanitize=none
        cd _bsdk
        ninja
        echo -e "\n ${PRP}yocto build -use-sdk${NOC}"
        echo -e "    fresh build, have created the _bsdk/ folder"
        echo -e "    sdk location:$sdk_path\n"
        cd $current_folder
    else
        echo -e "\n ${PRP}yocto build -use-sdk${NOC}"
        echo -e "    fresh build, but no meson.build file found, no build, exit!! \n"
    fi
    _yocto_reset_env_variables
}

# =============================================================================
function _yocto_list_resources
{
    # current folder -------------
    if [ -d .git ] ; then
        echo -e "\n${CYN}-------------------------------${NOC}"
        folder_name=`basename $PWD`
        echo -e " root: ${GRN}$folder_name${NOC}"
        branch_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
        echo " remote: $(git remote -v | grep fetch | awk '{print $2}')"
        echo " branch: $branch_name"
        git log --decorate=short --pretty=oneline -n1
    fi
    # iterate all folders ----------

    current_folder=${PWD}
    
    # this does not support git submodules ...
    for item in ./*; do
        if [[ -d $item ]] && [[ -d $item/.git ]] ; then
            echo -e "\n${CYN}-------------------------------${NOC}"
            cd $item
            folder_name=`basename "$item"`
            echo -e "${GRN}$folder_name${NOC}"
            branch_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
            echo " remote: $(git remote -v | grep fetch | awk '{print $2}')"
            echo " branch: $branch_name"
            git log --decorate=short --pretty=oneline -n1
            cd $current_folder
        fi
    done
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
        if [ $2 = 'sdk-plain' ] ; then
            _yocto_install_sdk_plain $3 $4 $5 $6 $7
            return
        fi
        echo -e "\n ${PRP}yocto install${NOC}: $2 command not supported\n"
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
        if [ $2 = 'resources' ] ; then
            _yocto_list_resources
            return
        fi
        echo -e "\n ${PRP}yocto list${NOC}: $2 command not supported\n"
        return
    fi
    # ------------------------------
    if [ $1 = 'build' ] ; then
        if [ $# = 1 ] ; then
            _yocto_help
            return
        fi
        if [ $2 = '-use-sdk' ] ; then
            _yocto_build_use_sdk $3 $4 $5 $6 $7
            return
        fi
        echo -e "\n ${PRP}yocto sdk${NOC}: $2 command not supported\n"
        return
    fi
    # ------------------------------
    echo -e "\n ${PRP}yocto${NOC}: \"$1 \"command not supported\n"
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
        build
        clone
        flash
        install
        list
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    clone_list="poky meta-openembedded meta-raspberrypi meta-rpi64 "
    ACTIONS[clone]+="$clone_list "
    for i in $clone_list ; do
        ACTIONS[$i]=" "
    done
    # -----------------------------------------------------
    flash_list="imx7-cl-som imx6ullevk raspberry-pi-4 wandboard "
    ACTIONS[flash]="$flash_list "
    target_card="sda sdb sdc sdd sde sdf sdg "
    target_card+="/dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg "
    for i in $flash_list ; do
        ACTIONS[$i]="$target_card "
    done
    for i in $target_card ; do
        ACTIONS[$i]=" "
    done
    # -----------------------------------------------------
    ACTIONS[install]+="dependencies sdk-plain "
    ACTIONS[dependencies]=" "
    ACTIONS[sdk-plain]=" "

    # -----------------------------------------------------
    list_item="machines images resources "
    ACTIONS[list]+="$list_item "
    for i in $list_item ; do
        ACTIONS[$i]=" "
    done

    # smart tab-completion ----------------
    wic_gz_files="$(ls . | grep wic.gz)"
    ACTIONS[-f]="$wic_gz_files "
    for i in $wic_gz_files ; do
        ACTIONS[$i]=" "
    done
    
    # -----------------------------------------------------
    ACTIONS[build]="-use-sdk -native "
    sdk_list="$(ls -a ${HOME}/ | grep oesdk | sed 's/-oesdk//g') "
    ACTIONS[-use-sdk]="$sdk_list "
    for i in $sdk_list ; do
        ACTIONS[$i]="--conti --fresh "
    done
    ACTIONS[--conti]=" "
    ACTIONS[--fresh]=" "
    ACTIONS[-native]=" "

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
