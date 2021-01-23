#!/bin/bash

# =============================================================================
function _system_help()
{
    echo -e '\n system help\n'
    echo ' exmaple command 1:'
    echo '   -- enable '
    echo '   -- disable '
    echo '   -- check '
    echo '   -- wallpaper '
    echo '   -- ubuntu-drivers '
    echo -e "   -- MORE IS COMMING\n"
}

# =============================================================================
function _system_enable_help()
{
    echo " _system_enable_help"
    echo "   -- xxxx "
    echo "   -- MORE IS COMMING "
}

# =============================================================================
function _system_disable_help()
{
    echo -e "\n system disable <argument>"
    echo "   -- program-problem-detected : to disable an Ubuntu error report"
    echo -e "   -- MORE IS COMMING\n"
}

# =============================================================================
function _system_check_help()
{
    echo -e "\n system check <argument>"
    echo "   -- cpu-memory    : to check CPU and memory usage of a PID"
    echo "   -- nvidia-driver : to check nvidia driver"
    echo "   -- temperature   : to check CPU temperature"
    echo "   -- udev-rules    : to check udev rules"
    echo -e "   -- MORE IS COMMING\n"
}

# =============================================================================
function _system_disable_program_problem_detected()
{
    sudo rm -f /var/crash/*
    sudo sed -i "s/enabled=1/enabled=0/g" /etc/default/apport
    echo -e "/etc/default/apport is revised to\n"
    cat /etc/default/apport
    echo -e '\n'
}

# =============================================================================
function _system_disable_apt_dpkg_locks()
{
    echo -e "\n${RED} running this command with caution!!${NOC}\n"
    
    echo "sudo rm -f /var/lib/dpkg/lock-frontend"
    sudo rm -f /var/lib/dpkg/lock-frontend
    _press_enter_to_continue

    echo "sudo rm -f /var/lib/dpkg/lock"
    sudo rm -f /var/lib/dpkg/lock
    _press_enter_to_continue

    echo "sudo rm -f /var/lib/apt/lock"
    sudo rm -f /var/lib/apt/lock
    _press_enter_to_continue

    echo "sudo rm -f /var/lib/apt/lists/lock"
    sudo rm -f /var/lib/apt/lists/lock
    _press_enter_to_continue
}

# =============================================================================
function _system_check_cpu_memory()
{
    if [ $# = 0 ] ; then
        echo -e "\n system check cpu-memory"
        echo    "    usage (example): "
        echo -e "   system check cpu-memory \"./bin/main\"\n"
        return
    fi
    cmd=$1
    pre_pid=$(ps aux | grep "$cmd" | awk '{print $2}') 
    final_pid=$(echo $pre_pid | awk '{print $1}')
    echo -e "[$RED"$final_pid"$NOC] "$cmd
    ps -p $final_pid -o %cpu,%mem
}

# =============================================================================
function _system_check_temperature()
{
    _install_if_not_installed lm-sensors
    if [[ "$ubuntu_v" = *"18.04"* ]] || \
       [[ "$ubuntu_v" = *"20.04"* ]] ; then
        ## cat /sys/class/thermal/thermal_zone*/temp
        zones=$(ls /sys/class/thermal/ | grep thermal_zone)
        echo "temperature X 1000: "
        for i in $zones ; do
            temp_x1000=$(cat /sys/class/thermal/$i/temp)
            echo -e "$i\t $temp_x1000" # how to convert string to float?
        done
        return
    fi
    sensors
}

# =============================================================================
function _system_check_nvidia_driver()
{
    _install_if_not_installed inxi
    inxi -G

    nvidia-smi
}

# =============================================================================
function _system_check_process()
{
    echo -e "run ${PRP}ps aux | grep $1${NOC}"
    ps aux | grep $1
}

# =============================================================================
function _system_check_threads()
{
    echo -e "run ${PRP}ps -eLf | grep $1${NOC}"
    ps -eLf | grep $1
}

# =============================================================================
function _system_wallpaper_random()
{
    # check if wallpaper_folder is set in .bashrc
    wallpaper_folder_is_set=0
    while IFS='' read -r line || [[ -n "$line" ]] ; do
        if [[ $line == *"wallpaper_folder="* ]] ; then
            wallpaper_folder_is_set=1
        fi
    done < ~/.bashrc

    if [ $wallpaper_folder_is_set = 0 ] ; then
        echo -e "\nwallpaper_folder is NOT set. please enter a path of the wallpapers: "
        read answer
        
        echo '# ===========================================================' >> ~/.bashrc
        echo '# (djtools) wallpaper setup' >> ~/.bashrc
        echo 'wallpaper_folder='$answer >> ~/.bashrc
        echo -e '\n' >> ~/.bashrc
        echo -e "\n"
    fi
    # _random_wallpaper # from funcs.bash
    current_folder=${PWD}

    cd $wallpaper_folder
    set -- *
    length=$#
    random_num=$((( $RANDOM % ($length) ) + 1))
    # it only works for gnome
    gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_folder/${!random_num}"
    
    cd $current_folder
}

# =============================================================================
function system()
{
    # ------------------------------
    if [ $# -eq 0 ] ; then
        _system_help
        return
    fi
    # ------------------------------
    if [ $1 = 'enable' ] ; then
        _system_enable_help
        return
    fi
    # ------------------------------
    if [ $1 = 'disable' ] ; then
        if [ $# = 1 ] ; then
            _system_disable_help
            return
        fi
        # --------------------------
        if [ $2 = 'program-problem-detected' ] ; then
            _system_disable_program_problem_detected $3 $4 $5 $6 $7
            return
        fi
        # --------------------------
        if [ $2 = 'apt-dpkg-locks' ] ; then
            _system_disable_apt_dpkg_locks $3 $4 $5 $6 $7
            return
        fi
    fi
    # ------------------------------
    if [ $1 = 'check' ] ; then
        if [ $# = 1 ] ; then
            _system_check_help
            return
        fi
        # --------------------------
        if [ $2 = 'cpu-memory' ] ; then
            _system_check_cpu_memory $3 $4 $5
            return
        fi
        # --------------------------
        if [ $2 = 'nvidia-driver' ] ; then
            _system_check_nvidia_driver
            return
        fi
        # --------------------------
        if [ $2 = 'process' ] ; then
            _system_check_process $3 $4 $5
            return
        fi
        # --------------------------
        if [ $2 = 'temperature' ] ; then
            _system_check_temperature
            return
        fi
        # --------------------------
        if [ $2 = 'threads' ] ; then
            _system_check_threads $3 $4 $5
            return
        fi
    fi
    # ------------------------------
    if [ $1 = 'wallpaper' ] ; then
        if [ $# = 1 ] ; then
            echo "system wallpaper: need argument"
            return
        fi
        # --------------------------
        if [ $2 = 'random' ] ; then
            _system_wallpaper_random
            return
        fi
        return
    fi
    # ------------------------------
    if [ $1 = 'ubuntu-drivers' ] ; then
        if [ $# = 1 ] ; then
            echo "sudo ubuntu-drivers: need argument"
            return
        fi
        # --------------------------
        if [ $2 = 'autoinstall' ] ; then
            sudo ubuntu-drivers autoinstall
            return
        fi
    fi
}

# =============================================================================
function _system()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        enable
        disable
        check
        wallpaper
        ubuntu-drivers
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # no space in front or after "="
    ACTIONS[enable]+=" "
    disable_list="program-problem-detected apt-dpkg-locks "
    ACTIONS[disable]+="$disable_list "
    for i in $disable_list ; do
        ACTIONS[$i]=" "
    done
    check_list="cpu-memory temperature nvidia-driver "
    check_list+="process threads "
    ACTIONS[check]+="$check_list "
    for i in $check_list ; do
        ACTIONS[$i]=" "
    done
    ACTIONS[wallpaper]+="random "
    ACTIONS[random]+=" "
    # ---------------------------------------------------------
    ACTIONS[ubuntu-drivers]+="autoinstall "
    ACTIONS[autoinstall]+=" "

    
    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================
complete -F _system system
