#!/bin/bash

source $djtools_path/clang-format.bash
source $djtools_path/clone.bash
source $djtools_path/help.bash
source $djtools_path/get.bash
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
    echo "   git        - git related features: cofnig. search, ssh-account, ssh clone"
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
        echo "run \"version swap g++\" to use higher version of g++ (>=10.1.0)"
        echo "run \"version swap gcc\" to use higher version of gcc (>=10.1.0)"
        return
    fi
    v=$(_find_package_version boost)
    _echo_install boost $v
    _press_enter_or_wait_s_continue 5

    # remove previously installed files
    _show_and_run sudo rm -rf /usr/local/include/boost
    _show_and_run sudo rm -rf /usr/local/lib/libboost*

    _show_and_run _install_if_not_installed python3-dev libxml2-dev
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
    _verify_lib_installation libboost_atomic.so /usr/local/lib
    _verify_lib_installation libboost_timer.so /usr/local/lib

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
    echo -e "going to install ${GRN}can-utils${NOC}"
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

    echo -e "\n${GRN}CLI11 $v${NOC} is installed."
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
# setting a fixed version is not a good idea, but ...
function _dj_setup_cmake() {
    # install dependencies
    _show_and_run _install_if_not_installed libssl-dev gcc g++
    new_v=$(_find_package_version cmake)
    v=v$new_v
    _echo_install CMake $v

    current_v=$(version check cmake)
    anw=$(_version_if_ge_than $current_v $new_v)
    if [ "$anw" = "yes" ]; then
        echo "CMake is as new as $current_v, no need to install $new_v"
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
    echo -e "${GRN}cmake${NOC} is installed to ${GRN}/usr/local/bin${NOC}"

    _popd_quiet
}

# =============================================================================
function _dj_setup_kdiff3_meld() {
    _show_and_run _install_if_not_installed kdiff3 meld

    all_config=$(git config --list)
    if [[ "$all_config" = *"merge.tool"* ]]; then
        git config --global --replace-all merge.tool kdiff3
    else
        git config --global --add merge.tool kdiff3
    fi
    if [[ "$all_config" = *"diff.guitool"* ]]; then
        git config --global --replace-all diff.guitool meld
    else
        git config --global --add diff.guitool meld
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
function _dj_setup_container_docker() {
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
    if [[ "${ubuntu_v}" = *'20.04'* ]]; then
        codename="focal"
    elif [[ "${ubuntu_v}" = *'22.04'* ]]; then
        codename="jammy"
    fi

    _show_and_run echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] $docker_url   "$(. /etc/os-release && echo "$codename")" stable" |
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
function _dj_setup_container_docker_compose() {
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
# https://github.com/wagoodman/dive
# how to clone the repo and use its Makefile to install? -- don't know
function _dj_setup_container_dive() {
    _pushd_quiet ${PWD}

    # ----------------------------------------------
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    dive_version="0.9.2"
    drive_url="https://github.com/wagoodman/dive/releases/download/v"
    _show_and_run wget $drive_url$dive_version"/dive_"$dive_version"_linux_amd64.deb"
    _show_and_run sudo dpkg -i dive_*.deb

    echo "use the following command to check the docker image layouts"
    echo "    \$ sudo dive <image-tag/hash>"
    echo "you can find the image-tag/hash from command: sudo docker images -a"

    _popd_quiet
}

# =============================================================================
function _dj_setup_container_lxd() {
    _show_and_run _install_if_not_installed snapd

    local v=$(_find_package_version lxd)
    _show_and_run sudo snap remove lxd
    _show_and_run sudo snap install lxd --channel=$v/stable
    echo "check version: sudo lxd --version"
    echo 'next step: $ sudo lxd init'
}

# =============================================================================
function _dj_setup_pangolin() {
    _show_and_run _pushd_quiet ${PWD}

    # dependency installation
    packages="libglew-dev mesa-utils libglm-dev libxkbcommon-x11-dev "
    _show_and_run _install_if_not_installed $packages
    _show_and_run dj setup glfw3
    local v=$(_find_package_version pangolin)

    # use command 'glxinfo | grep "OpenGL version" ' to see opengl version in Ubuntu

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run sudo rm -rf Pangolin/ # somehow it generate build/CMakeFiles/Progress/ as root
    _show_and_run git clone --recursive https://github.com/stevenlovegrove/Pangolin.git
    _show_and_run cd Pangolin
    _show_and_run git checkout v$v
    _show_and_run ./scripts/install_prerequisites.sh
    _show_and_run rm -rf build/
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install
    _show_and_run sudo cp libpango_* /usr/local/lib

    _verify_lib_installation libpango_core.so /usr/local/lib
    _verify_lib_installation libpango_geometry.so /usr/local/lib
    _verify_header_files pangolin.h /usr/local/include/pangolin

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
function _dj_setup_protobuf() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run sudo rm -rf /usr/local/lib/libproto*

    # install bazel by $ dj2 setup bazel (now it is v6.4.0)
    if [ ! -d protobuf ]; then
        _show_and_run git clone https://github.com/google/protobuf
        _show_and_run cd protobuf
    else
        _show_and_run cd protobuf
        _show_and_run git checkout main
        _show_and_run git fetch -p
        _show_and_run git pull
    fi
    _show_and_run git submoudle update --init --recursive
    v=$(_find_package_version protobuf)
    _show_and_run git checkout v$v

    _show_and_run bazel build :protoc :protobuf
    _show_and_run sudo cp bazel-bin/protoc /usr/local/bin

    # seems not needed?
    # _verify_lib_installation libprotobuf.a /usr/local/lib
    # _verify_lib_installation libprotobuf.la /usr/local/lib
    # _verify_lib_installation libprotobuf.so /usr/local/lib
    # _verify_lib_installation libprotobuf-lite.a /usr/local/lib
    # _verify_lib_installation libprotobuf-lite.la /usr/local/lib
    # _verify_lib_installation libprotobuf-lite.so /usr/local/lib
    # _verify_lib_installation libprotoc.a /usr/local/lib
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
function _dj_setup_python_3_9() {
    if [[ ! -f /etc/apt/sources.list.d/deadsnake*.list ]]; then
        _show_and_run sudo add-apt-repository ppa:deadsnakes/ppa
        _show_and_run sudo apt-get -y update
    fi
    _show_and_run _install_if_not_installed python3.9
    _show_and_run _install_if_not_installed python3.8

    # ----------------------
    echo -e "run update-alternatives:"
    for i in 3 4 6 7 8 9; do
        if [ -f /usr/bin/python3.$i ]; then
            _show_and_run sudo update-alternatives --install \
                /usr/bin/python3 python3 /usr/bin/python3.$i $i
        fi
    done

    # ----------------------
    _show_and_run sudo update-alternatives --config python3

    # install some related software package
    _show_and_run _install_if_not_installed python3.9-distutils

    # others ------------
    _show_and_run _install_if_not_installed python3-pip
    _show_and_run pip3 install --upgrade setuptools
}

# =============================================================================
function _dj_setup_python_3_10() {
    if [[ ! -f /etc/apt/sources.list.d/deadsnake*.list ]]; then
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

    echo -e "install ${GRN}st-link v2${NOC} and ${GRN}stm32flash${NOC} tools"
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

    # glfw3
    packages="build-essential cmake git xorg-dev libglu1-mesa-dev "
    _show_and_run _install_if_not_installed $packages
    _show_and_run rm -rf glfw3/
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
function _dj_setup_gtest() {
    _show_and_run _pushd_quiet ${PWD}

    v=$(_find_package_version googletest)
    _echo_install googletest $v
    _press_enter_or_wait_s_continue 5

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf googletest
    _show_and_run git clone https://github.com/google/googletest.git
    _show_and_run cd googletest
    _show_and_run git checkout release-$v
    _show_and_run rm -rf build
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo -e "\n${GRN}googletest $v${NOC} is installed:"
    _verify_lib_installation libgtest.a /usr/local/lib
    _verify_lib_installation libgtest_main.a /usr/local/lib
    _verify_header_files gtest.h /usr/local/include/gtest
    _verify_pkgconfig_file gtest.pc /usr/local/lib/pkgconfig
    _verify_pkgconfig_file gtest_main.pc /usr/local/lib/pkgconfig

    _popd_quiet
}

# =============================================================================
function _dj_setup_glog() {
    _show_and_run _pushd_quiet ${PWD}

    echo -e "install glog ..."

    v=$(_find_package_version glog)
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf glog
    _show_and_run git clone https://github.com/google/glog.git
    _show_and_run cd glog
    _show_and_run git checkout $v
    _show_and_run rm -rf build
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo -e "\n${GRN}glog $v${NOC} is installed:"
    _verify_lib_installation libglog.a /usr/local/lib
    _verify_lib_installation libglog.so /usr/local/lib
    _verify_header_files logging.h /usr/local/include/glog

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
    _show_and_run _pushd_quiet ${PWD}

    grpc_v=$(_find_package_version grpc)
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf grpc
    _show_and_run git clone https://github.com/grpc/grpc.git --recurse-submodules \
        --shallow-submodules --depth 1 --branch v${grpc_v}
    _show_and_run cd grpc
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake .. -GNinja
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
    echo -e "install ${GRN}gcc-10${NOC}, ${GRN}g++-10${NOC}"
    _press_enter_or_wait_s_continue 5

    if ! compgen -G "/etc/apt/sources.list.d/ubuntu-toolchain-r*.list" >/dev/null; then
        _show_and_run sudo add-apt-repository ppa:ubuntu-toolchain-r/test
        _show_and_run sudo apt-get -y update
    fi

    _show_and_run sudo apt-get install -y gcc-10
    _show_and_run sudo apt-get install -y g++-10

    # install g++9/gcc-9
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${GRN}gcc-9${NOC}, ${GRN}g++-9${NOC} "
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
    echo -e "install ${GRN}gcc-11${NOC}, ${GRN}g++-11${NOC}"
    _press_enter_or_wait_s_continue 5

    if ! compgen -G "/etc/apt/sources.list.d/ubuntu-toolchain-r*.list" >/dev/null; then
        _show_and_run sudo add-apt-repository ppa:ubuntu-toolchain-r/test
        _show_and_run sudo apt-get -y update
    fi

    _show_and_run sudo apt-get install -y gcc-11
    _show_and_run sudo apt-get install -y g++-11

    # install g++10/gcc-10
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${GRN}gcc-10${NOC}, ${GRN}g++-10${NOC} "
        _press_enter_or_wait_s_continue 5
        _show_and_run _install_if_not_installed gcc-10 g++-10
    fi

    # install g++9/gcc-9
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${GRN}gcc-9${NOC}, ${GRN}g++-9${NOC} "
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
    echo -e "install ${GRN}rust${NOC}"
    _show_and_run curl https://sh.rustup.rs -sSf | sh
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>$rc_file
    echo -e "You need to run ${GRN}\"source $rc_file\"${NOC} manually."
    echo -e "update rust by ${GRN}rustup update${NOC}"
    echo -e "check rust version by ${GRN}rustc --version${NOC}"
    echo -e "check cargo version by ${GRN}cargo --version${NOC}"
    echo -e "uninstall rust by ${GRN}rustup self uninstall${NOC}"
    echo -e "compile a rust program by (example) ${GRN}rustc main.rs${NOC}"
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
function _dj_setup_vtk_8_2_0() {
    echo "vtk 8.2.0 installation"

    _show_and_run _pushd_quiet ${PWD}

    # vtk 8 ----------------
    # reference: https://kezunlin.me/post/b901735e/
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run _install_if_not_installed cmake-qt-gui

    _show_and_run git clone https://gitee.com/dj-zhou/vtk-8.2.0.git

    _show_and_run cd vtk-8.2.0
    _show_and_run sudo rm -rf build/
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local -DVTK_RENDERING_BACKEND=OpenGL2 \
        -DQT5_DIR=$HOME/Qt5.14.2/5.14.2/gcc_64/lib/cmake/Qt5 \
        -DVTK_QT_VERSION=5 -DVTK_Group_Qt=ON ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo "the installed library seems to be in /usr/local/lib folder"
    echo "the installed header files seem to be in /usr/local/include/vtk-8.2/ folder"

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
    echo -e "run: ${GRN}ldconfig -p | grep $lib_to_find${NOC}:"

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
    if [ "$1" = "-in-bash" ]; then
        echo -e "grep in ${GRN}*.bash, *.sh${NOC} files"
        # how to search in the files without extension??
        _show_and_run grep "$2" -rIn \
            --include={*.bash,*.sh} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-ccode" ]; then
        echo -e "grep in ${GRN}*.c,*.cpp,*.h,*.hpp,Makefile*,CMakeLists.txt${NOC} files"
        _show_and_run grep "$2" -rIn \
            --include={*.c,*.cpp,*.h,*.hpp,Makefile*,CMakeLists.txt} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-config" ]; then
        echo -e "grep in ${GRN}*.json,Dockerfile,*.xml${NOC} files"
        _show_and_run grep "$2" -rIn \
            --include={*.json,Dockerfile,*.xml} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-meson" ]; then
        echo -e "grep in ${GRN}meson.build${NOC} files"
        _dj_grep_string_in_meson "$2"
        return
    fi
    if [ "$1" = "-in-python" ]; then
        echo -e "grep in ${GRN}*.py,*.ipynb${NOC} files"
        _show_and_run grep "$2" -rIn \
            --include={*.py,*.ipynb} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-rust" ]; then # seems not working for *.rs files
        echo -e "grep in ${GRN}*.rs,Cargo.toml,Cargo.lock${NOC} files"
        # not a bug, a single "*.rs" does not work here, don't know why
        _show_and_run grep "$2" -rIn \
            --include={*.rs,*.rs,Cargo.toml,Cargo.lock} \
            --exclude-dir={.venv,build,subprojects,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-yaml" ]; then
        echo -e "grep in ${GRN}*.yml,*.yaml${NOC} files"
        _show_and_run grep "$2" -rIn \
            --include={*.yml,*.yaml} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-yocto-recipe" ]; then
        echo -e "grep in ${GRN}*.bb,*.conf,*.inc,*.sample,*.bbappend${NOC} files"
        _show_and_run grep "$2" -rIn \
            --include={*.bb,*.conf,*.inc,*.sample,*.bbappend} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
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
            echo -e "\n${GRN} ---------------------------------------"
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

    # if ~/.ssh/id_rsa-general.pub does not exist, create one
    key_file="${HOME}/.ssh/id_rsa-general"
    if [ ! -f "$key_file" ]; then
        _show_and_run printf "${key_file}\n\n" | _show_and_run ssh-keygen
    fi

    # just to create .ssh on target machine
    _show_and_run ssh -l $user $ip "mkdir -p ~/.ssh"

    # then run, copy the content of local id_rsa.pub to .ssh/autorized_keys in remote
    _show_and_run cat "${key_file}.pub" | _show_and_run ssh $user_and_ip "cat >> .ssh/authorized_keys"
}

# =============================================================================
# reference: https://gist.github.com/jexchan/2351996
# I don't know why ~/.ssh/config is not needed
# make sure the content in ~/.ssh/id_rsa-github-<account>.pub is pasted to the GitHub account
# install ssh-askpass to avoid some error, however, it will have an popup window to press
function _dj_git_ssh_account_activate() {

    _show_and_run _install_if_not_installed ssh-askpass

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
            echo -e "SSH key file ${GRN}${key_file}${NOC} not found, generate one automatically:"
            echo -e "${YLW}Press [OK] on the popup window${NOC}"
            _show_and_run printf "${key_file}\n\n\n\n" | ssh-keygen
            echo -e "copy the following content into a new GitHub SSH Key (https://github.com/settings/keys, need login):"
            echo -e "${GRN}"
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
        echo -e "you need to run ${GRN}dj ssh-github activate <github username>${NOC} to activate one"
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
        echo -e "use command ${GRN}perf record -e cpu-clock -g <executable>${NOC}"
        echo -e "or ${GRN}perf record --call-graph dwarf <executable>${NOC}"
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
function dj() {
    # ------------------------------
    if [ $# -eq 0 ]; then
        _dj_help
        return
    fi
    # ------------------------------
    if [ $1 = 'flame-graph' ]; then
        shift 1
        _dj_flame_grapah "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'format' ]; then
        # ------------------------------
        if [[ $# -ge 2 ]]; then
            shift 1
            _dj_format "$@"
            return
        fi
        echo "dj format: argument not supported, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'grep' ]; then
        # ------------------------------
        if [ $2 = '-package' ]; then
            # ------------------------------
            if [[ $# -ge 3 ]]; then
                shift 2
                _dj_grep_package "$@"
                return
            fi
        fi
        # ------------------------------
        if [ $2 = '-string' ]; then
            # ------------------------------
            if [[ $# -ge 3 ]]; then
                shift 2
                _dj_grep_string "$@"
                return
            fi
        fi
        echo "dj grep: wrong argument, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'help' ]; then
        # ------------------------------
        if [ $# -ge 2 ]; then
            _dj_help_skill $2
            return
        fi
        echo 'dj help: argument not supported, exit.'
        return
    fi
    # ------------------------------
    if [ $1 = 'get' ]; then
        shift 1
        _dj_get "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'git' ]; then
        if [ $2 = 'config' ]; then
            shift 2
            _dj_git_config "$@"
            return
        fi
        if [ $2 = 'search' ]; then
            shift 2
            _dj_git_search "$@"
            return
        fi
        # ------------------------------
        if [ $2 = 'ssh-account' ]; then
            if [ $3 = '--activate' ]; then
                shift 3
                _dj_git_ssh_account_activate "$@"
                return
            fi
            if [ $3 = '--show-all' ]; then
                _dj_git_ssh_account_show_all
                return
            fi
            if [ $3 = '--show-current' ]; then
                _dj_git_ssh_account_show_current
                return
            fi
        fi
        # ------------------------------
        if [ $2 = 'ssh-clone' ]; then
            # --------------------------
            if [[ "$3" = 'bitbucket' ||
                "$3" = 'github' ]]; then
                shift 2
                _dj_git_ssh_clone_from "$@"
                return
            fi
            _dj_ssh_clone_help
            return
        fi
        echo 'dj git: argument not supported, exit.'
        return
    fi

    # ------------------------------
    if [ $1 = 'merge' ]; then
        # ------------------------------
        if [ $# -ge 2 ]; then
            shift 1
            _dj_merge "$@"
            return
        fi
        echo "dj merge: argument not supported, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'open' ]; then
        _dj_open_file $2 $3 $4
        return
    fi
    # ------------------------------
    if [ $1 = 'pack' ]; then
        shift 1
        _dj_pack "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'python3' ]; then
        shift 1
        _dj_python3 "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'replace' ]; then
        # ------------------------------
        if [[ $# -ge 2 ]]; then
            shift 1
            _dj_replace "$@"
            return
        fi
        echo "dj replace: argument not supported, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'setup' ]; then
        # ------------------------------
        if [ $# -ge 2 ]; then
            shift 1
            _dj_setup "$@"
            return
        fi
        echo "dj setup: argument not supported, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'split' ]; then
        # ------------------------------
        if [ $# -ge 2 ]; then
            shift 1
            _dj_split "$@"
            return
        fi
        echo "dj split: argument not supported, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'ssh-general' ]; then
        # ------------------------------
        if [ $2 = 'no-password' ]; then
            shift 2
            _dj_ssh_general_no_password "$@"
            return
        fi
        return
    fi

    # ------------------------------
    if [ $1 = 'systemd' ]; then
        shift 1
        _dj_systemd "$@"
        return
    fi

    # ------------------------------
    if [ $1 = 'udev' ]; then
        # ------------------------------
        if [ $# -ge 2 ]; then
            shift 1
            _dj_udev "$@"
            return
        fi
        _dj_udev_help
        return
    fi
    # ------------------------------
    if [ $1 = 'udevadm' ]; then
        if [ $# -ge 2 ]; then
            shift 1
            _dj_udevadm "$@"
            return
        fi
        _dj_udevadm_help $2 $3
        return
    fi
    # ------------------------------
    if [ $1 = 'unpack' ]; then
        shift 1
        _dj_unpack "$@"
        return
    fi
    # ------------------------------
    if [ $1 = 'work-check' ]; then
        shift 1
        _dj_work_check "$@"
        return
    fi
    _dj_help
    # ------------------------------
}

# =============================================================================
function _dj_linux() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
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
    ACTIONS[get]="$get_list "
    for i in $get_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS[setup]="$setup_list "
    for i in $setup_list; do
        ACTIONS[$i]=" "
    done
    # special ones -----------------
    ACTIONS[container]="dive docker docker-compose lxd "
    cli11_version="1.9.0 2.1.1 "
    ACTIONS[cli11]="$cli11_version"
    for i in $cli11_version; do
        ACTIONS[$i]=" "
    done
    ACTIONS[docker]=" "
    ACTIONS[dive]="  "
    ACTIONS["lxd-4.0"]=" "
    # ---------------------
    ACTIONS[driver]="wifi "
    wifi_list="rtl8812au "
    ACTIONS[wifi]="$wifi_list "
    for i in $wifi_list; do
        ACTIONS[$i]=" "
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
    ACTIONS[qemu]="2.11.1 4.2.0 "
    ACTIONS[2.11.1]=" "
    ACTIONS[4.2.0]=" "
    # ---------------------
    ACTIONS["ros-melodic"]="--from-deb-package --from-source "
    ACTIONS["ros-noetic"]=" "
    ACTIONS["ros2-foxy"]="--from-deb-package --from-source "
    ACTIONS["--from-deb-package"]=" "
    ACTIONS["--from-source"]=" "
    # ---------------------
    ACTIONS[spdlog]="static shared "
    ACTIONS[static]=" "
    ACTIONS[shared]=" "
    ACTIONS[0.6.2]=" "
    ACTIONS[0.6.3]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS[split]="$(ls)"
    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS[clone]="bitbucket github "

    # --------------------------------------------------------
    flame_list="generate clear help "
    ACTIONS["flame-graph"]="$flame_list "
    for i in $flame_list; do
        ACTIONS[$i]=" "
    done
    # --------------------------------------------------------
    format_list="brush show "
    ACTIONS[format]="$format_list "
    for i in $format_list; do
        ACTIONS[$i]=" "
    done
    ACTIONS[format]+="implement "
    brush_list="google file "
    ACTIONS[brush]="$brush_list"
    for i in $brush_list; do
        ACTIONS[$i]=" "
    done
    implement_list="djz bg "
    ACTIONS[implement]="$implement_list"
    for i in $implement_list; do
        ACTIONS[$i]=" "
    done
    # -----------------
    show_list="camel "
    ACTIONS[show]="$show_list "
    for i in $show_list; do
        ACTIONS[$i]=" "
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
    grep_list="-package -string "
    ACTIONS[grep]="$grep_list "
    for i in $grep_list; do
        ACTIONS[$i]=" "
    done
    string_list="-in-bash -in-config -in-meson -in-python -in-ccode "
    string_list+="-in-rust -in-yaml -in-yocto-recipe "
    ACTIONS["-string"]="$string_list "
    for i in $string_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    # git.bash
    ACTIONS[git]="$git_list "
    for i in $git_list; do
        ACTIONS[$i]=" "
    done
    ACTIONS[search]="$search_list "
    for i in $search_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    ACTIONS["ssh-account"]="$ssh_account_list "
    for i in $ssh_account_list; do
        ACTIONS[$i]=" "
    done
    ACTIONS["--activate"]="$all_accounts"
    for i in $all_accounts; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    ACTIONS["ssh-clone"]="bitbucket github "
    # --------------------------------------------------------
    bitbucket_repos="$(_dj_clone_repo_list bitbucket) "
    ACTIONS[bitbucket]+="$bitbucket_repos "
    ACTIONS[bitbucket]+="--add "
    for i in $bitbucket_repos; do
        ACTIONS[$i]=" "
    done
    # --------------------------------------------------------
    github_repos="$(_dj_clone_repo_list github) "
    ACTIONS[github]+="$github_repos "
    ACTIONS[github]+="--add "
    for i in $github_repos; do
        ACTIONS[$i]=" "
    done
    ACTIONS[--add]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS[help]="$_help_list "
    for i in $_help_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    pack_list="-tar.gz "
    ACTIONS[pack]="$pack_list "
    for i in $pack_list; do
        ACTIONS[$i]=" "
    done
    # --------------------------------------------------------
    pack_tar_gz_list="$(ls .)"
    ACTIONS["-tar.gz"]="$pack_tar_gz_list "
    for i in $pack_tar_gz_list; do
        ACTIONS[$i]=" "
    done
    # --------------------------------------------------------
    # --------------------------------------------------------
    unpack_list="tar.xz tar.gz "
    ACTIONS[unpack]="$unpack_list "
    # --------------------------------------------------------
    unpack_tar_xz_list="$(ls . | grep tar.xz)"
    ACTIONS[tar.xz]+="$unpack_tar_xz_list "
    for i in $unpack_tar_xz_list; do
        ACTIONS[$i]=" "
    done
    # --------------------------------------------------------
    unpack_tar_gz_list="$(ls . | grep tar.gz)"
    ACTIONS[tar.gz]+="$unpack_tar_gz_list "
    for i in $unpack_tar_gz_list; do
        ACTIONS[$i]=" "
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
if [ $system = 'Linux' ]; then
    complete -F _dj_linux dj
# elif [ $system = 'Darwin' ]; then
#     echo "todo"
fi
