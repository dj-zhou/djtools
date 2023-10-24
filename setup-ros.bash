#!/bin/bash

# =============================================================================
# not used, but just keep it here
function _dj_setup_ros_melodic() {
    _pushd_quiet ${PWD}

    # only Uubntu 18.04 can install ros-melodic
    if [[ $ubuntu_v != *'Ubuntu 18.04'* ]]; then
        echo -e "ROS Melodic can only be installed on Ubuntu 18.04"
        return
    fi

    # setup sources.list ---------------
    if [ ! -f /etc/apt/sources.list.d/ros-latest.list ]; then
        sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    fi

    # setup keys ---------------
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

    # installation ---------------
    sudo apt-get -y update || true
    _install_if_not_installed ros-melodic-desktop-full

    # initialize rosdep ---------------
    _install_if_not_installed python-pip
    sudo pip install -U rosdep
    sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
    sudo rosdep init || true
    rosdep update

    installed=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"source /opt/ros/melodic/setup.bash"* ]]; then
            installed=1
        fi
    done <$rc_file

    if [ $installed = 0 ]; then
        echo -e "source /opt/ros/melodic/setup.bash\n" >>$rc_file
    fi

    _install_if_not_installed python-roslaunch
    _install_if_not_installed python3-roslaunch

    echo -e '\n' >>$rc_file
    echo '# ===========================================================' >>$rc_file
    echo '# ROS (1) setup' >>$rc_file
    # echo 'export HOSTNAME:' >> $rc_file
    echo 'export ROS_MASTER_URI=http://localhost:11311' >>$rc_file
    echo 'export ROS_IP=localhost' >>$rc_file
    echo -e "ROS (1) settings are in $rc_file."

    # setup workspace ---------------
    cat <<eom
---------------------------------------------
You can run those now:
  $ source $rc_file
  $ mkdir -p ~/catkin_ws/src
  $ cd ~/catkin_ws
  $ catkin_make
---------------------------------------------
eom

    _popd_quiet
}

# =============================================================================
# not used, but just keep it here
function _dj_setup_ros_noetic() {
    _pushd_quiet ${PWD}

    # only Uubntu 18.04 can install ros-melodic
    if [[ $ubuntu_v != *'Ubuntu 20.04'* ]]; then
        echo -e "ROS Noetic can only be installed on Ubuntu 20.04"
        return
    fi

    # setup sources.list ---------------
    if [ ! -f /etc/apt/sources.list.d/ros-latest.list ]; then
        sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    fi
    # setup keys ---------------
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

    # installation ---------------
    sudo apt-get -y update || true
    _install_if_not_installed ros-noetic-desktop-full

    # initialize rosdep ---------------
    _install_if_not_installed python3-rosdep2
    sudo rm /etc/ros/rosdep/sources.list.d/20-default.list
    sudo rosdep init || true
    rosdep update

    # fix a problem: ros noetic resource not found: roslaunch
    _install_if_not_installed ros-noetic-roswtf

    installed=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"source /opt/ros/noetic/setup.bash"* ]]; then
            installed=1
        fi
    done <$rc_file

    if [ $installed = 0 ]; then
        echo -e "source /opt/ros/noetic/setup.bash\n" >>$rc_file
    fi

    echo -e '\n' >>$rc_file
    echo '# ===========================================================' >>$rc_file
    echo '# ROS (1) setup' >>$rc_file
    # echo 'export HOSTNAME:' >>$rc_file
    echo 'export ROS_MASTER_URI=http://localhost:11311' >>$rc_file
    echo 'export ROS_IP=localhost' >>$rc_file
    echo -e "ROS (1) settings are in $rc_file"

    # setup workspace ---------------
    cat <<eom
---------------------------------------------
You can run those now:
  $ source $rc_file
  $ mkdir -p ~/catkin_ws/src
  $ cd ~/catkin_ws
  $ catkin_make
---------------------------------------------
eom

    _popd_quiet
}

# =============================================================================
# https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Install-Debians/
# todo: fix apt-key
function _dj_setup_ros2_foxy_from_deb_package() {
    _pushd_quiet ${PWD}

    # only Uubntu 20.04 can install ros2 Foxy Fitzroy
    if [[ $ubuntu_v != *'Ubuntu 20.04'* ]]; then
        echo_warn "ROS2 Foxy Fitzroy can only be installed on Ubuntu 20.04"
        return
    fi

    # setup locale ---------------
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8

    # install dependencies ---------------
    sudo apt-get -y update
    _install_if_not_installed curl gnupg2 lsb-release

    # authorize our GPG key with apt ---------------
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

    # setup sources.list ---------------
    if [[ ! -f /etc/apt/sources.list.d/ros2-latest.list ]]; then
        sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
    fi

    # installation ---------------
    sudo apt-get -y update || true
    _install_if_not_installed ros-foxy-desktop

    source /opt/ros/foxy/setup.bash

    # ROS 2 command line tools use argcomplete to autocompletion.
    sudo apt install python3-argcomplete

    installed=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"source /opt/ros/foxy/setup.bash"* ]]; then
            installed=1
        fi
    done <$rc_file

    if [[ $installed = 0 ]]; then
        echo -e '\n' >>$rc_file
        echo '# ===========================================================' >>$rc_file
        echo '# (djtools) ROS 2 setup' >>$rc_file
        echo -e "source /opt/ros/foxy/setup.bash\n" >>$rc_file
    fi

    cat <<eom
---------------------------------------------
Try ROS2:
    1. in one terminal, run commands:
    $ source /opt/ros/foxy/setup.bash
    $ ros2 run demo_nodes_cpp talker
    2. in a new terminal, run commands:
    $ source /opt/ros/foxy/setup.bash
    $ ros2 run demo_nodes_py listener
---------------------------------------------

Other references:
https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Install-Debians/#install-additional-rmw-implementations-optional
https://index.ros.org/doc/ros2/Installation/Foxy/Linux-Install-Debians/#install-additional-packages-using-ros-1-packages
eom

    _popd_quiet
}

# =============================================================================
function _dj_setup_ros2_foxy_from_source() {
    echo "todo"
}

# =============================================================================
function _dj_setup_ros2_foxy() {
    if [[ $# = 0 || $1 = '--from-deb-package' ]]; then
        _dj_setup_ros2_foxy_from_deb_package
        return
    fi
    if [[ $1 = '--from-source' ]]; then
        _dj_setup_ros2_foxy_from_source
        return
    fi
}

# =============================================================================
# https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html
function _dj_setup_ros2_humble_from_deb_package() {
    # only Uubntu 22.04 can install ROS2 Humble Hawksbill
    if [[ $ubuntu_v != *'Ubuntu 22.04'* ]]; then
        echo_warn "ROS2 Humble Hawksbill can only be installed on Ubuntu 22.04"
        return
    fi

    # install packages
    _show_and_run sudo apt update -y
    _show_and_run _install_if_not_installed locales software-properties-common curl

    # Set locale
    _show_and_run sudo locale-gen en_US en_US.UTF-8
    _show_and_run sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    _show_and_run export LANG=en_US.UTF-8

    # Setup Sources
    _show_and_run _install_if_not_installed
    _show_and_run sudo add-apt-repository universe

    # Now add the ROS 2 GPG key with apt
    _show_and_run sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

    # add the repository to your sources list
    _show_and_run echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list >/dev/null

    # Install ROS 2 packages
    _show_and_run sudo apt update -y
    # Desktop Install: ROS, RViz, demos, tutorials.
    _show_and_run sudo apt install ros-humble-desktop -y
    _show_and_run sudo apt install ros-dev-tools -y

    # Setup environment
    installed=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"source /opt/ros/humble/setup.bash"* ]]; then
            installed=1
        fi
    done <$rc_file

    if [[ $installed = 0 ]]; then
        echo -e '\n' >>$rc_file
        echo '# ===========================================================' >>$rc_file
        echo '# (djtools) ROS 2 Humble setup' >>$rc_file
        echo -e "source /opt/ros/humble/setup.bash\n" >>$rc_file
    fi
}

# =============================================================================
function _dj_setup_ros2_humble_from_source() {
    echo "todo"
}

# =============================================================================
function _dj_setup_ros2_humble() {
    if [[ $# = 0 || $1 = '--from-deb-package' ]]; then
        _dj_setup_ros2_humble_from_deb_package
        return
    fi
    if [[ $1 = '--from-source' ]]; then
        _dj_setup_ros2_humble_from_source
        return
    fi
}
