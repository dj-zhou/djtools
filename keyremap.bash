#!/bin/bash

# =============================================================================
_keyremap_help() {
    echo -e "\n keyremap usage: \n"
    echo "    keyremap enable "
    echo "       -- swap Alt and Ctrl keys"
    echo "    keyremap disable "
    echo -e "       -- set Alt and Ctrl keys to default\n"
}

# =============================================================================
_keyremap_enable() {
    xmodmap $djtools_path/settings/keyremap-enable.txt
    echo -e "\n keyremap enabled\n"
}

# =============================================================================
_keyremap_disable() {
    xmodmap $djtools_path/settings/keyremap-disable.txt
    echo -e "\n keyremap disabled\n"
}

# =============================================================================
function keyremap {
    if [ $# -eq 0 ]; then
        _keyremap_enable
    else
        if [ ${1} = 'enable' ]; then
            _keyremap_enable
        elif [ ${1} = 'disable' ]; then
            _keyremap_disable
        elif [ ${1} = 'help' ]; then
            _keyremap_help
        else
            echo " "
            echo 'keyremap: argument not supported.'
            echo " "
        fi
    fi
}

# =============================================================================
# auto completion reference:
# https://blog.bouzekri.net/2017-01-28-custom-bash-autocomplete-script.html
_keyremap() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=(
        "enable"
        "disable"
        "help"
    )

    # declare an associative array for options
    declare -A ACTIONS
    # -------------------------------------------------------------------------
    # -------------------------------------------------------------------------
    ACTIONS[enable]=" "  # must have a space in " "
    ACTIONS[disable]=" " # must have a space in " "
    ACTIONS[help]=" "    # must have a space in " "

    # -------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

complete -F _keyremap keyremap
