#!/bin/bash

# =============================================================================
# usage:
#   result=$(_is_block_device_mounted sda)
#   echo $result
function _is_block_device_mounted() {
    if [ ! -n "$1" ]; then
        # printf "usage: _is_block_device_mounted sda\n"
        echo "_is_block_device_mounted: wrong usage"
        return
    fi

    block_device=/dev/$1
    sudo mount | grep '^/' | grep -q $block_device

    if [ $? -ne 1 ]; then # $? is usuall 0 if mounted
        # printf "%s is mounted.\r\n" $block_device
        echo "yes"
    else
        # printf "%s is NOT mounted.\r\n" $block_device
        echo "no"
    fi
}

# =============================================================================
function _disk_size_help() {
    cat <<eom
    _disk_size: wrong usage, use it like:
       _disk_size sda
       _disk_size /dev/sda
eom
}

# =============================================================================
# example:
#          _disk_size sda
#          _disk_size /dev/sda
# it only return size in bytes, to get human readable size, call _size_human_readable() function
function _disk_size() {
    if [[ $# -lt 1 ]]; then
        _disk_size_help
        return
    fi
    if [[ -b "$1" ]]; then
        disk_device=$1
    elif [[ -b "/dev/$1" ]]; then
        disk_device=/dev/$1
    fi
    # todo: the error "fdisk: cannot open /dev/sda: No such file or directory" is
    # not handled
    find_fz_byte=$(sudo fdisk -l $disk_device | grep "$disk_device")
    if [[ -z "$find_fz_byte" ]]; then
        echo -e "${RED}$disk_device error, return with nothing${NOC}" 1>&2 # to stderr
        return
    fi
    fz_byte=$(echo $find_fz_byte | cut -d' ' -f5 | grep -o -E '[0-9]+' |
        awk 'NR==1 {print $1}')
    echo $fz_byte
}

# =============================================================================
function _verify_block_device() {
    dev_to_check=$1
    if [ -b "$dev_to_check" ]; then
        echo $dev_to_check
        return
    fi
    if [ -b "/dev/${dev_to_check}" ]; then
        echo "/dev/${dev_to_check}"
        return
    fi
    echo " " # not found
}

# =============================================================================
# use &> /dev/null to make it quiet
function _prepare_sd_card_for_flash() {
    dev=$1
    sudo umount ${dev}?* &>/dev/null
    # this only work for a particular filesystem type
    # printf "o\nn\np\n1\n\n\nw\n" | sudo fdisk "$dev"
    sudo dd if=/dev/zero of=$dev bs=4M count=1 conv=notrunc &>/dev/null

    sudo mkfs.ext4 "${dev}1" &>/dev/null

    sudo chmod 666 $dev &>/dev/null
}

# =============================================================================
function _find_block_device() {
    devices="/dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde "
    devices+="/dev/sdf /dev/sdg /dev/sdh "
    existed_devices=" "
    for d in $devices; do
        if [ -b "$d" ]; then
            existed_devices+="$d "
        fi
    done
    echo "$existed_devices"
}
