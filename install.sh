#!/bin/bash

# =============================================================================
djtools_path=$PWD
echo -e "${GRN}djtools${NOC} current path is: $djtools_path"

echo -e "djtools installation ..."

# =============================================================================
# source the package in ~/.bashrc
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ $line == *"source "$djtools_path$"/djtools.bash"* ]]; then
        echo -e "djtools has already been installed, exit."
        echo -e "you can still revise ~/.bashrc for manual setup."
        exit
    fi
done <~/.bashrc

echo -e '\n' >>~/.bashrc
echo '# ===========================================================' >>~/.bashrc
echo '# djtools setup' >>~/.bashrc

# =============================================================================
# get bitbucket/github, etc, user name
repo_source="github bitbucket"
for rs in $repo_source; do
    # -----------------------------------------------------------------
    echo -e "Please enter your $rs username [empty answer means no account]: "
    read username
    if [ ! -z $username ]; then
        echo "${rs}_username="$username >>~/.bashrc
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
echo -e "usernames set wrong, you can still edit them in ~/.bashrc"
echo "source $djtools_path/djtools.bash" >>~/.bashrc
echo -e "djtools installation finished."
echo -e "\n" >>~/.bashrc

mkdir -p ~/.ssh
