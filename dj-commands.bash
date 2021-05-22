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
    echo -e " \nFirst level commands:"
    echo "   setup         - to install some software"
    echo "   clone         - clone a repo from github/gitee/bitbucket"
    echo "   clone-ssh     - use ssh protocol to clone a repo from github/gitee/bitbucket"
    echo "   udev          - udev rule setup for usb devices"
    echo "   work-check    - check work status of all repos in a folder"
    echo -e "\n"
    echo -e "\n   MORE IS COMMING\n"
    echo -e " All commands support tab completion\n"
}

# =============================================================================
function _dj_setup_boost() {
    cur_dir=${PWD}
    cd ~ && mkdir -p soft/ && cd soft/

    echo -e "${GRN}boost-1.74.0${NOC} is going to be installed\n"
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
    cur_dir=${PWD}
    cd ~ && mkdir -p soft/ && cd soft/

    rm -rf CLI11/
    git clone https://github.com/CLIUtils/CLI11
    cd CLI11
    git checkout v1.9.1         # v1.9.1 was released on June 20th, 2020.
    git submodule update --init # gtest is a submodule of it
    mkdir build
    cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install

    cat <<eom
 -----------------------------------------------------------------
    headers files installed to:
        /usr/local/include/CLI/
    *.cmake files installed to:
        /usr/local/lib/cmake/CLI11/
    package config file installed to:
        /usr/local/lib/pkgconfig/CLI11.pc
 -----------------------------------------------------------------

eom

    cd $cur_dir

}

# =============================================================================
# setting a fixed version is not a good idea, but ...
function _dj_setup_cmake_3_19_5() {
    v="3.19.5"
    echo -e "\n ${GRN} install CMake $v ${NOC}"
    _press_enter_or_wait_s_continue 5

    cur_dir=${PWD}

    # where did I got this? I cannot find the source -- do not delete
    # sudo rm -rf /etc/apt/sources.list.d/kitware-latest.list
    # wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc \
    #     2>/dev/null | sudo apt-key add -
    # sudo sh -c 'echo "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" \
    #     >> /etc/apt/sources.list.d/kitware-latest.list'

    cd ~ && mkdir -p soft/ && cd soft/
    file="cmake-$v.tar.gz"
    url="https://github.com/Kitware/CMake/releases/download/v$v/$file"
    _wget_if_not_exist $file "b05ac439a6f49c75a0faaeca4a2c3144" $url
    rm -rf cmake-$v
    tar zxvf cmake-$v.tar.gz
    cd cmake-$v
    rm build -rf && mkdir build && cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install

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

    cd ~ && mkdir -p workspace/ && cd workspace/
    git clone https://dj-zhou@github.com/dj-zhou/dj-gadgets.git
    cd dj-gadgets
    make && sudo make install

    # dj-file installation
    cd dj-file/
    ./install.sh

    cd ~/workspace/

    cd $cur_dir
}

# =============================================================================
# todo: for each package, yes (default) to intall, no to skip
function _dj_setup_devtools() {
    _install_if_not_installed libncurses5-dev
}

# =============================================================================
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
# this is only tested in Ubuntu 18.04
function _dj_setup_container_docker() {
    cur_dir=${PWD}

    # Install a few prerequisite packages
    packages=" apt-transport-https ca-certificates curl software-properties-common "
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

    echo -e "\n"
    echo "use the following command to check the docker image layouts"
    echo "  sudo dive <image-tag/hash>"
    echo -e "\n"
    echo "you can find the image-tag/hash from command: sudo docker images -a"
    echo -e "\n"

    # ----------------------------------------------
    cd $cur_dir
}

# =============================================================================
function _dj_setup_container_lxd_4_0() {
    _install_if_not_installed snapd

    sudo snap install lxd --channel=4.0/stable
    echo -e "\n"
    echo 'next step: '
    echo ' sudo lxd init'
    echo -e "\n"
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
    # this following commit is tested on Ubuntu 20.04, on Sept. 25th, 2020
    git checkout 86eb4975fc4fc8b5d92148c2e370045ae9bf9f5d # it is on master
    rm -rf build/ && mkdir build && cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install

    echo -e "\n libpangolin.so is in path: ${GRN}/usr/local/lib/${NOC}"
    echo -e " header files are in path: ${GRN}/usr/local/include/pangolin/${NOC}\n"

    echo -e "\n If you see error like this:"
    echo "   Could not find GLEW"
    echo " you should run the following commands first:"
    echo "   dj setup glfw3"
    echo -e "   dj setup gtest-glog\n"

    cd $cur_dir
}

# =============================================================================
function _dj_setup_pip() {
    cur_dir=$PWD

    cd ~/
    _install_if_not_installed python3-pip
    _install_if_not_installed python-pip

    sudo pip install --upgrade pip
    sudo pip3 install --upgrade pip

    echo -e "\n check the pip/pip3 version by\n"
    echo "   pip --version"
    echo -e "   pip3 --version\n"

    cd ${cur_dir}
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
        echo -e "\n $CYN the installed qemu is probably for ARM only, check it later$NOC\n"
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

    echo -e "${YLW}if cubeMX is not installed to ~/soft/STM32CubeMX/, you need to revise${NOC}"
    echo -e "${YLW} /usr/share/applications/$file accordingly.${NOC}"
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
# Ubuntu 18.04: v1.6.1 works (test with projects to download binaries)
# Ubuntu 20.04: v1.6.1 works
#
# stlink tests on Ubuntu 18.04
# v1.6.0 failed
function _dj_setup_stm32_tools() {
    cur_dir=$PWD

    echo -e "\n install ${GRN}st-link v2${NOC} and ${GRN}stm32flash${NOC} tools"
    _press_enter_or_wait_s_continue 10

    # install dependencies and some software ----------------
    packages="libusb-1.0.0-dev gtk+-3.0 cu cutecom putty screen cmake "
    _install_if_not_installed $packages

    # install stlink ----------------
    echo -e "\n install ${GRN}stlink${NOC}\n"
    _press_enter_or_wait_s_continue 10

    mkdir -p ~/soft && cd ~/soft
    rm stlink -rf
    git clone https://github.com/stlink-org/stlink

    cd stlink
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        git checkout v1.6.1
    elif [[ ${ubuntu_v} = *'20.04'* ]]; then
        git checkout v1.6.1
    else
        echo "${RED} NOT IMPLEMENTED YET${NOC}"
    fi
    echo "sudo rm -rf /usr/local/bin/st-*"
    sudo rm -rf /usr/local/bin/st-*
    make release -j$(cat /proc/cpuinfo | grep processor | wc -l)
    cd build/Release/
    sudo make install
    sudo ldconfig

    # install stm32flash ----------------
    echo -e "\n install  stm32flash\n"
    _press_enter_or_wait_s_continue 10
    cd ~/soft/
    rm stm32-tools -rf
    git clone https://github.com/dj-zhou/stm32-tools.git
    cd stm32-tools/stm32flash
    make clean
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo rm /usr/local/bin/stm32flash
    sudo make install

    # udev rule ----------------
    echo -e "\n add serial port privilege to current user\n"
    _press_enter_or_wait_s_continue 10
    sudo usermod -a -G dialout $(whoami)
    rule_file=stm32-tools.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyUSB[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyACM[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    sudo service udev restart

    echo -e "\n"

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_glfw3() {
    cur_dir=$PWD

    echo -e "\n install glfw3 ...\n"

    cd ~ && mkdir -p soft && cd soft/

    # glfw3
    packages="build-essential cmake git xorg-dev libglu1-mesa-dev "
    _install_if_not_installed $packages
    sudo rm -rf glfw3/
    git clone https://github.com/dj-zhou/glfw3.git
    cd glfw3/
    mkdir build && cd build/
    cmake .. -DBUILD_SHARED_LIBS=ON
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install && sudo ldconfig

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_google_repo() {
    cur_dir=$PWD

    # it needs python2
    _install_if_not_installed python

    if [ -f $djtools_path/tools/repo ]; then
        echo -e "\n use repo from tools/ \n"
        sudo cp $djtools_path/tools/repo /bin/
        sudo chmod a+x /bin/repo
    else
        echo -e "\n fetch from google \n"
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

    echo -e "\n install gtest ...\n"

    # install gtest from source, v1.10
    cd ~ && mkdir -p soft && cd soft/
    rm -rf googletest
    git clone https://github.com/google/googletest.git
    cd googletest
    git checkout release-1.10.0 # a fixed version on Oct. 3rd, 2019
    rm build -rf && mkdir build && cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install

    cat <<eom

 -----------------------------------------------------------------
    gtest.a and gtest_main.a are installed to:
        /usr/local/lib/
    
    header files:
        /usr/local/include/gtest/*

    pkg-config file:
        /usr/local/lib/pkgconfig/gtest.pc
        /usr/local/lib/pkgconfig/gtest_main.pc
 -----------------------------------------------------------------

eom

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_glog() {
    cur_dir=$PWD

    echo -e "\n install glog ...\n"

    # install gtest from source
    cd ~ && mkdir -p soft && cd soft/
    rm -rf glog
    git clone https://github.com/google/glog.git
    cd glog
    git checkout v0.4.0 # a fixed version on March 21st, 2019
    rm build -rf && mkdir build && cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install

    cat <<eom

 -----------------------------------------------------------------
    glog static library is installed to:
        /usr/local/lib/libglog.a
    
    header files:
        /usr/local/include/glog/*

    pkg-config file:
        none
 -----------------------------------------------------------------
eom

    cd ${cur_dir}
}

# =============================================================================
# instlal gnome, need more test
function _dj_setup_gnome() {
    echo -e "\n install gnome on Ubuntu\n"
    _press_enter_or_wait_s_continue 20

    _install_if_not_installed tasksel
    _install_if_not_installed gnome-session
    _install_if_not_installed ubuntu-desktop

    echo -e "\n when log in, choose GNOME\n"
}

# =============================================================================
# ninja is used to compile
function _dj_setup_grpc_1_29_1() {
    cur_dir=$PWD

    cd ~ && mkdir -p soft && cd soft/
    git clone https://github.com/grpc/grpc.git --recurse-submodules \
        --shallow-submodules --depth 1 --branch v1.29.1
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
    echo -e "\n install ${GRN}gcc-10${NOC}, ${GRN}g++-10${NOC} \n"
    _press_enter_or_wait_s_continue 10

    _install_if_not_installed gcc-10
    _install_if_not_installed g++-10
    if [[ ! -f /etc/apt/sources.list.d/ubuntu-toolchain-r*.list ]]; then
        sudo add-apt-repository ppa:ubuntu-toolchain-r/test
        sudo apt-get -y update
    fi

    # install g++10/gcc-10
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo -e "\n install ${GRN}gcc-9${NOC}, ${GRN}g++-9${NOC} \n"
        _press_enter_or_wait_s_continue 10
        _install_if_not_installed gcc-9
        _install_if_not_installed g++-9
    fi

    # ----------------------
    echo -e "run update-alternatives:\n"
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
    echo -e "\n-------------------\n"
    sudo update-alternatives --config gcc
    echo -e "\n-------------------\n"
    sudo update-alternatives --config g++
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
    elif [[ ${ubuntu_v} = *'18.04'* || \
        ${ubuntu_v} = *'20.04'* ]]; then
        echo -e "\n please follow the link below to finish the setup:"
        echo -e " https://www.pinyinjoe.com/linux/ubuntu-18-gnome-chinese-setup.htm\n"
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
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install

    echo -e "\n"
    echo " the installed library seems to be in /usr/local/lib folder"
    echo " the installed header files seem to be in /usr/local/include/vtk-8.2/ folder"
    echo -e "\n"

    cd ${cur_dir}
}

# =============================================================================
# call function in workspace-check.bash
function _dj_work_check() {
    _work_check $1 $2 $3 $4
}

# =============================================================================
# to search a library use: ldconfig -p | grep xxxx
# once this command get extended, we add sub command to "dj search"
function _dj_search_package() {
    cur_dir=$PWD

    lib_to_find=$1
    echo -e "\n run command:$GRN ldconfig -p | grep $lib_to_find$NOC, we get:"

    ldconfig -p | grep $lib_to_find

    echo -e "\n cd /usr/lib/x86_64-linux-gnu/pkgconfig"
    cd /usr/lib/x86_64-linux-gnu/pkgconfig
    echo -e " ls | grep $lib_to_find\n"
    ls | grep $lib_to_find
    cd $cur_dir
}

# =============================================================================
# to search some string in a project directory, excluding build/ and bin/
function _dj_search_string() {
    echo -e "\n run command:"
    echo -e "   $GRN grep -rI $1 .$NOC"
    echo -e " we get:"
    # how to use the variable in the below?? -- $excluded_dir does not work
    # -I option ignores the search from binary files, that is perfect!
    grep -rI --exclude-dir={build,bin,_bcross*,_bnative*,builddir,.git} $1 .
}

# =============================================================================
# to find something in a meson file
# only works in . directory
function _dj_find_in_meson() { # term
    term=$1
    if [ -z "$term" ]; then
        echo -e "\n usage:"
        echo -e "   dj meson find <something>\n"
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
        echo -e " dj ssh-general no-password username@ip_address\n"
        return
    fi
    user_and_ip="$1"
    user=${user_and_ip%"@"*}
    pos=$(_find_a_char_in_str $user_and_ip "@" 1)
    ip=${user_and_ip:${pos}+1:${#user_and_ip}-${pos}}

    # if ~/.ssh/id_rsa-general.pub does not exist, create one
    key_file=id_rsa-general
    if [ ! -f "$key_file" ]; then
        printf "${HOME}/.ssh/${key_file}\n\n\n" | ssh-keygen
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
        echo -e "\n account $1 does not exist, do you want to create it? (yes/no)"
        read asw
        if [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') || (\
            $asw = 'No') || ($asw = 'no') ]]; then
            echo 'Canceled and exit!'
            return
        elif [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || (\
            $asw = 'Yes') || ($asw = 'yes') ]]; then
            # proceed -------------
            echo -e "SSH key file ${GRN}${key_file}${NOC} not found, generate one automatically:"
            printf "${key_file}\n\n\n" | ssh-keygen
            echo -e "\ncopy the following content into a new GitHub SSH Key (https://github.com/settings/keys, need login):"
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
    echo -e "\n setup the vim as an IDE\n"
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
    printf "Plugin 'VundleVim/Vundle.vim'\n" >>${VIMRC}
    printf "Plugin 'majutsushi/tagbar'\n" >>${VIMRC}
    printf "Plugin 'scrooloose/nerdtree'\n" >>${VIMRC}
    printf "Plugin 'w0rp/ale'\n" >>${VIMRC}
    printf "Plugin 'Valloric/YouCompleteMe'\n" >>${VIMRC}
    printf "Plugin 'ludovicchabant/vim-gutentags'\n\n" >>${VIMRC}
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
    printf "let g:ale_sign_column_always = 1\n" >>${VIMRC}
    printf "let g:ale_sign_error = '>>'\n" >>${VIMRC}
    printf "let g:ale_sign_warning = '--'\n" >>${VIMRC}
    printf "let g:ale_statusline_format = ['x %%d', 'z %%d', 'y OK']\n" >>${VIMRC}
    printf "let g:ale_echo_msg_format = '[%%linter%%] %%code: %%%%s'\n" >>${VIMRC}
    printf "let g:ale_lint_on_text_changed = 'normal'\n" >>${VIMRC}
    printf "let g:ale_lint_on_insert_leave = 1\n" >>${VIMRC}
    printf "let g:ale_c_gcc_options = '-Wall -O2 -std=c99'\n" >>${VIMRC}
    printf "let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++20'\n" >>${VIMRC}
    printf "let g:ale_c_cppcheck_options = ' '\n" >>${VIMRC}
    printf "let g:ale_cpp_cppcheck_options = ' '\n" >>${VIMRC}
    echo -e '\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" YouCompleteMe setup' >>${VIMRC}
    printf "let g:ycm_server_python_interpreter='/usr/bin/python3'\n" >>${VIMRC}
    printf "let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'" >>${VIMRC}
    echo -e '\n\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" vim-gutentags setup' >>${VIMRC}
    printf "let g:gutentags_project_root= ['.root', '.svn', '.git', '.hg',  '.project']\n" >>${VIMRC}
    printf "let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']\n" >>${VIMRC}
    printf "let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']\n" >>${VIMRC}
    printf "let g:gutentags_ctags_extra_args += ['--c-kinds=+px']\n" >>${VIMRC}
    echo -e '\n' >>${VIMRC}
    echo '" ===========================================================' >>${VIMRC}
    echo '" some other setup' >>${VIMRC}
    echo 'set nu! " display line number' >>${VIMRC}
    echo 'syntax enable' >>${VIMRC}
    echo 'syntax on' >>${VIMRC}
    echo 'colorscheme desert' >>${VIMRC}
    echo -e ':set autowrite "auto save\n\n' >>${VIMRC}

    echo -e "\n\n to make effects of the plugins, start vim, and enter:"
    echo -e " :PluginInstall\n"
    echo -e "YouCompleteMe needs to be compiled after the plugins are installed:"
    echo -e "  dj setup you-complete-me\n"

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
        echo -e "dj setup vim-env\n"
    fi

    cd ${cur_dir}
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
            _dj_clone_from $2 $3 $4 $5 $6 $7
            return
        fi
        _dj_clone_help
        return
    fi
    # ------------------------------
    if [ $1 = 'clone-ssh' ]; then
        # --------------------------
        if [[ "$2" = 'bitbucket' ]] ||
            [[ "$2" = 'github' ]] ||
            [[ "$2" = 'gitee' ]]; then
            _dj_clone_ssh_from $2 $3 $4 $5 $6 $7
            return
        fi
        _dj_clone_help
        return
    fi
    # ------------------------------
    if [ $1 = 'format' ]; then
        # ------------------------------
        if [[ $# -ge 2 ]]; then
            _dj_format $2 $3 $4 $5 $6 $7 $8
            return
        fi
        echo "dj format: wrong argument, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'search' ]; then
        # ------------------------------
        if [ $2 = 'package' ]; then
            # ------------------------------
            if [[ $# -ge 3 ]]; then
                _dj_search_package $3 $4 $5 $6 $7 $8
                return
            fi
        fi
        # ------------------------------
        if [ $2 = 'string' ]; then
            # ------------------------------
            if [[ $# -ge 3 ]]; then
                _dj_search_string $3 $4 $5 $6 $7 $8
                return
            fi
        fi
        echo "dj search: wrong argument, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'help' ]; then
        # ------------------------------
        if [ $# -ge 2 ]; then
            _dj_help_skill $2
            return
        fi
        echo 'dj help: wrong argument, exit.'
        return
    fi
    # ------------------------------
    if [ $1 = 'find' ]; then
        # ------------------------------
        if [ $# -ge 2 ] && [ $2 = '-in-meson' ]; then
            _dj_find_in_meson $3 $4 $5 $6
            return
        fi
        echo 'dj find: wrong argument, exit.'
        return
    fi
    # ------------------------------
    if [ $1 = 'open' ]; then
        _dj_open_file $2 $3 $4
        return
    fi
    # ------------------------------
    if [ $1 = 'replace' ]; then
        # ------------------------------
        if [[ $# -ge 2 ]]; then
            _dj_replace $2 $3 $4 $5 $6 $7 $8
            return
        fi
        echo "dj replace: wrong argument, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'setup' ]; then
        # ------------------------------
        if [ $# -ge 2 ]; then
            _dj_setup $2 $3 $4 $5 $6 $7
            return
        fi
        echo "dj setup: wrong argument, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'ssh-general' ]; then
        # ------------------------------
        if [ $2 = 'no-password' ]; then
            _dj_ssh_general_no_password $3 $4 $5 $6 $7
            return
        fi
        return
    fi
    # ------------------------------
    if [ $1 = 'ssh-github' ]; then
        # ------------------------------
        if [ $2 = 'activate' ]; then
            _dj_ssh_github_activate $3 $4 $5 $6 $7
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
        echo "dj ssh-github: wrong argument, exit."
        return
    fi
    # ------------------------------
    if [ $1 = 'udev' ]; then
        # ------------------------------
        if [ $# -ge 2 ]; then
            _dj_udev $2 $3 $4 $5 $6 $7
            return
        fi
        _dj_udev_help
        return
    fi
    # ------------------------------
    if [ $1 = 'udevadm' ]; then
        if [ $# -ge 2 ]; then
            _dj_udevadm $2 $3 $4 $5 $6 $7
            return
        fi
        _dj_udevadm_help $2 $3
        return
    fi
    # ------------------------------
    if [ $1 = 'work-check' ]; then
        _dj_work_check $2 $3 $4 $5
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
        clone-ssh
        format
        find
        help
        open
        replace
        search
        setup
        ssh-general
        ssh-github
        udev
        udevadm
        work-check
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # --------------------------------------------------------
    # --------------------------------------------------------
    setup_list="adobe-pdf-reader anaconda arduino-1.8.13 baidu-netdisk boost clang-format clang-llvm "
    setup_list+="cli11 cmake-3.19.5 computer container dj-gadgets devtools driver dropbox eigen3 "
    setup_list+="foxit-pdf-reader gcc-arm-stm32 gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf "
    setup_list+="gcc-aarch64-linux-gnu git-lfs gitg-gitk glfw3 google-repo glog gnome grpc-1.29.1 "
    setup_list+="gtest g++-10 i219-v kdiff3-meld lcm libcsv-3.0.2 libev-4.33 libgpiod libiio lib-serialport "
    setup_list+="libyaml-cpp mathpix matplot++ magic-enum mbed meson mongodb nlohmann-json3-dev nvidia nvtop "
    setup_list+="opencv-2.4.13 opencv-3.4.13 opencv-4.1.1 opencv-4.2.0 pangolin pip pycharm python3.9 "
    setup_list+="qemu qt-5.13.1 qt-5.14.2 ros-melodic ros-noetic ros2-foxy saleae-logic spdlog slack "
    setup_list+="stm32-cubeMX stm32-tools sublime texlive typora vim-env vscode vtk-8.2.0 windows-fonts wubi "
    setup_list+="you-complete-me "
    ACTIONS[setup]="$setup_list "
    for i in $setup_list; do
        ACTIONS[$i]=" "
    done
    # special ones -----------------
    ACTIONS[container]="docker dive lxd-4.0 "
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
    ACTIONS["libyaml-cpp"]="-v "
    ACTIONS[-v]="0.6.2 0.6.3 "
    ACTIONS[0.6.2]=" "
    ACTIONS[0.6.3]=" "

    # --------------------------------------------------------
    # --------------------------------------------------------
    ACTIONS[clone]="bitbucket github gitee "
    ACTIONS["clone-ssh"]="bitbucket github gitee "

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
    help_list="auto-mount ffmpeg jupyter "
    ACTIONS[help]="$help_list "
    for i in $help_list; do
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
