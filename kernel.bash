#!/bin/bash

function _kernel_help() {
    echo -e "\n\n ---------------------- kernel ----------------------"
    echo "  Author      : Dingjiang Zhou"
    echo "  Email       : zhoudingjiang@gmail.com "
    echo "  Create Date : 2020-08-01"
    echo " -----------------------------------------------------"
    echo -e "\n First level commands:"
    echo "   config   - to config the _install foldre within the linux kernel"
    echo -e "   MORE IS COMMING\n"
    echo -e " All commands support tab completion\n"
    echo "-----------------------------------------------------"
}

# =============================================================================
function _kernel_find_version() {
    makefile=$1
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"VERSION ="* ]]; then
            VERSION=$(echo $line | awk '{ print $3 }')
        fi
        if [[ $line == *"PATCHLEVEL ="* ]]; then
            PATCHLEVEL=$(echo $line | awk '{ print $3 }')
        fi
        if [[ $line == *"SUBLEVEL ="* ]]; then
            SUBLEVEL=$(echo $line | awk '{ print $3 }')
            break
        fi
    done <$makefile
    echo $VERSION"."$PATCHLEVEL"."$SUBLEVEL
}

# =============================================================================
# this is a script to automate Section VI.6 in document 02-qemu-arm-vexpress.md
# options:
#   -t : target folder, default: _install
#   -b : busybox source folder, default: ../busybox-1.32.0/
#   -i : busybox install folder, default : _install
function _kernel_config_initramfs() {
    cur_dir=${PWD}

    # this command has to be run in a linux kernel folder, otherwise, exit
    if [ ! -f Makefile ]; then
        echo -e "kernel config initramfs: "
        echo -e "   no Makefile found, probably not a Linux kernel folder, exit!"
        return
    fi
    # find the kernel version
    kernel_version=$(_kernel_find_version Makefile)
    echo -e "Linux kernel version: "$kernel_version""

    # find the target folder
    target_folder=$(_find_argument_after_option -t $1 $2 $3 $4 $5 $6 $7 $8)
    # use the default target if it is empty
    if [ -z "$target_folder" ]; then
        target_folder="_install"
    fi
    # echo "target_folder = "$target_folder
    rm -rf $target_folder # remove the target folder first

    # find the busybox root folder
    busybox_folder=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    if [ -z "$busybox_folder" ]; then
        busybox_folder="../busybox-1.32.0" # how to use *?
    fi
    # echo "busybox_folder = "$busybox_folder
    # to check if the folder exists
    if [ ! -d "${busybox_folder}" ]; then
        echo -e " busybox install folder: $busybox_folder not found, exit."
        return
    fi
    # to check busybox version
    busybox_version=$(_kernel_find_version $busybox_folder/Makefile)
    echo -e " busybox_version = "$busybox_version""

    # find the busybox _install folder
    _install_folder=$(_find_argument_after_option -i $1 $2 $3 $4 $5 $6 $7 $8)
    if [ -z "$_install_folder" ]; then
        _install_folder="_install"
    fi
    # echo ?"_install_folder = "$_install_folder
    if [ ! -d "$busybox_folder/$_install_folder" ]; then
        echo -e "busybox may not be compiled, exit."
        return
    fi

    # start the configuration
    echo -e "going to copy $busybox_folder/$_install_folder to the folder"
    _press_enter_or_wait_s_continue 20

    cp $busybox_folder/$_install_folder -r .
    cd $_install_folder
    mkdir etc dev mnt lib
    mkdir -p etc/init.d/

    file="etc/init.d/rcS"
    echo -e "going to creete file: $file"
    _press_enter_or_wait_s_continue 20

    touch $file
    echo "#!/bin/sh" >>$file
    echo "mkdir -p /proc" >>$file
    echo "mkdir -p /tmp" >>$file
    echo "mkdir -p /sys" >>$file
    echo "mkdir -p /mnt" >>$file
    echo "/bin/mount -a" >>$file
    echo "mkdir -p /dev/pts" >>$file
    echo "mount -t devpts devpts /dev/pts" >>$file
    echo "echo /sbin/mdev > /proc/sys/kernel/hotplug" >>$file
    echo "mdev -s" >>$file
    chmod +x $file

    file="etc/fstab"
    echo -e "going to creete file: $file"
    _press_enter_or_wait_s_continue 20

    touch $file
    echo "proc /proc proc defaults 0 0" >>$file
    echo "tmpfs /tmp tmpfs defaults 0 0" >>$file
    echo "sysfs /sys sysfs defaults 0 0" >>$file
    echo "tmpfs /dev tmpfs defaults 0 0" >>$file
    echo "debugfs /sys/kernel/debug debugfs defaults 0 0" >>$file

    file="etc/inittab"
    echo -e "going to creete file: $file"
    _press_enter_or_wait_s_continue 20

    touch $file
    echo "::sysinit:/etc/init.d/rcS" >>$file
    echo "::respawn:-/bin/sh" >>$file
    echo "::askfirst:-/bin/sh" >>$file
    echo "::ctrlaltdel:/bin/umount -a -r" >>$file

    echo -e "going to creete device nodes in dev/"
    _press_enter_or_wait_s_continue 20

    cd dev
    sudo mknod -m 666 tty1 c 4 1
    sudo mknod -m 666 tty2 c 4 2
    sudo mknod -m 666 tty3 c 4 3
    sudo mknod -m 666 tty4 c 4 4
    sudo mknod console c 5 1
    sudo mknod null c 1 3

    echo -e "going to copy the arm linux libraries into lib/"
    _press_enter_or_wait_s_continue 20

    cd ../
    cp /usr/arm-linux-gnueabi/lib/* lib/ -rfp

    echo -e " next, you should config the Linux kernel by:"
    echo "   make vexpress_defconfig ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-"
    echo "   make menuconfig ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-"
    echo -e " you should put \"_install\" into: General setup ---> \"Initramfs source file(s) \""

    cd $cur_dir
}

# =============================================================================
function kernel {
    if [ $# -eq 0 ]; then
        _kernel_help
        return
    fi
    # --------------------------------------
    if [ $1 = 'config' ]; then
        if [ $# -eq 1 ]; then
            _kernel_help
            return
        fi
        if [ $2 = 'initramfs' ]; then
            _kernel_config_initramfs $3 $4 $5 $6 $7 $8 $9 ${10}
            return
        fi
        return
    fi
    _kernel_help
}

# =============================================================================
# auto completion reference:
# https://blog.bouzekri.net/2017-01-28-custom-bash-autocomplete-script.html
_kernel() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=(
        "config"
    )

    # declare an associative array for options
    declare -A ACTIONS
    # -------------------------------------------------------------------------
    # -------------------------------------------------------------------------
    ACTIONS[config]+="initramfs "
    ACTIONS[initramfs]=" "
    # -------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

complete -F _kernel kernel
