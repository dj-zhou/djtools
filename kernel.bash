#!/bin/bash

function _kernel_help()
{
    echo -e "\n\n---------------------- kernel ----------------------"
    echo " Author      : Dingjiang Zhou"
    echo " Email       : zhoudingjiang@gmail.com "
    echo " Create Date : 2020-08-01"
    echo "-----------------------------------------------------"
    echo -e "\n First level commands:"
    echo "   config   - to config the _install foldre within the linux kernel"
    echo -e "   MORE IS COMMING\n"
    echo -e " All commands support tab completion\n"
    echo "-----------------------------------------------------"
}

# =============================================================================
function _kernel_find_version()
{
    makefile=$1
    while IFS='' read -r line || [[ -n "$line" ]] ; do
        if [[ $line == *"VERSION ="* ]] ; then
            VERSION=`echo $line | awk '{ print $3 }'`
        fi
        if [[ $line == *"PATCHLEVEL ="* ]] ; then
            PATCHLEVEL=`echo $line | awk '{ print $3 }'`
        fi
        if [[ $line == *"SUBLEVEL ="* ]] ; then
            SUBLEVEL=`echo $line | awk '{ print $3 }'`
            break
        fi
    done < $makefile
    echo $VERSION"."$PATCHLEVEL"."$SUBLEVEL
}

# =============================================================================
# this is a script to automate Section VI.6 in document 02-qemu-arm-vexpress.md
# options:
#   -t : target folder, default: _install
#   -b : busybox source folder, default: ../busybox-1.32.0/
#   -i : busybox install folder, default : _install
function _kernel_config_initramfs()
{
    current_folder=${PWD}

    # this command has to be run in a linux kernel folder, otherwise, exit
    if [ ! -f Makefile ] ; then
        echo -e "\n kernel config initramfs: "
        echo -e "   no Makefile found, probably not a Linux kernel folder, exit!\n"
        return
    fi
    # find the kernel version
    kernel_version=$(_kernel_find_version Makefile)
    echo -e "\n Linux kernel version: "$kernel_version"\n"
    
    # find the target folder
    target_folder=$(_find_argument_after_option -t $1 $2 $3 $4 $5 $6 $7 $8)
    # use the default target if it is empty
    if [ -z "$target_folder" ] ; then
        target_folder="_install"
    fi
    # echo "target_folder = "$target_folder
    rm -rf $target_folder  # remove the target folder first

    # find the busybox root folder
    busybox_folder=$(_find_argument_after_option -b $1 $2 $3 $4 $5 $6 $7 $8)
    if [ -z "$busybox_folder" ] ; then
        busybox_folder="../busybox-1.32.0" # how to use *?
    fi
    # echo "busybox_folder = "$busybox_folder
    # to check if the folder exists
    if [ ! -d "${busybox_folder}" ] ; then
        echo -e " busybox install folder: $busybox_folder not found, exit.\n"
        return
    fi
    # to check busybox version
    busybox_version=$(_kernel_find_version $busybox_folder/Makefile)
    echo -e " busybox_version = "$busybox_version"\n"

    # find the busybox _install folder
    _install_folder=$(_find_argument_after_option -i $1 $2 $3 $4 $5 $6 $7 $8)
    if [ -z "$_install_folder" ] ; then
        _install_folder="_install"
    fi
    # echo ?"_install_folder = "$_install_folder
    if [ ! -d "$busybox_folder/$_install_folder" ] ; then
        echo -e "\n busybox may not be compiled, exit.\n"
        return
    fi

    # start the configuration
    echo -e "\n going to copy $busybox_folder/$_install_folder to the folder \n"
    _press_enter_to_continue

    cp $busybox_folder/$_install_folder -r .
    cd $_install_folder
    mkdir etc dev mnt lib
    mkdir -p etc/init.d/
    
    echo -e "\n going to creete file: etc/init.d/rcS \n"
    _press_enter_to_continue

    touch etc/init.d/rcS
    echo "#!/bin/sh" >> etc/init.d/rcS
    echo "mkdir -p /proc" >> etc/init.d/rcS
    echo "mkdir -p /tmp" >> etc/init.d/rcS
    echo "mkdir -p /sys" >> etc/init.d/rcS
    echo "mkdir -p /mnt" >> etc/init.d/rcS
    echo "/bin/mount -a" >> etc/init.d/rcS
    echo "mkdir -p /dev/pts" >> etc/init.d/rcS
    echo "mount -t devpts devpts /dev/pts" >> etc/init.d/rcS
    echo "echo /sbin/mdev > /proc/sys/kernel/hotplug" >> etc/init.d/rcS
    echo "mdev -s" >> etc/init.d/rcS
    chmod +x etc/init.d/rcS
    
    echo -e "\n going to creete file: etc/fstab \n"
    _press_enter_to_continue

    touch etc/fstab
    echo "proc /proc proc defaults 0 0" >> etc/fstab
    echo "tmpfs /tmp tmpfs defaults 0 0" >> etc/fstab
    echo "sysfs /sys sysfs defaults 0 0" >> etc/fstab
    echo "tmpfs /dev tmpfs defaults 0 0" >> etc/fstab
    echo "debugfs /sys/kernel/debug debugfs defaults 0 0" >> etc/fstab

    echo -e "\n going to creete file: etc/inittab \n"
    _press_enter_to_continue

    touch etc/inittab
    echo "::sysinit:/etc/init.d/rcS" >> etc/inittab
    echo "::respawn:-/bin/sh" >> etc/inittab
    echo "::askfirst:-/bin/sh" >> etc/inittab
    echo "::ctrlaltdel:/bin/umount -a -r" >> etc/inittab

    echo -e "\n going to creete device nodes in dev/ \n"
    _press_enter_to_continue

    cd dev
    sudo mknod -m 666 tty1 c 4 1
    sudo mknod -m 666 tty2 c 4 2
    sudo mknod -m 666 tty3 c 4 3
    sudo mknod -m 666 tty4 c 4 4
    sudo mknod console c 5 1
    sudo mknod null c 1 3

    echo -e "\n going to copy the arm linux libraries into lib/ \n"
    _press_enter_to_continue

    cd ../
    cp /usr/arm-linux-gnueabi/lib/* lib/ -rfp

    echo -e " next, you should config the Linux kernel by:"
    echo    "   make vexpress_defconfig ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-"
    echo    "   make menuconfig ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-"
    echo -e " you should put \"_install\" into: General setup ---> \"Initramfs source file(s) \"\n"
    
    cd $current_folder
}

# =============================================================================
function kernel {
    if [ $# -eq 0 ] ; then
        _kernel_help
        return
    fi
    # --------------------------------------
    if [ $1 = 'config' ] ; then
        if [ $# -eq 1 ] ; then
            _kernel_help
            return
        fi
        if [ $2 = 'initramfs' ] ; then
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
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

complete -F _kernel kernel
