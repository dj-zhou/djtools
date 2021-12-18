#!/bin/bash

# =============================================================================
function _dj_help_apt_pkg_error() {
    cat <<eom
if see the error:
-----------------------------------------
Traceback (most recent call last):
  File "/usr/lib/command-not-found", line 28, in <module>
    from CommandNotFound import CommandNotFound
  File "/usr/lib/python3/dist-packages/CommandNotFound/CommandNotFound.py", line 19, in <module>
    from CommandNotFound.db.db import SqliteDatabase
  File "/usr/lib/python3/dist-packages/CommandNotFound/db/db.py", line 5, in <module>
    import apt_pkg
ModuleNotFoundError: No module named 'apt_pkg'
-----------------------------------------
do this:
    $ cd /usr/lib/python3/dist-packages
    $ sudo cp apt_pkg.cpython-36m-x86_64-linux-gnu.so apt_pkg.so
eom

}

# =============================================================================
function _dj_help_auto_mount() {
    cat <<eom
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
eom
}

# =============================================================================
function _dj_help_ffmpeg() {
    cat <<eom
-----------------------------------------
use ffmpeg to convert videos:
1. convert avi to mp4
  $ ffmpeg -i input.avi output.mp4
2. convert mp4 to gif
  $ ffmpeg -i input.mp4 output.gif
3. convert mp4 to gif (starting from time 00:00:02, for 3 seconds)
  $ ffmpeg -t 3 -ss 00:00:02 -i input.mp4 output.gif
-----------------------------------------
eom
}

# =============================================================================
function _dj_help_jupyter() {
    cat <<eom
-----------------------------------------
1. convert juypter files to python scripts
  $ jupyter nbconvert --to python file.ipynb
-----------------------------------------
eom
}

# =============================================================================
function _dj_help_cu() {
    cat <<eom
-----------------------------------------
how to use cu:
    start: $ cu -l /dev/ttyUSB0 -s 115200 [ENTER]
    exit: input ~. and then [ENTER]
-----------------------------------------
eom
}

# =============================================================================
function _dj_help_pipocom() {
    cat <<eom
-----------------------------------------
how to use picocom:
    start: $ picocom /dev/ttyUSB0 -b 115200 -g file-$(TZ=UTC date +%FT%H%M%SZ).log
     exit: --
-----------------------------------------
eom
}

# =============================================================================
function _dj_help_screen() {
    cat <<eom
-----------------------------------------
how to use screen:
    start: $ screen /dev/ttyUSB0 115200 [ENTER]
     exit: press Ctrl+A and then \, and [y]
-----------------------------------------
eom
}

# =============================================================================
function _dj_help_skill() {
    if [ $1 = 'apt_pkg' ]; then
        _dj_help_apt_pkg_error
        return
    fi
    if [ $1 = 'auto-mount' ]; then
        _dj_help_auto_mount
        return
    fi
    if [ $1 = 'cu' ]; then
        _dj_help_cu
        return
    fi
    if [ $1 = 'ffmpeg' ]; then
        _dj_help_ffmpeg
        return
    fi
    if [ $1 = 'jupyter' ]; then
        _dj_help_jupyter
        return
    fi
    if [ $1 = 'pipocom' ]; then
        _dj_help_pipocom
        return
    fi
    if [ $1 = 'screen' ]; then
        _dj_help_screen
        return
    fi
}
