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
function _dj_setup_device_tree_compiler() {
    _show_and_run sudo apt update -y
    _show_and_run sudo apt install device-tree-compiler
}


# =============================================================================
function _dj_setup_glog() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run sudo rm -rf /usr/local/include/glog
     _show_and_run sudo find /usr/local/lib -name 'libglog*' -exec rm -f {} \;
    
    local v=$(_find_package_version glog)
    _echo_install glog v$v
    _show_and_run sudo rm -rf glog
    _show_and_run git clone https://github.com/google/glog.git
    _show_and_run cd glog
    _show_and_run git checkout v$v
    _show_and_run rm -rf build
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo -e "\n${INFO}glog $v${NOC} is installed:"
    if [ $system = 'Linux' ]; then
        _verify_lib_installation libglog.a /usr/local/lib
        _verify_lib_installation libglog.so /usr/local/lib
    elif [ $system = 'Darwin' ]; then
        _verify_lib_installation libglog.dylib /usr/local/lib
    fi
    _verify_header_files logging.h /usr/local/include/glog

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


# =============================================================================
function _dj_setup_spdlog() { # static/shared
    static_shared=$1          # if empty, treat as dynamic

    v=$(_find_package_version spdlog)
    _show_and_run _pushd_quiet ${PWD}

    if [ $system = 'Linux' ]; then
        _show_and_run sudo rm -f /usr/local/lib/libspdlog.a
        _show_and_run sudo find /usr/local/lib -name 'libspdlog.so*' -exec rm -f {} \;
    elif [ $system = 'Darwin' ]; then
        _show_and_run sudo find /usr/local/lib -name 'libspdlog*.dylib' -exec rm -f {} \;
    fi

    _show_and_run sudo rm -rf /usr/local/include/spdlog/
    _show_and_run sudo rm -f /usr/local/lib/pkgconfig/spdlog.pc
    _show_and_run sudo rm -rf /usr/local/lib/cmake/spdlog/

    _echo_install spdlog v$v
    _press_enter_or_wait_s_continue 5

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run sudo rm -rf spdlog

    _show_and_run git clone https://github.com/gabime/spdlog.git
    _show_and_run cd spdlog
    _show_and_run git checkout v$v
    _show_and_run mkdir -p build
    _show_and_run cd build

    # static build need to be specific
    # if no option found, "shared" is default
    if [ "$static_shared" = 'static' ]; then
        _show_and_run cmake -DSPDLOG_BUILD_SHARED=off -DSPDLOG_INSTALL=on -DSPDLOG_BUILD_EXAMPLES=off -DSPDLOG_BUILD_TESTS=off -DSPDLOG_BUILD_BENCH=off -DSPDLOG_FMT_EXTERNAL=off ..
    else
        _show_and_run cmake -DSPDLOG_BUILD_SHARED=on -DSPDLOG_FMT_EXTERNAL=off ..
    fi
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo -e "\n${INFO}spdlog v$v${NOC} is installed."
    if [ "$static_shared" = 'static' ]; then
        _verify_lib_installation libspdlog.a /usr/local/lib
    else
        if [ $system = 'Linux' ]; then
            _verify_lib_installation libspdlog.so /usr/local/lib
        elif [ $system = 'Darwin' ]; then
            _verify_lib_installation libspdlog.dylib /usr/local/lib
        fi
    fi
    _verify_header_files spdlog.h /usr/local/include/spdlog
    _verify_pkgconfig_file spdlog.pc /usr/local/lib/pkgconfig
    _verify_cmake_files spdlogConfig.cmake /usr/local/lib/cmake/spdlog

    _popd_quiet
}


# =============================================================================
# make sure the related package is public available in dj-zhou's github
# compile from the source code will install it to
#   /usr/local/lib/libyaml-cpp.a
# apt-get will install it to
#  /usr/lib/x86_64-linux-gnu/
# shared library build seems not working, error:
# ./_bnative.cmake/yaml-demo: symbol lookup error: ./_bnative.cmake/yaml-demo: undefined symbol: _ZN4YAML6detail9node_data12empty_scalarB5cxx11Ev
function _dj_setup_yaml_cpp() {
    _show_and_run _pushd_quiet ${PWD}

    # dependencies to install --------------
    if [ $system = 'Linux' ]; then
        _show_and_run sudo apt-get -y update
        _show_and_run _install_if_not_installed build-essential
    fi

    cmake_v=$(version check cmake)

    anw=$(_version_if_ge_than $cmake_v 3.20.5)
    if [ "$anw" = 'no' ]; then
        _show_and_run dj setup cmake
    fi
    
    # remove existing library, if there is any
    if [ $system = 'Linux' ]; then
        _show_and_run sudo find /usr/local/lib -name 'libyaml-cpp*' -exec rm -f {} \;
    elif [ $system = 'Darwin' ]; then
        _show_and_run sudo find /usr/local/lib -name 'libyaml-cpp*.dylib' -exec rm -f {} \;
    fi

    yaml_v=$(_find_package_version yaml-cpp)
    _echo_install yaml-cpp $yaml_v
    _press_enter_or_wait_s_continue 5

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf yaml-cpp

    _show_and_run git clone https://github.com/jbeder/yaml-cpp.git
    _show_and_run cd yaml-cpp
    _show_and_run git checkout yaml-cpp-$yaml_v
    _show_and_run rm -rf build/
    _show_and_run mkdir -p build
    _show_and_run cd build

    _show_and_run cmake ..
    _show_and_run make -j${nproc}
    _show_and_run sudo make install

    echo -e "\n${INFO}yaml-cpp $yaml_v${NOC} is installed."
    _verify_lib_installation libyaml-cpp.a /usr/local/lib
    _verify_header_files yaml.h /usr/local/include/yaml-cpp
    _verify_pkgconfig_file yaml-cpp.pc /usr/local/lib/pkgconfig

    _popd_quiet
}
