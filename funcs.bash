#!/bin/bash

function echo_info() { echo -e "${CYN}$@${NOC}" 1>&2; }
function echo_cmd() { echo -e "$ ${GRN}$@${NOC}" 1>&2; }
function echo_highlight() { echo -e "${HGRN}$@${NOC}" 1>&2; }
function echo_warn() { echo -e "${YLW}$@${NOC}" 1>&2; }
function echo_error() { echo -e "${RED}$@${NOC}" 1>&2; }

# =============================================================================
function _random_wallpaper() {
    cur_dir=${PWD}

    cd $wallpaper_folder
    set -- *
    length=$#
    random_num=$((($RANDOM % ($length)) + 1))
    gsettings set org.gnome.desktop.background picture-uri \
        "file://$wallpaper_folder/${!random_num}"

    cd $cur_dir
}

# =============================================================================
function _ask_to_remove_a_file() {
    gdialog --title 'Remove a File (djtools)' --yesno \
        'Do you want to remove file "'$1'"?' 9 50
    if [ $? != 0 ]; then
        gdialog --infobox 'File "'$1'" is NOT removed!' 9 50
    else
        rm $1
        gdialog --infobox 'File "'$1'" is removed!' 9 50
    fi
    gdialog --clear
}

# =============================================================================
function _ask_to_remove_a_folder() {
    gdialog --title 'Remove a Folder (djtools)' --yesno \
        'Do you want to remove folder "'$1'"?' 9 50
    if [ $? != 0 ]; then
        gdialog --infobox 'Folder "'$1'" is NOT removed!' 9 50
    else
        rm -rf $1
        gdialog --infobox 'Folder "'$1'" is removed!' 9 50
    fi
    gdialog --clear
}

# =============================================================================
function _ask_to_execute_cmd() {
    echo "command: "$1
    echo -e 'Do you want to execute command "'${1}'"?'
    read answer
    if [[ ($answer = 'n') || ($answer = 'N') || ($answer = 'NO') || (
        $answer = 'No') || ($answer = 'no') ]]; then
        echo 'Command "'$1'" is NOT executed!'
    elif [[ ($answer = 'y') || ($answer = 'Y') || ($answer = 'YES') || (
        $answer = 'Yes') || ($answer = 'yes') ]]; then
        echo 'Command "'$1'" is going to be executed!'
        $1
    else
        echo "Wrong answer! No action was taken!"
    fi
}

# =============================================================================
function _write_to_file_width() {
    str="$1"
    width="$2"
    file="$3"
    str_len=${#str}
    if [ "$str_len" -gt "$width" ]; then
        for ((c = 1; c <= $width; c++)); do
            single_char=${str:${c}-1:1}
            echo -ne "$single_char" >>$file
        done
        echo -ne " " >>$file
        return 1
    fi
    echo -ne "$str" >>$file
    for ((c = 1; c <= $width - $str_len + 1; c++)); do
        echo -ne " " >>$file
    done
}

# =============================================================================
function _press_enter_to_continue() {
    echo -e 'Press [ENTER] to continue ...'
    read answer
    echo $answer
}

# =============================================================================
function _press_enter_or_wait_s_continue() {
    second=$1
    while [ 0 -lt $second ]; do
        if [ $second = '1' ]; then
            echo -ne "\rPress [ENTER] or wait $second second to continue ...    "
        else
            echo -ne "\rPress [ENTER] or wait $second seconds to continue ...   "
        fi
        read -s -N 1 -t 1 key
        if [ "$key" == $'\x0a' ]; then
            break
        fi
        second=$((second - 1))
    done
    echo " "
}

# =============================================================================
function _display_section() {
    echo '----------------------------------------------------'
}

# =============================================================================
# example:
#    _find_argument_after_option -b aa bb -b cc dd
#                                $1 $2 $3 $4 $5 $6
# it will compare the first "-b" with all others, and it will find out $4 matches
# so the output is $5
function _find_argument_after_option() {
    # $1 is the one to find in all arguments from $2 to $9
    find_option=0
    find_argument=0
    for var in "$@"; do
        # echo "$var"
        if [ $var = $1 ]; then
            find_option=$((find_option + 1))
            # echo "find_option = "$find_option
            # echo "find_argument = "$find_argument
        elif [ $find_option = 2 ] && [ $find_argument = 0 ]; then
            arg_found=$var
            find_argument=1
            # echo "arg_found = "$arg_found
            # echo "find_argument = "$find_argument
        fi
        # echo "argument_no = "$argument_no
    done
    # echo "final result = "$arg_found
    echo $arg_found
}

# =============================================================================
function _if_option_exist() {
    find_option=0
    for var in "$@"; do
        if [ $var = $1 ]; then
            find_option=$((find_option + 1))
        fi
        if [ $find_option = 2 ]; then
            echo "true"
            return
        fi
    done
    echo "false"
}

# =============================================================================
# index starts from 1
# example: _find_option_index -s hello world aa bb -s 100 -t 10
# we want to search "-s" in arguments "hello world aa bb -s 100 -t 10"
# so the return value is 5
function _find_option_index() {
    index=0
    to_match="$1"
    shift 1
    for var in "$@"; do
        index=$((index + 1))
        if [ $var = "$to_match" ]; then
            echo "$index"
            return
        fi
    done
    echo "0"
}

# =============================================================================
# argument 1: the string
# argument 2: the character
function _count_a_char_in_str() {
    the_line=$1
    the_char=$2
    found_count=0
    for ((c = 1; c <= ${#the_line}; c++)); do
        single_char=${the_line:${c}-1:1}
        if [[ "$single_char" = "$the_char" ]]; then
            found_count=$((found_count + 1))
        fi
    done
    echo $found_count
}

# =============================================================================
# argument 1: the string
# argument 2: the character
# argument 3: the 1st, 2nd, or the i-th item to be found in the string
# return the position of the i-th character in the string
#            if position == length of the string, means cannot find the char
# the index of the sting starts from 0
function _find_a_char_in_str() {
    the_line=$1
    the_char=$2
    if [ -n "$3" ]; then
        the_i_th=$3
    else
        the_i_th=1
    fi
    found_count=0
    pos=${#the_line}
    for ((c = 1; c <= ${#the_line}; c++)); do
        single_char=${the_line:${c}-1:1}
        if [[ $single_char == $the_char ]]; then
            found_count=$((found_count + 1))
            # echo "find it: "$single_char
            if [ $found_count = $the_i_th ]; then
                pos=$((c - 1))
            fi
        fi
    done
    # echo "found_count = "$found_count
    # echo "pos = "$pos
    echo $pos
}

# =============================================================================
# example:  str ($1) : hello world
#         substr($2) : rld
#             output : 8
# if it does not find the sub string, return the length of str

function _find_substr_index_in_str() {
    str=$1
    substr=$2
    len_str=${#str}
    len_substr=${#substr}
    for ((c = 0; c <= $((len_str - len_substr)); c++)); do
        str_small="${str:${c}:$len_substr}"
        if [[ $str_small == $substr ]]; then
            echo $c
            return
        fi
    done
    echo $len_str
}

# =============================================================================
# str ch start

# example: str ($1) : hello world
#            ch($2) : o
#         start($3) : 5
#            output : 7

function _find_ch_index_in_str_start_from() {
    line=$1
    ch=$2
    if [ -n "$3" ]; then
        start=$3
    else
        start=0
    fi
    len=${#line}
    if [ $start -ge $len ]; then
        echo $len
        return
    fi
    for ((c = $start; c <= $len; c++)); do
        single_char=${line:${c}:1}
        if [[ $single_char == $ch ]]; then
            echo $c
            return
        fi
    done
    echo $len
}

# =============================================================================
function _size_human_readable() { # $fz_byte $output_control
    fz_byte=$1
    output_control=$2
    if [[ $output_control = 'true' ]]; then
        echo $fz_byte
    elif [[ $output_control = 'false' ]]; then
        fz_kbyte=$(awk "BEGIN {print $((fz_byte)) / 1024}" | awk '{printf("%d",$0);}')
        fz_kbyte_int=${fz_kbyte%.*}
        fz_mbyte=$(awk "BEGIN {print $((fz_kbyte_int)) / 1024}" | awk '{printf("%d",$0);}')
        fz_mbyte_int=${fz_mbyte%.*}
        fz_gbyte=$(awk "BEGIN {print $((fz_mbyte_int)) / 1024}" | awk '{printf("%d",$0);}')
        fz_gbyte_int=${fz_gbyte%.*}
        fz_tbyte=$(awk "BEGIN {print $((fz_gbyte_int)) / 1024}" | awk '{printf("%d",$0);}')
        fz_tbyte_int=${fz_tbyte%.*}
        if [[ $fz_kbyte_int = '0' ]]; then
            echo "$fz_byte bytes"
        elif [[ $fz_mbyte_int = '0' ]]; then
            echo "$fz_kbyte KiB"
        elif [[ $fz_gbyte_int = '0' ]]; then
            echo "$fz_mbyte MiB"
        elif [[ $fz_tbyte_int = '0' ]]; then
            echo "$fz_gbyte GiB"
        else
            echo "$fz_tbyte TiB"
        fi
    fi
}

# =============================================================================
function _wget_if_not_exist() { # $filename $md5sum $url $option
    filename=$1
    md5sum_passed_in=$2
    url=$3
    option=$4
    unset md5checksum
    if [[ -f "$filename" ]]; then
        md5checksum=$(md5sum "$filename")
    else
        md5checksum=" "
    fi
    if [[ "$md5checksum" = *"$md5sum_passed_in"* ]]; then
        echo "file exists, no need to wget again"
    else
        wget $option $filename "${url}"
    fi
}

# =============================================================================
# https://stackoverflow.com/questions/1298066/check-if-an-apt-get-package-is-installed-and-then-install-it-if-its-not-on-linu
function _check_if_package_installed() {
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1 2>/dev/null | grep "install ok installed")
    if [ "" = "$PKG_OK" ]; then
        echo "no"
    else
        echo "yes"
    fi
}

# =============================================================================
# should find a better way to install
function _install_if_not_installed() {
    local cur_dir_install=$PWD
    for package in "$@"; do
        if [[ "no" = $(_check_if_package_installed $package) ]]; then
            echo -e "${YLW}installing${NOC} $package"
            # bug: /var/lib/dpkg/lock-frontend, etc, errors will not be seen
            sudo apt-get install -y $package &>/dev/null
        else
            echo -e "$package ${CYN}is already installed${NOC}"
        fi
    done
    cd $cur_dir_install
}

# =============================================================================
function _verify_lib_installation() {
    if [ ! -f "$2/$1" ]; then
        echo -e "${RED}library $1 is not found in $2${NOC}"
    else
        echo -e "     library file: ${GRN}$2/$1${NOC}"
    fi
}

# =============================================================================
function _verify_header_files() {
    if [ $# != 2 ]; then
        echo "usage: _verify_header_files [header file] [path]"
        return
    fi
    if [ ! -f "$2/$1" ]; then
        echo -e "${RED}header file $1 is not found in $2${NOC}"
    else
        echo -e "      header file: ${GRN}$2/$1${NOC}"
    fi
    return
}

# =============================================================================
function _verify_cmake_files() {
    if [ ! -f "$2/$1" ]; then
        echo -e "${RED}cmake file $1 is not found in $2${NOC}"
    else
        echo -e "       cmake file: ${GRN}$2/$1${NOC}"
    fi
}

# =============================================================================
function _verify_pkgconfig_file() {
    if [ ! -f "$2/$1" ]; then
        echo -e "${RED}pkgconfig file $1 is not found in $2${NOC}"
    else
        echo -e "   pkgconfig file:$ ${GRN}$2/$1${NOC}"
    fi
}

# =============================================================================
# find package version from the file .package-version
function _find_package_version() {
    set -eu
    file="$djtools_path/.package-version"
    package=$1
    if [ -z "$package" ]; then
        echo >&2 -e "${RED}error: package empty${NOC}"
        return
    fi
    version=""
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == "$package"* ]]; then
            # echo $line
            if [[ ${ubuntu_v} == *'18.04'* && $line == *'1804'* ]]; then
                pos1=$(_find_substr_index_in_str "$line" "1804")
                pos2=$(_find_ch_index_in_str_start_from "$line" " " $((pos1 + 4)))
                echo ${line:$((pos1 + 5)):$((pos2 - pos1 - 5))}
                return
            elif [[ ${ubuntu_v} == *'20.04'* && $line == *'2004'* ]]; then
                pos1=$(_find_substr_index_in_str "$line" "2004")
                pos2=$(_find_ch_index_in_str_start_from "$line" " " $((pos1 + 4)))
                echo ${line:$((pos1 + 5)):$((pos2 - pos1 - 5))}
                return
            # elif: other system: todo
            else
                version=$(echo $line | awk '{ print $2 }')
                echo $version
                return
            fi

        fi
    done <$file
    if [ -z "$version" ]; then
        echo >&2 -e "${RED}error: package $package version not found, need to update .package-version${NOC}"
        return
    fi
    echo $version
}

# =============================================================================
function _echo_install() { # package # version
    echo -e "install ${GRN}$1 $2${NOC}"
}

# =============================================================================
function _get_time() {
    date "+%Y-%m-%d %H:%M:%S%z"
}

# =============================================================================
function _get_time_short() {
    date "+%Y%m%d-%H%M%S"
}
# =============================================================================
function _get_date() {
    date "+%Y-%m%d"
}

# =============================================================================
function _pushd_quiet() { # directory
    pushd $1 &>/dev/null
}

# =============================================================================
function _popd_quiet() {
    popd &>/dev/null
}

# =============================================================================
function _show() {
    printf >&2 "run:"
    local arg
    for arg in "$@"; do
        arg="${arg%\'/\'\\\'\'}"
        printf >&2 " $GRN'%s'$NOC" "$arg"
    done
    printf >&2 "\n"
}

# =============================================================================
function _show_and_run() {
    _show "$@"
    "$@"
}

# =============================================================================
function _tic_toc_run() {
    start_time=$(date +%s)
    _show_and_run "$@"
    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))
    echo -e "run time: $elapsed_time seconds"
}

# =============================================================================
# use the first argument as the log file name
function _log_show_run() {
    local log_file="$1"
    shift 1
    run_time=$(_get_time)
    printf >&2 "[${run_time}] "
    _show "$@"
    printf "[${run_time}] run:" >>$log_file
    for arg in "$@"; do
        arg="${arg%\'/\'\\\'\'}"
        printf >>$log_file " '%s'" "$arg"
    done
    printf >>$log_file "\n"
    "$@"
}

# =============================================================================
# to measure the time of running some commands
function tic-toc() {
    start_time=$(get-time-us)
    _show_and_run "$@"
    end_time=$(get-time-us)
    elapsed_time=$((end_time - start_time))
    printf "run time: $elapsed_time us"
    seconds=$((elapsed_time / 1000000))
    us=$((elapsed_time - seconds * 1000000))
    # the length is 1 char more
    len=$(echo $us | wc -c)
    # must add leading zeros
    leading_zeros=$((7 - len))
    printf " (${seconds}."
    if [ $leading_zeros -gt 1 ]; then
        for i in {1..${leading_zeros}}; do
            printf "0"
        done
    fi
    echo "$us s)"
}

# =============================================================================
# write text $1 into file $2, if $1 does not exits in $2
write_in_file() {
    if ! grep -Fxq "$1" "$2"; then
        echo "$1" >>"$2"
    fi
}
