#!/bin/bash

# =============================================================================
function _dj_setup_cuda() {
    _show_and_run sudo apt install -y nvidia-cuda-toolkit
    cat <<eom
check cuda version:
$ nvcc --version
eom
}

# =============================================================================
function _dj_setup_cutecom() {
    _pushd_quiet "${PWD}"

    if [[ ${ubuntu_v} = *'18.04'* || ${ubuntu_v} = *'20.04'* ]]; then
        v=$(_find_package_version cutecom)
    elif [[ ${ubuntu_v} = *'22.04'* ]]; then
        v="fe55f279a7da0b19948ebff6d1fb2990cccfd4fb"
    fi
    _echo_install cutecom $v
    _press_enter_or_wait_s_continue 5

    # this is important
    if [[ ${ubuntu_v} = *'18.04'* || ${ubuntu_v} = *'20.04'* ]]; then
        _install_if_not_installed qt5-default
    fi
    _install_if_not_installed qt5-default libqt5serialport5-dev

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run sudo rm -rf cutecom
    _show_and_run git clone https://gitlab.com/cutecom/cutecom.git
    _show_and_run cd cutecom
    _show_and_run git checkout $v
    _show_and_run cmake .
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    _popd_quiet
}
