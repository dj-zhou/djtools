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
    current_folder=${PWD}

    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install --no-install-recommends git cmake ninja-build gperf \
        ccache dfu-util device-tree-compiler wget \
        python3-dev python3-pip python3-setuptools \
        python3-tk python3-wheel xz-utils file \
        make gcc gcc-multilib g++-multilib libsdl2-dev

    # install CMakie 3.17.3 (Ubuntu 18.04.4 LTS)
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | sudo apt-key add -
    sudo sh -c 'echo "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" >> /etc/apt/sources.list.d/kitware-latest.list'

    sudo apt-get -y update
    sudo apt-get -y install cmake

    # install west
    pip3 install --user -U west
    # the west installation can fail!

    west_path_set=0
    while IFS='' read -r line || [[ -n "$line" ]] ; do
        if [[ $line == *"PATH=~/.local/bin:"* ]] ; then
            west_path_set=1
        fi
    done < ~/.bashrc

    if [ $west_path_set = 0 ] ; then
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) zephyr setup: west' >> ~/.bashrc
        echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
    fi

    # use west to get Zephyr source code
    if [ -n "$1" ] ; then
        zephyr_proj_folder="$1"
    else
        zephyr_proj_folder=~/zephyr-project
    fi

    # to search "ZEPHYR_PROJECT_PATH" in ~/.bashrc file to find the original
    # zephyr_proj_folder location, if does not match, remove it, and install
    # to the new location, and delete the line in ~/.bashrc ; if match, will 
    # not delete it, but update it.

    zephyr_proj_path_set=0
    while IFS='' read -r line || [[ -n "$line" ]] ; do
        if [[ $line == *"export ZEPHYR_PROJECT_PATH"* ]] ; then
            zephyr_proj_original_path_line=$line
            zephyr_proj_path_set=1
        fi
    done < ~/.bashrc

    pos=$(_find_a_char_in_str "$zephyr_proj_original_path_line" "=" 1)
    zephyr_proj_original_path=${zephyr_proj_original_path_line:$((pos+1)):${#zephyr_proj_original_path_line}}
    echo "zephyr_proj_original_path = "$zephyr_proj_original_path 
    echo "zephyr_proj_folder = "$zephyr_proj_folder

    if [[ $zephyr_proj_path_set = 1 ]] ; then
        if [[ $zephyr_proj_original_path != $zephyr_proj_folder ]] ; then
            sed -i "s%"$zephyr_proj_original_path"%"$zephyr_proj_folder"%g" ~/.bashrc
            # must delete the original folder
            rm -rf $zephyr_proj_original_path
        fi
    fi

    if [ $zephyr_proj_path_set = 0 ] ; then
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) Zephyr Project path:' >> ~/.bashrc
        echo 'export ZEPHYR_PROJECT_PATH='$zephyr_proj_folder >> ~/.bashrc
    fi

    if [ -d $zephyr_proj_folder ] ; then
        echo -e "zephyr pojrect fodler already exists, do you want to delete it? [Yes/No]\r\n"
        read asw
        if [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || ($asw = 'Yes') || ($asw = 'yes') ]] ; then
            sudo rm -rf $zephyr_proj_folder
        elif [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') || ($asw = 'No') || ($asw = 'no') ]] ; then
            init_zephyr_proj=0
        else
            echo -e "wrong answer, quit.\r\n"
            return
        fi
    fi
    
    # use west to initialize the zephyr --------------------
    # if west is freshly installed, it cannot find the west
    PATH="~/.local/bin:"$PATH
    west init $zephyr_proj_folder
    cd $zephyr_proj_folder
    west update

    # Export a Zephyr CMake package (don't understand this)
    west zephyr-export
    
    # install some required package by pip3
    pip3 install --user -r $zephyr_proj_folder/zephyr/scripts/requirements.txt

    #install the toolchain ---------------------------------
    cd ~ && mkdir -p soft/ &&  cd soft/

    sdk_ver="0.11.4"
    zephyr_sdk=zephyr-sdk-$sdk_ver-setup.run
    if [[ -f $zephyr_sdk ]] ; then
        md5checksum=`md5sum $zephyr_sdk`
        echo "md5checksum = "$md5checksum
    fi
    if [[ "$md5checksum" = *"15e003c49acc282c95cdf7543023f53d"* ]] ; then
        echo "file exists, no need to download again"
    else
        sdk_rul=https://github.com/zephyrproject-rtos/sdk-ng/releases
        wget $sdk_rul/download/v$sdk_ver/$zephyr_sdk
    fi
    chmod +x $zephyr_sdk

    echo -e "\n------------------------\nWhich location are you going to install the Zephyr SDK?"
    echo -e "1: ~/zephyr-sdk-$sdk_ver"
    echo -e "2: ~/.local/zephyr-sdk-$sdk_ver"
    echo -e "3: ~/.local/optzephyr-sdk-$sdk_ver"
    echo -e "4: ~/bin/zephyr-sdk-$sdk_ver"
    echo -e "5: /opt/zephyr-sdk-$sdk_ver"
    echo -e "6: /usr/zephyr-sdk-$sdk_ver"
    echo -e "7: /usr/local/zephyr-sdk-$sdk_ver"

    zephyr_sdk_folder=" "
    while [[ $zephyr_sdk_folder = " " ]] ; do
        echo -e "please enter a number from 1 to 7:"
        read asw
        case $asw in
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
            echo "wrong input."
        esac
    done

    # remove the folder, if it exists
    if [ -d $zephyr_sdk_folder ] ; then
        sudo rm $zephyr_sdk_folder -r
    fi
    ./$zephyr_sdk -- -d $zephyr_sdk_folder

    # install the default udev rule
    sudo cp ${zephyr_sdk_folder}/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
    sudo udevadm control --reload

    zephyr_sdk_path_set=0
    while IFS='' read -r line || [[ -n "$line" ]] ; do
        if [[ $line == *"export ZEPHYR_SDK_PATH"* ]] ; then
            zephyr_sdk_original_path_line=$line
            zephyr_sdk_path_set=1
        fi
    done < ~/.bashrc

    if [ $zephyr_sdk_path_set = 1 ] ; then
        pos=$(_find_a_char_in_str "$zephyr_sdk_original_path_line" "=" 1)
        zephyr_sdk_original_path=${zephyr_sdk_original_path_line:$((pos+1)):${#zephyr_sdk_original_path_line}}
        echo "zephyr_sdk_original_path = "$zephyr_sdk_original_path 
        echo "zephyr_sdk_folder = "$zephyr_sdk_folder
        if [ $zephyr_sdk_original_path != $zephyr_sdk_folder ] ; then
            sudo rm -rf $zephyr_sdk_original_path
            sed -i "s%"$zephyr_sdk_original_path"%"$zephyr_sdk_folder"%g" ~/.bashrc
        fi
    fi

    if [ $zephyr_sdk_path_set = 0 ] ; then
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) Zephyr SDK path:' >> ~/.bashrc
        echo 'export ZEPHYR_SDK_PATH='$zephyr_sdk_folder >> ~/.bashrc
    fi

    echo -e "\nTry the following commands to verify installation"
    echo -e "  cd $zephyr_proj_folder/zephyr/"
    echo -e "  west build -p auto -b nucleo_f767zi samples/basic/blinky\n"
    # ------------------------------
    cd $current_folder
    unset current_folder
}

# =============================================================================
function _zephyr_build_help()
{
    echo -e "\n------------ zephyr build (simplified tool) --------------"
    echo "  maitainer: Dingjiang Zhou "
    echo -e "----------------------------------------------------------\n"
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
# echo -e "\nTry the following commands to verify installation"
#     echo -e "  cd $zephyr_proj_folder/zephyr/"
#     echo -e "  west build -p auto -b nucleo_f767zi samples/basic/blinky\n"
# the new build function: copy everything into $zephyr_proj_folder/zephyr/
# $1: -b
# $2: board
function _zephyr_build_new1()
{
    board=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    if [ -z $ZEPHYR_PROJECT_PATH ] ; then
        echo -e "\n ZEPHYR_PROJECT_PATH is not set, exit.\n"
    fi
    project_path=${PWD}
    project_name=`basename "$project_path"`
    echo "project_path = "$project_path
    echo "project_name = "$project_name
    
    # remove build in current project path -----
    rm -rf build

    # copy source file to zephyr project path ------
    rm -rf $ZEPHYR_PROJECT_PATH/zephyr/$project_name
    cp -rf $project_path $ZEPHYR_PROJECT_PATH/zephyr/

    # go there and compile ------
    cd $ZEPHYR_PROJECT_PATH/zephyr/$project_name
    
    west build -p auto -b $board
    
    # if successful (how to check?), copy build folder to current project path
    mv build $project_path
    rm -rf $ZEPHYR_PROJECT_PATH/zephyr/$project_name

    cd ${project_path}
}

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
    project_name=`basename "$project_path"`

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
    echo -e "\n------------ zephyr flash (simplified tool) --------------"
    echo "  maitainer: Dingjiang Zhou "
    echo -e "----------------------------------------------------------\n"
    echo "supported commands:"
    echo -e " zephyr flash\n"
}

# =============================================================================
# todo: if the $ZEPHYR_PROJECT_PATH/zephyr/ is older, then rebuild
function _zephyr_flash()
{
    project_path=${PWD}
    project_name=`basename "$project_path"`
    
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
        echo -e "\n  the build target board is ${GRN}${board}${NOC}\n"
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

    echo -e '\r\nzephyr : "'$1 '"command not supported\r\n'
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
        setup
        build
        flash
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    ACTIONS[setup]+="sdk-0.11.4 "
    ACTIONS[sdk-0.11.4]=" "
    # ACTIONS[build]="-b "
    ACTIONS[flash]=" "
    # ACTIONS[stm32]=" "

    # supported boards, can be added here
    ACTIONS[-b]+="nucleo_f767zi "
    ACTIONS[nucleo_f767zi]=" "
    
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
