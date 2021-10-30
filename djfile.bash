#!/bin/bash

# =============================================================================
function djfile() {
    cur_dir=${PWD}

    # ------------------------------
    if [ $# -eq 0 ]; then
        echo "this is to make djfile program easier to use"
        return
    fi

    # ------------------------------
    if [ $1 = '--cmake' ]; then
        dj-file --cmake
        return
    fi

    # ------------------------------
    if [ $1 = '--help' ]; then
        dj-file --help
        return
    fi
    # ------------------------------
    if [ $1 = '--makefile' ]; then
        dj-file --makefile
        return
    fi
    # ------------------------------
    if [ $1 = '--meson' ]; then
        dj-file --meson
        return
    fi
    # ------------------------------
    if [ $1 = '--version' ]; then
        dj-file --version
        return
    fi

    echo -e 'djfile: "'$1 '"command not supported'
    djfile_help

    # ------------------------------
    cd $cur_dir
    unset cur_dir
}

# =============================================================================
function _djfile() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        --cmake
        --help
        --makefile
        --meson
        --version
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    ACTIONS["--cmake"]=" "
    ACTIONS["--help"]=" "
    ACTIONS["--makefile"]=" "
    ACTIONS["--meson"]=" "
    ACTIONS["--version"]=" "

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
complete -F _djfile djfile
