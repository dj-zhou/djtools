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
# options:
#   1. --name
#   2. --email
function _dj_git_see() {
    if [ $# -le 1 ]; then
        echo "usage: dj git see -name/-email"
        return
    fi
    if [ $1 = '-name' ]; then
        all_branches=$(git for-each-ref --format='%(committerdate) | %(authorname) | %(refname)' | grep "$2")
        total_lines=$(echo -e "$all_branches" | wc -l)

        while IFS= read -r line; do
            if [[ "$line" = *"remotes"* ]]; then
                if [ "${line:9:1}" = " " ]; then
                    newline="${line:0:7} 0"
                    for i in $(seq 8 ${#line}); do
                        newline="${newline}${line:${i}:1}"
                    done
                    echo "$newline"
                else
                    echo "$line"
                fi
            fi
        done <<<"$all_branches"
    fi
    if [ $1 = '-email' ]; then
        git for-each-ref --format='%(committerdate) %09 | %(authoremail) | %(refname)' | grep "$2"
        return
    fi
}

# git for-each-ref --sort=committerdate --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'
# Thu Oct 7 07:11:14 2021 -0400
# Thu Oct  07:11:14 2021 -0400
