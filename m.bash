#!/bin/bash

# =============================================================================
# =============================================================================
# not the build command

# =============================================================================
# if Makefile exists, use Makefile to compile and exit, otherwise
# if CMakeLists.txt exists, use cmake to compile (use default cmake ..) and exit, otherwise
# if meson.build exists, use "build meson -native" command to build and exit, otherwise
# if make.sh exist, use it, and make.sh file can be writen in whatever fashion

# build directories
# Makefile           bin/
# CMakeList.txt      build/
# meson.build       _bnative.meson/, or _bcross.*/
# make.sh            no build directory

function compile_make_build_etc()
{
    clean_tag=$1
    cur_dir=${PWD}

    # ------------------------------
    if [ -f "Makefile" ] ; then
        compile_makefile $clean_tag
        return
    fi
    # ------------------------------
    if [ -f "CMakeLists.txt" ] ; then
        compile_cmakelist $clean_tag
        return
    fi
    # ------------------------------
    if [ -f "meson.build" ] ; then
        if [ "$clean_tag" = 'clean' ] ; then
            rm -rf build
            rm -rf _bcross*
            rm -rf _bnative
            rm -rf builddir
            return
        fi
        echo -e "running: ${PRP} build meson -native${NOC}"
        build meson -native
        return
    fi
    # ------------------------------
    if [ -f "make.sh" ] ; then
        chmod +x make.sh
        ./make.sh $clean_tag
        return
    fi
    echo -e "(djtools) m/mc: ${RED}build method not defined${NOC}"
    cd $cur_dir
}

# =============================================================================
function m()
{
    compile_make_build_etc $1 $2 $3 $4 $5
}

# =============================================================================
function mc()
{
    compile_make_build_etc clean
}
