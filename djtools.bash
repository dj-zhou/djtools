#!/bin/bash 

# ===========================================================================================
# yugong or hanxin check
if [[ "$(hostname)" = "hx"* ]] ; then
    echo "This is a Hanxin computer"
    ros_ws="hanxin_ws"
elif [[ "$(hostname)" = "slam"* ]] ; then
    echo "This is a Slam computer"
    ros_ws=""
    is_slam="true"
elif [[ "$(hostname)" = "yg"* ]] ; then
    echo "This is a Yugong computer"
    ros_ws="yugong_ws"
elif [[ "$(hostname)" = "rog"* ]] || \
     [[ "$(hostname)" = "bintohw01"* ]]; then
    echo "This is a Snake computer"
    ros_ws="snake_ws"
else
    echo "This is a normal computer"
    ros_ws="catkin_ws"
fi
echo "ros_ws = "$ros_ws

# ===========================================================================================
# by doing so, the system can find the whole tooklit
djtools_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ubuntu_release_version=$(lsb_release -a)

# ===========================================================================================
source $djtools_path/coding.bash
source $djtools_path/dj-commands.bash
source $djtools_path/funcs.bash
source $djtools_path/keyremap.bash
source $djtools_path/repo.bash
source $djtools_path/resized.bash
source $djtools_path/system.bash
source $djtools_path/terminal-format.bash
source $djtools_path/touchpad.bash
source $djtools_path/work-check.bash

# ===========================================================================================
# initial setup -- can be overwrite by other setting, for example, dj-zhou-config.bash
_terminal_format_user_host_short_path

# ===========================================================================================
_wallpaper_setup

# ===========================================================================================
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
alias cdcv="cd ~/workspace/work/openCV/"
alias cdml="cd ~/ml/"
alias cdqt="cd ~/qt/"
alias cdsoft="cd ~/soft/"

# ===========================================================================================
export HOSTNAME

# ===========================================================================================
# ROS ---------------------------------------------------------
# set some ROS IP address
export ROS_MASTER_URI=http://localhost:11311
export ROS_IP=localhost

# ===========================================================================================
# Qt
export PATH=~/Qt5.14.2/5.14.2/gcc_64/bin:$PATH
export  LD_LIBRARY_PATH=~/Qt5.14.2/5.14.2/gcc_64/lib:$LD_LIBRARY_PATH

# ===========================================================================================
# pangolin
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
