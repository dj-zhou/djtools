#!/bin/bash

# =============================================================================
# color definition
NO_COLOR='\033[0m' # No Color
RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
BROWN_COLOR='\033[0;33m'
BLUE_COLOR='\033[0;34m'
PURPLE_COLOR='\033[0;35m'
CYAN_COLOR='\033[0;36m'
LGRAY_COLOR='\033[0;37m'
DGRAY_COLOR='\033[1;30m'
LRED_COLOR='\033[1;31m'
LGREEN_COLOR='\033[1;32m'
YELLOW_COLOR='\033[1;33m'
LBLUE_COLOR='\033[1;34m'
LPURPLE_COLOR='\033[1;35m'
LCYAN_COLOR='\033[1;36m'
WHITE_COLOR='\033[1;37m'

# =============================================================================
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

# =============================================================================
# by doing so, the system can find the whole tooklit
djtools_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ubuntu_release_version=$(lsb_release -a)

# =============================================================================
source $djtools_path/block-device.bash
source $djtools_path/code-name.bash
source $djtools_path/coding.bash
source $djtools_path/dj-commands.bash
source $djtools_path/funcs.bash
source $djtools_path/keyremap.bash
source $djtools_path/kernel.bash
source $djtools_path/mark-down.bash
source $djtools_path/repod.bash
source $djtools_path/resized.bash
source $djtools_path/system.bash
source $djtools_path/terminal-format.bash
source $djtools_path/touchpad.bash
source $djtools_path/version.bash
source $djtools_path/work-check.bash
source $djtools_path/yocto.bash
source $djtools_path/zephyr.bash

# =============================================================================
# alias ----------------------------------------------
alias ls="ls -l --color=always"
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias eixt="exit"
alias m='make -j$(cat /proc/cpuinfo | grep processor | wc -l)'
alias amke="m"
alias maek="m"
alias mkae="m"
alias amke="m"
alias maek="m"
alias mc="make clean"
alias mm="make clean && make -j$(cat /proc/cpuinfo | grep processor | wc -l) && make -j$(cat /proc/cpuinfo | grep processor | wc -l)"
alias md="make clean && make release -j$(cat /proc/cpuinfo | grep processor | wc -l) && make download"
alias mdd="make clean && make debug  -j$(cat /proc/cpuinfo | grep processor | wc -l) && make download-debug"
alias d="djfile"
alias ccc="clear"
alias geidt="gedit"
alias logout="gnome-session-quit"
alias lock="gnome-screensaver-command -l"

# folder alias ----------------------------------------------
# dropbox related folders will be removed at a later time
alias cddj="cd "$djtools_path
