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
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ---------------------------------------------------------------------------------
    ACTIONS[clone]+="poky meta-openembedded meta-raspberrypi meta-rpi64 "
    ACTIONS[poky]=" "
    ACTIONS[meta-openembedded]=" "
    ACTIONS[meta-raspberrypi]=" "
    ACTIONS[meta-rpi64]=" "
    
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
