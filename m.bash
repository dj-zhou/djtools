#!/bin/bash

# =============================================================================
# priorities:
# if Makefile exists, use Makefile to compile and exit, otherwise
# if CMakeLists.txt exists, use cmake to compile (use default cmake ..), no exit
# if meson.build exists, use "build meson-native" command to build, no exit
# if make.sh exist, use it as how it is written, exit

# build directories
# Makefile           bin/
# CMakeList.txt     _bnative.cmake/
# meson.build       _bnative.meson/, or _bcross.[sdk name]/
# make.sh            no build directory, it all depends on how make.sh is written

function compile_make_build_etc() {
    target="$1"

    # ------------------------------
    if [ -f "Makefile" ]; then
        _build_make "$target"
        return
    fi
    # ------------------------------
    if [[ -f "CMakeLists.txt" || -f "meson.build" ]]; then
        if [ -f "meson.build" ]; then
            _build_cmake "$target"
        fi
        if [ -f "meson.build" ]; then
            _build_meson_native "$target"
        fi
        return
    fi
    # ------------------------------
    if [ -f "make.sh" ]; then
        echo -e "use customized ${CYN}make.sh${NOC} file"
        chmod +x make.sh
        ./make.sh "$target"
        return
    fi
    echo -e "(djtools) m/mc: ${RED}build method not , nothing is built.${NOC}"
}

# =============================================================================
# this is only for native build
function m() {
    compile_make_build_etc "$@"
}

# =============================================================================
function mc() {
    compile_make_build_etc clean
}
