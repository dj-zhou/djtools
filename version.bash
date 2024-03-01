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
_version_if_ge_than() { # current version # required version

    # current_ver=$1
    local current_ver="$(echo $1)"
    if [[ "$current_ver" = *"not installed"* ]]; then
        echo "no"
        return
    fi

    # current_ver=$(echo $1 | grep -o '[^-]*$') # why I have this??
    local crr_ver_mjr=$(echo $current_ver | cut -d. -f1)
    # echo "crr_ver_mjr = $crr_ver_mjr"
    local crr_ver_mnr=$(echo $current_ver | cut -d. -f2)
    # echo "crr_ver_mnr = $crr_ver_mnr"
    local crr_ver_rev=$(echo $current_ver | cut -d. -f3)
    # echo "crr_ver_rev = $crr_ver_rev"

    local require_ver=$(echo $2)
    # echo "require_ver = $require_ver"
    local req_ver_mjr=$(echo $require_ver | cut -d. -f1)
    # echo "req_ver_mjr = $req_ver_mjr"
    local req_ver_mnr=$(echo $require_ver | cut -d. -f2)
    # echo "req_ver_mnr = $req_ver_mnr"
    local req_ver_rev=$(echo $require_ver | cut -d. -f3)
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
    echo -e "$1 ${YLW}maybe not installed correctly!${NOC}"
}

# =============================================================================
function _version_check_abseil() {
    file="/usr/local/lib/pkgconfig/absl_base.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "abseil"
        return
    fi
    _find_version_from_pkgconfig_file $file
}

# =============================================================================
function _version_check_arm_linux_gnueabi_gcc() {
    if command -v arm-linux-gnueabi-gcc >/dev/null 2>&1; then
        v=$(arm-linux-gnueabi-gcc --version | awk '{ print $4 }')
        vv=$(echo $v | awk '{ print $1 }')
        echo $vv
    else
        _echo_not_installed arm-linux-gnueabi-gcc
    fi
}

# =============================================================================
function _version_check_arm_linux_gnueabihf_gcc() {
    if command -v arm-linux-gnueabihf-gcc >/dev/null 2>&1; then
        v=$(arm-linux-gnueabihf-gcc --version | awk '{ print $4 }')
        vv=$(echo $v | awk '{ print $1 }')
        echo $vv
    else
        _echo_not_installed arm-linux-gnueabihf-gcc
    fi
}

# =============================================================================
function _version_check_arm_linux_gnueabihf_gpp() {
    if command -v arm-linux-gnueabihf-g++ >/dev/null 2>&1; then
        v=$(arm-linux-gnueabihf-g++ --version | awk '{ print $4 }')
        vv=$(echo $v | awk '{ print $1 }')
        echo $vv
    else
        _echo_not_installed arm-linux-gnueabihf-g++
    fi
}

# =============================================================================
function _version_check_aarch64_linux_gnu_gcc() {
    if command -v aarch64-linux-gnu-gcc >/dev/null 2>&1; then
        v=$(aarch64-linux-gnu-gcc --version | awk '{ print $4 }')
        vv=$(echo $v | awk '{ print $1 }')
        echo $vv
    else
        _echo_not_installed aarch64-linux-gnu-gcc
    fi
}

# =============================================================================
function _version_check_boost() {
    file="/usr/local/include/boost/version.hpp"

    if [ ! -f $file ]; then
        _echo_not_installed "boost"
        return
    fi

    boost_v=$(cat $file | grep "define BOOST_LIB_VERSION" | awk '{print $3}')
    boost_v=$(echo $boost_v | sed 's/"//g')
    boost_v=$(echo $boost_v | sed 's/_/./g')
    boost_v=$boost_v".0"
    echo $boost_v
}

# =============================================================================
function _version_check_cli11() {
    files=("/usr/local/lib/pkgconfig/CLI11.pc"
        "/usr/local/share/pkgconfig/CLI11.pc")
    file_is_found=0
    for file in "${files[@]}"; do
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
    if command -v cmake >/dev/null 2>&1; then
        v=$(cmake --version | grep -v kitware | awk '{ print $3 }')
        # return the version value
        echo $v
    else
        _echo_not_installed cmake
    fi
}

# =============================================================================
function _version_check_device_tree_compiler() {
    if command -v dtc >/dev/null 2>&1; then
        v=$(dtc --version | awk '{ print $3 }')
        # return the version value
        echo $v
    else
        _echo_not_installed device-tree-compiler
    fi
}

# =============================================================================
function _version_check_eigen3() {
    # Array of file paths
    files=("/usr/local/include/eigen3/Eigen/src/Core/util/Macros.h"
        "/usr/include/eigen3/Eigen/src/Core/util/Macros.h")

    file_is_found=0
    for file in "${files[@]}"; do
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
            done <"$file"
            echo $world_version.$major_version.$minor_version
            return
        fi
    done
    if [ $file_is_found = 0 ]; then
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
    if command -v gcc >/dev/null 2>&1; then
        v=$(gcc --version | awk '{ print $4 }')
        vv=$(echo $v | awk '{ print $1 }')
        echo $vv
    else
        _echo_not_installed gcc
    fi
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
        echo "glog installed from source does not have a libglog.pc file"
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
    if command -v g++ >/dev/null 2>&1; then
        v=$(g++ --version | awk '{ print $4 }')
        vv=$(echo $v | awk '{ print $1 }')
        echo $vv
    else
        _echo_not_installed g++
    fi
}

# =============================================================================
function _version_check_gnome() {
    v=$(gnome-shell --version | awk '{ print $3 }')
    # return the version value
    echo $v
}

# =============================================================================
function _version_check_go() {
    if command -v go >/dev/null 2>&1; then
        v_str=$(go version)
        if [[ "$v_str" =~ go([0-9]+\.[0-9]+\.[0-9]+) ]]; then
            go_version="${BASH_REMATCH[1]}"
            echo "$go_version"
        fi
    else
        _echo_not_installed "golang-go"
    fi
}

# =============================================================================
function _version_check_lcm() {
    file="/usr/local/lib/pkgconfig/lcm.pc"
    if [ ! -f $file ]; then
        _echo_not_installed "lcm"
        return
    fi
    _find_version_from_pkgconfig_file $file
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
function _version_check_meson() {
    if command -v meson >/dev/null 2>&1; then
        v=$(meson --version)
        echo $v
    else
        _echo_not_installed meson
    fi
}

# =============================================================================
function _version_check_ninja() {
    if command -v ninja >/dev/null 2>&1; then
        v=$(ninja --version)
        echo $v
    else
        _echo_not_installed ninja
    fi
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
    if command -v node >/dev/null 2>&1; then
        v=$(node -v)
        v=$(echo $v | sed 's/v//g')
        echo $v
    else
        _echo_not_installed node
    fi
}

# =============================================================================
# pretty sure that npm is installed along with nodejs
function _version_check_npm() {
    if command -v npm >/dev/null 2>&1; then
        npm --version
    else
        _echo_not_installed npm
    fi
}

# =============================================================================
# npx seems to be installed along with nodejs
function _version_check_npx() {
    if command -v npx >/dev/null 2>&1; then
        npx --version
    else
        _echo_not_installed npx
    fi
}

# =============================================================================
function _version_check_opencv() {
    # example:
    # #define CV_VERSION_MAJOR    3
    # #define CV_VERSION_MINOR    4
    # #define CV_VERSION_REVISION 13
    files=("/usr/local/include/opencv2/core/version.hpp"
        "/usr/include/opencv4/opencv2/core/version.hpp")
    file_is_found=0
    for file in "${files[@]}"; do
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
function _version_check_protobuf() {
    if command -v protoc >/dev/null 2>&1; then
        v=$(protoc --version | awk '{ print $2 }')
        echo "$v"
    else
        _echo_not_installed "protobuf"
    fi
}

# =============================================================================
function _version_check_python3() {
    if command -v python3 >/dev/null 2>&1; then
        v=$(python3 --version | awk '{ print $2 }')
        echo "$v"
    else
        _echo_not_installed "python3"
    fi
}

# =============================================================================
function _version_check_ros() {
    if command -v python >/dev/null 2>&1; then
        v=$(rosversion -d)
        echo "$v"
    else
        v=$(echo $ROS_DISTRO)
    fi
    if [ -z $v ]; then
        _echo_not_installed "ROS"
    fi
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
function _version_check {
    case $1 in
    "abseil") _version_check_abseil ;;
    "arm-linux-gnueabi-gcc") _version_check_arm_linux_gnueabi_gcc ;;
    "arm-linux-gnueabihf-gcc") _version_check_arm_linux_gnueabihf_gcc ;;
    "arm-linux-gnueabihf-g++") _version_check_arm_linux_gnueabihf_gpp ;;
    "aarch64-linux-gnu-gcc") _version_check_aarch64_linux_gnu_gcc ;;
    "boost") _version_check_boost ;;
    "cli11") _version_check_cli11 ;;
    "cmake") _version_check_cmake ;;
    "dtc" | "device-tree-compiler") _version_check_device_tree_compiler ;;
    "eigen3") _version_check_eigen3 ;;
    "fmt") _version_check_fmt ;;
    "gcc") _version_check_gcc ;;
    "glog") _version_check_glog ;;
    "gnome") _version_check_gnome ;;
    "go") _version_check_go ;;
    "grpc") _version_check_grpc ;;
    "gtest") _version_check_gtest ;;
    "g++") _version_check_gpp ;;
    "lcm") _version_check_lcm ;;
    "magic-enum") _version_check_magic_enum ;;
    "meson") _version_check_meson ;;
    "ninja") _version_check_ninja ;;
    "nlohmann-json3") _version_check_nlohmann_json3 ;;
    "node") _version_check_node ;;
    "npm") _version_check_npm ;;
    "npx") _version_check_npx ;;
    "opencv") _version_check_opencv ;;
    "opengl") _version_check_opengl ;;
    "protobuf") _version_check_protobuf ;;
    "python3") _version_check_python3 ;;
    "ros") _version_check_ros ;;
    "spdlog") _version_check_spdlog ;;
    "libsystemd") _version_check_libsystemd ;;
    "ubuntu") _version_check_ubuntu ;;
    "yaml-cpp") _version_check_yaml_cpp ;;
    *) echo -e "version check: argument \"$1\" is not supported" ;;
    esac
}

# =============================================================================
function _version_swap {
    if [[ $system = 'Darwin' ]]; then
        echo "version swap: does not work on Mac OS yet."
        return
    fi
    case $1 in
    gcc | g++ | gxx | arm-linux-gnueabi-gxx | arm-linux-gnueabihf-gxx | aarch64-linux-gnu-gcc | python3)
        sudo update-alternatives --config $1
        ;;
    *) echo -e "version swap: argument \"$1\" is not supported" ;;
    esac
}

# =============================================================================
function version {
    if [ $# -eq 0 ]; then
        _version_help
        return
    fi

    case $1 in
    check)
        if [ $# -lt 2 ]; then
            _version_help
        else
            _version_check "$2"
        fi
        ;;
    swap)
        if [ $# -lt 2 ]; then
            _version_help
        else
            _version_swap "$2"
        fi
        ;;
    *)
        echo -e 'version: "'$1'" command not supported'
        _version_help
        ;;
    esac
}

# =============================================================================
check_list+="abseil boost cli11 cmake eigen3 fmt gcc glog go grpc gtest g++ "
check_list+="lcm magic-enum meson ninja nlohmann-json3 node npm npx opencv protobuf "
check_list+="python3 ros spdlog yaml-cpp "

if [ $system = 'Linux' ]; then
    check_list+="arm-linux-gnueabi-gcc arm-linux-gnueabihf-gcc "
    check_list+="aarch64-linux-gnu-gcc arm-linux-gnueabihf-g++ "
    check_list+="dtc device-tree-compiler gnome libsystemd opengl ubuntu "
fi

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
