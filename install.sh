#!/bin/bash

# ===============================================================================
# make sure the package is in ~/workspace folder
# or make sure it can be sourced from anywhere
djtools_path=$PWD
echo $djtools_path

echo -e '\ndjtools installation ...\n'

# ===============================================================================
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

# ===============================================================================
# get bitbucket/github, etc, user name
# -----------------------------------------------------------------
echo -e '\nDo you have a BitBucket username? [Yes/No]'
read answer
username=" "
if [[ ($answer = 'n') || ($answer = 'N') || ($answer = 'NO') || ($answer = 'No') || ($answer = 'no') ]] ; then
    echo 'BitBucket username is not set.'
elif [[ ($answer = 'y') || ($answer = 'Y') || ($answer = 'YES') || ($answer = 'Yes') || ($answer = 'yes') ]] ; then
    echo " "
    echo 'Please enter your BitBucket username'
    read username
fi

echo 'bitbucket_username='$username >> ~/.bashrc

# -----------------------------------------------------------------
echo -e '\nDo you have a GitHub username? [Yes/No]'
read answer
username=" "
if [[ ($answer = 'n') || ($answer = 'N') || ($answer = 'NO') || ($answer = 'No') || ($answer = 'no') ]] ; then
    echo 'GitHub username is not set.'
elif [[ ($answer = 'y') || ($answer = 'Y') || ($answer = 'YES') || ($answer = 'Yes') || ($answer = 'yes') ]] ; then
    echo " "
    echo 'Please enter your GitHub username:'
    read username
fi

echo 'github_username='$username >> ~/.bashrc

# -----------------------------------------------------------------
echo -e '\nDo you have a GiTee username? [Yes/No]'
read answer
username=" "
if [[ ($answer = 'n') || ($answer = 'N') || ($answer = 'NO') || ($answer = 'No') || ($answer = 'no') ]] ; then
    echo 'GiTee username is not set.'
elif [[ ($answer = 'y') || ($answer = 'Y') || ($answer = 'YES') || ($answer = 'Yes') || ($answer = 'yes') ]] ; then
    echo " "
    echo 'Please enter your GiTee username:'
    read username
fi

echo 'gitee_username='$username >> ~/.bashrc

echo -e '\nIf bitbucket/github/gitee usernames set wrong, you can still edit them in ~/.bashrc\n'


echo "source "$djtools_path"/djtools.bash" >> ~/.bashrc
echo -e "\ndjtools installation finished.\n"
echo -e "\n" >> ~/.bashrc
