#/bin/bash

# =============================================================================
# usage:
#   result=$(_is_block_device_mounted sda)
#   echo $result
function _is_block_device_mounted()
{
    if [ ! -n "$1" ] ; then
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
function _disk_size_help()
{
    cat << eom

    _disk_size: wrong usage, use it like:
       _disk_size sda true
       _disk_size /dev/sda true
       _disk_size sda false
       _disk_size /dev/sda false
    
eom
}

# =============================================================================
# example: _disk_size sda true
#          _disk_size /dev/sda false
# if the $2 is true, it only return the size in bytes
# if the $2 is false, it will print necessary information
function _disk_size()
{
    if [ $# -lt 2 ] ; then
        _disk_size_help
        return
    fi
    if [ -b $1 ] ; then
        disk_device=$1
    elif [ -b /dev/$1 ] ; then
        disk_device=/dev/$1
    fi
    find_fz_byte=$(sudo fdisk -l $disk_device | grep "$disk_device")
    fz_byte=$(echo $find_fz_byte | cut -d' ' -f5 | grep -o -E '[0-9]+' | awk 'NR==1 {print $1}')
    _size_calculate $fz_byte $2
}
