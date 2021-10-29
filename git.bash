#!/bin/bash

# =============================================================================
function _dj_git_config() { # name, email
    if [ $# -eq 0 ]; then
        echo "usage: dj git config \"<name>\" <email>"
        return
    fi
    name="$1"
    email="$2"
    echo "git config --local user.name \"$name\""
    git config --local user.name "$name"
    echo "git config --local user.email \"$email\""
    git config --local user.email "$email"
}

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
# options:
#   1. --name
#   2. --email
function _dj_git_search() {
    if [ $# -le 1 ]; then
        echo "usage: dj git search -name/-email [name/email]"
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
}
