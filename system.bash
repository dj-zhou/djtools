#!/bin/bash 

# ===================================================================
function _system_help()
{
    echo ' '
    echo ' system help'
    echo ' '
    echo ' exmaple command 1:'
    echo '   TODO'
}

function _system_enable_help()
{
    echo " _system_enable_help"
    echo " todo"
}

function _system_disable_help()
{
    echo " _system_disable_help"
    echo " todo"
}

# ===========================================================================================
function _system_disable_program_problem_detected()
{
    sudo rm -f /var/crash/*
    sudo sed -i "s/enabled=1/enabled=0/g" /etc/default/apport
}

# ===========================================================================================
function system()
{
    # ------------------------------
    if [ $# -eq 0 ] ; then
        _system_help
        return
    fi
    # ------------------------------
    if [ $1 = 'enable' ] ; then
        _system_enable_help
        return
    fi
    # ------------------------------
    if [ $1 = 'disable' ] ; then
        # --------------------------
        if [ $2 = 'program-problem-detected' ] ; then
            _system_disable_program_problem_detected $3 $4 $5 $6 $7
            return
        fi
        # --------------------------
        _system_disable_help
        return
    fi
    _dj_help
    # ------------------------------
}

# ===================================================================
function _system()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        enable
        disable
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # no space in front or after "="
    ACTIONS[enable]+=" "
    ACTIONS[disable]+="program-problem-detected "
    ACTIONS[program-problem-detected]=" "

    
    # ---------------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# ===================================================================
complete -F _system system
