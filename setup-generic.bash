#!/bin/bash

# =============================================================================
function _dj_setup_help() {
    _dj_help
    cat <<eom
------------------------------- dj setup --------------------------------
    setup common used software and packages
-------------------------------------------------------------------------
eom
}

# =============================================================================
function _dj_setup_abseil_cpp() {
    _pushd_quiet ${PWD}
    cd ~ && mkdir -p soft/ && cd soft/

    abseil_v=$(_find_package_version abseil-cpp)
    rm abseil-cpp -rf
    git clone git@github.com:abseil/abseil-cpp.git
    cd abseil-cpp
    git checkout $abseil_v
    mkdir build && cd build && cmake ..
    make -j$(nproc)
    sudo make install

    _popd_quiet

    _verify_lib_installation libabsl_base.a /usr/local/lib
    _verify_pkgconfig_file absl_base.pc /usr/local/lib/pkgconfig
    _verify_header_files /usr/local/include/absl/
    _verify_cmake_files abslConfig.cmake /usr/local/lib/cmake/absl/
}

# =============================================================================
function _dj_setup_adobe_pdf_reader() {
    _pushd_quiet ${PWD}

    # install i386 related dependencies --------------------
    sudo dpkg --add-architecture i386
    sudo apt-get -y update
    _install_if_not_installed libxml2:i386
    _install_if_not_installed libcanberra-gtk-module:i386
    _install_if_not_installed gtk2-engines-murrine:i386
    _install_if_not_installed libatk-adaptor:i386

    cd ~ && mkdir -p soft/ && cd soft/
    file="AdbeRdr9.5.5-1_i386linux_enu.deb"
    url="ftp://ftp.adobe.com/pub/adobe/reader/unix/9.x"
    url=${url}/9.5.5/enu/$file
    _wget_if_not_exist $file "88036c68998d565c4365e2ad89b04d51" $url
    sudo dpkg -i $file

    _popd_quiet
}

# =============================================================================================
function _create_anaconda_desktop_item() {
    folder="/usr/share/applications"

    # copy the icon file
    sudo cp $djtools_path/settings/anaconda-navigator.xpm $folder

    file="anaconda-navigator.desktop"
    touch $file

    echo '[Desktop Entry]' >>$file
    echo 'Encoding=UTF-8' >>$file
    echo 'Name=anaconda-navigator' >>$file
    echo 'Comment=anaconda-navigator' >>$file
    echo 'Exec='$HOME'/.anaconda3/bin/anaconda-navigator' >>$file
    echo 'Icon='$folder'/anaconda-navigator.xpm' >>$file
    echo 'StartupNotify=false' >>$file
    echo 'Type=Application' >>$file
    echo 'Categories=Application;Development;' >>$file

    sudo rm -rf $folder/$file
    sudo mv $file $folder

    sudo chmod +x $folder/$file

    echo -e "${YLW}if Anaconda is not installed to ~/.anaconda3, you need to revise${NOC}"
    echo -e "${YLW}/usr/share/applications/$file accordingly.${NOC}"
}

# =============================================================================
function _dj_setup_anaconda() {
    _pushd_quiet ${PWD}
    cd ~ && mkdir -p soft/ && cd soft/

    python3_ver=$(version check python3)
    anw=$(_version_if_ge_than $python3_ver "3.8")
    if [[ "$anw" = 'no' ]]; then
        echo "anaconda for Python >=3.8.* only"
        return
    fi

    file=Anaconda3-2020.11-Linux-x86_64.sh
    url=https://repo.anaconda.com/archive/$file
    _wget_if_not_exist $file "4cd48ef23a075e8555a8b6d0a8c4bae2" $url
    chmod +x $file

    echo -e "${YLW}You need to install Anaconda to ~/.anaconda3 directory!${NOC}"
    ./$file

    _create_anaconda_desktop_item

    _popd_quiet
}

# =============================================================================
function _dj_setup_ansible() {
    sudo apt update
    sudo apt install software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible
}

# =============================================================================
function _dj_setup_arduino_1_8_13() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft/ && cd soft/
    rm arduino* -rf
    filename="arduino-1.8.13-linux64.tar.xz"
    url=https://downloads.arduino.cc/$filename
    _wget_if_not_exist $filename "e4d2ff4da4ba1ddb5bc010cb38b5fbc1" $url
    tar -xvf $filename

    sudo ln -sf ${HOME}/soft/arduino-1.8.13/arduino /usr/bin/arduino

    _popd_quiet
}

# =============================================================================
function _dj_setup_baidu_netdisk() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    file="baidunetdisk_linux_3.0.1.2.deb"
    curl -L http://wppkg.baidupcs.com/issue/netdisk/LinuxGuanjia/3.0.1/$file >$file

    sudo dpkg -i $file

    _popd_quiet
}

# =============================================================================
function _dj_setup_computer() {
    _pushd_quiet ${PWD}

    sudo rm -rf ~/Documents/
    sudo rm -rf ~/Music/
    sudo rm -rf ~/Pictures/
    sudo rm -rf ~/Public/
    sudo rm -rf ~/Templates/
    sudo rm -rf ~/Videos/
    sudo rm -rf ~/examples.desktop

    # -----------------------------------
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # -----------------------------------
    cat <<eom
going to install the following packages:
       ark cmake curl dconf-editor dconf-tools git
       git-lfs g++ htop libgtk2.0-dev lsb-core
       scrot terminator tree vlc vim wmctrl xclip yasm
eom

    _press_enter_or_wait_s_continue 10
    packages="ark cmake curl dconf-editor dconf-tools git "
    packages+="git-lfs g++ htop libgtk2.0-dev libncurses5-dev lsb-core "
    packages+="scrot terminator tree vlc vim wmctrl xclip yasm "
    _install_if_not_installed $packages

    # -----------------------------------
    echo -e "going to install Google Chrome\n"
    _press_enter_or_wait_s_continue 10
    cd ~ && mkdir -p soft/ && cd soft/
    google_ver=$(google-chrome --version)
    if [[ "$google_ver" = *"Google Chrome"* ]]; then
        echo "Google Chrome already installed"
    else
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo dpkg -i google-chrome*
    fi

    cd ~

    # -----------------------------------
    # remove firefox
    # echo -e "going to remove firefox\n"
    # _press_enter_or_wait_s_continue 10
    # sudo apt-get purge firefox -y
    # rm -Rf ~/.mozilla/firefox/

    # -----------------------------------
    gnome_v=$(version check gnome)
    # to display simplified Chinese: important, do not comment out!
    if [ ! "$gnome_v" = ' ' ]; then
        echo -e "going to setup simplified Chinese support\n"
        _press_enter_or_wait_s_continue 10
        gsettings set org.gnome.gedit.preferences.encodings \
            auto-detected "['CURRENT','GB18030','GBK','GB2312','UTF-8','UTF-16']"
    fi

    # -----------------------------------
    # to disable the fixed dock (in dock setting, it is Auto-hide the Dock option)
    if [ ! "$gnome_v" = ' ' ]; then
        echo -e "hide the Dock when any windows overlap with it\n"
        _press_enter_or_wait_s_continue 10
        gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    fi
    # -----------------------------------
    # to lock the screen from commands
    if [ ! "$gnome_v" = ' ' ]; then
        echo -e "going to setup lock screen command\n"
        _press_enter_or_wait_s_continue 10
        _install_if_not_installed gnome-screensaver
    fi
    # -----------------------------------
    echo -e "time & date control: \n you need to run the code:\n"
    echo -e "    timedatectl set-local-rtc 1\n"

    _popd_quiet
}

# =============================================================================
function _dj_setup_driver_wifi() {
    if [ $1 = 'rtl8812au' ]; then
        if [[ "${ubuntu_v}" = *'20.04'* ]]; then
            url="http://archive.ubuntu.com/ubuntu/pool/main/d/dkms"
            file="dkms_2.8.1-5ubuntu1_all.deb"
            echo "1. download dkms from $url/$file, then install it by:"
            echo " $ sudo dpkg -i $file"
            echo "2. clone repo: https://github.com/dj-zhou/usb-wifi-driver, and install driver:"
            echo " $ cd usb-wifi-driver/rtl8812au/"
            echo " $ make"
            echo " $ sudo make install"
            return
        fi
        echo -e "rtl8812au driver is only tested on Ubuntu 20.04 LTS (x86_64), exit"
        return
    fi
}

# =============================================================================
function _dj_setup_driver() {
    if [ $1 = 'wifi' ]; then
        _dj_setup_driver_wifi $2 $3 $4 $5
        return
    fi
}

# =============================================================================
function _dj_setup_dropbox() {
    _pushd_quiet ${PWD}

    sudo apt-get --fix-broken install
    _install_if_not_installed libpango1.0-0
    _install_if_not_installed curl

    cd ~ && mkdir -p soft/ && cd soft/

    curl -L \
        https://linux.dropbox.com/packages/ubuntu/dropbox_2020.03.04_amd64.deb \
        >dropbox.deb
    sudo dpkg -i dropbox.deb

    echo -e "You can run the following command to setup the Dropbox"
    echo -e "   dropbox start -i\n"

    _popd_quiet
}

# =============================================================================
# Install a version from its source code
function _dj_setup_eigen3() {
    _pushd_quiet ${PWD}

    eigen3_v=$(_find_package_version eigen3)
    _echo_install eigen3 $eigen3_v
    _press_enter_or_wait_s_continue 5

    sudo rm -rf /usr/local/include/eigen3
    sudo rm -rf /usr/include/eigen3

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf eigen*
    wget https://gitlab.com/libeigen/eigen/-/archive/$eigen3_v/eigen-$eigen3_v.tar.gz
    tar -xvf eigen-$eigen3_v.tar.gz

    cd eigen-$eigen3_v
    mkdir build && cd build && cmake ..
    make -j$(nproc) && sudo make install

    # just to prevent compiling error in the future
    sudo cp /usr/local/include/eigen3/ -r /usr/include/

    echo -e "\n${GRN}eigen3 $eigen3_v${NOC} is installed."
    _verify_header_files /usr/include/eigen3
    _verify_header_files /usr/local/include/eigen3

    _popd_quiet
}

# =============================================================================
function _dj_setup_flamegraph() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    _dj_setup_perf

    rm -rf FlameGraph
    git clone https://github.com/brendangregg/FlameGraph.git
    sudo cp -r FlameGraph /usr/local/bin/ # OK, I know, this is not good

    # create symbolic link
    sudo rm -f /usr/bin/stackcollapse-perf.pl
    sudo rm -f /usr/bin/flamegraph.pl
    sudo ln -s /usr/local/bin/FlameGraph/stackcollapse-perf.pl /usr/bin/stackcollapse-perf.pl
    sudo ln -s /usr/local/bin/FlameGraph/flamegraph.pl /usr/bin/flamegraph.pl

    cat <<eom
--------------------------------------------
FlameGraph is installed, use it by:
  $ dj flame-graph [perf.data]
# a "perf.svg" file will be generated
--------------------------------------------
eom

    _popd_quiet
}
# =============================================================================
# example code: packages/fmt; /packages/spdlog
function _dj_setup_fmt() {
    _pushd_quiet ${PWD}

    if [ $# -eq 0 ]; then
        fmt_v=$(_find_package_version fmt)
    else
        fmt_v=$1
    fi

    _echo_install fmt $fmt_v
    _press_enter_or_wait_s_continue 5

    # remove first ------------------
    sudo rm -rf /usr/local/lib/libfmt.a
    sudo rm -rf /usr/local/include/fmt/
    sudo rm -rf /usr/local/lib/pkgconfig/fmt.pc
    sudo rm -rf /usr/local/lib/cmake/fmt/

    # --------------------
    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf fmt
    git clone https://github.com/fmtlib/fmt.git
    cd fmt
    git checkout ${fmt_v}
    rm -rf build && mkdir build && cd build
    cmake .. -DBUILD_SHARED_LIBS=TRUE -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE
    make -j$(nproc)
    sudo make install

    echo -e "\n${GRN}fmt $fmt_v${NOC} is installed."

    # _verify_lib_installation libfmt.a /usr/local/lib
    _verify_lib_installation libfmt.so /usr/local/lib
    _verify_header_files /usr/local/include/fmt
    _verify_pkgconfig_file fmt.pc /usr/local/lib/pkgconfig
    _verify_cmake_files fmt-config.cmake /usr/local/lib/cmake/fmt

    _popd_quiet
}

# =============================================================================
function _dj_setup_foxit_reader() {
    _pushd_quiet ${PWD}

    echo -e "install Foxit Reader ..."
    echo -e "  recommended location: /opt/foxitsoftware/foxitreader\n"
    _press_enter_or_wait_s_continue 10

    cd ~ && mkdir -p soft/ && cd soft/

    # no way to get the latest version?
    file=FoxitReader.enu.setup.2.4.4.0911.x64.run
    url="http://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/"
    url=${url}linux/2.x/2.4/en_us/$file.tar.gz
    _wget_if_not_exist $file.tar.gz "22d2553945edc0af9dbd52dd4a2cee22" ${url}
    gzip -d $file.tar.gz
    tar xvf $file.tar
    sudo ./FoxitReader*.run

    # create a symbolic link
    foxit_reader_location=$(sudo find /opt -name "FoxitReader")
    echo $foxit_reader_location
    if [[ ! -z "$foxit_reader_location" ]]; then
        echo 'a symbolic link "foxit" is generated in /usr/bin'
        sudo ln -sf $foxit_reader_location /usr/bin/foxit
    else
        echo -e "FoxitReader not installed into a recommended location"
        echo -e "a symbolic link cannot be generated\n"
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_fsm_pro() {
    _pushd_quiet ${PWD}
    cd ~ && mkdir -p soft/ && cd soft/

    wget https://www.fsmpro.io/downloads/FsmPro.deb
    sudo dpkg -i FsmPro.deb

    echo "reference: https://www.fsmpro.io/"

    _popd_quiet
}

# =============================================================================
function _dj_setup_gcc_aarch64_linux() {
    _pushd_quiet ${PWD}

    echo -e "install gcc-aarch64-linux-gnu ...\n"
    _press_enter_or_wait_s_continue 10
    # common
    _install_if_not_installed libssl-dev # needed for compiling the Linux Kernel for ARMv8
    _install_if_not_installed gcc-aarch64-linux-gnu
    _install_if_not_installed g++-aarch64-linux-gnu

    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        _install_if_not_installed gcc-5-aarch64-linux-gnu
        _install_if_not_installed gcc-5-aarch64-linux-gnu
    else
        echo "do nothing at this moment"
    fi

    # update-alternatives configuration
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        sudo update-alternatives --install \
            /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc \
            /usr/bin/aarch64-linux-gnu-gcc-5 5
        sudo update-alternatives --install \
            /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc \
            /usr/bin/aarch64-linux-gnu-gcc-7 7

        echo -e "\n-------------------\n"
        sudo update-alternatives --config aarch64-linux-gnu-gcc
    fi

    _popd_quiet
}

# =============================================================================
# for Ubuntu 20.04:
# https://askubuntu.com/questions/1243252/how-to-install-arm-none-eabi-gdb-on-ubuntu-20-04-lts-focal-fossa
function _dj_setup_gcc_arm_stm32() {
    _pushd_quiet ${PWD}

    echo -e "remove ${RED}gcc-arm-none-eabi${NOC}, and install ${GRN}gcc-arm-embedded${NOC} ...\n"
    _press_enter_or_wait_s_continue 10

    cd ~ && mkdir -p soft/ && cd soft/
    packages="build-essential git flex bison libgmp3-dev libmpfr-dev "
    packages+="libncurses5-dev libmpc-dev autoconf texinfo libtool "
    packages+="libftdi-dev libusb-1.0-0-dev zlib1g zlib1g-dev python-yaml "
    packages+="libncurses-dev "
    _install_if_not_installed $packages

    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        # sudo echo "deb http://kr.archive.ubuntu.com/ubuntu bionic main universe" \
        # | sudo tee -a /etc/apt/sources.list
        sudo rm -rf /etc/apt/sources.list.d/gcc-arm-stm32.list
        sudo sh -c 'echo "deb http://kr.archive.ubuntu.com/ubuntu bionic main universe" \
            >> /etc/apt/sources.list.d/gcc-arm-stm32.list'
    elif [[ "${ubuntu_v}" = *'16.04'* ]]; then
        echo "just do nothing"
    fi
    if [[ "${ubuntu_v}" = *'18.04'* ||
        "${ubuntu_v}" = *'16.04'* ]]; then
        sudo apt-get remove gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi
        sudo apt-add-repository ppa:team-gcc-arm-embedded/ppa
        sudo apt-get update
        _install_if_not_installed gcc-arm-embedded

        echo -e "\n"
        echo " (just maybe) gcc-arm-embedded is installed in /usr/share/gcc-arm-embedded/"
        echo " (question) Is there still an arm-none-eabi? "
        echo -e "\n"
    elif [[ "${ubuntu_v}" = *'20.04'* ]]; then
        sudo apt remove gcc-arm-none-eabi
        file="gcc-arm-none-eabi-10.3-2021.10"
        filename="${file}-x86_64-linux.tar.bz2"
        url="https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm"
        link="${url}/10.3-2021.10/${filename}"

        # check if the file exists --------------------
        _wget_if_not_exist $filename "2383e4eb4ea23f248d33adc70dc3227e" ${link}

        echo "sudo tar xjf ${filename} -C /usr/share/"
        sudo tar xjf ${filename} -C /usr/share/

        echo -e "create symbolic links\n"
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-ar /usr/bin/arm-none-eabi-ar
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-gcc /usr/bin/arm-none-eabi-gcc
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-g++ /usr/bin/arm-none-eabi-g++
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-gdb /usr/bin/arm-none-eabi-gdb
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-objcopy /usr/bin/arm-none-eabi-objcopy
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-size /usr/bin/arm-none-eabi-size
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_gcc_arm_linux_gnueabi() {
    _pushd_quiet ${PWD}

    echo -e "install gcc-arm-linux-gnueabi ..."
    _press_enter_or_wait_s_continue 10
    _install_if_not_installed libncurses5-dev
    _install_if_not_installed build-essential
    # commonly available
    # on Ubuntu 18.04, they are of 7.3.0 version (probably)
    # on Ubuntu 20.04, they are of 9.3.0 version
    _install_if_not_installed gcc-arm-linux-gnueabi
    _install_if_not_installed g++-arm-linux-gnueabi
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        _install_if_not_installed gcc-5-arm-linux-gnueabi
        _install_if_not_installed g++-5-arm-linux-gnueabi
    else
        echo "do nothing at this moment"
    fi
    # update-alternatives configuration

    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        sudo update-alternatives --install \
            /usr/bin/arm-linux-gnueabi-gcc arm-linux-gnueabi-gcc \
            /usr/bin/arm-linux-gnueabi-gcc-5 5
        sudo update-alternatives --install \
            /usr/bin/arm-linux-gnueabi-gcc arm-linux-gnueabi-gcc \
            /usr/bin/arm-linux-gnueabi-gcc-7 7
        sudo update-alternatives --install \
            /usr/bin/arm-linux-gnueabi-g++ arm-linux-gnueabi-g++ \
            /usr/bin/arm-linux-gnueabi-g++-5 5
        sudo update-alternatives --install \
            /usr/bin/arm-linux-gnueabi-g++ arm-linux-gnueabi-g++ \
            /usr/bin/arm-linux-gnueabi-g++-7 7

        echo -e "\n-------------------\n"
        sudo update-alternatives --config arm-linux-gnueabi-gcc
        sudo update-alternatives --config arm-linux-gnueabi-g++
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_gcc_arm_linux_gnueabihf() {
    _pushd_quiet ${PWD}

    echo -e "install gcc-arm-linux-gnueabihf ..."
    _press_enter_or_wait_s_continue 10
    _install_if_not_installed libncurses5-dev
    _install_if_not_installed build-essential

    # commom ones
    _install_if_not_installed gcc-arm-linux-gnueabihf
    _install_if_not_installed g++-arm-linux-gnueabihf
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        _install_if_not_installed gcc-5-arm-linux-gnueabihf
        _install_if_not_installed g++-5-arm-linux-gnueabihf
    else
        echo "do nothing at this moment"
    fi
    # update-alternatives configuration
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        sudo update-alternatives --install \
            /usr/bin/arm-linux-gnueabihf-gcc arm-linux-gnueabihf-gcc \
            /usr/bin/arm-linux-gnueabihf-gcc-5 5
        sudo update-alternatives --install \
            /usr/bin/arm-linux-gnueabihf-gcc arm-linux-gnueabihf-gcc \
            /usr/bin/arm-linux-gnueabihf-gcc-7 7
        sudo update-alternatives --install \
            /usr/bin/arm-linux-gnueabihf-g++ arm-linux-gnueabihf-g++ \
            /usr/bin/arm-linux-gnueabihf-g++-5 5
        sudo update-alternatives --install \
            /usr/bin/arm-linux-gnueabihf-g++ arm-linux-gnueabihf-g++ \
            /usr/bin/arm-linux-gnueabihf-g++-7 7

        echo -e "\n-------------------\n"
        sudo update-alternatives --config arm-linux-gnueabihf-gcc
        sudo update-alternatives --config arm-linux-gnueabihf-g++
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_git_lfs() {
    _pushd_quiet ${PWD}
    curl -s \
        https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh |
        sudo bash
    _install_if_not_installed git-lfs

    _popd_quiet
}

# =============================================================================
function _dj_setup_gitg_gitk() {
    _pushd_quiet ${PWD}

    echo -e "install gitg and gitk ..."
    _press_enter_or_wait_s_continue 10 # to check the key pressed TODO
    _install_if_not_installed gitg
    _install_if_not_installed gitk
    git config --global credential.helper store
    # git config --global credential.helper 'cache --timeout=36000'

    _popd_quiet
}

# =============================================================================
# make sure the related package is public available in dj-zhou's github
function _dj_setup_i219_v() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    git clone https://dj-zhou@github.com/dj-zhou/i219-v.git
    cd i219-v/$1/src/
    sudo make install

    cd ~/soft/

    _ask_to_execute_cmd "sudo reboot"

    _popd_quiet
}

# =============================================================================
function _dj_setup_lcm() {
    _pushd_quiet ${PWD}

    if [[ ! "${ubuntu_v}" = *'20.04'* ]] && [[ ! "${ubuntu_v}" = *'18.04'* ]]; then
        echo "lcm installation is only tested within Ubuntu 20.04/18.04"
        return
    fi

    _install_if_not_installed default-jdk

    v=$(_find_package_version lcm)
    _echo_install lcm $v

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf lcm
    git clone https://github.com/lcm-proj/lcm.git
    cd lcm
    git checkout $v
    mkdir build && cd build
    cmake ..
    make -j$(nproc)
    sudo make install
    sudo ldconfig

    echo "lcm $v is installed."
    _verify_lib_installation liblcm.so /usr/local/lib
    _verify_header_files /usr/local/include/lcm/
    _verify_pkgconfig_file lcm-java.pc /usr/local/lib/pkgconfig

    _popd_quiet
}

# =============================================================================
function _dj_setup_libbpf() {
    _pushd_quiet ${PWD}

    _install_if_not_installed libelf-dev

    v=$(_find_package_version libbpf)
    _echo_install libbpf $v

    _show_and_run cd ~ && mkdir -p soft/ && cd soft/
    _show_and_run rm -rf libbpf
    _show_and_run git clone https://github.com/libbpf/libbpf.git
    _show_and_run cd libbpf
    _show_and_run git checkout $v

    _show_and_run cd src
    _show_and_run make -j$(nproc)
    _show_and_run mkdir build root
    BUILD_STATIC_ONLY=y OBJDIR=build DESTDIR=root make install

    _show_and_run cd root/usr/
    _show_and_run sudo cp -r include/* /usr/include/
    _show_and_run sudo cp lib64/* -r /usr/lib/

    _popd_quiet
}

# =============================================================================
function _dj_setup_libcsv_3_0_2() {
    _pushd_quiet ${PWD}
    cd ~ && mkdir -p soft/ && cd soft/

    rm -rf libcsv-3.0.2
    git clone https://github.com/dj-zhou/libcsv-3.0.2
    # the master branch is of version 3.0.2
    cd libcsv-3.0.2
    ./configure
    make check
    sudo make install

    cat <<eom
--------------------------------------------
libcsv
    /usr/local/lib/libcsv.a
    /usr/local/lib/libcsv.la
    /usr/local/lib/libcsv.so
    /usr/local/lib/libcsv.so.3
    /usr/local/lib/libcsv.so.3.0.2

header file:
    /usr/local/include/csv.h
--------------------------------------------
eom

    _popd_quiet
}

# =============================================================================
# libev can also be installed by
# $ _install_if_not_installed libev-dev
# however, it is the v4.22 to be installed, and the installation location is
#   /usr/lib/x86_64-linux-gnu/
# install from the source, will have the libev installed into
#  /usr/local/lib
# this setup works only for the host computer, don't know how to do it for
# cross compilers
function _dj_setup_libev() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    v=$(_find_package_version libev)
    _echo_install libev $v
    _press_enter_or_wait_s_continue 5

    file="libev-$v"
    wget http://dist.schmorp.de/libev/$file.tar.gz
    tar -zxf $file.tar.gz
    cd $file
    ./configure
    make
    sudo make install

    # check for the LD_LIBRARY_PATH
    # if it is not set for libev, then set it
    result=$(echo $LD_LIBRARY_PATH)
    if [[ "$result" = *"/usr/local/lib"* ]]; then
        echo "LD_LIBRARY_PATH is already set, no need to set it again"
    else
        echo "LD_LIBRARY_PATH is not set, set it now"
        echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >>~/.bashrc
    fi

    echo -e "\n${GRN}libev $v${NOC} is installed."
    _verify_lib_installation libev.so /usr/local/lib/
    _verify_lib_installation libev.a /usr/local/lib/

    cd ~/soft

    _popd_quiet
}

# =============================================================================
function _dj_setup_libgpiod() {
    _pushd_quiet ${PWD}
    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf libgpiod*

    libgpiod_v=$(_find_package_version libgpiod)

    _echo_install libgpiod $libgpiod_v
    _press_enter_or_wait_s_continue 5
    _
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        file_name=libgpiod-$libgpiod_v
        link="https://mirrors.edge.kernel.org/pub/software/"
        link="${link}libs/libgpiod/$file_name.tar.gz"

        wget $link
        tar -xvf $file_name.tar.gz

        # install -------------
        cd $file_name
        ./configure
        make -j$(nproc)
        sudo make install

    elif [[ "${ubuntu_v}" = *'20.04'* ]]; then
        _install_if_not_installed autoconf-archive

        rm libgpiod -rf
        git clone git://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
        cd libgpiod
        git checkout $libgpiod_v
        ./autogen.sh --enable-tools=yes
        make -j$(nproc)
        sudo make install

        _verify_lib_installation libgpiod.so /usr/local/lib
        _verify_pkgconfig_file libgpiod.pc /usr/local/lib/pkgconfig
        _verify_lib_installation gpiod.h /usr/local/include
    else
        echo "_dj_setup_libgpiod: todo"
        return
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_libiio() {
    _pushd_quiet ${PWD}
    # install some software
    _install_if_not_installed bison flex libxml2-dev

    v=$(_find_package_version libiio)
    _echo_install libiio $v

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf libiio
    git clone https://github.com/analogdevicesinc/libiio.git
    cd libiio
    if [[ "${ubuntu_v}" = *'18.04'* ||
        "${ubuntu_v}" = *'20.04'* ]]; then
        git checkout $v
    else
        echo -e "\n${YLW} TO BE IMPLEMENTED${NOC}\n"
        return
    fi

    mkdir build && cd build && cmake ..
    make -j$(nproc)
    sudo make install

    _verify_lib_installation /libiio.so /usr/lib/x86_64-linux-gnu/
    _verify_lib_installation iio_info /usr/bin/
    _verify_lib_installation iiod /usr/sbin/
    _verify_pkgconfig_file libiio.pc /usr/lib/x86_64-linux-gnu/pkgconfig/

    echo "iio.h is installed to /usr/include/"

    _popd_quiet
}

# =============================================================================
function _dj_setup_libserialport() {
    pushd "${PWD}" &>/dev/null

    cd ~ && mkdir -p soft/ && cd soft/

    v=$(_find_package_version libserialport)
    _echo_install libserialport $v
    _press_enter_or_wait_s_continue 5

    rm -rf libserialport/
    git clone git://sigrok.org/libserialport.git

    cd libserialport
    ./autogen.sh
    ./configure
    make -j4 && sudo make install

    # check if library installed correctly
    _verify_lib_installation libserialport.a /usr/local/lib/
    _verify_lib_installation libserialport.la /usr/local/lib/
    _verify_lib_installation libserialport.so /usr/local/lib/
    _verify_pkgconfig_file libserialport.pc /usr/local/lib/pkgconfig
    _verify_header_files libserialport.h /usr/local/include

    popd &>/dev/null
}

# =============================================================================
function _dj_setup_libsystemd() {
    _pushd_quiet ${PWD}

    _install_if_not_installed libmount-dev libcap-dev
    systemd_v=$(_find_package_version libsystemd)

    if [[ "${ubuntu_v}" = *'18.04'* ]] && [[ "${systemd_v}" = *'248'* ]]; then
        echo "just do not install it, it will break your system!"
        return
    fi
    echo -e "install ${GRN}libsystemd $systemd_v${NOC}"

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf systemd/
    git clone git@github.com:systemd/systemd.git
    cd systemd
    git checkout $systemd_v

    ./configure
    make -j$nproc
    sudo make install

    _verify_lib_installation libsystemd.so /x86_64-linux-gnu
    _verify_pkgconfig_file libsystemd.pc /usr/lib/x86_64-linux-gnu/pkgconfig

    _popd_quiet
}

# =============================================================================
function _dj_setup_mathpix() {
    _install_if_not_installed snapd
    sudo snap install mathpix-snipping-tool
}

# =============================================================================
# this might need a higher version of g++ to compile (>= 9.3?)
function _dj_setup_matplot_xx() {
    _pushd_quiet ${PWD}

    static_shared=$1

    v=$(_find_package_version matplotplusplus)
    _echo_install matplot++ $v
    _press_enter_or_wait_s_continue 5

    # dependency ------
    _install_if_not_installed gnuplot
    _install_if_not_installed libfftw3-dev

    # removed previously installed files ------
    sudo rm -f /usr/local/lib/Matplot++/libnodesoup.a
    sudo rm -f /usr/local/lib/libmatplot.a
    sudo rm -f /usr/local/lib/libmatplot.so
    sudo rm -rf /usr/local/include/matplot
    sudo rm -rf /usr/local/lib/cmake/Matplot++

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf matplotplusplus
    git clone https://github.com/alandefreitas/matplotplusplus.git
    cd matplotplusplus
    git checkout $v

    # compile and install ------
    mkdir build && cd build
    if [ "$static_shared" = 'static' ]; then
        cmake .. -DBUILD_SHARED_LIBS=OFF
    else
        cmake .. -DBUILD_SHARED_LIBS=ON
    fi
    make -j$(nproc)
    sudo make install
    sudo ldconfig
    if [ "$static_shared" = 'static' ]; then
        _verify_header_files /usr/local/include/matplot/
        _verify_lib_installation libmatplot.a /usr/local/lib/
        _verify_lib_installation libnodesoup.a /usr/local/lib/Matplot++/

    else
        _verify_header_files /usr/local/include/matplot/
        _verify_lib_installation libmatplot.so /usr/local/lib/
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_magic_enum() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft/ && cd soft/ && rm magic_enum -rf

    ver=$(_find_package_version magic-enum)
    git clone https://github.com/Neargye/magic_enum
    cd magic_enum
    git checkout $ver
    sudo cp include/magic_enum.hpp /usr/local/include/

    echo -e "${GRN}magic_enum $ver${NOC} is installed:"
    _verify_header_files magic_enum.hpp /usr/local/include/
    head -n 8 /usr/local/include/magic_enum.hpp

    _popd_quiet
}

# =============================================================================
# testing on Ubuntu 18.04
function _dj_setup_mbed() {
    _pushd_quiet ${PWD}

    _install_if_not_installed mercurial git
    # install mbed-cli
    python3 -m pip install mbed-cli
    cat <<eom
--------------------------------------------
to check if mbed CLI installed correctly:
  $ mbed --help
to upgrade mbed CLI:
  $ python3 -m pip install -U mbed-cli
--------------------------------------------
eom
    _press_enter_to_continue 10
    # install bash-completion for mbed
    cd ~ && mkdir -p soft/ && cd soft/ && rm mbed-cli -rf
    git clone https://github.com/ARMmbed/mbed-cli
    cd mbed-cli/tools/bash_completion
    sudo cp mbed /usr/share/bash-completion/completions/
    cat <<eom
--------------------------------------------
mbed tab-completion is installed to
    /usr/share/bash-completion/completions/mbed
--------------------------------------------
eom
    _press_enter_to_continue 10

    # install mbed-studio
    cd ~ && mkdir -p soft/ && cd soft/
    wget https://studio.mbed.com/installers/latest/linux/MbedStudio.sh
    chmod +x MbedStudio.sh
    ./MbedStudio.sh
    # reading the long license, is there a way to jump it?

    # install some python moudles
    python3 -m pip install jsonschema
    python3 -m pip install mbed_cloud_sdk
    python3 -m pip install mbed_ls
    python3 -m pip install mbed_host_tests
    python3 -m pip install mbed_greentea
    python3 -m pip install manifest_tool
    python3 -m pip install icetea
    python3 -m pip install pycryptodome
    python3 -m pip install cryptography

    _popd_quiet
}

# =============================================================================
# testing
function _dj_setup_meson_ninjia() {
    meson_v=$(_find_package_version meson)
    ninja_v=$(_find_package_version ninja)
    # sanity check
    cmake_v=$(version check cmake)
    anw=$(_version_if_ge_than "$cmake_v" "3.20")
    if [ "$anw" = "no" ]; then
        echo "cmake needs to be 3.20 or higher version, exit."
        return
    fi
    python3_v=$(version check python3)
    anw=$(_version_if_ge_than "$python3_v" "3.7")
    if [[ "$anw" = "yes" ]]; then
        echo "I failed to use python3>3.6 to install meson v$meson_v."
        return
    fi
    _echo_install meson $meson_v
    _press_enter_or_wait_s_continue 5
    # remove /usr/bin/meson
    sudo apt-get remove meson &>/dev/null

    # install needed software
    _install_if_not_installed python3

    # meson release: https://github.com/mesonbuild/meson/releases
    python3 -m pip install meson==$meson_v

    # make sure ~/.local/bin is in the PATH variable
    # but not sure if it is in it for new installed Ubuntu ... will check

    meson_path=$(grep "PATH:~/.local/bin" ~/.bashrc)
    if [ ! -z "$meson_path" ]; then
        echo -e "${GRN}meson ${NOC}path was set in ~/.bashrc"
    else
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) meson path setup' >>~/.bashrc
        echo -e 'export PATH=$PATH:~/.local/bin\n' >>~/.bashrc
    fi
    echo -e "${GRN}meson${NOC} is installed to ${GRN}~/.local/bin${NOC}"

    # ---------------------------------------------
    _echo_install ninja $ninja_v
    _press_enter_or_wait_s_continue 5
    # ninja is needed for meson, so install it as well

    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf ninja
    git clone https://github.com/ninja-build/ninja.git && cd ninja
    git checkout v$ninja_v
    mkdir build && cd build
    cmake ..
    make -j$(nproc)
    sudo make install
    echo -e "${GRN}meson${NOC} is installed to ${GRN}/usr/local/bin${NOC}"

    _popd_quiet
}

# =============================================================================
# reference: https://andyfelong.com/2020/10/mongodb-4-4-ubuntu-20-04-on-raspberry-pi-4/
# problem: if libyaml-cpp is installed first (0.6.3), then it cannot install
# mongodb, don't know why
function _dj_setup_mongodb() {
    sudo apt-get update -y
    uname_a=$(uname -a)
    if [[ "${ubuntu_v}" = *'20.04'* ]]; then
        # install v4.4 on x86 and aarch64 system
        wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
        if [[ "${uname_a}" = *'aarch64'* ]]; then
            echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" |
                sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
        elif [[ "${uname_a}" = *'x86_64'* ]]; then
            echo "deb [ arch=amd64] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" |
                sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
        fi

        # install
        sudo apt-get -y update
        _install_if_not_installed mongodb-org

        # Enable and start MongoDB Deamon program
        sudo systemctl enable --now mongod

        cat <<eom
--------------------------------------------
MongoDB istall:
    mongodb-org-server - mongodb守护程序以及相应的初始化脚本和配置
    mongodb-org-mongos - mongos守护程序
    mongodb-org-shell  - mongo shell，它是MongoDB的交互式JavaScript接口。
                         它用于执行命令行中的管理任务。
    mongodb-org-tools  - 包含几个用于导入和导出数据，统计信息以及其他实用程序的MongoDB工具

Enable and start MongoDB Deamon program:
    $ sudo systemctl enable --now mongod
    $ sudo systemctl start mongod

Check if MongoDB is running:
    $ sudo service mongod status

Check if MongoDB is installed:
    $ mongo --eval 'db.runCommand({ connectionStatus: 1 })'
--------------------------------------------
eom
    else
        echo -e "\n${YLW} TO BE IMPLEMENTED${NOC}\n"
        return
    fi
}

# =============================================================================

function _dj_stup_network_tools() {
    echo -e "install ${GRN}nethogs${NOC}, ${GRN}iptraf${NOC}"
    _install_if_not_installed nethogs iptraf

    echo -e "install ${GRN}mNet-Assist${NOC}"
    _pushd_quiet ${PWD}
    cd ~ && mkdir -p soft && cd soft
    rm -rf m-net-assist
    git clone https://github.com/dj-zhou/m-net-assist.git
    cd m-net-assist
    # does it support new Ubuntu system?
    sudo dpkg -i mNetAssist-release-amd64.deb

    _popd_quiet
}

# =============================================================================
function _dj_setup_nlohmann_json3_dev() {
    _pushd_quiet ${PWD}

    v=$(_find_package_version nlohmann-json3)
    _echo_install nlohmann-json3 $v
    _press_enter_or_wait_s_continue 5

    # Ubuntu 18.04
    # due to an error: ImportError: No module named apt_pkg
    # I need to use Python3.6 to use the add-apt-repository command
    python3_v=$(version check python3)
    anw=$(_version_if_ge_than $python3_v "3.7")
    # did not try it on Ubuntu 20.04
    if [[ "$anw" = 'yes' && "${ubuntu_v}" = *'18.04'* ]]; then
        echo "Python3 should be of v3.6 to continue."
        return
    fi

    # install from source

    cd ~ && mkdir -p soft/ && cd soft/

    rm json -rf
    git clone https://github.com/nlohmann/json.git
    cd json
    git checkout $v
    rm build -rf && mkdir build && cd build
    cmake ..
    make -j$(nproc)
    sudo make install

    _popd_quiet

    echo -e "${GRN}nlohmann-json3 $v${NOC} is installed:"
    _verify_header_files json.hpp /usr/local/include/nlohmann
    _verify_cmake_files nlohmann_jsonConfig.cmake /usr/local/lib/cmake/nlohmann_json
    _verify_pkgconfig_file nlohmann_json.pc /usr/local/lib/pkgconfig
}

# =============================================================================
# use nvm (node version management) to install nodejs
# https://github.com/nvm-sh/nvm#installing-and-updating
function _dj_setup_nodejs() {
    # _pushd_quiet ${PWD}
    # cd ~ && mkdir -p soft/ && cd soft/

    # # install nvm to ${HOME}/.nvm -----------
    # if [ ! -d ${HOME}/.nvm ]; then
    #     nvm_v=$(_find_package_version nvm)
    #     _echo_install nvm $nvm_v
    #     _press_enter_or_wait_s_continue 2

    #     curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_v/install.sh | bash
    #     export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" ||
    #         printf %s "${XDG_CONFIG_HOME}/nvm")"
    #     [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # fi
    # # install nodejs -----------
    # nodejs_v=$(_find_package_version nodejs)
    # _echo_install nodejs $nodejs_v
    # _press_enter_or_wait_s_continue 2

    # nvm install $nodejs_v

    # _popd_quiet

    # https://stackoverflow.com/a/36401038
    if [[ "${ubuntu_v}" = *'18.04'* || "${ubuntu_v}" = *'20.04'* ]]; then
        _install_if_not_installed git-core curl build-essential openssl libssl-dev
        _pushd_quiet ${PWD}
        cd ~ && mkdir -p soft/ && cd soft/

        v=$(_find_package_version nodejs)
        # nodejs is a huge package, do not build it from scratch
        if [[ ! -d node ]]; then
            git clone https://github.com/nodejs/node.git
            cd node
        else
            cd node
            git checkout master
            git fetch -p
            git pull
        fi
        git checkout v$v
        ./configure
        make -j$(nproc) && sudo make install

        _popd_quiet
        return
    fi
}

# =============================================================================
# this may only work on desktop computer
# nvidia-driver-455 is good at time of this commit
function _dj_setup_nvidia() {
    sudo apt-get purge nvidia*
    _install_if_not_installed libncurses5-dev
    if [[ "${ubuntu_v}" = *'18.04'* ||
        "${ubuntu_v}" = *'20.04'* ]]; then
        if [[ ! -f /etc/apt/sources.list.d/graphics-drivers*.list ]]; then
            sudo add-apt-repository ppa:graphics-drivers/ppa
            sudo apt-get -y update
        fi
        _install_if_not_installed nvidia-driver-455 nvidia-settings
    fi
    cat <<eom

--------------------------------------------
Now you need to reboot the computer
and you can run:
  $ nvidia-smi
or
  $ cat /proc/driver/nvidia/gpus/{tab}/information
--------------------------------------------

eom
}

# =============================================================================
function _dj_setup_nvtop() {
    _pushd_quiet ${PWD}

    if [[ "${ubuntu_v}" = *'18.04'* ||
        "${ubuntu_v}" = *'20.04'* ]]; then
        cd ~ && mkdir -p soft/ && cd soft/
        rm nvtop -rf
        git clone https://github.com/Syllo/nvtop.git
        cd nvtop
        mkdir build && cd build
        cmake .. -DNVML_RETRIEVE_HEADER_ONLINE=True
        make -j$(nproc)
        sudo make install
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_qt_5_13_1() {
    _pushd_quiet ${PWD}

    echo -e "install Qt 5.13.1 \n"

    # install serialport module
    _install_if_not_installed libqt5serialport5-dev

    cd ~ && mkdir -p soft/ && cd soft/

    # check if the file exists --------------------
    filename="qt-opensource-linux-x64-5.13.1.run"
    url=http://qt.mirror.constant.com/archive/qt/5.13/5.13.1/$filename
    _wget_if_not_exist $filename "21c3b16f851697fa8da8009f73694373" $url
    chmod +x $filename

    echo -e "It is recommended to install the Qt into ${HOME}/Qt5.13.1/"
    _press_enter_or_wait_s_continue 10

    ./$filename

    # setup the PATH and LD_LIBRARY_PATH into ~/.bashrc
    echo -e '\n' >>~/.bashrc
    echo '# ===========================================================' >>~/.bashrc
    echo '# Qt5.13.1 setup (djtools)' >>~/.bashrc
    echo 'export PATH=~/Qt5.13.1/5.13.1/gcc_64/bin:$PATH' >>~/.bashrc
    echo 'export LD_LIBRARY_PATH=~/Qt5.13.1/5.13.1/gcc_64/lib:$LD_LIBRARY_PATH' >>~/.bashrc
    echo -e "PATH and LD_LIBRARY_PATH are set in ~/.bashrc.\n"

    _popd_quiet
}

# =============================================================================
function _dj_setup_qt_5_14_2() {
    _pushd_quiet ${PWD}

    echo -e "\nInstall Qt 5.14.2\n"
    _press_enter_or_wait_s_continue 10

    # install serialport module
    _install_if_not_installed libqt5serialport5-dev

    cd ~ && mkdir -p soft/ && cd soft/

    # check if the file exists --------------------
    filename="qt-opensource-linux-x64-5.14.2.run"
    url=http://qt.mirror.constant.com/archive/qt/5.14/5.14.2/$filename
    _wget_if_not_exist $filename "dce0588874fd369ce493ea5bc2a21d99" $url
    chmod +x $filename

    echo -e "It is recommended to install the Qt into ${HOME}/Qt5.14.2/"
    _press_enter_or_wait_s_continue 20

    ./$filename

    # setup the PATH and LD_LIBRARY_PATH into ~/.bashrc
    echo -e '\n' >>~/.bashrc
    echo '# ===========================================================' >>~/.bashrc
    echo '# Qt5.14.2 setup (djtools)' >>~/.bashrc
    echo 'export PATH=~/Qt5.14.2/5.14.2/gcc_64/bin:$PATH' >>~/.bashrc
    echo 'export LD_LIBRARY_PATH=~/Qt5.14.2/5.14.2/gcc_64/lib:$LD_LIBRARY_PATH' >>~/.bashrc
    echo -e "PATH and LD_LIBRARY_PATH are set in ~/.bashrc.\n"

    _popd_quiet
}

# =============================================================================
function _dj_setup_rpi_pico() {
    _pushd_quiet ${PWD}

    # install dependencies
    _install_if_not_installed libnewlib-arm-none-eabi \
        libstdc++-arm-none-eabi-newlib \
        build-essential

    # make sure cmake is greater than v3.13
    cmake_v=$(version check cmake)
    anw=$(_version_if_ge_than $cmake_v 3.13.0)
    if [ "$anw" = 'no' ]; then
        dj setup cmake
    fi

    cd ~ && mkdir -p rpi-pico && cd rpi-pico
    # setup sdk
    v=$(_find_package_version pico-sdk)
    rm -rf pico-sdk
    git clone https://github.com/raspberrypi/pico-sdk.git
    cd pico-sdk
    git checkout $v
    git submodule update --init

    # clone examples
    cd ..
    v=$(_find_package_version pico-examples)
    rm -rf pico-examples
    git clone https://github.com/raspberrypi/pico-examples.git
    cd pico-examples
    git checkout $v

    # setup env

    installed=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"export PICO_SDK_PATH"* ]]; then
            echo -e "pico-sdk has already been setup, exit."
            echo -e "you can still revise ~/.bashrc for manual setup."
            installed=1
        fi
    done <~/.bashrc
    if [[ $installed = '0' ]]; then
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) pico-sdk setup' >>~/.bashrc
        echo "export PICO_SDK_PATH=$HOME/rpi-pico/pico-sdk" >>~/.bashrc
    fi
    # build pico-examples
    export PICO_SDK_PATH=$HOME/rpi-pico/pico-sdk
    mkdir build && cd build && cmake ..
    make -j$(nproc)

    _popd_quiet
    cat <<eom
download the firmware:
1. hold on BOOTSEL button
2. connect Raspberry Pi Pico to the laptop (still hold the BOOTSEL button)
3. $ cd path/to/pico-examples/build/blink
4. $ sudo cp blink.uf2 /media/$(whoami)/RPI-RP2/
5. release BOOTSEL button
6. unplug the USB cable and plug the cable in again

workaround to unplugging and plugging usb cable:
1. connect PIN 30 (RUN) to a RESET button to LOW (OV)
2. press and hold RESET button and then push and hold BOOTSEL button
3. release RESET and then release BOOTSEL button
4. now, the raspberry pi pico is in bootloader mode, we can cp blink.uf2 to it

using swd:
https://www.electronicshub.org/programming-raspberry-pi-pico-with-swd/
eom
}

# =============================================================================
function _dj_setup_slack() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft && cd soft/
    # the download page: https://slack.com/downloads/linux
    wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.8.0-amd64.deb
    sudo dpkg -i slack-desktop*.deb

    _popd_quiet
}

# =============================================================================
function _dj_setup_saleae_logic() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft && cd soft/
    version="1.2.18"
    file="Logic $version (64-bit)"
    url="https://downloads.saleae.com/logic/"
    url="$url$version/$file.zip"
    echo $url
    _wget_if_not_exist "$file.zip" "8c586a272a89019540cc365c82ade451" "$url"
    rm -rf "$file"
    unzip "$file.zip"
    rm -rf logic
    mv "$file" logic
    sudo ln -sf ${HOME}/soft/logic/Logic /usr/bin/logic

    _popd_quiet
}

# =============================================================================
function _dj_setup_serial_console() {
    pushd "${PWD}" &>/dev/null

    _install_if_not_installed cu screen putty screen

    _dj_setup_cutecom
    _dj_setup_picocom

    _dj_help_cu
    _dj_help_screen
    _dj_help_pipocom

    popd &>/dev/null

    _udev_screen_tab_completion
}

# =============================================================================
function _dj_setup_spdlog() { # static/shared
    static_shared=$1          # if empty, treat as dynamic

    v=$(_find_package_version spdlog)
    _pushd_quiet ${PWD}

    _show_and_run sudo rm -f /usr/local/lib/libspdlog.a
    _show_and_run sudo rm -f /usr/local/lib/libspdlog.so*
    _show_and_run sudo rm -rf /usr/local/include/spdlog/
    _show_and_run sudo rm -f /usr/local/lib/pkgconfig/spdlog.pc
    _show_and_run sudo rm -rf /usr/local/lib/cmake/spdlog/

    _echo_install spdlog v$v
    _press_enter_or_wait_s_continue 5

    cd ~ && mkdir -p soft && cd soft/
    rm spdlog -rf

    git clone https://github.com/gabime/spdlog.git
    cd spdlog && git checkout v$v && mkdir build && cd build

    # static build need to be specific
    # if no option found, "shared" is default
    if [ "$static_shared" = 'static' ]; then
        cmake .. -DSPDLOG_BUILD_SHARED="off"
    else
        cmake .. -DSPDLOG_BUILD_SHARED="on"
    fi
    make -j$(nproc)
    sudo make install

    echo -e "\n${GRN}spdlog $version${NOC} is installed."
    if [ "$static_shared" = 'static' ]; then
        _verify_lib_installation libspdlog.a /usr/local/lib
    else
        _verify_lib_installation libspdlog.so /usr/local/lib
    fi
    _verify_header_files spdlog.h /usr/local/include/spdlog
    _verify_pkgconfig_file spdlog.pc /usr/local/lib/pkgconfig
    _verify_cmake_files spdlogConfig.cmake /usr/local/lib/cmake/spdlog

    _popd_quiet
}

# =============================================================================
function _dj_setup_sublime() {
    _pushd_quiet ${PWD}

    sudo apt-get update
    _install_if_not_installed apt-transport-https ca-certificates curl
    _install_if_not_installed software-properties-common

    curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"

    sudo apt-get update
    _install_if_not_installed sublime-text

    _popd_quiet
}

# =============================================================================
function _dj_setup_texlive() {
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        list_file="jonathonf-ubuntu-texlive-2019-bionic.list"
        if ! [ -f "/etc/apt/sources.list.d/$list_file" ]; then
            sudo add-apt-repository ppa:jonathonf/texlive-2019
        fi
    fi
    sudo apt-get update
    sudo apt-get install texlive-full texlive-latex-extra texlive-latex-recommended
}

# =============================================================================
function _dj_setup_tldr() {
    _install_if_not_installed tldr
    echo "example: $ tldr tar"
}

# =============================================================================
# why this does not work with python3.9?
function _dj_setup_typora() {
    wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
    # add Typora's repository
    sudo add-apt-repository 'deb https://typora.io/linux ./'
    sudo apt-get -y update
    # install typora
    _install_if_not_installed typora
}

# =============================================================================
# tested: Ubuntu 18.04, Ubuntu 20.04
function _dj_setup_vscode() {
    _pushd_quiet ${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    # install dependency
    _install_if_not_installed curl

    echo -e "install vscode ...\n"
    curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" >vscode.deb
    sudo dpkg -i vscode.deb
    sudo rm vscode.deb

    _popd_quiet
}

# =============================================================================
function _dj_setup_windows_fonts() {
    echo -e "going to support Windows fonts\n"
    _press_enter_or_wait_s_continue 10
    _install_if_not_installed ttf-mscorefonts-installer
    _install_if_not_installed msttcorefonts
    _install_if_not_installed gtk2-engines-pixbuf # works for solving the GTK warning
}

# =============================================================================
function _dj_setup_wireshark() {
    sudo add-apt-repository ppa:wireshark-dev/stable
    sudo apt-get update -y
    _install_if_not_installed wireshark
    _show_and_run sudo adduser $USER wireshark
    if [ -f /usr/bin/lib/libQt5XcbQpa.so.5 ]; then
        echo "to solve the following error had seen before:"
        echo -e "${YLW}wireshark: relocation error: /usr/bin/plugins/platforms/../../lib/libQt5XcbQpa.so.5: symbol _ZdlPvm version Qt_5 not defined in file libQt5Core.so.5 with link time reference${NOC}"
        _show_and_run sudo cp /usr/bin/lib/* /usr/lib/x86_64-linux-gnu/
    fi
    cat <<eom
To create your own dissector:
https://mika-s.github.io/wireshark/lua/dissector/2017/11/04/creating-a-wireshark-dissector-in-lua-1.html
eom
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
    _pushd_quiet ${PWD}

    # dependencies to install --------------
    echo "install build-essential"
    sudo apt-get -y update &>/dev/null
    _install_if_not_installed build-essential

    cmake_v=$(version check cmake)

    anw=$(_version_if_ge_than $cmake_v 3.20.5)
    if [ "$anw" = 'no' ]; then
        dj setup cmake
    fi
    # remove existing library, if there is
    sudo rm -rf /usr/local/lib/libyaml-cpp*

    yaml_v=$(_find_package_version yaml-cpp)
    _echo_install yaml-cpp $yaml_v
    _press_enter_or_wait_s_continue 5

    cd ~ && mkdir -p soft/ && cd soft/
    rm yaml-cpp -rf

    git clone https://github.com/jbeder/yaml-cpp.git
    cd yaml-cpp
    git checkout yaml-cpp-$yaml_v
    rm -rf build/ && mkdir build && cd build

    cmake ..
    _press_enter_or_wait_s_continue 5
    make -j4 # do not use all CPU threads
    sudo make install

    echo -e "\n${GRN}yaml-cpp $yaml_v${NOC} is installed."
    _verify_lib_installation libyaml-cpp.a /usr/local/lib
    _verify_header_files /usr/local/include/yaml-cpp/
    _verify_pkgconfig_file yaml-cpp.pc /usr/local/lib/pkgconfig

    _popd_quiet
}

# =============================================================================
function _dj_setup() {
    # --------------------------
    if [ $1 = 'abseil-cpp' ]; then
        _dj_setup_abseil_cpp
        return
    fi
    if [ $1 = 'adobe-pdf-reader' ]; then
        _dj_setup_adobe_pdf_reader
        return
    fi
    # --------------------------
    if [ $1 = 'anaconda' ]; then
        _dj_setup_anaconda
        return
    fi
    # --------------------------
    if [ $1 = 'ansible' ]; then
        _dj_setup_ansible
        return
    fi
    # --------------------------
    if [ $1 = 'arduino-1.8.13' ]; then
        _dj_setup_arduino_1_8_13
        return
    fi
    # --------------------------
    if [ $1 = 'baidu-netdisk' ]; then
        _dj_setup_baidu_netdisk
        return
    fi
    # --------------------------
    if [ $1 = 'boost' ]; then
        _dj_setup_boost
        return
    fi
    # --------------------------
    if [ $1 = 'can-analyzer' ]; then
        _dj_setup_can_analyzer
        return
    fi
    # --------------------------
    if [ $1 = 'can-dev-tools' ]; then
        _dj_setup_can_dev_tools
        return
    fi

    # --------------------------
    if [ $1 = 'clang-format' ]; then
        _dj_setup_clang_format
        return
    fi
    # --------------------------
    if [ $1 = 'clang-llvm' ]; then
        _dj_setup_clang_llvm
        return
    fi
    # --------------------------
    if [ $1 = 'cli11' ]; then
        _dj_setup_cli11
        return
    fi
    # --------------------------
    if [ $1 = 'cmake' ]; then
        _dj_setup_cmake
        return
    fi
    # --------------------------
    if [ $1 = 'computer' ]; then
        _dj_setup_computer
        return
    fi
    # --------------------------
    if [ $1 = 'container' ]; then
        if [ $# -lt 2 ]; then
            echo "dj setup container: need argument"
            return
        fi
        if [ $2 = 'dive' ]; then
            _dj_setup_container_dive
            return
        fi
        if [ $2 = 'docker' ]; then
            _dj_setup_container_docker
            return
        fi
        if [ $2 = 'docker-compose' ]; then
            _dj_setup_container_docker_compose
            return
        fi
        if [ $2 = 'lxd-4.0' ]; then
            _dj_setup_container_lxd_4_0
            return
        fi
        return
    fi

    # --------------------------
    if [ $1 = 'cutecom' ]; then
        _dj_setup_cutecom
        return
    fi
    # --------------------------
    if [ $1 = 'devtools' ]; then
        _dj_setup_devtools
        return
    fi
    # --------------------------
    if [ $1 = 'driver' ]; then
        shift 1
        _dj_setup_driver $@
        return
    fi
    # --------------------------
    if [ $1 = 'dropbox' ]; then
        _dj_setup_dropbox
        return
    fi
    # --------------------------
    if [ $1 = 'eigen3' ]; then
        _dj_setup_eigen3
        return
    fi
    # --------------------------
    if [ $1 = 'flamegraph' ]; then
        _dj_setup_flamegraph
        return
    fi
    # --------------------------
    if [ $1 = 'fmt' ]; then
        _dj_setup_fmt $2
        return
    fi
    # --------------------------
    if [ $1 = 'foxit-pdf-reader' ]; then
        _dj_setup_foxit_reader
        return
    fi

    # --------------------------
    if [ $1 = 'fsm-pro' ]; then
        _dj_setup_fsm_pro
        return
    fi

    # --------------------------
    if [ $1 = 'gadgets' ]; then
        _dj_setup_gadgets
        return
    fi
    # --------------------------
    if [ $1 = 'gcc-arm-stm32' ]; then
        _dj_setup_gcc_arm_stm32
        return
    fi
    # --------------------------
    if [ $1 = 'gcc-arm-linux-gnueabi' ]; then
        _dj_setup_gcc_arm_linux_gnueabi
        return
    fi
    # --------------------------
    if [ $1 = 'gcc-arm-linux-gnueabihf' ]; then
        _dj_setup_gcc_arm_linux_gnueabihf
        return
    fi
    # --------------------------
    if [ $1 = 'gcc-aarch64-linux-gnu' ]; then
        _dj_setup_gcc_aarch64_linux
        return
    fi
    # --------------------------
    if [ $1 = 'git-lfs' ]; then
        _dj_setup_git_lfs
        return
    fi
    # --------------------------
    if [ $1 = 'gitg-gitk' ]; then
        _dj_setup_gitg_gitk
        return
    fi
    # --------------------------
    if [ $1 = 'glfw3' ]; then
        _dj_setup_glfw3
        return
    fi
    # --------------------------
    if [ $1 = 'gnuplot' ]; then
        _dj_setup_gnuplot
        return
    fi
    # --------------------------
    if [ $1 = 'google-repo' ]; then
        _dj_setup_google_repo
        return
    fi
    # --------------------------
    if [ $1 = 'gtest' ]; then
        _dj_setup_gtest $2 $3 $4
        return
    fi
    # --------------------------
    if [ $1 = 'glog' ]; then
        _dj_setup_glog $2 $3 $4
        return
    fi
    # --------------------------
    if [ $1 = 'gnome' ]; then
        _dj_setup_gnome
        return
    fi
    # --------------------------
    if [ $1 = 'grpc' ]; then
        _dj_setup_grpc
        return
    fi
    # --------------------------
    if [ $1 = 'g++-10' ]; then
        _dj_setup_gpp_10
        return
    fi
    # --------------------------
    if [ $1 = 'g++-11' ]; then
        _dj_setup_gpp_11
        return
    fi
    # --------------------------
    if [ $1 = 'i219-v' ]; then
        _dj_setup_i219_v $2
        return
    fi
    # --------------------------
    if [ $1 = 'kdiff3-meld' ]; then
        _dj_setup_kdiff3_meld
        return
    fi
    # --------------------------
    if [ $1 = 'kermit' ]; then
        _dj_setup_kermit
        return
    fi
    # --------------------------
    if [ $1 = 'lcm' ]; then
        _dj_setup_lcm
        return
    fi
    # --------------------------
    if [ $1 = 'libbpf' ]; then
        _dj_setup_libbpf
        return
    fi
    if [ $1 = 'libcsv-3.0.2' ]; then
        _dj_setup_libcsv_3_0_2
        return
    fi
    # --------------------------
    if [ $1 = 'libev' ]; then
        _dj_setup_libev
        return
    fi
    # --------------------------
    if [ $1 = 'libgpiod' ]; then
        _dj_setup_libgpiod
        return
    fi
    # --------------------------
    if [ $1 = 'libiio' ]; then
        _dj_setup_libiio
        return
    fi
    # --------------------------
    if [ $1 = 'libserialport' ]; then
        _dj_setup_libserialport
        return
    fi
    # --------------------------
    if [ $1 = 'libsystemd' ]; then
        _dj_setup_libsystemd
        return
    fi
    # --------------------------
    if [ $1 = 'yaml-cpp' ]; then
        _dj_setup_yaml_cpp $2
        return
    fi
    # --------------------------
    if [ $1 = 'mathpix' ]; then
        _dj_setup_mathpix
        return
    fi
    # --------------------------
    if [ $1 = 'matplot++' ]; then
        _dj_setup_matplot_xx
        return
    fi
    # --------------------------
    if [ $1 = 'magic-enum' ]; then
        _dj_setup_magic_enum
        return
    fi
    # --------------------------
    if [ $1 = 'mbed' ]; then
        _dj_setup_mbed
        return
    fi
    # --------------------------
    if [ $1 = 'meson-ninja' ]; then
        _dj_setup_meson_ninjia
        return
    fi
    # --------------------------
    if [ $1 = 'mongodb' ]; then
        _dj_setup_mongodb
        return
    fi
    # --------------------------
    if [ $1 = 'network-tools' ]; then
        _dj_stup_network_tools
        return
    fi
    # --------------------------
    if [ $1 = 'nlohmann-json3-dev' ]; then
        _dj_setup_nlohmann_json3_dev
        return
    fi
    # --------------------------
    if [ $1 = 'nodejs' ]; then
        _dj_setup_nodejs
        return
    fi
    # --------------------------
    if [ $1 = 'nvidia' ]; then
        _dj_setup_nvidia
        return
    fi
    # --------------------------
    if [ $1 = 'nvtop' ]; then
        _dj_setup_nvtop
        return
    fi
    # --------------------------
    if [ $1 = 'opencv-2.4.13' ]; then
        _dj_setup_opencv_2_4_13 $2 $3 $4 $5
        return
    fi
    # --------------------------
    if [ $1 = 'opencv-4.1.1' ]; then
        _dj_setup_opencv_4_1_1 $2 $3 $4 $5
        return
    fi
    # --------------------------
    if [ $1 = 'opencv-3.4.13' ]; then
        _dj_setup_opencv_3_4_13 $2 $3 $4 $5
        return
    fi
    # --------------------------
    if [ $1 = 'opencv-4.2.0' ]; then
        _dj_setup_opencv_4_2_0 $2 $3 $4 $5
        return
    fi
    # --------------------------
    if [ $1 = 'pangolin' ]; then
        _dj_setup_pangolin
        return
    fi
    # --------------------------
    if [ $1 = 'perf' ]; then
        _dj_setup_perf
        return
    fi
    # --------------------------
    if [ $1 = 'picocom' ]; then
        _dj_setup_picocom
        return
    fi
    # --------------------------
    if [ $1 = 'pip' ]; then
        _dj_setup_pip
        return
    fi
    # --------------------------
    if [ $1 = 'plotjuggler' ]; then
        _dj_setup_plotjuggler
        return
    fi
    # --------------------------
    if [ $1 = 'pycharm' ]; then
        _dj_setup_pycharm
        return
    fi
    # --------------------------
    if [ $1 = 'python3.9' ]; then
        _dj_setup_python_3_9
        return
    fi
    # --------------------------
    if [ $1 = 'qemu' ]; then
        _dj_setup_qemu $2 $3 $4 $5
        return
    fi
    # --------------------------
    if [ $1 = 'qt-5.13.1' ]; then
        _dj_setup_qt_5_13_1
        return
    fi
    # --------------------------
    if [ $1 = 'qt-5.14.2' ]; then
        _dj_setup_qt_5_14_2
        return
    fi
    # --------------------------
    if [ $1 = 'ros-melodic' ]; then
        _dj_setup_ros_melodic $2 $3 $4
        return
    fi
    # --------------------------
    if [ $1 = 'ros-noetic' ]; then
        _dj_setup_ros_noetic $2 $3 $4
        return
    fi
    # --------------------------
    if [ $1 = 'ros2-foxy' ]; then
        _dj_setup_ros2_foxy $2 $3 $4
        return
    fi
    # --------------------------
    if [ $1 = 'rpi-pico' ]; then
        _dj_setup_rpi_pico
        return
    fi
    # --------------------------
    if [ $1 = 'rust' ]; then
        shift
        _dj_setup_rust $@
        return
    fi
    # --------------------------
    if [ $1 = 'saleae-logic' ]; then
        _dj_setup_saleae_logic
        return
    fi
    # --------------------------
    if [ $1 = 'serial-console' ]; then
        _dj_setup_serial_console
        return
    fi
    # --------------------------
    if [ $1 = 'slack' ]; then
        _dj_setup_slack
        return
    fi
    # --------------------------
    if [ $1 = 'spdlog' ]; then
        _dj_setup_spdlog $2
        return
    fi
    # --------------------------
    if [ $1 = 'stm32-cubeMX' ]; then
        _dj_setup_stm32_cubemx $2 $3
        return
    fi
    # --------------------------
    if [ $1 = 'stm32-tools' ]; then
        _dj_setup_stm32_tools $2 $3
        return
    fi
    # --------------------------
    if [ $1 = 'sublime' ]; then
        _dj_setup_sublime
        return
    fi
    # --------------------------
    if [ $1 = 'texlive' ]; then
        _dj_setup_texlive
        return
    fi
    # --------------------------
    if [ $1 = 'tldr' ]; then
        _dj_setup_tldr
        return
    fi
    # --------------------------
    if [ $1 = 'typora' ]; then
        _dj_setup_typora
        return
    fi
    # --------------------------
    if [ $1 = 'vim-env' ]; then
        _dj_setup_vim_env
        return
    fi
    # --------------------------
    if [ $1 = 'vscode' ]; then
        _dj_setup_vscode
        return
    fi
    # --------------------------
    if [ $1 = 'vtk-8.2.0' ]; then
        _dj_setup_vtk_8_2_0
        return
    fi

    # --------------------------
    if [ $1 = 'windows-fonts' ]; then
        _dj_setup_windows_fonts
        return
    fi
    # --------------------------
    if [ $1 = 'wireshark' ]; then
        _dj_setup_wireshark
        return
    fi
    # --------------------------
    if [ $1 = 'wubi' ]; then
        _dj_setup_wubi
        return
    fi
    # --------------------------
    if [ $1 = 'you-complete-me' ]; then
        _dj_setup_you_complete_me
        return
    fi
    # --------------------------
    _dj_setup_help
    return
}
