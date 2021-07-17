#!/bin/bash

# =============================================================================
function _dj_setup_clang_format() {
    cur_dir=${PWD}

    _install_if_not_installed clang-format

    cd $djtools_path

    echo -e "\nDo you want to apply the default vscode settings? [Yes/No]\n"
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

    echo -e "\nInstall LLVM clang (clang+llvm) on Ubuntu $(version check ubuntu)\n"

    _press_enter_or_wait_s_continue 5

    # how to choose a version?

    if [[ ${ubuntu_v} = *'16.04'* ]]; then
        echo "todo"
        return
    elif [[ ${ubuntu_v} = *'18.04'* ]]; then
        echo "todo"
        return
    elif [[ ${ubuntu_v} = *'20.04'* ]]; then
        repo="clang-llvm-12.0.0-x86-64-ubuntu-2004"
        folder_unpacked="clang+llvm-12.0.0-x86_64-linux-gnu-ubuntu-20.04"
    fi

    # just move all things to dj-zhou github
    # use command:
    #    split -b 10M file.tar.xz file.tar.xz
    # to get file.tar.xzaa, file.tar.xzab, etc, and then push into github repo
    url=https://github.com/dj-zhou/${repo}.git
    cd ~ && mkdir -p soft/ && cd soft/
    rm $repo -rf
    git clone $url
    cd $repo
    cat clang-llvm* >$repo.tar.xz

    echo "untar the clang file ..."
    tar xf ${repo}.tar.xz
    sudo rm -rf /opt/clang-llvm-12.0.0/

    echo "copy the clang files into /opt/ ..."
    sudo mv ${folder_unpacked}/ clang-llvm-12.0.0/
    sudo mv clang-llvm-12.0.0/ /opt/

    mkdir -p ~/.config/Code/User

    echo -e "\nDo you want to apply the default vscode settings? [Yes/No]"
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
