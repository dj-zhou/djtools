#!/bin/bash 

# ===================================================================
function _system_help()
{
    echo ' '
    echo ' system help'
    echo ' '
    echo ' exmaple command 1:'
    echo '   -- enable '
    echo '   -- disable '
    echo '   -- check '
    echo "   -- MORE IS COMMING "
}

# ===========================================================================================
function _system_enable_help()
{
    echo " _system_enable_help"
    echo "   -- xxxx "
    echo "   -- MORE IS COMMING "
}

# ===========================================================================================
function _system_disable_help()
{
    echo " system disable <argument>"
    echo "   -- program-problem-detected : to disable an Ubuntu error report"
    echo "   -- MORE IS COMMING "
}

# ===========================================================================================
function _system_check_help()
{
    echo " system check <argument>"
    echo "   -- temperature : to check CPU temperature"
    echo "   -- MORE IS COMMING "
    echo " "
}

# ===========================================================================================
function _system_disable_program_problem_detected()
{
    sudo rm -f /var/crash/*
    sudo sed -i "s/enabled=1/enabled=0/g" /etc/default/apport
    echo "/etc/default/apport is revised to "
    echo ' '
    cat /etc/default/apport
    echo ' '
}

# ===========================================================================================
# this function has one error not solved:
#    bash: [: too many arguments
function _system_check_temperature()
{
    result=$(sensors)
    # echo $result
    if [ $result=*'not found'* ] ; then
        sudo apt-get install lm-sensors
    fi
    sensors
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
    # ------------------------------
    if [ $1 = 'check' ] ; then
        # --------------------------
        if [ $2 = 'temperature' ] ; then
            _system_check_temperature
            return
        fi
        _system_check_help
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
        check
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # no space in front or after "="
    ACTIONS[enable]+=" "
    ACTIONS[disable]+="program-problem-detected "
    ACTIONS[program-problem-detected]=" "
    ACTIONS[check]+="temperature "
    ACTIONS[temperature]+=" "

    
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
