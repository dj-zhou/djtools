#!/bin/bash

# =============================================================================
# it only supports meson build for now
# problem:
# on Ubuntu 18.04, the SDK .appolo-image-wandboard-poky-2.6.4-oesdk does not work!
# it still says native build (meson/ninja)
function _build_meson_cross() { # sdk_path
    echo -e "${CYN}meson.build (cross)${NOC} ..."
    if [ $# -lt 1 ]; then
        echo "build meson-cross: need the sdk path, or \"clean\" target."
        return
    fi
    if [ $1 = "clean" ]; then
        _show_and_run rm "_bcross"* -rf
        return
    fi
    _save_current_env_variables

    cur_dir=${PWD}
    # the path is determined by command:
    #    yocto setup plain-sdk
    machine_name=$(ls ${HOME}/$1-oesdk)
    distro_name=$(ls ${HOME}/$1-oesdk/$machine_name)

    sdk_path="${HOME}/$1-oesdk/$machine_name/$distro_name"
    sdk_output="_bcross$1"
    sdk_env_set=$(ls $sdk_path | grep environment)

    # ------------------------------------------------------------------
    # ------------------------------------------------------------------
    # if "--fresh" is given explicitly, build it freshly
    if [ -n "$2" ] && [ $2 = '--fresh' ]; then

        # source the environment variables --------------------
        unset LD_LIBRARY_PATH
        echo "source $sdk_path/$sdk_env_set"
        source $sdk_path/$sdk_env_set

        directory_name=$(basename "${PWD}")

        # if the curent directory contains the $sdk_output directory, then
        # rm $sdk_output -r
        # meson build && cd build && ninja
        if [ -d $sdk_output ]; then
            rm $sdk_output/ -rf
            meson . $sdk_output -Db_sanitize=none
            cd $sdk_output
            ninja
            echo -e " fresh build: directory \"${CYN}$sdk_output${NOC}\" exists, removed it."
            echo -e "sdk location: ${CYN}$sdk_path${NOC}"
            cd $cur_dir

        # if the curent directory is $fb2_sdk_build_directory/, then
        elif [ $directory_name = "$sdk_output" ]; then
            cd ../
            rm $sdk_output/ -rf
            meson . $sdk_output -Db_sanitize=none
            cd $sdk_output
            ninja
            echo -e " fresh build: inside directory \"${CYN}$sdk_output${NOC}\""
            echo -e "sdk location: ${CYN}$sdk_path${NOC}"

        # if in a subdirectory of $sdk_output/
        elif [[ "$cur_dir" = *"$sdk_output"* ]]; then
            sdk_build_parent_path=${cur_dir%"$sdk_output"*}
            cd $sdk_build_parent_path
            rm $sdk_output/ -rf
            meson . $sdk_output -Db_sanitize=none
            cd $sdk_output
            ninja
            echo -e " fresh build: inside a sub-directory of \"${CYN}$sdk_output${NOC}\""
            echo -e "sdk location: ${CYN}$sdk_path${NOC}"
            cd $cur_dir

        # if the current directory does not contain a $sdk_output/ directory,then
        # check if there is a meson.build file, then build
        elif [ -f meson.build ]; then
            meson . $sdk_output -Db_sanitize=none #  -Dprefix=/usr
            cd $sdk_output
            ninja
            echo -e " fresh build: create directory \"${CYN}$sdk_output${NOC}\""
            echo -e "sdk location: ${CYN}$sdk_path${NOC}"
            cd $cur_dir
        else
            echo -e " fresh build: ${RED}no meson.build file, exit!!${NOC}"
        fi
        _yocto_reset_env_variables
        rm -rf builddir # just a hack
        return
    fi

    # ------------------------------------------------------------------
    # ------------------------------------------------------------------
    # if "--fresh" is not given, it is a contiue build

    directory_name=$(basename "${PWD}")
    unset LD_LIBRARY_PATH
    source $sdk_path/$sdk_env_set
    # contains sdk_output directory
    if [ -d $sdk_output ]; then
        cd $sdk_output
        ninja

        echo -e "continue build: directory \"${CYN}$sdk_output${NOC}\" exists"
        echo -e "  sdk location: ${CYN}$sdk_path${NOC}"
        cd $cur_dir

    # just in the $sdk_output/ directory
    elif [ $directory_name = "$sdk_output" ]; then
        ninja
        echo -e "continue build: inside directory \"${CYN}$sdk_output${NOC}\""
        echo -e " sdk location: ${CYN}$sdk_path${NOC}"

    # if the current path is ~/xx/$sdk_output/yy/zz --------
    elif [[ "$cur_dir" = *"$sdk_output"* ]]; then
        sdk_build_path=${cur_dir%"$sdk_output"*}
        sdk_build_path=$sdk_build_path"$sdk_output"
        cd $sdk_build_path
        ninja
        cd $cur_dir
        echo -e "continue build: inside a sub-directory of \"${CYN}$sdk_output${NOC}\""
        echo -e "  sdk location: ${CYN}$sdk_path${NOC}"
    else
        echo -e " continue build: ${RED}failed, exit!!${NOC}"
    fi
    _yocto_reset_env_variables
    rm -rf builddir # just a hack
}

# =============================================================================
function _build_meson_native() {
    target_tag=$1
    if [[ -z "$target_tag" ]]; then
        target_tag="all"
    fi
    echo -e "${CYN}meson.build (native)${NOC}: $GRN$target_tag$NOC ..."
    proj_dir="_bnative.meson"

    if [ "$target_tag" = "clean" ]; then
        _show_and_run sudo rm -rf "$proj_dir"
        return
    fi

    if [ "$target_tag" = "test" ]; then
        _show_and_run echo "build meson-native test: todo"
        return
    fi

    if [ ! -d "$proj_dir" ]; then
        _show_and_run meson setup "$proj_dir"
    elif [ ! -f "$proj_dir/build.ninja" ]; then
        _show_and_run rm "$proj_dir" -rf
        _show_and_run meson setup "$proj_dir"

    fi
    _show_and_run _pushd_quiet "$proj_dir"
    _show_and_run ninja
    _popd_quiet
}

# =============================================================================
docker_sh_file="build-in-container"
function _build_in_docker() {
    echo -e "use ${CYN}Docker container${NOC} to build/clean ..."
    if ! [ -f "$docker_sh_file" ]; then
        echo "no $docker_sh_file file, exit."
        return
    fi
    if ! [ -f "docker/Dockerfile" ]; then
        echo "no docker/Dockerfile file, exit."
        return
    fi
    target_tag="$1"
    if [[ -z "$target_tag" || "$target_tag" = "all" ]]; then
        ./$docker_sh_file
        return
    fi
    if [[ "$target_tag" = "clean" ]]; then
        echo -e "${GRN}rm -rf _bdocker*${NOC}"
        rm -rf _bdocker*
    fi
}

# =============================================================================
# example of .project-stm32:
# STM32F107VCT6
# 256 FLASH (*1024)
#  64 RAM   (*1024)

# example output
# Memory region         Used Size  Region Size  %age Used
#            FLASH:       14644 B         2 MB      0.70%
#             DTCM:          0 GB       128 KB      0.00%
#             SRAM:        4544 B       384 KB      1.16%
#         IDT_LIST:         200 B         2 KB      9.77%

# =============================================================================
function _build_makefile() {
    target_tag=$1
    if [[ -z "$target_tag" ]]; then
        target_tag="all"
    fi
    echo -e "${CYN}Makefile${NOC}: $GRN$target_tag$NOC ..."
    if [ "$target_tag" = "clean" ]; then
        _show_and_run make clean
        return
    fi
    if [ "$target_tag" = "install" ]; then
        _show_and_run sudo make install
        return
    fi

    _show_and_run make -j$(nproc)

    # stm32 project dedicated scripts, can be moved into Makefile
    if [ ! -f .project-stm32 ] || [ ! -f bin/*.elf ]; then
        return
    fi
    micro_controller=$(grep "STM32" .project-stm32 | awk '{print $1}')
    flash_kb=$(grep "FLASH" .project-stm32 | awk '{print $1}')
    ram_kb=$(grep "RAM" .project-stm32 | awk '{print $1}')
    text_used=$(arm-none-eabi-size -B -d bin/*.elf | awk '{print $1}')
    text_used=$(echo $text_used | awk '{print $2}')
    data_used=$(arm-none-eabi-size -B -d bin/*.elf | awk '{print $2}')
    data_used=$(echo $text_used | awk '{print $2}')
    flash_percentage=$(awk "BEGIN {print ($((text_used))+$((data_used))) * 100  / $((flash_kb)) / 1024}" | awk '{printf("%d",$0);}')
    bss_used=$(arm-none-eabi-size -B -d bin/*.elf | awk '{print $3}')
    bss_used=$(echo $bss_used | awk '{print $2}')
    ram_percentage=$(awk "BEGIN {print $((bss_used)) * 100  / $((ram_kb)) / 1024}" | awk '{printf("%d",$0);}')
    echo -e "${CYN}\n------------------------------------${NOC}"
    echo -e "${micro_controller} memory usage summary\nFLASH: ${flash_percentage}%, RAM: ${ram_percentage}%\n"
}

# =============================================================================
function _build_cmake() {
    target_tag=$1
    if [[ -z "$target_tag" ]]; then
        target_tag="all"
    fi
    echo -e "${CYN}CMakeLists.txt${NOC}: $GRN$target_tag$NOC ..."
    build_dir="_bnative.cmake"
    # ---------------------------------------------------
    if [[ "$target_tag" = "all" ]]; then
        if [ ! -d "$build_dir" ]; then
            _show_and_run mkdir -p "$build_dir"
            _show_and_run _pushd_quiet "$build_dir"
            _show_and_run cmake ..
        else
            _show_and_run _pushd_quiet "$build_dir"
            _show_and_run cmake ..
        fi
        _show_and_run make -j$(nproc)
        _popd_quiet
        return
    fi
    # ---------------------------------------------------
    if [ "$target_tag" = "clean" ]; then
        _show_and_run sudo rm -rf "$build_dir"
        return
    fi
    # ---------------------------------------------------
    if [ "$target_tag" = "install" ]; then
        if [ ! -d "$build_dir" ]; then
            _show_and_run mkdir -p "$build_dir"
            _show_and_run _pushd_quiet "$build_dir"
            _show_and_run cmake ..
            _show_and_run make -j$(nproc)
            _show_and_run sudo make install
        else
            _show_and_run _pushd_quiet "$build_dir"
            _show_and_run sudo make install
        fi
        _popd_quiet
        return
    fi
    # # ---------------------------------------------------
    if [ "$target_tag" = "test" ]; then
        if [ -d $build_dir ]; then
            _show_and_run _pushd_quiet $build_dir
            _show_and_run make test
            _popd_quiet
        fi
    fi
}

# =============================================================================
function compile_template() {
    if [ $1 = '--cmake' ]; then
        cp $djtools_path/compile-template/CMakeLists.txt-native ./CMakeLists.txt
        return
    fi
    if [ $1 = '--stm32' ]; then
        if [ ! -f $djtools_path/compile-template/Makefile-stm32$2 ]; then
            echo "Makefile for $2 does not exist, exit!"
            return
        fi
        if [ ! -f $djtools_path/compile-template/.project-stm32$2 ]; then
            echo ".project-stm32 for $2 does not exist, exit!"
            return
        fi
        cp $djtools_path/compile-template/Makefile-stm32$2 ./Makefile
        cp $djtools_path/compile-template/.project-stm32$2 ./.project-stm32
        return
    fi
}

# =============================================================================
function build() {
    # ------------------------------
    if [ $1 = 'cmake' ]; then
        shift 1
        _build_cmake "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'docker' ]; then
        shift 1
        _build_in_docker "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'make' ]; then
        shift 1
        _build_makefile "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'meson-cross' ]; then

        shift 1
        _build_meson_cross "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'meson-native' ]; then
        shift 1
        _build_meson_native "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'template' ]; then
        shift 1
        compile_template "$@"
        return
    fi
    echo -e "${GRN}build${NOC}: argument ${RED}$1${NOC} not supported."
    return
}

# =============================================================================
function _build_main_meson_exists() {
    if [ -f "meson.build" ]; then
        find_main_meson=0
        while IFS='' read -r line || [[ -n "$line" ]]; do
            if [[ $line == *"project("* ]]; then
                find_main_meson=1
            fi
        done <meson.build
        if [ $find_main_meson = '1' ]; then
            echo "yes"
        else
            echo "no"
        fi
        return
    fi

    echo "no"
}

# =============================================================================
# todo: in some projects, CMakeLists.txt file can be in the sub-directory
function _build_cmakelists_exists() {
    if [ -f "CMakeLists.txt" ]; then
        echo "yes"
        return
    fi
    echo "no"
}

# =============================================================================
function _build_makefile_exists() {
    if [ -f "Makefile" ]; then
        echo "make "
        return
    fi
    echo " "
}

# =============================================================================
function _build_build_docker_exists() {
    if [[ -f "$docker_sh_file" ]] &&
        [[ -f "docker/build" ]] && [[ -f "docker/Dockerfile" ]]; then
        echo "docker "
        return
    fi
    echo " "
}

# =============================================================================
function _cmakelists_add_test_exists() {
    if [ -f "CMakeLists.txt" ]; then
        find_add_test=0
        while IFS='' read -r line || [[ -n "$line" ]]; do
            if [[ $line == *"add_test("* ]]; then
                find_add_test=1
            fi
        done <CMakeLists.txt
        if [ $find_add_test = '1' ]; then
            echo "test "
        else
            echo " "
        fi
        return
    fi

    echo " "
}

# =============================================================================
function _meson_build_test_exists() {
    if [ -f "meson.build" ]; then
        find_test=0
        while IFS='' read -r line || [[ -n "$line" ]]; do
            if [[ $line == *"test("* ]]; then
                find_test=1
            fi
        done <meson.build
        if [ $find_test = '1' ]; then
            echo "test "
        else
            echo " "
        fi
        return
    fi

    echo " "
}

# =============================================================================
function _build_linux() {
    COMPREPLY=()

    # All possible first values in command line
    service="template "
    service+=$(_build_build_docker_exists)
    if [ $(_build_cmakelists_exists) = 'yes' ]; then
        service+="cmake "
    fi
    service+=$(_build_makefile_exists)
    if [ $(_build_main_meson_exists) = 'yes' ]; then
        service+="meson-native meson-cross "
    fi
    local SERVICES=("
        $service
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # -----------------------------------------------------
    template_list="--cmake --stm32 "
    ACTIONS[template]="$template_list "
    for i in $template_list; do
        ACTIONS[$i]=" "
    done
    stm32_list="f030r8 f103rb f107xc f303re f407zg "
    stm32_list+="f407vg f427vi f746zg f767zi h750vb "
    ACTIONS["--stm32"]="$stm32_list "
    for i in $stm32_list; do
        ACTIONS[$i]=" "
    done
    # -----------------------------------------------------
    cmake_list="all clean install "
    # if "add_test " exists in CMakelist.txt file
    cmake_list+="$(_cmakelists_add_test_exists)"
    ACTIONS[cmake]="$cmake_list "
    for i in $cmake_list; do
        ACTIONS[$i]=" "
    done
    # -----------------------------------------------------
    docker_list="all clean "
    ACTIONS[docker]="$docker_list "
    for i in $docker_list; do
        ACTIONS[$i]=" "
    done

    # -----------------------------------------------------
    make_list="all clean install "
    ACTIONS[make]="$make_list "
    for i in $make_list; do
        ACTIONS[$i]=" "
    done

    # -----------------------------------------------------
    meson_cross_list="clean $(ls -a ${HOME}/ | grep oesdk | sed 's/-oesdk//g') "
    ACTIONS["meson-cross"]="$meson_cross_list "
    for i in $meson_cross_list; do
        ACTIONS[$i]="--conti --fresh "
    done
    ACTIONS["--conti"]=" "
    ACTIONS["--fresh"]=" "
    # -----------------------------------------------------
    meson_native_list="all clean "
    meson_native_list+="$(_meson_build_test_exists)"
    ACTIONS["meson-native"]="$meson_native_list"
    for i in $meson_native_list; do
        ACTIONS[$i]=" " # does not take --conti or --fresh option
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
if [ $system = 'Linux' ]; then
    complete -F _build_linux build
# elif [ $system = 'Darwin' ]; then
#     echo "todo"
fi
