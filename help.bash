#!/bin/bash

_help_list="apt_pkg auto-mount auto-unmount cu ffmpeg jupyter pipocom screen wireshark "

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
auto mount a disk, make sure the disk is formatted, and then:
1. locate the partition to be mounted, it should show the disk model.
   $ sudo fdisk -l
   for example, I see this:
    Disk /dev/nvme1n1: 1.82 TiB, 2000398934016 bytes, 3907029168 sectors
    Disk model: CT2000P3PSSD8                           
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes

2. find the UUID (Universal Unique Identifier) of the drive:
   $ sudo blkid | grep nvme1n1
    /dev/nvme1n1: UUID="6fe254d6-aac7-4b7f-8764-ee05122933fe" BLOCK_SIZE="4096" TYPE="ext4"

3. create a mount point (a directory), and change its ownership:
   $ sudo mkdir <a/path>
   $ sudo chown -R <user name> <a/path>

4. revise /etc/fstab, add the following:
   UUID=a664dd10-945e-4137-b97c-5d18f9119971 a/path ext4 nosuid,nodev,nofail,x-gvfs-show 0 0

5. manual mount to verify:
   $ sudo mount -a
   then reboot the computer to see if it is auto-mounted.

*. reference
   https://www.techrepublic.com/article/how-to-properly-automount-a-drive-in-ubuntu-linux/

-----------------------------------------
eom
}

# =============================================================================
function _dj_help_auto_unmount() {
    cat <<eom
-----------------------------------------
1. create a systemd service
   $ cd /etc/systemd/system
   $ sudo touch ssd-unmount.service
   then add the following (to be revised)

[Unit]
Description=Unmount SSD during shutdown
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/bin/true
ExecStop=/bin/umount -l a/path

[Install]
WantedBy=shutdown.target

   then enable this service by
   $ sudo systemctl enable ssd-unmount.service

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
     exit: 
      -- on Ubuntu:
            press Ctrl + A and then \, and Y
      -- on Mac OS:
            press Control + A and then K, and Y
-----------------------------------------
eom
}

# =============================================================================
function _dj_help_wireshark() {
    cat <<eom
1. Capture CAN messages (example):
    $ tcpdump -c 1000 -X -i can1 -w can1.pcap
    (be cautious about tcpdump version)
2. Create your own dissector:
    https://mika-s.github.io/wireshark/lua/dissector/2017/11/04/creating-a-wireshark-dissector-in-lua-1.html
3. Capture UDP/TCP messages:
    $ todo
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
    if [ $1 = 'auto-unmount' ]; then
        _dj_help_auto_unmount
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
    if [ $1 = 'wireshark' ]; then
        _dj_help_wireshark
        return
    fi
}
