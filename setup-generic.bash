#!/bin/bash

# ===========================================================================================
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
    echo "-----------------------------------------------------"
    echo " "
}

# ===========================================================================================
function _dj_setup_arm_gcc()
{
    current_folder=${PWD}

    echo " "
    echo "  remove gcc-arm-none-eabi, and install gcc-arm-embedded ..." 
    echo " "
    sleep 2
    sudo apt-get install -y build-essential git flex bison libgmp3-dev libmpfr-dev 
    sudo apt-get install -y libncurses5-dev libmpc-dev autoconf texinfo libtool
    sudo apt-get install -y libftdi-dev libusb-1.0-0-dev zlib1g zlib1g-dev python-yaml
    
    if [[ ${ubuntu_release_version} = *'18.04'* ]] ; then
        sudo echo "deb http://kr.archive.ubuntu.com/ubuntu bionic main universe" | sudo tee -a /etc/apt/sources.list
    elif  [[ ${ubuntu_release_version} = *'16.04'* ]] ; then
        echo "just do nothing"
    fi

    sudo apt-get remove gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi
    sudo apt-add-repository ppa:team-gcc-arm-embedded/ppa
    sudo apt-get update
    sudo apt-get install gcc-arm-embedded -y

    echo " "
    echo " (just maybe) gcc-arm-embedded is installed in /usr/share/gcc-arm-embedded/"
    echo " (question) Is there still an arm-none-eabi? "
    echo " "

    cd $current_folder
    unset current_folder
}

# ===========================================================================================
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

# ===========================================================================================
function _dj_setup_computer()
{
    current_folder=${PWD}

    cd ~

    # -----------------------------------
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # -----------------------------------
    echo " "
    echo "  going to install the following packages: "
    echo "      curl g++ git vim terminator kate scrot wmctrl  "
    echo "      dconf-editor dconf-tools vlc cutecom xclip tree "
    echo "      ark yasm cmake libgtk2.0-dev htop lsb-core "
    echo " "
    _press_enter_to_continue
    sudo apt-get install curl g++ git vim terminator kate scrot wmctrl -y
    sudo apt-get install dconf-editor dconf-tools vlc cutecom xclip tree -y
    sudo apt-get install ark yasm cmake libgtk2.0-dev htop lsb-core -y

    # -----------------------------------
    echo " "
    echo "  going to install Google Chrome "
    echo " "
    _press_enter_to_continue
    cd ~ && mkdir -p soft/ &&  cd soft/
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome*

    _ask_to_remove_a_file google-chrome*
    cd ~

    # -----------------------------------
    # Windows fonts
    echo " "
    echo "  going to support Windows fonts "
    echo " "
    _press_enter_to_continue
    sudo apt-get install ttf-mscorefonts-installer -y
    sudo apt-get install msttcorefonts -y
    sudo apt-get install gtk2-engines-pixbuf -y # works for solving the GTK warning

    # -----------------------------------
    # remove firefox
    echo " "
    echo "  going to remove firfox "
    echo " "
    _press_enter_to_continue
    sudo apt-get purge firefox -y; rm -Rf ~/.mozilla/firefox/;

    # -----------------------------------
    # to display simplified Chinese: important, do not comment out!
    echo " "
    echo "  going to setup simplified Chinese support "
    echo " "
    _press_enter_to_continue
    gsettings set org.gnome.gedit.preferences.encodings auto-detected "['CURRENT','GB18030','GBK','GB2312','UTF-8','UTF-16']"
    
    # -----------------------------------
    # to disable the fixed dock (in dock setting, it is Auto-hide the Dock option)
    echo " "
    echo "  hide the Dock when any windows overlap with it "
    echo " "
    _press_enter_to_continue
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false

    # -----------------------------------
    # to lock the screen from commands
    echo " "
    echo "  going to setup lock screen command "
    echo " "
    _press_enter_to_continue
    sudo apt-get install gnome-screensaver -y

    # -----------------------------------
    echo " "
    echo "  going to setup time & date control"
    echo " "
    _press_enter_to_continue
    timedatectl set-local-rtc 1

    cd $current_folder
}

# ===========================================================================================
function _dj_setup_dropbox()
{
    current_folder=${PWD}

    sudo apt-get install libpango1.0-0 -y
    sudo apt-get --fix-broken install
    # how to deal with version?

    cd ~ && mkdir -p soft/ &&  cd soft/

    curl -L https://linux.dropbox.com/packages/ubuntu/dropbox_2020.03.04_amd64.deb > dropbox.deb
    sudo dpkg -i dropbox.deb
    
    _ask_to_remove_a_file dropbox.deb
    
    echo " "
    echo " You can run the following command to setup the Dropbox"
    echo "   dropbox start -i"
    echo " "

    cd $current_folder
}

# ===========================================================================================
function _dj_setup_eigen()
{
    current_folder=${PWD}

    sudo apt-get install libeigen3-dev -y
    sudo updatedb
    # locate eigen3
    echo " "
    echo " eigen is installed in: /usr/include/eigen3"
    echo " "

    cd $current_folder
}

# ===========================================================================================
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

# ===========================================================================================
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
        echo 'export LD_LIBRARY_PATH=/usr/local/lib:'$LD_LIBRARY_PATH >> ~/.bashrc
    fi

    cd ~/soft
    _ask_to_remove_a_folder $file
    _ask_to_remove_a_file $file.tar.gz

    cd $current_folder
}

# ===========================================================================================
function _dj_setup_mathpix()
{
    sudo apt install snapd
    sudo snap install mathpix-snipping-tool
}

# ===========================================================================================
function _dj_setup_foxit_reader()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ &&  cd soft/

    # no way to get the latest version?
    wget http://cdn01.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/FoxitReader.enu.setup.2.4.4.0911.x64.run.tar.gz
    gzip -d FoxitReader.enu.setup.2.4.4.0911.x64.run.tar.gz
    tar xvf FoxitReader.enu.setup.2.4.4.0911.x64.run.tar
    sudo ./FoxitReader.enu.setup.*.run

    cd $current_folder
}

# ===========================================================================================
function _dj_setup_gitg_kdiff3()
{
    current_folder=${PWD}

    echo " "
    echo "  Install gitg and KDiff3 ..." 
    echo " "
    # sleep 2
    _press_enter_to_continue # to check the key pressed TODO
    sudo apt-get install gitg kdiff3 -y
    git config --global credential.helper store
    # git config --global credential.helper 'cache --timeout=36000'  
    git config --global --add merge.tool kdiff3
    git config --global --add diff.guitool kdiff3

    cd $current_folder
}

# ===========================================================================================
function _dj_setup_vscode()
{
    current_folder=${PWD}

    cd ~ && mkdir -p soft/ &&  cd soft/

    echo " "
    echo "  Install vscode ..." 
    echo " "
    sleep 2 
    curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
    sudo dpkg -i vscode.deb
    sudo rm vscode.deb

    cd $current_folder
}

# ===========================================================================================
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

# ===========================================================================================
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

    echo ' '
    echo ' if the version is NOT 0.5.2, it may have some problem.'
    echo ' '

    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_qt_5_11_2()
{
    cwd_before_running=$PWD

    echo "  "
    echo "Install Qt 5.11.2" 
    echo "  "
    sleep 2

    cd ~ && mkdir -p soft/ &&  cd soft/
    filename="qt-opensource-linux-x64-5.11.2.run"
    wget http://qt.mirror.constant.com/archive/qt/5.11/5.11.2/$filename
    chmod +x $filename
    
    ./$filename

    _ask_to_remove_a_file $filename
    
    # install serialport module
    sudo apt-get install libqt5serialport5-dev -y

    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_qt_5_13_1()
{
    cwd_before_running=$PWD

    echo "  "
    echo "Install Qt 5.13.1" 
    echo "  "
    sleep 2
    
    # install serialport module
    sudo apt-get install libqt5serialport5-dev -y

    cd ~ && mkdir -p soft/ &&  cd soft/
    filename="qt-opensource-linux-x64-5.13.1.run"

    # check if the file exists --------------------
    unset md5checksum
    if [[ -f $filename ]] ; then
        md5checksum=`md5sum $filename`
        echo "md5checksum="$md5checksum
    fi
    if [[ "$md5checksum" = *"21c3b16f851697fa8da8009f73694373"* ]] ; then
        echo "file exists, no need to download again"
        chmod +x $filename
    else
        wget http://qt.mirror.constant.com/archive/qt/5.13/5.13.1/$filename
        # md5 checksum: 21c3b16f851697fa8da8009f73694373  qt-opensource-linux-x64-5.13.1.run
        chmod +x $filename
    fi

    ./$filename

    _ask_to_remove_a_file $filename
    
    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_qt_5_14_2()
{
    cwd_before_running=$PWD

    echo "  "
    echo "Install Qt 5.14.2" 
    echo "  "
    sleep 2
    
    # install serialport module
    sudo apt-get install libqt5serialport5-dev -y

    cd ~ && mkdir -p soft/ &&  cd soft/
    http://qt.mirror.constant.com/archive/qt/5.14/5.14.2/qt-opensource-linux-x64-5.14.2.run
    filename="qt-opensource-linux-x64-5.14.2.run"

    # check if the file exists --------------------
    unset md5checksum
    if [[ -f $filename ]] ; then
        md5checksum=`md5sum $filename`
        echo "md5checksum="$md5checksum
    fi
    if [[ "$md5checksum" = *"dce0588874fd369ce493ea5bc2a21d99"* ]] ; then
        echo "file exists, no need to download again"
        chmod +x $filename
    else
        wget http://qt.mirror.constant.com/archive/qt/5.14/5.14.2/$filename
        # md5 checksum: dce0588874fd369ce493ea5bc2a21d99  qt-opensource-linux-x64-5.14.2.run
        chmod +x $filename
    fi

    ./$filename

    _ask_to_remove_a_file $filename
    
    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_ros_melodic()
{
    cwd_before_running=$PWD

    # only Uubntu 18.04 can install ros-melodic
    ubuntu_release_version=$(lsb_release -a)
    if [[ $ubuntu_release_version != *'Ubuntu 18.04'* ]] ; then
        echo " "
        echo "ROS Melodic can only be installed in Ubuntu 18.04"
        echo " "
        return
    fi

    # setup sources.list ---------------
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

    # setup keys ---------------
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

    # installation ---------------
    sudo apt-get -y update || true
    sudo apt-get install ros-melodic-desktop-full -y

    # initialize rosdep ---------------
    sudo apt install python-rosdep2
    sudo rosdep init || true
    rosdep update

    installed=0
    while IFS='' read -r line || [[ -n "$line" ]] ; do
        if [[ $line == *"source /opt/ros/melodic/setup.bash"* ]] ; then
            installed=1
        fi
    done < ~/.bashrc

    if [ $installed = 0 ] ; then 
        echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
        echo " "
    fi

    # setup workspace ---------------
    mkdir -p ~/catkin_ws/src
    cd ~/catkin_ws
    catkin_make
    
    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_typora()
{
    wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
    # add Typora's repository
    sudo add-apt-repository 'deb https://typora.io/linux ./'
    sudo apt-get update
    # install typora
    sudo apt-get install typora
}
