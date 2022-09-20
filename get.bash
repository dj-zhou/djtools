#!/bin/bash

get_list="git-branch git-commit git-tag "

function _dj_get() {
    if [ $1 = 'git-branch' ]; then
        git rev-parse --abbrev-ref HEAD
        return
    fi
    if [ $1 = 'git-commit' ]; then
        git rev-parse HEAD
        return
    fi
    if [ $1 = 'git-tag' ]; then
        git describe --abbrev=7 --dirty=+ --always --tags
        return
    fi
    echo "dj get: argument not supported"
}
