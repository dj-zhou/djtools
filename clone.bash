#!/bin/bash

# ===========================================================================================
function _dj_clone_help()
{
    _dj_help
    echo "--------------------- dj clone ----------------------"
    echo " Second level commands:"
    echo "   bitbuket - to clone repo from bitbucket"
    echo "   github   - to clone repo from github"
    echo "   gitee    - to clone repo from gitee"
    echo "   MORE IS COMMING"
    echo "-----------------------------------------------------"
    echo " "
}

# ===========================================================================================
function _dj_clone_bitbucket()
{
    echo " "
    echo "dj clone "$1" with bitbucket username "$bitbucket_username
    echo " "
    git clone https://$bitbucket_username@bitbucket.org/$bitbucket_username/$1.git
}

# ===========================================================================================
function _dj_clone_github()
{
    echo " "
    echo "dj clone "$1" with github username "$github_username
    echo " "
    # echo "argment 2 = "$2
    # echo "argment 3 = "$3
    # echo "argment 4 = "$4
    # echo "argment 5 = "$5
    # echo "argment 6 = "$6
    # echo "argment 7 = "$7
    # echo "argment 8 = "$8

    # get the branch to clone ---------------------
    clone_a_branch=0
    if [ $# -gt 2 ] && [ $2 = '-b' ]; then
        branch_name=$3
        clone_a_branch=1
    elif [ $# -gt 4 ] && [ $4 = '-b' ]; then
        branch_name=$5
        clone_a_branch=1
    fi
    # echo "clone_a_branch = " $clone_a_branch
    # echo "branch_name = " $branch_name
    
    # to clone ----------------------------------
    if [ $clone_a_branch = 0 ] ; then
        git clone https://$github_username@github.com/$github_username/$1.git
    fi
    if [ $clone_a_branch = 1 ] ; then
        git clone https://$github_username@github.com/$github_username/$1.git -b $branch_name
    fi
}

# ===========================================================================================
function _dj_clone_gitee()
{
    echo " "
    echo "dj clone "$1" with gitee username "$gitee_username
    echo " "
    git clone https://gitee.com/$gitee_username/$1.git
}
