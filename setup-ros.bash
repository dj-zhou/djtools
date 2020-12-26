#!/bin/bash

# =============================================================================
function _dj_setup_ros_melodic()
{
    cwd_before_running=$PWD

    # only Uubntu 18.04 can install ros-melodic
    if [[ $ubuntu_v != *'Ubuntu 18.04'* ]] ; then
        echo -e "\n ROS Melodic can only be installed on Ubuntu 18.04\n"
        return
    fi

    # setup sources.list ---------------
    if [ ! -f /etc/apt/sources.list.d/ros-latest.list ] ; then
        sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    fi

    # setup keys ---------------
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

    # installation ---------------
    sudo apt-get -y update || true
    sudo apt-get install ros-melodic-desktop-full -y

    # initialize rosdep ---------------
    sudo apt-get install python-pip
    sudo pip install -U rosdep
    sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
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

    sudo apt-get -y install python-roslaunch
    sudo apt-get -y install python3-roslaunch

    echo -e '\n' >> ~/.bashrc
    echo '# ===========================================================' >> ~/.bashrc
    echo '# ROS (1) setup' >> ~/.bashrc
    # echo 'export HOSTNAME:' >> ~/.bashrc
    echo 'export ROS_MASTER_URI=http://localhost:11311' >> ~/.bashrc
    echo 'export ROS_IP=localhost' >> ~/.bashrc
    echo -e "\n ROS (1) settings are in ~/.bashrc.\n"

    # setup workspace ---------------
    cat << EOM

    ---------------------------------------------
    You can run those now:
      $ source ~/.bashrc
      $ mkdir -p ~/catkin_ws/src
      $ cd ~/catkin_ws
      $ catkin_make
    ---------------------------------------------

EOM

    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_ros_noetic()
{
    cwd_before_running=$PWD

    # only Uubntu 18.04 can install ros-melodic
    if [[ $ubuntu_v != *'Ubuntu 20.04'* ]] ; then
        echo -e "\n ROS Noetic can only be installed on Ubuntu 20.04\n"
        return
    fi

    # setup sources.list ---------------
    if [ ! -f /etc/apt/sources.list.d/ros-latest.list ] ; then
        sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    fi
    # setup keys ---------------
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
    # or
    # curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | sudo apt-key add -

    # installation ---------------
    sudo apt-get -y update || true
    sudo apt-get install -y ros-noetic-desktop-full

    # initialize rosdep ---------------
    sudo apt-get install -y python3-rosdep2
    sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
    sudo rosdep init || true
    rosdep update

    # fix a problem: ros noetic resource not found: roslaunch
    sudo apt-get install ros-noetic-roswtf

    installed=0
    while IFS='' read -r line || [[ -n "$line" ]] ; do
        if [[ $line == *"source /opt/ros/noetic/setup.bash"* ]] ; then
            installed=1
        fi
    done < ~/.bashrc

    if [ $installed = 0 ] ; then 
        echo -e "source /opt/ros/noetic/setup.bash\n" >> ~/.bashrc
    fi

    echo -e '\n' >> ~/.bashrc
    echo '# ===========================================================' >> ~/.bashrc
    echo '# ROS (1) setup' >> ~/.bashrc
    # echo 'export HOSTNAME:' >> ~/.bashrc
    echo 'export ROS_MASTER_URI=http://localhost:11311' >> ~/.bashrc
    echo 'export ROS_IP=localhost' >> ~/.bashrc
    echo -e "\n ROS (1) settings are in ~/.bashrc\n"

    # setup workspace ---------------
        cat << EOM

    ---------------------------------------------
    You can run those now:
      $ source ~/.bashrc
      $ mkdir -p ~/catkin_ws/src
      $ cd ~/catkin_ws
      $ catkin_make
    ---------------------------------------------

EOM

    cd ${cwd_before_running}
}

# =============================================================================
# https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Install-Debians/
function _dj_setup_ros2_foxy_from_deb_package()
{
    cwd_before_running=$PWD

    # only Uubntu 20.04 can install ros2 Foxy Fitzroy
    if [[ $ubuntu_v != *'Ubuntu 20.04'* ]] ; then
        echo -e "\n ROS2 Foxy Fitzroy can only be installed on Ubuntu 20.04\n"
        return
    fi

    # setup locale ---------------
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8
    
    # install dependencies ---------------
    sudo apt-get -y update
    sudo apt-get -y install curl gnupg2 lsb-release

    # authorize our GPG key with apt ---------------
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

    # setup sources.list ---------------
    sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

    # installation ---------------
    sudo apt-get -y update || true
    sudo apt-get -y install ros-foxy-desktop

    source /opt/ros/foxy/setup.bash

    # ROS 2 command line tools use argcomplete to autocompletion.
    sudo apt install python3-argcomplete

    installed=0
    while IFS='' read -r line || [[ -n "$line" ]] ; do
        if [[ $line == *"ource /opt/ros/foxy/setup.bash"* ]] ; then
            installed=1
        fi
    done < ~/.bashrc

    if [ $installed = 0 ] ; then
        echo -e '\n' >> ~/.bashrc
        echo '# ===========================================================' >> ~/.bashrc
        echo '# (djtools) ROS 2 setup' >> ~/.bashrc
        echo -e "source /opt/ros/foxy/setup.bash\n" >> ~/.bashrc
    fi

    cat << EOM

    ---------------------------------------------
    Try ROS2:
        1. in one terminal, run commands:
        source /opt/ros/foxy/setup.bash
        ros2 run demo_nodes_cpp talker

        2. in a new terminal, run commands:
        source /opt/ros/foxy/setup.bash
        ros2 run demo_nodes_py listener
    ---------------------------------------------
    
    Other references:
    https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Install-Debians/#install-additional-rmw-implementations-optional
    https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Install-Debians/#install-additional-packages-using-ros-1-packages

EOM

    cd ${cwd_before_running}
}

# =============================================================================
function _dj_setup_ros2_foxy()
{
    if [ $1 = '--from-deb-package' ] ; then
        _dj_setup_ros2_foxy_from_deb_package
        return
    fi
    if [ $1 = '--from-source' ] ; then
        echo  "from source, todo"
        return
    fi
}
