#!/bin/bash

# =============================================================================
function _dj_clone_repo_list() { # platform
    platform="$1"
    if [ $platform = 'github' ]; then
        file=$HOME/.$platform-repos-$github_username
    elif [ $platform = 'bitbucket' ]; then
        file=$HOME/.$platform-repos-$bitbucket_username
    fi
    if [ ! -f $file ]; then
        echo "no_repo_list_file_in_${HOME}/_directory" &>/dev/null
        return
    fi
    list=$(cat $file)
    echo "$list"
}

# =============================================================================
function _dj_ssh_clone_help() {
    _dj_help
    cat <<eom
 ------------------------- dj ssh-clone ---------------------------
 Second level commands:
    bitbuket - to clone repo from BitBucket
    github   - to clone repo from GitHub

 Third level argument:
    --add        - to add the an argument into a repo file in ~ directory
                   such that the command "dj ssh-clone github" can tab-complete with
                   repo names
    <repo name>  - to clone a repo from a platform
 ------------------------------------------------------------------
eom
}

# =============================================================================
function _dj_clone_find_username() {
    platform=$1
    if [ "$platform" = 'bitbucket' ]; then
        echo $bitbucket_username
        return
    fi
    if [ "$platform" = 'github' ]; then
        echo $github_username
        return
    fi
}

# =============================================================================
function _dj_clone_find_link() {
    platform=$1
    if [ "$platform" = 'bitbucket' ]; then
        echo "bitbucket.org"
        return
    fi
    if [ "$platform" = 'github' ]; then
        echo "github.com"
        return
    fi
}

# =============================================================================
function _dj_git_ssh_clone_from() {
    platform=$1
    repo_name=$2 # it also can be an option "--add"

    uname=$(_dj_clone_find_username $platform)
    # ------------------------------------------------------
    # add repo name into files to make a completable list
    if [ "--add" == $2 ]; then
        echo -e "add ${GRN}$3${NOC} into file ${GRN}${HOME}/.$platform-repos-$uname${NOC}."
        echo $3 >>${HOME}/.$platform-repos-$uname
        return
    fi

    # ------------------------------------------------------

    # check if repo is listed in file ${HOME}/.$platform-repos-$uname$
    # if not, ask if add it to it
    listed_repos="$(_dj_clone_repo_list $platform)"
    if [[ ! "$listed_repos" = *"$repo_name"* ]]; then
        echo -e "do you want to add ${GRN}$repo_name${NOC} to ${GRN}~/.$platform-repos-$uname${NOC} [y/n]?"
        read asw
        if [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || (
            $asw = 'Yes') || ($asw = 'yes') ]]; then
            echo $repo_name >>${HOME}/.$platform-repos-$uname
            echo -e "${GRN}$repo_name${NOC} is added to ${GRN}~/.$platform-repos-$uname${NOC}"
        else
            echo -e "${GRN}$repo_name${NOC} is NOT added to ${GRN}~/.$platform-repos-$uname${NOC}"
        fi
    fi
    if [[ -z $repo_name ]]; then
        echo -e "${PRP}dj git ssh-clone $platform${NOC}: repo name not given"
        return
    fi
    uname=$(_dj_clone_find_username $platform)
    link=$(_dj_clone_find_link $platform)
    source_link=git@$link:$uname/$repo_name.git
    echo -e "dj git ssh-clone: ${GRN}$source_link${NOC}"

    branch_name="$(_find_argument_after_option -b $3 $4 $5 $6 $7 $8)"
    if [[ ! -z "$branch_name" ]]; then
        git clone "$source_link" -b "$branch_name"
    else
        git clone "$source_link"
    fi
}
