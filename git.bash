#!/bin/bash

git_list="search ssh-account "
if [ $system = 'Linux' ]; then
    git_list+="ssh-clone "
    # elif [ $system = 'Darwin' ]; then
    # do nothing here
fi

git_search_list="-name -email -commit "
git_ssh_account_list="--activate --show-all --show-current "

# =============================================================================
function _dj_git_ssh_account_show_all() {
    all_github_accounts=$(ls ~/.ssh | grep .pub)
    for i in $all_github_accounts; do
        username=${i%".pub"}
        username=$(echo "${username/"id_rsa-github-"/}")
        echo $username
    done
}

all_accounts="$(_dj_git_ssh_account_show_all) "

# =============================================================================
function _dj_git_search_show_result() {
    count=0
    while IFS= read -r line; do
        # only shows the remote branches
        if [[ "$line" = *"HEAD"* ]]; then
            continue
        fi
        if [[ "$line" = *"remotes"* ]]; then
            # to align the date, e.g., to revise "Thu Sep 9 xx:xx:xx" to "Thu Sep 09 xx:xx:xx"
            if [ "${line:9:1}" = " " ]; then
                newline="${line:0:7} 0"
                for i in $(seq 8 ${#line}); do
                    newline="${newline}${line:${i}:1}"
                done
                echo "$newline"
            else
                echo "$line"
            fi
            count=$((count + 1))
        fi
    done <<<"$1"
    echo "total branches: $count"
}

# =============================================================================
function _dj_git_search_commit() {
    str="$1"
    git log --oneline | grep "$str"
    echo -e "you can run ${INFO}git show [commit]${NOC} to see the detail of a commit"
}

# =============================================================================
function _dj_git_search() {
    if [ $# -le 1 ]; then
        echo "usage: dj git search -name/-email/-commit [name/email/commit message]"
        return
    fi
    if [ $1 = '-name' ]; then
        all_branches=$(git for-each-ref --format='%(committerdate) | %(authorname) | %(refname)' | grep "$2")
        _dj_git_search_show_result "$all_branches"
        return
    fi
    if [ $1 = '-email' ]; then
        all_branches=$(git for-each-ref --format='%(committerdate) | %(authoremail) | %(refname)' | grep "$2")
        _dj_git_search_show_result "$all_branches"
        return
    fi
    if [ $1 = '-commit' ]; then
        _dj_git_search_commit "$2"
        return
    fi
    echo "dj grep search: argument not supported, exit!"
}

# =============================================================================
function _dj_git() {
    if [ $1 = 'config' ]; then
        shift 1
        _dj_git_config "$@"
        return
    fi
    if [ $1 = 'search' ]; then
        shift 1
        _dj_git_search "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'ssh-account' ]; then
        if [ $2 = '--activate' ]; then
            shift 2
            _dj_git_ssh_account_activate "$@"
            return
        fi
        if [ $2 = '--show-all' ]; then
            _dj_git_ssh_account_show_all
            return
        fi
        if [ $2 = '--show-current' ]; then
            _dj_git_ssh_account_show_current
            return
        fi
    fi
    # ------------------------------
    if [ $1 = 'ssh-clone' ]; then
        # --------------------------
        if [[ "$2" = 'bitbucket' ||
            "$2" = 'github' ]]; then
            shift 1
            _dj_git_ssh_clone_from "$@"
            return
        fi
        _dj_ssh_clone_help
        return
    fi
    echo 'dj git: argument not supported, exit.'
    return
}
