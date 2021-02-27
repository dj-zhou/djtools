#!/bin/bash

# =============================================================================
djtools_path=$PWD
echo -e "\n ${GRN}djtools${NOC} current path is: $djtools_path\n"

echo -e "\n djtools installation ...\n"

# =============================================================================
# source the package in ~/.bashrc
while IFS='' read -r line || [[ -n "$line" ]] ; do
    if [[ $line == *"source "$djtools_path$"/djtools.bash"* ]] ; then
        echo -e "djtools has already been installed, exit."
        echo -e "you can still revise ~/.bashrc for manual setup.\n"
        exit
    fi
done < ~/.bashrc

echo -e '\n' >> ~/.bashrc
echo '# ===========================================================' >> ~/.bashrc
echo '# djtools setup' >> ~/.bashrc

# =============================================================================
# get bitbucket/github, etc, user name
repo_source="GitHub GiTee BitBucket"
for rs in $repo_source ; do
# -----------------------------------------------------------------
echo -e "\n Please enter your $rs username [empty answer means no account]: "
    read username
    echo "$username"
    if [ ! -z $username ] ; then
        echo "${rs}_username="$username >> ~/.bashrc
        echo "~/.${rs}-repos-$username is created."
        touch ~/.${rs}-repos-$username
    else
        echo "no $rs username set"
    fi
done

echo -e "\n If "
for rs in $repo_source ; do
    echo "$rs/"
done
echo -e "usernames set wrong, you can still edit them in ~/.bashrc\n"
echo "source $djtools_path/djtools.bash" >> ~/.bashrc
echo -e "\n djtools installation finished.\n"
echo -e "\n" >> ~/.bashrc
