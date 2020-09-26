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
# -----------------------------------------------------------------
echo -e '\n Do you have a GitHub username? [Yes/No]'
read anw
username=""
if [[ ("$anw" = 'n') || ("$anw" = 'N') || ("$anw" = 'NO') || \
    ("$anw" = 'No') || ("$anw" = 'no') ]] ; then
    echo 'GitHub username is not set.'
elif [[ ("$anw" = 'y') || ("$anw" = 'Y') || ("$anw" = 'YES') || \
    ("$anw" = 'Yes') || ("$anw" = 'yes') ]] ; then
    echo " "
    echo 'Please enter your GitHub username:'
    read username
    echo 'github_username='$username >> ~/.bashrc
fi

# -----------------------------------------------------------------
echo -e '\n Do you have a GiTee username? [Yes/No]'
read anw
unset username
if [[ ("$anw" = 'n') || ("$anw" = 'N') || ("$anw" = 'NO') || \
    ("$anw" = 'No') || ("$anw" = 'no') ]] ; then
    echo 'GiTee username is not set.'
elif [[ ("$anw" = 'y') || ("$anw" = 'Y') || ("$anw" = 'YES') || \
    ("$anw" = 'Yes') || ("$anw" = 'yes') ]] ; then
    echo " "
    echo 'Please enter your GiTee username:'
    read username
    echo 'gitee_username='$username >> ~/.bashrc
fi

# -----------------------------------------------------------------
echo -e '\n Do you have a BitBucket username? [Yes/No]'
read anw
unset username
if [[ ("$anw" = 'n') || ("$anw" = 'N') || ("$anw" = 'NO') || \
    ("$anw" = 'No') || ("$anw" = 'no') ]] ; then
    echo 'BitBucket username is not set.'
elif [[ ("$anw" = 'y') || ("$anw" = 'Y') || ("$anw" = 'YES') || \
    ("$anw" = 'Yes') || ("$anw" = 'yes') ]] ; then
    echo " "
    echo 'Please enter your BitBucket username'
    read username
    echo 'bitbucket_username='$username >> ~/.bashrc
fi


echo -e '\n If bitbucket/github/gitee usernames set wrong, you can still edit them in ~/.bashrc\n'
echo "source $djtools_path/djtools.bash" >> ~/.bashrc
echo -e "\n djtools installation finished.\n"
echo -e "\n" >> ~/.bashrc
