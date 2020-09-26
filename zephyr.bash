#!/bin/bash

# =============================================================================
function _zephyr_help()
{
    echo " "
    echo "---------------------  zephyr ------------------------"
    echo " Author      : Dingjiang Zhou"
    echo " Email       : zhoudingjiang@gmail.com "
    echo " Create Date : June 14th, 2020 "
    echo "-----------------------------------------------------"
    echo " "
    echo " TODO"
    echo " "
}

# =============================================================================
# $1: zephyr project folder, the default is ~/zephyr-project
function _zephyr_setup_sdk_0_11_4()
{
    echo -e "\n${PRP} zephyr setup sdk-0.11.4${NOC}"
    # argument parsing -------------------
    # determine Zephyr project folder
    if [ -n "$1" ] ; then
        zephyr_proj_folder="$1"
    else
        zephyr_proj_folder=~/zephyr-project
    fi
    # hard coded version number -------------------
    sdk_ver="0.11.4"

    current_folder=${PWD}

    # install dependencies ---------------------
    echo -e "\n ${GRN} install dependencies ${NOC}"
    _press_enter_or_wait_s_continue 5
    sudo apt-get update && sudo apt-get upgrade
    sudo apt-get install --no-install-recommends git cmake ninja-build gperf \
        ccache dfu-util device-tree-compiler wget \
        python3-dev python3-pip python3-setuptools \
        python3-tk python3-wheel xz-utils file \
        make gcc gcc-multilib g++-multilib libsdl2-dev

    # install latest CMake ---------------------
    # 3.17.3 (Ubuntu 18.04.4 LTS)
    # 3.18.2 (Ubuntu 20.04.1 LTS)
    echo -e "\n ${GRN} install latest CMake ${NOC}"
    _press_enter_or_wait_s_continue 5
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -
    sudo sh -c 'echo "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" >> /etc/apt/sources.list.d/kitware-latest.list'
    sudo apt-get -y update
    sudo apt-get -y install cmake

    # install west ---------------------
    echo -e "\n ${GRN} install ${YLW}west ${NOC}"
    _press_enter_or_wait_s_continue 5
    # the west installation can fail! any solution??
    pip3 install --user -U west

    # setup west path in ~/.bashrc ---------------------
    grep_west_path=$(grep "PATH:~/.local/bin" ~/.bashrc)
    if [ ! -z "$grep_west_path" ] ; then
        echo -e "\n ${YLW}west${GRN} path was set in ~/.bashrc${NOC}"
    else
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) zephyr setup: west' >> ~/.bashrc
        echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
    fi

    # find the Zephyr project path setting in ~/.bashrc ---------------------
    echo -e "\n ${GRN}find the Zephyr project path setting in ~/.bashrc ${NOC}"
    _press_enter_or_wait_s_continue 5
    zephyr_proj_path_set_str=$(grep "export ZEPHYR_PROJECT_PATH" ~/.bashrc)
    if [ ! -z "$zephyr_proj_path_set_str" ] ; then
        echo -e "\n ${GRN}ZEPHYR_PROJECT_PATH was set in ~/.bashrc${NOC}"
        # find the original path ---------------------
        pos=$(_find_a_char_in_str "$zephyr_proj_path_set_str" "=" 1)
        original_path=${zephyr_proj_path_set_str:$((pos+1)):${#zephyr_proj_path_set_str}}
        # if the original path is different with intended path, delete it 
        if [ "$original_path" != "$zephyr_proj_folder" ] ; then
            echo -e "\n ${RED}the original ZEPHYR_PROJECT_PATH is not${NOC} $zephyr_proj_folder"
            echo -e " ${RED}revise it, and delete${NOC} $original_path"
            sed -i "s|$original_path|$zephyr_proj_folder|g" ~/.bashrc
            rm -rf $original_path
        fi
    else
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) Zephyr Project path:' >> ~/.bashrc
        echo 'export ZEPHYR_PROJECT_PATH='$zephyr_proj_folder >> ~/.bashrc
    fi

    # delete zephyr project folder and start from scratch, or ---------------------
    # update it by using west
    if [ -d "$zephyr_proj_folder" ] ; then
        echo -e "\n ${GRN}Zephyr pojrect folder already exists, do you want to delete it? [Yes/No]${NOC}"
        read asw
        if [[ ("$asw" = 'y') || ("$asw" = 'Y') || ("$asw" = 'YES') || \
              ("$asw" = 'Yes') || ("$asw" = 'yes') ]] ; then
            # delete the zephyr project folder, and get it from scratch
            echo -e "\n ${GRN}delete the Zephyr Project folder at $zephyr_proj_folder${NOC}"
            echo -e " ${GRN}get it using ${YLW}west${GRN} from scratch${NOC}"
            sudo rm -rf $zephyr_proj_folder
        elif [[ ("$asw" = 'n') || ("$asw" = 'N') || ("$asw" = 'NO') || \
                ("$asw" = 'No') || ("$asw" = 'no') ]] ; then
            echo -e "\n ${GRN}DO NOT delete the Zephyr Project folder at $zephyr_proj_folder${NOC}"
            echo -e " ${GRN}upgrade it using ${YLW}west${NOC}"
        else
            echo -e "\n ${RED}wrong answer, quit.${NOC}"
            return
        fi
    fi
    
    # use west to initialize the zephyr --------------------
    # if west is freshly installed, it cannot find the west
    echo -e "\n ${GRN}use ${YLW}west${GRN} to initialize the Zephyr Project folder${NOC}"
    _press_enter_or_wait_s_continue 10
    PATH="$PATH:~/.local/bin"
    west init $zephyr_proj_folder
    cd $zephyr_proj_folder
    west update

    # Export a Zephyr CMake package (don't understand this) --------------------
    west zephyr-export
    
    # install some required package by pip3 --------------------
    echo -e "\n ${GRN}install required Python3 packages${NOC}"
    _press_enter_or_wait_s_continue 10
    pip3 install --user -r $zephyr_proj_folder/zephyr/scripts/requirements.txt

    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # install the toolchain ---------------------------------
    cd ~ && mkdir -p soft/ &&  cd soft/

    # get the Zephyr SDK ---------------------------------
    echo -e "\n ${GRN} get the Zephyr SDK${NOC}"
    _press_enter_or_wait_s_continue 20
    zephyr_sdk=zephyr-sdk-$sdk_ver-setup.run
    if [ -f "$zephyr_sdk" ] ; then
        md5checksum=$(md5sum $zephyr_sdk)
        echo "md5checksum = "$md5checksum
    fi
    if [[ "$md5checksum" = *"ca6cc42573f6548cf936b2a60df9a125"* ]] ; then
        echo -e "\n${GRN} file exists, no need to download again${NOC}"
    else
        echo -e "\n${GRN} file does not exist, need to download it${NOC}"
        sdk_rul=https://github.com/zephyrproject-rtos/sdk-ng/releases
        wget $sdk_rul/download/v$sdk_ver/$zephyr_sdk
    fi
    chmod +x $zephyr_sdk
    
    # choose a place to install ---------------------------------
    echo -e "\n ------------------------------"
    echo -e " ${GRN}Which location are you going to install the Zephyr SDK?${NOC}"
    echo -e " 1: ~/zephyr-sdk-$sdk_ver"
    echo -e " 2: ~/.local/zephyr-sdk-$sdk_ver"
    echo -e " 3: ~/.local/optzephyr-sdk-$sdk_ver"
    echo -e " 4: ~/bin/zephyr-sdk-$sdk_ver"
    echo -e " 5: /opt/zephyr-sdk-$sdk_ver"
    echo -e " 6: /usr/zephyr-sdk-$sdk_ver"
    echo -e " 7: /usr/local/zephyr-sdk-$sdk_ver"

    zephyr_sdk_folder=" "
    while [[ "$zephyr_sdk_folder" = " " ]] ; do
        echo -e "${GRN} please enter a number from 1 to 7:${NOC}"
        read asw
        case "$asw" in
            "1")
            zephyr_sdk_folder="${HOME}/zephyr-sdk-$sdk_ver"
            ;;
            "2")
            zephyr_sdk_folder="${HOME}/.local/zephyr-sdk-$sdk_ver"
            ;;
            "3")
            zephyr_sdk_folder="${HOME}/.local/opt/zephyr-sdk-$sdk_ver"
            ;;
            "4")
            zephyr_sdk_folder="${HOME}/bin/zephyr-sdk-$sdk_ver"
            ;;
            "5")
            zephyr_sdk_folder="/opt/zephyr-sdk-$sdk_ver"
            ;;
            "6")
            zephyr_sdk_folder="/usr/zephyr-sdk-$sdk_ver"
            ;;
            "7")
            zephyr_sdk_folder="/usr/local/zephyr-sdk-$sdk_ver"
            ;;
            *)
            echo -e "\n ${RED}wrong input, try again.${NOC}"
        esac
    done

    # remove the folder, if it exists ---------------------------------
    if [ -d $zephyr_sdk_folder ] ; then
        echo -e "\n ${YLW} remove $zephyr_sdk_folder${NOC}"
        sudo rm $zephyr_sdk_folder -r
    fi
    echo -e "\n ${GRN}install the Zephyr SDK ${NOC}"
    _press_enter_or_wait_s_continue 10
    ./$zephyr_sdk -- -d $zephyr_sdk_folder

    # install the default udev rule ---------------------------------
    echo -e "\n ${GRN}setup udev rule${NOC}"
    _press_enter_or_wait_s_continue 10
    udev_rule_path="sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib"
    sudo cp "${zephyr_sdk_folder}/$udev_rule_path/60-openocd.rules" /etc/udev/rules.d
    sudo udevadm control --reload

    echo -e "\n ${GRN}reset ZEPHYR_SDK_PATH in ~/.bashrc${NOC}"
    _press_enter_or_wait_s_continue 10
    zephyr_sdk_path_set_str=$(grep "export ZEPHYR_SDK_PATH" ~/.bashrc)
    if [ ! -z "$zephyr_sdk_path_set_str" ] ; then
        pos=$(_find_a_char_in_str "$zephyr_sdk_path_set_str" "=" 1)
        original_path=${zephyr_sdk_path_set_str:$((pos+1)):${#zephyr_sdk_path_set_str}}
        if [ "$original_path" != "$zephyr_sdk_folder" ] ; then
            sudo rm -rf $original_path
            sed -i "s|$original_path|$zephyr_sdk_folder|g" ~/.bashrc
        fi
    else
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) Zephyr SDK path:' >> ~/.bashrc
        echo 'export ZEPHYR_SDK_PATH='$zephyr_sdk_folder >> ~/.bashrc
    fi

    echo -e "\n ${GRN}try the following commands to verify installation${NOC}"
    echo -e "  cd $zephyr_proj_folder/zephyr/"
    echo -e "  west build -p auto -b nucleo_f767zi samples/basic/blinky"
    echo -e "  west flash\n"
    echo -e "\n ${GRN}or you can try tab-completable ${YLW}djtools${GRN} command:${NOC}"
    echo -e "  cd $zephyr_proj_folder/zephyr/samples/basic/blinky"
    echo -e "  zephyr build -b nucleo_f767zi"
    echo -e "  zephyr flash\n"

    # ------------------------------
    cd $current_folder
    unset current_folder
}

# =============================================================================
function _zephyr_build_help()
{
    echo -e "\n ------------ zephyr build (simplified tool) --------------"
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
function _zephyr_build_old()
{
    if [ $# = 0 ] ; then
        if [ -d build ] ; then
            cmake -B build -GNinja
            ninja -C build
            return
        fi
        echo -e "\n no previous build, need a target board to build, for example:"
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
# echo -e "\n Try the following commands to verify installation"
#     echo -e "  cd $zephyr_proj_folder/zephyr/"
#     echo -e "  west build -p auto -b nucleo_f767zi samples/basic/blinky\n"
# the new build function: copy everything into $zephyr_proj_folder/zephyr/
# $1: -b
# $2: board
function _zephyr_build_new()
{
    # find the board --------------
    board=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    if [ -z $board ] ; then
        echo -e "\n ${RED}target board is not assigned, exit.${NOC}\n"
        echo    " you can assign it by (tab-completable):"
        echo -e "   zephyr -build -b [board name]\n"
        return
    fi

    # check environment --------------
    if [ -z $ZEPHYR_PROJECT_PATH ] ; then
        echo -e "\n ${RED}ZEPHYR_PROJECT_PATH is not set, exit.${NOC}\n"
        return
    fi
    project_path=${PWD}
    project_name=$(basename "$project_path")

    # remove build folder in current project
    rm -rf build

    # to build ------
    cd $ZEPHYR_PROJECT_PATH/zephyr/
    # if the current build board or project name is different with previous one
    if [ -f build/board.txt ] ; then
        prv_board=$(cat build/board.txt)
    else
        prv_board=" "
    fi
    if [ -f build/project-name.txt ] ; then
        prv_project=$(cat build/project-name.txt)
    else
        prv_project=" "
    fi
    if [[ $prv_board != $board ]] || [[ $prv_project != $project_name ]] ; then
        echo -e "\n ${GRN}different board or project,${NOC} build from scratch ...\n"
        rm -rf build/*
        # rm build/CMakeCache.txt
        # rm build/CMakeFiles -rf
    else
        echo -e "\n same board and project ...\n"
    fi
    # build
    west build -p auto -b $board $project_path
    # record current build board, and project name
    echo "$board" > $ZEPHYR_PROJECT_PATH/zephyr/build/board.txt
    echo "$project_name" > $ZEPHYR_PROJECT_PATH/zephyr/build/project-name.txt

    # copy the build/ to current project path ------
    cp build -rf $project_path

    cd ${project_path}
}

# =============================================================================
function _zephyr_flash_help()
{
    echo -e "\n ------------ zephyr flash (simplified tool) --------------"
    echo "   maitainer: Dingjiang Zhou "
    echo -e " ----------------------------------------------------------\n"
    echo "supported commands:"
    echo -e " zephyr flash\n"
}

# =============================================================================
# todo: if the $ZEPHYR_PROJECT_PATH/zephyr/ is older, then rebuild
function _zephyr_flash()
{
    project_path=${PWD}
    project_name=$(basename "$project_path")
    
    # if no build directory, need to build --------
    cd $ZEPHYR_PROJECT_PATH/zephyr/
    if [ ! -d build ] ; then
        echo -e "\n${RED} no build directory, need to build ... ${NOC}\n"
        return
    fi
    # only if the current project is just build, then flash --------
    
    if [ -f build/project-name.txt ] ; then
        prv_project=$(cat build/project-name.txt)
    else
        echo -e "\n ${RED}project not built, need to build ...${NOC}\n"
        return
    fi
    if [[ $prv_project != $project_name ]] ; then
        echo -e "\n ${RED}different project, need to rebuild ...${NOC}\n"
        cd ${project_path}
        return
    else
        # to flash --------
        board=$(cat build/board.txt)
        echo -e "\n the build target board is ${GRN}${board}${NOC}\n"
        west flash
    fi

    cd ${project_path}
}

# =============================================================================
function zephyr()
{
    current_folder=${PWD}

    # ------------------------------
    if [ $# -eq 0 ] ; then
        _zephyr_help
        return
    fi

    # ------------------------------
    if [ $1 = 'setup' ] ; then
        if [ $2 = 'sdk-0.11.4' ] ; then
            _zephyr_setup_sdk_0_11_4 $3 $4 $5 $6
            return
        fi
        return
    fi
    if [ $1 = 'build' ] ; then
        _zephyr_build_new $2 $3 $4 $5 $6 $7 $8 $9 ${10}
        return
    fi
    if [ $1 = 'flash' ] ; then
        _zephyr_flash $2 $3 $4 $5 $6 $7 $8 $9 ${10}
        return
    fi

    echo -e '\r\n zephyr : "'$1 '"command not supported\r\n'
    _zephyr_help

    # ------------------------------
    cd $current_folder
    unset current_folder
}

# =============================================================================
function _zephyr()
{
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
    for i in $supported_boards ; do
        ACTIONS[$i]=" "
    done

    # ------------------------------------------------------------------------
    ACTIONS[setup]+="sdk-0.11.4 "
    ACTIONS[sdk-0.11.4]=" "

    # ------------------------------------------------------------------------
    ACTIONS[flash]=" "
    
    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================
complete -F _zephyr zephyr
