#!/bin/bash

# =============================================================================
function djfile() {
    _pushd_quiet ${PWD}

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
    if [ $1 = '--stm32' ]; then
        shift 1
        dj-file --stm32 $@
        return
    fi
    # ------------------------------
    if [ $1 = '--version' ]; then
        dj-file --version
        return
    fi

    echo -e 'djfile: "'$1 '"command not supported'
    djfile_help

    _popd_quiet
}

# =============================================================================
function _djfile() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        --cmake
        --help
        --makefile
        --stm32
        --meson
        --version
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    ACTIONS["--cmake"]=" "
    ACTIONS["--help"]=" "
    ACTIONS["--makefile"]=" "
    ACTIONS["--stm32"]="-t "
    stm32_list="f030r8 f103rb f107xc f303re f407vg f407zg f427vi f746zg f767zi h750vb "
    ACTIONS["-t"]="$stm32_list "
    for i in $stm32_list; do
        ACTIONS[$i]=" "
    done
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
