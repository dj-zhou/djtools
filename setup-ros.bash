#!/bin/bash

# ===========================================================================================
function _dj_setup_ros_melodic()
{
    cwd_before_running=$PWD

    # only Uubntu 18.04 can install ros-melodic
    ubuntu_release_version=$(lsb_release -a)
    if [[ $ubuntu_release_version != *'Ubuntu 18.04'* ]] ; then
        echo -e "\nROS Melodic can only be installed in Ubuntu 18.04\n"
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
        echo -e "source /opt/ros/melodic/setup.bash\n" >> ~/.bashrc
    fi

    # setup workspace ---------------
    mkdir -p ~/catkin_ws/src
    cd ~/catkin_ws
    catkin_make
    
    cd ${cwd_before_running}
}

# ===========================================================================================
function _dj_setup_ros2_foxy()
{
    echo "1 = "$1
    if [ $1 = '--from-deb-package' ] ; then
        echo  "from package"
        return
    fi
    if [ $1 = '--from-source' ] ; then
        echo  "from source"
        return
    fi
}