#!/bin/bash

source $djtools_path/clone.bash
source $djtools_path/help.bash
source $djtools_path/setup-generic.bash
source $djtools_path/setup-ros.bash
source $djtools_path/udev-rules.bash

# =============================================================================
function _dj_help()
{
    echo -e "\n"
    echo "------------------------ dj -------------------------"
    echo " Author      : Dingjiang Zhou"
    echo " Email       : zhoudingjiang@gmail.com "
    echo " Create Date : Mar. 1st, 2020"
    echo "-----------------------------------------------------"
    echo -e "\n"
    echo " First level commands:"
    echo "   setup         - to install some software"
    echo "   clone         - clone a repo from github/gitee/bitbucket"
    echo "   clone-ssh     - use ssh protocol to clone a repo from github/gitee/bitbucket"
    echo "   udev          - udev rule setup for usb devices"
    echo "   work-check    - check work status of all repos in a folder"
    echo -e "\n"
    echo "   MORE IS COMMING"
    echo -e "\n"
    echo " All commands support tab completion"
    echo -e "\n"
}

function _clang_write_to_file_part1() {
    file=$1
    echo '{'                                            >> ${file}
    echo '    "files.hotExit": "onExit",'               >> ${file}
    echo '    "editor.tabSize": 4,'                     >> ${file}
    echo '    "workbench.editor.enablePreview": false,' >> ${file}
    echo '    "C_Cpp.updateChannel": "Insiders",'       >> ${file}
    echo '    "C_Cpp.default.cppStandard": "c++17",'    >> ${file}
    echo '    "editor.detectIndentation": false,'       >> ${file}
    echo '    "files.autoSave": "afterDelay",'          >> ${file}
    echo '    "workbench.iconTheme": "vscode-icons",'   >> ${file}
    echo '    "editor.fontSize": 16,'                   >> ${file}
    echo '    "cSpell.enabledLanguageIds": ['           >> ${file}
    echo '        "asciidoc",'                          >> ${file}
    echo '        "c",'                                 >> ${file}
    echo '        "cpp",'                               >> ${file}
    echo '        "csharp",'                            >> ${file}
    echo '        "css",'                               >> ${file}
    echo '        "git-commit",'                        >> ${file}
    echo '        "go",'                                >> ${file}
    echo '        "handlebars",'                        >> ${file}
    echo '        "haskell",'                           >> ${file}
    echo '        "html",'                              >> ${file}
    echo '        "jade",'                              >> ${file}
    echo '        "java",'                              >> ${file}
    echo '        "javascript",'                        >> ${file}
    echo '        "javascriptreact",'                   >> ${file}
    echo '        "json",'                              >> ${file}
    echo '        "jsonc",'                             >> ${file}
    echo '        "less",'                              >> ${file}
    echo '        "markdown",'                          >> ${file}
    echo '        "php",'                               >> ${file}
    echo '        "plaintext",'                         >> ${file}
    echo '        "pug",'                               >> ${file}
    echo '        "python",'                            >> ${file}
    echo '        "restructuredtext",'                  >> ${file}
    echo '        "rust",'                              >> ${file}
    echo '        "scala",'                             >> ${file}
    echo '        "scss",'                              >> ${file}
    echo '        "text",'                              >> ${file}
    echo '        "typescript",'                        >> ${file}
    echo '        "typescriptreact",'                   >> ${file}
    echo '        "yaml",'                              >> ${file}
    echo '        "yml"'                                >> ${file}
    echo '    ],'                                       >> ${file}
    echo '    "[cpp]": {'                               >> ${file}
    echo '        "editor.defaultFormatter": "ms-vscode.cpptools"' >> ${file}
    echo '    },'                                       >> ${file}
    echo '    "Clang_format_style": "file",'            >> ${file}
    echo '    "clang-format.assumeFilename": "~/.config/Code/User/.clang-format",' >> ${file}
}

# =============================================================================
function _clang_write_to_file_part2_clang_version_clang_format() {
    file=$1
    clang_file_path="/usr/bin"
    
    string1="\"C_Cpp.clang_format_path\": \"${clang_file_path}/clang-format\""
    echo "    $string1," >> ${file}
}

# =============================================================================
function _clang_write_to_file_part2_clang_version_clang_llvm() {
    file=$1
    if [[ ${ubuntu_v} = *'16.04'* ]] ; then
        clang_file_path="/opt/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-16.04/bin"
    fi
    if [[ ${ubuntu_v} = *'18.04'* ]] ; then
        clang_file_path="/opt/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04/bin"
    fi
    if [[ ${ubuntu_v} = *'20.04'* ]] ; then
        clang_file_path="/opt/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04/bin"
    fi
    string1="\"C_Cpp.clang_format_path\": \"${clang_file_path}/clang-format\""
    string2="\"clang.executable\": \"${clang_file_path}/clang\""
    # echo "$string1"
    # echo "$string2"
    echo "    $string1," >> ${file}
    echo "    $string2," >> ${file}
}

# =============================================================================
function _clang_write_to_file_part3_format_on_save() {
    file=$1
    save_or_not=$2
    if [ $save_or_not = 'true' ] ; then
        echo '    "editor.formatOnSave": true,'  >> ${file}
    elif [ $save_or_not = 'false' ] ; then
        echo '    "editor.formatOnSave": false,' >> ${file}
    fi
}

# =============================================================================
function _clang_write_to_file_partN() {
    file=$1
    echo '}' >> ${file}
}

# =============================================================================
function _clang_format_vscode_setting_json()
{
    format_on_save=$1
    current_folder_json=${PWD}

    folder="/home/$USER/.config/Code/User"
    mkdir -p $folder

    target_file=$folder/settings.json
    sudo rm -f $target_file
    _clang_write_to_file_part1 $target_file
    _clang_write_to_file_part2_clang_version_clang_format $target_file
    _clang_write_to_file_part3_format_on_save $target_file "$format_on_save"
    _clang_write_to_file_partN $target_file

    echo -e "\n the default settings is in $folder/settings.json\n"
    echo -e " you can revise it manually"
    cd $current_folder_json
}


# =============================================================================
function _clang_llvm_vscode_setting_json()
{
    format_on_save=$1
    current_folder_json=${PWD}

    folder="/home/$USER/.config/Code/User"
    mkdir -p $folder

    target_file=$folder/settings.json
    sudo rm -f $target_file
    _clang_write_to_file_part1 $target_file
    _clang_write_to_file_part2_clang_version_clang_llvm $target_file
    _clang_write_to_file_part3_format_on_save $target_file "$format_on_save"
    _clang_write_to_file_partN $target_file

    echo -e "\n the default settings is in $folder/settings.json\n"
    echo -e " you can revise it manually"
    cd $current_folder_json
}

# =============================================================================
function _dj_setup_clang_format()
{
    current_folder=${PWD}

    sudo apt-get install -y clang-format

    cd $djtools_path

    echo -e "\nDo you want to apply the default vscode settings? [Yes/No]\n"
    read asw
    
    if [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') \
      || ($asw = 'No') || ($asw = 'no') ]] ; then
        echo "You can edit ~/.config/Code/User/settings.json manually."
    elif [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') \
       || ($asw = 'Yes') || ($asw = 'yes') ]] ; then
        _clang_format_vscode_setting_json "true"
    else
        echo "wrong answer, not setting applied!"
        echo "You can edit ~/.config/Code/User/settings.json manually."
    fi

    echo -e "\n"

    cd $current_folder
}

# =============================================================================
function _dj_setup_clang_llvm()
{
    current_folder=${PWD}

    echo -e "\n"
    if [[ ${ubuntu_v} = *'16.04'* ]] ; then
        echo " Install clang+llvm for Ubuntu 16.04 ..."
    elif [[ ${ubuntu_v} = *'18.04'* ]] ; then
        echo " Install clang+llvm for Ubuntu 18.04 ..."
    elif [[ ${ubuntu_v} = *'20.04'* ]] ; then
        echo " Install clang+llvm for Ubuntu 20.04 ..."
    fi
    echo -e "\n"
    _press_enter_to_continue

    cd ~ && mkdir -p soft/ && cd soft/
    
    # how to choose a version?
    if [[ ${ubuntu_v} = *'16.04'* ]] ; then
        clang_file="clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-16.04"
    elif [[ ${ubuntu_v} = *'18.04'* ]] ; then
        clang_file="clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04"
    elif [[ ${ubuntu_v} = *'20.04'* ]] ; then
        clang_file="clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04" # thtis is correct!
    fi
    # check if the file exists --------------------
    # check if the file exists --------------------
    
    url=http://releases.llvm.org/9.0.0/${clang_file}.tar.xz
    if [[ ${ubuntu_v} = *'18.04'* || ${ubuntu_v} = *'20.04'* ]] ; then
        _wget_if_not_exist $clang_file.tar.xz "9d8044379e151029bb1df3663c2fb2c1" $url
    elif [[ ${ubuntu_v} = *'16.04'* ]] ; then
        _wget_if_not_exist $clang_file.tar.xz "b3c5618fb3a5d268c371539e9f6a4b1f" $url
    fi
    
    echo "untar the clang file ..."
    tar xf ${clang_file}.tar.xz
    sudo rm -rf /opt/clang+llvm*

    echo "copy the clang file into /opt/ ..."
    sudo mv ${clang_file}/ /opt/

    mkdir -p ~/.config/Code/User

    cd $djtools_path

    echo -e "\nDo you want to apply the default vscode settings? [Yes/No]\n"
    read asw
    
    if [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') \
      || ($asw = 'No') || ($asw = 'no') ]] ; then
        echo "You can edit ~/.config/Code/User/settings.json manually."
    elif [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') \
       || ($asw = 'Yes') || ($asw = 'yes') ]] ; then
        _clang_llvm_vscode_setting_json "true"
    else
        echo "wrong answer, not setting applied!"
        echo "You can edit ~/.config/Code/User/settings.json manually."
    fi

    echo ' '

    cd $current_folder
}

# =============================================================================
function _dj_setup_cmake()
{
    echo -e "\n ${GRN} install latest CMake ${NOC}"
    _press_enter_or_wait_s_continue 5
    if [ ! -f /etc/apt/sources.list.d/kitware-latest.list ] ; then
        wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc \
                2>/dev/null | sudo apt-key add -
        sudo sh -c 'echo "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" \
                >> /etc/apt/sources.list.d/kitware-latest.list'
    fi
    sudo apt-get -y update
    sudo apt-get -y install cmake
}

# =============================================================================
function _dj_setup_kdiff3_meld()
{
    sudo apt-get install -y kdiff3 meld
    
    all_config=$(git config --list)
    if [[ "$all_config" = *"merge.tool"* ]] ; then
        git config --global --replace-all merge.tool kdiff3
    else
        git config --global --add merge.tool kdiff3
    fi
    if [[ "$all_config" = *"diff.guitool"* ]] ; then
        git config --global --replace-all diff.guitool meld
    else
        git config --global --add diff.guitool meld
    fi
}

# =============================================================================
function _dj_setup_dj_gadgets()
{
    current_folder=${PWD}

    cd ~ && mkdir -p workspace/ &&  cd workspace/
    git clone https://dj-zhou@github.com/dj-zhou/dj-gadgets.git
    cd dj-gadgets
    make && sudo make install

    # dj-file installation
    cd dj-file/
    ./install.sh

    cd ~/workspace/
    _ask_to_remove_a_folder dj-gadgets
    
    cd $current_folder
}

# =============================================================================
# todo: for each package, yes (default) to intall, no to skip
function _dj_setup_devtools()
{
    sudo apt-get install -y libncurses5-dev
}

# =============================================================================
# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04
# this is only tested in Ubuntu 18.04
function _dj_setup_container_docker()
{
    current_folder=${PWD}

    # Install a few prerequisite packages
    sudo apt-get install -y apt-transport-https ca-certificates curl 
    sudo apt-get install -y software-properties-common

    docker_url="https://download.docker.com/linux/ubuntu"

    # Add the GPG key for the official Docker repository
    curl -fsSL $docker_url/gpg | sudo apt-key add -

    # Add the Docker repository to APT sources
    sudo add-apt-repository \
        "deb [arch=amd64] $docker_url $(lsb_release -cs) stable"
    sudo apt-get -y update

    # Install
    sudo apt-get -y install docker-ce

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
    
    # ----------------------------------------------
    cd $current_folder
}

# =============================================================================
# https://github.com/wagoodman/dive
# how to clone the repo and use its Makefile to install? -- don't know
function _dj_setup_container_dive()
{
    current_folder=${PWD}

    # ----------------------------------------------
    cd ~ && mkdir -p soft/ &&  cd soft/
    dive_version="0.9.2"
    drive_url="https://github.com/wagoodman/dive/releases/download/v"
    wget $drive_url$dive_version"/dive_"$dive_version"_linux_amd64.deb"
    sudo dpkg -i dive_*.deb
    _ask_to_remove_a_file dive_*.deb

    echo -e "\n"
    echo "use the following command to check the docker image layouts"
    echo "  sudo dive <image-tag/hash>"
    echo -e "\n"
    echo "you can find the image-tag/hash from command: sudo docker images -a"
    echo -e "\n"

    # ----------------------------------------------
    cd $current_folder
}

# =============================================================================
function _dj_setup_container_lxd_4_0()
{
    sudo apt-get install snapd
    sudo snap install lxd --channel=4.0/stable
    echo -e "\n"
    echo 'next step: '
    echo ' sudo lxd init'
    echo -e "\n"
}

# =============================================================================
function _dj_setup_pangolin()
{
    current_folder=${PWD}
    # dependency installation
    sudo apt-get install libglew-dev mesa-utils -y
    sudo apt-get install libglm-dev -y # opengl related mathematics lib
    sudo apt-get install libxkbcommon-x11-dev # if error: No package 'xkbcommon' found

    # use command 'glxinfo | grep "OpenGL version" ' to see opengl version in Ubuntu
    
    cd ~ && mkdir -p soft/ &&  cd soft/
    rm -rf Pangolin/
    git clone https://github.com/stevenlovegrove/Pangolin.git
    cd Pangolin
    # this following commit tis tested on Ubuntu 20.04, on Sept. 25th, 2020
    git checkout 86eb4975fc4fc8b5d92148c2e370045ae9bf9f5d # it is on master
    rm -rf build/ && mkdir build && cd build
    cmake ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install

    cd ~/soft/
    _ask_to_remove_a_folder Pangolin

    _press_enter_or_wait_s_continue 10

    echo -e "\n libpangolin.so is in path: ${GRN}/usr/local/lib/${NOC}"
    echo -e " header files are in path: ${GRN}/usr/local/include/pangolin/${NOC}\n"
    
    _press_enter_or_wait_s_continue 10

    echo -e "\n If you see error like this:"
    echo    "   Could not find GLEW"
    echo    " you should run the following commands first:"
    echo    "   dj setup glfw3"
    echo -e "   dj setup gtest-glog\n"
    
    cd $current_folder
}

# =============================================================================
function _dj_setup_pip()
{
    cwd_before_running=$PWD

    cd ~/
    sudo apt-get install python3-pip -y
    sudo apt-get install python-pip -y

    sudo pip  install --upgrade pip
    sudo pip3 install --upgrade pip

    echo -e "\n check the pip/pip3 version by\n"
    echo    "   pip --version"
    echo -e "   pip3 --version\n"
    
    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_qemu()
{
    cwd_before_running=$PWD

    version=$1
    echo $version
    if [ $version = "2.11.1" ] ; then
        # this may only work within Ubuntu 18.04, not tested on other platforms
        sudo apt-get install qemu
    elif [ $version = "4.2.0" ] ; then
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

    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_stm32_cubemx()
{
    cwd_before_running=$PWD

    cd ~ && mkdir -p soft && cd soft/

    git clone https://gitee.com/d-zhou/stm32-cube-mx-v6.0.1.git
    cd stm32-cube-mx-v6.0.1/
    cat archive.tar.* | tar -xzvf -
    # rm archive.tar.*
    chmod +x SetupSTM32CubeMX-6.0.1.linux
    ./SetupSTM32CubeMX-6.0.1.linux

    cd $cwd_before_running
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
function _dj_setup_stm32_tools()
{
    cwd_before_running=$PWD

    echo -e "\n install ${GRN}st-link v2${NOC} and ${GRN}stm32flash${NOC} tools"
    _press_enter_or_wait_s_continue 10
    
    # install dependencies and some software ----------------
    sudo apt-get install -y libusb-1.0.0-dev gtk+-3.0
    sudo apt-get install -y cu cutecom putty screen
    sudo apt-get install -y cmake

    # install stlink ----------------
    echo -e "\n install ${GRN}stlink${NOC}\n"
    _press_enter_or_wait_s_continue 10

    mkdir -p ~/workspace && cd ~/workspace
    rm stlink -rf
    git clone https://github.com/stlink-org/stlink

    cd stlink
    if [[ ${ubuntu_v} = *'18.04'* ]] ; then
        git checkout v1.6.1
    elif [[ ${ubuntu_v} = *'20.04'* ]] ; then
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
    cd ~/workspace/
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
    cd ~/workspace
    _ask_to_remove_a_folder stm32-tools
    _ask_to_remove_a_folder stlink
    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_glfw3()
{
    cwd_before_running=$PWD

    echo -e "\n install glfw3 ...\n"
    _press_enter_or_wait_s_continue 20
    
    cd ~ && mkdir -p soft && cd soft/

    # glfw3
    sudo apt-get -y install build-essential cmake git xorg-dev libglu1-mesa-dev
    sudo rm -rf glfw3/
    git clone https://github.com/dj-zhou/glfw3.git
    cd glfw3/
    mkdir build && cd build/
    cmake .. -DBUILD_SHARED_LIBS=ON
    make -j$(cat /proc/cpuinfo | grep processor | wc -l)
    sudo make install && sudo ldconfig
    cd ~/soft/
    _ask_to_remove_a_folder glfw3

    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_google_repo()
{
    cwd_before_running=$PWD

    # it needs python

    if [ -f $djtools_path/tools/repo ] ; then
        echo -e "\n use repo from tools/ \n"
        sudo cp  $djtools_path/tools/repo /bin/
        sudo chmod a+x /bin/repo
    else
        echo -e "\n fetch from google \n"
        curl https://storage.googleapis.com/git-repo-downloads/repo > repo
        chmod a+x repo
        sudo mv repo /bin/
    fi

    cat << EOM

 -----------------------------------------
  Google tool "repo" is installed into folder: /bin/
 -----------------------------------------

EOM
    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_gtest_glog()
{
    cwd_before_running=$PWD

    echo -e "\n install gtest and glog ...\n"
    _press_enter_or_wait_s_continue 20
    
    cd ~ && mkdir -p soft && cd soft/
    
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

# =============================================================================
# instlal gnome, need more test
function _dj_setup_gnome()
{
    echo -e "\n install gnome on Ubuntu\n"
    _press_enter_or_wait_s_continue 20

    sudo apt-get install tasksel
    sudo apt-get install gnome-session
    sudo tasksel install ubuntu-desktop
    
    echo -e "\n when log in, choose GNOME\n"
}

# =============================================================================
# ninja is used to compile
function _dj_setup_grpc_1_29_1()
{
    cwd_before_running=$PWD

    cd ~ && mkdir -p soft && cd soft/
    git clone https://github.com/grpc/grpc.git --recurse-submodules \
         --shallow-submodules --depth 1 --branch v1.29.1
    cd grpc
    mkdir build && cd build
    cmake .. -GNinja
    cmake --build .
    sudo cmake --build . -- install

    cd ~/soft/
    _ask_to_remove_a_folder grpc

    cd ${cwd_before_running}
}

# =============================================================================
# default compiles:
# Ubuntu 18.04: g++-7
# Ubuntu 20.04: g++-9
function _dj_setup_gpp_10()
{
    echo -e "\n instal ${GRN}gcc-10${NOC} and ${GRN}g++-10${NOC} \n"
    _press_enter_or_wait_s_continue 20

    sudo add-apt-repository ppa:ubuntu-toolchain-r/test
    sudo apt-get update
    sudo apt-get install -y gcc-10 g++-10
    echo -e "\n do you want to set up the gcc/g++ priorities? [Yes/No]"
    read anw
    if [[ ($anw = 'n') || ($anw = 'N') || ($anw = 'NO') \
      || ($anw = 'No') || ($anw = 'no') ]] ; then
        echo -e '\n gcc/g++ are not to set to use gcc-10/g++-10\n'
    elif [[ ($anw = 'y') || ($anw = 'Y') || ($anw = 'YES') \
       || ($anw = 'Yes') || ($anw = 'yes') ]] ; then
        echo -e '\n gcc/g++ are set to use gcc-10/g++-10\n'
        # ----------------------
        if [ -f /usr/bin/gcc-5 ] ; then
            sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5  5
        fi
        if [ -f /usr/bin/g++-5 ] ; then
            sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5  5
        fi
        # ----------------------
        if [ -f /usr/bin/gcc-7 ] ; then
            sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7  7
        fi
        if [ -f /usr/bin/g++-7 ] ; then
            sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7  7
        fi
        # ----------------------
        if [ -f /usr/bin/gcc-9 ] ; then
            sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9  9
        fi
        if [ -f /usr/bin/g++-9 ] ; then
            sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9  9
        fi
        # ----------------------
        if [ -f /usr/bin/gcc-10 ] ; then
            sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10  10
        fi
        if [ -f /usr/bin/g++-10 ] ; then
            sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10  10
        fi
        echo -e "\n-------------------\n"
        sudo update-alternatives --config gcc
        echo -e "\n-------------------\n"
        sudo update-alternatives --config g++
    else
        echo "Wrong answer! No action was taken!"
    fi
}

# =============================================================================
# may not be a good way to install opencv
# recommend to install opencv-4.1.1
function _dj_setup_opencv_2_4_13()
{
    cwd_before_running=$PWD

    echo -e "\n Have you installed Qt? The openCV installation may need Qt"
    echo " use the following command to install Qt 5.11.2"
    echo -e "     dj setup qt-5.11.2\n\n"
    _press_enter_or_wait_s_continue 20
    
    cd ~ && mkdir -p soft && cd soft/

    sudo rm -rf opencv-4.1.1 # otherwise, it will not going to clone into this folder

    wget https://codeload.github.com/opencv/opencv/zip/2.4.13.6
    mv 2.4.13.6 opencv-2.4.13.6.zip
    unzip opencv-2.4.13.6.zip
    cd opencv-2.4.13.6
    mkdir build && cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON -D WITH_V4L=ON -D WITH_QT=ON -D WITH_OPENGL=ON \
          WITH_OPENCL=ON WITH_GDAL=ON WITH_IPP=ON BUILD_JASPER=ON BUILD_JPEG=ON \
          BUILD_PNG=ON BUIILD_TIFF=ON WITH_OPENMP=ON ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install

    _ask_to_remove_a_folder opencv-2.4.13
    _ask_to_remove_a_file opencv-2.4.13.zip

    cd ${cwd_before_running}
    echo -e "\n" 
    echo " lib files *.so are installed in /usr/local/lib/"
    echo " header files are installded in /usr/local/include/opencv2/"
    echo -e "\n" 
}

# =============================================================================
# the installation is from the book, which has a github repo:
# https://github.com/PacktPublishing/Learn-OpenCV-4-By-Building-Projects-Second-Edition
# however, this is a bad reference
# notice: there is some manual work todo before actually automate this procedure
# this does not work on Ubuntu 20.04!
function _dj_setup_opencv_4_1_1()
{
    cwd_before_running=$PWD

    echo -e "\n Have you installed Qt? The openCV installation may need Qt"
    echo " use the following command to install Qt 5.14.2"
    echo -e "     dj setup qt-5.14.2\n\n"
    _press_enter_or_wait_s_continue 20

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
    rm -rf opencv-4.1.1

    git clone https://github.com/dj-zhou/opencv-4.1.1.git
    git clone https://github.com/dj-zhou/ippicv.git

    if [ $# = 1 ] && [ $1 = 'with-contrib' ] ; then
        git clone https://github.com/dj-zhou/opencv_contrib-4.1.1.git
    fi
    
    cd opencv-4.1.1
    git checkout add-eigen3-include
    sudo rm -rf build && mkdir build && cd build
    if [ $# = 1 ] && [ $1 = 'with-contrib' ] ; then
        cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
              -D INSTALL_C_EXAMPLES=ON -D BUILD_EXAMPLES=ON \
              -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.1.1/modules ..
    else
        cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
              -D INSTALL_C_EXAMPLES=ON -D BUILD_EXAMPLES=ON ..
    fi
    
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install
    
    cd ~/soft/
    
    _ask_to_remove_a_folder opencv-4.1.1
    if [ $# = 1 ] && [ $1 = 'with-contrib' ] ; then
        _ask_to_remove_a_folder opencv_contrib-4.1.1
    fi

    cd ${cwd_before_running}
    echo -e "\n"
    echo " lib files *.so are installed in /usr/local/lib/"
    echo " header files are installded in /usr/local/include/opencv4/, "
         "   in which there is another folder opencv2/"
    echo -e "\n"
    echo " example code or template project can be seen from:"
    echo " https://github.com/dj-zhou/opencv4-demo/001-imread-imshow"
}

# =============================================================================
# https://medium.com/@sb.jaduniv/how-to-install-opencv-4-2-0-with-cuda-10-1-on-ubuntu-20-04-lts-focal-fossa-bdc034109df3
function _dj_setup_opencv_4_2_0()
{
    cwd_before_running=$PWD
    # Generic tools
    sudo apt-get install -y build-essential cmake pkg-config unzip yasm git checkinstall
    # Image I/O libs
    sudo apt-get install -y libjpeg-dev libpng-dev libtiff-dev
    # Video/Audio Libs — FFMPEG, GSTREAMER, x264 and so on
    sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libavresample-dev
    sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
    sudo apt-get install -y libxvidcore-dev x264 libx264-dev libfaac-dev libmp3lame-dev libtheora-dev
    sudo apt-get install -y libfaac-dev libmp3lame-dev libvorbis-dev
    # OpenCore — Adaptive Multi Rate Narrow Band (AMRNB) and Wide Band (AMRWB) speech codec
    sudo apt-get install -y libopencore-amrnb-dev libopencore-amrwb-dev
    # Cameras programming interface libs
    sudo apt-get install -y libdc1394-22 libdc1394-22-dev libxine2-dev libv4l-dev v4l-utils 
    cd /usr/include/linux
    sudo ln -s -f ../libv4l1-videodev.h videodev.h
    # GTK lib for the graphical user functionalities coming from OpenCV highghui module
    sudo apt-get install -y libgtk-3-dev
    # Python libraries for Python3
    sudo apt-get install -y python3-dev python3-pip
    sudo -H pip3 install -U pip numpy
    sudo apt-get install -y python3-testresources
    # Parallelism library C++ for CPU
    sudo apt-get install -y libtbb-dev
    # Optimization libraries for OpenCV
    sudo apt-get install -y libatlas-base-dev gfortran
    # Optional libraries
    sudo apt-get install -y libprotobuf-dev protobuf-compiler
    sudo apt-get install -y libgoogle-glog-dev libgflags-dev
    sudo apt-get install -y libgphoto2-dev libeigen3-dev libhdf5-dev doxygen
    # Install OpenCL SDK related things
    sudo apt-get install -y ocl-icd-opencl-dev

    # start to install ---------------------------------------------------
    cd ~ && mkdir -p soft && cd soft/
    rm -rf opencv-4.2.0
    rm -rf opencv_contrib-4.2.0
    wget -O opencv.zip https://github.com/opencv/opencv/archive/4.2.0.zip
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.2.0.zip
    unzip opencv.zip
    unzip opencv_contrib.zip

    # some kind of virtual??
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    source /usr/local/bin/virtualenvwrapper.sh
    mkvirtualenv cv -p python3
    
    cd opencv-4.2.0
    mkdir build && cd build
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_C_COMPILER=/usr/bin/gcc-9 \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D INSTALL_C_EXAMPLES=OFF \
        -D WITH_TBB=ON \
        -D BUILD_opencv_cudacodec=OFF \
        -D ENABLE_FAST_MATH=1 \
        -D WITH_CUBLAS=1 \
        -D WITH_V4L=ON \
        -D WITH_QT=OFF \
        -D WITH_OPENGL=ON \
        -D WITH_GSTREAMER=ON \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D OPENCV_PC_FILE_NAME=opencv.pc \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D OPENCV_PYTHON3_INSTALL_PATH=~/.virtualenvs/cv/lib/python3.8/site-packages \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-4.2.0/modules \
        -D PYTHON_EXECUTABLE=~/.virtualenvs/cv/bin/python \
        -D BUILD_EXAMPLES=ON \
        -D WITH_CUDNN=ON \
        -D CUDA_FAST_MATH=1 \
        -D WITH_CUDA=ON \
        -D OPENCV_DNN_CUDA=ON \
        -D CUDA_ARCH_BIN=7.5 \
        -D CUDNN_LIBRARY=/usr/local/cuda/lib64/libcudnn.so.7.6.5 \
        -D CUDNN_INCLUDE_DIR=/usr/local/cuda/include  ..
    cd ${cwd_before_running}
}

# =============================================================================
# https://www.linuxbabe.com/desktop-linux/how-to-install-chinese-wubi-input-method-on-debian-8-gnome-desktop
# tested on Ubuntu 16.04, 18.04 and 20.04
function _dj_setup_wubi()
{
    cwd_before_running=$PWD

    sudo apt-get install ibus ibus-table-wubi -y
    if [[ ${ubuntu_v} = *'16.04'* ]] ; then
        cat << EOM

        Follow the steps:
            1. log out and log in again;
            2. $ ibus-setup
               then in the opened window: Input Method -> Add -> Chinese -> choose WuBi-Jidian-86-JiShuang
            3. im-config -n ibus 
               this step will show nothing
            4. add an input source:
               Settings -> Keyboard -> Input Sources -> Others -> Chinese -> Chinese (WuBi-Jidian-86-JiShuang-6.0)

EOM
    elif [[ ${ubuntu_v} = *'18.04'* \
        || ${ubuntu_v} = *'20.04'* ]] ; then
        echo -e "\n please follow the link below to finish the setup:"
        echo -e " https://www.pinyinjoe.com/linux/ubuntu-18-gnome-chinese-setup.htm\n"
    fi
    cd ${cwd_before_running}
}

# =============================================================================
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
    cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr/local -DVTK_RENDERING_BACKEND=OpenGL2 \
          -DQT5_DIR=$HOME/Qt5.14.2/5.14.2/gcc_64/lib/cmake/Qt5 \
          -DVTK_QT_VERSION=5 -DVTK_Group_Qt=ON ..
    make -j$(cat /proc/cpuinfo | grep processor | wc -l) && sudo make install

    echo -e "\n"
    echo " the installed library seems to be in /usr/local/lib folder"
    echo " the installed header files seem to be in /usr/local/include/vtk-8.2/ folder"
    echo -e "\n"

    cd ~/soft/
    _ask_to_remove_a_folder VTK-8.2.0
    cd ${cwd_before_running}
}

# =============================================================================
# call function in workspace-check.bash
function _dj_work_check()
{
    _work_check $1 $2 $3 $4
}

# =============================================================================
# to find a library use: ldconfig -p | grep xxxx
# once this command get extended, we add sub command to "dj find"
function _dj_find()
{
    cwd_before_running=$PWD
    
    lib_to_find=$1
    echo -e "\n run command:$GRN ldconfig -p | grep $lib_to_find$NOC\n"

    ldconfig -p | grep $lib_to_find
    
    echo -e "\n cd /usr/lib/x86_64-linux-gnu/pkgconfig"
    cd /usr/lib/x86_64-linux-gnu/pkgconfig
    echo -e " ls | grep $lib_to_find\n"
    ls | grep $lib_to_find
    cd $cwd_before_running
}

# =============================================================================
function _dj_meson_build()
{
    folder_name=$(basename "$current_folder")
    
    # if the curent folder is build, then
    # cd ../ && rm build -r 
    # meson build && cd build && ninja
    if [ "$folder_name" = 'build' ] ; then
        cd ../
        rm build/ -rf
        meson . build
        cd build
        ninja

    # if the curent folder contains a build/ folder, then
    # rm build -r 
    # meson build && cd build && ninja
    elif [ -d build ] ; then
        rm build/ -rf
        meson . build
        cd build
        ninja
        
    # if the current folder does not contain a build/ folder,then
    # check if there is a meson.build file, then build
    elif [ -f meson.build ] ; then
        meson . build
        cd build
        ninja
    else
        echo -e '\nmeson: not in a meson folder\n'
    fi
}

# =============================================================================
# to find something in a meson file
# only works in . directory
function _dj_meson_find() # term
{
    term=$1
    if [ -z "$term" ] ; then
        echo -e "\n usage:"
        echo -e "   dj meson find <something>\n"
        return
    fi
    all_meson_build=$(find . -name meson.build)
    for file in $all_meson_build ; do
        find_term=$(grep -rn $term $file)
        if [ ! -z "$find_term" ] ; then
            echo -e "\n${GRN} ---------------------------------------"
            echo -e "$file${NOC}"
            echo "$find_term"
        fi
    done
}

# =============================================================================
function _dj_open_file()
{
    # --------------------------
    if [ $# -eq 0 ] ; then
        nautilus .
        return
    fi
    # --------------------------
    if [ $# -eq 1 ] ; then
        nautilus $1
        return
    fi
}

# =============================================================================
function _dj_ssh_no_password()
{
    if [ $# = 0 ] ; then
        echo -e "usage:"
        echo -e " dj ssh no-password username@ip_address\n"
        return
    fi
    user_and_ip="$1"
    user=${user_and_ip%"@"*}
    pos=$(_find_a_char_in_str $user_and_ip "@" 1)
    ip=${user_and_ip:${pos}+1:${#user_and_ip}-${pos}}

    # if ~/.ssh/id_rsa.pub does not exist, create one
    key_file=~/.ssh/id_rsa.pub
    if [ ! -f "$key_file" ] ; then
        printf "\n\n\n" | ssh-keygen
    fi

    # just to create .ssh on target machine
    echo "ssh -l $user $ip \"mkdir -p ~/.ssh\""
    ssh -l $user $ip "mkdir -p ~/.ssh"

    # then run
    echo "cat $key_file | ssh $user_and_ip \"cat >> .ssh/authorized_keys\""
    cat $key_file | ssh $user_and_ip "cat >> .ssh/authorized_keys"
}

# =============================================================================
function _dj_setup_vim_env()
{
    echo -e "\n setup the vim as an IDE\n"
    _press_enter_or_wait_s_continue 20

    cwd_before_running=$PWD

    VIMRC=~/.vimrc

    # install software, if not installed already
    sudo apt-get install -y vim
    sudo apt-get install -y ctags # Generate tag files for source code
    sudo apt-get install -y cscope
    # software needed to compile YouCompleteMe
    sudo apt-get install -y build-essential cmake
    sudo apt-get install -y python-dev python3-dev

    # install Vundle -- plugin manager
    rm -rf ~/.vim/bundle/Vundle.vim
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    
    # configure Vundle in ${VIMRC}
    # also configure tagbar, nerdtree, ALE
    rm -rf ${VIMRC}
    echo    '" ===========================================================' >> ${VIMRC}
    echo    '" Vundle manage'                                               >> ${VIMRC}
    echo    'set nocompatible      " be iMproved, required'                 >> ${VIMRC}
    echo -e 'filetype off          " required\n'                            >> ${VIMRC}
    echo    '" set the runtime path to include Vundle and initialize'       >> ${VIMRC}
    echo    'set rtp+=~/.vim/bundle/Vundle.vim'                             >> ${VIMRC}
    echo -e 'call vundle#begin()\n'                                         >> ${VIMRC}
    echo    '" let Vundle manage Vundle, required'                          >> ${VIMRC}
    printf  "Plugin 'VundleVim/Vundle.vim'\n"                               >> ${VIMRC}
    printf  "Plugin 'majutsushi/tagbar'\n"                                  >> ${VIMRC}
    printf  "Plugin 'scrooloose/nerdtree'\n"                                >> ${VIMRC}
    printf  "Plugin 'w0rp/ale'\n"                                           >> ${VIMRC}
    printf  "Plugin 'Valloric/YouCompleteMe'\n"                             >> ${VIMRC}
    printf  "Plugin 'ludovicchabant/vim-gutentags'\n\n"                     >> ${VIMRC}
    echo    '" All of your Plugins must be added before the following line' >> ${VIMRC}
    echo    'call vundle#end()         " required'                          >> ${VIMRC}
    echo -e 'filetype plugin indent on " required\n\n'                      >> ${VIMRC}
    echo    '" ===========================================================' >> ${VIMRC}
    echo    '" cscope setup'                                                >> ${VIMRC}
    echo    '"-------------------------------------------'                  >> ${VIMRC}
    echo    '" cscope to create database: cscope -Rbq'                      >> ${VIMRC}
    echo    '" F5: to look for C symbol                              (s)'   >> ${VIMRC}
    echo    '" F6: to look for a string                              (t)'   >> ${VIMRC}
    echo    '" F7: to look for function definition                   (g)'   >> ${VIMRC}
    echo    '" F8: to look for which function calls current function (c)'   >> ${VIMRC}
    echo    '"-------------------------------------------'                  >> ${VIMRC}
    echo    'if has("cscope")'                                              >> ${VIMRC}
    echo    '  set csprg=/usr/bin/cscope'                                   >> ${VIMRC}
    echo    '  set csto=1'                                                  >> ${VIMRC}
    echo    '  set cst'                                                     >> ${VIMRC}
    echo    '  set nocsverb'                                                >> ${VIMRC}
    echo    '  " add any database in current directory'                     >> ${VIMRC}
    echo    '  if filereadable("cscope.out")'                               >> ${VIMRC}
    echo    '    cs add cscope.out'                                         >> ${VIMRC}
    echo    '  endif'                                                       >> ${VIMRC}
    echo    '  set csverb'                                                  >> ${VIMRC}
    echo -e 'endif\n'                                                       >> ${VIMRC}

    echo    ':set cscopequickfix=s-,c-,d-,i-,t-,e-'                         >> ${VIMRC}
    echo    '"nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>'       >> ${VIMRC}
    echo    'nmap <silent> <F5> :cs find s <C-R>=expand("<cword>")<CR><CR>' >> ${VIMRC}
    echo    'nmap <silent> <F6> :cs find g <C-R>=expand("<cword>")<CR><CR>' >> ${VIMRC}
    echo    'nmap <silent> <F7> :cs find t <C-R>=expand("<cword>")<CR><CR>' >> ${VIMRC}
    echo    'nmap <silent> <F8> :cs find c <C-R>=expand("<cword>")<CR><CR>' >> ${VIMRC}
    echo -e '\n'                                                            >> ${VIMRC}
    echo    '" ===========================================================' >> ${VIMRC}
    echo    '" Tagbar setup'                                                >> ${VIMRC}
    echo    'let g:tagbar_width=25'                                         >> ${VIMRC}
    echo    'autocmd BufReadPost *.cpp,*.c,*.hpp,s*.h,*.cc,*.cxx call tagbar#autoopen()' >> ${VIMRC}
    echo -e '\n'                                                            >> ${VIMRC}
    echo    '" ===========================================================' >> ${VIMRC}
    echo    '" Nerdtree setup'                                              >> ${VIMRC}
    echo    'autocmd StdinReadPre * let s:std_in=1'                         >> ${VIMRC}
    echo -e 'autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif' >> ${VIMRC} # this line does not work?
    echo -e 'let NERDTreeWinSize=15'                                        >> ${VIMRC}
    echo -e 'let NERDTreeShowLineNumbers=1'                                 >> ${VIMRC}
    echo -e 'let NERDTreeAutoCenter=1'                                      >> ${VIMRC}
    echo -e 'let NERDTreeShowBookmarks=1'                                   >> ${VIMRC}
    echo -e '\n'                                                            >> ${VIMRC}
    echo    '" ===========================================================' >> ${VIMRC}
    echo    '" ALE (Asynchronization Line Engine) setup'                    >> ${VIMRC}
    printf  "let g:ale_sign_column_always = 1\n"                            >> ${VIMRC}
    printf  "let g:ale_sign_error = '>>'\n"                                 >> ${VIMRC}
    printf  "let g:ale_sign_warning = '--'\n"                               >> ${VIMRC}
    printf  "let g:ale_statusline_format = ['x %%d', 'z %%d', 'y OK']\n"    >> ${VIMRC}
    printf  "let g:ale_echo_msg_format = '[%%linter%%] %%code: %%%%s'\n"    >> ${VIMRC}
    printf  "let g:ale_lint_on_text_changed = 'normal'\n"                   >> ${VIMRC}
    printf  "let g:ale_lint_on_insert_leave = 1\n"                          >> ${VIMRC}
    printf  "let g:ale_c_gcc_options = '-Wall -O2 -std=c99'\n"              >> ${VIMRC}
    printf  "let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++20'\n"          >> ${VIMRC}
    printf  "let g:ale_c_cppcheck_options = ' '\n"                          >> ${VIMRC}
    printf  "let g:ale_cpp_cppcheck_options = ' '\n"                        >> ${VIMRC}
    echo -e '\n'                                                            >> ${VIMRC}
    echo    '" ===========================================================' >> ${VIMRC}
    echo    '" YouCompleteMe setup'                                         >> ${VIMRC}
    printf  "let g:ycm_server_python_interpreter='/usr/bin/python3'\n"      >> ${VIMRC}
    printf  "let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'"   >> ${VIMRC}
    echo -e '\n\n'                                                          >> ${VIMRC}
    echo    '" ===========================================================' >> ${VIMRC}
    echo    '" vim-gutentags setup'                                         >> ${VIMRC}
    printf  "let g:gutentags_project_root= ['.root', '.svn', '.git', '.hg',  '.project']\n" >> ${VIMRC}
    printf  "let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']\n" >> ${VIMRC}
    printf  "let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']\n"     >> ${VIMRC}
    printf  "let g:gutentags_ctags_extra_args += ['--c-kinds=+px']\n"       >> ${VIMRC}
    echo -e '\n'                                                            >> ${VIMRC}
    echo    '" ===========================================================' >> ${VIMRC}
    echo    '" some other setup'                                            >> ${VIMRC}
    echo    'set nu! " display line number'                                 >> ${VIMRC}
    echo    'syntax enable'                                                 >> ${VIMRC}
    echo    'syntax on'                                                     >> ${VIMRC}
    echo    'colorscheme desert'                                            >> ${VIMRC}
    echo -e ':set autowrite "auto save\n\n'                                 >> ${VIMRC}

    echo -e "\n\n to make effects of the plugins, start vim, and enter:"
    echo -e " :PluginInstall\n"
    echo -e "YouCompleteMe needs to be compiled after the plugins are installed:"
    echo -e "  dj setup you-complete-me\n"

    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_you_complete_me()
{
    cwd_before_running=$PWD

    folder=~/.vim/bundle/YouCompleteMe
    if [ -d $folder ] ; then
        cd $folder
        ./install.py --clang-completer
        cp third_party/ycmd/examples/.ycm_extra_conf.py ~/.vim/
    else
        echo "You need to install the YouCompleteMe plugin for Vim by"
        echo -e "dj setup vim-env\n"
    fi

    cd ${cwd_before_running}
}

# =============================================================================
function dj()
{
    # ------------------------------
    if [ $# -eq 0 ] ; then
        _dj_help
        return
    fi
    # ------------------------------
    if [ $1 = 'clone' ] ; then
        # --------------------------
        if [[ "$2" = 'bitbucket' ]] || \
           [[ "$2" = 'github' ]] || \
           [[ "$2" = 'gitee' ]] ; then
            _dj_clone_from $2 $3 $4 $5 $6 $7
            return
        fi
        _dj_clone_help
        return
    fi
    # ------------------------------
    if [ $1 = 'clone-ssh' ] ; then
        # --------------------------
        if [[ "$2" = 'bitbucket' ]] || \
           [[ "$2" = 'github' ]] || \
           [[ "$2" = 'gitee' ]] ; then
            _dj_clone_ssh_from $2 $3 $4 $5 $6 $7
            return
        fi
        _dj_clone_help
        return
    fi
    # ------------------------------
    if [ $1 = 'format' ] ; then
        if [[ $# -ge 2 ]] ; then
            _dj_format $2 $3 $4 $5 $6 $7 $8
            return
        fi
        echo 'arguments wrong, exit'
        return
    fi
    # ------------------------------
    if [ $1 = 'find' ] ; then
        if [[ $# -ge 2 ]] ; then
            _dj_find $2 $3 $4 $5 $6 $7 $8
            return
        fi
        echo 'arguments wrong, exit'
        return
    fi
    # ------------------------------
    if [ $1 = 'help' ] ; then
        if [ $# -ge 2 ] ; then
            _dj_help_skill $2
            return
        fi
        echo 'arguments wrong, exit'
        return
    fi
    # ------------------------------
    if [ $1 = 'meson' ] ; then
        if [ $# -ge 2 ] && [ $2 = 'build' ] ; then
            _dj_meson_build $3 $4 $5 $6
            return
        fi
        if [ $# -ge 2 ] && [ $2 = 'find' ] ; then
            _dj_meson_find $3 $4 $5 $6
            return
        fi
        echo 'arguments wrong, exit'
        return
    fi
    # ------------------------------
    if [ $1 = 'open' ] ; then
        _dj_open_file $2 $3 $4
        return
    fi
    # ------------------------------
    if [ $1 = 'replace' ] ; then
        if [[ $# -ge 2 ]] ; then
            _dj_replace $2 $3 $4 $5 $6 $7 $8
            return
        fi
        echo 'arguments wrong, exit'
        return
    fi
    # ------------------------------
    if [ $1 = 'setup' ] ; then
        if [ $# -ge 2 ] ; then
            _dj_setup $2 $3 $4 $5 $6 $7
            return
        fi
        echo 'arguments wrong, exit'
        return
    fi
    # ------------------------------
    if [ $1 = 'ssh' ] ; then
        if [ $2 = 'no-password' ] ; then
            _dj_ssh_no_password $3 $4 $5 $6 $7
            return
        fi
        return
    fi

    # ------------------------------
    if [ $1 = 'udev' ] ; then
        if [ $# -ge 2 ] ; then
            _dj_udev $2 $3 $4 $5 $6 $7
            return
        fi
        echo 'arguments wrong, exit'
        return
    fi
    # ------------------------------
    if [ $1 = 'udevadm' ] ; then
        _dj_udevadm $2 $3
        return
    fi
    # ------------------------------
    if [ $1 = 'work-check' ] ; then
        _dj_work_check $2 $3 $4 $5
        return
    fi
    _dj_help
    # ------------------------------
}

# =============================================================================
function _dj()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        clone
        clone-ssh
        format
        find
        help
        meson
        open
        replace
        setup
        ssh
        udev
        udevadm
        work-check
    ")

    # declare an associative array for options
    declare -A ACTIONS

    #---------------------------------------------------------
    #---------------------------------------------------------
    setup_tools+="adobe-pdf-reader arduino-1.8.13 baidu-netdisk clang-format clang-llvm cmake "
    setup_tools+="computer container kdiff3-meld dj-gadgets devtools dropbox eigen3 "
    setup_tools+="foxit-pdf-reader gcc-arm-stm32 gcc-arm-linux-gnueabi gcc-arm-linux-gnueabihf "
    setup_tools+="gcc-aarch64-linux-gnu git-lfs gitg-gitk glfw3 google-repo gtest-glog gnome "
    setup_tools+="grpc-1.29.1 g++-10 i219-v lcm libev-4.33 libgpiod libiio lib-serialport libyaml-cpp "
    setup_tools+="mathpix matplot++ mongodb nvidia nvtop opencv-2.4.13 opencv-4.1.1 opencv-4.2.0 "
    setup_tools+="pangolin pip qemu qt-5.13.1 qt-5.14.2 ros-melodic ros-noetic ros2-foxy spdlog "
    setup_tools+="slack stm32-cubeMX stm32-tools sublime typora vim-env vscode vtk-8.2.0 wubi "
    setup_tools+="YouCompleteMe you-complete-me "
    ACTIONS[setup]="$setup_tools "
    for i in $setup_tools ; do
        ACTIONS[$i]=" "
    done
    # special ones -----------------
    ACTIONS[container]="docker dive lxd-4.0 "
    ACTIONS[docker]=" "
    ACTIONS[dive]="  "
    ACTIONS[lxd-4.0]=" "
    # ---------------------
    ACTIONS[i219-v]="e1000e-3.4.2.1 e1000e-3.4.2.4 "
    ACTIONS[e1000e-3.4.2.1]=" "
    ACTIONS[e1000e-3.4.2.4]=" "
    # ---------------------
    ACTIONS[opencv-4.1.1]="with-contrib no-contrib "
    ACTIONS[with-contrib]=" "
    ACTIONS[no-contrib]=" "
    # ---------------------
    ACTIONS[qemu]="2.11.1 4.2.0 "
    ACTIONS[2.11.1]=" "
    ACTIONS[4.2.0]=" "
    # ---------------------
    ACTIONS[ros-melodic]="--from-deb-package --from-source "
    ACTIONS[ros-noetic]=" "
    ACTIONS[ros2-foxy]="--from-deb-package --from-source "
    ACTIONS[--from-deb-package]=" "
    ACTIONS[--from-source]=" "
    # ---------------------
    ACTIONS[spdlog]="static shared "
    ACTIONS[libyaml-cpp]="-v "
    ACTIONS[-v]="0.6.2 0.6.3 "
    ACTIONS[0.6.2]=" "
    ACTIONS[0.6.3]=" "

    #---------------------------------------------------------
    #---------------------------------------------------------
    ACTIONS[clone]="bitbucket github gitee "
    ACTIONS[clone-ssh]="bitbucket github gitee "
    
    #---------------------------------------------------------
    format_list="brush enable disable show "
    ACTIONS[format]="$format_list "
    for i in $format_list ; do
        ACTIONS[$i]=" "
    done
    ACTIONS[format]+="implement "
    ACTIONS[brush]+="google file "
    ACTIONS[implement]="dj bg "
    
    #---------------------------------------------------------
    ACTIONS[replace]=" "

    #---------------------------------------------------------
    bitbucket_repos="$(_dj_clone_repo_list BitBucket)"
    ACTIONS[bitbucket]+="$bitbucket_repos "
    for i in $bitbucket_repos ; do
        ACTIONS[$i]=" "
    done
    #---------------------------------------------------------
    github_repos="$(_dj_clone_repo_list GitHub)"
    ACTIONS[github]+="$github_repos "
    for i in $github_repos ; do
        ACTIONS[$i]=" "
    done
    #---------------------------------------------------------
    gitee_repos="$(_dj_clone_repo_list GiTee)"
    ACTIONS[gitee]+="$gitee_repos "
    for i in $gitee_repos ; do
        ACTIONS[$i]=" "
    done

    #---------------------------------------------------------
    #---------------------------------------------------------
    ACTIONS[open]=" "

    #---------------------------------------------------------
    #---------------------------------------------------------
    ACTIONS[ssh]="no-password "
    ACTIONS[no-password]=" "

    #---------------------------------------------------------
    #---------------------------------------------------------
    ACTIONS[work-check]=" "
    
    #---------------------------------------------------------
    #---------------------------------------------------------
    udev_list="uvc-video-capture --dialout one-third-console "
    udev_list+="stlink-v2.1 logitech-f710 "
    ACTIONS[udev]="$udev_list "
    for i in $udev_list ; do
        ACTIONS[$i]=" "
    done

    #---------------------------------------------------------
    #---------------------------------------------------------
    udevadm_list="$(ls /dev/tty*) "
    ACTIONS[udevadm]="$udevadm_list "
    for i in $udevadm_list ; do
        ACTIONS[$i]=" "
    done

    #---------------------------------------------------------
    #---------------------------------------------------------
    find_list=" "
    ACTIONS[find]="$find_list "
    for i in $find_list ; do
        ACTIONS[$i]=" "
    done

    #---------------------------------------------------------
    #---------------------------------------------------------
    meson_list="build find "
    ACTIONS[meson]="$meson_list "
    for i in $meson_list ; do
        ACTIONS[$i]=" "
    done

    #---------------------------------------------------------
    #---------------------------------------------------------
    help_list="auto-mount ffmpeg "
    ACTIONS[help]="$help_list "
    for i in $help_list ; do
        ACTIONS[$i]=" "
    done
    
    # --------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================
complete -F _dj dj
