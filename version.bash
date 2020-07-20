#!/bin/bash

# todo
# ROS (1)
# openCV
# =============================================================================
function _version_help()
{
    echo -e "\n---------------------  version ------------------------"
    echo " Author      : Dingjiang Zhou"
    echo " Email       : zhoudingjiang@gmail.com "
    echo " Create Date : July 19th, 2020 "
    echo "-----------------------------------------------------"
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
    current_folder=${PWD}

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
        if [ $2 = 'arm-linux-gnueabi-gcc' ] ; then
            sudo update-alternatives --config arm-linux-gnueabi-gcc
            return
        fi
    fi
    echo -e '\r\nversion : "'$1 '"command not supported\r\n'
    _version_help

    # ------------------------------
    cd $current_folder
    unset current_folder
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
    ACTIONS[check]+="arm-linux-gnueabi-gcc cmake gcc g++ gnome ubuntu "
    ACTIONS[arm-linux-gnueabi-gcc]=" "
    ACTIONS[cmake]=" "
    ACTIONS[gcc]=" "
    ACTIONS[g++]=" "
    ACTIONS[gnome]=" "
    ACTIONS[ubuntu]=" "
    ACTIONS[swap]+="gcc g++ arm-linux-gnueabi-gcc "
    
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
