#!/bin/bash

# remove the local branches that the upstreams are gone: to test
# git fetch -p 
# for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do 
#     git branch -D $branch;
# done

# =============================================================================
function _repod_help()
{
    echo -e "\n---------------------- repod ------------------------"
    echo " Author      : Dingjiang Zhou"
    echo " Email       : zhoudingjiang@gmail.com "
    echo " Create Date : Mar. 1st, 2020 "
    echo "-----------------------------------------------------"
    echo -e "\nFirst level arguments:"
    echo "   backup-to - push the repo to some repo"
    echo "   branches  - to check branch status"
    echo "   checkout  - only used to checkout all branches"
    echo "   switch-to - change the remote url"
    echo -e "   update    - update the repo information in a folder\n"
    echo "   MORE IS COMMING"
    echo -e "\nAll commands support tab completion\n"
}

# =============================================================================
function _backup_to_github()
{
    current_folder=${PWD}

    # -------------------------------------------------
    repo=`basename "$current_folder"`
    echo $repo

    # -------------------------------------------------
    if [[ ! -d .git ]] ; then
        echo " not a git repo, cannot backup to GitHub"
        return
    fi

    git_original_remote_url=`git remote get-url origin`
    
    if [[ $git_original_remote_url = *"github"* ]] ; then
        echo " already a GitHub repo, no need to backup"
        return
    fi

    # -------------------------------------------------
    git remote set-url origin https://$github_username@github.com/$github_username/$repo.git
    if [ $# = 0 ] ; then
        git push -u origin master
        git push --tags
        echo -e "\n master and all tags are pushed into GitHub\n"
    fi

    if [ $# = 1 ] ; then
        if [ $1 = '--all' ] ; then
            git push --all # that is only all local branches
            git push --tags
        else # push a specific branch
            git push -u origin $1
            echo -e "\n branch "$1" has been pushed to GitHub\n"
        fi
    fi
    git remote set-url origin $git_original_remote_url
    # -------------------------------------------------
    cd $current_folder
    unset current_folder
}

# =============================================================================
# only back up to personal private repo
function _backup_to_gitee()
{
    current_folder=${PWD}

    # -------------------------------------------------
    repo=`basename "$current_folder"`
    echo $repo

    # -------------------------------------------------
    if [[ ! -d .git ]] ; then
        echo " not a git repo, cannot backup to GiTee"
        return
    fi

    git_original_remote_url=`git remote get-url origin`
    
    if [[ $git_original_remote_url = *"gitee"* ]] ; then
        echo " already a GiTee repo, no need to backup"
        return
    fi

    # -------------------------------------------------
    git remote set-url origin https://$gitee_username@gitee.com/$gitee_username/$repo.git
    if [ $# = 0 ] ; then
        git push -u origin master
        git push --tags
        echo -e "\nmaster and all tags are pushed into GiTee\n"
    fi

    if [ $# = 1 ] ; then
        if [ $1 = '--all' ] ; then
            git push --all  # that is only all local branches
            git push --tags
        else # push a specific branch
            git push -u origin $1
            echo -e "\n branch "$1" has been pushed to GiTee\n"
        fi
    fi
    git remote set-url origin $git_original_remote_url
    # -------------------------------------------------
    cd $current_folder
    unset current_folder
}

# =============================================================================
function _repod_branches_list()
{
    # git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format='%(refname:short)'
    # this is not the latest
    git for-each-ref --count=10 --sort=committerdate refs/heads/ \
        --format='%(color:green)%(committerdate:short)%(color:reset)|%(color:red)%(objectname:short)%(color:reset)|%(HEAD)%(color:yellow)%(refname:short)%(color:reset) | %(authorname)'
    echo -e '\nnot finished yet\n'
}

# =============================================================================
function _repod_branches_list_all()
{
    if [ $1 = '--remote' ] ; then
        repod checkout all-branch
    fi
    
    git for-each-ref --sort=committerdate refs/heads/ \
        --format='%(color:green)%(committerdate:short)%(color:reset)|%(color:red)%(objectname:short)%(color:reset)|%(HEAD)%(color:yellow)%(refname:short)%(color:reset) | %(authorname)'
}

function _repod_update_help()
{
    _repod_help
    _display_section
    echo -e "repod update\n    supported arguments:"
    echo -e "      --all-sub-folders\n"

}
# =============================================================================
function _repod_update_repos_all_folders()
{
    current_folder=${PWD}

    for folder in ./* ; do
        if [ -d $folder ] ; then
            echo -e "${CYN}\r\n----------------------------"
            printf `basename "$folder"${NOC}`
            cd $folder
            if [ -d ".git/" ] ; then
                git_status=$(git status)
                if [[ $git_status = *"Changes not staged for commit"* ]] ; then
                    printf " ${RED}dirty${NOC}"
                elif [[ $git_status = *"is ahead"* ]] ; then
                    printf " ${BLU}ahead${NOC}"
                elif [[ $git_status = *"is behind"* ]] ; then
                    printf " ${CYN}behind${NOC}"
                fi
                echo " "
                git fetch -p
            else
                printf " ${BRN}NOT a git repo${NOC}"
                echo " "
            fi
            cd $current_folder
        fi
    done

    cd $current_folder
    unset current_folder
}

# =============================================================================
function repod()
{
    current_folder=${PWD}

    # ------------------------------
    if [ $# -eq 0 ] ; then
        _repod_help
        return
    fi

    # ------------------------------
    if [ $1 = 'backup-to' ] ; then
        if [ $# = 1 ] ; then
            _repod_help
            return
        fi
        if [ $2 = 'github' ] ; then
            _backup_to_github $3 $4 $5 $6
            return
        fi
        if [ $2 = 'gitee' ] ; then
            _backup_to_gitee $3 $4 $5 $6
            return
        fi
    fi

    # ------------------------------
    if [ $1 = 'switch-to' ] ; then
        if [ $# = 1 ] ; then
            _repod_help
            return
        fi
        repo=`basename "$current_folder"`

        _display_section
        echo 'remote url before switching:'
        git remote get-url origin
        _display_section
        echo -e "\n"

        if [ $2 = 'bitbucket' ] ; then
            echo " switch to bitbucket"
            git remote set-url origin \
                https://$bitbucket_username@bitbucket.org/$bitbucket_username/$repo.git
        fi
        if [ $2 = 'github' ] ; then
            echo " switch to github"
            git remote set-url origin \
                https://$github_username@github.com/$github_username/$repo.git
        fi
        if [ $2 = 'gitee' ] ; then
            git remote set-url origin \
                https://$gitee_username@gitee.com/$gitee_username/$repo.git
            echo " switch to gitee"
        fi

        echo -e "\n"
        _display_section
        echo 'remote url after switching:'
        git remote get-url origin
        _display_section
        return
    fi

    # ------------------------------
    if [[ $1 = 'update' ]] ; then
        if [ $# = 1 ] ; then
            _repod_update_help
            return
        fi
        if [ $2 = '--all-sub-folders' ] ; then
            _repod_update_repos_all_folders $3 $4 $5 $6
            return
        fi
        return
    fi

    # ------------------------------
    if [ $1 = 'checkout' ] ; then
        if [ $# = 1 ] ; then
            _repod_help
            return
        fi
        if [ $2 = 'all-branch' ] ; then
            echo " checkout all remote branches"
            git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
            git fetch --all
            git pull --all
            _display_section
            branch_count=$(git branch | wc -l)
            echo "branch count: "$branch_count
            _display_section
            return
        fi
    fi

    # ------------------------------
    if [ $1 = 'branches' ] ; then
        if [ $# = 1 ] ; then
            _repod_help
            return
        fi
        if [ $2 = 'list-all' ] ; then
            _repod_branches_list_all $3 $4 $5
            return
        elif [ $2 = 'list' ] ; then
            _repod_branches_list
            return
        fi
    fi
    
    echo -e '\r\nrepod : "'$1 '"command not supported\r\n'
    _repod_help
    # ------------------------------
    cd $current_folder
    unset current_folder
}

# =============================================================================
function _repod()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        backup-to
        branches
        checkout
        switch-to
        update
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # no space in front or after "="
    ACTIONS[backup-to]+="github gitee "
    ACTIONS[switch-to]+="bitbucket github gitee "
    ACTIONS[checkout]+="all-branch "
    ACTIONS[branches]+="list-all "
    ACTIONS[all-branch]=" "
    ACTIONS[bitbucket]="--all "
    ACTIONS[github]="--all "
    ACTIONS[gitee]="--all "
    ACTIONS[--all]=" "
    ACTIONS[list-all]="--local --remote "
    ACTIONS[--local]=" "
    ACTIONS[--remote]=" "
    ACTIONS[update]+="--all-sub-folders "
    ACTIONS[--all-sub-folders]+=" "
    
    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================
complete -F _repod repod
