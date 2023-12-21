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

# =============================================================================
# testing
function _dj_setup_meson_ninjia() {
    local meson_v=$(_find_package_version meson)
    local ninja_v=$(_find_package_version ninja)
    # sanity check
    local cmake_v=$(version check cmake)
    anw=$(_version_if_ge_than "$cmake_v" "3.20")
    if [ "$anw" = "no" ]; then
        echo "cmake needs to be 3.20 or higher version, exit."
        return
    fi

    _echo_install meson $meson_v
    _press_enter_or_wait_s_continue 5
    if [[ $system = 'Linux' && -f "/usr/bin/meson" ]]; then
        _show_and_run sudo apt-get remove meson &>/dev/null
    fi

    # install needed software
    _show_and_run _install_if_not_installed python3
    _show_and_run _install_if_not_installed python3-pip

    # meson release: https://github.com/mesonbuild/meson/releases
    _show_and_run python3 -m pip install meson==$meson_v

    # on Mac OS, `which meson` returns `/usr/local/bin/meson`
    # on Ubuntu, `which meson` returns: to verify
    if [[ $system = 'Linux' ]]; then
        meson_path=$(grep "PATH:~/.local/bin" $rc_file)
        if [ ! -z "$meson_path" ]; then
            echo -e "${INFO}meson ${NOC}path was set in $rc_file"
        else
            echo -e '\n' >>$rc_file
            echo '# ===========================================================' >>$rc_file
            echo '# (djtools) meson path setup' >>$rc_file
            echo -e 'export PATH=$PATH:~/.local/bin\n' >>$rc_file
        fi
        echo -e "${INFO}meson${NOC} is installed to ${INFO}${HOME}/.local/bin${NOC}"
    fi
    # ---------------------------------------------
    _echo_install ninja $ninja_v
    _press_enter_or_wait_s_continue 5
    # ninja is needed for meson, so install it as well

    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf ninja
    _show_and_run git clone https://github.com/ninja-build/ninja.git && cd ninja
    _show_and_run git checkout v$ninja_v
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    _show_and_run which meson
    _show_and_run which ninja
    _popd_quiet
}
