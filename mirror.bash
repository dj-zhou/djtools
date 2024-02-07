#!/bin/bash

# reference:
#    https://ostechnix.com/pishrink-make-raspberry-pi-images-smaller/
#    wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
#    github page: https://github.com/Drewsif/PiShrink
#    MIT license
# it is designed for RPI images, but it could also work for others
# =============================================================================
if [ $system = 'Linux' ]; then
    CURRENT_DIR="$(pwd)"
    SCRIPTNAME="${0##*/}"
    MYNAME="${SCRIPTNAME%.*}"
    LOGFILE="${CURRENT_DIR}/${SCRIPTNAME%.*}.log"
    REQUIRED_TOOLS="parted losetup tune2fs md5sum e2fsck resize2fs"
    ZIPTOOLS=("gzip xz")
    declare -A ZIP_PARALLEL_TOOL=([gzip]="pigz" [xz]="xz")    # parallel zip tool to use in parallel mode
    declare -A ZIP_PARALLEL_OPTIONS=([gzip]="-f9" [xz]="-T0") # options for zip tools in parallel mode
    declare -A ZIPEXTENSIONS=([gzip]="gz" [xz]="xz")          # extensions of zipped files
fi

# =============================================================================
function _rpi_shrink_info() {
    echo "$SCRIPTNAME: $1 ..."
}

# =============================================================================
function _rpi_shrink_error() {
    echo -n "$SCRIPTNAME: ERROR occured in line $1: "
    shift
    echo "$@"
}

# =============================================================================
function _rpi_shrink_cleanup() {
    if losetup "$loopback" &>/dev/null; then
        losetup -d "$loopback"
    fi
    if [ "$debug" = true ]; then
        local old_owner=$(stat -c %u:%g "$src")
        chown "$old_owner" "$LOGFILE"
    fi
}

# =============================================================================
function _rpi_shrink_log_variables() {
    if [ "$debug" = true ]; then
        echo "Line $1" >>"$LOGFILE"
        shift
        local v var
        for var in "$@"; do
            eval "v=\$$var"
            echo "$var: $v" >>"$LOGFILE"
        done
    fi
}

# =============================================================================
function _rpi_shrink_log_check_filesystem() {
    _rpi_shrink_info "Checking filesystem"
    sudo e2fsck -pf "$loopback"
    (($? < 4)) && return

    _rpi_shrink_info "Filesystem error detected!"

    _rpi_shrink_info "Trying to recover corrupted filesystem"
    sudo e2fsck -y "$loopback"
    (($? < 4)) && return

    if [[ $repair == true ]]; then
        _rpi_shrink_info "Trying to recover corrupted filesystem - Phase 2"
        sudo e2fsck -fy -b 32768 "$loopback"
        (($? < 4)) && return
    fi
    _rpi_shrink_error $LINENO "Filesystem recoveries failed. Giving up..."
    exit 9

}

# =============================================================================
function _rpi_shrink_set_autoexpand() {
    # make pi expand rootfs on next boot
    mountdir=$(sudo mktemp -d)
    sudo partprobe "$loopback"
    sudo mount "$loopback" "$mountdir"

    if [ ! -d "$mountdir/etc" ]; then
        _rpi_shrink_info "/etc not found, autoexpand will not be enabled"
        sudo umount "$mountdir"
        return
    fi

    if [[ -f "$mountdir/etc/rc.local" ]] &&
        [[ "$(md5sum "$mountdir/etc/rc.local" | cut -d ' ' -f 1)" != "1c579c7d5b4292fd948399b6ece39009" ]]; then
        echo "Creating new /etc/rc.local"
        if [ -f "$mountdir/etc/rc.local" ]; then
            sudo mv "$mountdir/etc/rc.local" "$mountdir/etc/rc.local.bak"
        fi

        cat <<\EOF1 >"$mountdir/etc/rc.local"
#!/bin/bash
do_expand_rootfs() {
  ROOT_PART=$(mount | sed -n 's|^/dev/\(.*\) on / .*|\1|p')

  PART_NUM=${ROOT_PART#mmcblk0p}
  if [ "$PART_NUM" = "$ROOT_PART" ]; then
    echo "$ROOT_PART is not an SD card. Don't know how to expand"
    return 0
  fi

  # Get the starting offset of the root partition
  PART_START=$(parted /dev/mmcblk0 -ms unit s p | grep "^${PART_NUM}" | cut -f 2 -d: | sed 's/[^0-9]//g')
  [ "$PART_START" ] || return 1
  # Return value will likely be error for fdisk as it fails to reload the
  # partition table because the root fs is mounted
  fdisk /dev/mmcblk0 <<EOF
p
d
$PART_NUM
n
p
$PART_NUM
$PART_START

p
w
EOF

cat <<EOF > /etc/rc.local &&
#!/bin/sh
echo "Expanding /dev/$ROOT_PART"
resize2fs /dev/$ROOT_PART
rm -f /etc/rc.local; cp -f /etc/rc.local.bak /etc/rc.local; /etc/rc.local

EOF
reboot
exit
}
raspi_config_expand() {
/usr/bin/env raspi-config --expand-rootfs
if [[ $? != 0 ]]; then
  return -1
else
  rm -f /etc/rc.local; cp -f /etc/rc.local.bak /etc/rc.local; /etc/rc.local
  reboot
  exit
fi
}
raspi_config_expand
echo "WARNING: Using backup expand..."
sleep 5
do_expand_rootfs
echo "ERROR: Expanding failed..."
sleep 5
if [[ -f /etc/rc.local.bak ]]; then
  cp -f /etc/rc.local.bak /etc/rc.local
  /etc/rc.local
fi
exit 0
EOF1
        #####End no touch zone#####
        chmod +x "$mountdir/etc/rc.local"
    fi
    sudo umount "$mountdir"
}

# =============================================================================
function _rpi_shrink_help() {
    local _rpi_shrink_help
    read -r -d '' _rpi_shrink_help <<eom
Usage: $0 [-adhrspvzZ] [image.img] [new-image.img]

  -s         Don't expand filesystem when image is booted the first time
  -v         Be verbose
  -r         Use advanced filesystem repair option if the normal one fails
  -z         Compress image after shrinking with gzip
  -Z         Compress image after shrinking with xz
  -a         Compress image in parallel using multiple cores
  -p         Remove logs, apt archives, dhcp leases and ssh hostkeys
  -d         Write debug messages in a debug log file
eom
    echo "$_rpi_shrink_help"
}

# =============================================================================
function _mirror_shrink() {
    should_skip_autoexpand=false
    debug=false
    repair=false
    parallel=false
    verbose=false
    prep=false
    ziptool=""
    while getopts ":adhprsvzZ" opt; do
        case "${opt}" in
        a) parallel=true ;;
        d) debug=true ;;
        h) _rpi_shrink_help ;;
        p) prep=true ;;
        r) repair=true ;;
        s) should_skip_autoexpand=true ;;
        v) verbose=true ;;
        z) ziptool="gzip" ;;
        Z) ziptool="xz" ;;
        *) _rpi_shrink_help ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ "$debug" = true ]; then
        _rpi_shrink_info "Creating log file $LOGFILE"
        rm "$LOGFILE" &>/dev/null
        exec 1> >(stdbuf -i0 -o0 -e0 tee -a "$LOGFILE" >&1)
        exec 2> >(stdbuf -i0 -o0 -e0 tee -a "$LOGFILE" >&2)
    fi

    # arguments ----------------
    src="$1" # this seems not right
    img="$1"

    # usage checks ----------------
    if [[ -z "$img" ]]; then
        _rpi_shrink_help
    fi

    if [[ ! -f "$img" ]]; then
        _rpi_shrink_error $LINENO "$img is not a file..."
        return
    fi

    # check ownership ----------------
    owner_ship=$(stat -c '%U' $img)
    if [[ ! "$owner_ship" = "$USER" ]]; then
        echo -e "file $img is$RED NOT$NOC owned by $USER, cannot shrink."
        return
    fi

    # check selected compression tool is supported and installed
    if [[ -n $ziptool ]]; then
        if [[ ! " ${ZIPTOOLS[@]} " =~ $ziptool ]]; then
            _rpi_shrink_error $LINENO "$ziptool is an unsupported ziptool."
            return
        else
            if [[ $parallel == true && $ziptool == "gzip" ]]; then
                REQUIRED_TOOLS="$REQUIRED_TOOLS pigz"
            else
                REQUIRED_TOOLS="$REQUIRED_TOOLS $ziptool"
            fi
        fi
    fi

    # check that what we need is installed
    for command in $REQUIRED_TOOLS; do
        command -v $command >/dev/null 2>&1
        if (($? != 0)); then
            _rpi_shrink_error $LINENO "$command is not installed."
            return
        fi
    done

    # copy to new file if requested
    if [ -n "$2" ]; then
        f="$2"
        if [[ -n $ziptool && "${f##*.}" == "${ZIPEXTENSIONS[$ziptool]}" ]]; then
            # remove zip extension if zip requested because zip tool will complain about extension
            f="${f%.*}"
        fi
        _rpi_shrink_info "Copying $1 to $f..."
        cp --reflink=auto --sparse=always "$1" "$f"
        if (($? != 0)); then
            _rpi_shrink_error $LINENO "Could not copy file..."
            return
        fi
        old_owner=$(stat -c %u:%g "$1")
        chown "$old_owner" "$f"
        img="$f"
    fi

    # cleanup at script exit
    trap _rpi_shrink_cleanup EXIT

    # gather _rpi_shrink_info
    _rpi_shrink_info "Gathering data"
    beforesize="$(ls -lh "$img" | cut -d ' ' -f 5)"
    parted_output="$(parted -ms "$img" unit B print)"
    rc=$?
    if (($rc)); then
        _rpi_shrink_error $LINENO "parted failed with rc $rc"
        _rpi_shrink_info "Possibly invalid image. Run 'parted $img unit B print' manually to investigate"
        return
    fi

    partnum="$(echo "$parted_output" | tail -n 1 | cut -d ':' -f 1)"
    partstart="$(echo "$parted_output" | tail -n 1 | cut -d ':' -f 2 | tr -d 'B')"
    if [ -z "$(parted -s "$img" unit B print | grep "$partstart" | grep logical)" ]; then
        parttype="primary"
    else
        parttype="logical"
    fi
    loopback="$(sudo losetup -f --show -o "$partstart" "$img")"
    tune2fs_output="$(sudo tune2fs -l "$loopback")"
    rc=$?
    if (($rc)); then
        echo "$tune2fs_output"
        _rpi_shrink_error $LINENO "tune2fs failed. Unable to shrink this type of image"
        return
    fi

    currentsize="$(echo "$tune2fs_output" | grep '^Block count:' | tr -d ' ' | cut -d ':' -f 2)"
    blocksize="$(echo "$tune2fs_output" | grep '^Block size:' | tr -d ' ' | cut -d ':' -f 2)"

    _rpi_shrink_log_variables $LINENO beforesize parted_output partnum partstart parttype tune2fs_output currentsize blocksize

    # check if we should make pi expand rootfs on next boot
    if [ "$parttype" == "logical" ]; then
        echo "WARNING: does not yet support autoexpanding of this type of image"
    elif [ "$should_skip_autoexpand" = false ]; then
        _rpi_shrink_set_autoexpand
    else
        echo "Skipping autoexpanding process..."
    fi

    if [[ $prep == true ]]; then
        _rpi_shrink_info "Syspreping: Removing logs, apt archives, dhcp leases and ssh hostkeys"
        mountdir=$(mktemp -d)
        sudo mount "$loopback" "$mountdir"
        sudo rm -rvf $mountdir/var/cache/apt/archives/*
        sudo rm -rvf $mountdir/var/lib/dhcpcd5/*
        sudo rm -rvf $mountdir/var/log/*
        sudo rm -rvf $mountdir/var/tmp/*
        sudo rm -rvf $mountdir/tmp/*
        sudo rm -rvf $mountdir/etc/ssh/*_host_*
        # add scripts here if want to remove more things fro mthe image
        sudo umount "$mountdir"
    fi

    # make sure filesystem is ok
    _rpi_shrink_log_check_filesystem

    if ! minsize=$(sudo resize2fs -P "$loopback"); then
        rc=$?
        _rpi_shrink_error $LINENO "resize2fs failed with rc $rc"
        return
    fi
    minsize=$(cut -d ':' -f 2 <<<"$minsize" | tr -d ' ')
    _rpi_shrink_log_variables $LINENO currentsize minsize
    if [[ $currentsize -eq $minsize ]]; then
        _rpi_shrink_error $LINENO "Image already shrunk to smallest size"
        return
    fi

    # add some free space to the end of the filesystem
    extra_space=$(($currentsize - $minsize))
    _rpi_shrink_log_variables $LINENO extra_space
    for space in 5000 1000 100; do
        if [[ $extra_space -gt $space ]]; then
            minsize=$(($minsize + $space))
            break
        fi
    done
    _rpi_shrink_log_variables $LINENO minsize

    # shrink filesystem
    _rpi_shrink_info "Shrinking filesystem"
    sudo resize2fs -p "$loopback" $minsize
    rc=$?
    if (($rc)); then
        _rpi_shrink_error $LINENO "resize2fs failed with rc $rc"
        sudo mount "$loopback" "$mountdir"
        mv "$mountdir/etc/rc.local.bak" "$mountdir/etc/rc.local"
        sudo umount "$mountdir"
        sudo losetup -d "$loopback"
        return
    fi
    sleep 1

    # shrink partition
    partnewsize=$(($minsize * $blocksize))
    newpartend=$(($partstart + $partnewsize))
    _rpi_shrink_log_variables $LINENO partnewsize newpartend
    sudo parted -s -a minimal "$img" rm "$partnum"
    rc=$?
    if (($rc)); then
        _rpi_shrink_error $LINENO "parted failed with rc $rc"
        return
    fi

    sudo parted -s "$img" unit B mkpart "$parttype" "$partstart" "$newpartend"
    rc=$?
    if (($rc)); then
        _rpi_shrink_error $LINENO "parted failed with rc $rc"
        return
    fi

    # truncate the file
    _rpi_shrink_info "Shrinking image"
    endresult=$(parted -ms "$img" unit B print free)
    rc=$?
    if (($rc)); then
        _rpi_shrink_error $LINENO "parted failed with rc $rc"
        return
    fi

    endresult=$(tail -1 <<<"$endresult" | cut -d ':' -f 2 | tr -d 'B')
    _rpi_shrink_log_variables $LINENO endresult
    truncate -s "$endresult" "$img"
    rc=$?
    if (($rc)); then
        _rpi_shrink_error $LINENO "trunate failed with rc $rc"
        return
    fi

    # handle compression
    if [[ -n $ziptool ]]; then
        options=""
        envVarname="${MYNAME^^}_${ziptool^^}" # PISHRINK_GZIP or PISHRINK_XZ environment variables allow to override all options for gzip or xz
        [[ $parallel == true ]] && options="${ZIP_PARALLEL_OPTIONS[$ziptool]}"
        [[ -v $envVarname ]] && options="${!envVarname}" # if environment variable defined use these options
        [[ $verbose == true ]] && options="$options -v"  # add verbose flag if requested

        if [[ $parallel == true ]]; then
            parallel_tool="${ZIP_PARALLEL_TOOL[$ziptool]}"
            _rpi_shrink_info "Using $parallel_tool on the shrunk image"
            if ! $parallel_tool ${options} "$img"; then
                rc=$?
                _rpi_shrink_error $LINENO "$parallel_tool failed with rc $rc"
                return
            fi

        else # sequential
            _rpi_shrink_info "Using $ziptool on the shrunk image"
            if ! $ziptool ${options} "$img"; then
                rc=$?
                _rpi_shrink_error $LINENO "$ziptool failed with rc $rc"
                return
            fi
        fi
        img=$img.${ZIPEXTENSIONS[$ziptool]}
    fi

    aftersize=$(ls -lh "$img" | cut -d ' ' -f 5)
    _rpi_shrink_log_variables $LINENO aftersize

    _rpi_shrink_info "Shrunk $img from $beforesize to $aftersize"
}

# =============================================================================
function _mirror_backup() {
    if [ $# -le 1 ]; then
        echo "Need more arguments: rpi backup [device] [image]"
        echo " -- device: i.e., /dev/sda, /dev/sdb, etc."
        echo " --  image: the image file to save."
        return
    fi
    blk=$1
    file=$2
    echo -e "Backing up $INFO$blk$NOC to $INFO$file$NOC"
    _show_and_run sudo dd bs=4M if="$blk" of="$file" status=progress
    _show_and_run sudo chown $USER "$file"
    echo -e "Now you can run ${INFO}rpi shrink $file${NOC} to make the file smaller"
}
