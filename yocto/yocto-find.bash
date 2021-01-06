#!/bin/bash

# =============================================================================
function _yocto_check_is_a_build_directory()
{
    if [ ! -d "conf" ] ; then
        echo "false"
        return
    fi
    if [ ! -f "conf/local.conf" ] ; then
        echo "false"
        return
    fi
    if [ ! -f "conf/bblayers.conf" ] ; then
        echo "false"
        return
    fi
    echo "true"
}

# =============================================================================
# the variable MACHINE defined in conf/local.conf, can be any of the forms:
function _yocto_find_variable_in_file() # $variable $file
{
    variable=$1
    file=$2
    # --------------------------------------------------------
    # form 1: MACHINE = "xxxx", MACHINE = 'xxxx'
    value=$(grep "^$variable = " $file | awk '{print $3 }' | \
              sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ] ; then
        echo $value
        return
    fi
    # --------------------------------------------------------
    # form 2: MACHINE ?= "xxxx", MACHINE ?= 'xxxx'
    value=$(grep "^$variable ?= " $file | awk '{print $3 }' | \
              sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ] ; then
        echo $value
        return
    fi
    # --------------------------------------------------------
    # form 3: MACHINE ??= "xxxx", MACHINE ??= 'xxxx'
    value=$(grep "^$variable ??= " $file | awk '{print $3 }' | \
              sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ] ; then
        echo $value
        return
    fi
    # --------------------------------------------------------
    # not found, return empty string, there maybe some other forms
    # echo "not found, return empty string " >&2
    echo " "
}

# =============================================================================
# MACHINE must be defined in conf/local.conf
function _yocto_find_MACHINE()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
        MACHINE=$(_yocto_find_variable_in_file "MACHINE" conf/local.conf)
        echo $MACHINE
    else
        echo "not in a build directory, return empty string " >&2
        echo " "
    fi
}

# =============================================================================
# TMPDIR can be defined in conf/local.conf
# or it is the default one, tmp/, in the build directory
function _yocto_find_TMPDIR()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
        TMPDIR=$(_yocto_find_variable_in_file "TMPDIR" conf/local.conf)
        if [ ! -z $TMPDIR ] ; then
            echo $TMPDIR
        elif [ -d tmp/ ] ; then
            echo "tmp"
        else
            echo "no tmp/ directory, return empty string " >&2
            echo " "
        fi
    else
        echo "not in a build directory, return empty string " >&2
        echo " "
    fi
}

# =============================================================================
# this function does not throw a warning if not in the build directory
function _yocto_find_DISTRO()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
        DISTRO=$(_yocto_find_variable_in_file "DISTRO" conf/local.conf)
        echo $DISTRO
    else
        echo "not in a build directory, return empty string " >&2
        echo " "
    fi
}

# =============================================================================
# this function should be run in a build directory
function _yocto_find_DISTRO_VERSION()
{
    if [ $(_yocto_check_is_a_build_directory) = 'false' ] ; then
        echo "not in a build directory, return emptry string " >&2
        echo " "
        return
    fi
    DISTRO=$(_yocto_find_DISTRO)
    if [ -z "$DISTRO" ] ; then
        echo " cannot find DISTRO, hence cannot find DISTRO_VERSION" <&2
        echo " "
    fi

    # then to find $DISTRO.conf, in which, to find something like
    # 'DISTRO_VERSION = "2.6.4"'. however, this file can require some other
    # file, then ... it can be too hard
    current_folder=${PWD}
    # it assumes that the meta-data directories are parallel to the build
    # directory, it is not always true (TODO)
    cd ..
    for item in ./*; do
        cd $current_folder/../
        # not a directory, continue -----------
        if [[ ! -d $item ]] ; then
            continue
        fi
        cd $item
        # in a build directory, continue -------------
        if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
            # echo "a build directory, no need to search" >&2
            continue
        fi
        folder_name=$(basename $item)
        file_path=$(find . -name $DISTRO.conf)
        # cannot find the file, continue ---------------
        if [  -z "$file_path" ] ; then
            continue
        fi
        file_full_path=$current_folder/../$folder_name/$file_path
        # find something like 'DISTRO_VERSION = "2.6.4"' in this file
        DISTRO_V=$(_yocto_find_variable_in_file "DISTRO_VERSION" $file_full_path)
        if [ ! -z $DISTRO_V ] ; then
            echo $DISTRO_V
            cd $current_folder
            return
        fi
    done

    # if reaches here, means $DISTRO_V is empty --------------
    # echo -e "\n\nDISTRO_VERSION not found, trying to find it in another way\n" <&2
    cd $current_folder/../
    # find the actual conf file
    required_file=$(grep -r require $file_full_path | awk '{print $2 }')
    slash_count=$(_count_a_char_in_str "$required_file" "/")
    pos=$(_find_a_char_in_str "$required_file" "/" $slash_count)
    conf_file=${required_file:${pos}+1:${#required_file}}
    
    # search that file again ---------------
    cd $current_folder/../
    for item in ./*; do
        cd $current_folder/../
        # not a directory, continue -----------
        if [[ ! -d $item ]] ; then
            continue
        fi
        cd $item
        # in a build directory, continue -------------
        if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
            # echo "a build directory, no need to search" >&2
            continue
        fi
        folder_name=$(basename $item)
        file_path=$(find . -name $conf_file)
        # cannot find the file, continue ---------------
        if [  -z "$file_path" ] ; then
            continue
        fi
        file_full_path=$current_folder/../$folder_name/$file_path
        # find something like 'DISTRO_VERSION = "2.6.4"' in this file
        DISTRO_V=$(_yocto_find_variable_in_file "DISTRO_VERSION" $file_full_path)
        # if there is a $ in the string ...
        DISTRO_V=${DISTRO_V%"$"*}
        if [ ! -z $DISTRO_V ] ; then
            # if last char is '-'
            if [ ${DISTRO_V:${#the_line}-1:1} = '-' ] ; then
                DISTRO_V=${DISTRO_V:0:${#the_line}-1}
            fi
            echo $DISTRO_V
            cd $current_folder
            return
        fi
    done
    cd $current_folder
}

# =============================================================================
function _yocto_find_image_name_in_build_directory()
{
    # must be a valid build directory ------------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ] ; then
        echo -e "\n ${PRP}_yocto_find_image_name_in_build_directory${NOC}:" >&2
        echo -e "    not in a valid bitbake build directory, exit!!\n" >&2
        echo " "
        return
    fi
    # find two terms ----------------------
    TMPDIR=$(_yocto_find_TMPDIR)
    MACHINE=$(_yocto_find_MACHINE)
    if [ -z $MACHINE ] ; then
        # output information to stderr ------
        echo -e "\n ${PRP}_yocto_find_image_name_in_build_directory${NOC}:" >&2
        echo -e "    MACHINE not found, exit!!\n" >&2
        echo " "
        return
    fi

    # the image file can be wic.gz, or wic.zst ----------
    # or it can be something else, should add later
    find_wic_file=$(ls $TMPDIR/deploy/images/$MACHINE | grep wic)
    if [[ ! -z $find_wic_file ]] ; then
        wic_file=$(echo $find_wic_file | awk '{print $1}')
    else
        echo " image file (*.wic.*) not found, return empty string" >&2
        echo " "
    fi
    
    # remove sub-string and whatever behind it ------------
    echo ${wic_file%"-$MACHINE"*}
}

# =============================================================================
function _yocto_find_image_file() # $tmp_dir $machine
{
    tmp_dir=$1
    machine=$2
    potential_image=$(ls $tmp_dir/deploy/images/$machine/ | grep wic )
    potential_image=$(echo $potential_image | awk '{ print $2 }' )
    echo $potential_image
}

# =============================================================================
function _yocto_find_bmap_file() # $wic_file
{
    wic_file=$1
    # wic.gz -> wic.bmap ---------------
    bmap_file=$(echo $wic_file | sed "s/wic.gz/wic.bmap/g" )
    # wic.zst -> wic.bmap ---------------
    if [ -z $bmap_file ] ; then
        bmap_file=$(echo $wic_file | sed "s/wic.zst/wic.bmap/g" )
    fi
    # other form -----------
    echo $bmap_file
}

# =============================================================================
# find a file in current directory, excluding the build directory
function _yocto_show_a_file() # file_full_name filter
{
    current_folder=${PWD}

    file_full_name=$1
    filter=$2
    for item in ./*; do
        cd $current_folder
        if [[ ! -d $item ]] ; then
            continue
        fi
        cd $item
        folder_name=$(basename $item)
        if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
            continue
        fi
        find_files=$(find -name "*$file_full_name")
        not_shown_folder_name=1
        if [ ! -z "$find_files" ] ; then
            
            for file in $find_files ; do
                if [[ "$file" = *"$filter"* ]] ; then
                    if [ $not_shown_folder_name = 1 ] ; then
                        echo -e "\n${GRN}---------------------------------------"
                        echo -e "$folder_name${NOC}"
                        not_shown_folder_name=0
                    fi
                    echo "$file"
                fi
            done
        fi
    done
    cd $current_folder
}

# =============================================================================
# it should not be started in a build directory
function _yocto_show_conf() # filter
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ;then
        echo -e "\n this is a build directory, stop searching, exit!!\n" >&2
        return
    fi

    conf_name=$1
    filter=$2
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)

    if [ "$exact_vague" = "exact" ] ; then
        conf_full_name="$conf_name.conf"
    else
        conf_full_name="$conf_name*.conf"
    fi
    
    _yocto_show_a_file $conf_full_name $filter
}

# =============================================================================
function _yocto_show_bb_file() #filter
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ;then
        echo -e "\n this is a build directory, stop searching, exit!!\n" >&2
        return
    fi

    bb_name=$1
    filter=$2
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)
    # find bb file ---------------
    if [ "$exact_vague" = "exact" ] ; then
        bb_full_name="$bb_name.bb"
    else
        bb_full_name="$bb_name*.bb"
    fi
    _yocto_show_a_file $bb_full_name $filter
}

# =============================================================================
function _yocto_show_inc_file() #filter
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ;then
        echo -e "\n this is a build directory, stop searching, exit!!\n" >&2
        return
    fi

    bb_name=$1
    filter=$2
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)
    # find bb file ---------------
    if [ "$exact_vague" = "exact" ] ; then
        bb_full_name="$bb_name.inc"
    else
        bb_full_name="$bb_name*.inc"
    fi
    _yocto_show_a_file $bb_full_name $filter
}

# =============================================================================
function _yocto_list_things()
{
    current_folder=${PWD}

    things=$1
    for item in ./*; do
        cd $current_folder
        if [[ ! -d $item ]] ; then
            continue
        fi
        cd $item
        if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
            continue
        fi
        folder_name=$(basename $item)
        for loop in "./" "./*/" "./*/*/" "./*/*/*/" ; do
            find_x=$(ls ${loop}${things} 2>/dev/null)
            if [[ ! -z "$find_x" ]] ; then
                echo -e "\n${GRN}---------------------------------------"
                echo -e "$(basename $item)${NOC}"
                echo "$find_x"
            fi
        done
    done
    echo -e "\n"
    cd $current_folder
}

# =============================================================================
function _yocto_list_resources()
{
    # current folder -------------
    if [ -d .git ] ; then
        echo -e "\n${GRN}----------------------------------------------${NOC}"
        folder_name=$(basename $PWD)
        echo -e "${GRN}$folder_name${NOC} (root)"
        branch_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
        echo "remote: $(git remote -v | grep fetch | awk '{print $2}')"
        echo "branch: $branch_name"
        git log --decorate=short --pretty=oneline -n1
    fi

    # iterate all folders ----------
    current_folder=${PWD}
    
    for item in ./*; do
        if [[ -d $item ]] && ( [[ -d $item/.git ]] || [[ -f $item/.git ]] ) ; then
            echo -e "\n${GRN}----------------------------------------------${NOC}"
            cd $item
            folder_name=$(basename "$item")
            printf "${GRN}$folder_name${NOC}"
            if [[ -d .git ]] ; then
                printf " (git repo)\n"
            elif [[ -f .git ]] ; then
                printf " (git submodule)\n"
            fi
            branch_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
            echo "remote: $(git remote -v | grep fetch | awk '{print $2}')"
            echo "branch: $branch_name"
            git log --decorate=short --pretty=oneline -n1
            cd $current_folder
        fi
    done
}

# =============================================================================
function _yocto_list()
{
    if [[ $1 = 'distros' ]] ; then
        _yocto_list_things "distro*/*.conf"
        return
    fi
    if [[ $1 = 'images' ]] ; then
        _yocto_list_things "recipes*/images*/*.bb"
        return
    fi
    if [[ $1 = 'machines' ]] ; then
        _yocto_list_things "conf/machine/*.conf"
        return
    fi
    if [[ $1 = 'resources' ]] ; then
        _yocto_list_resources
        return
    fi
}
