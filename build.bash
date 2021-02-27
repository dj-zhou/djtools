#!/bin/bash

# =============================================================================
# it only supports meson build for now
# problem:
# on Ubuntu 18.04, the SDK .appolo-image-wandboard-poky-2.6.4-oesdk does not work!
# it still says native build (meson/ninja)
function _build_meson_use_oesdk() # sdk_path
{
    if [ $# -lt 1 ] ; then
        echo "build meson -cross: need the sdk path."
        return
    fi
    _save_current_env_variables

    current_directory=${PWD}
    # the path is determined by command:
    #    yocto setup plain-sdk
    machine_name=$(ls ${HOME}/$1-oesdk)
    distro_name=$(ls ${HOME}/$1-oesdk/$machine_name)
    
    sdk_path="${HOME}/$1-oesdk/$machine_name/$distro_name" 
    sdk_output="_bcross$1"
    sdk_env_set=$(ls $sdk_path | grep environment)

    if [ -n "$2" ] && [ $2 = '--conti' ] ; then
        directory_name=`basename "${PWD}"`
        unset LD_LIBRARY_PATH
        source $sdk_path/$sdk_env_set
        # contains sdk_output directory
        if [ -d $sdk_output ] ; then
            cd $sdk_output
            ninja
            echo -e "\n ${PRP} build meson -cross${NOC}"
            echo -e "    with \"--conti\" option: contains $sdk_output/ directory"
            echo -e "    sdk location: ${GRN}$sdk_path${NOC}\n"
            cd $current_directory

        # just in the $sdk_output/ directory
        elif [ $directory_name = "$sdk_output" ] ; then
            ninja
            echo -e "\n ${PRP} build meson -cross${NOC}"
            echo -e "    with \"--conti\" option: in $sdk_output/ directory"
            echo -e "    sdk location: ${GRN}$sdk_path${NOC}\n"
        
        # if the current path is ~/xx/$sdk_output/yy/zz --------
        elif [[ "$current_directory" = *"$sdk_output"* ]] ; then
            sdk_build_path=${current_directory%"$sdk_output"*}
            sdk_build_path=$sdk_build_path"$sdk_output"
            cd $sdk_build_path
            ninja
            cd $current_directory
            echo -e "\n ${PRP} build meson -cross${NOC}"
            echo -e "    with \"--conti\" option: in $sdk_output/ sub-directory"
            echo -e "    sdk location: ${GRN}$sdk_path${NOC}\n"
        else
            echo -e "\n ${PRP} build meson -cross${NOC}"
            echo -e "    not in $sdk_output/ or its sub directory, no build, exit!!\n"
        fi
        _yocto_reset_env_variables
        rm -rf builddir # just a hack
        return
    fi

    # ------------------------------------------------------------------
    # ------------------------------------------------------------------
    # fresh build starts below

    # source the environment variables --------------------
    unset LD_LIBRARY_PATH
    echo "source $sdk_path/$sdk_env_set"
    source $sdk_path/$sdk_env_set

    directory_name=$(basename "${PWD}")

    # if the curent directory contains the $sdk_output directory, then
    # rm $sdk_output -r 
    # meson build && cd build && ninja
    if [ -d $sdk_output ] ; then
        echo "containes a $sdk_output directory"
        rm $sdk_output/ -rf
        meson . $sdk_output -Db_sanitize=none
        cd $sdk_output
        ninja
        echo -e "\n ${PRP} build meson -cross${NOC}"
        echo -e "    fresh build, contains $sdk_output/ directory."
        echo -e "    sdk location: ${GRN}$sdk_path${NOC}\n"
        cd $current_directory
    
    # if the curent directory is $fb2_sdk_build_directory/, then
    elif [ $directory_name = "$sdk_output" ] ; then
        echo "inside a $sdk_output directory"
        cd ../
        rm $sdk_output/ -rf
        meson . $sdk_output -Db_sanitize=none
        cd $sdk_output
        ninja
        echo -e "\n ${PRP} build meson -cross${NOC}"
        echo -e "    fresh build, in $sdk_output/ directory."
        echo -e "    sdk location: ${GRN}$sdk_path${NOC}\n"

    # if in a subdirectory of $sdk_output/
    elif [[ "$current_directory" = *"$sdk_output"* ]] ; then
        sdk_build_parent_path=${current_directory%"$sdk_output"*}
        cd $sdk_build_parent_path
        rm $sdk_output/ -rf
        meson . $sdk_output -Db_sanitize=none
        cd $sdk_output
        ninja
        echo -e "\n ${PRP} build meson -cross${NOC}"
        echo -e "    fresh build, in $sdk_output/ sub-directory."
        echo -e "    sdk location: ${GRN}$sdk_path${NOC}\n"
        cd $current_directory

    # if the current directory does not contain a $sdk_output/ directory,then
    # check if there is a meson.build file, then build
    elif [ -f meson.build ] ; then
        meson . $sdk_output -Db_sanitize=none
        cd $sdk_output
        ninja
        echo -e "\n ${PRP} build meson -cross${NOC}"
        echo -e "    fresh build, have created the $sdk_output/ directory"
        echo -e "    sdk location: $sdk_path\n"
        cd $current_directory
    else
        echo -e "\n ${PRP} build meson -cross${NOC}"
        echo -e "    fresh build, but no meson.build file found, no build, exit!! \n"
    fi
    _yocto_reset_env_variables
    rm -rf builddir # just a hack
}

# =============================================================================
# this should implement the same logic as in _build_oesdk()
function _build_meson_native()
{
    current_directory=${PWD}
    if [ -f "meson.build" ] ; then
        
        if [ ! -d "_bnative" ] ; then
            meson setup _bnative
        fi
        if [ ! -f "_bnative/build.ninja" ] ; then
            rm _bnative -rf
            meson setup _bnative
            rm -rf builddir # just a hack
            return
        fi
        cd _bnative
        ninja
    else
        echo "not a meson directory, exit!"
    fi
    rm -rf builddir # just a hack
    cd $current_directory
}

# =============================================================================
function build()
{
    # ------------------------------
    if [ $1 = 'meson' ] ;  then
        # ------------------------------
        if [ $2 = '-cross' ] ; then
            _build_meson_use_oesdk $3 $4 $5 $6 $7
            return
        fi
        # ------------------------------
        if [ $2 = '-native' ] ; then
            _build_meson_native $3 $4 $5 $6 $7
            return
        fi
        return
    fi
    # ------------------------------
    if [ $1 = 'cmake' ] ; then
        compile_cmakelist $2 $3 $4 $5 $6
        return
    fi
    # ------------------------------
    if [ $1 = 'make' ] ; then
        compile_makefile $2 $3 $4 $5 $6
        return
    fi
    echo -e "\n ${PRP}build${NOC}: argument ${RED}$1${NOC} not supported.\n"
    return
}

# =============================================================================
function _build_meson_exists()
{
    if [ -f "meson.build" ] ; then
        echo "meson"
        return
    fi
    if [ -f "build.ninja" ] ; then
        echo "meson"
        return
    fi
    echo " "
}

# =============================================================================
function _build_cmakelists_exists()
{
    if [ -f "CMakeLists.txt" ] ; then
        echo "cmake"
        return
    fi
    echo " "
}

# =============================================================================
function _build_makefile_exists()
{
    if [ -f "Makefile" ] ; then
        echo "make"
        return
    fi
    echo " "
}

# =============================================================================
function _build()
{
    COMPREPLY=()

    # All possible first values in command line
    service=$(_build_meson_exists)
    service+=$(_build_cmakelists_exists)
    service+=$(_build_makefile_exists)
    local SERVICES=("
        $service
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # -----------------------------------------------------
    meson_list="-cross -native "
    ACTIONS[meson]="$meson_list "
    oesdk_list="$(ls -a ${HOME}/ | grep oesdk | sed 's/-oesdk//g') "
    ACTIONS[-cross]="$oesdk_list "
    for i in $oesdk_list ; do
        ACTIONS[$i]="--conti --fresh "
    done
    ACTIONS[-native]="--conti --fresh "
    ACTIONS[--conti]=" "
    ACTIONS[--fresh]=" "

    # -----------------------------------------------------
    cmake_list="all clean "
    ACTIONS[cmake]="$cmake_list "
    for i in $cmake_list ; do
        ACTIONS[$i]=" "
    done
    
    # -----------------------------------------------------
    make_list="all clean "
    ACTIONS[make]="$make_list "
    for i in $make_list ; do
        ACTIONS[$i]=" "
    done

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( $(compgen -W "${ACTIONS[$3]}" -- $cur) )
    else
        COMPREPLY=( $(compgen -W "${SERVICES[*]}" -- $cur) )
    fi
}

# =============================================================================
complete -F _build build
