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
    cur_dir=$PWD

    if [ $# = 3 ]; then
        if [ $3 = '.' ]; then
            # find . -name "*.c", how to rule out .git folder?
            find . -type f -not -path "./.git*" -print0 | xargs -0 sed -i "s/"$1"/"$2"/g"
        elif [[ -f $3 ]]; then
            echo $3" is a file "
            sed -i "s/"$1"/"$2"/g" $3
            return
        else
            echo -e "{PRP}dj replace${NOC}: not supported!"
            return
        fi
    fi

    cd ${cur_dir}
}

# =============================================================================
# bug: it only works for files in current directory, not in the sub-directory
function dj_clang_format_brush() {
    format_style=$1
    echo $format_style
    if [ $format_style = 'file' ]; then
        find . \
            -name *.h -o -iname *.hpp -o -iname *.cpp -o -iname *.c |
            xargs clang-format -style=file -i
    elif [ $format_style = 'google' ]; then
        find . \
            -name *.h -o -iname *.hpp -o -iname *.cpp -o -iname *.c |
            xargs clang-format -style=google -i
    fi
}

# =============================================================================
function _dj_format() {
    if [ $1 = 'brush' ]; then
        dj_clang_format_brush $2 $3 $4 $5
        return
    fi
    if [ $1 = 'implement' ]; then
        _dj_format_clang_format_implement $2 $3 $4 $5 $6 $7
        return
    fi
    if [ $1 = 'show' ]; then
        if [ $2 = 'camel' ]; then
            _dj_format_clang_format_show_camel $3 $4 $5 $6 $7
            return
        fi
        return
    fi
    if [ $1 = 'enable' ]; then
        _clang_vscode_setting_json_format_on_save "true"
        return
    fi
    if [ $1 = 'disable' ]; then
        _clang_vscode_setting_json_format_on_save "false"
        return
    fi

    cd ${cur_dir}
}

# =============================================================================
function _dj_setup_clang_format() {
    cur_dir=${PWD}

    _install_if_not_installed clang-format

    cd $djtools_path

    echo -e "Do you want to apply the default vscode settings? [Yes/No]"
    read asw

    if [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') || (\
        $asw = 'No') || ($asw = 'no') ]]; then
        echo "You can edit ~/.config/Code/User/settings.json manually."
    elif [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || (\
        $asw = 'Yes') || ($asw = 'yes') ]]; then
        cp ${djtools_path}/settings/vscode-settings.json ~/.config/Code/User/settings.json
    else
        echo "wrong answer, not setting applied!"
        echo "You can edit ~/.config/Code/User/settings.json manually."
    fi

    cd $cur_dir
}

# =============================================================================
# Ubuntu 16.04: give up
# Ubuntu 18.04: 11.1.0 (tested), https://github.com/llvm/llvm-project/releases/tag/llvmorg-11.1.0
# Ubuntu 20.04: 12.0.0 (tested), https://github.com/llvm/llvm-project/releases/tag/llvmorg-12.0.0

function _dj_setup_clang_llvm() {
    cur_dir=${PWD}

    echo -e "Install LLVM clang (clang+llvm) on Ubuntu $(version check ubuntu)"

    _press_enter_or_wait_s_continue 5

    # how to choose a version?

    if [[ ${ubuntu_v} = *'16.04'* ]]; then
        echo "todo"
        return
    elif [[ ${ubuntu_v} = *'18.04'* ]]; then
        target_dir="clang-llvm-11.1.0"
        repo="$target_dir-x86-64-ubuntu-1604"
        folder_unpacked="clang+llvm-11.1.0-x86_64-linux-gnu-ubuntu-16.04" # this should be correct!
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
    cd ~ && mkdir -p soft/ && cd soft/
    rm $repo -rf
    git clone $url
    cd $repo
    cat clang-llvm* >$repo.tar.xz

    echo "untar the clang file ..."
    tar xf ${repo}.tar.xz
    sudo rm -rf /opt/$target_dir/

    echo "copy the clang files into /opt/$target_dir/ ..."
    sudo mv ${folder_unpacked}/ $target_dir/
    sudo mv $target_dir/ /opt/

    mkdir -p ~/.config/Code/User

    echo -e "Do you want to apply the default vscode settings? [Yes/No]"
    read asw

    if [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') || (\
        $asw = 'No') || ($asw = 'no') ]]; then
        echo "You can edit ~/.config/Code/User/settings.json manually."
    elif [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || (\
        $asw = 'Yes') || ($asw = 'yes') ]]; then
        if [[ ${ubuntu_v} = *'18.04'* ]]; then
            cp ${djtools_path}/settings/vscode-settings-1804.json ~/.config/Code/User/settings.json
        elif [[ ${ubuntu_v} = *'20.04'* ]]; then
            cp ${djtools_path}/settings/vscode-settings-2004.json ~/.config/Code/User/settings.json
        fi
    else
        echo "wrong answer, not setting applied!"
        echo "You can edit ~/.config/Code/User/settings.json manually."
    fi

    cd $cur_dir
}
