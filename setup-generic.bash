#!/bin/bash

# =============================================================================
function _dj_setup_help()
{
    _dj_help
    echo "--------------------- dj setup ----------------------"
    echo " Second level commands:"
    echo "   arm-gcc          - to install arm-gcc-embedded compiler"
    echo "   clang-8.0.0      - to install clang v8.0.0 for use of vscode"
    echo "   computer         - to pre install lots of necessary"
    echo "                      software package"
    echo "   dropbox          - to install dropbox"
    echo "   eigen            - to install eigen library"
    echo "   foxit            - to install foxit pdf reader"
    echo "   glfw3-gtest-glog - to install glfw3/gtest/glog"
    echo "   i219-v           - to install Intel I219-V WiFi chipset"
    echo "                      driver"
    echo "   opencv-2.4.13    - to install OpenCV version 2.4.13"
    echo "   opencv-4.1.1     - to install OpenCV version 4.1.1"
    echo "   pangolin         - to install openGL based visualization package"
    echo "   pip              - to install python software pip"
    echo "   qt-5.11.2        - to install Qt version 5.11.2"
    echo "   qt-5.13.1        - to install Qt version 5.13.1"
    echo "   ros-melodic      - to install ROS Melodic (Ubuntu 18.04)"
    echo "   shadowsocks      - to install a vpn tool"
    echo "   stm32tools       - to install stm32 tool"
    echo "   sublime          - to install sublime-text-3"
    echo "   vscode           - to install VS Code"
    echo "   typora           - to install Markdown editor typora"
    echo "   vtk-8.2.0        - to install visualization tool vtk-8.2.0"
    echo "   wubi             - to install Chinese wubi input method"
    echo "   yaml-cpp         - to install C++ based yaml file parser"
    echo "   MORE IS COMMING"
    echo -e "-----------------------------------------------------\n"
}

# =============================================================================
function _dj_setup_baidu_netdisk()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ &&  cd soft/

    file="baidunetdisk_linux_3.0.1.2.deb"
    curl -L http://wppkg.baidupcs.com/issue/netdisk/LinuxGuanjia/3.0.1/$file > $file

    sudo dpkg -i $file
    
    cd $current_folder
    unset current_folder
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
    echo -e "\n going to install the following packages: "
    echo "      ark cmake curl cutecom dconf-editor dconf-tools git "
    echo "      git-lfs g++ htop kate libgtk2.0-dev lsb-core putty "
    echo -e "      screen scrot terminator tree vlc vim wmctrl xclip yasm\n"

    echo "how to use cu and screen:"
    echo "      cu: cu -l /dev/ttyUSB0 -s 115200 [ENTER]"
    echo "  screen: screen /dev/ttyUSB0 115200 [ENTER]"
    echo "exit methods for cu and screen:"
    echo "      cu: input ~. and then [ENTER]"
    echo "  screen: press Ctrl+A and then \, and [y]"

    _press_enter_to_continue

    sudo apt-get install -y ark cmake curl cutecom dconf-editor dconf-tools git
    sudo apt-get install -y git-lfs g++ htop kate libgtk2.0-dev lsb-core putty
    sudo apt-get install -y screen scrot terminator tree vlc vim wmctrl xclip yasm

    # -----------------------------------
    echo -e "\n going to install Google Chrome\n"
    _press_enter_to_continue
    cd ~ && mkdir -p soft/ &&  cd soft/
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome*

    _ask_to_remove_a_file google-chrome*
    cd ~

    # -----------------------------------
    # Windows fonts
    echo -e "\n going to support Windows fonts\n"
    _press_enter_to_continue
    sudo apt-get install ttf-mscorefonts-installer -y
    sudo apt-get install msttcorefonts -y
    sudo apt-get install gtk2-engines-pixbuf -y # works for solving the GTK warning

    # -----------------------------------
    # remove firefox
    echo -e "\n going to remove firfox\n"
    _press_enter_to_continue
    sudo apt-get purge firefox -y; rm -Rf ~/.mozilla/firefox/;

    # -----------------------------------
    # to display simplified Chinese: important, do not comment out!
    echo -e "\n going to setup simplified Chinese support\n"
    _press_enter_to_continue
    gnome_version=$(version check gnome)
    if [ ! $gnome_version = ' ' ] ; then
        gsettings set org.gnome.gedit.preferences.encodings \
            auto-detected "['CURRENT','GB18030','GBK','GB2312','UTF-8','UTF-16']"
    fi
    # -----------------------------------
    # to disable the fixed dock (in dock setting, it is Auto-hide the Dock option)
    echo -e "\n hide the Dock when any windows overlap with it\n"
    _press_enter_to_continue
    if [ ! $gnome_version = ' ' ] ; then
        gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    fi
    # -----------------------------------
    # to lock the screen from commands
    echo -e "\n going to setup lock screen command\n"
    _press_enter_to_continue
    if [ ! $gnome_version = ' ' ] ; then
        sudo apt-get install gnome-screensaver -y
    fi
    # -----------------------------------
    echo -e "\n time & date control: \n you need to run the code:\n"
    echo -e "    timedatectl set-local-rtc 1   \n"    

    cd $current_folder
}

# =============================================================================
function _dj_setup_dropbox()
{
    current_folder=${PWD}

    sudo apt-get --fix-broken install
    sudo apt-get install libpango1.0-0 -y
    sudo apt-get install curl -y
    # how to deal with version?

    cd ~ && mkdir -p soft/ &&  cd soft/

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
function _dj_setup_eigen()
{
    current_folder=${PWD}

    sudo apt-get install libeigen3-dev -y
    sudo updatedb
    # locate eigen3
    echo -e "\n eigen is installed in: /usr/include/eigen3\n"

    cd $current_folder
}


# =============================================================================
function _dj_setup_foxit_reader()
{
    current_folder=${PWD}

    echo -e "\n install Foxit Reader ..."
    echo -e "  recommended location: /opt/foxitsoftware/foxitreader\n"
    _press_enter_to_continue

    cd ~ && mkdir -p soft/ &&  cd soft/

    # no way to get the latest version?
    file=FoxitReader.enu.setup.2.4.4.0911.x64.run
    wget http://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/$file.tar.gz
    gzip -d $file.tar.gz
    tar xvf $file.tar
    sudo ./FoxitReader*.run

    # create a symbolic link
    foxitreader_location=$(sudo find /opt -name "FoxitReader")
    echo $foxitreader_location
    if [ ! -z $foxitreader_location ] ; then
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
    _press_enter_to_continue
    sudo apt-get install -y gcc-aarch64-linux-gnu gcc-5-aarch64-linux-gnu
    sudo apt-get install -y libssl-dev # needed for compiling the Linux Kernel for ARMv8

    # update-alternatives configuration
    sudo update-alternatives --install \
        /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc \
        /usr/bin/aarch64-linux-gnu-gcc-5 5
    sudo update-alternatives --install \
        /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc \
        /usr/bin/aarch64-linux-gnu-gcc-7 7

    echo -e "\n-------------------\n"
    sudo update-alternatives --config aarch64-linux-gnu-gcc

    cd $current_folder
    unset current_folder
}

# =============================================================================
# for Ubuntu 20.04:
# https://askubuntu.com/questions/1243252/how-to-install-arm-none-eabi-gdb-on-ubuntu-20-04-lts-focal-fossa
function _dj_setup_gcc_arm_embedded()
{
    current_folder=${PWD}

    echo -e "\n remove gcc-arm-none-eabi, and install gcc-arm-embedded ...\n"
    _press_enter_to_continue

    cd ~ && mkdir -p soft/ &&  cd soft/

    sudo apt-get install -y build-essential git flex bison libgmp3-dev libmpfr-dev 
    sudo apt-get install -y libncurses5-dev libmpc-dev autoconf texinfo libtool
    sudo apt-get install -y libftdi-dev libusb-1.0-0-dev zlib1g zlib1g-dev python-yaml
    sudo apt-get install -y libncurses-dev

    if [[ ${ubuntu_release_version} = *'18.04'* ]] ; then
        sudo echo "deb http://kr.archive.ubuntu.com/ubuntu bionic main universe" \
        | sudo tee -a /etc/apt/sources.list
    elif  [[ ${ubuntu_release_version} = *'16.04'* ]] ; then
        echo "just do nothing"
    fi
    if [[ ${ubuntu_release_version} = *'18.04'* || \
          ${ubuntu_release_version} = *'16.04'* ]] ; then
        sudo apt-get remove gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi
        sudo apt-add-repository ppa:team-gcc-arm-embedded/ppa
        sudo apt-get update
        sudo apt-get install gcc-arm-embedded -y

        echo -e "\n"
        echo " (just maybe) gcc-arm-embedded is installed in /usr/share/gcc-arm-embedded/"
        echo " (question) Is there still an arm-none-eabi? "
        echo -e "\n"
    elif [[ ${ubuntu_release_version} = *'20.04'* ]] ;then
        sudo apt remove gcc-arm-none-eabi
        compiler_date="9-2020"
        compiler_q="q2"
        url="https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm"
        file="gcc-arm-none-eabi-${compiler_date}-${compiler_q}-update"
        filename="${file}-x86_64-linux.tar.bz2"
        # check if the file exists --------------------
        unset md5checksum
        if [[ -f $filename ]] ; then
            md5checksum=`md5sum $filename`
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
    _press_enter_to_continue
    sudo apt-get install -y libncurses5-dev build-essential
    sudo apt-get install -y gcc-arm-linux-gnueabi gcc-5-arm-linux-gnueabi
    sudo apt-get install -y g++-arm-linux-gnueabi g++-5-arm-linux-gnueabi

    # update-alternatives configuration
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

    cd $current_folder
    unset current_folder
}
# =============================================================================
function _dj_setup_gcc_arm_linux_gnueabihf()
{
    current_folder=${PWD}

    echo -e "\n install gcc-arm-linux-gnueabihf ...\n"
    _press_enter_to_continue
    sudo apt-get install -y libncurses5-dev build-essential
    sudo apt-get install -y gcc-arm-linux-gnueabihf gcc-5-arm-linux-gnueabihf
    sudo apt-get install -y g++-arm-linux-gnueabihf g++-5-arm-linux-gnueabihf

    # update-alternatives configuration
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

    cd $current_folder
    unset current_folder
}

# =============================================================================
function _dj_setup_git_lfs()
{
    current_folder=${PWD}
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install git-lfs
    cd $current_folder
}

# =============================================================================
function _dj_setup_gitg_kdiff3()
{
    current_folder=${PWD}

    echo -e "\n install gitg and KDiff3 ...\n"
    _press_enter_to_continue # to check the key pressed TODO
    sudo apt-get install gitg kdiff3 -y
    git config --global credential.helper store
    # git config --global credential.helper 'cache --timeout=36000'  
    git config --global --add merge.tool kdiff3
    git config --global --add diff.guitool kdiff3

    cd $current_folder
}

# =============================================================================
# make sure the related package is public available in dj-zhou's github
function _dj_setup_i219_v()
{
    current_folder=${PWD}

    cd ~
    
    git clone https://dj-zhou@github.com/dj-zhou/i219-v.git
    cd $1/src/
    sudo make install

    cd ~
    _ask_to_remove_a_folder ~/i219-v

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
function _dj_setup_libev_4_33()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ &&  cd soft/

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
function _dj_setup_mathpix()
{
    sudo apt install snapd
    sudo snap install mathpix-snipping-tool
}

# =============================================================================
function _dj_setup_matplotlib_cpp()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ &&  cd soft/

    git clone https://github.com/dj-zhou/matplotlib-cpp.git
    cd matplotlib-cpp
    git checkout install-zdj
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install
    cd ~/soft
    _ask_to_remove_a_folder matplotlib-cpp

    cd $current_folder
}

# =============================================================================
function _dj_setup_qt_5_13_1()
{
    cwd_before_running=$PWD

    echo -e "\n install Qt 5.13.1 \n"
    
    # install serialport module
    sudo apt-get install libqt5serialport5-dev -y

    cd ~ && mkdir -p soft/ &&  cd soft/
    filename="qt-opensource-linux-x64-5.13.1.run"

    # check if the file exists --------------------
    unset md5checksum
    if [[ -f $filename ]] ; then
        md5checksum=`md5sum $filename`
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
    _press_enter_to_continue

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
    _press_enter_to_continue
    
    # install serialport module
    sudo apt-get install libqt5serialport5-dev -y

    cd ~ && mkdir -p soft/ &&  cd soft/
    http://qt.mirror.constant.com/archive/qt/5.14/5.14.2/qt-opensource-linux-x64-5.14.2.run
    filename="qt-opensource-linux-x64-5.14.2.run"

    # check if the file exists --------------------
    unset md5checksum
    if [[ -f $filename ]] ; then
        md5checksum=`md5sum $filename`
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
    _press_enter_to_continue

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

    cd ~ && mkdir -p soft/ &&  cd soft/
    
    # install dependency
    sudo apt-get install -y curl

    echo -e "\n install vscode ...\n"
    curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
    sudo dpkg -i vscode.deb
    sudo rm vscode.deb

    echo -e "\n recommended vscode plugins:"
    echo    "         bitbake: BitBake recipe language support in Visual Studio Code "
    echo    "     CMake Tools: Extended CMake support in Visual Studio Code "
    echo    "      DeviceTree: DeviceTree Language Support for Visual Studio Code "
    echo    "         GitLens: Supercharge the Git capabilities built into Visual "
    echo    "                  Studio Code — Visualize code authorship at a glance "
    echo    "                  via Git blame annotations and code le"
    echo    "  LaTeX Workshop: Boost LaTeX typesetting efficiency with preview, "
    echo    "                  compile, autocomplete, colorize, and more. "
    echo    "          Python: Linting, Debugging (multi-threaded, remote), "
    echo    "                  Intellisense, Jupyter Notebooks, code formatting, "
    echo    "                  refactoring, unit tests, snippets, and more. "
    echo    "           C/C++: C/C++ IntelliSense, debugging, and code browsing."
    echo -e "      Bash Debug: A debugger extension for bash scripts (using bashdb). \n"

    cd $current_folder
}

# =============================================================================
# make sure the related package is public available in dj-zhou's github
# compile from the source code will install it to
#   /usr/local/lib/libyaml-cpp.a
# apt-get will install it to
#  /usr/lib/ -----not tested yet!
function _dj_setup_yaml_cpp()
{
    cwd_before_running=$PWD

    # cd ~ && mkdir -p soft/ &&  cd soft/
    # git clone https://dj-zhou@github.com/dj-zhou/yaml-cpp.git
    # cd yaml-cpp
    # sudo rm -rf build/ && mkdir build
    # cd build && cmake -DYAML_BUILD_SHARED_LIBS=ON ..
    # make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    # sudo make install

    # echo " "
    # echo "libyaml-cpp.a is installed in /usr/local/lib/"
    # echo "header files are installed in /usr/local/include/yaml-cpp/"
    # echo " "

    # _ask_to_remove_a_folder yaml-cpp/

    # a better way to install it
    sudo apt-get update
    sudo apt-get install libyaml-cpp-dev -y

    # to show the version
    sudo apt show libyaml-cpp-dev

    echo -e '\n if the version is NOT 0.5.2, it may have some problem.\n'

    cd ${cwd_before_running}
}
