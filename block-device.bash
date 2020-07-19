#/bin/bash

# =============================================================================
# usage:
#   result=$(_is_block_device_mounted sda)
#   echo $result
#
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

function _disk_size()
{
    if [ ! -n "$1" ] ; then
        # printf "usage: _is_block_device_mounted sda\n"
        echo "_disk_size: wrong usage"
        return
    fi
    disk_device=/dev/$1
    SIZE=`sudo fdisk -l $disk_device | grep "$disk_device" | cut -d' ' -f5 | grep -o -E '[0-9]+' | awk 'NR==1 {print $1}'`
    echo $SIZE
}