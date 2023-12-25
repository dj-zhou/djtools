#!/bin/bash

function echo_info() { echo -e "${CYN}$@${NOC}" 1>&2; }
function echo_cmd() { echo -e "$ ${INFO}$@${NOC}" 1>&2; }
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
    if [ $system = 'Linux' ]; then
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
    elif [ $system = 'Darwin' ]; then
        while ((second > 0)); do
            if ((second == 1)); then
                echo -ne "\rPress [ENTER] or wait $second second to continue ...    "
            else
                echo -ne "\rPress [ENTER] or wait $second seconds to continue ...   "
            fi

            # I cannot make the same action as in Linux
            sleep 1
            second=$((second - 1))
        done
    fi
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
function _size_human_readable() {
    size=$1
    units=("bytes" "KiB" "MiB" "GiB" "TiB")

    unit_index=0
    while ((size >= 1024 && unit_index < ${#units[@]})); do
        size=$((size / 1024))
        ((unit_index++))
    done
    highest_index=$unit_index

    round_size=$size
    base=1
    while ((unit_index > 0)); do
        round_size=$((round_size * 1024))
        base=$((base * 1024))
        ((unit_index--))
    done
    remain=$((($1 - $round_size) * 100))
    percent=$(($remain / $base))
    echo "${size}.${percent} ${units[highest_index]}"
}

# =============================================================================
function _wget_if_not_exist() { # $filename $md5sum $url $option
    filename=$1
    checksum_passed_in=$2
    url=$3
    option=$4
    local md5_checksum=""
    if [[ -f "$filename" ]]; then
        md5_checksum=$(md5sum "$filename")
    else
        md5_checksum=" "
    fi
    local sha256_checksum=""
    if [[ -f "$filename" ]]; then
        sha256_checksum=$(sha256sum "$filename")
    else
        sha256_checksum=" "
    fi
    need_to_download=1
    if [[ "$md5_checksum" = *"$checksum_passed_in"* ]]; then
        echo "file exists, md5 checksum matches, no need to download again"
        need_to_download=0
    fi
    if [[ "$sha256_checksum" = *"$checksum_passed_in"* ]]; then
        echo "file exists, sha256 checksum matches, no need to download again"
        need_to_download=0
    fi
    # finally, download it if necessary
    if [[ "$need_to_download" = "1" ]]; then
        wget $option $filename "${url}"
    fi
}

# =============================================================================
# https://stackoverflow.com/questions/1298066/check-if-an-apt-get-package-is-installed-and-then-install-it-if-its-not-on-linu
function _check_if_package_installed() {
    if [ $system = 'Linux' ]; then
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1 2>/dev/null | grep "install ok installed")
        if [ "" = "$PKG_OK" ]; then
            echo "no"
        else
            echo "yes"
        fi
    elif [ $system = 'Darwin' ]; then
        find_package=$(brew list | grep $1)
        if [ -z "$find_package" ]; then
            echo "no"
        else
            echo "yes"
        fi
    fi
}

# =============================================================================
# should find a better way to install
function _install_if_not_installed() {
    for package in "$@"; do
        if [[ "no" = $(_check_if_package_installed $package) ]]; then
            echo -e "${CYN}installing${NOC} $package"
            # bug: /var/lib/dpkg/lock-frontend, etc, errors will not be seen
            if [ $system = 'Linux' ]; then
                sudo apt-get install -y $package &>/dev/null
            elif [ $system = 'Darwin' ]; then
                brew install $package
            fi
        else
            echo -e "$package ${CYN}is already installed${NOC}"
        fi
    done
}

# =============================================================================
if [[ $system = 'Darwin' ]]; then
    # should find a better way to install
    function _cask_install_if_not_installed() {
        for package in "$@"; do
            if [[ "no" = $(_check_if_package_installed $package) ]]; then
                echo -e "${CYN}installing${NOC} $package"
                brew install --cask $package
            else
                echo -e "$package ${CYN}is already installed${NOC}"
            fi
        done
    }
fi

# =============================================================================
function _verify_lib_installation() {
    dir="${2%/}"
    if [[ $dir == "/usr/bin" || $dir == "/usr/sbin" ]]; then
        str="executable"
    else
        str="   library"
    fi
    if [ ! -f "$dir/$1" ]; then
        echo_error "library $1 is not found in $dir"
    else
        echo -e "  $str file: ${INFO}$dir/$1${NOC}"
    fi
}

# =============================================================================
function _verify_header_files() {
    dir="${2%/}"
    if [ $# != 2 ]; then
        echo "usage: _verify_header_files [header file] [path]"
        return
    fi
    if [ ! -f "$dir/$1" ]; then
        echo_error "header file $1 is not found in $dir"
    else
        echo -e "      header file: ${INFO}$dir/$1${NOC}"
    fi
    return
}

# =============================================================================
function _verify_cmake_files() {
    dir="${2%/}"
    if [ ! -f "$dir/$1" ]; then
        echo_error "cmake file $1 is not found in $dir"
    else
        echo -e "       cmake file: ${INFO}$dir/$1${NOC}"
    fi
}

# =============================================================================
function _verify_pkgconfig_file() {
    dir="${2%/}"
    if [ ! -f "$dir/$1" ]; then
        echo_error "pkgconfig file $1 is not found in $dir"
    else
        echo -e "   pkgconfig file: ${INFO}$dir/$1${NOC}"
    fi
}

# =============================================================================
# find package version from the file .package-version
function _find_package_version() {
    file="$djtools_path/.package-version"
    package=$1
    if [ -z "$package" ]; then
        echo >&2 -e "${RED}error: package empty${NOC}"
        return
    fi
    version=""
    while IFS='' read -r line || [[ -n "$line" ]]; do
        if [[ $line == "$package"* ]]; then
            # on Mac OS, ubuntu_v is not set
            if [ -z "${ubuntu_v}" ]; then
                version=$(echo $line | awk '{ print $2 }')
                echo $version
                return
            fi
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
            elif [[ ${ubuntu_v} == *'22.04'* && $line == *'2204'* ]]; then
                pos1=$(_find_substr_index_in_str "$line" "2204")
                pos2=$(_find_ch_index_in_str_start_from "$line" " " $((pos1 + 4)))
                echo ${line:$((pos1 + 5)):$((pos2 - pos1 - 5))}
                return
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
    echo -e "install ${INFO}$1 $2${NOC}"
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
# error: what is the get-time-us command here?
# t his function does not work!
# function tic_toc() {
#     start_time=$(get-time-us)
#     _show_and_run "$@"
#     end_time=$(get-time-us)
#     elapsed_time=$((end_time - start_time))
#     printf "run time: $elapsed_time us"
#     seconds=$((elapsed_time / 1000000))
#     us=$((elapsed_time - seconds * 1000000))
#     # the length is 1 char more
#     len=$(echo $us | wc -c)
#     # must add leading zeros
#     leading_zeros=$((7 - len))
#     printf " (${seconds}."
#     if [ $leading_zeros -gt 1 ]; then
#         for i in {1..${leading_zeros}}; do
#             printf "0"
#         done
#     fi
#     echo "$us s)"
# }

# =============================================================================
# write text $1 into file $2, if $1 does not exits in $2
write_in_file() {
    if ! grep -Fxq "$1" "$2"; then
        echo "$1" >>"$2"
    fi
}
