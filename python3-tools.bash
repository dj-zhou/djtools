#!/bin/bash

function _dj_python3_pip_install() {
    if [ "$1" = "numpy" ]; then
        pip3 install numpy
        return
    fi
}

function _dj_python3() {
    if [ "$1" = "pip-install" ]; then
        shift 1
        _dj_python3_pip_install "$@"
        return
    fi
}
