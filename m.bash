#!/bin/bash

# =============================================================================
# priorities:
# if Makefile exists, use Makefile to compile and exit, otherwise
# if CMakeLists.txt exists, use cmake to compile (use default cmake ..), no exit
# if meson.build exists, use "build meson-native" command to build, no exit
# if make.sh exist, use it as how it is written, exit

# build directories
# Makefile           bin/
# CMakeLists.txt    _bnative.cmake/
# meson.build       _bnative.meson/, or _bcross.[sdk name]/
# make.sh            no default build directory, it all depends on how make.sh is written

function compile_make_build_etc() {
    target="$1"
    options=()
    # let's choose --------------
    [ -f "Makefile" ] && options+=("Makefile")
    [ -f "CMakeLists.txt" ] && options+=("CMakeLists.txt")
    [ -f "meson.build" ] && options+=("meson.build")
    [ -f "make.sh" ] && options+=("make.sh")
    choose=""
    if [ ${#options[@]} -eq 1 ]; then
        choose=${options[0]}
    elif [ ${#options[@]} -ge 2 ]; then
        echo "Please choose a build file to continue:"
        select opt in "${options[@]}"; do
            case $opt in
            "CMakeLists.txt")
                choose="CMakeLists.txt"
                break
                ;;
            "Makefile")
                choose="Makefile"
                break
                ;;
            "meson.build")
                choose="meson.build"
                break
                ;;
            "make.sh")
                choose="make.sh"
                break
                ;;
            *) echo "Invalid option $REPLY" ;;
            esac
        done
    else
        echo "No known build files found."
    fi
    # ------------------------------
    if [ $choose = "Makefile" ]; then
        _build_makefile "$target"
        return
    fi
    # ------------------------------
    # CMake and Meson are of the same importance
    if [ $choose = "CMakeLists.txt" ]; then
        _build_cmake "$target"
        return
    fi
    if [ $choose = "meson.build" ]; then
        if [ $(_build_main_meson_exists) = 'yes' ]; then
            _build_meson_native "$target"
            # this is a hack
            if [ "$target" = "clean" ]; then
                _build_meson_cross "clean"
            fi
        fi
        return
    fi

    # ------------------------------
    if [ $choose = "make.sh" ]; then
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

# =============================================================================
# loop into each directory and build
function mma() {
    for dir in ./*; do
        if [[ -d $dir ]]; then
            echo -e "${CYN}-------------------------${NOC}"
            _show_and_run _pushd_quiet $dir
            m "$@"
            _popd_quiet
        fi
    done
}

# =============================================================================
# loop into each directory and build
function mmc() {
    for dir in ./*; do
        if [[ -d $dir ]]; then
            echo -e "${CYN}-------------------------${NOC}"
            _show_and_run _pushd_quiet $dir
            mc
            _popd_quiet
        fi
    done
}

# =============================================================================
# loop into each directory and build
function mmi() {
    for dir in ./*; do
        if [[ -d $dir ]]; then
            echo -e "${CYN}-------------------------${NOC}"
            _show_and_run _pushd_quiet $dir
            mi
            _popd_quiet
        fi
    done
}
