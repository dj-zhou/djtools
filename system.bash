#!/bin/bash

# =============================================================================
function _system_enable_help() {
    echo " _system_enable_help"
    echo "   -- xxxx "
    echo "   -- MORE IS COMMING "
}

# =============================================================================
function _system_disable_help() {
    echo -e "system disable <argument>"
    echo "   -- program-problem-detected : to disable an Ubuntu error report"
    echo -e "   -- MORE IS COMMING"
}

# =============================================================================
function _system_exam_help() {
    echo -e "system exam [argument]"
    echo "   -- cpu-memory    : to exam CPU and memory usage of a PID"
    echo "   -- nvidia-driver : to exam nvidia driver"
    echo "   -- temperature   : to exam CPU temperature"
    echo "   -- udev-rules    : to exam udev rules"
    echo -e "   -- MORE IS COMMING"
}

# =============================================================================
function _system_disable_program_problem_detected() {
    sudo rm -f /var/crash/*
    sudo sed -i "s/enabled=1/enabled=0/g" /etc/default/apport
    echo -e "/etc/default/apport is revised to:"
    cat /etc/default/apport
    echo -e '\n'
}

# =============================================================================
function _system_disable_apt_dpkg_locks() {
    echo -e "${RED}running this command with caution!!${NOC}"

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

    echo "sudo rm -f /var/cache/apt/archives/lock"
    sudo rm -f /var/cache/apt/archives/lock
    _press_enter_to_continue
}

# =============================================================================
function _system_exam_cpu_memory() {
    if [ $# = 0 ]; then
        echo -e "system exam cpu-memory"
        echo "    usage (example): "
        echo -e "   system exam cpu-memory \"./bin/main\""
        return
    fi
    cmd=$1
    pre_pid=$(ps aux | grep "$cmd" | awk '{print $2}')
    final_pid=$(echo $pre_pid | awk '{print $1}')
    echo -e "[$RED"$final_pid"$NOC] "$cmd
    ps -p $final_pid -o %cpu,%mem
}

# =============================================================================
function _system_exam_temperature() {
    if [[ "yes" = $(_check_if_package_installed lm-sensors) ]]; then
        sensors
        return
    fi
    if [[ "$ubuntu_v" = *"18.04"* ]] ||
        [[ "$ubuntu_v" = *"20.04"* ]]; then
        ## cat /sys/class/thermal/thermal_zone*/temp
        zones=$(ls /sys/class/thermal/ | grep thermal_zone)
        num_of_zones=$(echo "$zones" | wc -w)
        # echo "number of zones: $num_of_zones"
        sum_temp=0
        # echo "temperature X 1000: "
        for i in $zones; do
            temp=$(($(cat /sys/class/thermal/$i/temp) / 1000))
            echo -e "$i\t $temp" # how to convert string to float?
            sum_temp=$(($sum_temp + $temp))
        done
        # calcuate the average and show in C
        echo -e "average temperature: $(($sum_temp / 14))°C"
        echo -e "you can install ${INFO}lm-sensors${NOC} to have a better view"
        return
    fi
}

# =============================================================================
function _system_exam_nvidia_driver() {
    _install_if_not_installed inxi
    inxi -G

    nvidia-smi
}

# =============================================================================
function _system_exam_process() {
    echo -e "run ${PRP}ps aux | grep $1${NOC}"
    ps aux | grep $1
}

# =============================================================================
function _system_exam_threads() {
    if [ $# -eq 0 ]; then
        echo "usage: system exam threads [keyword]"
        return
    fi
    echo -e "run ${PRP}ps -eLf | grep $1${NOC}"
    ps -eLf | grep $1
}

# =============================================================================
function _system_wallpaper_random() {
    # exam if wallpaper_folder is set in .bashrc
    wallpaper_folder_is_set=0
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == *"wallpaper_folder="* ]]; then
            wallpaper_folder_is_set=1
        fi
    done <$rc_file

    if [ $wallpaper_folder_is_set = 0 ]; then
        echo -e "variable ${INFO}wallpaper_folder${NOC} is NOT set, please enter a path of the wallpapers: "
        read answer
        echo '# ===========================================================' >>$rc_file
        echo '# (djtools) wallpaper setup' >>$rc_file
        echo 'wallpaper_folder='$answer >>$rc_file
        echo -e '\n' >>$rc_file
    fi
    # _random_wallpaper # from funcs.bash
    _pushd_quiet ${PWD}

    cd $wallpaper_folder
    set -- *

    # fixed by ChatGPT
    # Store the file paths in an array
    mapfile -t wallpapers < <(find "$wallpaper_folder" -type f)
    length=${#wallpapers[@]}
    random_num=$((RANDOM % length))
    selected_wallpaper="${wallpapers[$random_num]}"
    gsettings set org.gnome.desktop.background picture-uri "file://$selected_wallpaper"

    _popd_quiet
}

# =============================================================================
function system() {
    # ------------------------------
    if [ $# -eq 0 ]; then
        echo "system: need an argument."
        return
    fi
    # ------------------------------
    if [ $1 = 'enable' ]; then
        _system_enable_help
        return
    fi
    # ------------------------------
    if [ $1 = 'disable' ]; then
        if [ $# = 1 ]; then
            _system_disable_help
            return
        fi
        # --------------------------
        if [ $2 = 'program-problem-detected' ]; then
            _system_disable_program_problem_detected $3 $4 $5 $6 $7
            return
        fi
        # --------------------------
        if [ $2 = 'apt-dpkg-locks' ]; then
            _system_disable_apt_dpkg_locks $3 $4 $5 $6 $7
            return
        fi
    fi
    # ------------------------------
    if [ $1 = 'exam' ]; then
        if [ $# = 1 ]; then
            _system_exam_help
            return
        fi
        # --------------------------
        if [ $2 = 'cpu-memory' ]; then
            _system_exam_cpu_memory $3 $4 $5
            return
        fi
        # --------------------------
        if [ $2 = 'nvidia-driver' ]; then
            _system_exam_nvidia_driver
            return
        fi
        # --------------------------
        if [ $2 = 'process' ]; then
            _system_exam_process $3 $4 $5
            return
        fi
        # --------------------------
        if [ $2 = 'temperature' ]; then
            _system_exam_temperature
            return
        fi
        # --------------------------
        if [ $2 = 'threads' ]; then
            _system_exam_threads $3 $4 $5
            return
        fi
    fi
    # ------------------------------
    if [ $1 = 'wallpaper' ]; then
        if [ $# = 1 ]; then
            echo "system wallpaper: need argument"
            return
        fi
        # --------------------------
        if [ $2 = 'random' ]; then
            _system_wallpaper_random
            return
        fi
        return
    fi
    # ------------------------------
    if [ $1 = 'ubuntu-drivers' ]; then
        if [ $# = 1 ]; then
            echo "sudo ubuntu-drivers: need argument"
            return
        fi
        # --------------------------
        if [ $2 = 'autoinstall' ]; then
            sudo ubuntu-drivers autoinstall
            return
        fi
    fi
}

# =============================================================================
function _system_linux() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        enable
        disable
        exam
        wallpaper
        ubuntu-drivers
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # no space in front or after "="
    ACTIONS[enable]+=" "
    disable_list="program-problem-detected apt-dpkg-locks "
    ACTIONS[disable]+="$disable_list "
    for i in $disable_list; do
        ACTIONS[$i]=" "
    done
    exam_list="cpu-memory temperature nvidia-driver "
    exam_list+="process threads "
    ACTIONS[exam]+="$exam_list "
    for i in $exam_list; do
        ACTIONS[$i]=" "
    done
    ACTIONS[wallpaper]+="random "
    ACTIONS[random]+=" "
    # ---------------------------------------------------------
    ACTIONS["ubuntu-drivers"]+="autoinstall "
    ACTIONS[autoinstall]+=" "

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
if [ $system = 'Linux' ]; then
    complete -F _system_linux system
# elif [ $system = 'Darwin' ]; then
#     echo "todo"
fi
