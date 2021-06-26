#!/bin/bash

# todo
# ROS (1)
# openCV

# =============================================================================
function _version_help() {
    echo -e "\n ---------------------  version ------------------------"
    echo "  Author      : Dingjiang Zhou"
    echo "  Email       : zhoudingjiang@gmail.com "
    echo "  Create Date : July 19th, 2020 "
    echo " -----------------------------------------------------"
    echo -e "\n supported commands:\n"
    echo " check - to check software version"
    echo " swap  - to swap softwaare version, for example, gcc/g++"
}

# =============================================================================
_version_if_ge_than() { # current version #  required version
    current_ver=$1
    current_ver=$(echo $1 | grep -o '[^-]*$')
    crr_ver_mjr=$(echo $current_ver | cut -d. -f1)
    crr_ver_mnr=$(echo $current_ver | cut -d. -f2)
    crr_ver_rev=$(echo $current_ver | cut -d. -f3)

    require_ver=$(echo $2 | grep -o '[^-]*$')
    req_ver_mjr=$(echo $require_ver | cut -d. -f1)
    req_ver_mnr=$(echo $require_ver | cut -d. -f2)
    req_ver_rev=$(echo $require_ver | cut -d. -f3)

    if [[ "$crr_ver_mjr" -gt "$req_ver_mjr" ]]; then
        echo "yes"
        return
    elif [[ "$crr_ver_mjr" -lt "$req_ver_mjr" ]]; then
        echo "no"
        return
    fi
    # reach here, means major version is the same
    if [[ "$crr_ver_mnr" -gt "$req_ver_mnr" ]]; then
        echo "yes"
        return
    elif [[ "$crr_ver_mnr" -lt "$req_ver_mnr" ]]; then
        echo "no"
        return
    fi
    # reach here, means minor version is the same
    if [[ "$crr_ver_rev" -gt "$req_ver_rev" ]]; then
        echo "yes"
        return
    elif [[ "$crr_ver_rev" -lt "$req_ver_rev" ]]; then
        echo "no"
        return
    fi
    # reach here, means the version are the same
    echo "yes"
}

# =============================================================================
function _version_check_arm_linux_gnueabi_gcc() {
    v=$(arm-linux-gnueabi-gcc --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_arm_linux_gnueabihf_gcc() {
    v=$(arm-linux-gnueabihf-gcc --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_arm_linux_gnueabihf_gpp() {
    v=$(arm-linux-gnueabihf-g++ --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_aarch64_linux_gnu_gcc() {
    v=$(aarch64-linux-gnu-gcc --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_cli11() {
    file=/usr/local/lib/pkgconfig/CLI11.pc
    if [ ! -f $file ]; then
        echo "cli11 may not installed correctly!"
        return
    fi
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"Version: "* ]]; then
            version=$(echo $line | awk '{ print $2 }')
        fi
    done <$file
    echo $version
}

# =============================================================================
function _version_check_cmake() {
    v=$(cmake --version | grep -v kitware | awk '{ print $3 }')
    # return the version value
    echo $v
}

# =============================================================================
function _version_check_eigen3() {
    # example:
    # #define EIGEN_WORLD_VERSION 3
    # #define EIGEN_MAJOR_VERSION 3
    # #define EIGEN_MINOR_VERSION 4

    files="/usr/local/include/eigen3/Eigen/src/Core/util/Macros.h "
    files+="/usr/include/eigen3/Eigen/src/Core/util/Macros.h "
    for file in $files; do
        if [[ -f "$file" ]]; then
            while IFS='' read -r line || [[ -n "$line" ]]; do
                if [[ $line == *"define EIGEN_WORLD_VERSION"* ]]; then
                    world_version=$(echo $line | awk '{ print $3 }')
                fi
                if [[ $line == *"define EIGEN_MAJOR_VERSION"* ]]; then
                    major_version=$(echo $line | awk '{ print $3 }')
                fi
                if [[ $line == *"define EIGEN_MINOR_VERSION"* ]]; then
                    minor_version=$(echo $line | awk '{ print $3 }')
                fi
            done <$file
            echo $world_version.$major_version.$minor_version
            return
        fi
    done
}

# =============================================================================
function _version_check_gcc() {
    v=$(gcc --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
# I found /usr/lib/x86_64-linux-gnu/pkgconfig/libglog.pc
# but it is from sudo apt-get install libgoogle-glog-dev
# however, the source code installation does not generate this package config file:
# https://github.com/google/glog/pull/239
function _version_check_glog() {
    file=/usr/lib/x86_64-linux-gnu/pkgconfig/libglog.pc
    if [ ! -f $file ]; then
        echo "glog may not installed correctly!"
        echo "note: source code installation does not have a libglog.pc file"
        return
    fi
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"Version: "* ]]; then
            version=$(echo $line | awk '{ print $2 }')
        fi
    done <$file
    echo $version
}

# =============================================================================
# I could only find /usr/local/lib/pkgconfig/gtest.pc to check its version
function _version_check_gtest() {
    file=/usr/local/lib/pkgconfig/gtest.pc
    if [ ! -f $file ]; then
        echo "gtest may not installed correctly!"
        return
    fi
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"Version: "* ]]; then
            version=$(echo $line | awk '{ print $2 }')
        fi
    done <$file
    echo $version
}

# =============================================================================
function _version_check_gpp() {
    v=$(g++ --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
    unset v
    unset vv
}

# =============================================================================
function _version_check_gnome() {
    v=$(gnome-shell --version | awk '{ print $3 }')
    # return the version value
    echo $v
    unset v
}

# =============================================================================
function _version_check_magic_enum() {
    file="/usr/local/include/magic_enum.hpp"
    if [[ -f "$file" ]]; then
        while IFS='' read -r line || [[ -n "$line" ]]; do
            if [[ $line == *"define MAGIC_ENUM_VERSION_MAJOR"* ]]; then
                major_version=$(echo $line | awk '{ print $3 }')
            fi
            if [[ $line == *"define MAGIC_ENUM_VERSION_MINOR"* ]]; then
                minor_version=$(echo $line | awk '{ print $3 }')
            fi
            if [[ $line == *"define MAGIC_ENUM_VERSION_PATCH"* ]]; then
                patch_version=$(echo $line | awk '{ print $3 }')
            fi
        done <$file
        echo $major_version.$minor_version.$patch_version
    fi
}

# =============================================================================
function _version_check_opencv() {
    # example:
    # #define CV_VERSION_MAJOR    3
    # #define CV_VERSION_MINOR    4
    # #define CV_VERSION_REVISION 13

    files="/usr/local/include/opencv2/core/version.hpp "
    files+="/usr/include/opencv2/core/version.hpp "
    for file in $files; do
        if [[ -f "$file" ]]; then
            while IFS='' read -r line || [[ -n "$line" ]]; do
                if [[ $line == *"define CV_VERSION_MAJOR"* ]]; then
                    major_version=$(echo $line | awk '{ print $3 }')
                fi
                if [[ $line == *"define CV_VERSION_MINOR"* ]]; then
                    minor_version=$(echo $line | awk '{ print $3 }')
                fi
                if [[ $line == *"define CV_VERSION_REVISION"* ]]; then
                    revision=$(echo $line | awk '{ print $3 }')
                fi
            done <$file
            echo $major_version.$minor_version.$revision
            return
        fi
    done
    unset file
    unset files
}

# =============================================================================
function _version_check_opengl() {
    _install_if_not_installed mesa-utils &>/dev/null
    glxinfo | grep version
}

# =============================================================================
function _version_check_python3() {
    anw=$(_check_if_package_installed python3)
    if [[ "$anw" = "no" ]]; then
        echo "python3 not installed"
        return
    fi
    echo $(python3 --version | awk '{ print $2 }')
}

# =============================================================================
function _version_check_ubuntu() {
    v=$(lsb_release -a | awk '{ print $3 }')
    vv=$(echo $v | awk '{ print $3 }')
    echo $vv
    unset v
    unset vv
}

# =============================================================================
function _version_check_yaml_cpp() {
    file=/usr/local/lib/pkgconfig/yaml-cpp.pc
    if [ ! -f $file ]; then
        echo "libyaml-cpp may not be installed correctly!"
        return
    fi
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"Version: "* ]]; then
            version=$(echo $line | awk '{ print $2 }')
        fi
    done <$file
    echo $version
}

# =============================================================================
function version() {
    # ------------------------------
    if [ $# -eq 0 ]; then
        _version_help
        return
    fi

    # ------------------------------
    if [ $1 = 'check' ]; then
        # ------------------------------
        if [ $# = 1 ]; then
            _version_help
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabi-gcc' ]; then
            _version_check_arm_linux_gnueabi_gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabihf-gcc' ]; then
            _version_check_arm_linux_gnueabihf_gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabihf-g++' ]; then
            _version_check_arm_linux_gnueabihf_gpp
            return
        fi
        # ------------------------------
        if [ $2 = 'aarch64-linux-gnu-gcc' ]; then
            _version_check_aarch64_linux_gnu_gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'cli11' ]; then
            _version_check_cli11
            return
        fi
        # ------------------------------
        if [ $2 = 'cmake' ]; then
            _version_check_cmake
            return
        fi
        # ------------------------------
        if [ $2 = 'eigen3' ]; then
            _version_check_eigen3
            return
        fi
        # ------------------------------
        if [ $2 = 'gcc' ]; then
            _version_check_gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'glog' ]; then
            _version_check_glog
            return
        fi
        # ------------------------------
        if [ $2 = 'gtest' ]; then
            _version_check_gtest
            return
        fi
        # ------------------------------
        if [ $2 = 'g++' ]; then
            _version_check_gpp
            return
        fi
        # ------------------------------
        if [ $2 = 'gnome' ]; then
            _version_check_gnome
            return
        fi
        # ------------------------------
        if [ $2 = 'magic-enum' ]; then
            _version_check_magic_enum
            return
        fi
        # ------------------------------
        if [ $2 = 'opencv' ]; then
            _version_check_opencv
            return
        fi
        # ------------------------------
        if [ $2 = 'opengl' ]; then
            _version_check_opengl
            return
        fi
        # ------------------------------
        if [ $2 = 'python3' ]; then
            _version_check_python3
            return
        fi
        # ------------------------------
        if [ $2 = 'ubuntu' ]; then
            _version_check_ubuntu
            return
        fi
        # ------------------------------
        if [ $2 = 'yaml-cpp' ]; then
            _version_check_yaml_cpp
            return
        fi
        # ------------------------------
        echo -e "\n version check: $2: argument not supported\n"
        return
    fi
    # ------------------------------
    if [ $1 = 'swap' ]; then
        # ------------------------------
        if [ $# = 1 ]; then
            _version_help
            return
        fi
        # ------------------------------
        if [ $2 = 'gcc' ]; then
            sudo update-alternatives --config gcc
            return
        fi
        # ------------------------------
        if [ $2 = 'g++' ]; then
            sudo update-alternatives --config g++
            return
        fi
        # ------------------------------
        if [ $2 = 'gxx' ]; then
            sudo update-alternatives --config gcc
            sudo update-alternatives --config g++
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabi-gxx' ]; then
            sudo update-alternatives --config arm-linux-gnueabi-gcc
            sudo update-alternatives --config arm-linux-gnueabi-g++
            return
        fi
        # ------------------------------
        if [ $2 = 'arm-linux-gnueabihf-gxx' ]; then
            sudo update-alternatives --config arm-linux-gnueabihf-gcc
            sudo update-alternatives --config arm-linux-gnueabihf-g++
            return
        fi
        # ------------------------------
        if [ $2 = 'python3' ]; then
            # this does not work due to anaconda setup! be careful
            sudo update-alternatives --config python3
            return
        fi
        # ------------------------------
        if [ $2 = 'aarch64-linux-gnu-gcc' ]; then
            sudo update-alternatives --config aarch64-linux-gnu-gcc
            return
        fi
        echo -e "\n version swap: $2: argument not supported\n"
        return
    fi
    echo -e '\r\n version : "'$1 '"command not supported\r\n'
    _version_help
}

# =============================================================================
function _version() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        check
        swap
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    check_list+="arm-linux-gnueabi-gcc arm-linux-gnueabihf-gcc "
    check_list+="aarch64-linux-gnu-gcc arm-linux-gnueabihf-g++ "
    check_list+="cli11 cmake eigen3 gcc glog gtest g++ gnome magic-enum opencv "
    check_list+="opengl python3 ubuntu yaml-cpp "
    ACTIONS[check]="$check_list "
    for i in $check_list; do
        ACTIONS[$i]=" "
    done
    swap_list+="arm-linux-gnueabi-gxx arm-linux-gnueabihf-gxx "
    swap_list+="aarch64-linux-gnu-gcc gcc g++ gxx python3 "
    ACTIONS[swap]="$swap_list "
    for i in $swap_list; do
        ACTIONS[$i]=" "
    done

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
complete -F _version version
