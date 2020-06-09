#!/bin/bash

# =============================================================================================
# make sure the package is in ~/workspace folder
# or make sure it can be sourced from anywhere
djtools_path=$PWD
echo $djtools_path

echo " "
echo 'djtools installation...'
echo " "

# =============================================================================================
# source the package in ~/.bashrc

while IFS='' read -r line || [[ -n "$line" ]] ; do
    if [[ $line == *"source "$djtools_path$"/djtools.bash"* ]] ; then
        echo " "
        echo "djtools has already been installed. exit."
        echo " "
        exit
    fi
done < ~/.bashrc

echo '   ' >> ~/.bashrc
echo '# ================================================================' >> ~/.bashrc
echo '# djtools setup' >> ~/.bashrc

# =============================================================================================
echo 'Enter a path for wallpaper'
read answer
echo 'wallpaper_folder='$answer >> ~/.bashrc

# =============================================================================================
# get bitbucket/github, etc, user name
# -----------------------------------------------------------------
echo " "
echo 'Do you have a BitBucket username? [Yes/No]'
echo " "
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
echo " "
echo 'Do you have a GitHub username? [Yes/No]'
echo " "
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
echo " "
echo 'Do you have a GiTee username? [Yes/No]'
echo " "
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

echo " "
echo 'If bitbucket/github/gitee usernames set wrong, you can still edit them in ~/.bashrc'
echo " "


echo "source "$djtools_path"/djtools.bash" >> ~/.bashrc
echo " "
echo "djtools installation finished."
echo " "
echo " " >> ~/.bashrc
