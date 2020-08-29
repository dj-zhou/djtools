#!/bin/bash

# =============================================================================
function _dj_clone_help()
{
    _dj_help
    cat << EOM

 ---------------------- dj clone/clone-ssh ------------------------
 Second level commands:
    bitbuket - to clone repo from bitbucket
    github   - to clone repo from github
    gitee    - to clone repo from gitee
    MORE IS COMMING
 ------------------------------------------------------------------
EOM

}

# =============================================================================
function _dj_clone_bitbucket()
{
    echo -e "\n dj clone ${GRN}$1${NOC} with ${GRN}bitbucket${NOC} username ${GRN}$bitbucket_username${NOC}\n"
    
    branch_name=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    
    if [[ ! -z $branch_name ]] ; then
        git clone https://$bitbucket_username@bitbucket.org/$bitbucket_username/$1.git -b $branch_name
    else 
        git clone https://$bitbucket_username@bitbucket.org/$bitbucket_username/$1.git
    fi
}

# =============================================================================
function _dj_clone_ssh_bitbucket()
{
    echo -e "\n dj clone ${GRN}$1${NOC} with ${GRN}bitbucket${NOC} username ${GRN}$bitbucket_username${NOC}\n"
    
    branch_name=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    
    if [[ ! -z $branch_name ]] ; then
        git clone git@bitbucket.org:$bitbucket_username/$1.git -b $branch_name
    else 
        git clone git@bitbucket.org:$bitbucket_username/$1.git
    fi
}

# =============================================================================
function _dj_clone_github()
{
    echo -e "\n dj clone ${GRN}$1${NOC} with ${GRN}github${NOC} username ${GRN}$github_username${NOC}\n"

    branch_name=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    
    if [[ ! -z $branch_name ]] ; then
        git clone https://$github_username@github.com/$github_username/$1.git -b $branch_name
    else 
        git clone https://$github_username@github.com/$github_username/$1.git
    fi
}

# =============================================================================
function _dj_clone_ssh_github()
{
    echo -e "\n dj clone ${GRN}$1${NOC} with ${GRN}github${NOC} username ${GRN}$github_username${NOC} use SSH\n"

    branch_name=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    
    if [[ ! -z $branch_name ]] ; then
        git clone git@github.com:$github_username/$1.git -b $branch_name
    else 
        git clone git@github.com:$github_username/$1.git
    fi
}

# =============================================================================
function _dj_clone_gitee()
{
    echo -e "\n dj clone ${GRN}$1${NOC} with ${GRN}gitee${NOC} username ${GRN}$github_username${NOC}\n"
    
    branch_name=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    
    if [[ ! -z $branch_name ]] ; then
        git clone https://gitee.com/$gitee_username/$1.git -b $branch_name
    else 
        git clone https://gitee.com/$gitee_username/$1.git
    fi
}

# =============================================================================
function _dj_clone_ssh_gitee()
{
    echo -e "\n todo\n"
}
