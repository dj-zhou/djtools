#!/bin/bash

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

# =============================================================================
# by doing so, the system can find the whole tooklit
djtools_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# add some global variables
ubuntu_v=$(lsb_release -a)

# =============================================================================
source $djtools_path/block-device.bash
source $djtools_path/build.bash
source $djtools_path/code-name.bash
source $djtools_path/coding.bash
source $djtools_path/dj-commands.bash
source $djtools_path/funcs.bash
source $djtools_path/keyremap.bash
source $djtools_path/kernel.bash
source $djtools_path/mark-down.bash
source $djtools_path/m.bash
source $djtools_path/mirror.bash
source $djtools_path/repod.bash
source $djtools_path/system.bash
source $djtools_path/terminal-format.bash
source $djtools_path/touchpad.bash
source $djtools_path/version.bash
source $djtools_path/unpack.bash
source $djtools_path/window-tile.bash
source $djtools_path/work-check.bash
source $djtools_path/yocto/yocto.bash
source $djtools_path/zephyr.bash

# =============================================================================
# alias ----------------------------------------------
alias lc="ls -lh --color=always"
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias eixt="exit"
alias amke="make"
alias maek="make"
alias mkae="make"
alias amke="make"
alias maek="make"
alias d="djfile"
alias ccc="clear"
alias geidt="gedit"
alias logout="gnome-session-quit"
alias lock="gnome-screensaver-command -l"

# folder alias ----------------------------------------------
alias cddj="cd "$djtools_path
