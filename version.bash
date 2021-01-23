#!/bin/bash

# todo
# ROS (1)
# openCV

# =============================================================================
function _version_help()
{
    echo -e "\n ---------------------  version ------------------------"
    echo "  Author      : Dingjiang Zhou"
    echo "  Email       : zhoudingjiang@gmail.com "
    echo "  Create Date : July 19th, 2020 "
    echo " -----------------------------------------------------"
    echo -e "\n supported commands:\n"
    echo " check - to check software version"
    echo " swap  - to swap softwaare version, for example, gcc/g++"
}

# =============================================================================
function _version_check_arm_linux_gnueabi_gcc()
{
    v=$(arm-linux-gnueabi-gcc --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_arm_linux_gnueabihf_gcc()
{
    v=$(arm-linux-gnueabihf-gcc --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_arm_linux_gnueabihf_gpp()
{
    v=$(arm-linux-gnueabihf-g++ --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_aarch64_linux_gnu_gcc()
{
    v=$(aarch64-linux-gnu-gcc --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_cmake()
{
    v=$(cmake --version | grep -v kitware | awk '{ print $3 }')
    # return the version value
    echo $v
}

# =============================================================================
function _version_check_gcc()
{
    v=$(gcc --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_gpp()
{
    v=$(g++ --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_gnome()
{
    v=$(gnome-shell --version | awk '{ print $3 }')
    # return the version value
    echo $v
}

# =============================================================================
function _version_check_ubuntu()
{
    v=$(lsb_release -a | awk '{ print $3 }')
    vv=$(echo $v | awk '{ print $3 }')
    echo $vv
}

# =============================================================================
function version()
{
    # ------------------------------
    if [ $# -eq 0 ] ; then
        _version_help
        return
    fi

    # ------------------------------
    if [ $1 = 'check' ] ; then
        # ------------------------------
        if [ $# = 1 ] ; then
            _version_help
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabi-gcc' ] ; then
            _version_check_arm_linux_gnueabi_gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabihf-gcc' ] ; then
            _version_check_arm_linux_gnueabihf_gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabihf-g++' ] ; then
            _version_check_arm_linux_gnueabihf_gpp
            return
        fi
        # ------------------------------
        if [ $2 = 'aarch64-linux-gnu-gcc' ] ; then
            _version_check_aarch64_linux_gnu_gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'cmake' ] ; then
            _version_check_cmake
            return
        fi
        # ------------------------------
        if [ $2 = 'gcc' ] ; then
            _version_check_gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'g++' ] ; then
            _version_check_gpp
            return
        fi
        # ------------------------------
        if [ $2 = 'gnome' ] ; then
            _version_check_gnome
            return
        fi
        # ------------------------------
        if [ $2 = 'ubuntu' ] ; then
            _version_check_ubuntu
            return
        fi
        # ------------------------------
        echo -e "\n version check: $2: argument not supported\n"
        return
    fi
    # ------------------------------
    if [ $1 = 'swap' ] ; then
        # ------------------------------
        if [ $# = 1 ] ; then
            _version_help
            return
        fi
        # ------------------------------
        if [ $2 = 'gcc' ] ; then
            sudo update-alternatives --config gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'g++' ] ; then
            sudo update-alternatives --config g++
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabi-gxx' ] ; then
            sudo update-alternatives --config arm-linux-gnueabi-gcc
            sudo update-alternatives --config arm-linux-gnueabi-g++
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabihf-gxx' ] ; then
            sudo update-alternatives --config arm-linux-gnueabihf-gcc
            sudo update-alternatives --config arm-linux-gnueabihf-g++
            return
        fi
        # ------------------------------
        if [ $2 = 'aarch64-linux-gnu-gcc' ] ; then
            sudo update-alternatives --config aarch64-linux-gnu-gcc
            return
        fi
        echo -e "\n version swap: $2: argument not supported\n"
        return
    fi
    echo -e '\r\n version : "'$1 '"command not supported\r\n'
    _version_help
}

# =============================================================================
function _version()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        check
        swap
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    check_list+="arm-linux-gnueabi-gcc arm-linux-gnueabihf-gcc "
    check_list+="aarch64-linux-gnu-gcc arm-linux-gnueabihf-g++ "
    check_list+="cmake gcc g++ gnome ubuntu "
    ACTIONS[check]="$check_list "
    for i in $check_list ; do
        ACTIONS[$i]=" "
    done
    swap_list+="gcc g++ arm-linux-gnueabi-gxx arm-linux-gnueabihf-gxx "
    swap_list+="aarch64-linux-gnu-gcc "
    ACTIONS[swap]="$swap_list "
    for i in $swap_list ; do
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
complete -F _version version
