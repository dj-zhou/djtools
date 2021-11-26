#!/bin/bash
# variables used in dj-commands.bash ----------
_python3_cmds="install "
_install_list="matplotlib numpy pandas "

function _dj_python3_install() {
    if [ "$1" = "matplotlib" ]; then
        sudo apt-get install python3-matplotlib
        return
    fi
    if [ "$1" = "numpy" ]; then
        pip3 install numpy
        return
    fi
    if [ "$1" = "pandas" ]; then
        pip3 install pandas
        return
    fi
}

function _dj_python3() {
    if [ "$1" = "install" ]; then
        shift 1
        _dj_python3_install "$@"
        return
    fi
}
