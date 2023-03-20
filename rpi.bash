#!/bin/bash

# =============================================================================
function _rpi_help() {
    echo "_rpi_help: todo"
}

# =============================================================================
function _rpi_setup_waveshare_7_inch_screen() {
    echo "_rpi_setup_waveshare_7_inch_screen: todo"
}

# =============================================================================
function rpi() {
    # ------------------------------
    if [ $# -eq 0 ]; then
        _rpi_help
        return
    fi

    # ------------------------------
    if [ $1 = 'setup' ]; then
        if [ $2 = 'wave-share-7-inch-screen' ]; then
            shift 1
            _rpi_setup_waveshare_7_inch_screen "$@"
            return
        fi
        echo "rpi setup: $2 is not supported"
        return
    fi
    # ------------------------------

    echo 'rpi : "'$1 '"command not supported'
    _rpi_help
}

# =============================================================================
function _rpi() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        setup
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    setup_list="wave-share-7-inch-screen "
    ACTIONS["setup"]+="$setup_list "
    for i in $setup_list; do
        ACTIONS[$i]=" "
    done

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
complete -F _rpi rpi
