#!/bin/bash

# =============================================================================
function _dj_clone_help()
{
    _dj_help
    echo "--------------------- dj clone ----------------------"
    echo " Second level commands:"
    echo "   bitbuket - to clone repo from bitbucket"
    echo "   github   - to clone repo from github"
    echo "   gitee    - to clone repo from gitee"
    echo "   MORE IS COMMING"
    echo -e "-----------------------------------------------------\n"
}

# =============================================================================
function _dj_clone_bitbucket()
{
    echo -e "\n dj clone ${GRN}$1${NOC} with ${GRN}bitbucket${NOC} username ${GRN}$bitbucket_username${NOC}\n"
    git clone https://$bitbucket_username@bitbucket.org/$bitbucket_username/$1.git
}

# =============================================================================
function _dj_clone_github()
{
    echo -e "\n dj clone ${GRN}$1${NOC} with ${GRN}github${NOC} username ${GRN}$github_username${NOC}\n"

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

# =============================================================================
function _dj_clone_gitee()
{
    echo -e "\n dj clone ${GRN}$1${NOC} with ${GRN}gitee${NOC} username ${GRN}$github_username${NOC}\n"
    git clone https://gitee.com/$gitee_username/$1.git
}
