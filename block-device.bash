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
    if [ -b "$1" ] ; then
        disk_device=$1
    elif [ -b "/dev/$1" ] ; then
        disk_device=/dev/$1
    fi
    find_fz_byte=$(sudo fdisk -l $disk_device | grep "$disk_device")
    fz_byte=$(echo $find_fz_byte | cut -d' ' -f5 | grep -o -E '[0-9]+' | \
              awk 'NR==1 {print $1}')
    _size_calculate $fz_byte $2
}

# =============================================================================
function _find_block_device()
{
    dev_to_check=$1
    # echo "dev_to_check = "$dev_to_check
    if [ -b "$dev_to_check" ] ; then
        echo $dev_to_check
        return
    fi
    if [ -b "/dev/${dev_to_check}" ] ; then
        echo "/dev/${dev_to_check}"
        return
    fi
    echo " " # not found
}

# =============================================================================
function _prepare_sd_card_for_flash()
{
    sd_card=$1

    # umount all partitions: /dev/sda1; /dev/sda2; /dev/sda3; etc
    for i in {1..100} ; do
        partition=$sd_card"${i}"
        if [ -b "$partition" ] ; then
            # check if mounted
            sudo mount | grep '^/' | grep -q $partition
            if [ "$?" -ne 1 ] ; then # is mounted
                echo -e " umount partition:" ${GRN}$partition${NOC}
                sleep 1 # just make it noticable
                sudo umount $partition
            else
                echo -e "        partition: ${GRN}$partition${NOC} not mounted"
            fi
        fi
    done
    # umount all partitions: /dev/mmcblk0p1; /dev/mmcblk0p2; etc
    for i in {1..9} ; do
        partition=$sd_card"p${i}"
        if [ -b "$partition" ] ; then
            # check if mounted
            sudo mount | grep '^/' | grep -q $partition
            if [ $? -ne 1 ] ; then # is mounted
                echo -e " umount partition:" ${GRN}$partition${NOC}
                sleep 1 # just make it noticable
                sudo umount $partition
            else
                echo -e "        partition: ${GRN}$partition${NOC} not mounted"
            fi
        fi
    done
    sudo chmod 666 $sd_card
}
