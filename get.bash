#!/bin/bash

get_list="epoch-time git-branches git-commit git-tag "

function _dj_get_git_branches_in_sub_dir() {
    # if there is no sub dir, exit
    for dir in ./*/; do
        # Check if it's a directory
        if [ -d "$dir" ]; then
            cd $dir
            if [ -d ".git" ]; then
                dir_name="${dir#./}"     # removes the leading ./
                dir_name="${dir_name%/}" # removes the trailing /
                echo -e "${HWHT}$dir_name${NOC}"
                git branch
            fi
            cd ../
        fi
    done
}
function _dj_get() {
    case $1 in
    epoch-time) date +%s.%6N ;;
    # git-branch) git rev-parse --abbrev-ref HEAD ;;
    git-commit) git rev-parse HEAD ;;
    git-branches) _dj_get_git_branches_in_sub_dir ;;
    git-tag) git describe --abbrev=7 --dirty=+ --always --tags ;;
    *) echo "dj get: argument not supported" ;;
    esac
}
