#!/bin/bash

# =============================================================================
function _dj_setup_help() {
    _dj_help
    cat <<eom
  ------------------------------- dj setup --------------------------------
    second level commands:"
      baidu-netdisk    - to install the baidu netdisk tool
      clang-format     - to install clang-format for use of vscode
      computer         - to install lots of necessary software packages
      dj-gadgets       - to install small gadget tools
      dropbox          - to install dropbox
      eigen3           - to install eigen3 library
      foxit            - to install foxit pdf reader
      g++-10           - to install compile g++ of version 10, then ask to 
                         choose version
      gitg-gitk        - to install gitg, gitk
      git-lfs          - to install large file storage of git
      glfw3            - to install glfw3"
      gnome            - to install Gnome, for Ubuntu 20.04, etc
      google-repo      - to install the repo utility developed by Google
      grpc-1.29.1      - to install the gRPC, v1.29.1
      i219-v           - to install Intel I219-V WiFi chipset driver
      libev-4.33       - to install libev, v4.33
      lib-serialport   - to install libserialport
      lib-yamlcpp      - to install yaml-cpp
      mathpix          - to install math latex equation tool mathpix
      matplot++        - to install the matplotplusplus, a cpp graph plot library
      opencv-4.1.1     - to install OpenCV version 4.1.1
      pangolin         - to install openGL based visualization package
      pip              - to install python software pip
      qemu             - to install the emulation tool qemu
      qt-5.13.1        - to install Qt version 5.13.1
      qt-5.14.2        - to install Qt version 5.14.2
      ros2-foxy        - to install ROS2 Foxy, with deb package, or from source
      ros-melodic      - to install ROS Melodic with deb package on Ubuntu 18.04
      slack            - to install Slack
      spdlog           - to install spdlog
      stm32tools       - to install stm32 tool
      sublime          - to install sublime-text-3
      typora           - to install Markdown editor typora
      vscode           - to install VS Code
      vtk-8.2.0        - to install visualization tool vtk-8.2.0
      wubi             - to install Chinese wubi input method
      YouCompleteMe    - to install a Vim plugin: YouCompleteMe

      gcc-aarch64-linux-gnu   - to install the 64-bit arm compiler
      gcc-arm-stm32           - to install micro controller development tool
      gcc-arm-linux-gnueabi   - to install the 32-bit arm compiler
      gcc-arm-linux-gnueabihf - to install the 32-bit arm compiler with hard
                                float unit

      MORE IS COMMING"
  -------------------------------------------------------------------------

eom
}

# =============================================================================
function _dj_setup_adobe_pdf_reader() {
    cur_dir=${PWD}

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

    cd $cur_dir && unset cur_dir
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
    echo -e "${YLW} /usr/share/applications/$file accordingly.${NOC}"
}

# =============================================================================
function _dj_setup_anaconda() {
    python3_ver=$(version check python3)
    anw=$(_version_if_ge_than $python3_ver "3.8")
    if [[ "$anw" = 'no' ]]; then
        echo "anaconda for Python >=3.8.* only"
        return
    fi

    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    file=Anaconda3-2020.11-Linux-x86_64.sh
    url=https://repo.anaconda.com/archive/$file
    _wget_if_not_exist $file "4cd48ef23a075e8555a8b6d0a8c4bae2" $url
    chmod +x $file

    echo -e "${YLW}You need to install Anaconda to ~/.anaconda3 directory!${NOC}"
    ./$file

    _create_anaconda_desktop_item

    cd $cur_dir && unset cur_dir
}

# =============================================================================
function _dj_setup_arduino_1_8_13() {
    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/
    rm arduino* -rf
    filename="arduino-1.8.13-linux64.tar.xz"
    url=https://downloads.arduino.cc/$filename
    _wget_if_not_exist $filename "e4d2ff4da4ba1ddb5bc010cb38b5fbc1" $url
    tar -xvf $filename

    sudo ln -sf ${HOME}/soft/arduino-1.8.13/arduino /usr/bin/arduino

    cd $cur_dir && unset cur_dir
}

# =============================================================================
function _dj_setup_baidu_netdisk() {
    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    file="baidunetdisk_linux_3.0.1.2.deb"
    curl -L http://wppkg.baidupcs.com/issue/netdisk/LinuxGuanjia/3.0.1/$file >$file

    sudo dpkg -i $file

    cd $cur_dir && unset cur_dir
}

# =============================================================================
function _dj_setup_computer() {
    cur_dir=${PWD}

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
       ark cmake curl cutecom dconf-editor dconf-tools git
       git-lfs g++ htop kate libgtk2.0-dev lsb-core putty
       screen scrot terminator tree vlc vim wmctrl xclip yasm

    how to use cu and screen:
        cu: cu -l /dev/ttyUSB0 -s 115200 [ENTER]
        screen: screen /dev/ttyUSB0 115200 [ENTER]
    exit methods for cu and screen:
        cu: input ~. and then [ENTER]
        screen: press Ctrl+A and then \, and [y]
eom

    _press_enter_or_wait_s_continue 10
    packages="ark cmake curl cutecom dconf-editor dconf-tools git "
    packages+="git-lfs g++ htop libgtk2.0-dev lsb-core putty "
    packages+="screen scrot terminator tree vlc vim wmctrl xclip yasm "
    _install_if_not_installed $packages

    # -----------------------------------
    echo -e "\n going to install Google Chrome\n"
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
    echo -e "\n going to remove firefox\n"
    _press_enter_or_wait_s_continue 10
    sudo apt-get purge firefox -y
    rm -Rf ~/.mozilla/firefox/

    # -----------------------------------
    gnome_v=$(version check gnome)
    # to display simplified Chinese: important, do not comment out!
    if [ ! "$gnome_v" = ' ' ]; then
        echo -e "\n going to setup simplified Chinese support\n"
        _press_enter_or_wait_s_continue 10
        gsettings set org.gnome.gedit.preferences.encodings \
            auto-detected "['CURRENT','GB18030','GBK','GB2312','UTF-8','UTF-16']"
    fi

    # -----------------------------------
    # to disable the fixed dock (in dock setting, it is Auto-hide the Dock option)
    if [ ! "$gnome_v" = ' ' ]; then
        echo -e "\n hide the Dock when any windows overlap with it\n"
        _press_enter_or_wait_s_continue 10
        gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    fi
    # -----------------------------------
    # to lock the screen from commands
    if [ ! "$gnome_v" = ' ' ]; then
        echo -e "\n going to setup lock screen command\n"
        _press_enter_or_wait_s_continue 10
        _install_if_not_installed gnome-screensaver
    fi
    # -----------------------------------
    echo -e "\n time & date control: \n you need to run the code:\n"
    echo -e "    timedatectl set-local-rtc 1\n"

    cd $cur_dir
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
    cur_dir=${PWD}

    sudo apt-get --fix-broken install
    _install_if_not_installed libpango1.0-0
    _install_if_not_installed curl

    cd ~ && mkdir -p soft/ && cd soft/

    curl -L \
        https://linux.dropbox.com/packages/ubuntu/dropbox_2020.03.04_amd64.deb \
        >dropbox.deb
    sudo dpkg -i dropbox.deb

    echo -e "\n You can run the following command to setup the Dropbox"
    echo -e "   dropbox start -i\n"

    cd $cur_dir
}

# =============================================================================
function _dj_setup_eigen3() {
    cur_dir=${PWD}
    _install_if_not_installed mlocate # updatedb is in this package
    _install_if_not_installed libeigen3-dev
    echo -e "\n sudo updatedb\n this may take a few minutes\n"
    sudo updatedb

    echo -e "\n eigen3 is installed in: /usr/include/eigen3\n"
    echo " if see error \"fatal error: Eigen/Core: No such file or directory\""
    echo -e " add \"-I/usr/include/eigen3\" to your Makefile\n"

    cd $cur_dir
}

# =============================================================================
function _dj_setup_foxit_reader() {
    cur_dir=${PWD}

    echo -e "\n install Foxit Reader ..."
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
        echo -e "\n FoxitReader not installed into a recommended location"
        echo -e "a symbolic link cannot be generated\n"
    fi

    cd $cur_dir
}

# =============================================================================
function _dj_setup_gcc_aarch64_linux() {
    cur_dir=${PWD}

    echo -e "\n install gcc-aarch64-linux-gnu ...\n"
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
    cd $cur_dir
    unset cur_dir
}

# =============================================================================
# for Ubuntu 20.04:
# https://askubuntu.com/questions/1243252/how-to-install-arm-none-eabi-gdb-on-ubuntu-20-04-lts-focal-fossa
function _dj_setup_gcc_arm_stm32() {
    cur_dir=${PWD}

    echo -e "\n remove ${RED}gcc-arm-none-eabi${NOC}, and install ${GRN}gcc-arm-embedded${NOC} ...\n"
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
    if [[ "${ubuntu_v}" = *'18.04'* || \
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
        compiler_date="9-2020"
        compiler_q="q2"
        url="https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm"
        file="gcc-arm-none-eabi-${compiler_date}-${compiler_q}-update"
        filename="${file}-x86_64-linux.tar.bz2"
        # check if the file exists --------------------
        _wget_if_not_exist $filename "2b9eeccc33470f9d3cda26983b9d2dc6" ${url}/${compiler_date}${compiler_q}/${filename}

        echo "sudo tar xjf ${filename} -C /usr/share/"
        sudo tar xjf ${filename} -C /usr/share/

        echo -e "\n create symbolic links\n"
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-gcc /usr/bin/arm-none-eabi-gcc
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-g++ /usr/bin/arm-none-eabi-g++
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-gdb /usr/bin/arm-none-eabi-gdb
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-size /usr/bin/arm-none-eabi-size
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-objcopy /usr/bin/arm-none-eabi-objcopy
    fi
    cd $cur_dir
    unset cur_dir
}

# =============================================================================
function _dj_setup_gcc_arm_linux_gnueabi() {
    cur_dir=${PWD}

    echo -e "\n install gcc-arm-linux-gnueabi ...\n"
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
    cd $cur_dir
    unset cur_dir
}

# =============================================================================
function _dj_setup_gcc_arm_linux_gnueabihf() {
    cur_dir=${PWD}

    echo -e "\n install gcc-arm-linux-gnueabihf ...\n"
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

    cd $cur_dir
    unset cur_dir
}

# =============================================================================
function _dj_setup_git_lfs() {
    cur_dir=${PWD}
    curl -s \
        https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh |
        sudo bash
    _install_if_not_installed git-lfs
    cd $cur_dir
}

# =============================================================================
function _dj_setup_gitg_gitk() {
    cur_dir=${PWD}

    echo -e "\n install gitg and gitk ...\n"
    _press_enter_or_wait_s_continue 10 # to check the key pressed TODO
    _install_if_not_installed gitg
    _install_if_not_installed gitk
    git config --global credential.helper store
    # git config --global credential.helper 'cache --timeout=36000'
    cd $cur_dir
}

# =============================================================================
# make sure the related package is public available in dj-zhou's github
function _dj_setup_i219_v() {
    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    git clone https://dj-zhou@github.com/dj-zhou/i219-v.git
    cd i219-v/$1/src/
    sudo make install

    cd ~/soft/

    _ask_to_execute_cmd "sudo reboot"

    cd $cur_dir
}

# =============================================================================
function _dj_setup_lcm() {
    if [[ ! "${ubuntu_v}" = *'20.04'* ]] && [[ ! "${ubuntu_v}" = *'18.04'* ]]; then
        echo "lcm installation is only tested within Ubuntu 20.04/18.04"
        return
    fi
    cur_dir=${PWD}

    _install_if_not_installed default-jdk
    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf lcm
    git clone https://github.com/lcm-proj/lcm.git
    cd lcm
    git checkout 501bb446d42c9a57f9e5ddf3c41ba78f4735c9f2 # master on Dec. 1st, 2020
    mkdir build && cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install
    sudo ldconfig

    cat <<eom

    --------------------------------------------
    lcm is installed to:
        /usr/local/lib/liblcm.so.1.4.0
        /usr/local/lib/liblcm.so.1
        /usr/local/lib/liblcm.so
    
    header file:
        /usr/local/include/lcm/*.h

    pkg-config file:
        /usr/local/lib/pkgconfig/lcm.pc
        /usr/local/lib/pkgconfig/lcm-java.pc

eom
    cd $cur_dir
}

# =============================================================================
function _dj_setup_libcsv_3_0_2() {
    cur_dir=${PWD} && cd ~ && mkdir -p soft/ && cd soft/

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

eom

    cd $cur_dir
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
function _dj_setup_libev_4_33() {
    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    file="libev-4.33"
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

    cd ~/soft

    cd $cur_dir
}

# =============================================================================
function _dj_setup_libgpiod() {
    cur_dir=${PWD}
    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf libgpiod*
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        libgpiod_v="1.4"
    elif [[ "${ubuntu_v}" = *'20.04'* ]]; then
        libgpiod_v="1.6"
    else
        echo "_dj_setup_libgpiod: todo"
        return
    fi
    file_name=libgpiod-$libgpiod_v
    link="https://mirrors.edge.kernel.org/pub/software/"
    link="${link}libs/libgpiod/$file_name.tar.xz"
    wget $link
    tar -xvf $file_name.tar.xz

    # install -------------
    cd $file_name
    ./configure
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install
    cd ~/soft

    cat <<eom

    --------------------------------------------
    libgpiod is installed to:
        /usr/lib/x86_64-linux-gnu/libgpiod.a
        /usr/lib/x86_64-linux-gnu/libgpiod.so
        /usr/lib/x86_64-linux-gnu/libgpiod.so.1
        /usr/lib/x86_64-linux-gnu/libgpiod.so.1.0.0
    
    header file:
        /usr/include/gpiod.h

    pkg-config file:
        /usr/lib/x86_64-linux-gnu/pkgconfig/libgpiod.pc

eom

    cd $cur_dir
}

# =============================================================================
function _dj_setup_libiio() {
    cur_dir=${PWD}
    # install some software
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        _install_if_not_installed libxml2-dev
    fi
    if [[ "${ubuntu_v}" = *'20.04'* ]]; then
        _install_if_not_installed bison flex libxml2-dev
    fi
    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf libiio
    git clone https://github.com/analogdevicesinc/libiio.git
    cd libiio
    if [[ "${ubuntu_v}" = *'18.04'* || \
        "${ubuntu_v}" = *'20.04'* ]]; then
        git checkout 0.21
    else
        echo -e "\n${YLW} TO BE IMPLEMENTED${NOC}\n"
        return
    fi
    mkdir build && cd build && cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install
    cd ~/soft

    cat <<eom

    --------------------------------------------
    libiio is installed to:
        /usr/lib/x86_64-linux-gnu/libiio.so.0.21
        /lib/udev/rules.d/90-libiio.rules
        /usr/bin/iio_info
        ...
        /usr/sbin/iiod
    
    header file:
        /usr/include/iio.h

    pkg-config file:
        /usr/lib/x86_64-linux-gnu/pkgconfig/libiio.pc

eom
    cd $cur_dir
}

# =============================================================================
function _dj_setup_libserialport() {
    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    rm -rf libserialport/
    git clone git://sigrok.org/libserialport.git

    cd libserialport
    ./autogen.sh
    ./configure
    make && sudo make install

    cat <<eom

    --------------------------------------------
    the library is installed:
        /usr/local/lib/libserialport.la
        /usr/local/lib/libserialport.so
    
    the header is:
        /usr/local/include/libserialport.h

    example code:
        todo

eom
    cd ~/soft/

    cd $cur_dir
}

# =============================================================================
function _dj_setup_mathpix() {
    _install_if_not_installed snapd
    sudo snap install mathpix-snipping-tool
}

# =============================================================================
# this might need a higher version of g++ to compile (>= 9.3?)
function _dj_setup_matplot_xx() {
    static_shared=$1
    cur_dir=${PWD}
    # dependency ------
    _install_if_not_installed gnuplot
    _install_if_not_installed libfftw3-dev

    # removed pre-installed files ------
    sudo rm -f /usr/local/lib/Matplot++/libnodesoup.a
    sudo rm -f /usr/local/lib/libmatplot.a
    sudo rm -f /usr/local/lib/libmatplot.so
    sudo rm -rf /usr/local/include/matplot
    sudo rm -rf /usr/local/lib/cmake/Matplot++

    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf matplotplusplus
    git clone https://github.com/alandefreitas/matplotplusplus.git
    cd matplotplusplus
    # used a fixed commit, revise later ------
    git checkout d83e3f1010fce3a09578efff4a20b4509ae8fa35

    # compile and install ------
    mkdir build && cd build
    if [ "$static_shared" = 'static' ]; then
        cmake .. -DBUILD_SHARED_LIBS=OFF
    else
        cmake .. -DBUILD_SHARED_LIBS=ON
    fi
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install
    sudo ldconfig
    if [ "$static_shared" = 'static' ]; then
        cat <<eom

    --------------------------------------------
    matplotplusplus is installed to:
        /usr/local/lib/Matplot++/libnodesoup.a
        /usr/local/lib/libmatplot.a

    header file:
        /usr/local/include/matplot/matplot.h
        etc.

    pkg-config file:
        none
    --------------------------------------------
eom
    else
        cat <<eom

    --------------------------------------------
    matplotplusplus is installed to:
        /usr/local/lib/libmatplot.so

    header file:
        /usr/local/include/matplot/matplot.h
        etc.

    pkg-config file:
        none
    --------------------------------------------

eom
    fi

    cd $cur_dir
}

# =============================================================================
function _dj_setup_magic_enum() {
    cur_dir=${PWD}
    cd ~ && mkdir -p soft/ && cd soft/ && rm magic_enum -rf

    ver="v0.7.2" # use static version number at this moment
    git clone https://github.com/Neargye/magic_enum
    cd magic_enum
    git checkout $ver
    sudo cp include/magic_enum.hpp /usr/local/include/

    echo -e "    --------------------------------------------------------"
    echo -e "    The header of ${GRN}Magic Enum C++${NOC} ($ver) is installed as:"
    echo -e "       /usr/local/include/magic_enum.hpp"
    echo -e "    --------------------------------------------------------"
    cat <<eom
  __  __             _        ______                          _____
 |  \/  |           (_)      |  ____|                        / ____|_     _
 | \  / | __ _  __ _ _  ___  | |__   _ __  _   _ _ __ ___   | |   _| |_ _| |_
 | |\/| |/ _\ |/ _\ | |/ __| |  __| | '_ \| | | | '_ \ _  \ | |  |_   _|_   _|
 | |  | | (_| | (_| | | (__  | |____| | | | |_| | | | | | | | |____|_|   |_|
 |_|  |_|\__,_|\__, |_|\___| |______|_| |_|\__,_|_| |_| |_|  \_____|
                __/ | https://github.com/Neargye/magic_enum
               |___ / version 0.7.2
eom
    cd $cur_dir
}

# =============================================================================
# testing on Ubuntu 18.04
function _dj_setup_mbed() {
    cur_dir=${PWD}

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
    cd $cur_dir
}

# =============================================================================
# testing
function _dj_setup_meson() {
    echo -e "\n install ${YLW}meson v0.57.0${NOC} and ${YLW}ninja v1.10.2${NOC} \n"
    _press_enter_or_wait_s_continue 5
    # remove /usr/bin/meson
    sudo apt-get remove meson &>/dev/null

    # install needed software
    _install_if_not_installed python3

    # use fixed version to install meson, and it is installed to ~/.local/bin
    python3 -m pip install meson==0.57.0

    # make sure ~/.local/bin is in the PATH variable
    # but not sure if it is in it for new installed Ubuntu ... will check

    meson_path=$(grep "PATH:~/.local/bin" ~/.bashrc)
    if [ ! -z "$meson_path" ]; then
        echo -e "\n ${YLW}meson ${GRN} path was set in ~/.bashrc${NOC}"
    else
        echo -e '\n' >>~/.bashrc
        echo '# ===========================================================' >>~/.bashrc
        echo '# (djtools) meson path setup' >>~/.bashrc
        echo -e 'export PATH=$PATH:~/.local/bin\n' >>~/.bashrc
    fi

    # ninja is needed for meson, so install it as well
    cur_dir=${PWD}
    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf ninja
    git clone git://github.com/ninja-build/ninja.git && cd ninja
    git checkout v1.10.2 # use fixed version, released on Nov. 28th, 2020
    mkdir build && cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install
    cd $cur_dir
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
function _dj_setup_nlohmann_json3_dev() {
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
    # on Ubuntu 18.04, this installed the 3.1.2-2~bionic version
    # (sudo apt-cache madison nlohmann-json3-dev)
    # sudo add-apt-repository ppa:team-xbmc/ppa
    # sudo apt-get update
    # sudo apt-get install nlohmann-json3-dev

    # install from source
    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    rm json -rf
    git clone https://github.com/nlohmann/json.git
    cd json
    git checkout v3.9.1 # use a fixed version at this moment
    rm build -rf && mkdir build && cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)

    cd $cur_dir
}

# =============================================================================
# this may only work on desktop computer
# nvidia-driver-455 is good at time of this commit
function _dj_setup_nvidia() {
    sudo apt-get purge nvidia*
    _install_if_not_installed libncurses5-dev
    if [[ "${ubuntu_v}" = *'18.04'* || \
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
    cur_dir=$PWD

    if [[ "${ubuntu_v}" = *'18.04'* || \
        "${ubuntu_v}" = *'20.04'* ]]; then
        cd ~ && mkdir -p soft/ && cd soft/
        rm nvtop -rf
        git clone https://github.com/Syllo/nvtop.git
        cd nvtop
        mkdir build && cd build
        cmake .. -DNVML_RETRIEVE_HEADER_ONLINE=True
        make -j$(cat /proc/cpuinfo | grep processor | wc -l)
        sudo make install
    fi

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_qt_5_13_1() {
    cur_dir=$PWD

    echo -e "\n install Qt 5.13.1 \n"

    # install serialport module
    _install_if_not_installed libqt5serialport5-dev

    cd ~ && mkdir -p soft/ && cd soft/

    # check if the file exists --------------------
    filename="qt-opensource-linux-x64-5.13.1.run"
    url=http://qt.mirror.constant.com/archive/qt/5.13/5.13.1/$filename
    _wget_if_not_exist $filename "21c3b16f851697fa8da8009f73694373" $url
    chmod +x $filename

    echo -e "\n It is recommended to install the Qt into ${HOME}/Qt5.13.1/"
    _press_enter_or_wait_s_continue 10

    ./$filename

    # setup the PATH and LD_LIBRARY_PATH into ~/.bashrc
    echo -e '\n' >>~/.bashrc
    echo '# ===========================================================' >>~/.bashrc
    echo '# Qt5.13.1 setup (djtools)' >>~/.bashrc
    echo 'export PATH=~/Qt5.13.1/5.13.1/gcc_64/bin:$PATH' >>~/.bashrc
    echo 'export LD_LIBRARY_PATH=~/Qt5.13.1/5.13.1/gcc_64/lib:$LD_LIBRARY_PATH' >>~/.bashrc
    echo -e "\n PATH and LD_LIBRARY_PATH are set in ~/.bashrc.\n"

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_qt_5_14_2() {
    cur_dir=$PWD

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

    echo -e "\n It is recommended to install the Qt into ${HOME}/Qt5.14.2/"
    _press_enter_or_wait_s_continue 20

    ./$filename

    # setup the PATH and LD_LIBRARY_PATH into ~/.bashrc
    echo -e '\n' >>~/.bashrc
    echo '# ===========================================================' >>~/.bashrc
    echo '# Qt5.14.2 setup (djtools)' >>~/.bashrc
    echo 'export PATH=~/Qt5.14.2/5.14.2/gcc_64/bin:$PATH' >>~/.bashrc
    echo 'export LD_LIBRARY_PATH=~/Qt5.14.2/5.14.2/gcc_64/lib:$LD_LIBRARY_PATH' >>~/.bashrc
    echo -e "\n PATH and LD_LIBRARY_PATH are set in ~/.bashrc.\n"

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_slack() {
    cur_dir=$PWD

    cd ~ && mkdir -p soft && cd soft/
    # the download page: https://slack.com/downloads/linux
    wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.8.0-amd64.deb
    sudo dpkg -i slack-desktop*.deb

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_saleae_logic() {
    cur_dir=$PWD

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
    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_spdlog() { # static/shared
    static_shared=$1          # if empty, treat as dynamic
    echo -e "\n ------------------------------"
    echo -e " ${GRN}which version are you going to install?${NOC}"
    echo -e " 1: v1.6.0"
    echo -e " 2: v1.6.1"
    echo -e " 3: v1.7.0 (default)"
    echo -e " 4: v1.8.0"

    echo -e "${GRN} please enter a number from 1 to 4:${NOC}"
    read asw
    case "$asw" in
    "1")
        version="v1.6.0"
        ;;
    "2")
        version="v1.6.1"
        ;;
    "3")
        version="v1.7.0"
        ;;
    "4")
        version="v1.8.0"
        ;;
    *)
        echo -e "\n ${YLW}wrong input, set to v1.7.0.${NOC}"
        version="v1.7.0"
        ;;
    esac
    echo "version = $version"
    cur_dir=$PWD

    cd ~ && mkdir -p soft && cd soft/
    rm spdlog -rf

    git clone https://github.com/gabime/spdlog.git -b $version
    cd spdlog && mkdir build && cd build

    # static build need to be specific
    # if no option found, "shared" is default
    if [ "$static_shared" = 'static' ]; then
        cmake .. -DSPDLOG_BUILD_SHARED="off"
    else
        cmake .. -DSPDLOG_BUILD_SHARED="on"
    fi
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install

    echo -e "\n ---------------------------------------\n"
    if [ "$static_shared" = 'static' ]; then
        echo " spdlog is installed statically: "
        echo -e "     /usr/local/lib/libspdlog.a\n"
    else
        echo " spdlog is installed sharedally: "
        echo -e "     /usr/local/lib/libspdlog.so\n"
        echo -e " you can run \"sudo ldconfig\" before running programs\n"
    fi
    echo -e "\n ---------------------------------------\n"

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_sublime() {
    cur_dir=${PWD}

    sudo apt-get update
    _install_if_not_installed apt-transport-https ca-certificates curl
    _install_if_not_installed software-properties-common

    curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"

    sudo apt-get update
    _install_if_not_installed sublime-text

    cd $cur_dir
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
    cur_dir=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    # install dependency
    _install_if_not_installed curl

    echo -e "\n install vscode ...\n"
    curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" >vscode.deb
    sudo dpkg -i vscode.deb
    sudo rm vscode.deb

    cd $cur_dir
}

# =============================================================================
function _dj_setup_windows_fonts() {
    echo -e "\n going to support Windows fonts\n"
    _press_enter_or_wait_s_continue 10
    _install_if_not_installed ttf-mscorefonts-installer
    _install_if_not_installed msttcorefonts
    _install_if_not_installed gtk2-engines-pixbuf # works for solving the GTK warning
}

# =============================================================================
# make sure the related package is public available in dj-zhou's github
# compile from the source code will install it to
#   /usr/local/lib/libyaml-cpp.a
# apt-get will install it to
#  /usr/lib/ -----not tested yet!
# shared library build seems not working!
function _dj_setup_yaml_cpp() {
    cur_dir=$PWD

    # dependencies to install --------------
    sudo apt-get -y update
    _install_if_not_installed build-essential

    dj setup cmake-3.19.5
    sudo rm -rf /usr/local/lib/libyaml-cpp*

    yaml_v=$(_find_argument_after_option -v $1 $2 $3 $4 $5 $6 $7 $8)
    if [ -z $yaml_v ]; then
        yaml_v="0.6.3"
    fi
    cd ~ && mkdir -p soft/ && cd soft/
    rm yaml-cpp -rf

    git clone https://github.com/jbeder/yaml-cpp.git
    cd yaml-cpp
    git checkout yaml-cpp-$yaml_v
    rm -rf build/ && mkdir build && cd build

    # use shared library as default
    if [[ "$yaml_v" = "0.6.2" ]]; then
        cmake .. -DBUILD_SHARED_LIBS=ON
    elif [[ "$yaml_v" = "0.6.3" ]]; then
        cmake .. -DYAML_BUILD_SHARED_LIBS=ON
    fi
    echo -e "version to be installed $YLW$yaml_v$NOC"
    _press_enter_or_wait_s_continue 5
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install

    echo -e "\n libyaml-cpp.so is installed in /usr/local/lib/"
    echo -e " header files are installed in /usr/local/include/yaml-cpp/"
    echo -e " pkg-config file installed to: /usr/local/lib/pkgconfig/yaml-cpp.pc\n"

    # ---------------------------------------------
    # # a better way to install it
    # sudo apt-get update
    # sudo apt-get install libyaml-cpp-dev -y

    # # to show the version
    # sudo apt show libyaml-cpp-dev

    # echo -e '\n if the version is NOT 0.5.2, it may have some problem.\n'

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup() {
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
    if [ $1 = 'cmake-3.19.5' ]; then
        _dj_setup_cmake_3_19_5
        return
    fi
    # --------------------------
    if [ $1 = 'computer' ]; then
        _dj_setup_computer
        return
    fi
    # --------------------------
    if [ $1 = 'container' ]; then
        if [ $2 = 'docker' ]; then
            _dj_setup_container_docker
            return
        fi
        if [ $2 = 'dive' ]; then
            _dj_setup_container_dive
            return
        fi
        if [ $2 = 'lxd-4.0' ]; then
            _dj_setup_container_lxd_4_0
            return
        fi
        return
    fi
    # --------------------------
    if [ $1 = 'kdiff3-meld' ]; then
        _dj_setup_kdiff3_meld
        return
    fi
    # --------------------------
    if [ $1 = 'dj-gadgets' ]; then
        _dj_setup_dj_gadgets
        return
    fi
    # --------------------------
    if [ $1 = 'devtools' ]; then
        _dj_setup_devtools
        return
    fi
    # --------------------------
    if [ $1 = 'driver' ]; then
        _dj_setup_driver $2 $3 $4 $5
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
    if [ $1 = 'foxit-pdf-reader' ]; then
        _dj_setup_foxit_reader
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
    if [ $1 = 'grpc-1.29.1' ]; then
        _dj_setup_grpc_1_29_1
        return
    fi
    # --------------------------
    if [ $1 = 'g++-10' ]; then
        _dj_setup_gpp_10
        return
    fi
    # --------------------------
    if [ $1 = 'i219-v' ]; then
        _dj_setup_i219_v $2
        return
    fi
    # --------------------------
    if [ $1 = 'lcm' ]; then
        _dj_setup_lcm
        return
    fi
    if [ $1 = 'libcsv-3.0.2' ]; then
        _dj_setup_libcsv_3_0_2
        return
    fi
    # --------------------------
    if [ $1 = 'libev-4.33' ]; then
        _dj_setup_libev_4_33
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
    if [ $1 = 'lib-serialport' ]; then
        _dj_setup_libserialport
        return
    fi
    # --------------------------
    if [ $1 = 'libyaml-cpp' ]; then
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
    if [ $1 = 'meson' ]; then
        _dj_setup_meson
        return
    fi
    # --------------------------
    if [ $1 = 'mongodb' ]; then
        _dj_setup_mongodb
        return
    fi
    # --------------------------
    if [ $1 = 'nlohmann-json3-dev' ]; then
        _dj_setup_nlohmann_json3_dev
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
    if [ $1 = 'pip' ]; then
        _dj_setup_pip
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
    if [ $1 = 'saleae-logic' ]; then
        _dj_setup_saleae_logic
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
