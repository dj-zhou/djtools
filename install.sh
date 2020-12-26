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
echo -e "\n Do you have a $rs username? [Yes/No]"
    read anw
    username=""
    if [[ ("$anw" = 'n') || ("$anw" = 'N') || ("$anw" = 'NO') || \
        ("$anw" = 'No') || ("$anw" = 'no') ]] ; then
        echo "$rs username is not set."
    elif [[ ("$anw" = 'y') || ("$anw" = 'Y') || ("$anw" = 'YES') || \
        ("$anw" = 'Yes') || ("$anw" = 'yes') ]] ; then
        echo " "
        echo " Please enter your $rs username:"
        read username
        echo "${rs}_username="$username >> ~/.bashrc
    fi
    touch ~/.${rs}-repos-$username
    echo -e "\n you can put repos in the ~/.GitHub-repos-$username to enable command \"dj clone\"\n"
done

echo -e "\n If GitHub/GiTee/BitBucket usernames set wrong, you can still edit them in ~/.bashrc\n"
echo "source $djtools_path/djtools.bash" >> ~/.bashrc
echo -e "\n djtools installation finished.\n"
echo -e "\n" >> ~/.bashrc
