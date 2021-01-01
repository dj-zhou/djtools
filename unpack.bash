#!/bin/bash

# =============================================================================
function _unpack_tar_xz()
{
    tar_xz_file=$1
    folder=${tar_xz_file%".tar.xz"*}
    rm $folder -rf
    echo -e "\n ${PRP}unpack tar.xz${NOC}:"
    echo -e "    unpack to directory ${GRN}${folder}${NOC}\n"
    
    _press_enter_or_wait_s_continue 10
    tar -xvf $tar_xz_file
}

# =============================================================================
function _unpack_tar_gz()
{
    tar_gz_file=$1
    folder=${tar_gz_file%".tar.gz"*}
    rm $folder -rf
    mkdir -p $folder
    echo -e "\n ${PRP}unpack tar.gz${NOC}:"
    echo -e "    unpack to directory ${GRN}${folder}${NOC}\n"
    
    _press_enter_or_wait_s_continue 10
    tar -xvf $tar_gz_file -C ./$folder
}

# =============================================================================
function unpack()
{
    if [ $# = 0 ] ; then
        echo -e "\n help: todo\n"
        return
    fi
    # -------------------------------------------
    if [ $1 = 'tar.xz' ] ; then
        _unpack_tar_xz $2 $3 $4 $5 $6 $7 $8 $9
        return
    fi
    # -------------------------------------------
    if [ $1 = 'tar.gz' ] ; then
        _unpack_tar_gz $2 $3 $4 $5 $6 $7 $8 $9
        return
    fi
    
    echo -e "\n help: todo\n"
    
}

# =============================================================================
function _unpack()
{
    COMPREPLY=()

    # ------------------------------------------------------------------------
    local SERVICES=("
        tar.xz
        tar.gz
    ")
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    tar_xz_list="$(ls . | grep tar.xz)"
    ACTIONS[tar.xz]+="$tar_xz_list "
    for i in $tar_xz_list ; do
        ACTIONS[$i]=" "
    done
    # ------------------------------------------------------------------------
    tar_gz_list="$(ls . | grep tar.gz)"
    ACTIONS[tar.gz]+="$tar_gz_list "
    for i in $tar_gz_list ; do
        ACTIONS[$i]=" "
    done
    
    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( $(compgen -W "${ACTIONS[$3]}" -- $cur) )
    else
        COMPREPLY=( $(compgen -W "${SERVICES[*]}" -- $cur) )
    fi
}

# =============================================================================
complete -F _unpack unpack
