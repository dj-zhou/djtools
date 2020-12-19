#!/bin/bash

# =============================================================================
function _dj_help_auto_mount()
{
    cat << EOM

 -----------------------------------------
  auto mount a disk:
  1. locate the partition to be mounted
     $ sudo fdisk -l
  2. find the UUID (Universal Unique Identifier) of the drive:
     $ sudo blkid
  3. create a mount point
     $ sudo mkdir <a/path>
  4. change the ownership of the mountpoint
     $ sudo chown -R <usr name> <a/path>
  5. revise fstab
     $ sudo gedit /etc/fstab
  6. add the following (need to revise)
     UUID=a664dd10-945e-4137-b97c-5d18f9119971 /home/mamba/soft ext4 nosuid,nodev,nofail,x-gvfs-show 0 0
  7. reference
     https://www.techrepublic.com/article/how-to-properly-automount-a-drive-in-ubuntu-linux/
  8. manual mount
     $ sudo mount -a
  9. reboot to verify
 -----------------------------------------

EOM
}