#!/bin/bash

# =============================================================================
function _dj_setup_help()
{
    _dj_help
    cat << EOM
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
      gtest-glog       - to install gtest/glog
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

EOM
}

# =============================================================================
function _dj_setup_adobe_pdf_reader()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    # install i386 related dependencies --------------------
    sudo dpkg --add-architecture i386
    sudo apt-get -y update
    sudo apt-get -y install libxml2:i386
    sudo apt-get -y install libcanberra-gtk-module:i386
    sudo apt-get -y install gtk2-engines-murrine:i386
    sudo apt-get -y install libatk-adaptor:i386

    link="ftp://ftp.adobe.com/pub/adobe/reader/unix/9.x"
    file="AdbeRdr9.5.5-1_i386linux_enu.deb"
    wget -O adobe.deb ${link}/9.5.5/enu/$file
    sudo dpkg -i adobe.deb

    cd $current_folder && unset current_folder
}

# =============================================================================
function _dj_setup_arduino_1_8_13()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/
    rm arduino* -rf

    wget https://downloads.arduino.cc/arduino-1.8.13-linux64.tar.xz
    tar -xvf arduino-1.8.13-linux64.tar.xz
    sudo ln -sf ${HOME}/soft/arduino-1.8.13/arduino /usr/bin/arduino

    cd $current_folder && unset current_folder
}

# =============================================================================
function _dj_setup_baidu_netdisk()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    file="baidunetdisk_linux_3.0.1.2.deb"
    curl -L http://wppkg.baidupcs.com/issue/netdisk/LinuxGuanjia/3.0.1/$file > $file

    sudo dpkg -i $file
    
    cd $current_folder && unset current_folder
}

# =============================================================================
function _dj_setup_computer()
{
    current_folder=${PWD}

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
    cat << EOM
    
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
EOM

    _press_enter_or_wait_s_continue 10

    sudo apt-get install -y ark cmake curl cutecom dconf-editor dconf-tools git
    sudo apt-get install -y git-lfs g++ htop libgtk2.0-dev lsb-core putty
    sudo apt-get install -y screen scrot terminator tree vlc vim wmctrl xclip yasm

    # -----------------------------------
    echo -e "\n going to install Google Chrome\n"
    _press_enter_or_wait_s_continue 10
    cd ~ && mkdir -p soft/ && cd soft/
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome*

    _ask_to_remove_a_file google-chrome*
    cd ~

    # -----------------------------------
    # Windows fonts
    echo -e "\n going to support Windows fonts\n"
    _press_enter_or_wait_s_continue 10
    sudo apt-get install ttf-mscorefonts-installer -y
    sudo apt-get install msttcorefonts -y
    sudo apt-get install gtk2-engines-pixbuf -y # works for solving the GTK warning

    # -----------------------------------
    # remove firefox
    echo -e "\n going to remove firfox\n"
    _press_enter_or_wait_s_continue 10
    sudo apt-get purge firefox -y; rm -Rf ~/.mozilla/firefox/;

    # -----------------------------------
    gnome_v=$(version check gnome)
    # to display simplified Chinese: important, do not comment out!
    if [ ! "$gnome_v" = ' ' ] ; then
        echo -e "\n going to setup simplified Chinese support\n"
        _press_enter_or_wait_s_continue 10
        gsettings set org.gnome.gedit.preferences.encodings \
            auto-detected "['CURRENT','GB18030','GBK','GB2312','UTF-8','UTF-16']"
    fi
    # -----------------------------------
    # to disable the fixed dock (in dock setting, it is Auto-hide the Dock option)
    if [ ! "$gnome_v" = ' ' ] ; then
        echo -e "\n hide the Dock when any windows overlap with it\n"
        _press_enter_or_wait_s_continue 10
        gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    fi
    # -----------------------------------
    # to lock the screen from commands
    if [ ! "$gnome_v" = ' ' ] ; then
        echo -e "\n going to setup lock screen command\n"
        _press_enter_or_wait_s_continue 10
        sudo apt-get install gnome-screensaver -y
    fi
    # -----------------------------------
    echo -e "\n time & date control: \n you need to run the code:\n"
    echo -e "    timedatectl set-local-rtc 1\n"    

    cd $current_folder
}

# =============================================================================
function _dj_setup_dropbox()
{
    current_folder=${PWD}

    sudo apt-get --fix-broken install
    sudo apt-get install libpango1.0-0 -y
    sudo apt-get install curl -y

    cd ~ && mkdir -p soft/ && cd soft/

    curl -L \
    https://linux.dropbox.com/packages/ubuntu/dropbox_2020.03.04_amd64.deb \
        > dropbox.deb
    sudo dpkg -i dropbox.deb
    
    _ask_to_remove_a_file dropbox.deb
    
    echo -e "\n You can run the following command to setup the Dropbox"
    echo -e "   dropbox start -i\n"

    cd $current_folder
}

# =============================================================================
function _dj_setup_eigen3()
{
    current_folder=${PWD}
    sudo apt-get install mlocate -y # updatedb is in this package
    sudo apt-get install libeigen3-dev -y
    echo -e "\n sudo updatedb\n this may take a few minutes\n"
    sudo updatedb
    
    echo -e "\n eigen3 is installed in: /usr/include/eigen3\n"
    echo " if see error \"fatal error: Eigen/Core: No such file or directory\""
    echo -e " add \"-I/usr/include/eigen3\" to your Makefile\n"

    cd $current_folder
}

# =============================================================================
function _dj_setup_foxit_reader()
{
    current_folder=${PWD}

    echo -e "\n install Foxit Reader ..."
    echo -e "  recommended location: /opt/foxitsoftware/foxitreader\n"
    _press_enter_or_wait_s_continue 10

    cd ~ && mkdir -p soft/ && cd soft/

    # no way to get the latest version?
    file=FoxitReader.enu.setup.2.4.4.0911.x64.run
    wget http://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/$file.tar.gz
    gzip -d $file.tar.gz
    tar xvf $file.tar
    sudo ./FoxitReader*.run

    # create a symbolic link
    foxitreader_location=$(sudo find /opt -name "FoxitReader")
    echo $foxitreader_location
    if [ ! -z "$foxitreader_location" ] ; then
        echo 'a symbolic link "foxit" is generated in /usr/bin'
        sudo ln -sf $foxitreader_location /usr/bin/foxit
    else
        echo -e "\n FoxitReader not installed into a recommended location"
        echo -e "a symbolic link cannot be generated\n"
    fi

    cd $current_folder
}

# =============================================================================
function _dj_setup_gcc_aarch64_linux()
{
    current_folder=${PWD}

    echo -e "\n install gcc-aarch64-linux-gnu ...\n"
    _press_enter_or_wait_s_continue 10
    # common
    sudo apt-get install -y libssl-dev # needed for compiling the Linux Kernel for ARMv8
    sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

    if [[ "${ubuntu_v}" = *'18.04'* ]] ; then
        sudo apt-get install -y gcc-5-aarch64-linux-gnu
        sudo apt-get install -y gcc-5-aarch64-linux-gnu
    else
        echo "do nothing at this moment"
    fi
        

    # update-alternatives configuration
    if [[ "${ubuntu_v}" = *'18.04'* ]] ; then
        sudo update-alternatives --install \
            /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc \
            /usr/bin/aarch64-linux-gnu-gcc-5 5
        sudo update-alternatives --install \
            /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc \
            /usr/bin/aarch64-linux-gnu-gcc-7 7

        echo -e "\n-------------------\n"
        sudo update-alternatives --config aarch64-linux-gnu-gcc
    fi
    cd $current_folder
    unset current_folder
}

# =============================================================================
# for Ubuntu 20.04:
# https://askubuntu.com/questions/1243252/how-to-install-arm-none-eabi-gdb-on-ubuntu-20-04-lts-focal-fossa
function _dj_setup_gcc_arm_stm32()
{
    current_folder=${PWD}

    echo -e "\n remove ${RED}gcc-arm-none-eabi${NOC}, and install ${GRN}gcc-arm-embedded${NOC} ...\n"
    _press_enter_or_wait_s_continue 10

    cd ~ && mkdir -p soft/ && cd soft/

    sudo apt-get install -y build-essential git flex bison libgmp3-dev libmpfr-dev 
    sudo apt-get install -y libncurses5-dev libmpc-dev autoconf texinfo libtool
    sudo apt-get install -y libftdi-dev libusb-1.0-0-dev zlib1g zlib1g-dev python-yaml
    sudo apt-get install -y libncurses-dev

    if [[ "${ubuntu_v}" = *'18.04'* ]] ; then
        sudo echo "deb http://kr.archive.ubuntu.com/ubuntu bionic main universe" \
        | sudo tee -a /etc/apt/sources.list
    elif  [[ "${ubuntu_v}" = *'16.04'* ]] ; then
        echo "just do nothing"
    fi
    if [[ "${ubuntu_v}" = *'18.04'* || \
          "${ubuntu_v}" = *'16.04'* ]] ; then
        sudo apt-get remove gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi
        sudo apt-add-repository ppa:team-gcc-arm-embedded/ppa
        sudo apt-get update
        sudo apt-get install gcc-arm-embedded -y

        echo -e "\n"
        echo " (just maybe) gcc-arm-embedded is installed in /usr/share/gcc-arm-embedded/"
        echo " (question) Is there still an arm-none-eabi? "
        echo -e "\n"
    elif [[ "${ubuntu_v}" = *'20.04'* ]] ; then
        sudo apt remove gcc-arm-none-eabi
        compiler_date="9-2020"
        compiler_q="q2"
        url="https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm"
        file="gcc-arm-none-eabi-${compiler_date}-${compiler_q}-update"
        filename="${file}-x86_64-linux.tar.bz2"
        # check if the file exists --------------------
        unset md5checksum
        if [[ -f "$filename" ]] ; then
            md5checksum=$(md5sum $filename)
            echo "md5checksum = "$md5checksum
        fi
        if [[ "$md5checksum" = *"2b9eeccc33470f9d3cda26983b9d2dc6"* ]] ; then
            echo "file exists, no need to download again"
        else
            wget ${url}/${compiler_date}${compiler_q}/${filename}
            # md5 checksum: 2b9eeccc33470f9d3cda26983b9d2dc6
        fi
        
        echo "sudo tar xjf ${filename} -C /usr/share/"
        sudo tar xjf ${filename} -C /usr/share/

        echo -e "\n create symbolic links\n"
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-gcc     /usr/bin/arm-none-eabi-gcc 
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-g++     /usr/bin/arm-none-eabi-g++
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-gdb     /usr/bin/arm-none-eabi-gdb
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-size    /usr/bin/arm-none-eabi-size
        sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-objcopy /usr/bin/arm-none-eabi-objcopy

        _ask_to_remove_a_file ${filename}
    fi
    cd $current_folder
    unset current_folder
}

# =============================================================================
function _dj_setup_gcc_arm_linux_gnueabi()
{
    current_folder=${PWD}

    echo -e "\n install gcc-arm-linux-gnueabi ...\n"
    _press_enter_or_wait_s_continue 10
    sudo apt-get install -y libncurses5-dev build-essential
    # commonly available
    # on Ubuntu 18.04, they are of 7.3.0 version (probably)
    # on Ubuntu 20.04, they are of 9.3.0 version
    sudo apt-get install -y gcc-arm-linux-gnueabi
    sudo apt-get install -y g++-arm-linux-gnueabi
    if [[ "${ubuntu_v}" = *'18.04'* ]] ; then
        sudo apt-get install -y gcc-5-arm-linux-gnueabi
        sudo apt-get install -y g++-5-arm-linux-gnueabi
    else
        echo "do nothing at this moment"
    fi
    # update-alternatives configuration

    if [[ "${ubuntu_v}" = *'18.04'* ]] ; then
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
    cd $current_folder
    unset current_folder
}

# =============================================================================
function _dj_setup_gcc_arm_linux_gnueabihf()
{
    current_folder=${PWD}

    echo -e "\n install gcc-arm-linux-gnueabihf ...\n"
    _press_enter_or_wait_s_continue 10
    sudo apt-get install -y libncurses5-dev build-essential

    # commom ones
    sudo apt-get install -y gcc-arm-linux-gnueabihf
    sudo apt-get install -y g++-arm-linux-gnueabihf
    if [[ "${ubuntu_v}" = *'18.04'* ]] ; then
        sudo apt-get install -y gcc-5-arm-linux-gnueabihf
        sudo apt-get install -y  g++-5-arm-linux-gnueabihf
    else
        echo "do nothing at this moment"
    fi
    # update-alternatives configuration
    if [[ "${ubuntu_v}" = *'18.04'* ]] ; then
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

    cd $current_folder
    unset current_folder
}

# =============================================================================
function _dj_setup_git_lfs()
{
    current_folder=${PWD}
    curl -s \
      https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh \
      | sudo bash
    sudo apt-get install git-lfs
    cd $current_folder
}

# =============================================================================
function _dj_setup_gitg_gitk()
{
    current_folder=${PWD}

    echo -e "\n install gitg and gitk ...\n"
    _press_enter_or_wait_s_continue 10 # to check the key pressed TODO
    sudo apt-get install gitg gitk -y
    git config --global credential.helper store
    # git config --global credential.helper 'cache --timeout=36000'
    cd $current_folder
}

# =============================================================================
# make sure the related package is public available in dj-zhou's github
function _dj_setup_i219_v()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/
    
    git clone https://dj-zhou@github.com/dj-zhou/i219-v.git
    cd i219-v/$1/src/
    sudo make install

    cd ~/soft/
    _ask_to_remove_a_folder i219-v

    _ask_to_execute_cmd "sudo reboot"

    cd $current_folder
}

# =============================================================================
# libev can also be installed by 
# $ sudo apt-get install -y libev-dev
# however, it is the v4.22 to be installed, and the installation location is
#   /usr/lib/x86_64-linux-gnu/
# install from the source, will have the libev installed into
#  /usr/local/lib
# this setup works only for the host computer, don't know how to do it for 
# cross compilers
function _dj_setup_libev_4_33()
{
    current_folder=${PWD}

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
        echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
    fi

    cd ~/soft
    _ask_to_remove_a_folder $file
    _ask_to_remove_a_file $file.tar.gz

    cd $current_folder
}

# =============================================================================
function _dj_setup_libgpiod()
{
    current_folder=${PWD}
    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf libgpiod*
    if [[ "${ubuntu_v}" = *'18.04'* ]] ; then
        libgpiod_v="1.4"
    elif [[ "${ubuntu_v}" = *'20.04'* ]] ; then
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
    _ask_to_remove_a_folder $file_name
    
    cat << EOM

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

EOM

    cd $current_folder
}

# =============================================================================
function _dj_setup_libiio()
{
    current_folder=${PWD}
    # install some software
    if [[ "${ubuntu_v}" = *'18.04'* ]] ; then
        sudo apt-get install -y libxml2-dev
    fi
    if [[ "${ubuntu_v}" = *'20.04'* ]] ; then
        sudo apt-get install -y bison flex libxml2-dev
    fi
    cd ~ && mkdir -p soft/ && cd soft/
    rm -rf libiio
    git clone https://github.com/analogdevicesinc/libiio.git
    cd libiio
    if [[ "${ubuntu_v}" = *'18.04'* || \
          "${ubuntu_v}" = *'20.04'* ]] ; then
        git checkout 0.21
    else
        echo -e "\n${YLW} TO BE IMPLEMENTED${NOC}\n"
        return
    fi
    mkdir build && cd build && cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install
    cd ~/soft
    _ask_to_remove_a_folder libiio
    
    cat << EOM

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

EOM
    cd $current_folder
}

# =============================================================================
function _dj_setup_libserialport()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/

    rm -rf libserialport/
    git clone git://sigrok.org/libserialport.git
    
    cd libserialport
    ./autogen.sh
    ./configure
    make && sudo make install

    cat << EOM

    --------------------------------------------
    the library is installed:
        /usr/local/lib/libserialport.la
        /usr/local/lib/libserialport.so
    
    the header is:
        /usr/local/include/libserialport.h

    example code:
        TODO

EOM
    cd ~/soft/
    _ask_to_remove_a_folder libserialport/
    
    cd $current_folder
}

# =============================================================================
function _dj_setup_mathpix()
{
    sudo apt-get install -y snapd
    sudo snap install mathpix-snipping-tool
}

# =============================================================================
function _dj_setup_matplot_xx()
{
    static_shared=$1
    current_folder=${PWD}
    # dependency ------
    sudo apt-get install gnuplot -y

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
    if [ "$static_shared" = 'static' ] ; then
        cmake .. -DBUILD_SHARED_LIBS="off"
    else
        cmake .. -DBUILD_SHARED_LIBS="on"
    fi
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install
    sudo ldconfig
    if [ "$static_shared" = 'static' ] ; then
    cat << EOM

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

EOM
    else
    cat << EOM

    --------------------------------------------
    matplotplusplus is installed to:
        /usr/local/lib/libmatplot.so

    header file:
        /usr/local/include/matplot/matplot.h
        etc.

    pkg-config file:
        none
    --------------------------------------------

EOM
    fi

    cd $current_folder
}

# =============================================================================
# reference: https://linux.ci/217.html
# problem: if libyaml-cpp is installed first (0.6.3), then it cannot install
# mongodb, don't know why
function _dj_setup_mongodb()
{
    sudo apt-get update -y
    uname_a=$(uname -a)
    if [[ "${ubuntu_v}" = *'20.04'* ]] ; then
        sudo apt-get -y install dirmngr
        sudo apt-get -y install gnupg
        sudo apt-get -y install apt-transport-https
        sudo apt-get -y install ca-certificates
        sudo apt-get -y install software-properties-common

        if [[ "${uname_a}" = *'aarch64'* ]] ; then # not sure if it works on other platform
            # unable to install v4.4 on raspberry Ubuntu  Server 20.04, so, install v4.2
            curl -s https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
            echo "deb [ arch=arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
        elif [[ "${uname_a}" = *'x86_64'* ]] ; then
            # unable to install v4.2 on laptop Ubuntu 20.04, so, install v4.4
            wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
            sudo add-apt-repository "deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse"
        fi

        # install
        sudo apt-get -y update
        sudo apt-get -y install mongodb-org

        cat << EOM

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
    
    Check if MongoDB is installed:
        $ mongo --eval 'db.runCommand({ connectionStatus: 1 })'
    --------------------------------------------

EOM
    else
        echo -e "\n${YLW} TO BE IMPLEMENTED${NOC}\n"
        return
    fi
    
}

# =============================================================================
function _dj_setup_qt_5_13_1()
{
    cwd_before_running=$PWD

    echo -e "\n install Qt 5.13.1 \n"
    
    # install serialport module
    sudo apt-get install libqt5serialport5-dev -y

    cd ~ && mkdir -p soft/ && cd soft/
    filename="qt-opensource-linux-x64-5.13.1.run"

    # check if the file exists --------------------
    unset md5checksum
    if [[ -f $filename ]] ; then
        md5checksum=$(md5sum $filename)
        echo "md5checksum = "$md5checksum
    fi
    if [[ "$md5checksum" = *"21c3b16f851697fa8da8009f73694373"* ]] ; then
        echo "file exists, no need to download again"
        chmod +x $filename
    else
        wget http://qt.mirror.constant.com/archive/qt/5.13/5.13.1/$filename
        # md5 checksum: 21c3b16f851697fa8da8009f73694373  qt-opensource-linux-x64-5.13.1.run
        chmod +x $filename
    fi

    echo -e "\n It is recommended to install the Qt into ${HOME}/Qt5.13.1/"
    _press_enter_or_wait_s_continue 10

    ./$filename

    _ask_to_remove_a_file $filename

    # setup the PATH and LD_LIBRARY_PATH into ~/.bashrc
    echo -e '\n' >> ~/.bashrc
    echo '# ===========================================================' >> ~/.bashrc
    echo '# Qt5.13.1 setup (djtools)' >> ~/.bashrc
    echo 'export PATH=~/Qt5.13.1/5.13.1/gcc_64/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=~/Qt5.13.1/5.13.1/gcc_64/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
    echo -e "\n PATH and LD_LIBRARY_PATH are set in ~/.bashrc.\n"
    
    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_qt_5_14_2()
{
    cwd_before_running=$PWD

    echo -e "\nInstall Qt 5.14.2\n"
    _press_enter_or_wait_s_continue 10
    
    # install serialport module
    sudo apt-get install libqt5serialport5-dev -y

    cd ~ && mkdir -p soft/ && cd soft/
    http://qt.mirror.constant.com/archive/qt/5.14/5.14.2/qt-opensource-linux-x64-5.14.2.run
    filename="qt-opensource-linux-x64-5.14.2.run"

    # check if the file exists --------------------
    unset md5checksum
    if [[ -f "$filename" ]] ; then
        md5checksum=$(md5sum $filename)
        echo "md5checksum = "$md5checksum
    fi
    if [[ "$md5checksum" = *"dce0588874fd369ce493ea5bc2a21d99"* ]] ; then
        echo "file exists, no need to download again"
        chmod +x $filename
    else
        wget http://qt.mirror.constant.com/archive/qt/5.14/5.14.2/$filename
        # md5 checksum: dce0588874fd369ce493ea5bc2a21d99  qt-opensource-linux-x64-5.14.2.run
        chmod +x $filename
    fi

    echo -e "\n It is recommended to install the Qt into ${HOME}/Qt5.14.2/"
    _press_enter_or_wait_s_continue 20

    ./$filename

    _ask_to_remove_a_file $filename

    # setup the PATH and LD_LIBRARY_PATH into ~/.bashrc
    echo -e '\n' >> ~/.bashrc
    echo '# ===========================================================' >> ~/.bashrc
    echo '# Qt5.14.2 setup (djtools)' >> ~/.bashrc
    echo 'export PATH=~/Qt5.14.2/5.14.2/gcc_64/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=~/Qt5.14.2/5.14.2/gcc_64/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
    echo -e "\n PATH and LD_LIBRARY_PATH are set in ~/.bashrc.\n"

    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_slack()
{
    cwd_before_running=$PWD
    
    cd ~ && mkdir -p soft && cd soft/
    # the download page: https://slack.com/downloads/linux
    wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.8.0-amd64.deb
    sudo dpkg -i slack-desktop*.deb
    _ask_to_remove_a_file slack-desktop*.deb

    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_spdlog() # static/shared
{
    static_shared=$1 # if empty, treat as dynamic
    # version=$2
    # if [ -z "$version" ] ; then
    #     version="v1.7.0"
    # fi
    # if [ ! "$version" == "v1.7.0" ] && \
    #    [ ! "$version" == "v1.8.0" ] \
    #     ; then
    #     echo -e "\n supported version: v1.7.0, v1.8.0\n"
    #     return
    # fi
    # choose a place to install ---------------------------------
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
    esac
    echo "version = $version"
    cwd_before_running=$PWD
    
    cd ~ && mkdir -p soft && cd soft/
    rm spdlog -rf
        
    git clone https://github.com/gabime/spdlog.git -b $version
    cd spdlog && mkdir build && cd build

    # static build need to be specific
    # if no option found, "shared" is default
    if [ "$static_shared" = 'static' ] ; then
        cmake .. -DSPDLOG_BUILD_SHARED="off"
    else
        cmake .. -DSPDLOG_BUILD_SHARED="on"
    fi
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install
    
    echo -e "\n ---------------------------------------\n"
    if [ "$static_shared" = 'static' ] ; then
        echo    " spdlog is installed statically: "
        echo -e "     /usr/local/lib/libspdlog.a\n"
    else
        echo    " spdlog is installed sharedally: "
        echo -e "     /usr/local/lib/libspdlog.so\n"
        echo -e " you can run \"sudo ldconfig\" before running programs\n"
    fi
    echo -e "\n ---------------------------------------\n"
    _ask_to_remove_a_folder spdlog

    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_sublime()
{
    current_folder=${PWD}

    sudo apt-get update
    sudo apt-get install apt-transport-https ca-certificates curl -y
    sudo apt-get install software-properties-common -y

    curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"
    
    sudo apt-get update
    sudo apt-get install sublime-text
    
    cd $current_folder
}

# =============================================================================
function _dj_setup_typora()
{
    wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
    # add Typora's repository
    sudo add-apt-repository 'deb https://typora.io/linux ./'
    sudo apt-get update
    # install typora
    sudo apt-get install typora -y
}

# =============================================================================
# tested: Ubuntu 18.04, Ubuntu 20.04
function _dj_setup_vscode()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ && cd soft/
    
    # install dependency
    sudo apt-get install -y curl

    echo -e "\n install vscode ...\n"
    curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
    sudo dpkg -i vscode.deb
    sudo rm vscode.deb

    cd $current_folder
}

# =============================================================================
# make sure the related package is public available in dj-zhou's github
# compile from the source code will install it to
#   /usr/local/lib/libyaml-cpp.a
# apt-get will install it to
#  /usr/lib/ -----not tested yet!
# shared library build seems not working!
function _dj_setup_yaml_cpp()
{
    cwd_before_running=$PWD

    # dependencies to install --------------
    sudo apt-get -y update
    sudo apt-get -y install build-essential

    dj setup cmake
    sudo rm -rf /usr/local/lib/libyaml-cpp*

    yaml_v=$(_find_argument_after_option -v $1 $2 $3 $4 $5 $6 $7 $8)
    if [ -z $yaml_v ] ; then
        yaml_v="0.6.3"
    fi
    cd ~ && mkdir -p soft/ && cd soft/
    rm yaml-cpp -rf

    git clone https://github.com/jbeder/yaml-cpp.git
    cd yaml-cpp
    git checkout yaml-cpp-$yaml_v
    rm -rf build/ && mkdir build && cd build

    # use shared library as default
    if [[ "$yaml_v" = "0.6.2" ]] ; then
        cmake .. -DBUILD_SHARED_LIBS=ON
    elif [[ "$yaml_v" = "0.6.3" ]] ; then
        cmake .. -DYAML_BUILD_SHARED_LIBS=ON
    fi
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install

    echo -e "\n libyaml-cpp.so is installed in /usr/local/lib/"
        echo -e " header files are installed in /usr/local/include/yaml-cpp/\n"
    _ask_to_remove_a_folder yaml-cpp/

    # ---------------------------------------------
    # # a better way to install it
    # sudo apt-get update
    # sudo apt-get install libyaml-cpp-dev -y

    # # to show the version
    # sudo apt show libyaml-cpp-dev

    # echo -e '\n if the version is NOT 0.5.2, it may have some problem.\n'

    cd ${cwd_before_running}
}
