#!/bin/bash

# =============================================================================
function _dj_clone_repo_list() # platform
{
    platform="$1"
    if [ $platform = 'GitHub' ] ; then
        file=$HOME/.$platform-repos-$GitHub_username
    elif [ $platform = 'GiTee' ] ; then
        file=$HOME/.$platform-repos-$GiTee_username
    elif [ $platform = 'BitBucket' ] ; then
        file=$HOME/.$platform-repos-$BitBucket_username
    fi
    if [ ! -f $file ] ; then
        echo "no_repo_list_file_in_${HOME}/_directory"
        return
    fi
    list=$(cat $file)
    echo "$list"
}

# =============================================================================
function _dj_clone_help()
{
    _dj_help
    cat << EOM

 ---------------------- dj clone/clone-ssh ------------------------
 Second level commands:
    bitbuket - to clone repo from BitBucket
    github   - to clone repo from GitHub
    gitee    - to clone repo from GiTee
    MORE IS COMMING
 ------------------------------------------------------------------
EOM
}

# =============================================================================
function _dj_clone_find_username()
{
    platform=$1
    if [ "$platform" = 'bitbucket' ] ; then
        echo $BitBucket_username
        return
    fi
    if [ "$platform" = 'github' ] ; then
        echo $GitHub_username
        return
    fi
    if [ "$platform" = 'gitee' ] ; then
        echo $GiTee_username
        return
    fi
}

# =============================================================================
function _dj_clone_find_link()
{
    platform=$1
    if [ "$platform" = 'bitbucket' ] ; then
        echo "bitbucket.org"
        return
    fi
    if [ "$platform" = 'github' ] ; then
        echo "github.com"
        return
    fi
    if [ "$platform" = 'gitee' ] ; then
        echo "gitee.com"
        return
    fi
}

# =============================================================================
function _dj_clone_from() # platform, repo, etc
{
    platform=$1
    repo_name=$2
    if [[ -z $repo_name ]] ; then
        echo -e "\n ${PRP}dj clone $platform${NOC}: repo name not given\n"
        return
    fi
    uname=$(_dj_clone_find_username $platform)
    link=$(_dj_clone_find_link $platform)
    source_link=https://$uname@$link/$uname/$repo_name.git
    echo -e "\n dj clone: ${GRN}$source_link${NOC}\n"

    b_name=$(_find_argument_after_option -b $3 $4 $5 $6 $7 $8)
    
    if [[ ! -z $b_name ]] ; then
        git clone $source_link -b $b_name
    else
        git clone $source_link
    fi
}

# =============================================================================
function _dj_clone_ssh_from()
{
    platform=$1
    repo_name=$2
    if [[ -z $repo_name ]] ; then
        echo -e "\n ${PRP}dj clone-ssh $platform${NOC}: repo name not given\n"
        return
    fi
    uname=$(_dj_clone_find_username $platform)
    link=$(_dj_clone_find_link $platform)
    source_link=git@$link/$uname/$repo_name.git
    echo -e "\n dj clone-ssh: ${GRN}$source_link${NOC}\n"

    b_name=$(_find_argument_after_option -b $3 $4 $5 $6 $7 $8)
    
    if [[ ! -z $b_name ]] ; then
        git clone $source_link -b $b_name
    else
        git clone $source_link
    fi
}
