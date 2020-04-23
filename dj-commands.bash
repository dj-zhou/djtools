#!/bin/bash

source $djtools_path/clone.bash
source $djtools_path/setup-generic.bash
source $djtools_path/udev-rules.bash

# ===========================================================================================
function _dj_help()
{
    echo " "
    echo "------------------------ dj -------------------------"
    echo " Author      : Dingjiang Zhou"
    echo " Email       : zhoudingjiang@gmail.com "
    echo " Create Date : Mar. 1st, 2020"
    echo "-----------------------------------------------------"
    echo " "
    echo " First level commands:"
    echo "   setup         - to install some software"
    echo "   clone         - clone a repo from bitbucket/github"
    echo "   udev          - udev rule setup for usb devices"
    echo "   work-check    - check work status of all repos in a folder"
    echo " "
    echo "   MORE IS COMMING"
    echo " "
    echo " All commands support tab completion"
    echo " "
}

# ===========================================================================================
function _clang_vscode_setting_json()
{
    # echo "hello world"
    current_folder=${PWD}
    cd $djtools_path # otherwise there will be no copy
    # pwd
    folder="/home/$USER/.config/Code/User"
    if [ ! -d $folder ] ; then
        mkdir -p $folder
    fi

    if [[ ${ubuntu_release_version} = *'16.04'* ]] ; then
        json_file="clang-setting-ubuntu-16.04.json"
    elif [[ ${ubuntu_release_version} = *'18.04'* ]] ; then
        json_file="clang-setting-ubuntu-18.04.json"
    fi
    echo "json_file = "$json_file
    sudo rm -f $folder/settings.json
    cp $json_file $folder/settings.json
    cp .clang-format $folder/.clang-format

    cd $current_folder
}

# ===========================================================================================
function _dj_setup_clang_9_0_0()
{
    current_folder=${PWD}

    echo " "
    if [[ ${ubuntu_release_version} = *'16.04'* ]] ; then
        echo "  Install clang for Ubuntu 16.04..."
    elif [[ ${ubuntu_release_version} = *'18.04'* ]] ; then
        echo "  Install clang for Ubuntu 18.04..."
    fi
    echo " "
    sleep 2

    cd ~ && mkdir -p soft/ && cd soft/
    
    # how to choose a version?
    if [[ ${ubuntu_release_version} = *'16.04'* ]] ; then
        clang_file="clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-16.04"
    elif [[ ${ubuntu_release_version} = *'18.04'* ]] ; then
        clang_file="clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04"
    fi

    # check if the file exists --------------------
    unset md5checksum
    if [[ -f $clang_file.tar.xz ]] ; then
        md5checksum=`md5sum $clang_file.tar.xz`
        echo "md5checksum="$md5checksum
    fi
    if [[ ( ( ${ubuntu_release_version} = *'18.04'* ) && ( "$md5checksum" = *"9d8044379e151029bb1df3663c2fb2c1"* ) ) \
      || ( ( ${ubuntu_release_version} = *'16.04'* ) && ( "$md5checksum" = *"b3c5618fb3a5d268c371539e9f6a4b1f"* ) ) ]] ; then
        echo "file exists, no need to download again."
    else
        wget http://releases.llvm.org/9.0.0/${clang_file}.tar.xz
    fi
    echo "untar the clang file ..."
    tar xf ${clang_file}.tar.xz
    sudo rm -rf /opt/clang+llvm*
    sudo mv ${clang_file}/ /opt/
    _ask_to_remove_a_file ${clang_file}.tar.xz

    if [[ ! -d ~/.config/Code/User ]] ; then
        mkdir -p ~/.config/Code/User
    fi

    cd $djtools_path

    if [[ ${ubuntu_release_version} = *'16.04'* ]] ; then
        cat clang-setting-ubuntu-16.04.json
    elif [[ ${ubuntu_release_version} = *'18.04'* ]] ; then
        cat clang-setting-ubuntu-18.04.json
    fi

    echo ' '
    echo "Do you want to apply the above settings? [Yes/No]"
    echo ' '
    
    read answer
    
    if [[ ($answer = 'n') || ($answer = 'N') || ($answer = 'NO') || ($answer = 'No') || ($answer = 'no') ]] ; then
        echo "You can edit ~/.config/Code/User/settings.json manually."
    elif [[ ($answer = 'y') || ($answer = 'Y') || ($answer = 'YES') || ($answer = 'Yes') || ($answer = 'yes') ]] ; then
        _clang_vscode_setting_json
    else
        echo "wrong answer, not setting applied!"
        echo "You can edit ~/.config/Code/User/settings.json manually."
    fi

    cd $current_folder
}

# ===========================================================================================
function _dj_setup_dj_gadgets()
{
    current_folder=${PWD}

    cd ~ && mkdir -p workspace/ &&  cd workspace/
    git clone https://dj-zhou@github.com/dj-zhou/dj-gadgets.git
    cd dj-gadgets
    make && sudo make install
    cd ~/workspace/
    _ask_to_remove_a_folder dj-gadgets
    cd $current_folder
}

# ===========================================================================================
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
# this is only tested in Ubuntu 18.04
function _dj_setup_container_docker()
{
    current_folder=${PWD}

    # Install a few prerequisite packages
    sudo apt-get install -y apt-transport-https ca-certificates curl 
    sudo apt-get install -y software-properties-common

    # Add the GPG key for the official Docker repository
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Add the Docker repository to APT sources
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    sudo apt update

    # Install
    sudo apt install docker-ce

    # check the status -- not sure if the "active status" need a system reboot
    sudo systemctl status docker

    # ----------------------------------------------
    # add current user to the docker group, which was created from above scripts
    # to avoid typing "sudo" whenever run the docker command 
    # -- comment out, -- do not delete
    # sudo usermod -aG docker ${USER}
    # (to remove a user from a group: sudo gpasswd -d user group, need log in/out)

    # to list the users in the docker group
    # result=$(getent group docker)
    result=$(id -nG)
    if [ $result=*'docker'* ] ; then
        echo 'The user '${USER}' is in the docker group'
    else
        echo 'The user '${USER}' is NOT in the docker group'
    fi
    # ----------------------------------------------
    cd $current_folder
}

# ===========================================================================================
# https://github.com/wagoodman/dive
# how to clone the repo and use its Makefile to install? -- don't know
function _dj_setup_container_dive()
{
    current_folder=${PWD}

    # ----------------------------------------------
    cd ~ && mkdir -p soft/ &&  cd soft/
    dive_version="0.9.2"
    wget "https://github.com/wagoodman/dive/releases/download/v"$dive_version"/dive_"$dive_version"_linux_amd64.deb"
    sudo dpkg -i dive_*.deb
    _ask_to_remove_a_file dive_*.deb

    echo " "
    echo "use the following command to check the docker image layouts"
    echo "  sudo dive <image-tag/hash>"
    echo " "
    echo "you can find the image-tag/hash from command: sudo docker images -a"
    echo " "

    # ----------------------------------------------
    cd $current_folder
}

# ===========================================================================================
function _dj_setup_container_lxd_4_0()
{
    sudo apt install snapd
    sudo snap install lxd --channel=4.0/stable
}

# ===========================================================================================
function _dj_setup_pangolin()
{
    current_folder=${PWD}
    # dependency installation
    sudo apt-get install libglew-dev mesa-utils -y
    sudo apt-get install libglm-dev -y # opengl related mathematics lib
    sudo apt-get install libxkbcommon-x11-dev # if error: No package 'xkbcommon' found

    # use command 'glxinfo | grep "OpenGL version" ' to see opengl version in Ubuntu
    
    cd ~ && mkdir -p soft/ &&  cd soft/
    git clone https://dj-zhou@github.com/dj-zhou/pangolin.git
    cd pangolin
    git checkout add-eigen3-include
    git pull
    sudo rm -rf build/ && mkdir build && cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install

    _ask_to_remove_a_folder pangolin

    echo " "
    echo "libpangolin.so is in path: /usr/local/lib/"
    echo "header files (i.e., pangolin/pangolin.h) are in path: /usr/local/include/"
    echo " "
    
    echo "If you see error like this:"
    echo "   Could not find GLEW"
    echo " you should run the following command first:"
    echo "   dj setup glfw3-gtest-glog"
    echo " "
    
    cd $current_folder
}

# ===========================================================================================
function _dj_setup_pip()
{
    cwd_before_running=$PWD

    cd ~/
    sudo apt-get install python3-pip -y
    sudo apt-get install python-pip -y
    # pip upgrade, only for python 2
    sudo pip install --upgrade pip

    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_slack()
{
    cwd_before_running=$PWD
    
    cd ~ && mkdir -p soft && cd soft/
    wget https://downloads.slack-edge.com/linux_releases/slack-desktop-4.4.2-amd64.deb
    sudo dpkg -i slack-desktop*.deb
    _ask_to_remove_a_file slack-desktop*.deb

    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_stm32tools()
{

    cwd_before_running=$PWD

    mkdir -p ~/workspace && cd ~/workspace
    echo "  "
    echo " ----------------------------------------------- "
    echo " " 
    cd ~/workspace
    repo=stm32tools
    if [ ! -d $repo ] ; then
        echo " " 
        echo "stm32tools does not exist, git clone ..."
        echo " " 
        git clone https://dj-zhou@github.com/dj-zhou/stm32tools.git
    else 
        echo " " 
        echo ${repo} "exists, git pull in master branch ..."
        echo " " 
        cd $repo
        git checkout master
        git pull
    fi
    cd ~/workspace/$repo

    echo " " 
    echo "install st-link v2"
    echo " "
    sudo apt-get install libusb-1.0.0-dev -y

    cd ~/workspace/stm32tools
    sudo rm -rf stlink-master/build/
    cd stlink-master && make release
    cd build/Release/ && sudo make install
    sudo ldconfig

    cd $cwd_before_running
    echo " "
    echo "compile stm32flash"
    echo " "
    cd ~/workspace/stm32tools/stm32flash
    make clean
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install

    echo "  "
    echo "install cu & cutecom -- serial port console"
    echo "  "
    sudo apt-get install cu cutecom -y

    echo "  "
    echo "add serial port privilege to current user"
    echo "  "
    sudo usermod -a -G dialout $(whoami)
    rule_file=stm32tools.rules
    sudo rm -f /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyUSB[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    echo 'KERNEL=="ttyACM[0-99]*",MODE="0666"' | sudo tee -a /etc/udev/rules.d/$rule_file
    sudo service udev restart

    echo "  "
    cd ~
    _ask_to_remove_a_folder ~/workspace/stm32tools

    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_glfw3_gtest_glog()
{
    cwd_before_running=$PWD

    echo " "
    echo "  Install glfw3, gtest, glog ..."
    echo " "
    sleep 2
    cd ~
    
    # glfw3
    sudo apt-get -y install build-essential cmake git xorg-dev libglu1-mesa-dev -y
    sudo rm -rf glfw3/
    git clone https://github.com/dj-zhou/glfw3.git
    cd glfw3/
    mkdir build && cd build/
    cmake .. -DBUILD_SHARED_LIBS=ON
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install && sudo ldconfig
    cd ~
    _ask_to_remove_a_folder glfw3
    
    # gtest
    sudo apt-get install libgtest-dev -y
    cd /usr/src/gtest
    sudo cmake CMakeLists.txt
    sudo make
    sudo cp *.a /usr/local/lib

    # glog
    sudo apt-get install libgoogle-glog-dev -y

    cd ${cwd_before_running}
}

# ===========================================================================================
# may not be a good way to install opencv
# recommend to install opencv-4.1.1
function _dj_setup_opencv_2_4_13()
{
    cwd_before_running=$PWD

    echo " "
    echo " Have you installed Qt? The openCV installation may need Qt"
    echo " use the following command to install Qt 5.11.2"
    echo "     dj setup qt-5.11.2"
    echo " "
    sleep 3
    
    cd ~ && mkdir -p soft && cd soft/

    sudo rm -rf opencv-4.1.1 # otherwise, it will not going to clone into this folder

    wget https://codeload.github.com/opencv/opencv/zip/2.4.13.6
    mv 2.4.13.6 opencv-2.4.13.6.zip
    unzip opencv-2.4.13.6.zip
    cd opencv-2.4.13.6
    mkdir build && cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D WITH_V4L=ON -D WITH_QT=ON -D WITH_OPENGL=ON WITH_OPENCL=ON WITH_GDAL=ON WITH_IPP=ON BUILD_JASPER=ON BUILD_JPEG=ON BUILD_PNG=ON BUIILD_TIFF=ON WITH_OPENMP=ON ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install

    _ask_to_remove_a_folder opencv-2.4.13
    _ask_to_remove_a_file opencv-2.4.13.zip

    cd ${cwd_before_running}
    echo " "
    echo " lib files *.so are installed in /usr/local/lib/"
    echo " header files are installded in /usr/local/include/opencv2/"
    echo " "
}

# ===========================================================================================
# the installation is from the book, which has a github repo:
# https://github.com/PacktPublishing/Learn-OpenCV-4-By-Building-Projects-Second-Edition
# however, this is a bad reference
# notice: there is some manual work todo before actually automate this procedure
function _dj_setup_opencv_4_1_1()
{
    cwd_before_running=$PWD

    echo " "
    echo " Have you installed Qt? The openCV installation may need Qt"
    echo " use the following command to install Qt 5.14.2"
    echo "     dj setup qt-5.14.2"
    echo
    echo " "
    sleep 3

    # install dependency:
    sudo apt-get install -y libopencv-dev build-essential cmake libdc1394-22
    sudo apt-get install -y libdc1394-22-dev libjpeg-dev libpng12-dev
    sudo apt-get install -y libtiff5-dev libjasper-dev libavcodec-dev
    sudo apt-get install -y libavformat-dev libswscale-dev libxine2-dev
    sudo apt-get install -y libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev
    sudo apt-get install -y libv4l-dev libtbb-dev libqt4-dev libmp3lame-dev
    sudo apt-get install -y libopencore-amrnb-dev libopencore-amrwb-dev
    sudo apt-get install -y libtheora-dev libvorbis-dev libxvidcore-dev
    sudo apt-get install -y x264 v4l-utils

    cd ~ && mkdir -p soft && cd soft/
    sudo rm -rf opencv-4.1.1 # otherwise, it will not going to clone into this folder

    git clone https://github.com/dj-zhou/opencv-4.1.1.git
    git clone https://github.com/dj-zhou/ippicv.git

    if [ $# = 1 ] && [ $1 = 'with-contrib' ] ; then
        git clone https://github.com/dj-zhou/opencv_contrib-4.1.1.git
    fi
    
    cd opencv-4.1.1
    git checkout add-eigen3-include
    sudo rm -rf build && mkdir build && cd build
    if [ $# = 1 ] && [ $1 = 'with-contrib' ] ; then
        cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=ON -D BUILD_EXAMPLES=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.1.1/modules ..
    else
        cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=ON -D BUILD_EXAMPLES=ON ..
    fi
    
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install
    
    cd ~/soft/
    
    _ask_to_remove_a_folder opencv-4.1.1
    if [ $# = 1 ] && [ $1 = 'with-contrib' ] ; then
        _ask_to_remove_a_folder opencv_contrib-4.1.1
    fi

    cd ${cwd_before_running}
    echo " "
    echo " lib files *.so are installed in /usr/local/lib/"
    echo " header files are installded in /usr/local/include/opencv4/, in which there is another folder opencv2/"
    echo " "
    echo " example code or template project can be seen from:"
    echo " https://github.com/dj-zhou/opencv4-demo/001-imread-imshow"
}

# ===========================================================================================
# https://www.linuxbabe.com/desktop-linux/how-to-install-chinese-wubi-input-method-on-debian-8-gnome-desktop
function _dj_setup_wubi()
{
    cwd_before_running=$PWD

    sudo apt-get install ibus ibus-table-wubi -y
    if [[ ${ubuntu_release_version} = *'16.04'* ]] ; then
        echo " "
        echo "Following the steps:"
        echo " "
        echo "  $ ibus-setup"
        echo "  in the opened window: Input Method -> Add -> Chinese -> choose WuBi-Jidian-86-JiShuang"
        echo "  (it may need reboot the computer if the WuBi input is not shown) "
        echo "  $ im-config -n ibus (nothing will happen after ENTER)"
        echo "  Add an Input Source to Gnome:"
        echo "  Settings -> Keyboard -> Input Sources -> Others -> Chinese -> Chise (WuBi-Jidian-86-JiShuang-6.0) "
        echo "  use Windows Key (or named Super Key) + Space to switch the two input methods"
        echo " "
    elif [[ ${ubuntu_release_version} = *'18.04'* ]] ; then
        echo " "
        echo " pleaase follow the link below to finish the setup"
        echo " https://www.pinyinjoe.com/linux/ubuntu-18-gnome-chinese-setup.htm"
        echo " "
    fi
    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_vtk_8_2_0()
{
    echo "vtk 8.2.0 installation"

    cwd_before_running=$PWD

    # vtk 8 ----------------
    # reference: https://kezunlin.me/post/b901735e/
    cd ~ && mkdir -p soft && cd soft/

    sudo apt-get install cmake-qt-gui -y

    git clone https://gitee.com/dj-zhou/vtk-8.2.0.git

    cd vtk-8.2.0 && sudo rm -rf build/ && mkdir -p build && cd build
    cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DVTK_RENDERING_BACKEND=OpenGL2 -DQT5_DIR=$HOME/Qt5.14.2/5.14.2/gcc_64/lib/cmake/Qt5 -DVTK_QT_VERSION=5 -DVTK_Group_Qt=ON ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install
    # some warning:
    # CMake Warning:
    #     Manually-specified variables were not used by the project:

    #     QT5_DIR
    # however, the compilation seems have no problem

    echo " "
    echo " the installed library seems to be in /usr/local/lib folder"
    echo " the installed header files seem to be in /usr/local/include/vtk-8.2/ folder"
    echo " "

    cd ~/soft/
    _ask_to_remove_a_folder VTK-8.2.0
    cd ${cwd_before_running}
}

# ===========================================================================================
# call function in workspace-check.bash
function _dj_work_check()
{
    _work_check $1 $2 $3 $4
}

# ===========================================================================================
function dj()
{
    # ------------------------------
    if [ $# -eq 0 ] ; then
        _dj_help
        return
    fi
    # ------------------------------
    if [ $1 = 'setup' ] ; then
        # --------------------------
        if [ $2 = 'arm-gcc' ] ; then
            _dj_setup_arm_gcc
            return
        fi
        # --------------------------
        if [ $2 = 'clang-8.0.0' ] ; then
            _dj_setup_clang_8_0_0
            return
        fi
        # --------------------------
        if [ $2 = 'clang-9.0.0' ] ; then
            _dj_setup_clang_9_0_0
            return
        fi
        # --------------------------
        if [ $2 = 'computer' ] ; then
            _dj_setup_computer
            return
        fi
        # --------------------------
        if [ $2 = 'dj-gadgets' ] ; then
            _dj_setup_dj_gadgets
            return
        fi
        # --------------------------
        if [ $2 = 'container' ] ; then
            if [ $3 = 'docker' ] ; then
                _dj_setup_container_docker
                return
            fi
            if [ $3 = 'dive' ] ; then
                _dj_setup_container_dive
                return
            fi
            if [ $3 = 'lxd-4.0' ] ; then
                _dj_setup_container_lxd_4_0
                return
            fi
            return
        fi
        # --------------------------
        if [ $2 = 'dropbox' ] ; then
            _dj_setup_dropbox
            return
        fi
        # --------------------------
        if [ $2 = 'eigen' ] ; then
            _dj_setup_eigen
            return
        fi
        # --------------------------
        if [ $2 = 'i219-v' ] ; then
            _dj_setup_i219_v $3
            return
        fi
        # --------------------------
        if [ $2 = 'mathpix' ] ; then
            _dj_setup_mathpix
            return
        fi
        # --------------------------
        if [ $2 = 'foxit' ] ; then
            _dj_setup_foxit_reader
            return
        fi
        # --------------------------
        if [ $2 = 'gitg-kdiff3' ] ; then
            _dj_setup_gitg_kdiff3
            return
        fi
        # --------------------------
        if [ $2 = 'pangolin' ] ; then
            _dj_setup_pangolin
            return
        fi
        # --------------------------
        if [ $2 = 'yaml-cpp' ] ; then
            _dj_setup_yaml_cpp
            return
        fi
        # --------------------------
        if [ $2 = 'qt-5.11.2' ] ; then
            _dj_setup_qt_5_11_2
            return
        fi
        # --------------------------
        if [ $2 = 'qt-5.13.1' ] ; then
            _dj_setup_qt_5_13_1
            return
        fi
        # --------------------------
        if [ $2 = 'qt-5.14.2' ] ; then
            _dj_setup_qt_5_14_2
            return
        fi
        # --------------------------
        if [ $2 = 'pip' ] ; then
            _dj_setup_pip
            return
        fi
        # --------------------------
        if [ $2 = 'ros-melodic' ] ; then
            _dj_setup_ros_melodic
            return
        fi
        # --------------------------
        if [ $2 = 'slack' ] ; then
            _dj_setup_slack
            return
        fi
        # --------------------------
        if [ $2 = 'stm32tools' ] ; then
            _dj_setup_stm32tools
            return
        fi
        # --------------------------
        if [ $2 = 'typora' ] ; then
            _dj_setup_typora
            return
        fi
        # --------------------------
        if [ $2 = 'glfw3-gtest-glog' ] ; then
            _dj_setup_glfw3_gtest_glog
            return
        fi
        # --------------------------
        if [ $2 = 'opencv-2.4.13' ] ; then
            _dj_setup_opencv_2_4_13
            return
        fi
        # --------------------------
        if [ $2 = 'opencv-4.1.1' ] ; then
            _dj_setup_opencv_4_1_1
            return
        fi
        # --------------------------
        if [ $2 = 'wubi' ] ; then
            _dj_setup_wubi
            return
        fi
        # --------------------------
        if [ $2 = 'vtk-8.2.0' ] ; then
            _dj_setup_vtk_8_2_0
            return
        fi
        # --------------------------
        if [ $2 = 'sublime' ] ; then
            _dj_setup_sublime
            return
        fi
        # --------------------------
        if [ $2 = 'vscode' ] ; then
            _dj_setup_vscode
            return
        fi
        # --------------------------
        _dj_setup_help
        return
    fi
    # ------------------------------
    if [ $1 = 'clone' ] ; then
        # --------------------------
        if [ $2 = 'bitbucket' ] ; then
            _dj_clone_bitbucket $3 $4 $5 $6 $7
            return
        fi
        # --------------------------
        if [ $2 = 'github' ] ; then
            _dj_clone_github $3 $4 $5 $6 $7
            return
        fi
        # --------------------------
        if [ $2 = 'gitee' ] ; then
            _dj_clone_gitee $3 $4 $5 $6 $7
            return
        fi
        # --------------------------
        _dj_clone_help
        return
    fi
    # ------------------------------
    if [ $1 = 'work-check' ] ; then
        _dj_work_check $2 $3 $4 $5
        return
    fi
    if [ $1 = 'udev' ] ; then
        _dj_udev_uvc_video_capture $2 $3 $4 $5
        return
    fi
    _dj_help
    # ------------------------------
}

# ===========================================================================================
function _dj()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        setup
        clone
        work-check
        udev
    ")

    # declare an associative array for options
    declare -A ACTIONS

    #---------------------------------------------------------
    #---------------------------------------------------------
    ACTIONS[setup]+="arm-gcc clang-9.0.0 container computer dj-gadgets dropbox eigen foxit "
    ACTIONS[setup]+="gitg-kdiff3 glfw3-gtest-glog i219-v mathpix opencv-2.4.13 opencv-4.1.1 "
    ACTIONS[setup]+="pangolin pip qt-5.11.2 qt-5.13.1 qt-5.14.2 ros-melodic slack stm32tools "
    ACTIONS[setup]+="typora sublime vscode vtk-8.2.0 wubi yaml-cpp "
    ACTIONS[arm-gcc]=" "
    ACTIONS[clang-8.0.0]=" "
    ACTIONS[clang-9.0.0]=" "
    ACTIONS[computer]=" "
    ACTIONS[dj-gadgets]=" "
    ACTIONS[container]="docker dive lxd-4.0 "
    ACTIONS[docker]=" "
    ACTIONS[dive]=" "
    ACTIONS[lxd-4.0]=" "
    ACTIONS[dropbox]=" "
    ACTIONS[eigen]=" "
    ACTIONS[foxit]=" "
    ACTIONS[glfw3-gtest-glog]=" "
    ACTIONS[i219-v]="e1000e-3.4.2.1 e1000e-3.4.2.4 "
    ACTIONS[mathpix]=" "
    ACTIONS[e1000e-3.4.2.1]=" "
    ACTIONS[e1000e-3.4.2.4]=" "
    ACTIONS[opencv-2.4.13]=" "
    ACTIONS[opencv-4.1.1]="with-contrib no-contrib "
    ACTIONS[with-contrib]=" "
    ACTIONS[no-contrib]=" "
    ACTIONS[pangolin]=" "
    ACTIONS[pip]=" "
    ACTIONS[qt-5.11.2]=" "
    ACTIONS[qt-5.13.1]=" "
    ACTIONS[qt-5.14.2]=" "
    ACTIONS[ros-melodic]=" "
    ACTIONS[slack]=" "
    ACTIONS[stm32tools]=" "
    ACTIONS[typora]=" "
    ACTIONS[vscode]=" "
    ACTIONS[sublime]=" "
    ACTIONS[vtk-8.2.0]=" "
    ACTIONS[wubi]=" "
    ACTIONS[yaml-cpp]=" "

    #---------------------------------------------------------
    #---------------------------------------------------------
    ACTIONS[clone]="bitbucket github gitee "
    #---------------------------------------------------------
    ACTIONS[bitbucket]+="lib-stm32f4-v2 "
    ACTIONS[lib-stm32f4-v2]=" "
    #---------------------------------------------------------
    ACTIONS[github]="python-demo learn-ml opencv4-demo "
    ACTIONS[github]="e1000e-3.4.2.1 e1000e-3.4.2.4 vtk-demo libsodium-1.0.18 "
    ACTIONS[github]="pangolin-demo learn-md dj-lib-cpp glfw3 pangolin yaml-cpp "
    ACTIONS[python-demo]=" "
    ACTIONS[learn-ml]=" "
    ACTIONS[opencv4-demo]=" "
    ACTIONS[e1000e-3.4.2.1]=" "
    ACTIONS[e1000e-3.4.2.4]=" "
    ACTIONS[vtk-demo]=" "
    ACTIONS[libsodium-1.0.18]=" "
    ACTIONS[pangolin-demo]=" "
    ACTIONS[learn-md]=" "
    ACTIONS[dj-lib-cpp]=" "
    ACTIONS[glfw3]=" "
    ACTIONS[pangolin]=" "
    ACTIONS[yaml-cpp]=" "
    #---------------------------------------------------------
    ACTIONS[gitee]="vtk-8.2.0 opencv-4.1.1 "
    ACTIONS[vtk-8.2.0]=" "
    ACTIONS[opencv-4.1.1]=" "

    #---------------------------------------------------------
    #---------------------------------------------------------
    ACTIONS[work-check]=" "
    ACTIONS[udev]="uvc-video-capture "
    ACTIONS[uvc-video-capture]=" "

    # --------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# ===========================================================================================
complete -F _dj dj
