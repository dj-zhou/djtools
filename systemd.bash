#!/bin/bash

_dj_systemd_umount_dir() {
    SERVICE_CONTENT="[Unit]
Description=Unmount SSD during shutdown
DefaultDependencies=no
Before=umount.target

[Service]
Type=oneshot
ExecStart=/bin/true
ExecStop=/bin/bash -c 'if [ -d \"$1\" ] && mountpoint -q \"$1\"; then /bin/umount -l \"$1\"; fi'

[Install]
WantedBy=umount.target"

    service_name="ssd-umount.service"
    service_file_path="/etc/systemd/system/$service_name"
    # service_file_path="$HOME/1.service"
    if [ -f $service_file_path ]; then
        _show_and_run sudo systemctl disable $service_name
        _show_and_run sudo rm $service_file_path
    fi
    _show_and_run echo "$SERVICE_CONTENT" | sudo tee "$service_file_path" >/dev/null
    echo "Service file '$service_file_path' written successfully."
    _show_and_run sudo systemctl daemon-reload
    # _show_and_run sudo systemctl enable $service_name
}

function _dj_systemd() {
    if [ "$1" = "umount" ]; then
        if [ $# -gt 1 ]; then
            _dj_systemd_umount_dir $2
            return
        fi
        return
    fi
}
