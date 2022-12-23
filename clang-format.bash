#!/bin/bash

# =============================================================================
function _dj_format_help() {
    echo -e 'dj format help:'
    echo ' example command 1:'
    echo ' code replace <original> <new> .'
    echo '     - to replace the text content of <original> to <new> in the current folder '
    echo -e 'exmaple command 2:'
    echo ' code replace <original> <new> <path to file>'
    echo '     - to replace the text content of <original> to <new> in the file <path to file> '
}

# =============================================================================
function _dj_format_clang_format_implement() {
    if [ -z $1 ]; then
        echo "need argument, supported: djz, bg"
        return
    fi
    if [ $1 = 'djz' ]; then
        echo ".clang-format in djz style"
        cp $djtools_path/settings/.clang-format-dj .clang-format
        return
    fi
    if [ $1 = 'bg' ]; then
        echo ".clang-format in bg style"
        cp $djtools_path/settings/.clang-format-bg .clang-format
        return
    fi
}

# =============================================================================
function _dj_format_clang_format_show_camel() {
    cat <<eom
                    Camel Case
 +-----------------------------------------------------------+
 |          Code Element | Stype                             |
 +-----------------------------------------------------------+
 |             Namespace | under_scored                      |
 |            Class name | CamelCase                         |
 |         Function name | camelCase                         |
 |     Parameters/Locals | under_scored                      |
 |      Member Variables | under_socred_with_                |
 | Enums and its mumbers | CamelCase                         |
 |               Globals | g_under_scored                    |
 |             Constants | UPPER_CASE                        |
 |            File names | Match the case of the class name  |
 +-----------------------------------------------------------+

eom
}

# =============================================================================
function _dj_replace() {
    _pushd_quiet ${PWD}

    if [ $# = 3 ]; then
        if [ $3 = '.' ]; then
            # find . -name "*.c", how to rule out .git folder?
            find . -type f -not -path "./.git*" -print0 | xargs -0 sed -i "s/"$1"/"$2"/g"
        elif [[ -f $3 ]]; then
            echo $3" is a file "
            sed -i "s/"$1"/"$2"/g" $3
            return
        else
            echo -e "${YLW}dj replace${NOC}: not supported!"
            return
        fi
    fi

    _popd_quiet
}

# =============================================================================
# bug: it only works for files in current directory, not in the sub-directory
function dj_clang_format_brush() {
    format_style=$1
    echo "clang_format_path=$clang_format_path"
    if [[ $format_style = 'file' ]]; then
        type_list="h hpp c cpp hh cc "
        for tt in $type_list; do
            a=$(find . -iname *.$tt)
            if [ ! -z "$a" ]; then
                echo -e "${BLU}format $tt files${NOC}"
                find . -iname *.$tt | xargs $clang_format_path -i
            fi
        done
    elif [[ $format_style = 'google' ]]; then
        find . \
            -name *.h -o -iname *.hpp -o -iname *.cpp -o -iname *.c |
            xargs clang-format -style=google -i
    fi
}

# =============================================================================
function _dj_format() {
    _pushd_quiet ${PWD}

    if [[ $1 = 'brush' ]]; then
        shift 1
        dj_clang_format_brush "$@"
        return
    fi
    if [[ $1 = 'implement' ]]; then
        shift 1
        _dj_format_clang_format_implement "$@"
        return
    fi
    if [[ $1 = 'show' ]]; then
        shift 1
        if [[ $2 = 'camel' ]]; then
            shift 1
            _dj_format_clang_format_show_camel "$@"
            return
        fi
        echo "dj format show: need argument."
        return
    fi

    _popd_quiet
}

# =============================================================================
function _dj_setup_clang_format() {
    _pushd_quiet ${PWD}

    _install_if_not_installed clang-format

    cd $djtools_path

    echo -e "Do you want to apply the default vscode settings? [Yes/No]"
    read asw

    if [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') || (
        $asw = 'No') || ($asw = 'no') ]]; then
        echo "You can edit ~/.config/Code/User/settings.json manually."
    elif [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || (
        $asw = 'Yes') || ($asw = 'yes') ]]; then
        cp ${djtools_path}/settings/vscode-settings.json ~/.config/Code/User/settings.json
    else
        echo "wrong answer, not setting applied!"
        echo "You can edit ~/.config/Code/User/settings.json manually."
    fi

    _popd_quiet
}

# =============================================================================
# Ubuntu 16.04: give up
# Ubuntu 18.04: 11.1.0 (tested), https://github.com/llvm/llvm-project/releases/tag/llvmorg-11.1.0
# Ubuntu 20.04: 12.0.0 (tested), https://github.com/llvm/llvm-project/releases/tag/llvmorg-12.0.0
function _dj_setup_clang_llvm() {
    _show_and_run _pushd_quiet ${PWD}

    echo -e "Install LLVM clang (clang+llvm) on Ubuntu ${GRN}$(version check ubuntu)${NOC}"

    _press_enter_or_wait_s_continue 5

    # how to choose a version?

    if [[ ${ubuntu_v} = *'16.04'* ]]; then
        echo "not supported"
        return
    elif [[ ${ubuntu_v} = *'18.04'* ]]; then
        target_dir="clang-llvm-11.1.0"
        repo="$target_dir-x86-64-ubuntu-1604"
        # this should be correct!
        folder_unpacked="clang+llvm-11.1.0-x86_64-linux-gnu-ubuntu-16.04"
    elif [[ ${ubuntu_v} = *'20.04'* ]]; then
        target_dir="clang-llvm-12.0.0"
        repo="$target_dir-x86-64-ubuntu-2004"
        folder_unpacked="clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04"
    fi

    # just move all things to dj-zhou github
    # use command:
    #    split -b 10M [file].tar.xz clang-llvm.tar.xz
    # to get file.tar.xzaa, file.tar.xzab, etc, and then push into github repo
    url=https://github.com/dj-zhou/${repo}.git
    _show_and_run mkdir -p ~/soft/
    _show_and_run cd ~/soft/
    _show_and_run rm $repo -rf
    _show_and_run git clone $url
    _show_and_run cd $repo
    _show_and_run cat clang-llvm* >$repo.tar.xz

    _show_and_run tar xf ${repo}.tar.xz
    _show_and_run sudo rm -rf /opt/$target_dir/

    _show_and_run sudo mv ${folder_unpacked}/ $target_dir/
    _show_and_run sudo mv $target_dir/ /opt/

    _show_and_run mkdir -p ~/.config/Code/User

    echo -e "Do you want to apply the default vscode settings? [Yes/No]"
    read asw

    if [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') || (
        $asw = 'No') || ($asw = 'no') ]]; then
        echo "You can edit ~/.config/Code/User/settings.json manually."
    elif [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || (
        $asw = 'Yes') || ($asw = 'yes') ]]; then
        if [[ ${ubuntu_v} = *'18.04'* ]]; then
            _show_and_run cp ${djtools_path}/settings/vscode-settings-1804.json ~/.config/Code/User/settings.json
        elif [[ ${ubuntu_v} = *'20.04'* ]]; then
            _show_and_run cp ${djtools_path}/settings/vscode-settings-2004.json ~/.config/Code/User/settings.json
        fi
    else
        echo "wrong answer, not setting applied!"
        echo "You can edit ~/.config/Code/User/settings.json manually."
    fi

    echo '# ===========================================================' >>~/.bashrc
    echo '# (djtools) clang-format LLVM setup' >>~/.bashrc
    echo "clang_format_path=/opt/$target_dir/bin/clang-format" >>~/.bashrc

    _popd_quiet
}
