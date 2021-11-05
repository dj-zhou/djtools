#!/bin/bash
# variables used in dj-commands.bash ----------
python3_cmds="pip-install "
pip_install_list="numpy pandas "

function _dj_python3_pip_install() {
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
    if [ "$1" = "pip-install" ]; then
        shift 1
        _dj_python3_pip_install "$@"
        return
    fi
}
