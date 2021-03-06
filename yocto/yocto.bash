#!/bin/bash

source $djtools_path/yocto/yocto-env.bash
source $djtools_path/yocto/yocto-find.bash

# =============================================================================
function _yocto_bake_image() { # meta-layer #image-name
    source ../poky/oe-init-build-env . &>/dev/null
    bitbake $2
}

# =============================================================================
# must run this function in a build directory
function _yocto_build_plain_sdk() { # image-file
    if [ $# -lt 1 ]; then
        echo "yocto build plain-sdk: need the image name"
        return
    fi
    source ../poky/oe-init-build-env . &>/dev/null
    # must be in a build directory ---------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ]; then
        echo -e "not in a valid bitbake build directory, exit!\n"
        return
    fi

    # it can fail to find image name ------------------
    image_file=$(_yocto_find_image_file_from_its_name $1)
    if [ -z $image_file ]; then
        echo -e "image is not built, need to build the image first, exit!\n"
        return
    fi
    # finally, build the plain-sdk ------------------
    echo -e "\n is going to build the SDK with the command:"
    echo -e "   ${PRP}bitbake -c populate_sdk $1${NOC}\n"
    _press_enter_or_wait_s_continue 5
    bitbake -c populate_sdk $1
}

# =============================================================================
# $1 must be the device block, for example, /dev/sda
# $2 to all others, can be -f and other options, like image.wic.gz, or *.wic.zst
# todo: let it work for upboard
# notice: it must be in a build directory, and the build directory and poky directory
# should be parallel.
function _yocto_flash() { # block-device # image-file
    # argument check -------------------
    if [ $# -lt 1 ]; then
        echo -e "\n usage:\n   yocto flash /dev/sdx <image name>"
        echo -e "      or \n   yocto flash /dev/sdx -f [filename].wic.gz"
        return
    fi
    # check the device block ------------
    dev_str=$1
    dev=$(_verify_block_device $dev_str)
    if [ -z $dev ]; then
        echo -e "\n block device $dev_str not found, exit!!"
        echo -e " you can use command \"lsblk\" to find it.\n"
        return
    fi
    echo -e "          SD card: ${GRN}$dev_str${NOC}"
    echo -e "             size: ${GRN}$(_disk_size $dev_str false)${NOC}"

    source ../poky/oe-init-build-env . &>/dev/null

    # if -f option is used, image_file should be that after -f option
    image_file=$(_find_argument_after_option -f $2 $3 $4 $5 $6 $7 $8)
    # if image_file is not given, try to find it
    if [[ -z "$image_file" || ! -f "$image_file" ]]; then
        # must be in a build folder --------------
        if [ $(_yocto_check_is_a_build_directory) = 'false' ]; then
            echo -e "\n ${RED}not in a valid bitbake build directory, exit!${NOC}\n"
            return
        fi
        # find the machine -----------------
        machine=$(_yocto_find_MACHINE)
        if [ -z $machine ]; then
            echo -e "\n ${RED} MACHINE not found, exit!!${NOC}"
            return
        fi
        echo -e "          machine: ${GRN}$machine${NOC}"
        # find tmp/ folder ---------------
        tmp_dir=$(_yocto_find_TMPDIR)
        if [ -z $tmp_dir ]; then
            echo "TMPDIR not found, exit!\n"
            return
        fi
        # find the wic.gz or wic.zst file ----------
        # if some other target use some other kind of file, update this ------
        image_file=$(_yocto_find_image_file_from_its_name $2)
        if [ -z "$image_file" ]; then
            echo -e "image file not found, exit!\n"
            return
        fi
        echo -e "       image name: ${GRN}$2${NOC}"
        echo -e "    file location: ${GRN}$tmp_dir/deploy/images/$machine/${NOC}"
        # if it is a symbolic file ----------
        if [ -L "$image_file" ]; then
            image_file=$(readlink -f $image_file)
        fi
    else
        echo -e "       image file: ${GRN}$image_file${NOC}"
        echo -e "    file location: ${GRN}./${NOC}"
    fi
    # show its file size --------------
    image_size=$(stat -c %s $image_file)
    echo -e "       image size: ${GRN}$(_size_calculate $image_size false)${NOC}"

    # shows its creation time --------------
    creation_time=$(stat -c %y $image_file)
    echo -e "    creation time: ${GRN}$creation_time${NOC}"

    # wic image should have a bmap file --------------
    bmap_file=$(_yocto_find_bmap_file $image_file)

    # prepare the SD card, umount, chmod 666, etc ------------
    _prepare_sd_card_for_flash $dev

    # finally, flash the image to the SD card ------------------
    # wic.gz or wic.zst file for ARM based board -------------
    # if [[ "$image_file"=*"wic.gz" || "$image_file"=*"wic.zst" ]] ; then
    if [[ ${image_file} = *'wic.gz'* || ${image_file} = *'wic.zst'* ]]; then
        # try always run this before flashing ------------------
        echo -e "-----------------------------\n"
        echo -e " run ${PRP}bitbake bmap-tools-native -caddto_recipe_sysroot${NOC}"
        _press_enter_or_wait_s_continue 2
        bitbake bmap-tools-native -caddto_recipe_sysroot
        if [[ -f "$bmap_file" ]]; then
            # the following command need to use a *.wic.bmap file in the same path
            # of the wic.gz file
            echo -e "\n bmap file found, run command:"
            echo -e " ${PRP}oe-run-native bmap-tools-native bmaptool copy <image> $dev${NOC}\n"
            _press_enter_or_wait_s_continue 4
            oe-run-native bmap-tools-native bmaptool copy $image_file $dev
        else
            echo -e "\n bmap file ${YLW}NOT${NOC} found, run command:"
            echo -e " sudo bmaptool copy -nobmap $image_file $dev\n"
            _press_enter_or_wait_s_continue 4
            sudo bmaptool copy --nobmap $image_file $dev
        fi
        return
    fi
    # hddimg for upboard -------------
    if [[ "${image_file}" = *'hddimg'* ]]; then
        echo -e "\nrun the command:"
        echo -e "${PRP}  sudo dd bs=4M if=<image file> | pv | dd of=$dev${NOC}"
        # sudo dd bs=4M if=$image_file of=$dev status=progress
        sudo dd bs=4M if=$image_file | pv | dd of=$dev
        sync
        return
    fi
}

# =============================================================================
function yocto() {
    cur_dir=${PWD}

    # ------------------------------
    if [ $# -eq 0 ]; then
        _yocto_help
        return
    fi
    # ------------------------------
    if [ $1 = 'bake' ]; then
        if [ $2 = 'image' ]; then
            _yocto_bake_image $3 $4 $5
            return
        fi
        if [ $2 = 'plain-sdk' ]; then
            _yocto_build_plain_sdk $3 $4 $5 $6 $7
            return
        fi
        return
    fi

    # ------------------------------
    if [ $1 = 'flash' ]; then
        _yocto_flash $2 $3 $4 $5 $6 $7 $8 $9 ${10}
        return
    fi
    # ------------------------------
    if [ $1 = 'list' ]; then
        if [ $# = 1 ]; then
            _yocto_help
            return
        fi
        _yocto_list "$2"
        return
    fi
    # ------------------------------
    if [ $1 = 'setup' ]; then
        if [ $# = 1 ]; then
            _yocto_help
            return
        fi
        if [ $2 = 'dev-env' ]; then
            _yocto_setup_dev_env $3 $4 $5 $6 $7
            return
        fi
        if [ $2 = 'plain-sdk' ]; then
            _yocto_setup_plain_sdk $3 $4 $5 $6 $7
            return
        fi
    fi
    # ------------------------------
    if [ $1 = 'show' ]; then
        if [ $# = 1 ]; then
            _yocto_help
            return
        fi
        if [ $2 = 'distro-conf' ]; then
            _yocto_show_conf $3 "distro" $4 $5 $6 $7 $8 $9
            return
        fi
        if [ $2 = 'machine-conf' ]; then
            _yocto_show_conf $3 "machine" $4 $5 $6 $7 $8 $9
            return
        fi
        if [ $2 = 'image-bb' ]; then
            _yocto_show_bb_file $3 "image" $4 $5 $6 $7 $8 $9
            return
        fi
        if [ $2 = 'recipe-bb' ]; then
            _yocto_show_bb_file $3 "recipe" -e vague
            return
        fi
        if [ $2 = 'image-inc' ]; then
            _yocto_show_inc_file $3 "image" $4 $5 $6 $7 $8 $9
            return
        fi
        return
    fi
    # ------------------------------
    echo -e "\n ${PRP}yocto${NOC}: argument ${RED}$1${NOC} not supported\n"
    _yocto_help

    # ------------------------------
    cd $cur_dir
    unset cur_dir
}

# =============================================================================
function _yocto() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        bake
        flash
        list
        setup
        show
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    bake_list="image plain-sdk "
    ACTIONS[bake]="$bake_list "
    meta_layer_list="$(_yocto_find_meta_layers) "
    ACTIONS[image]="$meta_layer_list "
    for i in $meta_layer_list; do
        image_recipe_list="$(_yocto_find_images_of_layer $i) "
        ACTIONS[$i]="$image_recipe_list "
        for j in $image_recipe_list; do
            ACTIONS[j]=" "
        done
    done
    # ------------------------------------------------------------------------
    setup_list="dev-env plain-sdk "
    ACTIONS[setup]="$setup_list "
    for i in $setup_list; do
        ACTIONS[$i]=" "
    done
    plain_sdk_list="$(_yocto_find_images_in_tmp_deploy) "
    ACTIONS["plain-sdk"]="$plain_sdk_list "
    for i in $plain_sdk_list; do
        ACTIONS[$i]=" "
    done
    # ------------------------------------------------------------------------
    block_device_list="$(_find_block_device)"
    ACTIONS[flash]="$block_device_list "
    for i in $block_device_list; do
        image_file_list="$(_yocto_find_images_in_tmp_deploy) "
        ACTIONS[$i]="$image_file_list "
        for j in $image_file_list; do
            ACTIONS[$j]=" "
        done
    done

    # smart tab-completion for -f option ----------------
    image_files="$(ls . | grep wic.gz) "
    image_files+="$(ls . | grep wic.zst) "
    ACTIONS[-f]="$image_files "
    for i in $image_files; do
        ACTIONS[$i]=" "
    done
    # ------------------------------------------------------------------------
    list_list="distros images machines resources "
    ACTIONS[list]+="$list_list "
    for i in $list_list; do
        ACTIONS[$i]=" "
    done

    # ------------------------------------------------------------------------
    show_list="distro-conf machine-conf image-bb recipe-bb "
    ACTIONS[show]+="$show_list "
    for i in $show_list; do
        ACTIONS[$i]=" "
    done
    ACTIONS[-e]="exact vague "
    ACTIONS[exact]=" "
    ACTIONS[vague]=" "

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
complete -F _yocto yocto
