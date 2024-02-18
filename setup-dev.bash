#!/bin/bash

# =============================================================================
function _dj_setup_ansible() {
    if [ "$system" = "Linux" ]; then
        _show_and_run sudo apt update
        _show_and_run sudo apt install software-properties-common
        _show_and_run sudo add-apt-repository --yes --update ppa:ansible/ansible
        _show_and_run sudo apt install ansible
    elif [ "$system" = "Darwin" ]; then
        _show_and_run brew install ansible
    fi
}

# =============================================================================
# setting a fixed version is not a good idea, but ...
function _dj_setup_cmake() {
    # install dependencies
    _show_and_run _install_if_not_installed libssl-dev gcc
    if [ "$system" = "Linux" ]; then
        _show_and_run _install_if_not_installed g++
    fi
    new_v=$(_find_package_version cmake)
    v=v$new_v
    _echo_install CMake $v

    current_v=$(version check cmake)
    anw=$(_version_if_ge_than $current_v $new_v)
    if [ "$anw" = "yes" ]; then
        echo "CMake is as new as $current_v, no need to install $new_v."
        return
    fi

    _press_enter_or_wait_s_continue 5

    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf CMake
    _show_and_run git clone https://github.com/Kitware/CMake.git
    _show_and_run cd CMake
    _show_and_run git checkout $v

    _show_and_run ./bootstrap --prefix=/usr/local --parallel=$(nproc)
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install
    echo -e "${INFO}cmake${NOC} is installed to ${INFO}/usr/local/bin${NOC}"

    _popd_quiet
}

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
function _dj_setup_lcm() {
    _pushd_quiet ${PWD}

    if [[ ! "${ubuntu_v}" = *'20.04'* ]] && [[ ! "${ubuntu_v}" = *'22.04'* ]]; then
        echo "lcm installation is only tested on Ubuntu 20.04/22.04."
        return
    fi

    _show_and_run _install_if_not_installed default-jdk build-essential libglib2.0-dev
    _show_and_run _install_if_not_installed doxygen liblua5.3-dev lua5.3
    _show_and_run _install_if_not_installed python3-dev

    v=$(_find_package_version lcm)
    _echo_install lcm v$v

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf lcm
    _show_and_run git clone https://github.com/lcm-proj/lcm.git
    _show_and_run cd lcm
    _show_and_run git checkout v$v
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install
    _show_and_run sudo ldconfig

    echo -e "${INFO}lcm $v${NOC} is installed."
    _verify_lib_installation liblcm.so /usr/local/lib
    _verify_header_files lcm.h /usr/local/include/lcm/
    _verify_pkgconfig_file lcm.pc /usr/local/lib/pkgconfig
    _verify_pkgconfig_file lcm-java.pc /usr/local/lib/pkgconfig

    _popd_quiet
}

# =============================================================================
# libev can also be installed by
# $ _show_and_run _install_if_not_installed libev-dev
# however, it is the v4.22 to be installed, and the installation location is
#   /usr/lib/x86_64-linux-gnu/
# install from the source, will have the libev installed into
#  /usr/local/lib
# this setup works only for the host computer, don't know how to do it for
# cross compilers
function _dj_setup_libev() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    v=$(_find_package_version libev)
    _echo_install libev $v
    _press_enter_or_wait_s_continue 5

    file="libev-$v"
    _show_and_run wget http://dist.schmorp.de/libev/$file.tar.gz
    _show_and_run tar -zxf $file.tar.gz
    _show_and_run cd $file
    _show_and_run ./configure
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    # check for the LD_LIBRARY_PATH
    # if it is not set for libev, then set it
    result=$(echo $LD_LIBRARY_PATH)
    if [[ "$result" = *"/usr/local/lib"* ]]; then
        echo "LD_LIBRARY_PATH is already set, no need to set it again"
    else
        _show_and_run echo '# ===========================================================' >>$rc_file
        _show_and_run echo '# (djtools) dj setup libev' >>$rc_file
        _show_and_run echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >>$rc_file
    fi

    echo -e "\n${INFO}libev $v${NOC} is installed."
    if [ "$system" = "Linux" ]; then
        _verify_lib_installation libev.so /usr/local/lib/
    elif [ "$system" = "Darwim" ]; then
        _verify_lib_installation libev.dylib /usr/local/lib/
    fi
    _verify_lib_installation libev.a /usr/local/lib/

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
function _dj_setup_pangolin() {
    _show_and_run _pushd_quiet ${PWD}

    if [ $system = 'Linux' ]; then
        # dependency installation
        packages="libglew-dev mesa-utils libglm-dev libxkbcommon-x11-dev freeglut3 freeglut3-dev "
        _show_and_run _install_if_not_installed $packages
        _show_and_run dj setup glfw3
    elif [ $system = 'Darwin' ]; then
        _show_and_run _install_if_not_installed freeglut glew
    fi

    # on my m3max, I have to use the master, probably because of ffmpeg version (6.1.1)
    local v=$(_find_package_version pangolin)

    # use command 'glxinfo | grep "OpenGL version" ' to see opengl version in Ubuntu

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run sudo rm -rf Pangolin/
    _show_and_run git clone --recursive https://github.com/stevenlovegrove/Pangolin.git
    _show_and_run cd Pangolin
    _show_and_run git checkout $v
    if [ $system = 'Darwin' ]; then
        _show_and_run ./scripts/install_prerequisites.sh -m brew all
    elif [ $system = 'Linux' ]; then
        _show_and_run ./scripts/install_prerequisites.sh
    fi
    _show_and_run rm -rf build/
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..

    # without using pyhton3.10, I have lots of errors when build
    # on my m3max macbook, I don't have to do this and I don't have python3.10
    # _show_and_run cmake .. -DPython_EXECUTABLE=/usr/local/bin/python3.10
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install
    _show_and_run sudo cp libpango_* /usr/local/lib

    if [ $system = 'Darwin' ]; then
        _verify_lib_installation libpango_core.dylib /usr/local/lib
        _verify_lib_installation libpango_geometry.dylib /usr/local/lib
    elif [ $system = 'Linux' ]; then
        _verify_lib_installation libpango_core.so /usr/local/lib
        _verify_lib_installation libpango_geometry.so /usr/local/lib
    fi
    _verify_header_files pangolin.h /usr/local/include/pangolin

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
