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
        git for-each-ref --format='%(committerdate) %09 | %(authorname) | %(refname)' | grep "$2"
        return
    fi
    if [ $1 = '-email' ]; then
        git for-each-ref --format=' %(committerdate) %09 | %(authoremail) | %(refname)' | grep "$2"
        return
    fi

}
