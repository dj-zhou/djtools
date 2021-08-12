#!/bin/bash

# =============================================================================
# it only supports meson build for now
# problem:
# on Ubuntu 18.04, the SDK .appolo-image-wandboard-poky-2.6.4-oesdk does not work!
# it still says native build (meson/ninja)
function _build_meson_use_oesdk() { # sdk_path
    if [ $# -lt 1 ]; then
        echo "build meson -cross: need the sdk path."
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
            echo "containes a $sdk_output directory"
            rm $sdk_output/ -rf
            meson . $sdk_output -Db_sanitize=none
            cd $sdk_output
            ninja
            echo -e "${GRN}build meson -cross${NOC}"
            echo -e "    fresh build, contains $sdk_output/ directory."
            echo -e "    sdk location: ${GRN}$sdk_path${NOC}"
            cd $cur_dir

        # if the curent directory is $fb2_sdk_build_directory/, then
        elif [ $directory_name = "$sdk_output" ]; then
            echo "inside a $sdk_output directory"
            cd ../
            rm $sdk_output/ -rf
            meson . $sdk_output -Db_sanitize=none
            cd $sdk_output
            ninja
            echo -e "${GRN}build meson -cross${NOC}"
            echo -e "    fresh build, in $sdk_output/ directory."
            echo -e "    sdk location: ${GRN}$sdk_path${NOC}"

        # if in a subdirectory of $sdk_output/
        elif [[ "$cur_dir" = *"$sdk_output"* ]]; then
            sdk_build_parent_path=${cur_dir%"$sdk_output"*}
            cd $sdk_build_parent_path
            rm $sdk_output/ -rf
            meson . $sdk_output -Db_sanitize=none
            cd $sdk_output
            ninja
            echo -e "${GRN}build meson -cross${NOC}"
            echo -e "    fresh build, in $sdk_output/ sub-directory."
            echo -e "    sdk location: ${GRN}$sdk_path${NOC}"
            cd $cur_dir

        # if the current directory does not contain a $sdk_output/ directory,then
        # check if there is a meson.build file, then build
        elif [ -f meson.build ]; then
            meson . $sdk_output -Db_sanitize=none #  -Dprefix=/usr
            cd $sdk_output
            ninja
            echo -e "${GRN}build meson -cross${NOC}"
            echo -e "    fresh build, have created the $sdk_output/ directory"
            echo -e "    sdk location: $sdk_path"
            cd $cur_dir
        else
            echo -e "${GRN} build meson -cross${NOC}"
            echo -e "    fresh build, but no meson.build file found, no build, exit!!"
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
        echo -e "${GRN}build meson -cross${NOC}"
        echo -e "with \"--conti\" option: contains $sdk_output/ directory"
        echo -e "sdk location: ${GRN}$sdk_path${NOC}"
        cd $cur_dir

    # just in the $sdk_output/ directory
    elif [ $directory_name = "$sdk_output" ]; then
        ninja
        echo -e "${GRN} build meson -cross${NOC}"
        echo -e "with \"--conti\" option: in $sdk_output/ directory"
        echo -e "sdk location: ${GRN}$sdk_path${NOC}"

    # if the current path is ~/xx/$sdk_output/yy/zz --------
    elif [[ "$cur_dir" = *"$sdk_output"* ]]; then
        sdk_build_path=${cur_dir%"$sdk_output"*}
        sdk_build_path=$sdk_build_path"$sdk_output"
        cd $sdk_build_path
        ninja
        cd $cur_dir
        echo -e "${GRN}build meson -cross${NOC}"
        echo -e "with \"--conti\" option: in $sdk_output/ sub-directory"
        echo -e "    sdk location: ${GRN}$sdk_path${NOC}"
    else
        echo -e "${GRN}build meson -cross${NOC}"
        echo -e "not in $sdk_output/ or its sub directory, no build, exit!!"
    fi
    _yocto_reset_env_variables
    rm -rf builddir # just a hack
}

# =============================================================================
# this should implement the same logic as in _build_oesdk()
# now, it does not take --fresh or --conti option, but it runs a taking --conti option
function _build_meson_native() {
    cur_dir=${PWD}
    proj_dir="_bnative.meson"
    if [ -f "meson.build" ]; then
        if [ ! -d "$proj_dir" ]; then
            meson setup $proj_dir
        fi
        if [ ! -f "$proj_dir/build.ninja" ]; then
            rm $proj_dir -rf
            meson setup $proj_dir
            rm -rf builddir # just a hack
            return
        fi
        cd $proj_dir && ninja
        cd $cur_dir && rm -rf builddir # just a hack
    else
        echo -e "${RED}not a meson project directory, exit!${NOC}"
    fi
    rm -rf builddir # just a hack
    cd $cur_dir
}

# =============================================================================
function _build_in_docker() {
    if ! [ -f "build-docker.sh" ]; then
        echo "no build file, exit."
        return
    fi
    target_tag="$1"
    if [[ -z "$target_tag" || "$target_tag" = "all" ]]; then
        ./build-docker.sh
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
function compile_makefile() {
    echo -e "use ${GRN}Makefile${NOC} to build"
    target_tag=$1
    if [ "$target_tag" = "clean" ]; then
        echo -e "${GRN}make clean${NOC}"
        make clean
        return
    fi
    if [ "$target_tag" = "install" ]; then
        echo -e "${GRN}sudo make install${NOC}"
        sudo make install
        return
    fi

    echo -e "${GRN}make -j$(nproc) $target_tag${NOC}"
    make -j$(nproc) $target_tag

    # stm32 project dedicated scripts, can be moved into Makefile
    if [ ! -f .project-stm32 ] && [ ! -f bin/*.elf ]; then
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
    echo -e "${GRN}\n------------------------------------${NOC}"
    echo -e "${micro_controller} memory usage summary\nFLASH: ${flash_percentage}%, RAM: ${ram_percentage}%\n"
}

# =============================================================================
function compile_cmakelist() {
    echo -e "use ${GRN}CMakeLists.txt${NOC} to build/clean"
    cur_dir=${PWD}
    build_dir="_bnative.cmake"
    target_tag=$1
    if [[ -z "$target_tag" || "$target_tag" = "all" ]]; then
        if [ ! -d "$build_dir" ]; then
            echo -e "${GRN}mkdir "$build_dir" && cd "$build_dir" && cmake ..${NOC}"
            mkdir "$build_dir" && cd "$build_dir" && cmake ..
        else
            echo -e "${GRN}cd $build_dir/ && cmake ..${NOC}"
            cd "$build_dir"/ && cmake ..
        fi
        echo -e "${GRN}make -j$(nproc)${NOC}"
        make -j$(nproc)
        cd $cur_dir
        return
    fi
    if [ "$target_tag" = "clean" ]; then
        echo -e "${GRN}rm -rf "$build_dir"/${NOC}"
        rm -rf "$build_dir"/
        return
    fi
    if [ "$target_tag" = "install" ]; then
        echo -e "${GRN}cd "$build_dir"/ && sudo make install${NOC}"
        cd $build_dir
        sudo make install
        cd $cur_dir
        return
    fi
}

# =============================================================================
function compile_template() {
    if [ $1 = 'cmake' ]; then
        cp $djtools_path/compile-template/CMakeLists.txt-native ./CMakeLists.txt
        return
    fi
    if [ $1 = 'stm32f107xc' ]; then
        cp $djtools_path/compile-template/Makefile-stm32f107xc ./Makefile
        cp $djtools_path/compile-template/.project-stm32f107xc ./.project-stm32
        return
    fi
    if [ $1 = 'stm32f407zg' ]; then
        cp $djtools_path/compile-template/Makefile-stm32f407zg ./Makefile
        cp $djtools_path/compile-template/.project-stm32f407zg ./.project-stm32
        return
    fi
}

# =============================================================================
function build() {
    # ------------------------------
    if [ $1 = 'cmake' ]; then
        compile_cmakelist $2 $3 $4 $5 $6
        return
    fi
    # ------------------------------
    if [ $1 = 'docker' ]; then
        shift
        _build_in_docker $@
        return
    fi
    # ------------------------------
    if [ $1 = 'make' ]; then
        compile_makefile $2 $3 $4 $5 $6
        return
    fi
    # ------------------------------
    if [ $1 = 'meson' ]; then
        # ------------------------------
        if [ $2 = '-cross' ]; then
            _build_meson_use_oesdk $3 $4 $5 $6 $7
            return
        fi
        # ------------------------------
        if [ $2 = '-native' ]; then
            _build_meson_native $3 $4 $5 $6 $7
            return
        fi
        return
    fi
    # ------------------------------
    if [ $1 = 'template' ]; then
        shift
        compile_template $@
        return
    fi
    echo -e "${GRN}build${NOC}: argument ${RED}$1${NOC} not supported."
    return
}

# =============================================================================
function _build_meson_exists() {
    if [ -f "meson.build" ]; then
        echo "meson "
        return
    fi
    if [ -f "build.ninja" ]; then
        echo "meson "
        return
    fi
    echo " "
}

# =============================================================================
function _build_cmakelists_exists() {
    if [ -f "CMakeLists.txt" ]; then
        echo "cmake "
        return
    fi
    echo " "
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
    if [[ -f "build-docker.sh" ]] && [[ -f "docker/build-in-container.sh" ]] && [[ -f "docker/Dockerfile" ]]; then
        echo "docker "
        return
    fi
    echo " "
}

# =============================================================================
function _build() {
    COMPREPLY=()

    # All possible first values in command line
    service="template"
    service+=$(_build_build_docker_exists)
    service+=$(_build_cmakelists_exists)
    service+=$(_build_makefile_exists)
    service+=$(_build_meson_exists)
    local SERVICES=("
        $service
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # -----------------------------------------------------
    template_list="cmake stm32f107xc stm32f407zg "
    ACTIONS[template]="$template_list "
    for i in $template_list; do
        ACTIONS[$i]=" "
    done
    # -----------------------------------------------------
    cmake_list="all clean install "
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
    meson_list="-cross -native "
    ACTIONS[meson]="$meson_list "
    oesdk_list="$(ls -a ${HOME}/ | grep oesdk | sed 's/-oesdk//g') "
    ACTIONS[-cross]="$oesdk_list "
    for i in $oesdk_list; do
        ACTIONS[$i]="--conti --fresh "
    done
    ACTIONS[-native]=" " # does not take --conti or --fresh option
    ACTIONS[--conti]=" "
    ACTIONS[--fresh]=" "

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
complete -F _build build
