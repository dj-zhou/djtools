#!/bin/bash

# =============================================================================
function _yocto_help()
{
    cat << eom

------------------------------------  yocto -----------------------------------
   Author      : Dingjiang Zhou
   Email       : zhoudingjiang@gmail.com
   Create Date : June 8th, 2020
-------------------------------------------------------------------------------
  The yocto toolset is to make the Yocto related commands simpler.

  supported first level commands:
     bake    -- to bitbake an image
     build   -- to build the plain SDK, or build applications using the SDK, etc
     flash   -- to flash the image into SD card
     list    -- to list machines, images, or resources
     setup   -- to install dependencies, setup plain SDK, etc
     show    -- to find distro-conf/image-bb/machine-conf/package-recipe-bb files

eom
}

# =============================================================================
function _yocto_setup_dev_env()
{
    packages="autoconf automake binutils bmap-tools bsdmainutils build-essential "
    packages+="ca-certificates ccache chrpath coreutils cpio curl dblatex "
    packages+="debianutils desktop-file-utils diffstat docbook-utils dosfstools "
    packages+="dos2unix file fop gawk gcc gcc-multilib git gnupg groff g++ "
    packages+="g++-multilib iputils-ping locales  lib32z1 libc6-dev "
    packages+="libegl1-mesa libgl1-mesa-dev libglib2.0-dev libglu1-mesa-dev "
    packages+="liblz4-tool libsdl1.2-dev libtool libx11-dev libxml-parser-perl make "
    packages+="mtools patch parted pv python3 python3-distutils python3-git "
    packages+="python3-jinja2 python3-pexpect python3-pip screen sed ssh socat "
    packages+="subversion texi2html texinfo unzip wget xmlto xsltproc xsltproc xterm xz-utils zstd "
    # dependencies needed for building documents
    packages+="fonts-liberation libfreetype6-dev libjpeg8-dev "
    packages+="python3-dev python3-sphinx texlive-fonts-recommended "
    packages+="texlive-latex-extra zlib1g-dev"
    for package in $packages ; do
        _show_and_run _install_if_not_installed $package
    done

    # should test in each platform
    if [[ "${ubuntu_v}" != *'22.04'* ]] ; then
        packages="lib32ncurses5 pylint3 python python-gtk2 python-pysqlite2 "
        for package in $packages ; do
            _show_and_run _install_if_not_installed $package
        done
    fi
    if [[ "${ubuntu_v}" == *'22.04'* ]] ; then
        packages=" "
        for package in $packages ; do
            _show_and_run _install_if_not_installed $package
        done
    fi

    _show_and_run pip3 install reportlab sphinxcontrib-blockdiag  

    echo "Yocto build environment dependencies are installed"
}

# =============================================================================
function _save_current_env_variables()
{
    rm -f ~/.saved-env
    export -p > ~/.saved-env
}

# =============================================================================
function _env_blacklisted()
{
  case $1 in
    PWD|OLDPWD|SHELL|STORAGE|-*) return 0 ;;
    *) return 1 ;;
  esac
}

# =============================================================================
function _yocto_reset_env_variables()
{
    source $rc_file
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
    unset NM
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

    # just don't know why PATH cannot be recovered!
    unset PATH
    export PATH=/usr/bin
    export PATH=$PATH:$HOME/.local/bin
    export PATH=$PATH:/bin
    export PATH=$PATH:/usr/local/sbin
    export PATH=$PATH:/usr/local/bin
    export PATH=$PATH:/usr/sbin
    export PATH=$PATH:/usr/bin
    export PATH=$PATH:/sbin

    # what does this do?
    eval '
    export() {
        blacklisted "${1%%=*}" || unset -v "${1%%=*}"
    }
    '"$(export -p)"

    export() {
    _env_blacklisted "${1%%=*}" || command export "$@"
    }
    source ~/.saved-env
}

# =============================================================================
# must run this function in a build directory
function _yocto_setup_plain_sdk() #image-name
{
    if [ $# -lt 1 ] ; then
        echo "yocto setup plain-sdk: need the image name"
        return
    fi
    source ../poky/oe-init-build-env . &> /dev/null
    image_name=$1
    # must be a valid buid directory ------------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ] ; then
        echo -e "\n ${PRP}yocto setup plain-sdk${NOC}:"
        echo -e "    not in a valid bitbake build directory, exit!!\n"
        return
    fi
    # find tmp/ folder ---------------
    TMPDIR=$(_yocto_find_TMPDIR)
    if [ -z $TMPDIR ] ; then
        echo -e "${RED}no TMPDIR found, is the image built? exit!\n${NOC}"
        return
    fi

    # check if there is a sdk/ directory --------------
    if [ ! -d $TMPDIR/deploy/sdk ] ; then
        echo -e "\n ${PRP}yocto setup plain-sdk${NOC}:"
        echo -e "    no SDK found, exit!!"
        echo -e "    run: \"b${PRP}itbake -c populate_sdk <image name>${NOC}\" to build a SDK.\n"
        return
    fi

    # there should be only one sh file, and that is the SDK source
    sdk_source=$(ls $TMPDIR/deploy/sdk/*$image_name* | grep host.manifest | sed 's/host.manifest/sh/g')
    # echo "sdk_source = $sdk_source"
    if [ -z "$sdk_source" ] ; then
        echo -e "${RED}SDK source is not found, exit!\n${NOC}"
        return
    fi

    # get the final target SDK directory -------------------
    machine=$(_yocto_find_MACHINE)
    distro=$(_yocto_find_DISTRO)
    distro_v=$(_yocto_find_DISTRO_VERSION)
    if [[ -z "$distro_v" ]] ; then
        echo -e '\n Please enter a Distro Version No.:'
        read answer
        distro_v=$answer
    fi
    sdk_folder=$HOME/.$image_name-oesdk/$machine/$distro-$distro_v
    echo -e "    image name: $INFO"$image_name$NOC >&2
    echo -e "       machine: $INFO"$machine$NOC >&2
    echo -e "        distro: $INFO"$distro$NOC >&2
    echo -e "distro version: $INFO"$distro_v$NOC >&2
    echo -e " sdk directory: $INFO"$sdk_folder$NOC  >&2

    # return
    # remove the existing sdk folder ---------
    if [ -d "$sdk_folder" ] ; then
      _show_and_run  sudo rm "$HOME/.$image_name-oesdk" -r
    fi

    # start to install the plain SDK ----------------------
    tmp_var=$LD_LIBRARY_PATH
    unset LD_LIBRARY_PATH # this is important, why? not sure yet.
    printf "y\n"| $sdk_source -d $sdk_folder
    LD_LIBRARY_PATH=$tmp_var
}
