#!/bin/bash

# =============================================================================
function _yocto_check_is_a_build_directory() {
    if [ ! -d "conf" ]; then
        echo "false"
        return
    fi
    if [ ! -f "conf/local.conf" ]; then
        echo "false"
        return
    fi
    if [ ! -f "conf/bblayers.conf" ]; then
        echo "false"
        return
    fi
    echo "true"
}

# =============================================================================
# the variable MACHINE defined in conf/local.conf, can be any of the forms:
function _yocto_find_variable_in_file() { # $variable $file
    variable=$1
    file=$2
    # ----------------------------------------
    # form 1: MACHINE = "xxxx", MACHINE = 'xxxx'
    value=$(grep "^$variable = " $file | awk '{print $3 }' |
        sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ]; then
        echo $value
        return
    fi
    # ----------------------------------------
    # form 2: MACHINE ?= "xxxx", MACHINE ?= 'xxxx'
    value=$(grep "^$variable ?= " $file | awk '{print $3 }' |
        sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ]; then
        echo $value
        return
    fi
    # ----------------------------------------
    # form 3: MACHINE ??= "xxxx", MACHINE ??= 'xxxx'
    value=$(grep "^$variable ??= " $file | awk '{print $3 }' |
        sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ]; then
        echo $value
        return
    fi
    # ----------------------------------------
    # not found, return empty string, there maybe some other forms
    # echo "not found, return empty string " >&2
    echo " "
}

# =============================================================================
# MACHINE must be defined in conf/local.conf
function _yocto_find_MACHINE() {
    if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
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
function _yocto_find_TMPDIR() {
    if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
        echo "not in a build directory, return empty string " >&2
        echo " "
    fi
    if [ -d "tmp/" ]; then
        echo "tmp"
    elif [ -d "tmp-glibc/" ]; then
        echo "tmp-glibc"
    else
        echo "no \"tmp/\" or \"tmp-glibc/\" directory, return empty string " >&2
        echo ""
    fi
}

# =============================================================================
# this function does not throw a warning if not in the build directory
function _yocto_find_DISTRO() {
    if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
        DISTRO=$(_yocto_find_variable_in_file "DISTRO" conf/local.conf)
        echo $DISTRO
    else
        echo "not in a build directory, return empty string " >&2
        echo " "
    fi
}

# =============================================================================
# this function should be run in a build directory
function _yocto_find_DISTRO_VERSION() {
    if [ $(_yocto_check_is_a_build_directory) = 'false' ]; then
        echo "not in a build directory, return emptry string " >&2
        echo " "
        return
    fi
    DISTRO=$(_yocto_find_DISTRO)
    if [ -z "$DISTRO" ]; then
        echo " cannot find DISTRO, hence cannot find DISTRO_VERSION" <&2
        echo " "
    fi

    # then to find $DISTRO.conf, in which, to find something like
    # 'DISTRO_VERSION = "2.6.4"'. however, this file can require some other
    # file, then ... it can be too hard
    cur_dir=${PWD}
    # it assumes that the meta-data directories are parallel to the build
    # directory, it is not always true (TODO)
    cd ..
    for item in ./*; do
        cd $cur_dir/../
        # not a directory, continue -----------
        if [[ ! -d $item ]]; then
            continue
        fi
        cd $item
        # in a build directory, continue -------------
        if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
            # echo "a build directory, no need to search" >&2
            continue
        fi
        folder_name=$(basename $item)
        file_path=$(find . -name $DISTRO.conf)
        # cannot find the file, continue ---------------
        if [ -z "$file_path" ]; then
            continue
        fi
        file_full_path=$cur_dir/../$folder_name/$file_path
        # find something like 'DISTRO_VERSION = "2.6.4"' in this file
        DISTRO_V=$(_yocto_find_variable_in_file "DISTRO_VERSION" $file_full_path)
        if [ ! -z $DISTRO_V ]; then
            echo $DISTRO_V
            cd $cur_dir
            return
        fi
    done

    # if reaches here, means $DISTRO_V is empty --------------
    # echo -e "\n\nDISTRO_VERSION not found, trying to find it in another way\n" <&2
    cd $cur_dir/../
    # find the actual conf file
    required_file=$(grep -r require $file_full_path | awk '{print $2 }')
    slash_count=$(_count_a_char_in_str "$required_file" "/")
    pos=$(_find_a_char_in_str "$required_file" "/" $slash_count)
    conf_file=${required_file:${pos}+1:${#required_file}}

    # search that file again ---------------
    cd $cur_dir/../
    for item in ./*; do
        cd $cur_dir/../
        # not a directory, continue -----------
        if [[ ! -d $item ]]; then
            continue
        fi
        cd $item
        # in a build directory, continue -------------
        if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
            # echo "a build directory, no need to search" >&2
            continue
        fi
        folder_name=$(basename $item)
        file_path=$(find . -name $conf_file)
        # cannot find the file, continue ---------------
        if [ -z "$file_path" ]; then
            continue
        fi
        file_full_path=$cur_dir/../$folder_name/$file_path
        # find something like 'DISTRO_VERSION = "2.6.4"' in this file
        DISTRO_V=$(_yocto_find_variable_in_file "DISTRO_VERSION" $file_full_path)
        # if there is a $ in the string ...
        DISTRO_V=${DISTRO_V%"$"*}
        if [ ! -z $DISTRO_V ]; then
            # if last char is '-'
            if [ ${DISTRO_V:${#the_line}-1:1} = '-' ]; then
                DISTRO_V=${DISTRO_V:0:${#the_line}-1}
            fi
            echo $DISTRO_V
            cd $cur_dir
            return
        fi
    done
    cd $cur_dir
}

# =============================================================================
# this function should be retired
# todo: it could contain multiple images
function _yocto_find_image_name_in_build_directory() {
    # must be a valid build directory ------------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ]; then
        echo -e "\n ${PRP}_yocto_find_image_name_in_build_directory${NOC}:" >&2
        echo -e "    not in a valid bitbake build directory, exit!!\n" >&2
        echo " "
        return
    fi
    # find two terms ----------------------
    tmp_dir=$(_yocto_find_TMPDIR)
    MACHINE=$(_yocto_find_MACHINE)
    if [ -z $MACHINE ]; then
        # output information to stderr ------
        echo -e "\n ${PRP}_yocto_find_image_name_in_build_directory${NOC}:" >&2
        echo -e "    MACHINE not found, exit!!\n" >&2
        echo " "
        return
    fi

    # the image file can be wic.gz, or wic.zst ----------
    # or it can be something else, should add later
    find_wic_file=$(ls $tmp_dir/deploy/images/$MACHINE | grep wic)
    if [[ ! -z $find_wic_file ]]; then
        wic_file=$(echo $find_wic_file | awk '{print $1}')
    else
        echo " image file (*.wic.*) not found, return empty string" >&2
        echo " "
    fi

    # remove sub-string and whatever behind it ------------
    echo ${wic_file%"-$MACHINE"*}
}

# =============================================================================
# todo: let it work for upboard
# it can be multiple files!
# wic file can be wic.gz, wic.zst, etc
function _yocto_find_image_name() { # $tmp_dir $machine
    tmp_dir=$1
    machine=$2
    images=" "
    file_types="rootfs.wic.gz "
    file_types+="rootfs.wic.zst "
    file_types+="hddimg "

    # no tmp/ directory, nothing was built
    if ! [[ -d $tmp_dir/deploy/images/ ]]; then
        echo " "
        return
    fi

    for f in $file_types; do
        potential_files=$(ls $tmp_dir/deploy/images/$machine/ | grep $f)
        for p in $potential_files; do
            if [[ ! -L $p ]]; then
                images+="${p%"-$machine"*} "
            fi
        done
    done
    echo $images
}

# =============================================================================
function _yocto_find_images_in_tmp_deploy() {
    if [ $(_yocto_check_is_a_build_directory) = 'false' ]; then
        echo " "
        return
    fi
    tmp_dir=$(_yocto_find_TMPDIR)
    if [ ! -d "$tmp_dir" ]; then # no built yet
        echo " "
        return
    fi
    machine=$(_yocto_find_MACHINE)
    images=$(_yocto_find_image_name $tmp_dir $machine)
    echo $images
}

# =============================================================================
function _yocto_find_image_file_from_its_name() {
    tmp_dir=$(_yocto_find_TMPDIR)
    machine=$(_yocto_find_MACHINE)
    image_name=$1
    image_file=""
    file_types="rootfs.wic.gz "
    file_types+="rootfs.wic.zst "
    file_types+="hddimg "

    # no tmp/ directory, nothing was built
    if ! [[ -d $tmp_dir/deploy/images/ ]]; then
        echo " "
        return
    fi

    for f in $file_types; do
        potential_files=$(ls $tmp_dir/deploy/images/$machine/$image_name* | grep $f)
        for p in $potential_files; do
            if [[ ! -L $p ]]; then
                image_file+="$p "
                echo "$image_file"
                return
            fi
        done
    done
}

# =============================================================================
function _yocto_find_bmap_file() { # $wic_file
    wic_file=$1
    # wic.gz -> wic.bmap ---------------
    bmap_file=$(echo $wic_file | sed "s/wic.gz/wic.bmap/g")
    # wic.zst -> wic.bmap ---------------
    if [ -z $bmap_file ]; then
        bmap_file=$(echo $wic_file | sed "s/wic.zst/wic.bmap/g")
    fi
    # other form -----------
    echo $bmap_file
}

# =============================================================================
# find a file in current directory, excluding the build directory
function _yocto_show_bb_or_inc() { # file_full_name filter
    base_dir=${PWD}

    file_full_name=$1
    filter=$2
    for item in ./*; do
        # always start from the base directory
        cd $base_dir
        if [[ ! -d $item ]]; then
            continue
        fi

        cd $item
        folder_name=$(basename $item)
        # filter out the build directory
        if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
            continue
        fi
        # sometimes, the file pattern can be found from files other than *bb or *.inc
        find_files=$(find -type f \( -name "*.bb" -o -name "*.inc" \) -name "*$file_full_name"*)
        not_shown_folder_name=1
        if [ ! -z "$find_files" ]; then
            for file in $find_files; do
                if [[ "$file" = *"$filter"* ]]; then
                    if [ $not_shown_folder_name = 1 ]; then
                        echo -e "\n-------------------------------------------------------"
                        echo -e "${HGRN}$folder_name${NOC}"
                        not_shown_folder_name=0
                    fi
                    echo "$file"
                fi
            done
        fi
    done
    # return back to base directory
    cd $base_dir
}

# =============================================================================
# it should not be started in a build directory
function _yocto_show_conf() { # filter
    if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
        echo -e "\n this is a build directory, stop searching, exit!!\n" >&2
        return
    fi

    conf_name=$1
    filter=$2
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)

    if [ "$exact_vague" = "exact" ]; then
        conf_full_name="$conf_name.conf"
    else
        conf_full_name="$conf_name*.conf"
    fi

    _yocto_show_bb_or_inc $conf_full_name $filter
}

# =============================================================================
function _yocto_show_bb_file() { #filter
    if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
        echo -e "${YLW}this is a build directory, stop searching, exit!!${NOC}" >&2
        return
    fi

    bb_name=$1
    filter=$2
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)
    # find bb file ---------------
    if [ "$exact_vague" = "exact" ]; then
        bb_full_name="$bb_name"
    else
        bb_full_name="$bb_name*"
    fi
    _yocto_show_bb_or_inc $bb_full_name $filter
}

# =============================================================================
function _yocto_list_things() {
    if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
        echo "${YLW}in a build directory, exit!${NOC}"
        return
    fi
    cur_dir=${PWD}

    things=$1
    for item in ./*; do
        cd $cur_dir
        if [[ ! -d $item ]]; then
            continue
        fi
        cd $item
        if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
            continue
        fi
        folder_name=$(basename $item)
        for loop in "./" "./*/" "./*/*/" "./*/*/*/"; do
            find_x=$(ls ${loop}${things} 2>/dev/null)
            if [[ ! -z "$find_x" ]]; then
                echo -e "\n---------------------------------------"
                echo -e "${HGRN}$(basename $item)${NOC}"
                echo "$find_x"
            fi
        done
    done
    echo -e "\n"
    cd $cur_dir
}

# =============================================================================
function _yocto_list_resources() {
    # current folder -------------
    if [ -d .git ]; then
        echo -e "\n${GRN}----------------------------------------------${NOC}"
        folder_name=$(basename $PWD)
        echo -e "${GRN}$folder_name${NOC} (root)"
        branch_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
        echo "remote: $(git remote -v | grep fetch | awk '{print $2}')"
        echo "branch: $branch_name"
        git log --decorate=short --pretty=oneline -n1
    fi

    # iterate all folders ----------
    cur_dir=${PWD}

    for item in ./*; do
        if [[ -d $item ]] && ([[ -d $item/.git ]] || [[ -f $item/.git ]]); then
            echo -e "\n----------------------------------------------"
            cd $item
            folder_name=$(basename "$item")
            printf "${HGRN}$folder_name${NOC}"
            if [[ -d .git ]]; then
                printf " (git repo)\n"
            elif [[ -f .git ]]; then
                printf " (git submodule)\n"
            fi
            branch_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
            echo "remote: $(git remote -v | grep fetch | awk '{print $2}')"
            echo "branch: $branch_name"
            git log --decorate=short --pretty=oneline -n1
            cd $cur_dir
        fi
    done
}

# =============================================================================
function _yocto_list() {
    if [[ $1 = 'distros' ]]; then
        _yocto_list_things "distro*/*.conf"
        return
    fi
    if [[ $1 = 'images' ]]; then
        _yocto_list_things "recipes*/images*/*.bb"
        return
    fi
    if [[ $1 = 'machines' ]]; then
        _yocto_list_things "conf/machine/*.conf"
        return
    fi
    if [[ $1 = 'resources' ]]; then
        _yocto_list_resources
        return
    fi
}

# =============================================================================
# this can only run in a build directory
function _yocto_find_meta_layers() {
    if [ $(_yocto_check_is_a_build_directory) = 'true' ]; then
        layers=" "
        dirs=$(ls ../)
        for i in $dirs; do
            if [[ -f ../$i/.git ]]; then
                layers+="$i "
                continue
            fi
            if compgen -G "../$i/recipe*" >>/dev/null; then
                layers+="$i "
                continue
            fi
            if compgen -G "../$i/meta-*" >>/dev/null; then
                layers+="$i "
                continue
            fi
        done
        echo $layers
    else
        echo " "
    fi
}

# =============================================================================
# this can only run in a build directory
function _yocto_find_images_of_layer() {
    if [ $(_yocto_check_is_a_build_directory) = 'false' ]; then
        echo " "
        return
    fi
    dir=$1
    image_bb=""
    for loop in "./" "./*/" "./*/*/" "./*/*/*/"; do
        image_bb+=$(ls ../$dir/${loop}images 2>/dev/null)
    done
    images=""
    for i in $image_bb; do
        images+="${i%"."*} "
    done
    echo "$images "
}
