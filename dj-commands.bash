#!/bin/bash

source $djtools_path/clang-format.bash
source $djtools_path/clone.bash
source $djtools_path/help.bash
source $djtools_path/get.bash
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
    echo "   setup         - to install some software"
    echo "   clone         - clone a repo from github/bitbucket"
    echo "   ssh-clone     - use ssh protocol to clone a repo from github/bitbucket"
    echo "   udev          - udev rule setup for usb devices"
    echo "   work-check    - check work status of all repos in a folder"
    echo -e ""
    echo -e "  MORE IS COMMING"
    echo -e "All commands support tab completion"
}

# =============================================================================
function _dj_setup_boost() {
    cur_dir=${PWD}

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

    _install_if_not_installed python3-dev libxml2-dev
    cd ~ && mkdir -p soft/ && cd soft/
    sudo rm -rf boost
    git clone https://github.com/boostorg/boost.git

    cd boost
    git checkout boost-$v
    # clone the submodules! this takes long though
    git submodule update --init --recursive
    # install is simple
    ./bootstrap.sh --prefix=/usr/local
    sudo ./b2 install

    _verify_header_files /usr/include/ # this is not accurate
    _verify_lib_installation libboost_atomic.so /usr/local/lib/
    _verify_lib_installation libboost_timer.so /usr/local/lib/

    cd $cur_dir
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
    echo 'Exec=bash -c "cd '$HOME'/soft/can-analyzer/ && ./CANAnalysis"' >>$file
    echo 'Icon='$folder'/can-analyzer.xpm' >>$file
    echo 'StartupNotify=false' >>$file
    echo 'Type=Application' >>$file
    echo 'Categories=Application;Development;' >>$file

    sudo rm -rf $folder/$file
    sudo mv $file $folder

    sudo chmod +x $folder/$file

    echo -e "${YLW}if CAN Analyzer is not installed to ~/soft/can-analyzer/, you need to revise file:${NOC}"
    echo -e "${YLW}/usr/share/applications/$file accordingly.${NOC}"
}

# =============================================================================
# note
function _dj_setup_can_analyzer() {
    cur_dir=$PWD
    cd ~ && mkdir -p soft/ && cd soft/
    rm can-analyzer -rf
    git clone https://github.com/dj-zhou/can-analyzer.git
    chmod +x can-analyzer/CANAnalysis
    cd ${cur_dir}
    _create_can_analyzer_desktop_item
}

# =============================================================================
function _dj_setup_can_dev_tools() {
    sudo apt update &>/dev/null
    echo -e "going to install ${GRN}can-utils${NOC}"
    _install_if_not_installed can-utils
}

# =============================================================================
function _dj_setup_cli11() {
    cur_dir_cli11=${PWD}

    v=$(_find_package_version cli11)
    _echo_install CLI11 v$v
    _press_enter_or_wait_s_continue 5

    # remove some exisiting files to prevent error
    # v2.1.1 does not have CLI11.pc file installed, but >=v2.0.0 has!
    sudo rm -rf /usr/local/lib/pkgconfig/CLI11.pc
    sudo rm -rf /usr/local/lib/cmake/CLI11/CLI11Config.cmake
    sudo rm -rf /usr/local/lib/cmake/CLI11/CLI11ConfigVersion.cmake

    cd ~ && mkdir -p soft/ && cd soft/

    rm -rf CLI11/
    git clone https://github.com/CLIUtils/CLI11
    cd CLI11
    git checkout v$v
    # gtest is a submodule of it
    git submodule update --init
    mkdir build
    cd build
    cmake ..
    make -j$(nproc)
    sudo make install

    echo -e "\n${GRN}CLI11 $v${NOC} is installed."
    anw=$(_version_if_ge_than $v "1.9.1")
    if [ "$anw" = "no" ]; then
        _verify_header_files /usr/local/include/CLI/
        _verify_cmake_files CLI11Config.cmake /usr/local/lib/cmake/CLI11/
        _verify_cmake_files CLI11ConfigVersion.cmake /usr/local/lib/cmake/CLI11/
        _verify_pkgconfig_file CLI11.pc /usr/local/lib/pkgconfig
    else
        _verify_header_files /usr/local/include/CLI/
        _verify_cmake_files CLI11Config.cmake /usr/local/share/cmake/CLI11/
        _verify_cmake_files CLI11ConfigVersion.cmake /usr/local/share/cmake/CLI11/
        _verify_pkgconfig_file CLI11.pc /usr/local/share/pkgconfig
    fi

    cd $cur_dir_cli11
}

# =============================================================================
# setting a fixed version is not a good idea, but ...
function _dj_setup_cmake() {
    # install dependencies
    _install_if_not_installed libssl-dev
    v=$(_find_package_version cmake)
    _echo_install CMake $v

    _press_enter_or_wait_s_continue 5

    _show_and_run _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft/ && cd soft/
    _show_and_run rm -rf CMake
    _show_and_run git clone https://github.com/Kitware/CMake.git
    _show_and_run cd CMake
    _show_and_run git checkout $v

    _show_and_run ./bootstrap --prefix=/usr/local
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install
    echo -e "${GRN}cmake${NOC} is installed to ${GRN}/usr/local/bin${NOC}"

    _show_and_run _popd_quiet
}

# =============================================================================
function _dj_setup_kdiff3_meld() {
    _install_if_not_installed kdiff3
    _install_if_not_installed meld

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
    _install_if_not_installed ckermit lrzsz

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
    _show_and_run mv $kermrc_file ~/

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

    cd ~ && mkdir -p soft/ && cd soft/
    _show_and_run sudo rm -rf dj-gadgets
    _show_and_run git clone https://dj-zhou@github.com/dj-zhou/dj-gadgets.git
    _show_and_run cd dj-gadgets
    _show_and_run sudo rm -rf build
    _show_and_run mkdir build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    # check depenency
    v=$(version check cli11)
    if [ "$v" = "cli11 is not installed" ]; then
        _show_and_run dj setup cli11
    fi

    if [ ! -f /usr/local/lib/libmatplot.* ]; then
        _show_and_run dj setup matplot++
    fi

    if [ ! -f "/usr/local/include/magic_enum.hpp" ]; then
        _show_and_run dj setup magic-enum
    fi

    # dj-file installation
    _show_and_run cd ../dj-file/
    _show_and_run rm build -rf
    _show_and_run mkdir build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make
    _show_and_run sudo make install

    _show_and_run _popd_quiet
}

# =============================================================================
# todo: for each package, yes (default) to intall, no to skip
function _dj_setup_devtools() {
    _install_if_not_installed \
        libncurses5-dev \
        libnl-genl-3-dev
}

# =============================================================================
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
# this is only tested in Ubuntu 18.04
function _dj_setup_container_docker() {
    _pushd_quiet ${PWD}

    # Install a few prerequisite packages
    packages="apt-transport-https ca-certificates curl software-properties-common "
    _install_if_not_installed $packages

    docker_url="https://download.docker.com/linux/ubuntu"

    # Add the GPG key for the official Docker repository
    curl -fsSL $docker_url/gpg | sudo apt-key add -

    # Add the Docker repository to APT sources
    sudo add-apt-repository \
        "deb [arch=amd64] $docker_url $(lsb_release -cs) stable"
    sudo apt-get -y update

    # Install
    _install_if_not_installed docker-ce

    # check the status -- not sure if the "active status" need a system reboot
    sudo systemctl status docker

    # ----------------------------------------------
    # add current user to the docker group, which was created from above scripts
    # to avoid typing "sudo" whenever run the docker command
    # (to remove a user from a group: sudo gpasswd -d user group, need log in/out)
    sudo usermod -aG docker ${USER}
    su - ${USER}

    # to solve a problem: dial unix /var/run/docker.sock: connect: permission denied
    sudo chmod 666 /var/run/docker.sock
    echo -e "you need to reboot computer so docker does not need sudo to run"

    _popd_quiet
}

# =============================================================================
function _dj_setup_container_docker_compose() {

    url="https://github.com/docker/compose/releases/download"
    v="1.29.2"
    echo "installing docker-compose v$v (version hardcoded)"
    sudo curl -L "${url}/$v/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

# =============================================================================
# https://github.com/wagoodman/dive
# how to clone the repo and use its Makefile to install? -- don't know
function _dj_setup_container_dive() {
    _pushd_quiet ${PWD}

    # ----------------------------------------------
    cd ~ && mkdir -p soft/ && cd soft/
    dive_version="0.9.2"
    drive_url="https://github.com/wagoodman/dive/releases/download/v"
    wget $drive_url$dive_version"/dive_"$dive_version"_linux_amd64.deb"
    sudo dpkg -i dive_*.deb

    echo "use the following command to check the docker image layouts"
    echo "    \$ sudo dive <image-tag/hash>"
    echo "you can find the image-tag/hash from command: sudo docker images -a"

    _popd_quiet
}

# =============================================================================
function _dj_setup_container_lxd_4_0() {
    _install_if_not_installed snapd

    sudo snap install lxd --channel=4.0/stable
    echo 'next step: $ sudo lxd init'
}

# =============================================================================
function _dj_setup_pangolin() {
    _pushd_quiet ${PWD}

    # dependency installation
    packages="libglew-dev mesa-utils libglm-dev libxkbcommon-x11-dev "
    _install_if_not_installed $packages

    # use command 'glxinfo | grep "OpenGL version" ' to see opengl version in Ubuntu

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf Pangolin/
    git clone https://github.com/stevenlovegrove/Pangolin.git
    cd Pangolin
    git checkout v0.6 # released on Apr 22, 2021, need test
    rm -rf build/ && mkdir build && cd build
    cmake ..
    make -j$(nproc)
    sudo make install

    echo -e "libpangolin.so is in path: ${GRN}/usr/local/lib/${NOC}"
    echo -e "header files are in path: ${GRN}/usr/local/include/pangolin/${NOC}"

    echo -e "If you see error: ${RED}Could not find GLEW${NOC}"
    echo "you should run the following commands:"
    echo "   \$ dj setup glfw3"
    echo "   \$ dj setup gtest"
    echo "   \$ dj setup glog"

    _popd_quiet
}

# =============================================================================
function _dj_setup_cutecom() {
    _pushd_quiet "${PWD}"

    v=$(_find_package_version cutecom)
    _echo_install cutecom $v
    _press_enter_or_wait_s_continue 5

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf cutecom
    git clone https://gitlab.com/cutecom/cutecom.git
    cd cutecom
    git checkout $v
    cmake .
    make -j$(nproc)
    sudo make install

    _popd_quiet
}

# =============================================================================
function _dj_setup_picocom() {
    _pushd_quiet "${PWD}"

    cd ~ && mkdir -p soft/ && cd soft/

    v=$(_find_package_version picocom)
    _echo_install picocom $v
    _press_enter_or_wait_s_continue 5

    rm -rf picocom
    git clone git@github.com:npat-efault/picocom.git
    cd picocom
    git checkout $V
    make
    sudo cp picocom /usr/bin/

    _popd_quiet
}

# =============================================================================
function _dj_setup_pip() {
    _pushd_quiet ${PWD}

    cd ~/
    _install_if_not_installed python3-pip
    _install_if_not_installed python-pip

    sudo pip install --upgrade pip
    sudo pip3 install --upgrade pip

    echo -e "check the pip/pip3 version by:"
    echo "   \$ pip --version"
    echo "   \$ pip3 --version"

    _popd_quiet
}

# =============================================================================
function _dj_setup_perf() {
    _install_if_not_installed linux-tools-common linux-tools-generic linux-tools-$(uname -r)
    _install_if_not_installed linux-tools-common linux-tools-generic

    echo "check perf version: \$ perf --version"
}

# =============================================================================
function _dj_setup_plotjuggler() {
    _pushd_quiet ${PWD}
    cd ~ && mkdir -p soft && cd soft

    _install_if_not_installed qtbase5-dev libqt5svg5-dev \
        libqt5websockets5-dev libqt5opengl5-dev libqt5x11extras5-dev

    v=$(_find_package_version plotjuggler)

    rm -rf PlotJuggler
    git clone https://github.com/facontidavide/PlotJuggler.git
    cd PlotJuggler
    git checkout $v
    mkdir build && cd build
    cmake ..
    make -j$(nproc)
    sudo make install

    _popd_quiet
}

# =============================================================================
function _dj_setup_pycharm() {
    _install_if_not_installed snap

    # cd ~ && mkdir -p soft && cd soft/
    # file=pycharm-community-2020.3.3.tar.gz
    # url=https://download-cf.jetbrains.com/python/$file
    # _wget_if_not_exist $file "12e20683a01fb7182a029fe1ceeeed95" $url

    sudo snap install pycharm-community --classic
}

# =============================================================================
function _dj_setup_python_3_9() {
    if [[ ! -f /etc/apt/sources.list.d/deadsnake*.list ]]; then
        sudo add-apt-repository ppa:deadsnakes/ppa
        sudo apt-get -y update
    fi
    _install_if_not_installed python3.9 python3.8

    # ----------------------
    echo -e "run update-alternatives:"
    for i in 3 4 6 7 8 9; do
        if [ -f /usr/bin/python3.$i ]; then
            sudo update-alternatives --install \
                /usr/bin/python3 python3 /usr/bin/python3.$i $i
        fi
    done

    # ----------------------
    sudo update-alternatives --config python3

    # install some related software package
    _install_if_not_installed python3.9-distutils

    # others ------------
    _install_if_not_installed python3-pip
    pip3 install --upgrade setuptools
}

# =============================================================================
function _dj_setup_qemu() {
    _pushd_quiet ${PWD}

    version=$1
    echo $version
    if [ $version = "2.11.1" ]; then
        # this may only work within Ubuntu 18.04, not tested on other platforms
        _install_if_not_installed qemu
    elif [ $version = "4.2.0" ]; then
        cd ~ && mkdir -p soft && cd soft/
        git clone git://git.qemu-project.org/qemu.git
        cd qemu
        git checkout stable-4.2
        mkdir build && cd build
        # is this only for ARM? will fix it later if needed
        ../configure --target-list=arm-softmmu --audio-drv-list=
        make -j8 && sudo make install
        echo -e "$CYN the installed qemu is probably for ARM only, check it later$NOC"
    fi

    _popd_quiet
}

# =============================================================================================
function _create_stm32cubemx_desktop_item() {
    folder="/usr/share/applications"

    # copy the icon file
    sudo cp $djtools_path/settings/cubemx.xpm $folder

    file="cubeMX.desktop"
    touch $file

    echo '[Desktop Entry]' >>$file
    echo 'Encoding=UTF-8' >>$file
    echo 'Name=cube-MX' >>$file
    echo 'Comment=cube-MX' >>$file
    echo 'Exec='$HOME'/soft/STM32CubeMX/STM32CubeMX' >>$file
    echo 'Icon='$folder'/cubemx.xpm' >>$file
    echo 'StartupNotify=false' >>$file
    echo 'Type=Application' >>$file
    echo 'Categories=Application;Development;' >>$file

    sudo rm -rf $folder/$file
    sudo mv $file $folder

    sudo chmod +x $folder/$file

    echo -e "${YLW}if cubeMX is not installed to ~/soft/STM32CubeMX/, you need to revise file:${NOC}"
    echo -e "${YLW}/usr/share/applications/$file accordingly.${NOC}"
}

# =============================================================================
function _dj_setup_stm32_cubemx() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft && cd soft/

    git clone https://gitee.com/d-zhou/stm32-cube-mx-v6.0.1.git
    cd stm32-cube-mx-v6.0.1/
    cat archive.tar.* | tar -xzvf -
    # rm archive.tar.*
    chmod +x SetupSTM32CubeMX-6.0.1.linux
    ./SetupSTM32CubeMX-6.0.1.linux

    _create_stm32cubemx_desktop_item

    _popd_quiet
}

# =============================================================================
# I experienced lots of problems with the stlink-v2 software, so I hard coded
# the version in the scripts
# some test result must be list here
# stlink-v2 software from https://github.com/stlink-org/stlink
# Ubuntu 18.04: v1.6.1 works (need to run st-flash twice to download the firmware)
# Ubuntu 20.04: v1.7.0 works (fixed the bug in v1.6.1)
#
# stlink tests on Ubuntu 18.04
# v1.6.0 failed
function _dj_setup_stm32_tools() {
    _pushd_quiet ${PWD}

    echo -e "install ${GRN}st-link v2${NOC} and ${GRN}stm32flash${NOC} tools"
    _press_enter_or_wait_s_continue 5

    # install dependencies and some software ----------------
    packages="libusb-1.0.0-dev gtk+-3.0 cu putty screen cmake "
    _install_if_not_installed $packages

    # install cutecom from source ----------------
    _dj_setup_cutecom

    # install stlink ----------------
    echo -e "install ${GRN}stlink${NOC}"
    _press_enter_or_wait_s_continue 5

    mkdir -p ~/soft && cd ~/soft
    rm stlink -rf
    git clone https://github.com/stlink-org/stlink

    cd stlink
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        git checkout v1.7.0 # need test v1.7.0 before switch to it
    elif [[ ${ubuntu_v} = *'20.04'* ]]; then
        git checkout v1.7.0
    else
        echo "${RED} NOT IMPLEMENTED YET${NOC}"
    fi
    echo "sudo rm -rf /usr/local/bin/st-*"
    sudo rm -rf /usr/local/bin/st-*
    make release -j$(nproc)
    cd build/Release/
    sudo make install
    sudo ldconfig

    # install stm32flash ----------------
    echo -e "install  stm32flash ..."
    _press_enter_or_wait_s_continue 10
    cd ~/soft/
    rm stm32-tools -rf
    git clone https://github.com/dj-zhou/stm32-tools.git
    cd stm32-tools/stm32flash
    make clean
    make -j$(nproc)
    sudo rm -rf /usr/local/bin/stm32flash
    sudo make install

    # udev rule ----------------
    echo -e "add serial port privilege to current user ..."
    _press_enter_or_wait_s_continue 10
    sudo usermod -a -G dialout $(whoami)
    rule_file=stm32-tools.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyUSB[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyACM[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    sudo service udev restart

    _popd_quiet
}

# =============================================================================
function _dj_setup_glfw3() {
    _pushd_quiet ${PWD}

    echo -e "install glfw3 ..."

    cd ~ && mkdir -p soft && cd soft/

    # glfw3
    packages="build-essential cmake git xorg-dev libglu1-mesa-dev "
    _install_if_not_installed $packages
    rm -rf glfw3/
    git clone https://github.com/dj-zhou/glfw3.git
    cd glfw3/
    mkdir build && cd build/
    cmake .. -DBUILD_SHARED_LIBS=ON
    make -j$(nproc)
    sudo make install && sudo ldconfig

    _popd_quiet
}

# =============================================================================
function _dj_setup_gnuplot() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft && cd soft/
    rm -rf gnuplot
    git clone https://github.com/gnuplot/gnuplot.git
    cd gnuplot
    ./prepare
    ./configure
    make -j$(nproc)
    sudo make install && sudo ldconfig

    _popd_quiet
}

# =============================================================================
function _dj_setup_google_repo() {
    _pushd_quiet ${PWD}

    # it needs python2
    _install_if_not_installed python

    if [ -f $djtools_path/tools/repo ]; then
        echo -e "use repo from tools/"
        sudo cp $djtools_path/tools/repo /bin/
        sudo chmod a+x /bin/repo
    else
        echo -e "fetch from google "
        curl https://storage.googleapis.com/git-repo-downloads/repo >repo
        chmod a+x repo
        sudo mv repo /bin/
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
    _pushd_quiet ${PWD}

    v=$(_find_package_version googletest)
    _echo_install googletest $v
    _press_enter_or_wait_s_continue 5

    cd ~ && mkdir -p soft && cd soft/
    rm -rf googletest
    git clone https://github.com/google/googletest.git
    cd googletest
    git checkout release-$v
    rm build -rf && mkdir build && cd build
    cmake ..
    make -j$(nproc) && sudo make install

    echo -e "\n${GRN}googletest $v${NOC} is installed."
    _verify_lib_installation libgtest.a /usr/local/lib/
    _verify_lib_installation libgtest_main.a /usr/local/lib/
    _verify_header_files /usr/local/include/gtest/
    _verify_pkgconfig_file gtest.pc /usr/local/lib/pkgconfig/
    _verify_pkgconfig_file gtest_main.pc /usr/local/lib/pkgconfig/

    _popd_quiet
}

# =============================================================================
function _dj_setup_glog() {
    _pushd_quiet ${PWD}

    echo -e "install glog ..."

    v=$(_find_package_version glog)
    cd ~ && mkdir -p soft && cd soft/
    rm -rf glog
    git clone https://github.com/google/glog.git
    cd glog
    git checkout $v
    rm build -rf && mkdir build && cd build
    cmake ..
    make -j$(nproc) && sudo make install

    _verify_lib_installation libglog.a /usr/local/lib
    _verify_lib_installation libglog.so /usr/local/lib
    _verify_header_files /usr/local/include/glog/

    _popd_quiet
}

# =============================================================================
# instlal gnome, need more test
function _dj_setup_gnome() {
    echo -e "install gnome on Ubuntu"
    _press_enter_or_wait_s_continue 20

    _install_if_not_installed tasksel
    _install_if_not_installed gnome-session
    _install_if_not_installed ubuntu-desktop

    echo -e "when log in, choose GNOME"
}

# =============================================================================
# ninja is used to compile
function _dj_setup_grpc() {
    _pushd_quiet ${PWD}

    grpc_v=$(_find_package_version grpc)
    cd ~ && mkdir -p soft && cd soft/
    rm grpc -rf
    git clone https://github.com/grpc/grpc.git --recurse-submodules \
        --shallow-submodules --depth 1 --branch v${grpc_v}
    cd grpc
    mkdir build && cd build
    cmake .. -GNinja
    cmake --build .
    sudo cmake --build . -- install

    _popd_quiet
}

# =============================================================================
# default compiles:
# Ubuntu 18.04: g++-7
# Ubuntu 20.04: g++-9
# make this function to install g++-9 on Ubuntu 18.04 as well!
function _dj_setup_gpp_10() {
    # install g++10/gcc-10
    echo -e "install ${GRN}gcc-10${NOC}, ${GRN}g++-10${NOC}"
    _press_enter_or_wait_s_continue 10

    if ! compgen -G "/etc/apt/sources.list.d/ubuntu-toolchain-r*.list" >/dev/null; then
        sudo add-apt-repository ppa:ubuntu-toolchain-r/test
        sudo apt-get -y update
    fi

    sudo apt-get install -y gcc-10
    sudo apt-get install -y g++-10

    # install g++9/gcc-9
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${GRN}gcc-9${NOC}, ${GRN}g++-9${NOC} "
        _press_enter_or_wait_s_continue 5
        _install_if_not_installed gcc-9
        _install_if_not_installed g++-9
    fi

    # ----------------------
    echo -e "run update-alternatives:"
    for i in 4 5 6 7 8 9 10; do
        if [ -f /usr/bin/gcc-$i ]; then
            sudo update-alternatives --install \
                /usr/bin/gcc gcc /usr/bin/gcc-$i $i
        fi
        if [ -f /usr/bin/g++-$i ]; then
            sudo update-alternatives --install \
                /usr/bin/g++ g++ /usr/bin/g++-$i $i
        fi
    done
    echo -e "\n-------------------"
    sudo update-alternatives --config gcc
    echo -e "\n-------------------"
    sudo update-alternatives --config g++
}

# =============================================================================
function _dj_setup_gpp_11() {
    # install g++10/gcc-10
    echo -e "install ${GRN}gcc-11${NOC}, ${GRN}g++-11${NOC}"
    _press_enter_or_wait_s_continue 5

    if ! compgen -G "/etc/apt/sources.list.d/ubuntu-toolchain-r*.list" >/dev/null; then
        sudo add-apt-repository ppa:ubuntu-toolchain-r/test
        sudo apt-get -y update
    fi

    sudo apt-get install -y gcc-11
    sudo apt-get install -y g++-11

    # install g++10/gcc-10
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${GRN}gcc-10${NOC}, ${GRN}g++-10${NOC} "
        _press_enter_or_wait_s_continue 5
        _install_if_not_installed gcc-10
        _install_if_not_installed g++-10
    fi

    # install g++9/gcc-9
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${GRN}gcc-9${NOC}, ${GRN}g++-9${NOC} "
        _press_enter_or_wait_s_continue 5
        _install_if_not_installed gcc-9
        _install_if_not_installed g++-9
    fi

    # ----------------------
    echo -e "run update-alternatives:"
    for i in 4 5 6 7 8 9 10 11; do
        if [ -f /usr/bin/gcc-$i ]; then
            sudo update-alternatives --install \
                /usr/bin/gcc gcc /usr/bin/gcc-$i $i
        fi
        if [ -f /usr/bin/g++-$i ]; then
            sudo update-alternatives --install \
                /usr/bin/g++ g++ /usr/bin/g++-$i $i
        fi
    done
    echo -e "\n-------------------"
    sudo update-alternatives --config gcc
    echo -e "\n-------------------"
    sudo update-alternatives --config g++
}

# =============================================================================
function _dj_setup_rust() {
    echo -e "install ${GRN}rust${NOC}"
    curl https://sh.rustup.rs -sSf | sh
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >>~/.bashrc
    echo -e "You need to run ${GRN}\"source ~/.bashrc\"${NOC} manually."
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

    _install_if_not_installed ibus
    _install_if_not_installed ibus-table-wubi
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

    _pushd_quiet ${PWD}

    # vtk 8 ----------------
    # reference: https://kezunlin.me/post/b901735e/
    cd ~ && mkdir -p soft && cd soft/

    _install_if_not_installed cmake-qt-gui

    git clone https://gitee.com/dj-zhou/vtk-8.2.0.git

    cd vtk-8.2.0 && sudo rm -rf build/ && mkdir -p build && cd build
    cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local -DVTK_RENDERING_BACKEND=OpenGL2 \
        -DQT5_DIR=$HOME/Qt5.14.2/5.14.2/gcc_64/lib/cmake/Qt5 \
        -DVTK_QT_VERSION=5 -DVTK_Group_Qt=ON ..
    make -j$(nproc) && sudo make install

    echo "the installed library seems to be in /usr/local/lib folder"
    echo "the installed header files seem to be in /usr/local/include/vtk-8.2/ folder"

    _popd_quiet
}

# =============================================================================
# call function in workspace-check.bash
function _dj_work_check() {
    _work_check $@
}

# =============================================================================
# to search a library use: ldconfig -p | grep xxxx
# once this command get extended, we add sub command to "dj search"
function _dj_grep_package() {
    _pushd_quiet ${PWD}

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
        grep "$2" -rIn \
            --include={*.bash,*.sh} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-ccode" ]; then
        echo -e "grep in ${GRN}*.c,*.cpp,*.h,*.hpp,Makefile*,CMakeLists.txt${NOC} files"
        grep "$2" -rIn \
            --include={*.c,*.cpp,*.h,*.hpp,Makefile*,CMakeLists.txt} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-config" ]; then
        echo -e "grep in ${GRN}*.json,Dockerfile,*.xml${NOC} files"
        grep "$2" -rIn \
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
        grep "$2" -rIn \
            --include={*.py,*.ipynb} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-rust" ]; then # seems not working for *.rs files
        echo -e "grep in ${GRN}*.rs,Cargo.toml,Cargo.lock${NOC} files"
        # not a bug, a single "*.rs" does not work here, don't know why
        grep "$2" -rIn \
            --include={*.rs,*.rs,Cargo.toml,Cargo.lock} \
            --exclude-dir={.venv,build,subprojects,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-yaml" ]; then
        echo -e "grep in ${GRN}*.yml,*.yaml${NOC} files"
        grep "$2" -rIn \
            --include={*.yml,*.yaml} \
            --exclude-dir={.venv,build,subprojects,bin,_b*,builddir,.git,.cache} \
            --exclude='*.lst' \
            .
        return
    fi
    if [ "$1" = "-in-yocto-recipe" ]; then
        echo -e "grep in ${GRN}*.bb,*.conf,*.inc,*.sample,*.bbappend${NOC} files"
        grep "$2" -rIn \
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
        echo -e "    dj ssh-general no-password username@ip_address"
        return
    fi
    user_and_ip="$1"
    user=${user_and_ip%"@"*}
    pos=$(_find_a_char_in_str $user_and_ip "@" 1)
    ip=${user_and_ip:${pos}+1:${#user_and_ip}-${pos}}

    # if ~/.ssh/id_rsa-general.pub does not exist, create one
    key_file=id_rsa-general
    if [ ! -f "$key_file" ]; then
        printf "${HOME}/.ssh/${key_file}\n\n" | ssh-keygen
    fi

    # just to create .ssh on target machine
    echo "ssh -l $user $ip \"mkdir -p ~/.ssh\""
    ssh -l $user $ip "mkdir -p ~/.ssh"

    # then run, copy the content of local id_rsa.pub to .ssh/autorized_keys in remote
    echo "cat ${HOME}/.ssh/${key_file}.pub | ssh $user_and_ip \"cat >> .ssh/authorized_keys\""
    cat ${HOME}/.ssh/${key_file}.pub | ssh $user_and_ip "cat >> .ssh/authorized_keys"
}

# =============================================================================
# reference: https://gist.github.com/jexchan/2351996
# I don't know why ~/.ssh/config is not needed
# make sure the content in ~/.ssh/id_rsa-github-<account>.pub is pasted to the GitHub account
# install ssh-askpass to avoid some error, however, it will have an popup window to press
function _dj_git_ssh_account_activate() {

    _install_if_not_installed ssh-askpass

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
        echo -e "you need to run ${PRP} dj ssh-github activate <github username>${NOC} to activate one"
        return
    fi
    cat ~/.ssh/.github-activated-account
}

# =============================================================================
function _dj_setup_vim_env() {
    echo -e "setup the vim as an IDE"
    _press_enter_or_wait_s_continue 20

    _pushd_quiet ${PWD}

    VIMRC=~/.vimrc

    # install software, if not installed already
    packages="vim ctags cscope build-essential cmake python-dev python3-dev "
    _install_if_not_installed $packages

    # install Vundle -- plugin manager
    rm -rf ~/.vim/bundle/Vundle.vim
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

    # configure Vundle in ${VIMRC}
    # also configure tagbar, nerdtree, ALE
    rm -rf ${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" Vundle manage' >>${VIMRC}
    echo 'set nocompatible      " be iMproved, required' >>${VIMRC}
    echo -e 'filetype off          " required\n' >>${VIMRC}
    echo '" set the runtime path to include Vundle and initialize' >>${VIMRC}
    echo 'set rtp+=~/.vim/bundle/Vundle.vim' >>${VIMRC}
    echo -e 'call vundle#begin()\n' >>${VIMRC}
    echo '" let Vundle manage Vundle, required' >>${VIMRC}
    printf "Plugin 'VundleVim/Vundle.vim'" >>${VIMRC}
    printf "Plugin 'majutsushi/tagbar'" >>${VIMRC}
    printf "Plugin 'scrooloose/nerdtree'" >>${VIMRC}
    printf "Plugin 'w0rp/ale'" >>${VIMRC}
    printf "Plugin 'Valloric/YouCompleteMe'" >>${VIMRC}
    printf "Plugin 'ludovicchabant/vim-gutentags'\n" >>${VIMRC}
    echo '" All of your Plugins must be added before the following line' >>${VIMRC}
    echo 'call vundle#end()         " required' >>${VIMRC}
    echo -e 'filetype plugin indent on " required\n\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" cscope setup' >>${VIMRC}
    echo '"-------------------------------------------' >>${VIMRC}
    echo '" cscope to create database: cscope -Rbq' >>${VIMRC}
    echo '" F5: to look for C symbol                              (s)' >>${VIMRC}
    echo '" F6: to look for a string                              (t)' >>${VIMRC}
    echo '" F7: to look for function definition                   (g)' >>${VIMRC}
    echo '" F8: to look for which function calls current function (c)' >>${VIMRC}
    echo '"-------------------------------------------' >>${VIMRC}
    echo 'if has("cscope")' >>${VIMRC}
    echo '  set csprg=/usr/bin/cscope' >>${VIMRC}
    echo '  set csto=1' >>${VIMRC}
    echo '  set cst' >>${VIMRC}
    echo '  set nocsverb' >>${VIMRC}
    echo '  " add any database in current directory' >>${VIMRC}
    echo '  if filereadable("cscope.out")' >>${VIMRC}
    echo '    cs add cscope.out' >>${VIMRC}
    echo '  endif' >>${VIMRC}
    echo '  set csverb' >>${VIMRC}
    echo -e 'endif\n' >>${VIMRC}

    echo ':set cscopequickfix=s-,c-,d-,i-,t-,e-' >>${VIMRC}
    echo '"nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>' >>${VIMRC}
    echo 'nmap <silent> <F5> :cs find s <C-R>=expand("<cword>")<CR><CR>' >>${VIMRC}
    echo 'nmap <silent> <F6> :cs find g <C-R>=expand("<cword>")<CR><CR>' >>${VIMRC}
    echo 'nmap <silent> <F7> :cs find t <C-R>=expand("<cword>")<CR><CR>' >>${VIMRC}
    echo 'nmap <silent> <F8> :cs find c <C-R>=expand("<cword>")<CR><CR>' >>${VIMRC}
    echo -e '\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" Tagbar setup' >>${VIMRC}
    echo 'let g:tagbar_width=25' >>${VIMRC}
    echo 'autocmd BufReadPost *.cpp,*.c,*.hpp,s*.h,*.cc,*.cxx call tagbar#autoopen()' >>${VIMRC}
    echo -e '\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" Nerdtree setup' >>${VIMRC}
    echo 'autocmd StdinReadPre * let s:std_in=1' >>${VIMRC}
    echo -e 'autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif' >>${VIMRC} # this line does not work?
    echo -e 'let NERDTreeWinSize=15' >>${VIMRC}
    echo -e 'let NERDTreeShowLineNumbers=1' >>${VIMRC}
    echo -e 'let NERDTreeAutoCenter=1' >>${VIMRC}
    echo -e 'let NERDTreeShowBookmarks=1' >>${VIMRC}
    echo -e '\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" ALE (Asynchronization Line Engine) setup' >>${VIMRC}
    printf "let g:ale_sign_column_always = 1" >>${VIMRC}
    printf "let g:ale_sign_error = '>>'" >>${VIMRC}
    printf "let g:ale_sign_warning = '--'" >>${VIMRC}
    printf "let g:ale_statusline_format = ['x %%d', 'z %%d', 'y OK']" >>${VIMRC}
    printf "let g:ale_echo_msg_format = '[%%linter%%] %%code: %%%%s'" >>${VIMRC}
    printf "let g:ale_lint_on_text_changed = 'normal'" >>${VIMRC}
    printf "let g:ale_lint_on_insert_leave = 1" >>${VIMRC}
    printf "let g:ale_c_gcc_options = '-Wall -O2 -std=c99'" >>${VIMRC}
    printf "let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++20'" >>${VIMRC}
    printf "let g:ale_c_cppcheck_options = ' '" >>${VIMRC}
    printf "let g:ale_cpp_cppcheck_options = ' '" >>${VIMRC}
    echo -e '\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" YouCompleteMe setup' >>${VIMRC}
    printf "let g:ycm_server_python_interpreter='/usr/bin/python3'" >>${VIMRC}
    printf "let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'" >>${VIMRC}
    echo -e '\n\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" vim-gutentags setup' >>${VIMRC}
    printf "let g:gutentags_project_root= ['.root', '.svn', '.git', '.hg',  '.project']" >>${VIMRC}
    printf "let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']" >>${VIMRC}
    printf "let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']" >>${VIMRC}
    printf "let g:gutentags_ctags_extra_args += ['--c-kinds=+px']" >>${VIMRC}
    echo -e '\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" some other setup' >>${VIMRC}
    echo 'set nu! " display line number' >>${VIMRC}
    echo 'syntax enable' >>${VIMRC}
    echo 'syntax on' >>${VIMRC}
    echo 'colorscheme desert' >>${VIMRC}
    echo -e ':set autowrite "auto save\n\n' >>${VIMRC}

    echo -e "\n\n to make effects of the plugins, start vim, and enter:"
    echo -e " :PluginInstall"
    echo -e "YouCompleteMe needs to be compiled after the plugins are installed:"
    echo -e "  dj setup you-complete-me"

    _popd_quiet
}

# =============================================================================
function _dj_setup_you_complete_me() {
    _pushd_quiet ${PWD}

    folder=~/.vim/bundle/YouCompleteMe
    if [ -d $folder ]; then
        cd $folder
        ./install.py --clang-completer
        cp third_party/ycmd/examples/.ycm_extra_conf.py ~/.vim/
    else
        echo "You need to install the YouCompleteMe plugin for Vim by"
        echo -e "dj setup vim-env"
    fi

    _popd_quiet
}

# =============================================================================
function _dj_flame_grapah() {
    if [ "$1" = 'clear' ]; then
        sudo rm -f perf.data.old
        sudo rm -f perf.folded
        sudo rm -f perf.unfold
        sudo rm -f perf.svg
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
    sudo perf script -i ${perf_data_file} &>perf.unfold
    stackcollapse-perf.pl perf.unfold &>perf.folded
    flamegraph.pl perf.folded >perf.svg

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
        shift
        _dj_flame_grapah $@
        return
    fi
    # ------------------------------
    if [ $1 = 'format' ]; then
        # ------------------------------
        if [[ $# -ge 2 ]]; then
            shift
            _dj_format $@
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
                _dj_grep_package $@
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
                _dj_git_ssh_account_activate $@
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
                _dj_git_ssh_clone_from $@
                return
            fi
            _dj_clone_help
            return
        fi
        echo 'dj git: argument not supported, exit.'
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
        _dj_pack $@
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
            _dj_replace $@
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
            _dj_setup $@
            return
        fi
        echo "dj setup: argument not supported, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'ssh-general' ]; then
        # ------------------------------
        if [ $2 = 'no-password' ]; then
            shift 2
            _dj_ssh_general_no_password $@
            return
        fi
        return
    fi

    # ------------------------------
    if [ $1 = 'udev' ]; then
        # ------------------------------
        if [ $# -ge 2 ]; then
            shift 1
            _dj_udev $@
            return
        fi
        _dj_udev_help
        return
    fi
    # ------------------------------
    if [ $1 = 'udevadm' ]; then
        if [ $# -ge 2 ]; then
            shift 1
            _dj_udevadm $@
            return
        fi
        _dj_udevadm_help $2 $3
        return
    fi
    # ------------------------------
    if [ $1 = 'unpack' ]; then
        shift 1
        _dj_unpack $@
        return
    fi
    # ------------------------------
    if [ $1 = 'work-check' ]; then
        shift 1
        _dj_work_check $@
        return
    fi
    _dj_help
    # ------------------------------
}

# =============================================================================
function _dj() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        flame-graph
        format
        get
        git
        grep
        help
        open
        python3
        pack
        replace
        setup
        ssh-general
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
    setup_list="abseil-cpp adobe-pdf-reader anaconda ansible arduino-1.8.13 baidu-netdisk boost can-analyzer "
    setup_list+="can-dev-tools clang-format clang-llvm cli11 cmake computer container cutecom devtools driver dropbox eigen3 "
    setup_list+="flamegraph fmt foxit-pdf-reader fsm-pro gadgets gcc-arm-stm32 gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf "
    setup_list+="gcc-aarch64-linux-gnu git-lfs gitg-gitk glfw3 glog gnome gnuplot google-repo grpc "
    setup_list+="gtest g++-10 g++-11 i219-v kdiff3-meld kermit lcm libbpf libcsv-3.0.2 libev libgpiod libiio libserialport "
    setup_list+="libsystemd mathpix matplot++ magic-enum mbed meson-ninja mongodb network-tools nlohmann-json3-dev "
    setup_list+="nodejs nvidia nvtop opencv-2.4.13 opencv-3.4.13 opencv-4.1.1 opencv-4.2.0 pangolin perf picocom "
    setup_list+="pip plotjuggler pycharm python3.9 qemu qt-5.13.1 qt-5.14.2 ros-melodic ros-noetic ros2-foxy rpi-pico rust "
    setup_list+="saleae-logic serial-console spdlog slack stm32-cubeMX stm32-tools sublime texlive tldr typora vim-env "
    setup_list+="vscode vtk-8.2.0 windows-fonts wireshark wubi yaml-cpp you-complete-me "
    ACTIONS[setup]="$setup_list "
    for i in $setup_list; do
        ACTIONS[$i]=" "
    done
    # special ones -----------------
    ACTIONS[container]="dive docker docker-compose lxd-4.0 "
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
    ACTIONS[clone]="bitbucket github "

    # --------------------------------------------------------
    flame_list="generate clear help "
    ACTIONS["flame-graph"]="$flame_list "
    for i in $flame_list; do
        ACTIONS[$i]=" "
    done
    # --------------------------------------------------------
    format_list="brush enable disable show "
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
complete -F _dj dj
