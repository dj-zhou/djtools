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
# make.sh            no default build directory, it all depends on how make.sh is written

function compile_make_build_etc() {
    target="$1"
    # ------------------------------
    if [ -f "Makefile" ]; then
        _build_make "$target"
        return
    fi
    # ------------------------------
    # CMake and Meson are of the same importance
    if [[ -f "CMakeLists.txt" || -f "meson.build" ]]; then
        if [ -f "CMakeLists.txt" ]; then
            _build_cmake "$target"
        fi
        if [ -f "meson.build" ]; then
            _build_meson_native "$target"
            # this is a hack
            if [ "$target" = "clean" ]; then
                _build_meson_cross "clean"
            fi
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
    if [ "$target" = "clean" ]; then
        printf "(djtools) mc: "
    else
        printf "(djtools) m: "
    fi
    printf "${RED}build script (Makefile/CMakeLists.txt/meson.build/make.sh) not found, exit.${NOC}\n"
}

# =============================================================================
# this is only for native build
function m() {
    compile_make_build_etc "$@"
}

# =============================================================================
function mc() {
    compile_make_build_etc "clean"
}

# =============================================================================
function mi() {
    compile_make_build_etc "install"
}
