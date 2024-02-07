#!/bin/bash

# =============================================================================
function _rpi_help() {
    echo "_rpi_help: todo"
}

# =============================================================================
# https://www.waveshare.com/wiki/7inch_DSI_LCD_(C)
function _rpi_setup_waveshare_dsi_lcd() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf Waveshare-DSI-LCD
    _show_and_run git clone https://github.com/waveshare/Waveshare-DSI-LCD
    _show_and_run cd Waveshare-DSI-LCD

    uname_r="$(uname -r)"
    if [[ "${uname_r}" = "5.15.61"* ]]; then
        _show_and_run cd "5.15.61"
    elif [[ "${uname_r}" = "5.15.76"* ]]; then
        _show_and_run cd "5.15.76"
    elif [[ "${uname_r}" = "5.15.84"* ]]; then
        _show_and_run cd "5.15.84"
    else
        echo_warn "Kernel ${uname_r} is not supported, exit."
        _popd_quiet
        return
    fi
    uname_m=$(uname -m)
    if [[ "${uname_m}" = "armv7l"* ]]; then
        _show_and_run cd 32
    else
        echo_warn "Uknown architecture, exit."
        _popd_quiet
        return
    fi

    _show_and_run sudo bash ./WS_xinchDSI_MAIN.sh 70C I2C1

    echo "Waveshare DSI LCD driver installed, you need to reboot"
    _popd_quiet
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
        if [ $# -eq 1 ]; then
            echo "rpi setup: need argument, exit."
            return
        fi
        if [ $2 = 'waveshare-dsi-lcd' ]; then
            shift 1
            _rpi_setup_waveshare_dsi_lcd "$@"
            return
        fi
        echo "rpi setup: $2 is not supported"
        return
    fi
    # ------------------------------
    if [ $1 = 'shrink' ]; then
        if [ $# -eq 1 ]; then
            echo "need argument, example: $ rpi shrink image.img"
            return
        fi
        _mirror_shrink $2
        return
    fi
    # ------------------------------
    if [ $1 = 'backup' ]; then
        shift
        _mirror_backup "$@"
        return
    fi
    echo 'rpi : "'$1 '"command not supported'
    _rpi_help
}

# =============================================================================
function _rpi_linux() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        backup
        setup
        shrink
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    backup_list="/dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg "
    ACTIONS[backup]="$backup_list "
    for i in $backup_list; do
        backup_file_lit="$(ls | grep img) "
        ACTIONS[$i]="$backup_file_lit"
        for j in $backup_file_lit; do
            ACTIONS[$j]=" "
        done
    done
    # ------------------------------------------------------------------------
    setup_list="waveshare-dsi-lcd "
    ACTIONS["setup"]+="$setup_list "
    for i in $setup_list; do
        ACTIONS[$i]=" "
    done

    # ------------------------------------------------------------------------
    shrink_list="$(ls | grep img) "
    ACTIONS[shrink]="$shrink_list "
    for i in $shrink_list; do
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
if [ $system = 'Linux' ]; then
    complete -F _rpi_linux rpi
# elif [ $system = 'Darwin' ]; then
#     echo "todo"
fi
