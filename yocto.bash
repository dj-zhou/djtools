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
  The yocto toolset is to make the Yocto related commands simpler.

  supported first level commands:
     build   -- to build the plain SDK, or build applications using the SDK, etc
     clone   -- to clone some common used repos
     find    -- to find distro-conf/image-bb/machine-conf/package-recipe-bb files
     flash   -- to flash the image into SD card
     install -- to install dependencies, plain SDK, etc
     list    -- to list machines, images, or resources

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
    TMPDIR=$(_yocto_find_TMPDIR)
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
    TMPDIR=$(_yocto_find_TMPDIR)
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
    distro=$(_yocto_find_DISTRO)
    distro_v=$(_yocto_find_DISTRO_VERSION)
    echo "distro_v = $distro_v"
    if [ -z $distro_v ] ; then
        echo -e '\n Please enter Distro Version No.'
        read answer
        distro_v=$answer
    fi
    sdk_folder=$HOME/.$image_name-$machine-$distro-$distro_v-oesdk

    # remove the existing sdk folder ---------
    if [ -d $sdk_folder ] ; then
        sudo rm $sdk_folder -r
    fi
    unset LD_LIBRARY_PATH # this is important, why? not sure yet.
    ./$TMPDIR/deploy/sdk/$sdk_source -d $sdk_folder
}

# =============================================================================
# lsblk output examples
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
    echo "true"
}

# =============================================================================
# the variable MACHINE defined in conf/local.conf, can be any of the forms:
# MACHINE = "xxxx", MACHINE = 'xxxx'
# MACHINE ?= "xxxx", MACHINE ?= 'xxxx'
# MACHINE ??= "xxxx", MACHINE ??= 'xxxx'
function _yocto_find_variable_in_file() # $variable $file
{
    variable=$1
    file=$2
    value=$(grep "^$variable = " $file | awk '{print $3 }' | \
              sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ] ; then
        echo $value
        return
    fi
    value=$(grep "^$variable ?= " $file | awk '{print $3 }' | \
              sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ] ; then
        echo $value
        return
    fi
    value=$(grep "^$variable ??= " $file | awk '{print $3 }' | \
              sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ] ; then
        echo $value
        return
    fi
    echo " " # not found
}
# =============================================================================
function _yocto_find_MACHINE()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
        MACHINE=$(_yocto_find_variable_in_file "MACHINE" conf/local.conf)
        echo $MACHINE
    else
        echo " " # not found
    fi
}

# =============================================================================
function _yocto_find_TMPDIR()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
        TMPDIR=$(_yocto_find_variable_in_file "TMPDIR" conf/local.conf)
        echo $TMPDIR
    else
        echo " " # not found
    fi
}

# =============================================================================
function _yocto_find_DISTRO()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
        DISTRO=$(_yocto_find_variable_in_file "DISTRO" conf/local.conf)
        echo $DISTRO
    else
        echo " " # not found
    fi
}

# =============================================================================
function _yocto_find_DISTRO_VERSION()
{
    DISTRO=$(_yocto_find_DISTRO)
    if [ -z $DISTRO ] ; then
        echo " "
    fi

    # then find $DISTRO.conf, in which, to find something like 'DISTRO_VERSION = "2.6.4"'
    # however, this file can require some other find, then ... it can be too hard
    current_folder=${PWD}
    cd ..

    for item in ./*; do
        cd $current_folder
        cd ..
        if [[ -d $item ]] ; then
            # echo $item
            cd $item
            folder_name=$(basename $item)
            if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
                # echo "a build directory"
                continue
            fi
            file_path=$(find . -name $DISTRO.conf)
            if [ ! -z "$file_path" ] ; then
                file_full_path=$current_folder/../$folder_name/$file_path
                # find something like 'DISTRO_VERSION = "2.6.4"' in this file
                DISTRO_V=$(_yocto_find_variable_in_file "DISTRO_VERSION" $file_full_path)
                if [ ! -z $DISTRO_V ] ; then
                    echo $DISTRO_V
                    cd $current_folder
                    return
                # else
                    # if contains "requre ...", check that file
                    # ...
                fi
            fi
        fi
    done
    cd $current_folder
}

# =============================================================================
function _yocto_find_a_file() # $file_full_name
{
    file_full_name=$1
    current_folder=${PWD}
    for item in ./*; do
        cd $current_folder
        if [[ -d $item ]] ; then
            cd $item
            folder_name=$(basename $item)
            if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
                continue
            fi
            find_file=$(find -name "*$file_full_name")
            if [ ! -z "$find_file" ] ; then
                echo -e "\n ${GRN}---------------------------------------"
                echo -e " $folder_name${NOC}"
                echo "$find_file"
            fi
        fi
    done
    echo -e "\n"
    cd $current_folder
}

# =============================================================================
function _yocto_find_conf()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ;then
        echo -e "\n this is a build directory, stop search, exit!!\n"
        return
    fi

    conf_name=$1
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)

    if [ "$exact_vague" = "exact" ] ; then
        conf_full_name="$conf_name.conf"
    else
        conf_full_name="$conf_name*.conf"
    fi
    
    _yocto_find_a_file $conf_full_name
}

# =============================================================================
function _yocto_find_bb()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ;then
        echo -e "\n this is a build directory, stop search, exit!!\n"
        return
    fi

    bb_name=$1
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)
    if [ "$exact_vague" = "exact" ] ; then
        bb_full_name="$bb_name.bb"
    else
        bb_full_name="$bb_name*.bb"
    fi
    
    _yocto_find_a_file $bb_full_name
}


# =============================================================================
# this function does not support exact search
function _yocto_find_package_recipe_bb()
{
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)
    if [ "$exact_vague" = "exact" ] ; then
        echo -e "\n only support vague search \n"
    fi
    _yocto_find_bb $1 -e vague
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
    _prepare_sd_card_for_flash $DEV

    _display_section
    TMPDIR=$(_yocto_find_TMPDIR)
    if [ -z $TMPDIR ] ; then
        if [ -d "tmp" ] ; then
            TMPDIR="tmp"
        fi
    fi
    
    wic_gz_file_name=$(echo $wic_gz_file | sed "s|${PWD}||g" )
    wic_gz_file_name=$(echo $wic_gz_file_name | sed "s|/${TMPDIR}/deploy/images/${machine}/||g" )
    echo -e "       image file: ${GRN}$wic_gz_file_name${NOC}"
    file_size=$(stat -c %s $wic_gz_file)
    echo -e "       image size: ${GRN}$(_size_calculate $file_size false)${NOC}"
    
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
# $2 must be the device
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
    DEV=$(_find_block_device $dev_str)
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
    TMPDIR=$(_yocto_find_TMPDIR)
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
function _yocto_list_distros()
{
    current_folder=${PWD}

    echo -e "\n${PRP}yocto list distros ${NOC}"
    for item in ./*; do
        cd $current_folder
        if [[ -d $item ]] ; then
            # echo $item
            cd $item
            folder_name=$(basename $item)
            if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
                # echo "a build directory"
                continue
            fi
            find_1=$(ls  ./conf/distro/*.conf 2>/dev/null)
            find_2=$(ls  ./*/conf/distro/*.conf 2>/dev/null)
            find_3=$(ls  ./*/*/conf/distro/*.conf 2>/dev/null)
            find_4=$(ls  ./*/*/*/conf/distro/*.conf 2>/dev/null)
            if [ ! -z "$find_1" ] || [ ! -z "$find_2" ] || \
               [ ! -z "$find_3" ] || [ ! -z "$find_4" ] ; then
                echo -e "\n ${GRN}---------------------------------------"
                echo -e " $folder_name${NOC}"
            fi
            if [ ! -z "$find_1" ] ; then
                echo "$find_1"
            fi
            if [ ! -z "$find_2" ] ; then
                echo "$find_2"
            fi
            if [ ! -z "$find_3" ] ; then
                echo "$find_3"
            fi
            if [ ! -z "$find_4" ] ; then
                echo "$find_4"
            fi
        fi
    done
    echo -e "\n"
    cd $current_folder
}

# =============================================================================
function _yocto_list_images()
{
    current_folder=${PWD}

    echo -e "\n${PRP}yocto list images ${NOC}"
    for item in ./*; do
        cd $current_folder
        if [[ -d $item ]] ; then
            # echo $item
            cd $item
            folder_name=$(basename $item)
            if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
                # echo "a build directory"
                continue
            fi
            find_1=$(ls  ./recipes*/images*/*.bb 2>/dev/null)
            find_2=$(ls  ./*/recipes*/images*/*.bb 2>/dev/null)
            find_3=$(ls  ./*/*/recipes*/images*/*.bb 2>/dev/null)
            find_4=$(ls  ./*/*/*/recipes*/images*/*.bb 2>/dev/null)
            if [ ! -z "$find_1" ] || [ ! -z "$find_2" ] || \
               [ ! -z "$find_3" ] || [ ! -z "$find_4" ] ; then
                echo -e "\n ${GRN}---------------------------------------"
                echo -e " $folder_name${NOC}"
            fi
            if [ ! -z "$find_1" ] ; then
                echo "$find_1"
            fi
            if [ ! -z "$find_2" ] ; then
                echo "$find_2"
            fi
            if [ ! -z "$find_3" ] ; then
                echo "$find_3"
            fi
            if [ ! -z "$find_4" ] ; then
                echo "$find_4"
            fi
        fi
    done
    echo -e "\n"
    cd $current_folder
}

# =============================================================================
function _yocto_list_machines()
{
    current_folder=${PWD}

    echo -e "\n${PRP}yocto list machines ${NOC}"
    for item in ./*; do
        cd $current_folder
        if [[ -d $item ]] ; then
            # echo $item
            cd $item
            folder_name=$(basename $item)
            if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
                # echo "a build directory"
                continue
            fi
            find_1=$(ls  ./conf/machine/*.conf 2>/dev/null)
            find_2=$(ls  ./*/conf/machine/*.conf 2>/dev/null)
            find_3=$(ls  ./*/*/conf/machine/*.conf 2>/dev/null)
            find_4=$(ls  ./*/*/*/conf/machine/*.conf 2>/dev/null)
            if [ ! -z "$find_1" ] || [ ! -z "$find_2" ] || \
               [ ! -z "$find_3" ] || [ ! -z "$find_4" ] ; then
                echo -e "\n ${GRN}---------------------------------------"
                echo -e " $folder_name${NOC}"
            fi
            if [ ! -z "$find_1" ] ; then
                echo "$find_1"
            fi
            if [ ! -z "$find_2" ] ; then
                echo "$find_2"
            fi
            if [ ! -z "$find_3" ] ; then
                echo "$find_3"
            fi
            if [ ! -z "$find_4" ] ; then
                echo "$find_4"
            fi
        fi
    done
    echo -e "\n"
    cd $current_folder
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
# to use bitbake command to build the SDK (plain)
function _yocto_build_sdk_plain()
{
    # must be in a build directory ---------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ] ; then
        # echo -e "\n ${PRP}_yocto_find_image_name${NOC}:"
        # echo -e "    not in a valid bitbake build directory, exit!!\n"
        return
    fi

    # find tmp/ folder ---------------
    TMPDIR=$(_yocto_find_TMPDIR)
    if [ -z $TMPDIR ] ; then
        if [ -d "tmp" ] ; then
            TMPDIR="tmp"
        fi
    fi
    image_name=$(_yocto_find_image_name)
    # echo $image_name
    echo -e "\n is going to build the SDK with the command:"
    echo -e "   ${PRP}bitbake -c populate_sdk $image_name${NOC}\n"
    _press_enter_or_wait_s_continue 10

    bitbake -c populate_sdk $image_name
}

# =============================================================================
function _yocto_list_resources()
{
    # current folder -------------
    if [ -d .git ] ; then
        echo -e "\n${GRN} ----------------------------------------------${NOC}"
        folder_name=`basename $PWD`
        echo -e " ${GRN}$folder_name${NOC} (root)"
        branch_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
        echo " remote: $(git remote -v | grep fetch | awk '{print $2}')"
        echo " branch: $branch_name"
        git log --decorate=short --pretty=oneline -n1
    fi

    # iterate all folders ----------
    current_folder=${PWD}
    
    for item in ./*; do
        if [[ -d $item ]] && ( [[ -d $item/.git ]] || [[ -f $item/.git ]] ) ; then
            echo -e "\n${GRN} ----------------------------------------------${NOC}"
            cd $item
            folder_name=`basename "$item"`
            printf "${GRN}$folder_name${NOC}"
            if [[ -d .git ]] ; then
                printf " (git repo)\n"
            elif [[ -f .git ]] ; then
                printf " (git submodule)\n"
            fi
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
    if [ $1 = 'build' ] ; then
        if [ $# = 1 ] ; then
            _yocto_help
            return
        fi
        if [ $2 = 'sdk-plain' ] ; then
            _yocto_build_sdk_plain $3 $4 $5 $6 $7
            return
        fi

        echo -e "\n ${PRP}yocto build${NOC}: argument ${RED}$2${NOC} not supported\n"
        return
    fi
    # ------------------------------
    if [ $1 = 'clone' ] ; then
        dj clone github $2 $3 $4 $5 $6 $7 $8
        return
    fi
    # ------------------------------
    # distro-conf image-bb machine-conf package-recipe-bb
    if [ $1 = 'find' ] ; then
        if [ $# = 1 ] ; then
            _yocto_help
            return
        fi
        if [ $2 = 'distro-conf' ] ; then
            # _yocto_find_distro_conf $3 $4 $5 $6 $7 $8 $9
            _yocto_find_conf $3 $4 $5 $6 $7 $8 $9
            return
        fi
        if [ $2 = 'image-bb' ] ; then
            _yocto_find_bb $3 $4 $5 $6 $7 $8 $9
            return
        fi
        if [ $2 = 'machine-conf' ] ; then
            _yocto_find_conf $3 $4 $5 $6 $7 $8 $9
            return
        fi
        if [ $2 = 'package-recipe-bb' ] ; then
            exact_vague=$(_find_argument_after_option -e $3 $4 $5 $6 $7 $8)
            if [ "$exact_vague" = "exact" ] ; then
                echo -e "\n only support vague search \n"
            fi
            _yocto_find_bb $3 -e vague
            return
        fi
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
        echo -e "\n ${PRP}yocto install${NOC}: argument ${RED}$2${NOC} not supported\n"
        return
    fi
    # ------------------------------
    if [ $1 = 'list' ] ; then
        if [ $# = 1 ] ; then
            _yocto_help
            return
        fi
        if [ $2 = 'distros' ] ; then
            _yocto_list_distros
            return
        fi
        if [ $2 = 'images' ] ; then
            _yocto_list_images
            return
        fi
        if [ $2 = 'machines' ] ; then
            _yocto_list_machines
            return
        fi
        if [ $2 = 'resources' ] ; then
            _yocto_list_resources
            return
        fi
        echo -e "\n ${PRP}yocto list${NOC}: argument ${RED}$2${NOC} not supported\n"
        return
    fi
    # ------------------------------
    echo -e "\n ${PRP}yocto${NOC}: argument ${RED}$1${NOC} not supported\n"
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
        find
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
    find_list="distro-conf image-bb machine-conf package-recipe-bb "
    ACTIONS[find]+="$find_list "
    for i in $find_list ; do
        ACTIONS[$i]=" "
    done
    ACTIONS[-e]="exact vague "
    ACTIONS[exact]=" "
    ACTIONS[vague]=" "
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
    list_item="distros images machines resources "
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
    ACTIONS[build]="sdk-plain "
    ACTIONS[sdk-plain]=" "

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
