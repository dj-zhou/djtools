#!/bin/bash

source $djtools_path/clang-format.bash
source $djtools_path/clone.bash
source $djtools_path/help.bash
source $djtools_path/setup-generic.bash
source $djtools_path/setup-opencv.bash
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
    echo "   clone         - clone a repo from github/gitee/bitbucket"
    echo "   ssh-clone     - use ssh protocol to clone a repo from github/gitee/bitbucket"
    echo "   udev          - udev rule setup for usb devices"
    echo "   work-check    - check work status of all repos in a folder"
    echo -e ""
    echo -e "  MORE IS COMMING"
    echo -e "All commands support tab completion"
}

# =============================================================================
function _dj_setup_boost() {
    cur_dir=${PWD}
    cd ~ && mkdir -p soft/ && cd soft/

    echo -e "${GRN}boost-1.74.0${NOC} is going to be installed"
    _press_enter_to_continue

    rm -rf boost
    git clone https://github.com/boostorg/boost.git

    cd boost
    # checkout a specific version
    git checkout boost-1.74.0
    # clone the submodules! this takes long though
    git submodule update --init --recursive
    # install is simple
    ./bootstrap.sh --prefix=/usr/local
    ./b2

    echo -e "${PRP}sudo cp libboost_* /usr/local/lib/${NOC}"
    sudo cp libboost_* /usr/local/lib/

    cat <<eom
-----------------------------------------------------------------
    headers installed to:
        /usr/include/
    shared library is copied to:
        /usr/local/lib/
-----------------------------------------------------------------

eom

    cd $cur_dir
}

# =============================================================================
function _dj_setup_cli11() {
    cur_dir_cli11=${PWD}
    cd ~ && mkdir -p soft/ && cd soft/

    rm -rf CLI11/
    git clone https://github.com/CLIUtils/CLI11
    cd CLI11
    git checkout v2.0.0
    git submodule update --init # gtest is a submodule of it
    mkdir build
    cd build
    cmake ..
    make -j$(nproc)
    sudo make install

    _verify_header_files /usr/local/include/CLI/
    _verify_cmake_files /usr/local/lib/cmake/CLI11/
    _verify_pkgconfig_file CLI11.pc /usr/local/lib/pkgconfig

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

    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf CMake
    git clone https://github.com/Kitware/CMake.git
    cd CMake
    git checkout $v

    ./bootstrap --prefix=/usr/local
    make -j$(nproc)
    sudo make install
    echo -e "${GRN}cmake${NOC} is installed to ${GRN}/usr/local/bin${NOC}"
    cd $cur_dir
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
function _dj_setup_dj_gadgets() {
    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/
    sudo rm -rf dj-gadgets
    git clone https://dj-zhou@github.com/dj-zhou/dj-gadgets.git
    cd dj-gadgets
    sudo rm build -rf
    mkdir build
    cd build
    cmake ..
    make
    sudo make install

    # todo: check if CLI11 is installed, if not, install it
    if [ ! -f /usr/local/lib/pkgconfig/CLI11.pc ]; then
        dj setup cli11
    fi

    # dj-file installation
    cd ../dj-file/
    rm build -rf
    mkdir build
    cd build
    cmake ..
    make
    sudo make install

    cd $cur_dir
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
    cur_dir=${PWD}

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

    # ----------------------------------------------
    cd $cur_dir
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
    cur_dir=${PWD}

    # ----------------------------------------------
    cd ~ && mkdir -p soft/ && cd soft/
    dive_version="0.9.2"
    drive_url="https://github.com/wagoodman/dive/releases/download/v"
    wget $drive_url$dive_version"/dive_"$dive_version"_linux_amd64.deb"
    sudo dpkg -i dive_*.deb

    echo "use the following command to check the docker image layouts"
    echo "    \$ sudo dive <image-tag/hash>"
    echo "you can find the image-tag/hash from command: sudo docker images -a"

    # ----------------------------------------------
    cd $cur_dir
}

# =============================================================================
function _dj_setup_container_lxd_4_0() {
    _install_if_not_installed snapd

    sudo snap install lxd --channel=4.0/stable
    echo 'next step: $ sudo lxd init'
}

# =============================================================================
function _dj_setup_pangolin() {
    cur_dir=${PWD}
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

    cd $cur_dir
}

# =============================================================================
function _dj_setup_picocom() {
    cur_dir=${PWD}
    cd ~ && mkdir -p soft/ && cd soft/

    v=$(_find_package_version picocom)
    rm -rf picocom
    git clone git@github.com:npat-efault/picocom.git
    cd picocom
    git checkout $V
    make
    sudo cp picocom /usr/bin/

    cd $cur_dir

    echo "example of using picocom:"
    echo "$ picocom /dev/ttyUSB0 -b 115200 -g file-$(TZ=UTC date +%FT%H%M%SZ).log"
}

# =============================================================================
function _dj_setup_pip() {
    cur_dir=$PWD

    cd ~/
    _install_if_not_installed python3-pip
    _install_if_not_installed python-pip

    sudo pip install --upgrade pip
    sudo pip3 install --upgrade pip

    echo -e "check the pip/pip3 version by:"
    echo "   \$ pip --version"
    echo "   \$ pip3 --version"

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_perf() {
    _install_if_not_installed linux-tools-common linux-tools-generic linux-tools-$(uname -r)
    _install_if_not_installed linux-tools-common linux-tools-generic

    echo "check perf version: \$ perf --version"
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
    cur_dir=$PWD

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

    cd ${cur_dir}
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
    cur_dir=$PWD

    cd ~ && mkdir -p soft && cd soft/

    git clone https://gitee.com/d-zhou/stm32-cube-mx-v6.0.1.git
    cd stm32-cube-mx-v6.0.1/
    cat archive.tar.* | tar -xzvf -
    # rm archive.tar.*
    chmod +x SetupSTM32CubeMX-6.0.1.linux
    ./SetupSTM32CubeMX-6.0.1.linux

    cd $cur_dir

    _create_stm32cubemx_desktop_item
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
    cur_dir=$PWD

    echo -e "install ${GRN}st-link v2${NOC} and ${GRN}stm32flash${NOC} tools"
    _press_enter_or_wait_s_continue 10

    # install dependencies and some software ----------------
    packages="libusb-1.0.0-dev gtk+-3.0 cu cutecom putty screen cmake "
    _install_if_not_installed $packages

    # install stlink ----------------
    echo -e "install ${GRN}stlink${NOC}"
    _press_enter_or_wait_s_continue 10

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

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_glfw3() {
    cur_dir=$PWD

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

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_gnuplot() {
    cur_dir=$PWD

    cd ~ && mkdir -p soft && cd soft/
    rm -rf gnuplot
    git clone https://github.com/gnuplot/gnuplot.git
    cd gnuplot
    ./prepare
    ./configure
    make -j$(nproc)
    sudo make install && sudo ldconfig

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_google_repo() {
    cur_dir=$PWD

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
    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_gtest() {
    cur_dir=$PWD

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

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_glog() {
    cur_dir=$PWD

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

    cd ${cur_dir}
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
    cur_dir=$PWD

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

    cd ${cur_dir}
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

    _install_if_not_installed gcc-10
    _install_if_not_installed g++-10

    # install g++10/gcc-10
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "install ${GRN}gcc-9${NOC}, ${GRN}g++-9${NOC} "
        _press_enter_or_wait_s_continue 10
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
    cur_dir=$PWD

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
    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_vtk_8_2_0() {
    echo "vtk 8.2.0 installation"

    cur_dir=$PWD

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

    cd ${cur_dir}
}

# =============================================================================
# call function in workspace-check.bash
function _dj_work_check() {
    _work_check $@
}

# =============================================================================
# to search a library use: ldconfig -p | grep xxxx
# once this command get extended, we add sub command to "dj search"
function _dj_search_package() {
    cur_dir=$PWD

    lib_to_find=$1
    echo -e "run command:$GRN ldconfig -p | grep $lib_to_find$NOC, we get:"

    ldconfig -p | grep $lib_to_find

    echo -e "cd /usr/lib/x86_64-linux-gnu/pkgconfig"
    cd /usr/lib/x86_64-linux-gnu/pkgconfig
    echo -e " \$ ls | grep $lib_to_find"
    ls | grep $lib_to_find
    cd $cur_dir
}

# =============================================================================
# to search some string in a project directory, excluding build/ and bin/
function _dj_search_string() {
    echo -e "run command:"
    echo -e "   $GRN grep -rI $1 .$NOC"
    echo -e "we get:"
    # how to use the variable in the below?? -- $excluded_dir does not work
    # -I option ignores the search from binary files, that is perfect!
    grep -rI --exclude-dir={build,bin,_bcross*,_bnative*,builddir,.git,.cache} "$1" .
}

# =============================================================================
# to find something in a meson file
# only works in . directory
function _dj_find_in_meson() { # term
    term=$1
    if [ -z "$term" ]; then
        echo -e "usage:"
        echo -e "   dj meson find <something>"
        return
    fi
    all_meson_build=$(find . -name meson.build)
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
# there may be a better solution
function _dj_ssh_github_activate() {
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
            printf "${key_file}\n\n" | ssh-keygen
            echo -e "copy the following content into a new GitHub SSH Key (https://github.com/settings/keys, need login):"
            echo -e "${GRN}"
            cat ${key_file}.pub
            echo -e "${NOC}"
        else
            echo "Wrong answer! Canceled and exit!"
        fi
    fi

    # if see this error: Error connecting to agent: Connection refused, do
    # eval "$(ssh-agent)"
    ssh-add -D
    ssh-add ${key_file}
    echo $github_username >~/.ssh/.github-activated-account
}

# =============================================================================
function _dj_ssh_github_all_accounts() {
    all_github_accounts=$(ls ~/.ssh | grep .pub)
    for i in $all_github_accounts; do
        username=${i%".pub"}
        username=$(echo "${username/"id_rsa-github-"/}")
        echo $username
    done
}

# =============================================================================
function _dj_ssh_github_current_account() {
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

    cur_dir=$PWD

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

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_you_complete_me() {
    cur_dir=$PWD

    folder=~/.vim/bundle/YouCompleteMe
    if [ -d $folder ]; then
        cd $folder
        ./install.py --clang-completer
        cp third_party/ycmd/examples/.ycm_extra_conf.py ~/.vim/
    else
        echo "You need to install the YouCompleteMe plugin for Vim by"
        echo -e "dj setup vim-env"
    fi

    cd ${cur_dir}
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
    if [ $1 = 'clone' ]; then
        # --------------------------
        if [[ "$2" = 'bitbucket' ]] ||
            [[ "$2" = 'github' ]] ||
            [[ "$2" = 'gitee' ]]; then
            shift
            _dj_clone_from $@
            return
        fi
        _dj_clone_help
        return
    fi
    # ------------------------------
    if [ $1 = 'ssh-clone' ]; then
        # --------------------------
        if [[ "$2" = 'bitbucket' ]] ||
            [[ "$2" = 'github' ]] ||
            [[ "$2" = 'gitee' ]]; then
            shift
            _dj_clone_ssh_from $@
            return
        fi
        _dj_clone_help
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
    if [ $1 = 'search' ]; then
        # ------------------------------
        if [ $2 = 'package' ]; then
            # ------------------------------
            if [[ $# -ge 3 ]]; then
                shift 2
                _dj_search_package $@
                return
            fi
        fi
        # ------------------------------
        if [ $2 = 'string' ]; then
            # ------------------------------
            if [[ $# -ge 3 ]]; then
                _dj_search_string "$3" "$4" "$5" "$6" "$7" "$8"
                return
            fi
        fi
        echo "dj search: argument not supported, exit."
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
    if [ $1 = 'find' ]; then
        # ------------------------------
        if [ $# -ge 2 ] && [ $2 = '-in-meson' ]; then
            _dj_find_in_meson $3 $4 $5 $6
            return
        fi
        echo 'dj find: argument not supported, exit.'
        return
    fi
    # ------------------------------
    if [ $1 = 'git' ]; then
        if [ $2 = 'config' ]; then
            shift 2
            _dj_git_config "$@"
            return
        fi
        if [ $2 = 'see' ]; then
            shift 2
            _dj_git_see "$@"
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
    if [ $1 = 'ssh-github' ]; then
        # ------------------------------
        if [ $2 = 'activate' ]; then
            shift 2
            _dj_ssh_github_activate $@
            return
        fi
        # ------------------------------
        if [ $2 = 'all-accounts' ]; then
            _dj_ssh_github_all_accounts
            return
        fi
        # ------------------------------
        if [ $2 = 'current-account' ]; then
            _dj_ssh_github_current_account
            return
        fi
        # ------------------------------
        echo "dj ssh-github: argument not supported, exit."
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
        clone
        ssh-clone
        flame-graph
        format
        find
        git
        help
        open
        pack
        replace
        search
        setup
        ssh-general
        ssh-github
        udev
        udevadm
        unpack
        work-check
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # --------------------------------------------------------
    # --------------------------------------------------------
    setup_list="abseil-cpp adobe-pdf-reader anaconda ansible arduino-1.8.13 baidu-netdisk boost clang-format "
    setup_list+="clang-llvm cli11 cmake computer container dj-gadgets devtools driver dropbox eigen3 "
    setup_list+="flamegraph fmt foxit-pdf-reader gcc-arm-stm32 gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf "
    setup_list+="gcc-aarch64-linux-gnu git-lfs gitg-gitk glfw3 glog gnome gnuplot google-repo grpc "
    setup_list+="gtest g++-10 i219-v kdiff3-meld lcm libcsv-3.0.2 libev libgpiod libiio lib-serialport "
    setup_list+="libsystemd mathpix matplot++ magic-enum mbed meson mongodb nlohmann-json3-dev "
    setup_list+="nvidia nvtop opencv-2.4.13 opencv-3.4.13 opencv-4.1.1 opencv-4.2.0 pangolin perf picocom pip "
    setup_list+="pycharm python3.9 qemu qt-5.13.1 qt-5.14.2 ros-melodic ros-noetic ros2-foxy rust saleae-logic "
    setup_list+="spdlog slack stm32-cubeMX stm32-tools sublime texlive typora vim-env vscode vtk-8.2.0 "
    setup_list+="windows-fonts wubi yaml-cpp you-complete-me "
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
    ACTIONS[clone]="bitbucket github gitee "
    ACTIONS["ssh-clone"]="bitbucket github gitee "

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
    ACTIONS[brush]+="google file "
    ACTIONS[implement]="djz bg "
    # -----------------
    show_list="camel "
    ACTIONS[show]="$show_list "
    for i in $show_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    ACTIONS[replace]=" "

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
    # --------------------------------------------------------
    gitee_repos="$(_dj_clone_repo_list gitee) "
    ACTIONS[gitee]+="$gitee_repos "
    ACTIONS[gitee]+="--add "
    for i in $gitee_repos; do
        ACTIONS[$i]=" "
    done
    ACTIONS[--add]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS[open]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS["ssh-general"]="no-password "
    ACTIONS["no-password"]=" "
    # --------------------------------------------------------
    # --------------------------------------------------------
    ssh_github_list="activate all-accounts current-account "
    ACTIONS["ssh-github"]="$ssh_github_list"
    for i in $ssh_github_list; do
        ACTIONS[$i]=" "
    done
    all_accounts="$(_dj_ssh_github_all_accounts) "
    ACTIONS[activate]="$all_accounts"
    for i in $all_accounts; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS["work-check"]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    udev_list="uvc-video-capture --dialout --show one-third-console "
    udev_list+="stlink-v2.1 logitech-f710 ft4232h "
    ACTIONS[udev]="$udev_list "
    for i in $udev_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    udevadm_list="$(ls /dev/tty*) "
    ACTIONS[udevadm]="$udevadm_list "
    for i in $udevadm_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    search_list="package string "
    ACTIONS[search]="$search_list "
    for i in $search_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    find_list="-in-meson "
    ACTIONS[find]="$find_list "
    for i in $find_list; do
        ACTIONS[$i]=" "
    done

    # --------------------------------------------------------
    # --------------------------------------------------------
    git_list="config see "
    ACTIONS[git]="$git_list "
    for i in $git_list; do
        ACTIONS[$i]=" "
    done
    see_list="-name -email"
    ACTIONS[see]="$see_list "
    for i in $see_list; do
        ACTIONS[$i]=" "
    done
    # --------------------------------------------------------
    # --------------------------------------------------------
    help_list="apt_pkg auto-mount ffmpeg jupyter "
    ACTIONS[help]="$help_list "
    for i in $help_list; do
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
