#!/bin/bash

setup_list="abseil-cpp anaconda ansible arduino-ide boost cli11 cmake computer docker docker-compose  "
setup_list+="eigen3 esp-idf fast-github flamegraph fmt gadgets git-lfs "
setup_list+="gitg-gitk glog gnuplot go googletest grpc gtest g++-10 g++-11 htop kdiff3 "
setup_list+="kermit lcm libbpf libcsv-3.0.2 libev libgpiod libiio libserialport libsystemd "
setup_list+="magic-enum  meson-ninja mongodb nlohmann-json3-dev nodejs opencv-3.4.13 "
setup_list+="opencv-4.5.5 pangolin perf picocom pip plotjuggler protobuf pycharm "
setup_list+="python3.10 python3.11 qemu ros2-foxy ros2-humble rpi-pico rust  spdlog "
setup_list+="sublime yaml-cpp "

if [ $system = 'Linux' ]; then
    setup_list+="adobe-pdf-reader baidu-netdisk can-analyzer can-dev-tools clang-format "
    setup_list+="clang-llvm cuda cutecom devtools driver dtc device-tree-compilier "
    setup_list+="foxit-pdf-reader fsm-pro gcc-arm-stm32 gcc-arm-linux-gnueabi "
    setup_list+="gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu glfw3 gnome google-repo "
    setup_list+="i219-v mbed network-tools nvidia nvtop qt-5.13.1 qt-5.14.2 saleae-logic "
    setup_list+="serial-console slack stm32-cube-ide stm32-cube-ide-desktop-item "
    setup_list+="stm32-cube-mx stm32-cube-mx-desktop-item stm32-cube-programmer "
    setup_list+="stm32-tools texlive thermal-printer typora vscode windows-fonts wireshark wubi "
    # elif [ $system = 'Darwin' ]; then
    # do nothing at this point
fi

# =============================================================================
function _dj_setup_help() {
    _dj_help
    cat <<eom
------------------------------- dj setup --------------------------------
    setup common used software and packages, usually tested on Ubuntu 20.04/22.04
-------------------------------------------------------------------------
eom
}

# =============================================================================
function _dj_setup_abseil_cpp() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    abseil_v=$(_find_package_version abseil-cpp)
    _show_and_run rm -rf abseil-cpp
    _show_and_run git clone git@github.com:abseil/abseil-cpp.git
    _show_and_run cd abseil-cpp
    _show_and_run git checkout $abseil_v
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    _popd_quiet

    _verify_lib_installation libabsl_base.a /usr/local/lib
    _verify_pkgconfig_file absl_base.pc /usr/local/lib/pkgconfig
    _verify_header_files config.h /usr/local/include/absl/base
    _verify_cmake_files abslConfig.cmake /usr/local/lib/cmake/absl
}

# =============================================================================
function _dj_setup_adobe_pdf_reader() {
    _pushd_quiet ${PWD}

    # install i386 related dependencies --------------------
    _show_and_run sudo dpkg --add-architecture i386
    _show_and_run sudo apt-get -y update
    _show_and_run _install_if_not_installed libxml2:i386
    _show_and_run _install_if_not_installed libcanberra-gtk-module:i386
    _show_and_run _install_if_not_installed gtk2-engines-murrine:i386
    _show_and_run _install_if_not_installed libatk-adaptor:i386

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

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
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    python3_ver=$(version check python3)
    anw=$(_version_if_ge_than $python3_ver "3.8")
    if [[ "$anw" = 'no' ]]; then
        echo "anaconda for Python >=3.8.* only"
        return
    fi

    v=$(_find_package_version anaconda)

    file=Anaconda3-$v-Linux-x86_64.sh
    url=https://repo.anaconda.com/archive/$file
    _show_and_run _wget_if_not_exist $file "95102d7c732411f1458a20bdf47e4c1b0b6c8a21a2edfe4052ca370aaae57bab" $url
    _show_and_run chmod +x $file

    echo -e "${YLW}You need to install Anaconda to ~/.anaconda3 directory!${NOC}"
    _show_and_run ./$file

    _create_anaconda_desktop_item

    _popd_quiet
}

# =============================================================================================
function _create_arduino_desktop_item() {
    folder="/usr/share/applications"

    # copy the icon file
    _show_and_run sudo cp $djtools_path/settings/arduino-ide.xpm $folder

    file="arduino-ide.desktop"
    _show_and_run touch $file

    _show_and_run echo '[Desktop Entry]' >>$file
    _show_and_run echo 'Encoding=UTF-8' >>$file
    _show_and_run echo 'Name=arduino-ide' >>$file
    _show_and_run echo 'Comment=arduino-ide' >>$file
    _show_and_run echo 'Exec=/usr/bin/arduino-ide' >>$file
    _show_and_run echo 'Icon='$folder'/arduino-ide.xpm' >>$file
    _show_and_run echo 'StartupNotify=false' >>$file
    _show_and_run echo 'Type=Application' >>$file
    _show_and_run echo 'Categories=Application;Development;' >>$file

    _show_and_run sudo rm -rf $folder/$file
    _show_and_run sudo mv $file $folder

    _show_and_run sudo chmod +x $folder/$file
}

# =============================================================================
function _dj_setup_arduino() {
    _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf arduino*

    v=$(_find_package_version arduino)
    ide_name="arduino-ide_${v}_Linux_64bit"
    url=https://downloads.arduino.cc/arduino-ide/${ide_name}.zip
    _show_and_run _wget_if_not_exist ${ide_name}.zip "f9118378e198523fcfe0fc4d9864c3ef" $url
    _show_and_run rm -rf $ide_name
    _show_and_run unzip ${ide_name}.zip
    _show_and_run rm -rf arduino-$v
    _show_and_run mv $ide_name arduino-$v

    _show_and_run sudo rm -f /usr/bin/arduino-ide
    _show_and_run sudo ln -sf $soft_dir/arduino-$v/arduino-ide /usr/bin/arduino-ide

    _popd_quiet

    _create_arduino_desktop_item
}

# =============================================================================
function _dj_setup_baidu_netdisk() {
    _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    file="baidunetdisk_linux_3.0.1.2.deb"
    curl -L http://wppkg.baidupcs.com/issue/netdisk/LinuxGuanjia/3.0.1/$file >$file

    sudo dpkg -i $file

    _popd_quiet
}

# =============================================================================
function _dj_setup_computer() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run sudo rm -rf ~/Documents/
    _show_and_run sudo rm -rf ~/Music/
    _show_and_run sudo rm -rf ~/Pictures/
    _show_and_run sudo rm -rf ~/Public/
    _show_and_run sudo rm -rf ~/Templates/
    _show_and_run sudo rm -rf ~/Videos/
    _show_and_run sudo rm -rf ~/examples.desktop

    # -----------------------------------
    _show_and_run sudo apt-get update -y
    _show_and_run sudo apt-get upgrade -y

    # -----------------------------------
    _press_enter_or_wait_s_continue 5
    packages="ark cmake curl dconf-editor dconf-tools gedit git git-lfs g++ "
    packages+="kazam libgtk2.0-dev libncurses5-dev lsb-core okular scrot "
    packages+="silversearcher-ag terminator tree vlc vim wmctrl xclip yasm "
    _show_and_run _install_if_not_installed $packages

    # -----------------------------------
    echo -e "${CYN}install Google Chrome${NOC}"
    _press_enter_or_wait_s_continue 5
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    google_ver=$(google-chrome --version)
    if [[ "$google_ver" = *"Google Chrome"* ]]; then
        echo "Google Chrome already installed"
    else
        _show_and_run wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        _show_and_run sudo dpkg -i google-chrome*
    fi

    _popd_quiet

    # -----------------------------------
    gnome_v=$(version check gnome)
    # to display simplified Chinese: important, do not comment out!
    if [ ! "$gnome_v" = ' ' ]; then
        echo -e "${CYN}setup simplified Chinese support${NOC}"
        _press_enter_or_wait_s_continue 5
        _show_and_run gsettings set org.gnome.gedit.preferences.encodings \
            auto-detected "['CURRENT','GB18030','GBK','GB2312','UTF-8','UTF-16']"
    fi

    # -----------------------------------
    # to disable the fixed dock (in dock setting, it is Auto-hide the Dock option)
    if [ ! "$gnome_v" = ' ' ]; then
        echo -e "${CYN}hide the Dock when any windows overlap with it${NOC}"
        _press_enter_or_wait_s_continue 5
        _show_and_run gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    fi

    # -----------------------------------
    # to lock the screen from commands
    if [ ! "$gnome_v" = ' ' ]; then
        echo -e "${CYN}setup lock screen command${NOC}"
        _press_enter_or_wait_s_continue 5
        _show_and_run _install_if_not_installed gnome-screensaver
    fi

    _show_and_run dj setup htop
    # -----------------------------------
    echo -e "${CYN}time & date control, please run command:${NOC}"
    echo "$ timedatectl set-local-rtc 1"

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
        # testing on Raspbian Pi Zero 2W board, kernel 6.1.21-v7+
        if [[ "${ubuntu_v}" = *"Raspbian"* ]]; then
            _show_and_run _install_if_not_installed iw
            _show_and_run mkdir -p ~/soft
            _show_and_run cd ~/soft
            _show_and_run rm 8812au-20210629
            _show_and_run git clone https://github.com/morrownr/8812au-20210629.git
            _show_and_run cd 8812au-20210629
            _show_and_run sudo ./install-driver.sh
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
# Install a version from its source code
function _dj_setup_eigen3() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run _install_if_not_installed wget

    if command -v cmake >/dev/null 2>&1; then
        echo "cmake is installed already"
    else
        dj setup cmake
    fi
    eigen3_v=$(_find_package_version eigen3)
    _echo_install eigen3 $eigen3_v
    _press_enter_or_wait_s_continue 5

    _show_and_run sudo rm -rf /usr/local/include/eigen3
    _show_and_run sudo rm -rf /usr/include/eigen3

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    if ls eigen* 1>/dev/null 2>&1; then
        _show_and_run rm -rf eigen*
    fi
    _show_and_run wget https://gitlab.com/libeigen/eigen/-/archive/$eigen3_v/eigen-$eigen3_v.tar.gz
    _show_and_run tar -xvf eigen-$eigen3_v.tar.gz

    _show_and_run cd eigen-$eigen3_v
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo -e "\n${INFO}eigen3 $eigen3_v${NOC} is installed."
    _verify_header_files Eigen /usr/local/include/eigen3/Eigen
    # just to prevent compiling error in the future
    if [ $system = 'Linux' ]; then
        _show_and_run sudo ln -s /usr/local/include/eigen3 /usr/include/eigen3
        _verify_header_files Eigen /usr/include/eigen3/Eigen
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_esp_idf() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run _install_if_not_installed git wget flex bison gperf python3 python3-venv python3-setuptools cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0

    # make sure CMake is newer than 3.16
    cmake_v=$(version check cmake)
    anw=$(_version_if_ge_than $cmake_v "3.16")
    if [[ "$anw" = 'no' ]]; then
        echo_info "need to install new version of CMake"
        dj setup cmake
    fi

    # make sure ninja is installed
    which_meson=$(which meson)
    which_ninja=$(which ninja)
    if [[ -z "$which_meson" || -z "$which_ninja" ]]; then
        _show_and_run dj setup meson-ninja
    else
        echo "meson version: $(meosn --version)"
        echo "ninja version: $(ninja --version)"
    fi

    # clone esp repo
    if [ -d "esp-idf" ]; then
        _show_and_run cd esp-idf
        _show_and_run git checkout master
        _show_and_run git pull
    else
        _show_and_run git clone --recursive https://github.com/espressif/esp-idf.git
        _show_and_run cd esp-idf
    fi

    # setup for all target
    _show_and_run ./install.sh all # esp32s3, etc
    # ./install.sh esp32,esp32s2

    # setup env, this is not a good idea! We should only source it when develop ESP32 chips
    # _show_and_run write_in_file "source $soft_dir/esp-idf/export.sh" $rc_file
    # this is better:
    _show_and_run write_in_file "alias get_esp_idf='source $soft_dir/esp-idf/export.sh'" $rc_file
    _popd_quiet
}

# =============================================================================
function _dj_setup_fast_github() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run rm -rf fast-github
    _show_and_run git clone https://github.com/dj-zhou/fast-github.git

    _show_and_run cd fast-github

    if [[ $OSTYPE = "linux-gnu" && $(uname -m) = "x86_64" ]]; then
        _show_and_run sudo rm -rf /opt/fastgithub_linux-x64
        _show_and_run unzip fastgithub_linux-x64.zip
        _show_and_run mv fastgithub_linux-x64 /opt/
    fi

    _show_and_run sudo rm -f /usr/local/bin/fastgithub
    _show_and_run sudo ln -s /opt/fastgithub_linux-x64/fastgithub /usr/local/bin/fastgithub

    _popd_quiet
}

# =============================================================================
function _dj_setup_flamegraph() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run dj setup perf

    _show_and_run rm -rf FlameGraph
    _show_and_run git clone https://github.com/brendangregg/FlameGraph.git
    _show_and_run sudo cp -r FlameGraph /usr/local/bin/ # OK, I know, this is not good

    # create symbolic link
    _show_and_run sudo rm -f /usr/bin/stackcollapse-perf.pl
    _show_and_run sudo rm -f /usr/bin/flamegraph.pl
    _show_and_run sudo ln -s /usr/local/bin/FlameGraph/stackcollapse-perf.pl /usr/bin/stackcollapse-perf.pl
    _show_and_run sudo ln -s /usr/local/bin/FlameGraph/flamegraph.pl /usr/bin/flamegraph.pl

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
    _show_and_run _pushd_quiet ${PWD}

    if [ $# -eq 0 ]; then
        fmt_v=$(_find_package_version fmt)
    else
        fmt_v=$1
    fi

    _echo_install fmt $fmt_v
    _press_enter_or_wait_s_continue 5

    # remove first ------------------
    _show_and_run sudo rm -rf /usr/local/lib/libfmt.a
    _show_and_run sudo rm -rf /usr/local/include/fmt/
    _show_and_run sudo rm -rf /usr/local/lib/pkgconfig/fmt.pc
    _show_and_run sudo rm -rf /usr/local/lib/cmake/fmt/

    # --------------------
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf fmt
    _show_and_run git clone https://github.com/fmtlib/fmt.git
    _show_and_run cd fmt
    _show_and_run git checkout ${fmt_v}
    _show_and_run rm -rf build
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake .. -DBUILD_SHARED_LIBS=TRUE -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo -e "\n${INFO}fmt $fmt_v${NOC} is installed."

    # _verify_lib_installation libfmt.a /usr/local/lib
    _verify_lib_installation libfmt.so /usr/local/lib
    _verify_header_files format.h /usr/local/include/fmt
    _verify_pkgconfig_file fmt.pc /usr/local/lib/pkgconfig
    _verify_cmake_files fmt-config.cmake /usr/local/lib/cmake/fmt

    _popd_quiet
}

# =============================================================================
function _dj_setup_foxit_reader() {
    _show_and_run _pushd_quiet ${PWD}

    echo -e "install Foxit Reader ..."
    echo -e "  recommended location: /opt/foxitsoftware/foxitreader\n"
    _press_enter_or_wait_s_continue 5

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    # no way to get the latest version?
    file=FoxitReader.enu.setup.2.4.5.0727.x64.run
    url="https://cdn78.foxitsoftware.com/pub/foxit/reader/desktop/"
    url=${url}linux/2.x/2.4/en_us/$file.tar.gz
    _show_and_run _wget_if_not_exist $file.tar.gz "22d2553945edc0af9dbd52dd4a2cee22" ${url}
    _show_and_run gzip -d $file.tar.gz
    _show_and_run tar xvf $file.tar
    _show_and_run sudo ./FoxitReader*.run

    # create a symbolic link
    foxit_reader_location=$(sudo find /opt -name "FoxitReader")
    echo $foxit_reader_location
    if [[ ! -z "$foxit_reader_location" ]]; then
        echo 'a symbolic link "foxit" is generated in /usr/bin'
        _show_and_run sudo ln -sf $foxit_reader_location /usr/bin/foxit
    else
        echo -e "FoxitReader not installed into a recommended location"
        echo -e "a symbolic link cannot be generated\n"
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_fsm_pro() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run wget https://www.fsmpro.io/downloads/FsmPro.deb
    _show_and_run sudo dpkg -i FsmPro.deb

    echo "reference: https://www.fsmpro.io/"

    _popd_quiet
}

# =============================================================================
function _dj_setup_gcc_aarch64_linux() {
    _pushd_quiet ${PWD}

    echo -e "install gcc-aarch64-linux-gnu ...\n"
    _press_enter_or_wait_s_continue 5
    # common
    _show_and_run _install_if_not_installed libssl-dev # needed for compiling the Linux Kernel for ARMv8
    _show_and_run _install_if_not_installed gcc-aarch64-linux-gnu
    _show_and_run _install_if_not_installed g++-aarch64-linux-gnu

    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        _show_and_run _install_if_not_installed gcc-5-aarch64-linux-gnu
        _show_and_run _install_if_not_installed gcc-5-aarch64-linux-gnu
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
    _show_and_run _pushd_quiet ${PWD}

    echo -e "remove ${RED}gcc-arm-none-eabi${NOC}, and install ${INFO}gcc-arm-embedded${NOC} ...\n"
    _press_enter_or_wait_s_continue 5

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    packages="build-essential git flex bison libgmp3-dev libmpfr-dev "
    packages+="libncurses5-dev libmpc-dev autoconf texinfo libtool "
    packages+="libftdi-dev libusb-1.0-0-dev zlib1g zlib1g-dev python-yaml "
    packages+="libncurses-dev "
    _show_and_run _install_if_not_installed $packages

    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        # sudo echo "deb http://kr.archive.ubuntu.com/ubuntu bionic main universe" \
        # | sudo tee -a /etc/apt/sources.list
        _show_and_run sudo rm -rf /etc/apt/sources.list.d/gcc-arm-stm32.list
        _show_and_run sudo sh -c 'echo "deb http://kr.archive.ubuntu.com/ubuntu bionic main universe" \
            >> /etc/apt/sources.list.d/gcc-arm-stm32.list'
    elif [[ "${ubuntu_v}" = *'16.04'* ]]; then
        echo "just do nothing"
    fi
    if [[ "${ubuntu_v}" = *'18.04'* ||
        "${ubuntu_v}" = *'16.04'* ]]; then
        _show_and_run sudo apt-get remove gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi
        _show_and_run sudo apt-add-repository ppa:team-gcc-arm-embedded/ppa
        _show_and_run sudo apt-get update
        _show_and_run _install_if_not_installed gcc-arm-embedded

        echo " (just maybe) gcc-arm-embedded is installed in /usr/share/gcc-arm-embedded/"
        echo " (question) Is there still an arm-none-eabi? "

    elif [[ "${ubuntu_v}" = *'20.04'* ]]; then
        _show_and_run sudo apt remove gcc-arm-none-eabi
        file="gcc-arm-none-eabi-10.3-2021.10"
        filename="${file}-x86_64-linux.tar.bz2"
        url="https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm"
        link="${url}/10.3-2021.10/${filename}"

        # check if the file exists --------------------
        _show_and_run _wget_if_not_exist $filename "2383e4eb4ea23f248d33adc70dc3227e" ${link}

        _show_and_run sudo tar xjf ${filename} -C /usr/share/

        echo -e "create symbolic links"
        _show_and_run sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-ar /usr/bin/arm-none-eabi-ar
        _show_and_run sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-gcc /usr/bin/arm-none-eabi-gcc
        _show_and_run sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-g++ /usr/bin/arm-none-eabi-g++
        _show_and_run sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-gdb /usr/bin/arm-none-eabi-gdb
        _show_and_run sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-objcopy /usr/bin/arm-none-eabi-objcopy
        _show_and_run sudo ln -sf /usr/share/${file}/bin/arm-none-eabi-size /usr/bin/arm-none-eabi-size
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_gcc_arm_linux_gnueabi() {
    _pushd_quiet ${PWD}

    echo -e "install gcc-arm-linux-gnueabi ..."
    _press_enter_or_wait_s_continue 5
    _show_and_run _install_if_not_installed libncurses5-dev
    _show_and_run _install_if_not_installed build-essential
    # commonly available
    # on Ubuntu 18.04, they are of 7.3.0 version (probably)
    # on Ubuntu 20.04, they are of 9.3.0 version
    _show_and_run _install_if_not_installed gcc-arm-linux-gnueabi
    _show_and_run _install_if_not_installed g++-arm-linux-gnueabi
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        _show_and_run _install_if_not_installed gcc-5-arm-linux-gnueabi
        _show_and_run _install_if_not_installed g++-5-arm-linux-gnueabi
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
    _press_enter_or_wait_s_continue 5
    _show_and_run _install_if_not_installed libncurses5-dev
    _show_and_run _install_if_not_installed build-essential

    # commom ones
    _show_and_run _install_if_not_installed gcc-arm-linux-gnueabihf
    _show_and_run _install_if_not_installed g++-arm-linux-gnueabihf
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        _show_and_run _install_if_not_installed gcc-5-arm-linux-gnueabihf
        _show_and_run _install_if_not_installed g++-5-arm-linux-gnueabihf
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
    _show_and_run _install_if_not_installed git-lfs

    _popd_quiet
}

# =============================================================================
function _dj_setup_gitg_gitk() {
    _pushd_quiet ${PWD}

    echo -e "install gitg and gitk ..."
    _press_enter_or_wait_s_continue 5 # to check the key pressed TODO
    _show_and_run _install_if_not_installed gitg
    _show_and_run _install_if_not_installed gitk
    git config --global credential.helper store
    # git config --global credential.helper 'cache --timeout=36000'

    _popd_quiet
}

# =============================================================================
function _dj_setup_htop() {
    _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    local v=$(_find_package_version htop)
    _show_and_run rm -rf htop
    _show_and_run git clone https://github.com/htop-dev/htop.git
    _show_and_run cd htop
    _show_and_run git checkout $v
    _show_and_run ./autogen.sh
    _show_and_run ./configure
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install
}

# =============================================================================
# make sure the related package is public available in dj-zhou's github
function _dj_setup_i219_v() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run git clone https://dj-zhou@github.com/dj-zhou/i219-v.git
    _show_and_run cd i219-v/$1/src/
    _show_and_run sudo make install

    _show_and_run cd $soft_dir

    _ask_to_execute_cmd "sudo reboot"

    _popd_quiet
}

# =============================================================================
function _dj_setup_libbpf() {
    _pushd_quiet ${PWD}

    _show_and_run _install_if_not_installed libelf-dev

    v=$(_find_package_version libbpf)
    _echo_install libbpf $v

    _show_and_run cd mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf libbpf
    _show_and_run git clone https://github.com/libbpf/libbpf.git
    _show_and_run cd libbpf
    _show_and_run git checkout $v

    _show_and_run cd src
    _show_and_run make -j$(nproc)
    _show_and_run mkdir -p build root
    BUILD_STATIC_ONLY=y OBJDIR=build DESTDIR=root make install

    _show_and_run cd root/usr/
    _show_and_run sudo cp -r include/* /usr/include/
    _show_and_run sudo cp lib64/* -r /usr/lib/

    _popd_quiet
}

# =============================================================================
function _dj_setup_libcsv_3_0_2() {
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run cd mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run rm -rf libcsv-3.0.2
    _show_and_run git clone https://github.com/dj-zhou/libcsv-3.0.2
    # the master branch is of version 3.0.2
    _show_and_run cd libcsv-3.0.2
    _show_and_run ./configure
    _show_and_run make check
    _show_and_run sudo make install

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
function _dj_setup_libgpiod() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf libgpiod*

    libgpiod_v=$(_find_package_version libgpiod)

    _echo_install libgpiod $libgpiod_v
    _press_enter_or_wait_s_continue 5
    _
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        file_name=libgpiod-$libgpiod_v
        link="https://mirrors.edge.kernel.org/pub/software/"
        link="${link}libs/libgpiod/$file_name.tar.gz"

        _show_and_run wget $link
        _show_and_run tar -xvf $file_name.tar.gz

        # install -------------
        _show_and_run cd $file_name
        _show_and_run ./configure
        _show_and_run make -j$(nproc)
        _show_and_run sudo make install

    elif [[ "${ubuntu_v}" = *'20.04'* || "${ubuntu_v}" = *'22.04'* ]]; then
        _show_and_run _install_if_not_installed autoconf-archive
        _show_and_run rm -rf libgpiod
        _show_and_run git clone git://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
        _show_and_run cd libgpiod
        _show_and_run git checkout $libgpiod_v
        _show_and_run ./autogen.sh --enable-tools=yes
        _show_and_run make -j$(nproc)
        _show_and_run sudo make install

        _verify_lib_installation libgpiod.so /usr/local/lib
        _verify_pkgconfig_file libgpiod.pc /usr/local/lib/pkgconfig
        _verify_header_files gpiod.h /usr/local/include
    else
        echo "_dj_setup_libgpiod: todo"
        return
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_libiio() {
    _show_and_run _pushd_quiet ${PWD}
    # install some software
    _show_and_run _install_if_not_installed bison flex libxml2-dev

    v=$(_find_package_version libiio)
    _echo_install libiio $v

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf libiio
    _show_and_run git clone https://github.com/analogdevicesinc/libiio.git
    _show_and_run cd libiio
    if [[ "${ubuntu_v}" = *'18.04'* ||
        "${ubuntu_v}" = *'20.04'* ||
        "${ubuntu_v}" = *'22.04'* ]]; then
        _show_and_run git checkout $v
    else
        echo -e "\n${YLW} TO BE IMPLEMENTED${NOC}\n"
        return
    fi

    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    _verify_lib_installation libiio.so /usr/lib/x86_64-linux-gnu/
    _verify_lib_installation iio_info /usr/bin/
    _verify_lib_installation iiod /usr/sbin/
    _verify_pkgconfig_file libiio.pc /usr/lib/x86_64-linux-gnu/pkgconfig/
    _verify_header_files iio.h /usr/include/

    _popd_quiet
}

# =============================================================================
function _dj_setup_libserialport() {
    _show_and_run _pushd_quiet "${PWD}"

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd ~/ $soft_dir

    v=$(_find_package_version libserialport)
    _echo_install libserialport $v
    _press_enter_or_wait_s_continue 5

    _show_and_run rm -rf libserialport/
    _show_and_run git clone git://sigrok.org/libserialport.git

    _show_and_run cd libserialport
    _show_and_run ./autogen.sh
    _show_and_run ./configure
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    # check if library installed correctly
    _verify_lib_installation libserialport.a /usr/local/lib/
    _verify_lib_installation libserialport.la /usr/local/lib/
    _verify_lib_installation libserialport.so /usr/local/lib/
    _verify_pkgconfig_file libserialport.pc /usr/local/lib/pkgconfig
    _verify_header_files libserialport.h /usr/local/include

    _popd_quiet
}

# =============================================================================
function _dj_setup_libsystemd() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run _install_if_not_installed libmount-dev libcap-dev
    systemd_v=$(_find_package_version libsystemd)

    if [[ "${ubuntu_v}" = *'18.04'* ]] && [[ "${systemd_v}" = *'248'* ]]; then
        echo "just do not install it, it will break your system!"
        return
    fi
    echo -e "install ${INFO}libsystemd $systemd_v${NOC}"

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd ~/ $soft_dir

    _show_and_run rm -rf systemd/
    _show_and_run git clone git@github.com:systemd/systemd.git
    _show_and_run cd systemd
    _show_and_run git checkout $systemd_v

    _show_and_run ./configure
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    _verify_lib_installation libsystemd.so /x86_64-linux-gnu
    _verify_pkgconfig_file libsystemd.pc /usr/lib/x86_64-linux-gnu/pkgconfig

    _popd_quiet
}

# =============================================================================
function _dj_setup_magic_enum() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run sudo rm -rf magic_enum

    gpp_v=$(version check g++)
    anw=$(_version_if_ge_than $gpp_v "12.0.0")
    if [ $anw="yes" ]; then
        echo_warn "g++ > 12.0.0 does not support extended characters"
        ver="0.7.3"
    else
        ver=$(_find_package_version magic-enum)
    fi
    _show_and_run git clone https://github.com/Neargye/magic_enum.git
    _show_and_run cd magic_enum
    _show_and_run git checkout v$ver
    _show_and_run rm -rf build
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    echo -e "${INFO}magic_enum $ver${NOC} is installed:"
    _verify_header_files magic_enum.hpp /usr/local/include
    _verify_cmake_files magic_enumConfig.cmake /usr/local/lib/cmake/magic_enum
    _verify_cmake_files magic_enumConfigVersion.cmake /usr/local/lib/cmake/magic_enum
    head -n 8 /usr/local/include/magic_enum.hpp

    _popd_quiet
}

# =============================================================================
# testing on Ubuntu 18.04
function _dj_setup_mbed() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run _install_if_not_installed mercurial git
    # install mbed-cli
    _show_and_run python3 -m pip install mbed-cli
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

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf mbed-cli
    git clone https://github.com/ARMmbed/mbed-cli
    _show_and_run cd mbed-cli/tools/bash_completion
    _show_and_run sudo cp mbed /usr/share/bash-completion/completions/
    cat <<eom
--------------------------------------------
mbed tab-completion is installed to
    /usr/share/bash-completion/completions/mbed
--------------------------------------------
eom
    _press_enter_to_continue 10

    # install mbed-studio

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run wget https://studio.mbed.com/installers/latest/linux/MbedStudio.sh
    _show_and_run chmod +x MbedStudio.sh
    _show_and_run ./MbedStudio.sh
    # reading the long license, is there a way to jump it?

    # install some python moudles
    _show_and_run python3 -m pip install jsonschema
    _show_and_run python3 -m pip install mbed_cloud_sdk
    _show_and_run python3 -m pip install mbed_ls
    _show_and_run python3 -m pip install mbed_host_tests
    _show_and_run python3 -m pip install mbed_greentea
    _show_and_run python3 -m pip install manifest_tool
    _show_and_run python3 -m pip install icetea
    _show_and_run python3 -m pip install pycryptodome
    _show_and_run python3 -m pip install cryptography

    _popd_quiet
}

# =============================================================================
# https://wiki.crowncloud.net/How_To_Install_Duf_On_Ubuntu_22_04?How_to_Install_Latest_MongoDB_on_Ubuntu_22_04
function _dj_setup_mongodb() {
    uname_a=$(uname -a)
    if [[ ! "${ubuntu_v}" = *'20.04'* && ! "${ubuntu_v}" = *'22.04'* && ! "${uname_a}" = *'x86_64'* ]]; then
        echo_warn "dj setup mongodb: only tested on x86_64 Ubuntu 20.04/22.04, exit!"
        return
    fi

    _show_and_run sudo apt-get update -y
    _show_and_run _install_if_not_installed dirmngr gnupg apt-transport-https \
        ca-certificates software-properties-common libssl1.1
    # install libssl1.1 (https://askubuntu.com/a/1403683)

    v=$(_find_package_version mongodb)
    _echo_install mongodb $v
    wget -qO - https://www.mongodb.org/static/pgp/server-$v.asc |
        sudo gpg -o /usr/share/keyrings/mongodb-server-$v.gpg \
            --dearmor

    if [[ "${ubuntu_v}" = *'20.04'* ]]; then
        codename="focal"
    elif [[ "${ubuntu_v}" = *'22.04'* ]]; then
        codename="jammy"
    fi

    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-$v.gpg] https://repo.mongodb.org/apt/ubuntu $codename/mongodb-org/$v multiverse" |
        sudo tee /etc/apt/sources.list.d/mongodb-org-$v.list

    _show_and_run sudo apt update -y
    _show_and_run sudo apt install -y mongodb-org

    # Enable and start MongoDB Deamon program
    sudo systemctl enable --now mongod

    cat <<eom

--------------------------------------------
MongoDB install:
    mongodb-org-server - mongodb守护程序以及相应的初始化脚本和配置
    mongodb-org-mongos - mongos守护程序
    mongodb-org-shell  - mongo shell, 它是MongoDB的交互式JavaScript接口。
                         它用于执行命令行中的管理任务。
    mongodb-org-tools  - 包含几个用于导入和导出数据, 统计信息以及其他实用程序的MongoDB工具

Enable and start MongoDB Deamon program:
    $ sudo systemctl enable --now mongod
    $ sudo systemctl start mongod

Check if MongoDB is running:
    $ sudo systemctl status mongod

Check if MongoDB is installed:
    $ mongo --eval 'db.runCommand({ connectionStatus: 1 })'
    or (for newer version)
    $ mongosh --eval 'db.runCommand({ connectionStatus: 1 })'
--------------------------------------------
eom
}

# =============================================================================
function _dj_stup_network_tools() {
    echo -e "install ${INFO}nethogs${NOC}, ${INFO}iptraf${NOC}"
    _show_and_run _install_if_not_installed nethogs iptraf

    echo -e "install ${INFO}mNet-Assist${NOC}"
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf m-net-assist
    _show_and_run git clone https://github.com/dj-zhou/m-net-assist.git
    _show_and_run cd m-net-assist
    # does it support new Ubuntu system?
    _show_and_run sudo dpkg -i mNetAssist-release-amd64.deb

    _popd_quiet
}

# =============================================================================
function _dj_setup_nlohmann_json3_dev() {
    _show_and_run _pushd_quiet ${PWD}

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

    _show_and_run sudo rm -rf /usr/local/lib/pkgconfig/nlohmann_json.pc

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run rm -rf json
    _show_and_run git clone https://github.com/nlohmann/json.git
    _show_and_run cd json
    _show_and_run git checkout $v
    _show_and_run rm -rf build
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake ..
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    _popd_quiet

    echo -e "${INFO}nlohmann-json3 $v${NOC} is installed:"
    _verify_header_files json.hpp /usr/local/include/nlohmann
    _verify_cmake_files nlohmann_jsonConfig.cmake /usr/local/share/cmake/nlohmann_json
    _verify_pkgconfig_file nlohmann_json.pc /usr/local/share/pkgconfig
}

# =============================================================================
# use nvm (node version management) to install nodejs
# https://github.com/nvm-sh/nvm#installing-and-updating
# https://stackoverflow.com/a/36401038
function _dj_setup_nodejs() {

    if [ $system = 'Linux' ]; then
        _show_and_run _install_if_not_installed git-core curl build-essential openssl libssl-dev
    fi
    _show_and_run _pushd_quiet ${PWD}
    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    v=$(_find_package_version nodejs)
    # nodejs is a huge package, do not build it from scratch
    if [[ ! -d node ]]; then
        _show_and_run git clone https://github.com/nodejs/node.git
        _show_and_run cd node
    else
        _show_and_run cd node
        _show_and_run git checkout master
        _show_and_run git fetch -p
        _show_and_run git pull
    fi
    _show_and_run git checkout v$v
    _show_and_run ./configure
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    _popd_quiet
}

# =============================================================================
# this may only work on desktop computer
# nvidia-driver-455 is good at time of this commit
function _dj_setup_nvidia() {
    _show_and_run _install_if_not_installed libncurses5-dev
    if [[ ! -f /etc/apt/sources.list.d/graphics-drivers*.list ]]; then
        _show_and_run sudo add-apt-repository ppa:graphics-drivers/ppa
        _show_and_run sudo apt-get -y update
    fi
    if [[ "${ubuntu_v}" = *'18.04'* ]]; then
        _show_and_run sudo apt install -y nvidia-driver-455 nvidia-settings
    elif [[ "${ubuntu_v}" = *'20.04'* ]]; then
        _show_and_run sudo apt install -y nvidia-driver-470 nvidia-settings
    elif [[ "${ubuntu_v}" = *'22.04'* ]]; then
        _show_and_run sudo apt install -y nvidia-driver-525 nvidia-settings
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
    _show_and_run _pushd_quiet ${PWD}
    if [[ "${ubuntu_v}" != *'18.04'* &&
        "${ubuntu_v}" != *'20.04'* &&
        "${ubuntu_v}" != *'22.04'* ]]; then
        echo_error "dj setup nvtop: not tested platform, exit."
        return
    fi

    _install_if_not_installed libudev-dev libdrm-dev libdrm-amdgpu1

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    _show_and_run rm -rf nvtop
    _show_and_run git clone https://github.com/Syllo/nvtop.git
    _show_and_run cd nvtop
    _show_and_run mkdir -p build
    _show_and_run cd build
    _show_and_run cmake .. -DNVML_RETRIEVE_HEADER_ONLINE=True
    _show_and_run make -j$(nproc)
    _show_and_run sudo make install

    _popd_quiet
}

# =============================================================================
function _dj_setup_qt_5_13_1() {
    _show_and_run _pushd_quiet ${PWD}

    echo -e "install Qt 5.13.1 \n"

    # install serialport module
    _show_and_run _install_if_not_installed libqt5serialport5-dev

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    # check if the file exists --------------------
    filename="qt-opensource-linux-x64-5.13.1.run"
    url=http://qt.mirror.constant.com/archive/qt/5.13/5.13.1/$filename
    _wget_if_not_exist $filename "21c3b16f851697fa8da8009f73694373" $url
    chmod +x $filename

    echo -e "It is recommended to install the Qt into ${HOME}/Qt5.13.1/"
    _press_enter_or_wait_s_continue 5

    ./$filename

    # setup the PATH and LD_LIBRARY_PATH into $rc_file
    echo -e '\n' >>$rc_file
    echo '# ===========================================================' >>$rc_file
    echo '# Qt5.13.1 setup (djtools)' >>$rc_file
    echo 'export PATH=~/Qt5.13.1/5.13.1/gcc_64/bin:$PATH' >>$rc_file
    echo 'export LD_LIBRARY_PATH=~/Qt5.13.1/5.13.1/gcc_64/lib:$LD_LIBRARY_PATH' >>$rc_file
    echo -e "PATH and LD_LIBRARY_PATH are set in $rc_file.\n"

    _popd_quiet
}

# =============================================================================
function _dj_setup_qt_5_14_2() {
    _show_and_run _pushd_quiet ${PWD}

    echo -e "\nInstall Qt 5.14.2\n"
    _press_enter_or_wait_s_continue 5

    # install serialport module
    _show_and_run _install_if_not_installed libqt5serialport5-dev

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    # check if the file exists --------------------
    filename="qt-opensource-linux-x64-5.14.2.run"
    url=http://qt.mirror.constant.com/archive/qt/5.14/5.14.2/$filename
    _show_and_run _wget_if_not_exist $filename "dce0588874fd369ce493ea5bc2a21d99" $url
    _show_and_run chmod +x $filename

    echo -e "It is recommended to install the Qt into ${HOME}/Qt5.14.2/"
    _press_enter_or_wait_s_continue 10

    _show_and_run ./$filename

    # setup the PATH and LD_LIBRARY_PATH into $rc_file
    echo -e '\n' >>$rc_file
    echo '# ===========================================================' >>$rc_file
    echo '# Qt5.14.2 setup (djtools)' >>$rc_file
    echo 'export PATH=~/Qt5.14.2/5.14.2/gcc_64/bin:$PATH' >>$rc_file
    echo 'export LD_LIBRARY_PATH=~/Qt5.14.2/5.14.2/gcc_64/lib:$LD_LIBRARY_PATH' >>$rc_file
    echo -e "PATH and LD_LIBRARY_PATH are set in $rc_file.\n"

    _popd_quiet
}

# =============================================================================
function _dj_setup_rpi_pico() {
    _pushd_quiet ${PWD}

    # install dependencies
    _show_and_run _install_if_not_installed libnewlib-arm-none-eabi \
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
            echo -e "you can still revise $rc_file for manual setup."
            installed=1
        fi
    done <$rc_file
    if [[ $installed = '0' ]]; then
        echo -e '\n' >>$rc_file
        echo '# ===========================================================' >>$rc_file
        echo '# (djtools) pico-sdk setup' >>$rc_file
        echo "export PICO_SDK_PATH=$HOME/rpi-pico/pico-sdk" >>$rc_file
    fi
    # build pico-examples
    export PICO_SDK_PATH=$HOME/rpi-pico/pico-sdk
    mkdir -p build && cd build && cmake ..
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
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run _pushd_quiet $soft_dir
    # just in case
    _show_and_run rm -rf slack-desktop*.deb

    # the download page: https://slack.com/downloads/linux
    local v=$(_find_package_version slack)
    _show_and_run wget https://downloads.slack-edge.com/releases/linux/$v/prod/x64/slack-desktop-$v-amd64.deb
    _show_and_run sudo dpkg -i slack-desktop*.deb
    _show_and_run rm slack-desktop*.deb

    # is one popd enough?
    _popd_quiet
}

# =============================================================================
function _dj_setup_saleae_logic() {
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir
    version="1.2.18"
    file="Logic $version (64-bit)"
    url="https://downloads.saleae.com/logic/"
    url="$url$version/$file.zip"
    echo $url
    _show_and_run _wget_if_not_exist "$file.zip" "8c586a272a89019540cc365c82ade451" "$url"
    _show_and_run rm -rf "$file"
    _show_and_run unzip "$file.zip"
    _show_and_run rm -rf logic
    _show_and_run mv "$file" logic
    _show_and_run sudo ln -sf ${soft_dir}/logic/Logic /usr/bin/logic

    _popd_quiet
}

# =============================================================================
function _dj_setup_serial_console() {
    _show_and_run _pushd_quiet "${PWD}"

    if [[ ${ubuntu_v} = *'22.04'* ]]; then
        _show_and_run sudo apt remove brltty
    fi

    _show_and_run _install_if_not_installed cu screen putty screen

    _show_and_run _dj_setup_cutecom
    _show_and_run _dj_setup_picocom

    _show_and_run _dj_help_cu
    _show_and_run _dj_help_screen
    _show_and_run _dj_help_pipocom

    _show_and_run _popd_quiet

    _udev_screen_tab_completion
}

# =============================================================================
function _dj_setup_sublime() {
    _pushd_quiet ${PWD}

    _show_and_run sudo apt-get update -y
    _show_and_run _install_if_not_installed apt-transport-https ca-certificates curl software-properties-common

    _show_and_run wget -nc https://download.sublimetext.com/sublimehq-pub.gpg
    cat sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-pub.gpg >/dev/null
    _show_and_run sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"
    _show_and_run sudo apt-get update -y
    _show_and_run sudo apt install sublime-text
    rm sublimehq-pub.gpg
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
function _dj_setup_thermal_printer() {
    _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    _show_and_run sudo apt-get update -y
    _show_and_run sudo apt-get upgrade -y
    _show_and_run sudo apt install cups
    _show_and_run sudo usermod -a -G lpadmin $USER

    _show_and_run rm -rf rollo
    _show_and_run mkdir rollo
    _show_and_run cd rollo
    if [[ "${ubuntu_v}" = *'Raspbian'*'bullseye'* ]]; then
        _show_and_run wget https://www.rollo.com/driver-dl/beta/rollo-driver-raspberrypi-beta.zip
        _show_and_run unzip rollo-driver-raspberrypi-beta.zip
        _show_and_run chmod +x install.run
        _show_and_run sudo ./install.run
    elif [[ "${ubuntu_v}" = *'Ubuntu'*'22'* ]]; then
        local f="rollo-driver-ubuntu_x86_64_v1.0.2"
        _show_and_run wget https://rollo-main.b-cdn.net/driver-dl/beta/${f}.tar.gz
        _show_and_run dj unpack tar.gz ${f}.tar.gz
        _show_and_run cd ${f}/${f}/ubuntu_x86_64_v1.0.2
        _show_and_run sudo ./install
    else
        echo_warn "Not tested platform, exit."
        return
    fi

    _show_and_run sudo cupsctl --remote-admin --remote-any --share-printers
    _show_and_run sudo /etc/init.d/cups restart

    _popd_quiet
}

# =============================================================================
# why this does not work with python3.9?
function _dj_setup_typora() {
    _show_and_run wget -qO - https://typoraio.cn/linux/public-key.asc | sudo tee /etc/apt/trusted.gpg.d/typora.asc
    # add Typora's repository
    _show_and_run sudo add-apt-repository 'deb https://typora.io/linux ./'
    _show_and_run sudo apt-get -y update
    # install typora
    _show_and_run sudo apt install -y typora
}

# =============================================================================
# tested: Ubuntu 18.04, Ubuntu 20.04
function _dj_setup_vscode() {
    if [ $system = 'Darwin' ]; then
        _show_and_run brew install --cask visual-studio-code
        return
    fi
    _show_and_run _pushd_quiet ${PWD}

    _show_and_run mkdir -p $soft_dir
    _show_and_run cd $soft_dir

    # install dependency
    _show_and_run _install_if_not_installed curl

    echo -e "install vscode ...\n"
    curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" >vscode.deb
    _show_and_run sudo dpkg -i vscode.deb
    _show_and_run sudo rm vscode.deb

    _popd_quiet
}

# =============================================================================
function _dj_setup_windows_fonts() {
    echo -e "going to support Windows fonts\n"
    _press_enter_or_wait_s_continue 5
    _show_and_run _install_if_not_installed ttf-mscorefonts-installer
    _show_and_run _install_if_not_installed msttcorefonts
    _show_and_run _install_if_not_installed gtk2-engines-pixbuf # works for solving the GTK warning
}

# =============================================================================
function _dj_setup_wireshark() {
    _show_and_run sudo add-apt-repository ppa:wireshark-dev/stable
    _show_and_run sudo apt-get update -y
    _show_and_run _install_if_not_installed wireshark
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
function _dj_setup() {
    case $1 in
    "abseil-cpp") _dj_setup_abseil_cpp ;;
    "adobe-pdf-reader") _dj_setup_adobe_pdf_reader ;;
    "anaconda") _dj_setup_anaconda ;;
    "ansible") _dj_setup_ansible ;;
    "arduino-ide") _dj_setup_arduino ;;
    "baidu-netdisk") _dj_setup_baidu_netdisk ;;
    "boost") _dj_setup_boost ;;
    "can-analyzer") _dj_setup_can_analyzer ;;
    "can-dev-tools") _dj_setup_can_dev_tools ;;
    "clang-format") _dj_setup_clang_format ;;
    "clang-llvm") _dj_setup_clang_llvm ;;
    "cli11") _dj_setup_cli11 ;;
    "cmake") _dj_setup_cmake ;;
    "computer") _dj_setup_computer ;;
    "cuda") _dj_setup_cuda ;;
    "cutecom") _dj_setup_cutecom ;;
    "devtools") _dj_setup_devtools ;;
    "docker") _dj_setup_docker ;;
    "docker-compose") _dj_setup_docker_compose ;;
    "driver") shift 1 && _dj_setup_driver "$@" ;;
    "dtc" | "device-tree-compiler") _dj_setup_device_tree_compiler ;;
    "eigen3") _dj_setup_eigen3 ;;
    "esp-idf") _dj_setup_esp_idf ;;
    "fast-github") _dj_setup_fast_github ;;
    "flamegraph") _dj_setup_flamegraph ;;
    "fmt") _dj_setup_fmt $2 ;;
    "foxit-pdf-reader") _dj_setup_foxit_reader ;;
    "fsm-pro") _dj_setup_fsm_pro ;;
    "gadgets") _dj_setup_gadgets ;;
    "gcc-arm-stm32") _dj_setup_gcc_arm_stm32 ;;
    "gcc-arm-linux-gnueabi") _dj_setup_gcc_arm_linux_gnueabi ;;
    "gcc-arm-linux-gnueabihf") _dj_setup_gcc_arm_linux_gnueabihf ;;
    "gcc-aarch64-linux-gnu") _dj_setup_gcc_aarch64_linux ;;
    "git-lfs") _dj_setup_git_lfs ;;
    "gitg-gitk") _dj_setup_gitg_gitk ;;
    "glfw3") _dj_setup_glfw3 ;;
    "gnuplot") _dj_setup_gnuplot ;;
    "go") _dj_setup_go ;;
    "google-repo") _dj_setup_google_repo ;;
    "gtest" | "googletest") _dj_setup_googletest ;;
    "glog") _dj_setup_glog ;;
    "gnome") _dj_setup_gnome ;;
    "grpc") _dj_setup_grpc ;;
    "g++-10") _dj_setup_gpp_10 ;;
    "g++-11") _dj_setup_gpp_11 ;;
    "htop") _dj_setup_htop ;;
    "i219-v") _dj_setup_i219_v $2 ;;
    "kdiff3") _dj_setup_kdiff3 ;;
    "kermit") _dj_setup_kermit ;;
    "lcm") _dj_setup_lcm ;;
    "libbpf") _dj_setup_libbpf ;;
    "libcsv-3.0.2") _dj_setup_libcsv_3_0_2 ;;
    "libev") _dj_setup_libev ;;
    "libgpiod") _dj_setup_libgpiod ;;
    "libiio") _dj_setup_libiio ;;
    "libserialport") _dj_setup_libserialport ;;
    "libsystemd") _dj_setup_libsystemd ;;
    "yaml-cpp") _dj_setup_yaml_cpp ;;
    "magic-enum") _dj_setup_magic_enum ;;
    "mbed") _dj_setup_mbed ;;
    "meson-ninja") _dj_setup_meson_ninjia ;;
    "mongodb") _dj_setup_mongodb ;;
    "network-tools") _dj_stup_network_tools ;;
    "nlohmann-json3-dev") _dj_setup_nlohmann_json3_dev ;;
    "nodejs") _dj_setup_nodejs ;;
    "nvidia") _dj_setup_nvidia ;;
    "nvtop") _dj_setup_nvtop ;;
    "opencv-3.4.13") _dj_setup_opencv_3_4_13 ;;
    "opencv-4.5.5") _dj_setup_opencv_4_5_5 ;;
    "pangolin") _dj_setup_pangolin ;;
    "perf") _dj_setup_perf ;;
    "picocom") _dj_setup_picocom ;;
    "pip") _dj_setup_pip ;;
    "plotjuggler") _dj_setup_plotjuggler ;;
    "protobuf") _dj_setup_protobuf ;;
    "pycharm") _dj_setup_pycharm ;;
    "python3.10") _dj_setup_python_3_10 ;;
    "python3.11") _dj_setup_python_3_11 ;;
    "qemu") shift 1 && _dj_setup_qemu "$@" ;;
    "qt-5.13.1") _dj_setup_qt_5_13_1 ;;
    "qt-5.14.2") _dj_setup_qt_5_14_2 ;;
    "ros2-foxy") shift 1 && _dj_setup_ros2_foxy "$@" ;;
    "ros2-humble") shift 1 && _dj_setup_ros2_humble "$@" ;;
    "rpi-pico") _dj_setup_rpi_pico ;;
    "rust") shift 1 && _dj_setup_rust "$@" ;;
    "saleae-logic") _dj_setup_saleae_logic ;;
    "serial-console") _dj_setup_serial_console ;;
    "slack") _dj_setup_slack ;;
    "spdlog") _dj_setup_spdlog ;;
    "stm32-cube-ide") _dj_setup_stm32_cube_ide ;;
    "stm32-cube-ide-desktop-item") shift 1 && _dj_setup_stm32_cube_ide_desktop_item "$@" ;;
    "stm32-cube-mx") shift 1 && _dj_setup_stm32_cube_mx "$@" ;;
    "stm32-cube-mx-desktop-item") shift 1 && _dj_setup_stm32_cube_mx_desktop_item "$@" ;;
    "stm32-cube-programmer") shift 1 && _dj_setup_stm32_cube_programmer "$@" ;;
    "stm32-tools") shift 1 && _dj_setup_stm32_tools "$@" ;;
    "sublime") _dj_setup_sublime ;;
    "texlive") _dj_setup_texlive ;;
    "thermal-printer") _dj_setup_thermal_printer ;;
    "typora") _dj_setup_typora ;;
    "vscode") _dj_setup_vscode ;;
    "windows-fonts") _dj_setup_windows_fonts ;;
    "wireshark") _dj_setup_wireshark ;;
    "wubi") _dj_setup_wubi ;;
    *) echo -e "dj setup: argument \"$1\" is not supported." ;;
    esac
}
