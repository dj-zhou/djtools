#!/bin/bash

# =============================================================================
function _dj_unpack_tar_xz() {
    tar_xz_file=$1
    folder=${tar_xz_file%".tar.xz"*}
    rm $folder -rf
    echo -e "unpack ${GRN}$tar_xz_file${NOC} to directory ${GRN}${folder}/${NOC}\n"

    _press_enter_or_wait_s_continue 10
    tar -xvf $tar_xz_file
}

# =============================================================================
function _dj_unpack_tar_gz() {
    tar_gz_file=$1
    folder=${tar_gz_file%".tar.gz"*}
    rm $folder -rf
    mkdir -p $folder
    echo -e "unpack ${GRN}$tar_gz_file${NOC} to directory ${GRN}${folder}/${NOC}\n"

    _press_enter_or_wait_s_continue 10
    tar -xvf $tar_gz_file -C ./$folder
}

# =============================================================================
function _dj_unpack() {
    if [ $# = 0 ]; then
        echo -e "\n help: todo\n"
        return
    fi
    # -------------------------------------------
    if [ $1 = 'tar.xz' ]; then
        shift 1
        _dj_unpack_tar_xz $@
        return
    fi
    # -------------------------------------------
    if [ $1 = 'tar.gz' ]; then
        shift 1
        _dj_unpack_tar_gz $@
        return
    fi

    echo -e "\n help: todo\n"

}
