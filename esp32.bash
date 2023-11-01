#!/bin/bash

# =============================================================================
function _esp32_find_serial_port() {
    ls -l /dev/ttyUSB* 2>/dev/null | grep -q ttyUSB
    if [ $? -eq 0 ]; then
        echo "$(ls /dev/ttyUSB*) "
    fi

    ls -l /dev/ttyACM* 2>/dev/null | grep -q ttyACM
    if [ $? -eq 0 ]; then
        echo "$(ls /dev/ttyACM*) "
    fi
}

# =============================================================================
function _esp32_source_env() {
    if [ -z "$IDF_PATH" ]; then
        # todo: use some good path
        if [ -f ~/soft/esp-idf/export.sh ]; then
            _show_and_run source ~/soft/esp-idf/export.sh
        else
            echo_error "ESP-IDF is not setup yet"
            echo_info "run \"dj setup esp-idf\" to set it up"
            return
        fi
    fi
}

# =============================================================================
function _esp32_build() {
    local target="$1"
    _esp32_source_env

    _show_and_run idf.py set-target $target
    _show_and_run idf.py build
}

# =============================================================================
# note: it seems the start address is different for different esp32 chips
function _esp32_flash() {
    local dev="$1"
    _esp32_source_env

    _show_and_run idf.py -p $dev flash
}

# =============================================================================
function _esp32_get_env() {
    _esp32_source_env
}

# =============================================================================
# note: it seems the start address is different for different esp32 chips
function _esp32_monitor() {
    local dev="$1"
    _esp32_source_env
    # _show_and_run source ~/soft/esp-idf/export.sh
    _show_and_run idf.py -p $dev monitor
}

# =============================================================================
function esp32() {
    # ------------------------------
    if [ $1 = 'build' ]; then
        shift 1
        _esp32_build "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'flash' ]; then
        shift 1
        _esp32_flash "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'get-env' ]; then
        _esp32_get_env
        return
    fi
    # ------------------------------
    if [ $1 = 'monitor' ]; then
        shift 1
        _esp32_monitor "$@"
        return
    fi

    echo -e "${GRN}esp32${NOC}: argument ${RED}$1${NOC} not supported."
    return
}

# =============================================================================
function _esp32_linux() {
    COMPREPLY=()

    # All possible first values in command line
    service="build flash get-env monitor "
    local SERVICES=("
        $service
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # -----------------------------------------------------
    build_list="esp32s3 "
    ACTIONS[build]="$build_list "
    for i in $build_list; do
        ACTIONS[$i]=" "
    done
    # -----------------------------------------------------
    flash_list="$(_esp32_find_serial_port)"
    # flash_list+="$(ls /dev/ttyUSB*) "
    ACTIONS[flash]="$flash_list "
    for i in $flash_list; do
        ACTIONS[$i]=" "
    done
    # -----------------------------------------------------
    ACTIONS["get-env"]="  "
    # -----------------------------------------------------
    monitor_list="$flash_list "
    # flash_list+="$(ls /dev/ttyUSB*) "
    ACTIONS[monitor]="$monitor_list "
    for i in $monitor_list; do
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
    complete -F _esp32_linux esp32
# elif [ $system = 'Darwin' ]; then
#     echo "todo"
fi