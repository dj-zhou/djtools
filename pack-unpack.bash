#!/bin/bash

# =============================================================================
function _dj_unpack_tar_xz() {
    tar_xz_file=$1
    folder=${tar_xz_file%".tar.xz"*}
    _show_and_run rm $folder -rf
    echo -e "unpack ${GRN}$tar_xz_file${NOC} to directory ${GRN}${folder}/${NOC}\n"

    _press_enter_or_wait_s_continue 10
    _show_and_run tar -xvf $tar_xz_file
}

# =============================================================================
function _dj_unpack_tar_gz() {
    tar_gz_file=$1
    folder=${tar_gz_file%".tar.gz"*}
    _show_and_run rm $folder -rf
    _show_and_run mkdir -p $folder
    echo -e "unpack ${GRN}$tar_gz_file${NOC} to directory ${GRN}${folder}/${NOC}"

    _press_enter_or_wait_s_continue 10
    _show_and_run tar -xvf $tar_gz_file -C ./$folder
}

# =============================================================================
# todo: use `*`, or multiple files
function _dj_pack_tar_gz() {
    filename=$(basename $1)
    _show_and_run tar -czvf $filename.tar.gz $1
}

# =============================================================================
function _dj_pack() {
    if [ $# = 0 ]; then
        echo -e "_dj_pack help: todo"
        return
    fi
    # -------------------------------------------
    if [ $1 = '-tar.gz' ]; then
        shift 1
        _dj_pack_tar_gz $@
        return
    fi
}

# =============================================================================
function _dj_unpack() {
    if [ $# = 0 ]; then
        echo -e "_dj_unpack help: todo"
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

    echo -e "help: todo"
}
