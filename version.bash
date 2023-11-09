#!/bin/bash

# =============================================================================
function _version_help() {
    echo -e "\n ---------------------  version ------------------------"
    echo "  Author      : Dingjiang Zhou"
    echo "  Email       : zhoudingjiang@gmail.com "
    echo "  Create Date : July 19th, 2020 "
    echo " -------------------------------------------------------"
    echo -e "\n supported commands:\n"
    echo " check - to check software version"
    echo " swap  - to swap softwaare version, for example, gcc/g++"
}

# =============================================================================
function _find_version_from_pkgconfig_file() { # file
    file="$1"
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"Version: "* ]]; then
            version=$(echo $line | awk '{ print $2 }')
        fi
    done <"$file"
    echo "$version"
}
# =============================================================================
# it can only compile x.y.z and xx.yy.zz
_version_if_ge_than() { # current version #  required version
    # current_ver=$1
    current_ver=$(echo $1)
    # current_ver=$(echo $1 | grep -o '[^-]*$') # why I have this??
    crr_ver_mjr=$(echo $current_ver | cut -d. -f1)
    # echo "crr_ver_mjr = $crr_ver_mjr"
    crr_ver_mnr=$(echo $current_ver | cut -d. -f2)
    # echo "crr_ver_mnr = $crr_ver_mnr"
    crr_ver_rev=$(echo $current_ver | cut -d. -f3)
    # echo "crr_ver_rev = $crr_ver_rev"

    require_ver=$(echo $2)
    # echo "require_ver = $require_ver"
    req_ver_mjr=$(echo $require_ver | cut -d. -f1)
    # echo "req_ver_mjr = $req_ver_mjr"
    req_ver_mnr=$(echo $require_ver | cut -d. -f2)
    # echo "req_ver_mnr = $req_ver_mnr"
    req_ver_rev=$(echo $require_ver | cut -d. -f3)
    # echo "req_ver_rev = $req_ver_rev"

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
function _echo_not_installed() {
    echo -e "$1 ${YLW}maybe not be installed correctly!${NOC}"
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
function _version_check_boost() {
    file="/usr/local/include/boost/version.hpp"

    if [ ! -f $file ]; then
        _echo_not_installed "boost"
    fi

    boost_v=$(cat $file | grep "define BOOST_LIB_VERSION" | awk '{print $3}')
    boost_v=$(echo $boost_v | sed 's/"//g')
    boost_v=$(echo $boost_v | sed 's/_/./g')
    boost_v=$boost_v".0"
    echo $boost_v
}

# =============================================================================
function _version_check_cli11() {
    files="/usr/local/lib/pkgconfig/CLI11.pc "
    files+="/usr/local/share/pkgconfig/CLI11.pc "
    file_is_found=0
    for file in $files; do
        if [[ -f "$file" ]]; then
            while IFS='' read -r line || [[ -n "$line" ]]; do
                if [[ $line == *"Version: "* ]]; then
                    version=$(echo $line | awk '{ print $2 }')
                    file_is_found=1
                fi
            done <$file
            echo $version
            return
        fi
    done
    if [ $file_is_found='0' ]; then
        _echo_not_installed "cli11"
    fi
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
    file_is_found=0
    for file in $files; do
        if [[ -f "$file" ]]; then
            file_is_found=1
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
    if [ $file_is_found='0' ]; then
        _echo_not_installed "eigen3"
    fi
}

# =============================================================================
function _version_check_fmt() {
    file="/usr/local/lib/pkgconfig/fmt.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "fmt"
        return
    fi

    _find_version_from_pkgconfig_file $file
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
# dj setup glog will generate the file: /usr/local/lib/pkgconfig/libglog.pc
function _version_check_glog() {
    # file="/usr/lib/x86_64-linux-gnu/pkgconfig/libglog.pc"
    file="/usr/local/lib/pkgconfig/libglog.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "glog"
        echo "note: source code installation does not have a libglog.pc file"
        return
    fi

    _find_version_from_pkgconfig_file $file
}

# =============================================================================
function _version_check_grpc() {
    file="/usr/local/lib/pkgconfig/grpc++.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "grpc"
        return
    fi

    _find_version_from_pkgconfig_file $file
}

# =============================================================================
# I could only find /usr/local/lib/pkgconfig/gtest.pc to check its version
function _version_check_gtest() {
    file="/usr/local/lib/pkgconfig/gtest.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "gtest"
        return
    fi

    _find_version_from_pkgconfig_file $file
}

# =============================================================================
function _version_check_gpp() {
    v=$(g++ --version | awk '{ print $4 }')
    vv=$(echo $v | awk '{ print $1 }')
    echo $vv
}

# =============================================================================
function _version_check_gnome() {
    v=$(gnome-shell --version | awk '{ print $3 }')
    # return the version value
    echo $v
}

# =============================================================================
function _version_check_go() {
    v_str=$(go version)
    if [[ "$v_str" =~ go([0-9]+\.[0-9]+\.[0-9]+) ]]; then
        go_version="${BASH_REMATCH[1]}"
        echo "$go_version"
    else
        _echo_not_installed "golang-go"
    fi
}

# =============================================================================
function _version_check_magic_enum() {
    file="/usr/local/include/magic_enum.hpp"
    if [ ! -f $file ]; then
        _echo_not_installed "magic-enum"
        return
    fi

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
}

# =============================================================================
function _version_check_nlohmann_json3() {
    file="/usr/local/share/pkgconfig/nlohmann_json.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "nlohmann-json3"
        return
    fi
    _find_version_from_pkgconfig_file $file
}

# =============================================================================
function _version_check_node() {
    v=$(node -v)
    v=$(echo $v | sed 's/v//g')
    echo $v
}

# =============================================================================
function _version_check_npm() {
    npm --version
}

# =============================================================================
function _version_check_opencv() {
    # example:
    # #define CV_VERSION_MAJOR    3
    # #define CV_VERSION_MINOR    4
    # #define CV_VERSION_REVISION 13

    files="/usr/local/include/opencv2/core/version.hpp "
    files+="/usr/include/opencv4/opencv2/core/version.hpp"
    file_is_found=0
    for file in $files; do
        if [[ -f "$file" ]]; then
            file_is_found=1
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
    if [ $file_is_found='0' ]; then
        _echo_not_installed "opencv"
    fi
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
        _echo_not_installed "python3"
        return
    fi
    echo $(python3 --version | awk '{ print $2 }')
}

# =============================================================================
function _version_check_spdlog() {
    file="/usr/local/lib/pkgconfig/spdlog.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "spdlog"
        return
    fi
    _find_version_from_pkgconfig_file $file
}

# =============================================================================
function _version_check_libsystemd() {
    file="/usr/lib/x86_64-linux-gnu/pkgconfig/libsystemd.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "libsystemd"
        return
    fi
    _find_version_from_pkgconfig_file $file
}

# =============================================================================
function _version_check_ubuntu() {
    v=$(lsb_release -a | awk '{ print $3 }')
    vv=$(echo $v | awk '{ print $3 }')
    echo $vv
}

# =============================================================================
function _version_check_yaml_cpp() {
    file="/usr/local/lib/pkgconfig/yaml-cpp.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "libyaml-cpp"
        return
    fi
    _find_version_from_pkgconfig_file $file
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
        if [ $2 = 'boost' ]; then
            _version_check_boost
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
        if [ $2 = 'fmt' ]; then
            _version_check_fmt
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
        if [ $2 = 'gnome' ]; then
            _version_check_gnome
            return
        fi
        # ------------------------------
        if [ $2 = 'go' ]; then
            _version_check_go
            return
        fi
        # ------------------------------
        if [ $2 = 'grpc' ]; then
            _version_check_grpc
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
        if [ $2 = 'magic-enum' ]; then
            _version_check_magic_enum
            return
        fi
        # ------------------------------
        if [ $2 = 'nlohmann-json3' ]; then
            _version_check_nlohmann_json3
            return
        fi
        # ------------------------------
        if [ $2 = 'node' ]; then
            _version_check_node
            return
        fi
        # ------------------------------
        if [ $2 = 'npm' ]; then
            _version_check_npm
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
        if [ $2 = 'spdlog' ]; then
            _version_check_spdlog
            return
        fi
        # ------------------------------
        if [ $2 = 'libsystemd' ]; then
            _version_check_libsystemd
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
        echo -e " version check: $2: argument not supported"
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
        echo -e "version swap: $2: argument not supported"
        return
    fi
    echo -e 'version : "'$1 '"command not supported'
    _version_help
}

check_list+="arm-linux-gnueabi-gcc arm-linux-gnueabihf-gcc "
check_list+="aarch64-linux-gnu-gcc arm-linux-gnueabihf-g++ boost cli11 cmake "
check_list+="eigen3 fmt gcc glog gnome go grpc gtest g++ libsystemd magic-enum "
check_list+="nlohmann-json3 node npm opencv opengl python3 spdlog ubuntu yaml-cpp "

swap_list+="arm-linux-gnueabi-gxx arm-linux-gnueabihf-gxx "
swap_list+="aarch64-linux-gnu-gcc gcc g++ gxx python3 "

# =============================================================================
function _version_linux() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        check
        swap
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    ACTIONS[check]="$check_list "
    for i in $check_list; do
        ACTIONS[$i]=" "
    done
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
# Function to provide custom completions
function _version_darwin() {
    # Getting the current word and previous word in the command-line
    local curcontext="$curcontext" state line
    typeset -A opt_args

    # Array of options for the custom command
    custom_options=("check" "swap")
    read -r -A check_options <<<"$check_list"
    read -r -A swap_options <<<"$swap_list"

    # Defining states for the completion
    _arguments -C \
        '1: :->first' \
        '2: :->second' && return 0

    case $state in
    first)
        _wanted first_level_options expl 'main option' compadd -a custom_options
        ;;
    second)
        case $words[2] in
        check)
            _wanted check_second_level_options expl 'subcommand for check' compadd -a check_options
            ;;
        swap)
            _wanted swap_second_level_options expl 'subcommand for swap' compadd -a swap_options
            ;;
        # You can add more cases here for other options if they have subcommands
        esac
        ;;
    esac
}

# =============================================================================
if [ $system = 'Linux' ]; then
    complete -F _version_linux version
elif [ $system = 'Darwin' ]; then
    compdef _version_darwin version
fi
