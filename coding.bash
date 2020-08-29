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
    if [ $1 = 'dj' ] ; then
        echo "copy .clang-format-dj to current folder"
        cp $djtools_path/settings/.clang-format-dj .clang-format
        return
    fi
    if [ $1 = 'bg' ] ; then
        echo "copy .clang-format-bg to current folder"
        cp $djtools_path/settings/.clang-format-bg .clang-format
        return
    fi
}

# =============================================================================
function _coding_clang_format_show()
{
    cat << EOM

                  clang format naming conventions
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

If you want to use Hungarian notation, refer to this page:
    http://web.mst.edu/~cpp/common/hungarian.html

  However, this is not encouraged
EOM
}

# =============================================================================
function coding()
{
    cwd_before_running=$PWD
    
    if [ $# = 0 ] ; then
        _coding_help
    elif [ $1 = 'help' ] ; then
        _coding_help
    elif [ $1 = 'replace' ] && [ $# = 4 ] ; then
        if [ $4 = '.' ] ; then
            # find . -name "*.c", how to rule out .git folder?
            find . -type f -not -path "./.git*" -print0 | xargs -0 sed -i "s/"$2"/"$3"/g"
        elif [[ -f $4 ]] ; then
            echo $4" is a file "
            sed -i "s/"$2"/"$3"/g" $4
        else
            echo -e "\n ${PRP}coding${NOC}: not supported!"
        fi
    elif [ $1 = 'clang-format' ] ; then
        if [ $# = 1 ] ; then
            _coding_help
            return
        fi
        if [ $2 = 'implement' ] ; then
            _coding_clang_format_implement $3 $4 $5 $6 $7
            return
        fi
        if [ $2 = 'show' ] ; then
            _coding_clang_format_show $3 $4 $5 $6 $7
            return
        fi
        if [ $2 = 'enable' ] ; then
            _clang_vscode_setting_json_format_on_save "true"
            return
        fi
        if [ $2 = 'disable' ] ; then
            _clang_vscode_setting_json_format_on_save "false"
            return
        fi
        _coding_help
        return
    else
        _coding_help
    fi
    
    cd ${cwd_before_running}
}

# =============================================================================
function _coding()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        help
        replace
        clang-format
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # no space in front or after "="
    ACTIONS[replace]+="help "
    ACTIONS[help]+=" "
    ACTIONS[clang-format]+="implement show enable disable "
    format_style+="dj bg "
    ACTIONS[implement]+="$format_style "
    for i in $format_style ; do
        ACTIONS[$i]=" "
    done
    ACTIONS[show]+=" "
    ACTIONS[enable]+=" "
    ACTIONS[disable]+=" "
    
    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================
complete -F _coding coding
