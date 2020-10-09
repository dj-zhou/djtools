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
function _yocto_find_image_name()
{
    current_folder=${PWD}
    # must be a valid buid directory ------------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ] ; then
        echo -e "\n ${PRP}_yocto_find_image_name${NOC}:"
        echo -e "    not in a valid bitbake build directory, exit!!\n"
        return
    fi
    # find tmp/ folder ---------------
    TMPDIR=$(_yocto_find_TMPDIR)
    if [ -z $TMPDIR ] ; then
        if [ -d "tmp" ] ; then
            TMPDIR="tmp"
        fi
    fi
    # echo $TMPDIR

    MACHINE=$(_yocto_find_MACHINE)
    if [ -z $MACHINE ] ; then
        # echo -e "\n ${PRP}_yocto_find_image_name${NOC}:"
        # echo -e "    MACHINE not found, exit!!\n"
        return
    fi
    # echo $MACHINE

    cd $TMPDIR/deploy/images/$MACHINE
    # the image file can be wic.gz ----------
    find_wic_file=$(ls | grep wic.gz)
    # echo $find_wic_file
    if [[ ! -z $find_wic_file ]] ; then
        wic_file=$(echo $find_wic_file | awk '{print $1}')
    fi
    # it can also be wic.zst file ------------
    # in distro file: IMAGE_FSTYPES += "tar.zst"
    # in machine.conf: IMAGE_FSTYPES = "wic.bmap wic.zst"
    if [[ -z $find_wic_file ]] ; then
        find_wic_file=$(ls | grep wic.zst)
        if [[ ! -z $find_wic_file ]] ; then
            wic_file=$(echo $find_wic_file | awk '{print $1}')
        fi
    fi
    # echo "wic_file = $wic_file"
    image_name=${wic_file%"-$MACHINE"*}
    echo $image_name # this is the output
    cd $current_folder
}

# =============================================================================
# the variable MACHINE defined in conf/local.conf, can be any of the forms:
# MACHINE = "xxxx", MACHINE = 'xxxx'
# MACHINE ?= "xxxx", MACHINE ?= 'xxxx'
# MACHINE ??= "xxxx", MACHINE ??= 'xxxx'
function _yocto_find_variable_in_file() # $variable $file
{
    variable=$1
    file=$2
    value=$(grep "^$variable = " $file | awk '{print $3 }' | \
              sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ] ; then
        echo $value
        return
    fi
    value=$(grep "^$variable ?= " $file | awk '{print $3 }' | \
              sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ] ; then
        echo $value
        return
    fi
    value=$(grep "^$variable ??= " $file | awk '{print $3 }' | \
              sed 's/"//g' | sed "s/'//g")
    if [ ! -z $value ] ; then
        echo $value
        return
    fi
    echo " " # not found
}

# =============================================================================
function _yocto_find_MACHINE()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
        MACHINE=$(_yocto_find_variable_in_file "MACHINE" conf/local.conf)
        echo $MACHINE
    else
        echo " " # not found
    fi
}

# =============================================================================
function _yocto_find_TMPDIR()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
        TMPDIR=$(_yocto_find_variable_in_file "TMPDIR" conf/local.conf)
        echo $TMPDIR
    else
        echo "tmp" # not found, return empty!!
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
        echo " " # not found, return empty!!
    fi
}

# =============================================================================
function _yocto_find_DISTRO_VERSION()
{
    DISTRO=$(_yocto_find_DISTRO)
    # if DISTRO is not found, cannot find its version
    if [ -z $DISTRO ] ; then
        echo " "
    fi

    # then find $DISTRO.conf, in which, to find something like 'DISTRO_VERSION = "2.6.4"'
    # however, this file can require some other find, then ... it can be too hard
    current_folder=${PWD}
    cd ..

    for item in ./*; do
        cd $current_folder
        cd ..
        if [[ -d $item ]] ; then
            # echo $item
            cd $item
            folder_name=$(basename $item)
            if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
                # echo "a build directory"
                continue
            fi
            file_path=$(find . -name $DISTRO.conf)
            if [ ! -z "$file_path" ] ; then
                file_full_path=$current_folder/../$folder_name/$file_path
                # find something like 'DISTRO_VERSION = "2.6.4"' in this file
                DISTRO_V=$(_yocto_find_variable_in_file "DISTRO_VERSION" $file_full_path)
                if [ ! -z $DISTRO_V ] ; then
                    echo $DISTRO_V
                    cd $current_folder
                    return
                # else
                    # if contains "requre ...", check that file
                    # ...
                fi
            fi
        fi
    done
    cd $current_folder
}

# =============================================================================
function _yocto_find_a_file() # $file_full_name
{
    file_full_name=$1
    current_folder=${PWD}
    for item in ./*; do
        cd $current_folder
        if [[ -d $item ]] ; then
            cd $item
            folder_name=$(basename $item)
            if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
                continue
            fi
            find_file=$(find -name "*$file_full_name")
            if [ ! -z "$find_file" ] ; then
                echo -e "\n ${GRN}---------------------------------------"
                echo -e " $folder_name${NOC}"
                echo "$find_file"
            fi
        fi
    done
    echo -e "\n"
    cd $current_folder
}

# =============================================================================
function _yocto_find_conf()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ;then
        echo -e "\n this is a build directory, stop search, exit!!\n"
        return
    fi

    conf_name=$1
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)

    if [ "$exact_vague" = "exact" ] ; then
        conf_full_name="$conf_name.conf"
    else
        conf_full_name="$conf_name*.conf"
    fi
    
    _yocto_find_a_file $conf_full_name
}

# =============================================================================
function _yocto_find_bb_inc()
{
    if [ $(_yocto_check_is_a_build_directory) = 'true' ] ;then
        echo -e "\n this is a build directory, stop search, exit!!\n"
        return
    fi

    bb_name=$1
    exact_vague=$(_find_argument_after_option -e $1 $2 $3 $4 $5 $6 $7 $8)
    echo "exact_vague = $exact_vague"
    # find bb file ---------------
    for file_suf in "bb" "inc" ; do
        if [ "$exact_vague" = "exact" ] ; then
            bb_full_name="$bb_name.$file_suf"
        else
            bb_full_name="$bb_name*.$file_suf"
        fi
        _yocto_find_a_file $bb_full_name
    done
}

# =============================================================================
function _yocto_list_images()
{
    current_folder=${PWD}

    echo -e "\n${PRP}yocto list images ${NOC}"
    for item in ./*; do
        cd $current_folder
        if [[ -d $item ]] ; then
            # echo $item
            cd $item
            folder_name=$(basename $item)
            if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
                # echo "a build directory"
                continue
            fi
            find_1=$(ls  ./recipes*/images*/*.bb 2>/dev/null)
            find_2=$(ls  ./*/recipes*/images*/*.bb 2>/dev/null)
            find_3=$(ls  ./*/*/recipes*/images*/*.bb 2>/dev/null)
            find_4=$(ls  ./*/*/*/recipes*/images*/*.bb 2>/dev/null)
            if [ ! -z "$find_1" ] || [ ! -z "$find_2" ] || \
               [ ! -z "$find_3" ] || [ ! -z "$find_4" ] ; then
                echo -e "\n ${GRN}---------------------------------------"
                echo -e " $folder_name${NOC}"
            fi
            if [ ! -z "$find_1" ] ; then
                echo "$find_1"
            fi
            if [ ! -z "$find_2" ] ; then
                echo "$find_2"
            fi
            if [ ! -z "$find_3" ] ; then
                echo "$find_3"
            fi
            if [ ! -z "$find_4" ] ; then
                echo "$find_4"
            fi
        fi
    done
    echo -e "\n"
    cd $current_folder
}

# =============================================================================
function _yocto_list_machines()
{
    current_folder=${PWD}

    echo -e "\n${PRP}yocto list machines ${NOC}"
    for item in ./*; do
        cd $current_folder
        if [[ -d $item ]] ; then
            # echo $item
            cd $item
            folder_name=$(basename $item)
            if [ $(_yocto_check_is_a_build_directory) = 'true' ] ; then
                # echo "a build directory"
                continue
            fi
            find_1=$(ls  ./conf/machine/*.conf 2>/dev/null)
            find_2=$(ls  ./*/conf/machine/*.conf 2>/dev/null)
            find_3=$(ls  ./*/*/conf/machine/*.conf 2>/dev/null)
            find_4=$(ls  ./*/*/*/conf/machine/*.conf 2>/dev/null)
            if [ ! -z "$find_1" ] || [ ! -z "$find_2" ] || \
               [ ! -z "$find_3" ] || [ ! -z "$find_4" ] ; then
                echo -e "\n ${GRN}---------------------------------------"
                echo -e " $folder_name${NOC}"
            fi
            if [ ! -z "$find_1" ] ; then
                echo "$find_1"
            fi
            if [ ! -z "$find_2" ] ; then
                echo "$find_2"
            fi
            if [ ! -z "$find_3" ] ; then
                echo "$find_3"
            fi
            if [ ! -z "$find_4" ] ; then
                echo "$find_4"
            fi
        fi
    done
    echo -e "\n"
    cd $current_folder
}

# =============================================================================
function _yocto_list_resources()
{
    # current folder -------------
    if [ -d .git ] ; then
        echo -e "\n${GRN} ----------------------------------------------${NOC}"
        folder_name=$(basename $PWD)
        echo -e " ${GRN}$folder_name${NOC} (root)"
        branch_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
        echo " remote: $(git remote -v | grep fetch | awk '{print $2}')"
        echo " branch: $branch_name"
        git log --decorate=short --pretty=oneline -n1
    fi

    # iterate all folders ----------
    current_folder=${PWD}
    
    for item in ./*; do
        if [[ -d $item ]] && ( [[ -d $item/.git ]] || [[ -f $item/.git ]] ) ; then
            echo -e "\n${GRN} ----------------------------------------------${NOC}"
            cd $item
            folder_name=$(basename "$item")
            printf "${GRN}$folder_name${NOC}"
            if [[ -d .git ]] ; then
                printf " (git repo)\n"
            elif [[ -f .git ]] ; then
                printf " (git submodule)\n"
            fi
            branch_name=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
            echo " remote: $(git remote -v | grep fetch | awk '{print $2}')"
            echo " branch: $branch_name"
            git log --decorate=short --pretty=oneline -n1
            cd $current_folder
        fi
    done
}
