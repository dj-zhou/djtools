#!/bin/bash

# =============================================================================
function _dj_clone_repo_list() { # platform
    platform="$1"
    if [ $platform = 'github' ]; then
        file=$HOME/.$platform-repos-$github_username
    elif [ $platform = 'gitee' ]; then
        file=$HOME/.$platform-repos-$gitee_username
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
function _dj_clone_help() {
    _dj_help
    cat <<eom

 ---------------------- dj clone/clone-ssh ------------------------
 Second level commands:
    bitbuket - to clone repo from BitBucket
    github   - to clone repo from GitHub
    gitee    - to clone repo from GiTee

 Third level argument:
    --add        - to add the $4 argument into a repo file in ~ directory
                   such that the command "dj clone-ssh github" can tab-complete with
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
    if [ "$platform" = 'gitee' ]; then
        echo $gitee_username
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
    if [ "$platform" = 'gitee' ]; then
        echo "gitee.com"
        return
    fi
}

# =============================================================================
function _dj_clone_from() { # platform, repo, etc
    echo -e "${YLW}http clone with username and password is going to be deprecated${NOC}"
    platform=$1
    repo_name=$2
    if [[ -z $repo_name ]]; then
        echo -e "\n ${PRP}dj clone $platform${NOC}: repo name not given\n"
        return
    fi
    uname=$(_dj_clone_find_username $platform)
    link=$(_dj_clone_find_link $platform)
    source_link=https://$uname@$link/$uname/$repo_name.git
    echo -e "\n dj clone: ${GRN}$source_link${NOC}\n"

    b_name=$(_find_argument_after_option -b $3 $4 $5 $6 $7 $8)

    if [[ ! -z $b_name ]]; then
        git clone $source_link -b $b_name
    else
        git clone $source_link
    fi
}

# =============================================================================
function _dj_clone_ssh_from() {
    platform=$1
    repo_name=$2 # it also can be an option "--add"

    uname=$(_dj_clone_find_username $platform)
    # ------------------------------------------------------
    # add repo name into files to make a completable list
    if [ "--add" == $2 ]; then
        echo -e "add ${GRN}$3${NOC} into file ${GRN}${HOME}/.$platform-repos-$uname${NOC}:"
        echo $3 >>${HOME}/.$platform-repos-$uname
        return
    fi

    # ------------------------------------------------------

    # check if repo is listed in file ${HOME}/.$platform-repos-$uname$
    # if not, ask if add it to it
    listed_repos="$(_dj_clone_repo_list $platform)"
    if [[ ! "$listed_repos" = *"$repo_name"* ]]; then
        echo -e "do you want to add ${GRN}$repo_name${NOC} to ${GRN}~/.$platform-repos-$uname${NOC}[y/n]?"
        read asw
        if [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || (\
            $asw = 'Yes') || ($asw = 'yes') ]]; then
            echo $repo_name >>${HOME}/.$platform-repos-$uname
            echo -e "${GRN}$repo_name${NOC} is added to ${GRN}~/.$platform-repos-$uname${NOC}"
        else
            echo -e "${GRN}$repo_name${NOC} is NOT added to ${GRN}~/.$platform-repos-$uname${NOC}"
        fi
    fi
    if [[ -z $repo_name ]]; then
        echo -e "\n ${PRP}dj clone-ssh $platform${NOC}: repo name not given\n"
        return
    fi
    uname=$(_dj_clone_find_username $platform)
    link=$(_dj_clone_find_link $platform)
    source_link=git@$link:$uname/$repo_name.git
    echo -e "\n dj clone-ssh: ${GRN}$source_link${NOC}\n"

    b_name=$(_find_argument_after_option -b $3 $4 $5 $6 $7 $8)

    if [[ ! -z $b_name ]]; then
        git clone $source_link -b $b_name
    else
        git clone $source_link
    fi
}
