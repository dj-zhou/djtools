#!/bin/bash

# =============================================================================
function _zephyr_help() {
    cat <<eom
TODO
eom
}

# =============================================================================
function _zephyr_setup_help() {
    cat <<eom
zephyr setup: 
  -- sdk             - Setup Zephyr SDK and official zephyr project directory
  -- zephyr-project  - Setup Zephyr project directory (official workspace)
eom
}

# =============================================================================
# default SDK directory: $HOME/.local/zephyr-sdk-0.15.2
# https://docs.zephyrproject.org/latest/develop/getting_started/index.html
function _zephyr_setup_sdk() {
    local sdk_v=$(_find_package_version zephyr-sdk)
    _echo_install zephyr v$sdk_v

    # argument parsing -------------------
    # determine Zephyr project directory
    if [ -n "$1" ]; then
        zephyr_proj_folder="$1"
    else
        zephyr_proj_folder=~/zephyr-project
    fi

    # install dependencies ---------------------
    echo_info "install dependencies"
    _press_enter_or_wait_s_continue 5
    # _show_and_run sudo apt-get -y update
    # _show_and_run sudo apt-get -y upgrade
    _show_and_run _install_if_not_installed git cmake ninja-build gperf
    _show_and_run _install_if_not_installed ccache dfu-util wget
    _show_and_run _install_if_not_installed python3-dev python3-pip python3-setuptools
    _show_and_run _install_if_not_installed python3-tk python3-wheel xz-utils file
    _show_and_run _install_if_not_installed make gcc gcc-multilib g++-multilib libsdl2-dev

    # check minimum requirements ---------------------
    local cmake_v=$(version check cmake)
    anw=$(_version_if_ge_than $cmake_v 3.20.5)
    if [ "$anw" = 'no' ]; then
        _show_and_run dj setup cmake
    fi
    local python3_v=$(version check python3)
    anw=$(_version_if_ge_than $python3_v 3.8)
    if [ "$anw" = 'no' ]; then
        _show_and_run dj setup python3.10
    fi
    local dtc_v=$(version check dtc)
    anw=$(_version_if_ge_than $dtc_v 1.4.6)
    if [ "$anw" = 'no' ]; then
        _show_and_run dj setup device-tree-compiler
    fi
    return
    # install west ---------------------
    echo_info "install ${INFO}west${NOC}"
    _press_enter_or_wait_s_continue 5
    _show_and_run pip3 install --user -U west

    # setup west path ---------------------
    local west_path=$(grep "PATH:~/.local/bin" ~/.bashrc)
    if [ ! -z "$west_path" ]; then
        echo -e "${INFO}west${NOC} path was set in ~/.bashrc"
    else
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) west path setup' >>~/.bashrc
        echo -e 'export PATH=$PATH:~/.local/bin\n' >>~/.bashrc
    fi
    echo -e "${INFO}west${NOC} is installed to ${INFO}${HOME}/.local/bin${NOC}"

    # ready to download the sdk files ---------------------
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $HOME/.local
    _show_and_run cd $HOME/.local

    # download sdk bundle ---------------------
    local sdk_url="https://github.com/zephyrproject-rtos/sdk-ng/releases/download"
    local file="zephyr-sdk-${sdk_v}_linux-x86_64.tar.gz"
    _show_and_run rm -rf sha256.sum
    _show_and_run wget "$sdk_url/v$sdk_v/sha256.sum"
    local read_checksum=$(cat sha256.sum | grep $file | awk '{print $1}')
    if [ -f $file ]; then
        echo -e "calculating sha256sum value for ${INFO}$file${NOC} ..."
        local check_checksum=$(sha256sum zephyr-sdk-${sdk_v}_linux-x86_64.tar.gz | awk '{print $1}')
        if [ "$check_checksum" = "$read_checksum" ]; then
            echo_info "$file exists, do not need to download again."
        else
            echo_info "$file exists, but sha256sum does not match, need to download again."
            wget "$sdk_url/v$sdk_v/zephyr-sdk-${sdk_v}_linux-x86_64.tar.gz"
        fi
    fi

    # extract the sdk file ---------------------
    local sdk_dir="zephyr-sdk-$sdk_v"
    _show_and_run rm -rf $sdk_dir
    _show_and_run tar xvf $file

    # setup ---------------------
    _show_and_run cd $sdk_dir
    _show_and_run ./setup.sh

    # udev rule ---------------------
    _show_and_run sudo cp $HOME/.local/zephyr-sdk-${sdk_v}/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rule.d/
    _show_and_run sudoo udevadm control --reload

    # lastly
    _popd_quiet
}

# =============================================================================
function _zephyr_setup_zephyr_project() {
    echo -e "setup an official zephyr project or workspace using ${INFO}west${NOC}"
    echo -e "setup to directory ${INFO}${HOME}/zephyr-project${NOC}"
    _press_enter_or_wait_s_continue 5
    local zephyr_proj_dir="${HOME}/zephyr-project"
    if [ ! -d $zephyr_proj_dir ]; then
        _show_and_run west init $zephyr_proj_dir
    fi
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run cd $zephyr_proj_dir
    _show_and_run west update

    _popd_quiet
}

# =============================================================================
function _zephyr_build_help() {
    echo -e "------------ zephyr build (simplified tool) --------------"
    echo "  maitainer: Dingjiang Zhou "
    echo -e " ----------------------------------------------------------\n"
    echo "supported commands:"
    echo " zephyr build -b <board> [-G <make tool>]"
    echo " - <board> "
    echo "   supported boards. includes the following: "
    echo "      nucleo_f767zi"
    echo "      ..."
    echo " - <make tool>"
    echo "   ninja or cmake, or west (wip)"
    echo -e "   the default tool is ninja\n"
}

# =============================================================================
# usage:
# zephyr build -b nucleo_f767zi
# todo: add -G option to choose between ninja and cmake, and even west
# todo: use -DBOARD_ROOT to specify the path of the custom board repository
# todo: use -DDTS_ROOT to specify the path of the DeviceTree (a repository)

# update:
# if there is no build folder, must use -b option and assign a build target board
# if there is a build folder: 1) if no -b option used, then just build; 2) if -b
# option is used, then ALWAYS delete the build folder and rebuild from scratch

# the old fucntion has some problem due to environment setup, keep it until it is
# solved
function _zephyr_build_old() {
    if [ $# = 0 ]; then
        if [ -d build ]; then
            cmake -B build -GNinja
            ninja -C build
            return
        fi
        echo -e "no previous build, need a target board to build, for example:"
        echo -e " zephyr build -b nucleo_f767zi\n"
        return
    fi
    # search the arguments to find the board name
    board=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    rm -rf build/
    # echo "board = "$board
    # the default build tool is ninja
    cmake -B build -GNinja -DBOARD=$board .
    ninja -C build
}

# =============================================================================
# echo -e "Try the following commands to verify installation"
#     echo -e "  cd $zephyr_proj_folder/zephyr/"
#     echo -e "  west build -p auto -b nucleo_f767zi samples/basic/blinky\n"
# the new build function: copy everything into $zephyr_proj_folder/zephyr/
# $1: -b
# $2: board
function _zephyr_build_new() {
    # find the board --------------
    board=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    if [ -z $board ]; then
        echo -e "${RED}target board is not assigned, exit.${NOC}\n"
        echo " you can assign it by (tab-completable):"
        echo -e "   zephyr -build -b [board name]\n"
        return
    fi

    # check environment --------------
    if [ -z $ZEPHYR_PROJECT_PATH ]; then
        echo -e "${RED}ZEPHYR_PROJECT_PATH is not set, exit.${NOC}\n"
        return
    fi
    project_path=${PWD}
    project_name=$(basename "$project_path")

    # remove build folder in current project
    rm -rf build

    # to build ------
    cd $ZEPHYR_PROJECT_PATH/zephyr/
    # if the current build board or project name is different with previous one
    if [ -f build/board.txt ]; then
        prv_board=$(cat build/board.txt)
    else
        prv_board=" "
    fi
    if [ -f build/project-name.txt ]; then
        prv_project=$(cat build/project-name.txt)
    else
        prv_project=" "
    fi
    if [[ $prv_board != $board ]] || [[ $prv_project != $project_name ]]; then
        echo -e "${INFO}different board or project,${NOC} build from scratch ...\n"
        rm -rf build/*
        # rm build/CMakeCache.txt
        # rm build/CMakeFiles -rf
    else
        echo -e "same board and project ...\n"
    fi
    # build
    west build -p auto -b $board $project_path
    # record current build board, and project name
    echo "$board" >$ZEPHYR_PROJECT_PATH/zephyr/build/board.txt
    echo "$project_name" >$ZEPHYR_PROJECT_PATH/zephyr/build/project-name.txt

    # copy the build/ to current project path ------
    cp build -rf $project_path

    cd ${project_path}
}

# =============================================================================
function _zephyr_flash_help() {
    echo -e "------------ zephyr flash (simplified tool) --------------"
    echo "   maitainer: Dingjiang Zhou "
    echo -e " ----------------------------------------------------------\n"
    echo "supported commands:"
    echo -e " zephyr flash\n"
}

# =============================================================================
# todo: if the $ZEPHYR_PROJECT_PATH/zephyr/ is older, then rebuild
function _zephyr_flash() {
    project_path=${PWD}
    project_name=$(basename "$project_path")

    # if no build directory, need to build --------
    cd $ZEPHYR_PROJECT_PATH/zephyr/
    if [ ! -d build ]; then
        echo -e "\n${RED} no build directory, need to build ... ${NOC}\n"
        return
    fi
    # only if the current project is just build, then flash --------

    if [ -f build/project-name.txt ]; then
        prv_project=$(cat build/project-name.txt)
    else
        echo -e "${RED}project not built, need to build ...${NOC}\n"
        return
    fi
    if [[ $prv_project != $project_name ]]; then
        echo -e "${RED}different project, need to rebuild ...${NOC}\n"
        cd ${project_path}
        return
    else
        # to flash --------
        board=$(cat build/board.txt)
        echo -e "the build target board is ${INFO}${board}${NOC}\n"
        west flash
    fi

    cd ${project_path}
}

# =============================================================================
function zephyr() {
    cur_dir=${PWD}

    # ------------------------------
    if [ $# -eq 0 ]; then
        _zephyr_help
        return
    fi

    # ------------------------------
    if [ $1 = 'setup' ]; then
        if [ $2 = 'sdk' ]; then
            shift 2
            _zephyr_setup_sdk "$@"
            return
        fi
        if [ $2 = 'zephyr-project' ]; then
            shift 2
            _zephyr_setup_zephyr_project "$@"
            return
        fi
        _zephyr_setup_help
        return
    fi
    if [ $1 = 'build' ]; then
        shift 1
        _zephyr_build_new "$@"
        return
    fi
    if [ $1 = 'flash' ]; then
        shift 1
        _zephyr_flash "$@"
        return
    fi

    echo -e '\rzephyr : "'$1 '"command not supported\r\n'
    _zephyr_help

    # ------------------------------
    cd $cur_dir
    unset cur_dir
}

# =============================================================================
function _zephyr_linux() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        build
        flash
        setup
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    ACTIONS[build]+=" "

    # supported boards, can be added here --------------------
    supported_boards+="nucleo_f767zi "
    ACTIONS[-b]="$supported_boards "
    for i in $supported_boards; do
        ACTIONS[$i]=" "
    done

    # ------------------------------------------------------------------------
    setup_list="sdk zephyr-project "
    ACTIONS[setup]+="$setup_list "
    for i in $setup_list; do
        ACTIONS[$i]=" "
    done

    # ------------------------------------------------------------------------
    ACTIONS[flash]=" "

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
if [ $system = 'Linux' ]; then
    complete -F _zephyr_linux zephyr
# elif [ $system = 'Darwin' ]; then
#     echo "todo"
fi
