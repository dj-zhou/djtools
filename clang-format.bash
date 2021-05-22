#!/bin/bash

# =============================================================================
function _clang_write_to_file_part1() {
    file=$1
    echo '{' >>${file}
    echo '    "files.hotExit": "onExit",' >>${file}
    echo '    "editor.tabSize": 4,' >>${file}
    echo '    "workbench.editor.enablePreview": false,' >>${file}
    echo '    "C_Cpp.updateChannel": "Insiders",' >>${file}
    echo '    "C_Cpp.default.cppStandard": "c++17",' >>${file}
    echo '    "editor.detectIndentation": false,' >>${file}
    echo '    "files.autoSave": "afterDelay",' >>${file}
    echo '    "workbench.iconTheme": "vscode-icons",' >>${file}
    echo '    "editor.fontSize": 16,' >>${file}
    echo '    "cSpell.enabledLanguageIds": [' >>${file}
    echo '        "asciidoc",' >>${file}
    echo '        "c",' >>${file}
    echo '        "cpp",' >>${file}
    echo '        "csharp",' >>${file}
    echo '        "css",' >>${file}
    echo '        "git-commit",' >>${file}
    echo '        "go",' >>${file}
    echo '        "handlebars",' >>${file}
    echo '        "haskell",' >>${file}
    echo '        "html",' >>${file}
    echo '        "jade",' >>${file}
    echo '        "java",' >>${file}
    echo '        "javascript",' >>${file}
    echo '        "javascriptreact",' >>${file}
    echo '        "json",' >>${file}
    echo '        "jsonc",' >>${file}
    echo '        "less",' >>${file}
    echo '        "markdown",' >>${file}
    echo '        "php",' >>${file}
    echo '        "plaintext",' >>${file}
    echo '        "pug",' >>${file}
    echo '        "python",' >>${file}
    echo '        "restructuredtext",' >>${file}
    echo '        "rust",' >>${file}
    echo '        "scala",' >>${file}
    echo '        "scss",' >>${file}
    echo '        "text",' >>${file}
    echo '        "typescript",' >>${file}
    echo '        "typescriptreact",' >>${file}
    echo '        "yaml",' >>${file}
    echo '        "yml"' >>${file}
    echo '    ],' >>${file}
    echo '    "[cpp]": {' >>${file}
    echo '        "editor.defaultFormatter": "ms-vscode.cpptools"' >>${file}
    echo '    },' >>${file}
    echo '    "Clang_format_style": "file",' >>${file}
    echo '    "clang-format.assumeFilename": "~/.config/Code/User/.clang-format",' >>${file}
}

# =============================================================================
function _clang_write_to_file_part2_clang_version_clang_format() {
    file=$1
    clang_file_path="/usr/bin"

    string1="\"C_Cpp.clang_format_path\": \"${clang_file_path}/clang-format\""
    echo "    $string1," >>${file}
}

# =============================================================================
# the version here is hard-coded! stupid
function _clang_write_to_file_part2_clang_version_clang_llvm() {
    file=$1
    if [[ ${ubuntu_v} = *'16.04'* ]]; then
        clang_file_path="/opt/clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04/bin"
    fi
    if [[ ${ubuntu_v} = *'18.04'* ]]; then
        clang_file_path="/opt/clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04/bin"
    fi
    if [[ ${ubuntu_v} = *'20.04'* ]]; then
        clang_file_path="/opt/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04/bin"
    fi
    string1="\"C_Cpp.clang_format_path\": \"${clang_file_path}/clang-format\""
    string2="\"clang.executable\": \"${clang_file_path}/clang\""
    # echo "$string1"
    # echo "$string2"
    echo "    $string1," >>${file}
    echo "    $string2," >>${file}
}

# =============================================================================
function _clang_write_to_file_part3_format_on_save() {
    file=$1
    save_or_not=$2
    if [ $save_or_not = 'true' ]; then
        echo '    "editor.formatOnSave": true,' >>${file}
    elif [ $save_or_not = 'false' ]; then
        echo '    "editor.formatOnSave": false,' >>${file}
    fi
}

# =============================================================================
function _clang_write_to_file_partN() {
    file=$1
    echo '}' >>${file}
}

# =============================================================================
function _clang_format_vscode_setting_json() {
    format_on_save=$1
    cur_dir_json=${PWD}

    folder="/home/$USER/.config/Code/User"
    mkdir -p $folder

    target_file=$folder/settings.json
    sudo rm -f $target_file
    _clang_write_to_file_part1 $target_file
    _clang_write_to_file_part2_clang_version_clang_format $target_file
    _clang_write_to_file_part3_format_on_save $target_file "$format_on_save"
    _clang_write_to_file_partN $target_file

    echo -e "\n the default settings is in $folder/settings.json\n"
    echo -e " you can revise it manually"
    cd $cur_dir_json
}

# =============================================================================
function _clang_llvm_vscode_setting_json() {
    format_on_save=$1
    cur_dir_json=${PWD}

    folder="/home/$USER/.config/Code/User"
    mkdir -p $folder

    target_file=$folder/settings.json
    sudo rm -f $target_file
    _clang_write_to_file_part1 $target_file
    _clang_write_to_file_part2_clang_version_clang_llvm $target_file
    _clang_write_to_file_part3_format_on_save $target_file "$format_on_save"
    _clang_write_to_file_partN $target_file

    echo -e "\n the default settings is in $folder/settings.json\n"
    echo -e " you can revise it manually"
    cd $cur_dir_json
}

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
        _clang_format_vscode_setting_json "true"
    else
        echo "wrong answer, not setting applied!"
        echo "You can edit ~/.config/Code/User/settings.json manually."
    fi

    echo -e "\n"

    cd $cur_dir
}

# =============================================================================
# LLVM clang 11.1.0 cannot work on Ubuntu 18.04, it needs libtinfo.so.6

# Ubuntu 16.04: xx (try 10.0.1)
# Ubuntu 18.04: 10.0.1
# Ubuntu 20.04: xx (todo)

# todo: https://github.com/llvm/llvm-project/releases/tag/llvmorg-12.0.0
function _dj_setup_clang_llvm() {
    cur_dir=${PWD}

    echo -e "\nInstall LLVM clang (clang+llvm) on Ubuntu $(version check ubuntu)\n"

    _press_enter_or_wait_s_continue 5

    cd ~ && mkdir -p soft/ && cd soft/

    # how to choose a version?

    if [[ ${ubuntu_v} = *'16.04'* ]]; then
        repo="clang-llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04" # not tested!
        file="clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04" # - to +
        clang_v="10.0.1"
    elif [[ ${ubuntu_v} = *'18.04'* ]]; then
        repo="clang-llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04"
        file="clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04" # - to +
        clang_v="10.0.1"
    elif [[ ${ubuntu_v} = *'20.04'* ]]; then
        repo="clang-llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04" # to fix
        file="clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04"
    fi

    # just move all things to dj-zhou github
    # use command:
    #    split -b 10M file.tar.xz file.tar.xz
    # to get file.tar.xzaa, file.tar.xzab, etc, and then push into github repo
    url=https://github.com/dj-zhou/${repo}

    echo "url = $url"
    if [[ ${ubuntu_v} = *'16.04'* ]]; then
        echo "todo"
    elif [[ ${ubuntu_v} = *'18.04'* ]]; then
        rm -rf $repo
        git clone $url
        cd $repo
        cat $file.tar.xz* >$file.tar.xz
    elif [[ ${ubuntu_v} = *'20.04'* ]]; then
        git clone $url
        cd $repo
        cat $file.tar.xz* >$file.tar.xz
    fi

    echo "untar the clang file ..."
    tar xf ${file}.tar.xz
    sudo rm -rf /opt/clang+llvm*

    echo "copy the clang file into /opt/ ..."
    sudo mv ${file}/ /opt/

    mkdir -p ~/.config/Code/User

    cd $djtools_path

    echo -e "\nDo you want to apply the default vscode settings? [Yes/No]\n"
    read asw

    if [[ ($asw = 'n') || ($asw = 'N') || ($asw = 'NO') || (\
        $asw = 'No') || ($asw = 'no') ]]; then
        echo "You can edit ~/.config/Code/User/settings.json manually."
    elif [[ ($asw = 'y') || ($asw = 'Y') || ($asw = 'YES') || (\
        $asw = 'Yes') || ($asw = 'yes') ]]; then
        _clang_llvm_vscode_setting_json "true" $clang_v #clang_v is not used, but keep it here
    else
        echo "wrong answer, not setting applied!"
        echo "You can edit ~/.config/Code/User/settings.json manually."
    fi

    echo ' '

    cd $cur_dir
}
