#!/bin/bash

# =============================================================================
# if Makefile exists, use Makefile to compile and exit, otherwise
# if CMakeLists.txt exists, use cmake to compile (use default cmake ..) and exit, otherwise
# if meson.build exists, use "build meson -native" command to build and exit, otherwise
# if make.sh exist, use it, and make.sh file can be writen in whatever fashion

# build directories
# Makefile           bin/
# CMakeList.txt     _bnative.cmake/
# meson.build       _bnative.meson/, or _bcross.*/
# make.sh            no build directory, it all depends on how make.sh is written

function compile_make_build_etc() {
    clean_tag=$1
    cur_dir=${PWD}

    # ------------------------------
    if [ -f "Makefile" ]; then
        compile_makefile $clean_tag
        return
    fi
    # ------------------------------
    if [ -f "CMakeLists.txt" ]; then
        compile_cmakelist $clean_tag
        return
    fi
    # ------------------------------
    if [ -f "meson.build" ]; then
        if [ "$clean_tag" = 'clean' ]; then
            rm -rf _bcross*
            rm -rf _bnative*
            return
        fi
        echo -e "\n  use ${PRP}meson.build${NOC} to build\n"
        _build_meson_native
        return
    fi
    # ------------------------------
    if [ -f "make.sh" ]; then
        echo -e "\n  use ${PRP}make.sh${NOC} to build\n"
        chmod +x make.sh
        ./make.sh $clean_tag
        return
    fi
    echo -e "(djtools) m/mc: ${RED}build method not defined${NOC}"
    cd $cur_dir
}

# =============================================================================
# this is only for native build
function m() {
    compile_make_build_etc $1 $2 $3 $4 $5
}

# =============================================================================
function mc() {
    compile_make_build_etc clean
}
