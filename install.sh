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

echo -e "\n If "
for rs in $repo_source; do
    echo "$rs/"
done
echo -e "usernames set wrong, you can still edit them in $rc_file"
echo "djtools_path=${PWD}" >>$rc_file
echo "source $djtools_path/djtools.bash" >>$rc_file
echo -e "djtools installation finished."
echo -e "\n" >>$rc_file

mkdir -p ~/.ssh
