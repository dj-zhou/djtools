#!/bin/bash

# =============================================================================
djtools_path=$PWD
echo -e "${GRN}djtools${NOC} current path is: $djtools_path"

echo -e "djtools installation ..."

system=$(uname -s)
if [ $system = 'Darwin' ]; then
    rc_file="$HOME/.zshrc"
elif [ $system = 'Linux' ]; then
    rc_file="$HOME/.bashrc"
fi
# =============================================================================
# source the package in ~/.bashrc or ~/.zshrc
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ $line == *"source "$djtools_path$"/djtools.bash"* ]]; then
        echo -e "djtools has already been installed, exit."
        echo -e "you can still revise $rc_file for manual setup."
        exit
    fi
done <$rc_file

echo -e '\n' >>$rc_file
echo '# ===========================================================' >>$rc_file
echo '# djtools setup' >>$rc_file
if [ $system = 'Darwin' ]; then
    echo 'autoload -Uz compinit && compinit' >>$rc_file
fi

# =============================================================================
# get bitbucket/github, etc, user name
repo_source="github bitbucket"
for rs in $repo_source; do
    # -----------------------------------------------------------------
    echo -e "Please enter your $rs username [empty answer means no account]: "
    read username
    if [ ! -z $username ]; then
        echo "${rs}_username="$username >>$rc_file
        echo "~/.${rs}-repos-$username is created."
        touch ~/.${rs}-repos-$username
    else
        echo "no $rs username set"
    fi
done

echo -e "\nIf "
for rs in $repo_source; do
    echo "\"$rs\" "
done
echo -e "usernames set wrong, you can still edit them in $rc_file"
echo "djtools_path=${PWD}" >>$rc_file
echo "source $djtools_path/djtools.bash" >>$rc_file
echo -e "djtools installation finished."
echo -e "\n" >>$rc_file

mkdir -p ~/.ssh


# # ===========================================================

# # autoload -Uz compinit && compinit

# # djtools setup
# github_username=dj-zhou
# bitbucket_username=sky-Hawk
# djtools_path=/Users/dingjiangzhou/workspace/djtools
# source /Users/dingjiangzhou/workspace/djtools/djtools.bash




# # =============================================================================
# function _show() {
#     printf >&2 "run:"
#     local arg
#     for arg in "$@"; do
#         arg="${arg%\'/\'\\\'\'}"
#         printf >&2 " $GRN'%s'$NOC" "$arg"
#     done
#     printf >&2 "\n"
# }

# # =============================================================================
# function _show_and_run() {
#     _show "$@"
#     "$@"
# }


# NOC='\033[0m'
# GRY='\033[0;30m'
# RED='\033[0;31m'
# GRN='\033[0;32m'
# YLW='\033[0;33m'
# BLU='\033[0;34m'
# PRP='\033[0;35m'
# CYN='\033[0;36m'
# WHT='\033[0;37m'
# HGRY='\033[1;30m'
# HRED='\033[1;31m'
# HGRN='\033[1;32m'
# HYLW='\033[1;33m'
# HBLU='\033[1;34m'
# HPRP='\033[1;35m'
# HCYN='\033[1;36m'
# HWHT='\033[1;37m'
