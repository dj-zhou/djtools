#!/bin/bash

# =============================================================================
# it only supports meson build for now
# problem:
# on Ubuntu 18.04, the SDK .appolo-image-wandboard-poky-2.6.4-oesdk does not work!
# it still says native build (meson/ninja)
function _build_use_oesdk() # sdk_path
{
    current_folder=${PWD}

    sdk_path="${HOME}/$1-oesdk"
    sdk_output="_bsdk$1"
    echo "sdk_path = $sdk_path"
    sdk_env_set=$(ls $sdk_path | grep environment)
    echo "sdk_env_set = $sdk_env_set"

    if [ -n "$2" ] && [ $2 = '--conti' ] ; then
        folder_name=`basename "${PWD}"`
        unset LD_LIBRARY_PATH
        source $sdk_path/$sdk_env_set
        # contains sdk_output folder
        if [ -d $sdk_output ] ; then
            cd $sdk_output
            ninja
            echo -e "\n ${PRP} build -use-oesdk${NOC}"
            echo -e "    with \"--conti\" option: contains $sdk_output/ folder"
            echo -e "    sdk location:$sdk_path\n"
            cd $current_folder

        # just in the $sdk_output/ folder
        elif [ $folder_name = "$sdk_output" ] ; then
            ninja
            echo -e "\n ${PRP} build -use-oesdk${NOC}"
            echo -e "    with \"--conti\" option: in $sdk_output/ folder"
            echo -e "    sdk location:$sdk_path\n"
        
        # if the current path is ~/xx/$sdk_output/yy/zz --------
        elif [[ "$current_folder" = *"$sdk_output"* ]] ; then
            sdk_build_path=${current_folder%"$sdk_output"*}
            sdk_build_path=$sdk_build_path"$sdk_output"
            cd $sdk_build_path
            ninja
            cd $current_folder
            echo -e "\n ${PRP} build -use-oesdk${NOC}"
            echo -e "    with \"--conti\" option: in $sdk_output/ sub-folder"
            echo -e "    sdk location:$sdk_path\n"
        else
            echo -e "\n ${PRP} build -use-oesdk${NOC}"
            echo -e "    not in $sdk_output/ or its sub folder, no build, exit!!\n"
        fi
        # _yocto_reset_env_variables
        return
    fi

    # ------------------------------------------------------------------
    # ------------------------------------------------------------------
    # fresh build starts below

    # source the environment variables --------------------
    unset LD_LIBRARY_PATH
    echo "source $sdk_path/$sdk_env_set"
    source $sdk_path/$sdk_env_set

    folder_name=$(basename "${PWD}")

    # if the curent folder contains the $sdk_output folder, then
    # rm $sdk_output -r 
    # meson build && cd build && ninja
    if [ -d $sdk_output ] ; then
        echo "containes a $sdk_output folder"
        rm $sdk_output/ -rf
        meson . $sdk_output -Db_sanitize=none
        cd $sdk_output
        ninja
        echo -e "\n ${PRP} build -use-oesdk${NOC}"
        echo -e "    fresh build, contains $sdk_output/ folder."
        echo -e "    sdk location:$sdk_path\n"
        cd $current_folder
    
    # if the curent folder is $fb2_sdk_build_folder/, then
    elif [ $folder_name = "$sdk_output" ] ; then
        echo "inside a $sdk_output folder"
        cd ../
        rm $sdk_output/ -rf
        meson . $sdk_output -Db_sanitize=none
        cd $sdk_output
        ninja
        echo -e "\n ${PRP} build -use-oesdk${NOC}"
        echo -e "    fresh build, in $sdk_output/ folder."
        echo -e "    sdk location:$sdk_path\n"

    # if in a subfolder of $sdk_output/
    elif [[ "$current_folder" = *"$sdk_output"* ]] ; then
        sdk_build_parent_path=${current_folder%"$sdk_output"*}
        cd $sdk_build_parent_path
        rm $sdk_output/ -rf
        meson . $sdk_output -Db_sanitize=none
        cd $sdk_output
        ninja
        echo -e "\n ${PRP} build -use-oesdk${NOC}"
        echo -e "    fresh build, in $sdk_output/ sub-folder."
        echo -e "    sdk location:$sdk_path\n"
        cd $current_folder

    # if the current folder does not contain a $sdk_output/ folder,then
    # check if there is a meson.build file, then build
    elif [ -f meson.build ] ; then
        meson . $sdk_output -Db_sanitize=none
        cd $sdk_output
        ninja
        echo -e "\n ${PRP} build -use-oesdk${NOC}"
        echo -e "    fresh build, have created the $sdk_output/ folder"
        echo -e "    sdk location:$sdk_path\n"
        cd $current_folder
    else
        echo -e "\n ${PRP} build -use-oesdk${NOC}"
        echo -e "    fresh build, but no meson.build file found, no build, exit!! \n"
    fi
    # _yocto_reset_env_variables
}

# =============================================================================
function build()
{
    if [ $1 = '-use-oesdk' ] ; then
        _build_use_oesdk $2 $3 $4 $5 $6 $7
        return
    fi
    echo -e "\n ${PRP}build${NOC}: argument ${RED}$1${NOC} not supported.\n"
    return
}

# =============================================================================
function _build()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        -use-oesdk
        -native
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # -----------------------------------------------------
    sdk_list="$(ls -a ${HOME}/ | grep oesdk | sed 's/-oesdk//g') "
    ACTIONS[-use-oesdk]="$sdk_list "
    for i in $sdk_list ; do
        ACTIONS[$i]="--conti --fresh "
    done
    ACTIONS[--conti]=" "
    ACTIONS[--fresh]=" "
    # -----------------------------------------------------
    ACTIONS[-native]=" "

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================
complete -F _build build