#!/bin/bash

# =============================================================================
function _coding_help()
{
    echo -e '\n coding help\n'
    echo ' exmaple command 1:'
    echo ' code replace <original> <new> .'
    echo '     - to replace the text content of <original> to <new> in the current folder '
    echo -e '\n exmaple command 2:'
    echo ' code replace <original> <new> <path to file>'
    echo '     - to replace the text content of <original> to <new> in the file <path to file> '
    echo -e '\n'
}

# =============================================================================
function _coding_clang_format_implement()
{
    if [ ! -n $1 ] ; then
        echo "wrong usage"
        return
    fi
    if [ $1 = 'djz' ] ; then
        echo ".clang-format in djz style"
        cp $djtools_path/settings/.clang-format-dj .clang-format
        return
    fi
    if [ $1 = 'bg' ] ; then
        echo ".clang-format in bg style"
        cp $djtools_path/settings/.clang-format-bg .clang-format
        return
    fi
}

# =============================================================================
function _coding_clang_format_show_camel()
{
    cat << eom

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
function _dj_replace()
{
    cwd_before_running=$PWD
    
    if [ $# = 3 ] ; then
        if [ $3 = '.' ] ; then
            # find . -name "*.c", how to rule out .git folder?
            find . -type f -not -path "./.git*" -print0 | xargs -0 sed -i "s/"$1"/"$2"/g"
        elif [[ -f $3 ]] ; then
            echo $3" is a file "
            sed -i "s/"$1"/"$2"/g" $3
            return
        else
            echo -e "\n ${PRP}coding${NOC}: not supported!"
            return
        fi
    fi

    cd ${cwd_before_running}
}

# =============================================================================
# bug: it only works for files in current directory, not in the sub-directory
function dj_clang_format_brush()
{
    format_style=$1
    echo $format_style
    if [ $format_style = 'file' ] ; then
        find . \
        -name *.h -o -iname *.hpp -o -iname *.cpp -o -iname *.c \
        | xargs clang-format -style=file -i
    elif [ $format_style = 'google' ] ; then
        find . \
        -name *.h -o -iname *.hpp -o -iname *.cpp -o -iname *.c \
        | xargs clang-format -style=google -i
    fi
}

# =============================================================================
function _dj_format()
{
    if [ $1 = 'brush' ] ; then
        dj_clang_format_brush $2 $3 $4 $5
        return
    fi
    if [ $1 = 'implement' ] ; then
        _coding_clang_format_implement $2 $3 $4 $5 $6 $7
        return
    fi
    if [ $1 = 'show' ] ; then
        if [ $2 = 'camel' ] ; then
            _coding_clang_format_show_camel $3 $4 $5 $6 $7
            return
        fi
        return
    fi
    if [ $1 = 'enable' ] ; then
        _clang_vscode_setting_json_format_on_save "true"
        return
    fi
    if [ $1 = 'disable' ] ; then
        _clang_vscode_setting_json_format_on_save "false"
        return
    fi
    
    cd ${cwd_before_running}
}
