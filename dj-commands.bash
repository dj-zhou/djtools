#!/bin/bash

source $djtools_path/clang-format.bash
source $djtools_path/clone.bash
source $djtools_path/format.bash
source $djtools_path/help.bash
source $djtools_path/get.bash
source $djtools_path/git.bash
source $djtools_path/setup-dev.bash
source $djtools_path/setup-generic.bash
source $djtools_path/setup-opencv.bash
source $djtools_path/python3-tools.bash
source $djtools_path/setup-ros.bash
source $djtools_path/udev-rules.bash

# =============================================================================
function _dj_help() {
    echo -e "\n------------------------ dj -------------------------"
    echo " Author      : Dingjiang Zhou"
    echo " Email       : zhoudingjiang@gmail.com "
    echo " Create Date : Mar. 1st, 2020"
    echo "-----------------------------------------------------"
    echo -e "\nFirst level commands:"
    echo "   git        - git related features: config. search, ssh-account, ssh clone"
    echo "   merge      - merge splited files into a single file (reversion operation: split)"
    echo "   split      - split a single file into small files (reversion operation: merge)"
    echo "   setup      - to install some software"
    echo "   format     - used to format code"
    echo "   udev       - udev rule setup for usb devices"
    echo "   work-check - check work status of all repos in a folder"
    echo -e ""
    echo -e "  ETC ETC"
    echo -e "All commands support tab completion"
}

# =============================================================================
function _dj_setup_boost() {
    _show_and_run _pushd_quiet ${PWD}

    gpp_v=$(version check g++)
    anw=$(_version_if_ge_than $gpp_v "10.1.0")
    if [ "$anw" = "no" ]; then
        if [ "$system" = "Linux" ]; then
            echo "run \"version swap g++\" to use higher version of g++ (>=10.1.0)"
            echo "run \"version swap gcc\" to use higher version of gcc (>=10.1.0)"
        elif [ "$system" = "Darwin" ]; then
            echo "Need to upgrade gcc/g++ version, wip."
        fi
        return
    fi
    v=$(_find_package_version boost)
    _echo_install boost $v
    _press_enter_or_wait_s_continue 5

    # remove previously installed files
    _show_and_run sudo rm -rf /usr/local/include/boost
    # remove those if previouly has installed another version
    _show_and_run sudo find /usr/local/lib/cmake -name 'boost*' -exec rm -rf {} \; || true
    _show_and_run sudo find /usr/local/lib/cmake -name 'Boost*' -exec rm -rf {} \; || true
    _show_and_run sudo find /usr/local/lib/cmake -name 'BoostDetectToolset*' -exec rm -rf {} \; || true
    _show_and_run sudo find /usr/local/lib -name 'libboost*' -exec rm -f {} \;

    if [ "$system" = "Linux" ]; then
        _show_and_run _install_if_not_installed python3-dev libxml2-dev
    elif [ "$system" = "Darwin" ]; then
        echo "May need to install some dependencies."
    fi

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run sudo rm -rf boost
    _show_and_run git clone https://github.com/boostorg/boost.git

    _show_and_run cd boost
    _show_and_run git checkout boost-$v
    # clone the submodules! this takes long though
    _show_and_run git submodule update --init --recursive
    # install is simple
    _show_and_run ./bootstrap.sh --prefix=/usr/local
    _show_and_run sudo ./b2 install

    _verify_header_files version.hpp /usr/local/include/boost
    if [ $system = 'Linux' ]; then
        _verify_lib_installation libboost_atomic.so /usr/local/lib
        _verify_lib_installation libboost_timer.so /usr/local/lib
    elif [ $system = 'Darwin' ]; then
        _verify_lib_installation libboost_atomic.dylib /usr/local/lib
        _verify_lib_installation libboost_timer.dylib /usr/local/lib
    fi

    _popd_quiet
}

# =============================================================================================
function _create_can_analyzer_desktop_item() {
    folder="/usr/share/applications"

    # copy the icon file
    sudo cp $djtools_path/settings/can-analyzer.xpm $folder

    file="can-analyzer.desktop"
    touch $file

    echo '[Desktop Entry]' >>$file
    echo 'Encoding=UTF-8' >>$file
    echo 'Name=can-analyzer' >>$file
    echo 'Comment=can-analyzer' >>$file
    echo 'Exec=bash -c "cd '$soft_dir'/can-analyzer/ && ./CANAnalysis"' >>$file
    echo 'Icon='$folder'/can-analyzer.xpm' >>$file
    echo 'StartupNotify=false' >>$file
    echo 'Type=Application' >>$file
    echo 'Categories=Application;Development;' >>$file

    sudo rm -rf $folder/$file
    sudo mv $file $folder

    sudo chmod +x $folder/$file

    if [ ! -f "$soft_dir/can-analyzer/CANAnalysis" ]; then
        echo -e "${YLW}CAN Analyzer is not installed to $soft_dir/can-analyzer/, you need to revise file:${NOC}"
        echo -e "${YLW}$folder/$file accordingly.${NOC}"
    fi
}

# =============================================================================
# note
function _dj_setup_can_analyzer() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf can-analyzer
    _show_and_run git clone https://github.com/dj-zhou/can-analyzer.git
    _show_and_run chmod +x can-analyzer/CANAnalysis
    _popd_quiet
    _create_can_analyzer_desktop_item
}

# =============================================================================
function _dj_setup_can_dev_tools() {
    sudo apt update &>/dev/null
    echo -e "going to install ${INFO}can-utils${NOC}"
    _show_and_run _install_if_not_installed can-utils
}

# =============================================================================
# it failed to install v1.9.0 on ubuntu 20.04, due to build error from googletest
function _dj_setup_cli11() {
    _show_and_run _pushd_quiet ${PWD}
    if [ ! -z $1 ]; then
        v=$1
    else
        v=$(_find_package_version cli11)
    fi
    _echo_install CLI11 v$v
    _press_enter_or_wait_s_continue 5

    # remove some exisiting files to prevent error
    # v2.1.1 does not have CLI11.pc file installed, but >=v2.0.0 has!
    _show_and_run sudo rm -rf /usr/local/lib/pkgconfig/CLI11.pc
    _show_and_run sudo rm -rf /usr/local/lib/cmake/CLI11/CLI11Config.cmake
    _show_and_run sudo rm -rf /usr/local/lib/cmake/CLI11/CLI11ConfigVersion.cmake

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run sudo rm -rf CLI11/
    _show_and_run git clone https://github.com/CLIUtils/CLI11
    _show_and_run cd CLI11
    _show_and_run git checkout v$v
    # gtest is a submodule of it
    _show_and_run git submodule update --init
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo -e "\n${INFO}CLI11 $v${NOC} is installed."
    anw=$(_version_if_ge_than $v "1.9.0")
    if [ "$anw" = "no" ]; then
        _verify_header_files CLI.hpp /usr/local/include/CLI
        _verify_cmake_files CLI11Config.cmake /usr/local/lib/cmake/CLI11
        _verify_cmake_files CLI11ConfigVersion.cmake /usr/local/lib/cmake/CLI11
        _verify_pkgconfig_file CLI11.pc /usr/local/lib/pkgconfig
    else
        _verify_header_files CLI.hpp /usr/local/include/CLI
        _verify_cmake_files CLI11Config.cmake /usr/local/share/cmake/CLI11
        _verify_cmake_files CLI11ConfigVersion.cmake /usr/local/share/cmake/CLI11
        _verify_pkgconfig_file CLI11.pc /usr/local/share/pkgconfig
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_k9s() {

    _show_and_run _pushd_quiet ${PWD}
    v=$(_find_package_version k9s)
    if [[ "$v" = *"not be installed"* ]]; then
        _show_and_run dj setup k9s
    fi
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run rm -rf k9s-*
    file="k9s-v${v}.zip"
    _show_and_run rm -rf $file
    _show_and_run wget -O "$file" "https://codeload.github.com/derailed/k9s/zip/refs/tags/v${v}"
    _show_and_run unzip "$file"

    _show_and_run pushd k9s-${v}/
    _show_and_run git init
    _show_and_run git add .
    _show_and_run git commit -m "local build"
    COMMIT=$(git rev-parse HEAD)
    DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    _show_and_run go build -ldflags="-s -w -X github.com/derailed/k9s/cmd.version=0.50.9 -X github.com/derailed/k9s/cmd.commit=$COMMIT -X github.com/derailed/k9s/cmd.date=$DATE" -o k9s .

    _show_and_run sudo mv k9s /usr/local/bin/

    _popd_quiet
}

# =============================================================================
function _dj_setup_kdiff3() {
    check_m=$(sysctl -a | grep machdep.cpu.brand_string)
    if [[ "$check_m" = *"Apple M"* ]]; then
        echo "This is an Apple M sillicon computer, need to run the following:"
        _show_and_run softwareupdate --install-rosetta --agree-to-license
        _show_and_run brew install kdiff3
    fi
    if [ "$system" = "Linux" ]; then
        _show_and_run _cask_install_if_not_installed kdiff3
    fi

    all_config=$(git config --list)
    if [[ "$all_config" = *"merge.tool"* ]]; then
        _show_and_run git config --global --replace-all merge.tool kdiff3
    else
        _show_and_run git config --global --add merge.tool kdiff3
    fi
    if [[ "$all_config" = *"diff.guitool"* ]]; then
        _show_and_run git config --global --replace-all diff.guitool kdiff3
    else
        _show_and_run git config --global --add diff.guitool kdiff3
    fi
}

# =============================================================================
# tested on ubuntu 18.04
function _dj_setup_kermit() {
    _show_and_run _install_if_not_installed ckermit lrzsz

    kermrc_file="kermrc"
    _show_and_run rm $kermrc_file -f
    _show_and_run touch $kermrc_file
    # _show_and_run does not show the ">>" thing
    _show_and_run echo 'set line /dev/ttyUSB0' >>$kermrc_file
    _show_and_run echo 'set speed 115200' >>$kermrc_file
    _show_and_run echo 'set carrier-watch off' >>$kermrc_file
    _show_and_run echo 'set handshake none' >>$kermrc_file
    _show_and_run echo 'set flow-control none' >>$kermrc_file
    _show_and_run echo 'set stop-bits 1' >>$kermrc_file
    _show_and_run echo 'set modem none' >>$kermrc_file
    _show_and_run echo 'set protocol zmodem' >>$kermrc_file
    _show_and_run echo 'connect' >>$kermrc_file
    _show_and_run mv $kermrc_file ~/.kermrc

    _show_and_run sudo cp $djtools_path/scripts/kermit-serial /usr/bin
    _show_and_run sudo chmod +x /usr/bin/kermit-serial

    cat <<eom
Kermit is installed, usage:
1. use ~/.kermrc config: $ kermit
2. use kermit-serial: $ kermit-serial /dev/ttyUSB0 115200
eom

}

# =============================================================================
function _dj_setup_gadgets() {
    _show_and_run _pushd_quiet ${PWD}

    v=$(version check eigen3)
    if [[ "$v" = *"not be installed"* ]]; then
        _show_and_run dj setup eigen3
    fi
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run sudo rm -rf dj-gadgets
    _show_and_run git clone https://github.com/dj-zhou/dj-gadgets.git
    _show_and_run cd dj-gadgets
    _show_and_run sudo rm -rf build
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    # check dependency
    v=$(version check cli11)
    if [[ "$v" = *"not be installed"* ]]; then
        _show_and_run dj setup cli11
    fi

    if [[ ! -f "/usr/local/include/magic_enum.hpp" ]]; then
        _show_and_run dj setup magic-enum
    fi

    # dj-file installation
    _show_and_run cd ../dj-file/
    _show_and_run rm -rf build
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make
    _show_and_run sudo make install

    _popd_quiet
}

# =============================================================================
# todo: for each package, yes (default) to intall, no to skip
function _dj_setup_devtools() {
    _show_and_run _install_if_not_installed \
        libncurses5-dev \
        libnl-genl-3-dev
}

# =============================================================================
# https://docs.docker.com/engine/install/ubuntu/
function _dj_setup_docker() {
    if [ "$system" = "Darwin" ]; then
        echo "Follow instructions from https://docs.docker.com/desktop/install/mac-install/"
        echo "then open \"docker\" from Applications to finish setup"
        return
    fi
    _show_and_run _pushd_quiet ${PWD}

    # Install a few prerequisite packages
    packages="apt-transport-https ca-certificates curl software-properties-common gnupg "
    _show_and_run _install_if_not_installed $packages

    docker_url="https://download.docker.com/linux/ubuntu"

    # Add the GPG key for the official Docker repository
    _show_and_run curl -fsSL $docker_url/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    _show_and_run sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the Docker repository to APT sources
    # the install page uses VERSION_CODENAME or UBUNTU_CODENAME, but they are not defined

    _show_and_run echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] $docker_url   "$(. /etc/os-release && echo "$ubuntu_codename")" stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    _show_and_run sudo apt-get -y update

    # Install
    _show_and_run sudo apt install docker-ce

    # check the status -- not sure if the "active status" need a system reboot
    _show_and_run sudo systemctl status docker

    # ----------------------------------------------
    # add current user to the docker group, which was created from above scripts
    # to avoid typing "sudo" whenever run the docker command
    # (to remove a user from a group: sudo gpasswd -d user group, need log in/out)
    _show_and_run sudo usermod -aG docker ${USER}
    _show_and_run su - ${USER}

    # to solve a problem: dial unix /var/run/docker.sock: connect: permission denied
    # (must run "exit" to exit the above entered session)
    _show_and_run sudo chmod 666 /var/run/docker.sock
    echo -e "you may need to reboot your computer so docker does not need sudo to run"

    _popd_quiet
}

# =============================================================================
function _dj_setup_docker_compose() {
    if [ "$system" = "Darwin" ]; then
        echo "If Docker Desktop is installed, docker-compose should just have came with it."
        return
    fi
    # "dj setup go" installs specific version, and won't be overwritten by the below script:
    _show_and_run _install_if_not_installed golang-go

    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run rm -rf compose
    _show_and_run git clone https://github.com/docker/compose.git
    _show_and_run cd compose
    local v=$(_find_package_version docker-compose)
    _show_and_run git checkout v$v
    _show_and_run make -j$(nproc)
    _show_and_run sudo cp bin/build/docker-compose /usr/local/bin

    _popd_quiet
}

# =============================================================================
function _dj_setup_picocom() {
    _pushd_quiet "${PWD}"

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    v=$(_find_package_version picocom)
    _echo_install picocom $v
    _press_enter_or_wait_s_continue 5

    _show_and_run rm -rf picocom
    _show_and_run git clone git@github.com:npat-efault/picocom.git
    _show_and_run cd picocom
    _show_and_run git checkout $V
    _show_and_run make
    _show_and_run sudo cp picocom /usr/bin/

    _popd_quiet
}

# =============================================================================
function _dj_setup_pip() {
    _pushd_quiet ${PWD}

    cd ~/
    _show_and_run _install_if_not_installed python3-pip
    _show_and_run _install_if_not_installed python-pip

    sudo pip install --upgrade pip
    sudo pip3 install --upgrade pip

    echo -e "check the pip/pip3 version by:"
    echo "   \$ pip --version"
    echo "   \$ pip3 --version"

    _popd_quiet
}

# =============================================================================
function _dj_setup_perf() {
    _show_and_run _install_if_not_installed linux-tools-common linux-tools-generic linux-tools-$(uname -r)
    _show_and_run _install_if_not_installed linux-tools-common linux-tools-generic

    echo "check perf version: \$ perf --version"
}

# =============================================================================
function _dj_setup_plotjuggler() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run _install_if_not_installed qtbase5-dev libqt5svg5-dev \
        libqt5websockets5-dev libqt5opengl5-dev libqt5x11extras5-dev

    v=$(_find_package_version plotjuggler)

    _show_and_run rm -rf PlotJuggler
    _show_and_run git clone https://github.com/facontidavide/PlotJuggler.git
    _show_and_run cd PlotJuggler
    _show_and_run git checkout $v
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    _popd_quiet
}

# =============================================================================
# v3.25.0 uses bazel to compile, so I installed bazel v6.4.0 by command:
# $ dj2 setup bazel
# however, the compile of protobuf is unachievable due to abseil link issue
# so I roll back to v3.21.12 version
function _dj_setup_protobuf() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run sudo rm -rf /usr/local/lib/libproto*
    _show_and_run sudo rm -rf /usr/bin/protoc
    _show_and_run sudo rm -rf /usr/local/bin/protoc

    local v=$(_find_package_version protobuf)

    # just do NOT enter into protobuf/ directory to pull
    _show_and_run rm -rf protobuf
    _show_and_run git clone https://github.com/google/protobuf
    _show_and_run cd protobuf
    _show_and_run git checkout v$v

    _show_and_run git submodule update --init --recursive

    _show_and_run mkdir build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    # seems not needed?
    _verify_lib_installation libprotobuf.a /usr/local/lib
    # _verify_lib_installation libprotobuf.la /usr/local/lib
    # _verify_lib_installation libprotobuf.so /usr/local/lib
    _verify_lib_installation libprotobuf-lite.a /usr/local/lib
    # _verify_lib_installation libprotobuf-lite.la /usr/local/lib
    # _verify_lib_installation libprotobuf-lite.so /usr/local/lib
    _verify_lib_installation libprotoc.a /usr/local/lib
    # _verify_lib_installation libprotoc.la /usr/local/lib
    # _verify_lib_installation libprotoc.so /usr/local/lib

    _popd_quiet

}

# =============================================================================
function _dj_setup_pycharm() {
    _show_and_run _install_if_not_installed snap

    _show_and_run sudo snap install pycharm-community --classic
}

# =============================================================================
function _dj_setup_python_3_10() {
    local anw=$(_check_file_existence deadsnake /etc/apt/sources.list.d)
    if [ "$anw" = "no" ]; then
        _show_and_run sudo add-apt-repository ppa:deadsnakes/ppa
        _show_and_run sudo apt-get -y update
    fi
    _show_and_run _install_if_not_installed python3.10
    _show_and_run _install_if_not_installed python3.9

    # ----------------------
    echo -e "run update-alternatives:"
    for i in 3 4 6 7 8 9 10; do
        if [ -f /usr/bin/python3.$i ]; then
            _show_and_run sudo update-alternatives --install \
                /usr/bin/python3 python3 /usr/bin/python3.$i $i
        fi
    done

    # ----------------------
    _show_and_run sudo update-alternatives --config python3

    # install some related software package
    _show_and_run _install_if_not_installed python3.10-distutils
    _show_and_run _install_if_not_installed python3.9-distutils

    # others ------------
    _show_and_run _install_if_not_installed python3-pip
    # _show_and_run pip3 install --upgrade setuptools # not working
}

# =============================================================================
function _dj_setup_python_3_11() {
    local anw=$(_check_file_existence deadsnake /etc/apt/sources.list.d)
    if [ "$anw" = "no" ]; then
        _show_and_run sudo add-apt-repository ppa:deadsnakes/ppa
        _show_and_run sudo apt-get -y update
    fi
    _show_and_run _install_if_not_installed python3.11
    _show_and_run _install_if_not_installed python3.10

    # ----------------------
    echo -e "run update-alternatives:"
    for i in 3 4 6 7 8 9 10 11; do
        if [ -f /usr/bin/python3.$i ]; then
            _show_and_run sudo update-alternatives --install \
                /usr/bin/python3 python3 /usr/bin/python3.$i $i
        fi
    done

    # ----------------------
    _show_and_run sudo update-alternatives --config python3

    # install some related software package
    _show_and_run _install_if_not_installed python3.11-distutils

    # others ------------
    _show_and_run _install_if_not_installed python3-pip
}

# =============================================================================
function _dj_setup_python_3_12() {
    local anw=$(_check_file_existence deadsnake /etc/apt/sources.list.d)
    if [ "$anw" = "no" ]; then
        _show_and_run sudo add-apt-repository ppa:deadsnakes/ppa
        _show_and_run sudo apt-get -y update
    fi
    _show_and_run _install_if_not_installed python3.12
    _show_and_run _install_if_not_installed python3.11

    # ----------------------
    echo -e "run update-alternatives:"
    for i in 3 4 6 7 8 9 10 11 12; do
        if [ -f /usr/bin/python3.$i ]; then
            _show_and_run sudo update-alternatives --install \
                /usr/bin/python3 python3 /usr/bin/python3.$i $i
        fi
    done

    # ----------------------
    _show_and_run sudo update-alternatives --config python3

    # install some related software package
    _show_and_run _install_if_not_installed python3.11-distutils

    # others ------------
    _show_and_run _install_if_not_installed python3-pip
}

# =============================================================================
function _dj_setup_qemu() {
    _show_and_run _pushd_quiet ${PWD}

    version=$1
    if [ $version = "2.11.1" ]; then
        # this may only work within Ubuntu 18.04, not tested on other platforms
        _show_and_run _install_if_not_installed qemu
    elif [ $version = "4.2.0" ]; then
        _show_and_run mkdir -p $soft_dir
        _show_and_run cd $soft_dir
        _show_and_run git clone git://git.qemu-project.org/qemu.git
        _show_and_run cd qemu
        _show_and_run git checkout stable-4.2
        _show_and_run mkdir -p build
        _show_and_run cd build
        # is this only for ARM? will fix it later if needed
        _show_and_run ../configure --target-list=arm-softmmu --audio-drv-list=
        _show_and_run make -j$(nproc)
        _show_and_run sudo make install
        echo -e "$CYN the installed qemu is probably for ARM only, check it later$NOC"
    fi

    _popd_quiet
}

# =============================================================================================
function _dj_setup_stm32_cube_mx_desktop_item() {
    if [ ! -f STM32CubeMX ]; then
        echo_warn "STM32CubeMX executable \"STM32CubeMX\" is not found in the current directory, exit!"
        return
    fi
    desktop_item_dir="/usr/share/applications"

    # copy the icon file
    _show_and_run sudo cp $djtools_path/settings/stm32-cube-mx.xpm $desktop_item_dir

    file="stm32-cube-mx.desktop"
    _show_and_run touch $file

    _show_and_run echo '[Desktop Entry]' >>$file
    _show_and_run echo 'Encoding=UTF-8' >>$file
    _show_and_run echo 'Name=cube-mx' >>$file
    _show_and_run echo 'Comment=cube-mx' >>$file
    _show_and_run echo 'Exec='${PWD}'/STM32CubeMX' >>$file
    _show_and_run echo 'Icon='$desktop_item_dir'/stm32-cube-mx.xpm' >>$file
    _show_and_run echo 'StartupNotify=false' >>$file
    _show_and_run echo 'Type=Application' >>$file
    _show_and_run echo 'Categories=Application;Development;' >>$file

    _show_and_run sudo rm -rf $desktop_item_dir/$file
    _show_and_run sudo mv $file $desktop_item_dir

    _show_and_run sudo chmod +x $desktop_item_dir/$file
}

# =============================================================================
function _dj_setup_stm32_cube_mx() {
    _show_and_run _pushd_quiet ${PWD}

    # tested on Ubuntu 20.04
    _install_if_not_installed default-jre
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run rm -rf stm32-cube-mx
    _show_and_run git clone https://github.com/dj-zhou/stm32-cube-mx.git

    _show_and_run cd stm32-cube-mx/
    _show_and_run ./merge-file.sh

    _show_and_run unzip en.stm32cubemx-lin.zip

    echo_highlight "Recommended to install to $soft_dir/STM32CubeMX directory"
    _show_and_run mv SetupSTM32CubeMX* SetupSTM32CubeMX
    _show_and_run chmod +x SetupSTM32CubeMX
    _show_and_run ./SetupSTM32CubeMX

    echo_info "Now you should navigate to the STM32CubeMX executable directory and run:"
    echo_cmd "dj setup stm32-cube-mx-desktop-item"

    _popd_quiet
}

# =============================================================================
function _dj_setup_stm32_cube_ide_desktop_item() {
    if [ ! -f stm32cubeide ]; then
        echo_warn "STM32CubeIDE executable \"stm32cubeide\" is not found in the current directory, exit!"
        return
    fi
    desktop_item_dir="/usr/share/applications"

    # copy the icon file
    _show_and_run sudo cp $djtools_path/settings/stm32-cube-ide.xpm $desktop_item_dir

    file="stm32-cube-ide.desktop"
    _show_and_run touch $file

    _show_and_run echo '[Desktop Entry]' >>$file
    _show_and_run echo 'Encoding=UTF-8' >>$file
    _show_and_run echo 'Name=cube-ide' >>$file
    _show_and_run echo 'Comment=cube-ide' >>$file
    _show_and_run echo 'Exec='${PWD}'/stm32cubeide' >>$file
    _show_and_run echo 'Icon='$desktop_item_dir'/stm32-cube-ide.xpm' >>$file
    _show_and_run echo 'StartupNotify=false' >>$file
    _show_and_run echo 'Type=Application' >>$file
    _show_and_run echo 'Categories=Application;Development;' >>$file

    _show_and_run sudo rm -rf $desktop_item_dir/$file
    _show_and_run sudo mv $file $desktop_item_dir

    _show_and_run sudo chmod +x $desktop_item_dir/$file
}

# =============================================================================
function _dj_setup_stm32_cube_ide() {
    _show_and_run _pushd_quiet ${PWD}

    # tested on Ubuntu 20.04/22.04
    _install_if_not_installed default-jre
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    local exist=0
    if [ -d stm32-cube-ide ]; then
        cd stm32-cube-ide
        remote_v=$(git remote -v | grep fetch | awk '{print $2}')
        echo "remote_v=$remote_v"
        if [ ! -z $remote_v ]; then
            exist=1
            cd ../
        else
            _show_and_run sudo rm stm32-cube-ide
        fi
    fi
    if [ $exist = 1 ]; then
        _show_and_run cd stm32-cube-ide
        _show_and_run git pull
    else
        _show_and_run git clone https://github.com/dj-zhou/stm32-cube-ide.git
        _show_and_run cd stm32-cube-ide/
    fi
    _show_and_run ./merge-file.sh

    _show_and_run unzip en.st-stm32cubeide-lin.zip

    echo_warn "Please install to $soft_dir/ directory"
    if [ -d $soft_dir/STM32CubeIDE ]; then
        _show_and_run sudo rm -rf $soft_dir/STM32CubeIDE
    fi
    _show_and_run mv st-stm32cubeide_* st-stm32cubeide.sh
    _show_and_run chmod +x st-stm32cubeide.sh
    _show_and_run ./st-stm32cubeide.sh

    echo_info "Despite of the license, I have installed the jlink udev rules into /etc/udev/rule.d/\n"
    _show_and_run sudo cp $djtools_path/settings/99-jlink.rules /etc/udev/rule.d/
    echo_info "Now you should navigate to the STM32CubeIDE executable directory and run:"
    echo_cmd "dj setup stm32-cube-ide-desktop-item"

    _popd_quiet
}

# =============================================================================================
function _dj_setup_stm32_cube_programmer_desktop_item() {
    desktop_item_dir="/usr/share/applications"

    # copy the icon file
    _show_and_run sudo cp $djtools_path/settings/stm32-cube-programmer.xpm $desktop_item_dir

    file="stm32-cube-programmer.desktop"
    _show_and_run touch $file

    target_dir="/usr/local/STMicroelectronics/STM32Cube/STM32CubeProgrammer"
    echo '[Desktop Entry]' >>$file
    echo 'Encoding=UTF-8' >>$file
    echo 'Name=cube-programmer' >>$file
    echo 'Comment=cube-programmer' >>$file
    echo 'Exec='$target_dir'/bin/STM32CubeProgrammer' >>$file
    echo 'Icon='$desktop_item_dir'/stm32-cube-programmer.xpm' >>$file
    echo 'StartupNotify=false' >>$file
    echo 'Type=Application' >>$file
    echo 'Categories=Application;Development;' >>$file

    _show_and_run sudo rm -rf $desktop_item_dir/$file
    _show_and_run sudo mv $file $desktop_item_dir

    _show_and_run sudo chmod +x $desktop_item_dir/$file

    _show_and_run sudo cp $target_dir/Drivers/rules/*.rules /etc/udev/rules.d/
}

# =============================================================================
function _dj_setup_stm32_cube_programmer() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run rm -rf stm32-cube-programer
    _show_and_run git clone git@github.com:dj-zhou/stm32-cube-programer.git
    _show_and_run cd stm32-cube-programer
    _show_and_run ./merge-file.sh
    _show_and_run unzip en.stm32cubeprg-lin.zip

    _show_and_run mv SetupSTM32CubeProgrammer*.linux SetupSTM32CubeProgrammer.linux
    _show_and_run sudo ./SetupSTM32CubeProgrammer.linux

    # stm32 cube programmer is installed to /usr/local/ directory, no need to choose
    _dj_setup_stm32_cube_programmer_desktop_item

    _popd_quiet
}

# =============================================================================
# stlink-v2 software from https://github.com/stlink-org/stlink
# Ubuntu 18.04: v1.6.1 works (need to run st-flash twice to download the firmware)
# Ubuntu 20.04: v1.7.0 works (fixed the bug in v1.6.1, bug: need to run twice to download the firmware)
function _dj_setup_stm32_tools() {
    _pushd_quiet ${PWD}

    echo -e "install ${INFO}st-link v2${NOC} and ${INFO}stm32flash${NOC} tools"
    _press_enter_or_wait_s_continue 5

    # remove a package that makes problem!
    if [[ ${ubuntu_v} = *'22.04'* ]]; then
        _show_and_run sudo apt remove brltty
    fi
    # install dependencies and some software ----------------
    packages="libusb-1.0.0-dev gtk+-3.0 cu putty screen cmake "
    _show_and_run _install_if_not_installed $packages
    # install cutecom from source ----------------
    _dj_setup_cutecom

    # install ch340 driver ----------------

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf CH341SER
    _show_and_run git clone https://github.com/juliagoda/CH341SER.git
    _show_and_run cd CH341SER
    _show_and_run make
    _show_and_run make load

    # install stlink ----------------
    _echo_install "stlink"
    _press_enter_or_wait_s_continue 5

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf stlink
    _show_and_run git clone https://github.com/stlink-org/stlink

    _show_and_run cd stlink
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        _show_and_run git checkout v1.7.0 # need test v1.7.0 before switch to it
    elif [[ ${ubuntu_v} = *'20.04'* || ${ubuntu_v} = *'22.04'* ]]; then
        _show_and_run git checkout v1.7.0
    else
        echo "${RED}NOT IMPLEMENTED YET${NOC}"
    fi

    _show_and_run sudo rm -rf /usr/local/bin/st-*
    _show_and_run make release -j$(nproc)
    _show_and_run cd build/Release/
    _show_and_run sudo make install
    _show_and_run sudo ldconfig

    # install stm32flash ----------------
    _echo_install "stm32flash"
    _press_enter_or_wait_s_continue 5
    _show_and_run cd $soft_dir
    _show_and_run rm -rf stm32-tools
    _show_and_run git clone https://github.com/dj-zhou/stm32-tools.git
    _show_and_run cd stm32-tools/stm32flash
    _show_and_run make clean
    _show_and_run make -j$(nproc)
    _show_and_run sudo rm -rf /usr/local/bin/stm32flash
    _show_and_run sudo make install

    # udev rule ----------------
    echo -e "add serial port privilege to current user ..."
    _press_enter_or_wait_s_continue 5
    _show_and_run sudo usermod -a -G dialout $(whoami)
    rule_file=stm32-tools.rules
    _show_and_run sudo rm -f /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyUSB[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyACM[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    _show_and_run sudo service udev restart

    _popd_quiet
}

# =============================================================================
function _dj_setup_glfw3() {
    _echo_install "glfw3"

    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    if [ $system = 'Darwin' ]; then
        _show_and_run _cask_install_if_not_installed cmake xorg-server
    elif [ $system = 'Linux' ]; then
        packages="build-essential cmake xorg-dev libglu1-mesa-dev "
        _show_and_run _install_if_not_installed $packages
    fi

    _show_and_run rm -rf glfw3
    _show_and_run git clone https://github.com/dj-zhou/glfw3.git
    _show_and_run cd glfw3/
    _show_and_run mkdir -p build
    _show_and_run cd build/
    _show_and_run cmake .. -DBUILD_SHARED_LIBS=ON
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install
    _show_and_run sudo ldconfig

    _popd_quiet
}

# =============================================================================
function _dj_setup_gnuplot() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf gnuplot
    _show_and_run git clone https://github.com/gnuplot/gnuplot.git
    _show_and_run cd gnuplot
    _show_and_run ./prepare
    _show_and_run ./configure
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install && sudo ldconfig

    _popd_quiet
}

# =============================================================================
function _dj_setup_go() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    v=$(_find_package_version go)
    echo "v=$v"
    ARCH="amd64"
    _show_and_run curl -O -L "https://golang.org/dl/go${v}.linux-${ARCH}.tar.gz"

    local url="https://golang.org/dl/"
    local file="go${v}.linux-${ARCH}.tar.gz"

    local checksum_output=$(curl -sL "$url" | grep -A 5 -w "$file")
    checksum_line=$(echo "$checksum_output" | tail -n 1)
    checksum_calc=$(sha256sum $file | awk '{print $1}')
    if [[ ! "$checksum_line"=*"$checksum_calc"* ]]; then
        echo_error "dj setup go: checksum error, exit."
        return
    fi

    _show_and_run tar -xf "$file"
    _show_and_run sudo rm -rf /usr/local/go
    _show_and_run sudo rm -rf /usr/bin/go # installed by apt
    _show_and_run sudo mv go /usr/local

    installed=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"PATH:/usr/local/go/bin"* ]]; then
            echo -e "PATH for go is setup correctly."
            echo -e "you can still revise $rc_file for manual setup."
            installed=1
        fi
    done <$rc_file
    if [[ $installed = '0' ]]; then
        echo -e "setup the PATH for go (golong)."
        echo -e '\n' >>$rc_file
        echo '# ===========================================================' >>$rc_file
        echo '# (djtools) go (golang) setup' >>$rc_file
        echo -e 'export PATH=$PATH:/usr/local/go/bin\n' >>$rc_file
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_google_repo() {
    _show_and_run _pushd_quiet ${PWD}

    # it needs python2
    _show_and_run _install_if_not_installed python

    if [ -f $djtools_path/tools/repo ]; then
        _show_and_run sudo cp $djtools_path/tools/repo /bin/
        _show_and_run sudo chmod a+x /bin/repo
    else
        echo -e "fetch from google "
        _show_and_run curl https://commondatastorage.googleapis.com/git-repo-downloads/repo >repo
        _show_and_run chmod a+x repo
        _show_and_run sudo mv repo /bin/
    fi

    cat <<eom
-----------------------------------------------------------------
  Google tool "repo" is installed into directory: /bin/
-----------------------------------------------------------------
eom
    _popd_quiet
}

# =============================================================================
function _dj_setup_googletest() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    local v=$(_find_package_version googletest)
    _echo_install googletest $v
    _press_enter_or_wait_s_continue 5

    _show_and_run sudo rm -rf googletest
    _show_and_run git clone https://github.com/google/googletest.git
    _show_and_run cd googletest
    _show_and_run git checkout release-$v
    _show_and_run sudo rm -rf build
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo -e "\n${INFO}googletest $v${NOC} is installed:"
    _verify_lib_installation libgtest.a /usr/local/lib
    _verify_lib_installation libgtest_main.a /usr/local/lib
    _verify_header_files gtest.h /usr/local/include/gtest
    _verify_pkgconfig_file gtest.pc /usr/local/lib/pkgconfig
    _verify_pkgconfig_file gtest_main.pc /usr/local/lib/pkgconfig

    _popd_quiet
}

# =============================================================================
# instlal gnome, need more test
function _dj_setup_gnome() {
    echo -e "install gnome on Ubuntu"
    _press_enter_or_wait_s_continue 5

    _show_and_run _install_if_not_installed tasksel gnome-session ubuntu-desktop

    echo -e "when log in, choose GNOME"
}

# =============================================================================
# ninja is used to compile
function _dj_setup_grpc() {
    _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    grpc_v=$(_find_package_version grpc)
    if [ ! -d grpc ]; then
        _show_and_run git clone https://github.com/grpc/grpc.git --recurse-submodules
        _show_and_run cd grpc
    else
        _show_and_run cd grpc
        _show_and_run git checkout master
        _show_and_run git fetch -p
        _show_and_run git pull
    fi
    _show_and_run git checkout v$grpc_v
    _show_and_run git submodule update --init --recursive
    _show_and_run rm -r build_dir
    _show_and_run mkdir -p build_dir
    _show_and_run cd build_dir
    _show_and_run cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF .. -GNinja
    _show_and_run cmake --build .
    _show_and_run sudo cmake --build . -- install

    _popd_quiet
}

# =============================================================================
# default compiles:
# Ubuntu 18.04: g++-7
# Ubuntu 20.04: g++-9
# Ubuntu 22.04: g++ 11.3.0
# make this function to install g++-9 on Ubuntu 18.04 as well!
function _dj_setup_gpp_10() {
    # install g++10/gcc-10
    echo -e "install ${INFO}gcc-10${NOC}, ${INFO}g++-10${NOC}"
    _press_enter_or_wait_s_continue 5

    if ! compgen -G "/etc/apt/sources.list.d/ubuntu-toolchain-r*.list" >/dev/null; then
        _show_and_run sudo add-apt-repository ppa:ubuntu-toolchain-r/test
        _show_and_run sudo apt-get -y update
    fi

    _show_and_run sudo apt-get install -y gcc-10
    _show_and_run sudo apt-get install -y g++-10

    # install g++9/gcc-9
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${INFO}gcc-9${NOC}, ${INFO}g++-9${NOC} "
        _press_enter_or_wait_s_continue 5
        _show_and_run _install_if_not_installed gcc-9 g++-9
    fi

    # ----------------------
    echo -e "run update-alternatives:"
    for i in 4 5 6 7 8 9 10; do
        if [ -f /usr/bin/gcc-$i ]; then
            _show_and_run sudo update-alternatives --install \
                /usr/bin/gcc gcc /usr/bin/gcc-$i $i
        fi
        if [ -f /usr/bin/g++-$i ]; then
            _show_and_run sudo update-alternatives --install \
                /usr/bin/g++ g++ /usr/bin/g++-$i $i
        fi
    done
    _show_and_run sudo update-alternatives --config gcc
    _show_and_run sudo update-alternatives --config g++
}

# =============================================================================
function _dj_setup_gpp_11() {
    # install g++11/gcc-11
    echo -e "install ${INFO}gcc-11${NOC}, ${INFO}g++-11${NOC}"
    _press_enter_or_wait_s_continue 5

    if ! compgen -G "/etc/apt/sources.list.d/ubuntu-toolchain-r*.list" >/dev/null; then
        _show_and_run sudo add-apt-repository ppa:ubuntu-toolchain-r/test
        _show_and_run sudo apt-get -y update
    fi

    _show_and_run sudo apt-get install -y gcc-11
    _show_and_run sudo apt-get install -y g++-11

    # install g++10/gcc-10
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${INFO}gcc-10${NOC}, ${INFO}g++-10${NOC} "
        _press_enter_or_wait_s_continue 5
        _show_and_run _install_if_not_installed gcc-10 g++-10
    fi

    # install g++9/gcc-9
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${INFO}gcc-9${NOC}, ${INFO}g++-9${NOC} "
        _press_enter_or_wait_s_continue 5
        _show_and_run _install_if_not_installed gcc-9 g++-9
    fi

    # ----------------------
    echo -e "run update-alternatives:"
    for i in 4 5 6 7 8 9 10 11; do
        if [ -f /usr/bin/gcc-$i ]; then
            _show_and_run sudo update-alternatives --install \
                /usr/bin/gcc gcc /usr/bin/gcc-$i $i
        fi
        if [ -f /usr/bin/g++-$i ]; then
            _show_and_run sudo update-alternatives --install \
                /usr/bin/g++ g++ /usr/bin/g++-$i $i
        fi
    done
    _show_and_run sudo update-alternatives --config gcc
    _show_and_run sudo update-alternatives --config g++
}

# =============================================================================
function _dj_setup_rust() {
    echo -e "install ${INFO}rust${NOC}"
    _show_and_run curl https://sh.rustup.rs -sSf | sh
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>$rc_file
    echo -e "You need to run ${INFO}\"source $rc_file\"${NOC} manually."
    echo -e "update rust by ${INFO}rustup update${NOC}"
    echo -e "check rust version by ${INFO}rustc --version${NOC}"
    echo -e "check cargo version by ${INFO}cargo --version${NOC}"
    echo -e "uninstall rust by ${INFO}rustup self uninstall${NOC}"
    echo -e "compile a rust program by (example) ${INFO}rustc main.rs${NOC}"
}

# =============================================================================
# https://www.linuxbabe.com/desktop-linux/how-to-install-chinese-wubi-input-method-on-debian-8-gnome-desktop
# tested on Ubuntu 16.04, 18.04 and 20.04
function _dj_setup_wubi() {
    _pushd_quiet ${PWD}

    _show_and_run _install_if_not_installed ibus ibus-table-wubi
    if [[ ${ubuntu_v} = *'16.04'* ]]; then
        cat <<eom
-----------------------------------------------------------------
Follow the steps:
1. log out and log in again;
2. $ ibus-setup
    then in the opened window: Input Method -> Add -> Chinese -> choose WuBi-Jidian-86-JiShuang
3. im-config -n ibus
    this step will show nothing
4. add an input source:
    Settings -> Keyboard -> Input Sources -> Others -> Chinese -> Chinese (WuBi-Jidian-86-JiShuang-6.0)
-----------------------------------------------------------------

eom
    elif [[ ${ubuntu_v} = *'18.04'* ||
        ${ubuntu_v} = *'20.04'* ]]; then
        echo -e "please follow the link below to finish the setup:"
        echo -e " https://www.pinyinjoe.com/linux/ubuntu-18-gnome-chinese-setup.htm"
    fi
    _popd_quiet
}

# =============================================================================
# call function in workspace-check.bash
function _dj_work_check() {
    _work_check "$@"
}

# =============================================================================
# to search a library use: ldconfig -p | grep xxxx
# once this command get extended, we add sub command to "dj search"
function _dj_grep_package() {
    _show_and_run _pushd_quiet ${PWD}

    lib_to_find=$1
    echo -e "run: ${INFO}ldconfig -p | grep $lib_to_find${NOC}:"

    ldconfig -p | grep $lib_to_find

    # pkgconfig file cannot also be in /usr/local/lib/pkgconfig/, so, this is not general
    # fix it in the future
    # echo -e "cd /usr/lib/x86_64-linux-gnu/pkgconfig"
    # cd /usr/lib/x86_64-linux-gnu/pkgconfig
    # echo -e " \$ ls | grep $lib_to_find"
    # ls | grep $lib_to_find

    _popd_quiet
}

# =============================================================================
# todo: combine exclude-dir and excludes
function _dj_grep_string() {
    if [ "$1" = "--in-bash" ]; then
        echo -e "grep in ${INFO}*.bash, *.sh${NOC} files"
        # how to search in the files without extension??
        grep "$2" -rIn \
            --include={"*.bash","*.sh"} \
            --exclude-dir={".venv","build","subprojects","bin","_b*","builddir",".git",".cache"} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "--in-ccode" ]; then
        echo -e "grep in ${INFO}*.c,*.cpp,*.h,*.hpp,Makefile*,CMakeLists.txt${NOC} files"
        grep "$2" -rn \
            --include={"*.c","*.cpp","*.h","*.hpp","Makefile*","CMakeLists.txt"} \
            --exclude-dir={".venv","build","subprojects","bin","_b*","builddir",".git",".cache"} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "--in-config" ]; then
        echo -e "grep in ${INFO}*.json,Dockerfile,*.xml${NOC} files"
        grep "$2" -rIn \
            --include={"*.json","Dockerfile","*.xml"} \
            --exclude-dir={".venv","build","subprojects","bin","_b*","builddir",".git",".cache"} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "--in-js" ]; then
        echo -e "grep in ${INFO}js, jsx${NOC} files"
        grep "$2" -rI \
            --include={"*.js","*.jsx"} \
            --exclude-dir={".venv","build","subprojects","bin","_b*","builddir",".git",".cache","node_modules"} \
            --exclude={'*.lst','*.pyc'} \
            .
        return
    fi
    if [ "$1" = "--in-meson" ]; then
        echo -e "grep in ${INFO}meson.build${NOC} files"
        _dj_grep_string_in_meson "$2"
        return
    fi
    if [ "$1" = "--in-python" ]; then
        echo -e "grep in ${INFO}*.py,*.ipynb${NOC} files"
        grep "$2" --color=always -rI \
            --include={"*.py","*.ipynb"} \
            --exclude-dir={".venv",".dev-venv","build","subprojects","bin","_b*","builddir",".git",".cache"} \
            --exclude={'*.lst','*.pyc'} \
            . | awk -F ":" '{print $1 " :" $2}'
        return
    fi
    if [ "$1" = "--in-rust" ]; then # seems not working for *.rs files
        echo -e "grep in ${INFO}*.rs,Cargo.toml,Cargo.lock${NOC} files"
        # not a bug, a single "*.rs" does not work here, don't know why
        grep "$2" -rIn \
            --include={"*.rs","*.rs","Cargo.toml","Cargo.lock"} \
            --exclude-dir={".venv","build","subprojects","bin","_b*","builddir",".git",".cache"} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "--in-yaml" ]; then
        echo -e "grep in ${INFO}*.yml,*.yaml${NOC} files"
        grep "$2" -rIn \
            --include={"*.yml","*.yaml"} \
            --exclude-dir={".venv","build","subprojects","bin","_b*","builddir",".git",".cache"} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "--in-yocto-recipe" ]; then
        echo -e "grep in ${INFO}*.bb,*.conf,*.inc,*.sample,*.bbappend${NOC} files"
        grep "$2" -rIn \
            --include={"*.bb","*.conf","*.inc","*.sample","*.bbappend"} \
            --exclude-dir={".venv","build","subprojects","bin","_b*","builddir",".git",".cache"} \
            --exclude='*.lst' \
            .
        return
    fi
}

# =============================================================================
# to find something in a meson file
# only works in . directory
function _dj_grep_string_in_meson() { # term
    term=$1
    if [ -z "$term" ]; then
        echo -e "usage:"
        echo -e "   dj meson find <something>"
        return
    fi
    all_meson_build=$(find . -name meson.build)
    if [ -z "$all_meson_build" ]; then
        echo "no meson.build file found, exit."
        return
    fi
    for file in $all_meson_build; do
        find_term=$(grep -rn "$term" "$file")
        if [ ! -z "$find_term" ]; then
            echo -e "\n${INFO} ---------------------------------------"
            echo -e "$file${NOC}"
            echo "$find_term"
        fi
    done
}

# =============================================================================
function _dj_open_file() {
    # --------------------------
    if [ $# -eq 0 ]; then
        nautilus .
        return
    fi
    # --------------------------
    if [ $# -eq 1 ]; then
        nautilus $1
        return
    fi
}

# =============================================================================
function _dj_ssh_general_no_password() {
    if [ $# = 0 ]; then
        echo -e "usage:"
        echo -e "$ dj ssh-general no-password user@ip"
        return
    fi
    user_and_ip="$1"
    user=${user_and_ip%"@"*}
    pos=$(_find_a_char_in_str $user_and_ip "@" 1)
    ip=${user_and_ip:${pos}+1:${#user_and_ip}-${pos}}

    # if ~/.ssh/id_rsa.pub does not exist, create one
    # when ssh to the target, it find the default id_rsa file, not any other names
    key_file="${HOME}/.ssh/id_rsa"
    if [ ! -f "$key_file" ]; then
        _show_and_run printf "${key_file}\n\n" | _show_and_run ssh-keygen
    fi

    # just to create .ssh on target machine
    _show_and_run ssh -l $user $ip "mkdir -p ~/.ssh"

    # then run, copy the content of local id_rsa.pub to .ssh/autorized_keys in remote
    echo "${INFO}copy $key_file to the remote:${NOC}"
    cat "${key_file}.pub" | ssh $user_and_ip "cat >> ~/.ssh/authorized_keys"
}

# =============================================================================
function _dj_ssh_general() {
    # ------------------------------
    if [ $1 = 'no-password' ]; then
        shift 1
        _dj_ssh_general_no_password "$@"
        return
    fi
}

# =============================================================================
# reference: https://gist.github.com/jexchan/2351996
# I don't know why ~/.ssh/config is not needed
# make sure the content in ~/.ssh/id_rsa-github-<account>.pub is pasted to the GitHub account
# install ssh-askpass to avoid some error, however, it will have an popup window to press
function _dj_git_ssh_account_activate() {
    if [ $system = 'Linux' ]; then
        _show_and_run _install_if_not_installed ssh-askpass
    fi

    github_username=$1
    key_file=${HOME}/.ssh/id_rsa-github-$github_username
    if [ ! -f ${key_file} ]; then
        # ask if proceed (yes/no) --------------
        echo -e "account $1 does not exist, do you want to create it? (yes/no)"
        read asw
        if [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') || (
            $asw = 'No') || ($asw = 'no') ]]; then
            echo 'Canceled and exit!'
            return
        elif [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || (
            $asw = 'Yes') || ($asw = 'yes') ]]; then
            # proceed -------------
            echo -e "SSH key file ${INFO}${key_file}${NOC} not found, generate one automatically:"
            echo -e "${YLW}Press [OK] on the popup window${NOC}"
            _show_and_run printf "${key_file}\n\n\n\n" | ssh-keygen
            echo -e "copy the following content into a new GitHub SSH Key (https://github.com/settings/keys, need login):"
            echo -e "${INFO}"
            cat ${key_file}.pub
            echo -e "${NOC}"
        else
            echo "Wrong answer! Canceled and exit!"
        fi
    fi

    # if see this error: Error connecting to agent: Connection refused, do
    # it is just fine to run it
    _show_and_run eval "$(ssh-agent)" &>/dev/null
    _show_and_run ssh-add -D
    _show_and_run ssh-add ${key_file}
    echo $github_username >~/.ssh/.github-activated-account
}

# =============================================================================
function _dj_git_ssh_account_show_current() {
    if [ ! -f ~/.ssh/.github-activated-account ]; then
        echo -e "you need to run ${INFO}dj ssh-github activate <github username>${NOC} to activate one"
        return
    fi
    _show_and_run cat ~/.ssh/.github-activated-account
}

# =============================================================================
function _dj_flame_grapah() {
    if [ "$1" = 'clear' ]; then
        _show_and_run sudo rm -f perf.data.old
        _show_and_run sudo rm -f perf.folded
        _show_and_run sudo rm -f perf.unfold
        _show_and_run sudo rm -f perf.svg
        return 0
    fi
    if [ "$1" = 'help' ]; then
        echo "\$ perf record --call-graph dwarf <executable>"
        echo "\$ perf record -e cpu-clock -g <executable>"
        echo "manual: https://man7.org/linux/man-pages/man1/perf-record.1.html"
        return 0
    fi

    # add options here
    while getopts "f:" flag; do
        case "${flag}" in
        f) perf_data_file= "${OPTARG}" ;;
        esac
    done

    # default files
    if [ -z "${perf_data_file}" ]; then
        perf_data_file="perf.data"
    fi
    if [ ! -f "${perf_data_file}" ]; then
        echo "${perf_data_file} not found, exit."
        echo -e "use command ${INFO}perf record -e cpu-clock -g <executable>${NOC}"
        echo -e "or ${INFO}perf record --call-graph dwarf <executable>${NOC}"
        echo -e "to generate perf.data."
        return 1
    fi
    # need sudo??
    _show_and_run sudo perf script -i ${perf_data_file} &>perf.unfold
    _show_and_run stackcollapse-perf.pl perf.unfold &>perf.folded
    _show_and_run flamegraph.pl perf.folded >perf.svg

    if [ -f "perf.svg" ]; then
        echo "perf.svg is generated, use browser to open it."
    else
        echo "perf.svg is not generated."
    fi
    return 0
}

# =============================================================================
function _dj_grep() {
    # ------------------------------
    if [ $1 = '--package' ]; then
        # ------------------------------
        if [[ $# -ge 2 ]]; then
            shift 1
            _dj_grep_package "$@"
            return
        fi
    fi
    # ------------------------------
    if [ $1 = '--string' ]; then
        # ------------------------------
        if [[ $# -ge 2 ]]; then
            shift 1
            _dj_grep_string "$@"
            return
        fi
    fi
    echo "dj grep: wrong argument, exit."
    return
}

# =============================================================================
function dj() {
    if [ $# -eq 0 ]; then
        _dj_help
        return
    fi
    case $1 in
    'clean') shift && _dj_clean "$@" ;;
    'flame-graph') shift && _dj_flame_grapah "$@" ;;
    'format') shift && _dj_format "$@" ;;
    'grep') shift && _dj_grep "$@" ;;
    'get') shift && _dj_get "$@" ;;
    'git') shift && _dj_git "$@" ;;
    'help') shift && _dj_help_skill "$@" ;;
    'merge') shift && _dj_merge "$@" ;;
    'open') shift && _dj_open_file "$@" ;;
    'pack') shift && _dj_pack "$@" ;;
    'python3') shift && _dj_python3 "$@" ;;
    'replace') shift && _dj_replace "$@" ;;
    'setup') shift && _dj_setup "$@" ;;
    'split') shift && _dj_split "$@" ;;
    'ssh-general') shift && _dj_ssh_general "$@" ;;
    'systemd') shift && _dj_systemd "$@" ;;
    'udev') shift && _dj_udev "$@" ;;
    'udevadm') shift && _dj_udevadm "$@" ;;
    'unpack') shift && _dj_unpack "$@" ;;
    'work-check') shift && _dj_work_check "$@" ;;

    *) echo "Invalid option: $1" && _dj_help ;;
    esac
}

_grep_list="--string "
if [ $system = 'Linux' ]; then
    _grep_list+="--package "
    # elif [ $system = 'Darwin' ]; then
    # do nothing here
fi

_grep_string_list="--in-bash --in-config --in-js --in-meson --in-python --in-ccode "
_grep_string_list+="--in-rust --in-yaml --in-yocto-recipe "

# =============================================================================
function _dj_linux() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        clean
        flame-graph
        format
        get
        git
        grep
        help
        merge
        open
        python3
        pack
        replace
        setup
        split
        ssh-general
        systemd
        udev
        udevadm
        unpack
        work-check
    ")

    # declare an associative array for options
    declare -A ACTIONS
    # --------------------------------------------------------
    # --------------------------------------------------------
    # get.bash
    ACTIONS["get"]="$get_list "
    for i in $get_list; do
        ACTIONS["$i"]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS["setup"]="$setup_list "
    for i in $setup_list; do
        ACTIONS["$i"]=" "
    done
    # special ones -----------------
    cli11_version="1.9.0 2.1.1 "
    ACTIONS["cli11"]="$cli11_version"
    for i in $cli11_version; do
        ACTIONS["$i"]=" "
    done
    # ---------------------
    ACTIONS["driver"]="wifi "
    wifi_list="rtl8812au "
    ACTIONS["wifi"]="$wifi_list "
    for i in $wifi_list; do
        ACTIONS["$i"]=" "
    done
    # ---------------------
    ACTIONS["i219-v"]="e1000e-3.4.2.1 e1000e-3.4.2.4 "
    ACTIONS["e1000e-3.4.2.1"]=" "
    ACTIONS["e1000e-3.4.2.4"]=" "
    # ---------------------
    ACTIONS["opencv-4.1.1"]="with-contrib no-contrib "
    ACTIONS["with-contrib"]=" "
    ACTIONS["no-contrib"]=" "
    # ---------------------
    ACTIONS["qemu"]="2.11.1 4.2.0 "
    ACTIONS[2.11.1]=" "
    ACTIONS[4.2.0]=" "
    # ---------------------
    ACTIONS["ros-melodic"]="--from-deb-package --from-source "
    ACTIONS["ros-noetic"]=" "
    ACTIONS["ros2-foxy"]="--from-deb-package --from-source "
    ACTIONS["--from-deb-package"]=" "
    ACTIONS["--from-source"]=" "
    # ---------------------
    ACTIONS["spdlog"]="static shared "
    ACTIONS["static"]=" "
    ACTIONS["shared"]=" "
    ACTIONS[0.6.2]=" "
    ACTIONS[0.6.3]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS["clean"]="$clean_list "
    for i in $clean_list; do
        ACTIONS["$i"]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS["split"]="$(ls)"

    # --------------------------------------------------------
    # --------------------------------------------------------
    flame_list="generate clear help "
    ACTIONS["flame-graph"]="$flame_list "
    for i in $flame_list; do
        ACTIONS["$i"]=" "
    done
    # --------------------------------------------------------
    format_list="brush show python-dir cpp-dir "
    ACTIONS["format"]="$format_list "
    for i in $format_list; do
        ACTIONS["$i"]=" "
    done
    brush_list="google file "
    ACTIONS["brush"]="$brush_list"
    for i in $brush_list; do
        ACTIONS["$i"]=" "
    done
    implement_list="djz bg "
    ACTIONS["implement"]="$implement_list"
    for i in $implement_list; do
        ACTIONS["$i"]=" "
    done
    # -----------------
    show_list="camel "
    ACTIONS["show"]="$show_list "
    for i in $show_list; do
        ACTIONS["$i"]=" "
    done

    # --------------------------------------------------------
    ACTIONS[replace]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS[open]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS["python3"]="$_python3_cmds "
    # ------------------------
    ACTIONS["install"]="$_install_list "
    for i in $_install_list; do
        ACTIONS[$i]=" "
    done
    # ------------------------
    ACTIONS["virtual-env"]="$_virtual_env_list "
    for i in $_virtual_env_list; do
        ACTIONS[$i]=" "
    done
    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS["ssh-general"]="no-password "
    ACTIONS["no-password"]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    systemd_list="umount "
    ACTIONS["systemd"]="$systemd_list  "
    for i in $systemd_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS["work-check"]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS[udev]="$udev_list "
    for i in $udev_list; do
        ACTIONS[$i]=" "
    done
    ACTIONS[udevadm]="$udevadm_list "
    for i in $udevadm_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS[grep]="$_grep_list "
    for i in $_grep_list; do
        ACTIONS[$i]=" "
    done

    ACTIONS["--string"]="$_grep_string_list "
    for i in $_grep_string_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    # git.bash
    ACTIONS["git"]="$git_list "
    for i in $git_list; do
        ACTIONS["$i"]=" "
    done
    ACTIONS["search"]="$git_search_list "
    for i in $git_search_list; do
        ACTIONS["$i"]=" "
    done

    # --------------------------------------------------------
    ACTIONS["ssh-account"]="$git_ssh_account_list "
    for i in $git_ssh_account_list; do
        ACTIONS["$i"]=" "
    done

    all_accounts="$(_dj_git_ssh_account_show_all) "
    ACTIONS["--activate"]="$all_accounts "
    for i in $all_accounts; do
        ACTIONS["$i"]=" "
    done

    # --------------------------------------------------------
    ACTIONS["ssh-clone"]="bitbucket github "
    # --------------------------------------------------------
    bitbucket_repos="$(_dj_clone_repo_list bitbucket) "
    ACTIONS["bitbucket"]+="$bitbucket_repos "
    ACTIONS["bitbucket"]+="--add "
    for i in $bitbucket_repos; do
        ACTIONS["$i"]=" "
    done
    # --------------------------------------------------------
    github_repos="$(_dj_clone_repo_list github) "
    ACTIONS["github"]+="$github_repos "
    ACTIONS["github"]+="--add "
    for i in $github_repos; do
        ACTIONS["$i"]=" "
    done
    ACTIONS[--add]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS["help"]="$_help_list "
    for i in $_help_list; do
        ACTIONS["$i"]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    pack_list="-tar.gz "
    ACTIONS["pack"]="$pack_list "
    for i in $pack_list; do
        ACTIONS["$i"]=" "
    done
    # --------------------------------------------------------
    pack_tar_gz_list="$(ls .)"
    ACTIONS["-tar.gz"]="$pack_tar_gz_list "
    for i in $pack_tar_gz_list; do
        ACTIONS["$i"]=" "
    done
    # --------------------------------------------------------
    # --------------------------------------------------------
    unpack_list="tar.xz tar.gz "
    ACTIONS["unpack"]="$unpack_list "
    # --------------------------------------------------------
    unpack_tar_xz_list="$(ls . | grep tar.xz)"
    ACTIONS["tar.xz"]+="$unpack_tar_xz_list "
    for i in $unpack_tar_xz_list; do
        ACTIONS["$i"]=" "
    done
    # --------------------------------------------------------
    unpack_tar_gz_list="$(ls . | grep tar.gz)"
    ACTIONS["tar.gz"]+="$unpack_tar_gz_list "
    for i in $unpack_tar_gz_list; do
        ACTIONS["$i"]=" "
    done

    # --------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
# Function to provide custom completions
function _dj_darwin() {
    # Getting the current word and previous word in the command-line
    local curcontext="$curcontext" state line
    typeset -A opt_args

    # Array of options for the custom command
    custom_options=(
        clean
        format
        get
        git
        grep
        setup
        ssh-general
        work-check
    )
    # ------------
    read -r -A clean_options <<<"$clean_list"
    # ------------
    read -r -A format_options <<<"$format_list"
    # ------------
    read -r -A get_options <<<"$get_list"
    # ------------
    read -r -A git_options <<<"$git_list"
    read -r -A git_search_options <<<"$git_search_list"
    read -r -A git_ssh_account_options <<<"$git_ssh_account_list"
    # ------------
    read -r -A grep_options <<<"$_grep_list"
    read -r -A grep_string_options <<<"$_grep_string_list"
    # ------------
    read -r -A setup_options <<<"$setup_list"
    # ------------
    ssh_general_list="no-password "
    read -r -A ssh_generals_options <<<"$ssh_general_list"
    # ------------
    work_check_list=" "
    read -r -A work_check_options <<<"$work_check_list"

    # Defining states for the completion
    _arguments -C \
        '1: :->first' \
        '2: :->second' \
        '3: :->third' && return 0

    case $state in
    first)
        _wanted fl_options expl 'main option' compadd -a custom_options
        ;;
    second)
        case $words[2] in
        "clean")
            _wanted clean_sl_options expl 'subcommand for clean' compadd -a clean_options
            ;;
        "format")
            _wanted format_sl_options expl 'subcommand for format' compadd -a format_options
            ;;
        "get")
            _wanted get_sl_options expl 'subcommand for get' compadd -a get_options
            ;;
        "git")
            _wanted git_sl_options expl 'subcommand for git' compadd -a git_options
            ;;
        "grep")
            _wanted grep_sl_options expl 'subcommand for grep' compadd -a grep_options
            ;;
        "setup")
            _wanted setup_sl_options expl 'subcommand for setup' compadd -a setup_options
            ;;
        "ssh-general")
            _wanted ssh_general_sl_options expl 'subcommand for ssh-general' compadd -a ssh_generals_options
            ;;
        "work-check")
            _wanted work_check_sl_options expl 'subcommand for work-check' compadd -a work_check_options
            ;;
        esac
        ;;
    third)
        case $words[2] in
        git)
            case $words[3] in
            search)
                _wanted git_tl_options expl 'subcommands for git search' compadd -a git_search_options
                ;;
            ssh-account)
                _wanted git_tl_options expl 'subcommands for git ssh-account' compadd -a git_ssh_account_options
                ;;
            esac
            ;;
        grep)
            case $words[3] in
            --string)
                _wanted grep_tl_options expl 'subcommands for grep --string' compadd -a grep_string_options
                ;;
            esac
            ;;
        esac
        ;;
    esac
}

# =============================================================================
if [ $system = 'Linux' ]; then
    complete -F _dj_linux dj
elif [ $system = 'Darwin' ]; then
    compdef _dj_darwin dj
fi
