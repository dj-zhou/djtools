#!/bin/bash

source $djtools_path/yocto/yocto-env.bash
source $djtools_path/yocto/yocto-find.bash

# =============================================================================
function _yocto_bake_image() { # meta-layer #image-name
    source ../poky/oe-init-build-env . &>/dev/null
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib32:/usr/lib32:/usr/lib/i386-linux-gnu
    bitbake $2
}

# =============================================================================
# must run this function in a build directory
function _yocto_bake_plain_sdk() { # image-file
    if [ $# -lt 1 ]; then
        echo "yocto bake plain-sdk: need the image name"
        return
    fi
    source ../poky/oe-init-build-env . &>/dev/null
    # must be in a build directory ---------------
    if [ $(_yocto_check_is_a_build_directory) = 'false' ]; then
        echo -e "not in a valid bitbake build directory, exit!!"
        return
    fi

    # it can fail to find image name ------------------
    image_file=$(_yocto_find_image_file_from_its_name $1)
    if [ -z $image_file ]; then
        echo -e "image is not built, need to build the image first, exit!!"
        return
    fi
    # finally, build the plain-sdk ------------------
    echo -e "bake the SDK with the command:"
    echo -e "${PRP}  bitbake -c populate_sdk $1${NOC}"
    _press_enter_or_wait_s_continue 5
    bitbake -c populate_sdk $1
}

# =============================================================================
# must run this function in a build directory
# this does not work well
function _yocto_bake_recipe() { # full recipe name
    if [ $# -lt 1 ]; then
        echo "yocto bake recip: need a full recipe name"
        return
    fi
    source ../poky/oe-init-build-env . &>/dev/null
    _show_and_run bitbake -b $1 -c compile
}

# =============================================================================
# $1 must be the device block, for example, /dev/sda
# $2 to all others, can be -f and other options, like image.wic.gz, or *.wic.zst
# todo: let it work for upboard
# notice: it must be in a build directory, and the build directory and poky directory
# should be parallel.

# bmaptool needs to be the one from the SDK (i.e. ~/.--oesdk/xx/yy/environment-setup-armv7vet2hf-neon-fb-linux-gnueabi)
# however, in this script, we "source ../poky/oe-init-build-env ." and it still works fine
function _yocto_flash() { # block-device # image-file # "--skip"
    # argument check -------------------
    if [ $# -lt 1 ]; then
        echo -e "usage:\n   yocto flash /dev/sdx <image name>"
        echo -e "     or \n   yocto flash /dev/sdx -f [filename].wic.gz"
        return
    fi
    # check the device block ------------
    dev_str=$1
    dev=$(_verify_block_device $dev_str)
    if [ -z $dev ]; then
        echo -e "${RED}block device $dev_str not found, exit!!${NOC}"
        echo -e "you can use command \"lsblk\" to find it."
        return
    fi
    echo -e "          SD card: ${INFO}$dev${NOC}"
    card_size_byte=$(_disk_size $dev)
    if [ $card_size_byte -gt 137438953472 ]; then # max size: 128G
        echo -e "${YLW}card too large, a wrong card? Max size supported: 128G${NOC}"
        return
    fi
    card_size=$(_size_human_readable $card_size_byte false)
    if [[ -z "$card_size" ]]; then
        echo -e "${RED}card size not obtained, abort \"yocto flash\" command ${NOC}"
        return
    fi
    echo -e "             size: ${INFO}${card_size}${NOC}"
    source ../poky/oe-init-build-env . &>/dev/null

    # if -f option is used, image_file should be that after -f option
    image_file=$(_find_argument_after_option -f $2 $3 $4 $5 $6 $7 $8)
    # if image_file is not given, try to find it
    if [[ -z "$image_file" || ! -f "$image_file" ]]; then
        # must be in a build folder --------------
        if [ $(_yocto_check_is_a_build_directory) = 'false' ]; then
            echo -e "${RED}not in a valid bitbake build directory, exit!!${NOC}"
            return
        fi
        # find the machine -----------------
        machine=$(_yocto_find_MACHINE)
        if [ -z $machine ]; then
            echo -e "${RED}MACHINE not found, exit!!${NOC}"
            return
        fi
        echo -e "          machine: ${INFO}$machine${NOC}"
        # find tmp/ folder ---------------
        tmp_dir=$(_yocto_find_TMPDIR)
        if [ -z $tmp_dir ]; then
            echo -e "${RED}TMPDIR not found, exit!!${NOC}"
            return
        fi
        # find the wic.gz or wic.zst file ----------
        # if some other target use some other kind of file, update this ------
        image_file=$(_yocto_find_image_file_from_its_name $2)
        if [ -z "$image_file" ]; then
            echo -e "${RED}image file not found, exit!!${NOC}"
            return
        fi
        echo -e "       image name: ${INFO}$2${NOC}"
        echo -e "    file location: ${INFO}$tmp_dir/deploy/images/$machine/${NOC}"
        # if it is a symbolic file ----------
        if [ -L "$image_file" ]; then
            image_file=$(readlink -f $image_file)
        fi
    else
        echo -e "       image file: ${INFO}$image_file${NOC}"
        echo -e "    file location: ${INFO}./${NOC}"
    fi
    # show its file size --------------
    image_size=$(stat -c %s $image_file)
    echo -e "  image file size: ${INFO}$(_size_human_readable $image_size false)${NOC}"

    # shows its creation time --------------
    creation_time=$(stat -c %y $image_file)
    echo -e "image create time: ${INFO}$creation_time${NOC}"

    # wic image should have a bmap file --------------
    bmap_file=$(_yocto_find_bmap_file $image_file)

    # prepare the SD card, umount, chmod 666, etc ------------
    _prepare_sd_card_for_flash $dev

    # finally, flash the image to the SD card ------------------
    # wic.gz or wic.zst file for ARM based board -------------
    # if [[ "$image_file"=*"wic.gz" || "$image_file"=*"wic.zst" ]] ; then
    if [[ ${image_file} = *'wic.gz'* || ${image_file} = *'wic.zst'* ]]; then
        # try always run this before flashing ------------------
        if [[ $# = 3 && $3 = "--skip" ]]; then
            echo -e "skip bitbake check, flash ..."
        else
            echo -e "-----------------------------\n"
            echo -e "run ${INFO}bitbake bmap-tools-native -caddto_recipe_sysroot${NOC}"
            _press_enter_or_wait_s_continue 2
            bitbake bmap-tools-native -caddto_recipe_sysroot
        fi
        if [[ -f "$bmap_file" ]]; then
            # the following command need to use a *.wic.bmap file in the same path
            # of the wic.gz file
            echo -e "bmap file found, run command:"
            echo -e "${INFO}oe-run-native bmap-tools-native bmaptool copy <image> $dev${NOC}"
            _press_enter_or_wait_s_continue 4
            oe-run-native bmap-tools-native bmaptool copy $image_file $dev
        else
            echo -e "bmap file ${YLW}NOT${NOC} found, run command:"
            echo -e "sudo bmaptool copy -nobmap $image_file $dev"
            _press_enter_or_wait_s_continue 4
            sudo bmaptool copy --nobmap $image_file $dev
        fi
        return
    fi
    # hddimg for upboard -------------
    if [[ "${image_file}" = *'hddimg'* ]]; then
        echo -e "run the command:"
        echo -e "${PRP}sudo dd bs=4M if=<image file> | pv | dd of=$dev${NOC}"
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
            shift 2
            _yocto_bake_image $@
            return
        fi
        if [ $2 = 'plain-sdk' ]; then
            shift 2
            _yocto_bake_plain_sdk $@
            return
        fi
        if [ $2 = 'recipe' ]; then
            shift 2
            _yocto_bake_recipe $@
            return
        fi
        return
    fi

    # ------------------------------
    if [ $1 = 'flash' ]; then
        shift 1
        _yocto_flash $@
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
            shift 2
            _yocto_setup_dev_env $@
            return
        fi
        if [ $2 = 'plain-sdk' ]; then
            shift 2
            _yocto_setup_plain_sdk $@
            return
        fi
    fi
    # ------------------------------
    if [ $1 = 'show' ]; then
        if [ $# = 1 ]; then
            _yocto_help
            return
        fi
        if [ $# -lt 3 ]; then
            echo_warn "need more argument, exit!"
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
        if [ $2 = 'image-bb-inc' ]; then
            _yocto_show_bb_file $3 "image"
            return
        fi
        if [ $2 = 'recipe-bb-inc' ]; then
            _yocto_show_bb_file $3 "recipe"
            return
        fi
        return
    fi
    # ------------------------------
    echo -e "${PRP}yocto${NOC}: argument ${RED}$1${NOC} not supported"
    _yocto_help

    # ------------------------------
    cd $cur_dir
    unset cur_dir
}

# =============================================================================
function _yocto_linux() {
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
    bake_list="image plain-sdk recipe "
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
    ACTIONS[recipe]=" "
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
    show_list="distro-conf machine-conf image-bb-inc recipe-bb-inc "
    ACTIONS[show]+="$show_list "
    for i in $show_list; do
        ACTIONS[$i]=" "
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
    complete -F _yocto_linux yocto
# elif [ $system = 'Darwin' ]; then
#     echo "todo"
fi