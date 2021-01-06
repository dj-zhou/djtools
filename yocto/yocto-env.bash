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
     flash   -- to flash the image into SD card
     list    -- to list machines, images, or resources
     setup   -- to install dependencies, setup plain SDK, etc
     show    -- to find distro-conf/image-bb/machine-conf/package-recipe-bb files

EOM
}

# =============================================================================
function _yocto_setup_dev_env()
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
    if [[ "${ubuntu_v}" != *'20.04'* ]] ; then
        sudo apt-get install -y libstdc++-5-dev # unavailable on Ubuntu 20.04
    fi
    sudo apt-get install -y libtool
    sudo apt-get install -y libx11-dev
    sudo apt-get install -y libxml-parser-perl
    sudo apt-get install -y make
    sudo apt-get install -y mtools
    sudo apt-get install -y parted
    sudo apt-get install -y pylint3
    sudo apt-get install -y python
    if [[ "${ubuntu_v}" != *'20.04'* ]] ; then
        sudo apt-get install -y python-git # unavailable on Ubuntu 20.04
    fi
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
    sudo apt-get install -y zstd # to support wic.zst file

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
    unset OECORE_BASELIB
    unset PKG_CONFIG_PATH
    unset CPP
    unset LD

    # not very sure about this operation
    unset PATH
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
function _yocto_setup_plain_sdk()
{
    # must be a valid buid directory ------------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ] ; then
        echo -e "\n ${PRP}yocto setup plain-sdk${NOC}:"
        echo -e "    not in a valid bitbake build directory, exit!!\n"
        return
    fi
    # find tmp/ folder ---------------
    TMPDIR=$(_yocto_find_TMPDIR)
    if [ -z $sdk_source ] ; then
        echo -e "${RED}no TMPDIR found, is the image built? exit!\n${NOC}"
        return
    fi

    # check if there is a sdk/ directory --------------
    if [ ! -d $TMPDIR/deploy/sdk ] ; then
        echo -e "\n ${PRP}yocto install sdk${NOC}:"
        echo -e "    no SDK found, exit!!"
        echo -e "    run: \"b${PRP}itbake -c populate_sdk <image>${NOC}\" to build a SDK.\n"
        return
    fi
    
    # there should be only one sh file, and that is the SDK source
    sdk_source=$(ls $TMPDIR/deploy/sdk | grep host.manifest | sed 's/host.manifest/sh/g')
    if [ -z $sdk_source ] ; then
        echo -e "${RED}SDK source is not found, exit.!\n${NOC}"
        return
    fi
    
    # get the final target SDK directory -------------------
    image_name=$(_yocto_find_image_name_in_build_directory)
    machine=$(_yocto_find_MACHINE)
    distro=$(_yocto_find_DISTRO)
    distro_v=$(_yocto_find_DISTRO_VERSION)
    if [[ -z "$distro_v" ]] ; then
        echo -e '\n Please enter a Distro Version No.:'
        read answer
        distro_v=$answer
    fi
    sdk_folder=$HOME/.$image_name-$machine-$distro-$distro_v-oesdk
    echo -e "$GRN"
    echo "    image name: "$image_name >&2
    echo "       machine: "$machine >&2
    echo "        distro: "$distro >&2
    echo "distro version: "$distro_v >&2
    echo " sdk directory: "$sdk_folder  >&2
    echo -e "$NOC"

    # remove the existing sdk folder ---------
    if [ -d "$sdk_folder" ] ; then
        echo -e "${PRP}rm \"$sdk_folder\" -r${NOC}\n"
        rm "$sdk_folder" -r
    fi

    # start to install the plain SDK ----------------------
    tmp_var=$LD_LIBRARY_PATH
    unset LD_LIBRARY_PATH # this is important, why? not sure yet.
    ./$TMPDIR/deploy/sdk/$sdk_source -d $sdk_folder
    LD_LIBRARY_PATH=$tmp_var
}
