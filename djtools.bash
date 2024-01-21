#!/bin/bash

system=$(uname -s)
if [ $system = 'Darwin' ]; then
    rc_file="$HOME/.zshrc"
    alias nproc="sysctl -n hw.ncpu"
elif [ $system = 'Linux' ]; then
    rc_file="$HOME/.bashrc"
    # add some global variables -- only tested on Ubuntu
    ubuntu_v=$(lsb_release -a)
fi

# =============================================================================
NOC='\033[0m'
GRY='\033[0;30m'
RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[0;33m'
BLU='\033[0;34m'
PRP='\033[0;35m'
CYN='\033[0;36m'
WHT='\033[0;37m'
HGRY='\033[1;30m'
HRED='\033[1;31m'
HGRN='\033[1;32m'
HYLW='\033[1;33m'
HBLU='\033[1;34m'
HPRP='\033[1;35m'
HCYN='\033[1;36m'
HWHT='\033[1;37m'
INFO='\033[1;37m'

# =============================================================================
function _show() {
    printf >&2 "${INFO}run:"
    local arg
    for arg in "$@"; do
        arg="${arg%\'/\'\\\'\'}"
        printf >&2 " '%s'" "$arg"
    done
    printf >&2 "$NOC\n"
}

# =============================================================================
function _show_and_run() {
    _show "$@"
    "$@"
}

soft_dir="$HOME/soft"

# =============================================================================
# alias ----------------------------------------------
alias lc="_show_and_run ls -lh --color=always"
alias ll='_show_and_run ls -alF'
alias la='_show_and_run ls -A'
alias l='_show_and_run ls -CF'
alias eixt="_show_and_run exit"
alias amke="_show_and_run make"
alias maek="_show_and_run make"
alias mkae="_show_and_run make"
alias amke="_show_and_run make"
alias maek="_show_and_run make"
alias ccc="_show_and_run clear"
alias logout="_show_and_run gnome-session-quit"
alias lock="_show_and_run gnome-screensaver-command -l"
alias cddj="_show_and_run cd $djtools_path"
alias .b="_show_and_run source $rc_file"

alias ..="_show_and_run cd .."
alias ...="_show_and_run cd ../.."
alias ....="_show_and_run cd ../../.."

# =============================================================================
source $djtools_path/block-device.bash
source $djtools_path/build.bash
source $djtools_path/djfile.bash
source $djtools_path/dj-commands.bash
source $djtools_path/esp32.bash
source $djtools_path/funcs.bash
source $djtools_path/kernel.bash
source $djtools_path/mark-down.bash
source $djtools_path/m.bash
source $djtools_path/mirror.bash
source $djtools_path/pack-unpack.bash
source $djtools_path/split-merge.bash
source $djtools_path/system.bash
source $djtools_path/touchpad.bash
source $djtools_path/version.bash
source $djtools_path/work-check.bash

if [ $system = 'Linux' ]; then
    source $djtools_path/keyremap.bash
    source $djtools_path/rpi.bash
    source $djtools_path/systemd.bash
    source $djtools_path/terminal-format.bash
    source $djtools_path/window-tile.bash
    source $djtools_path/yocto/yocto.bash
    source $djtools_path/zephyr.bash
fi
