#!/bin/bash

clean_list="--python-dir "

function _dj_clean_python_dir() {
    _show_and_run find . -type d -name "__pycache__" -exec rm -r {} +
    _show_and_run find . -type f -name "*.pyc" -delete
    _show_and_run find . -type d -name "*.egg-info" -exec rm -r {} +
}

function _dj_clean_help() {
    cat <<eom
Usage: clean [OPTION]...
eom
}

function _dj_clean() {
    printf >&2 "${HYLW}cleaning...$NOC\n"
    if [ $# -eq 0 ]; then
        _dj_help
        return
    fi
    case $1 in
    '--python-dir') shift && _dj_clean_python_dir "$@" ;;

    *) echo "Invalid option: $1" && _dj_clean_help ;;
    esac
}
