#!/bin/bash
sleep 5

source ~/.bashrc


djtools_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source $djtools_path/funcs.bash

xmodmap $djtools_path/keyremap-enable.txt
_terminal_format_user_host_short_path