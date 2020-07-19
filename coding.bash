#!/bin/bash 

# =============================================================================
function _coding_help()
{
    echo ' '
    echo ' coding help'
    echo ' '
    echo ' exmaple command 1:'
    echo ' code replace <original> <new> .'
    echo '     - to replace the text content of <original> to <new> in the current folder '
    echo ' '
    echo ' exmaple command 2:'
    echo ' code replace <original> <new> <path to file>'
    echo '     - to replace the text content of <original> to <new> in the file <path to file> '
    echo ' '
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
        cp $djtools_path/.clang-format-dj .clang-format
        return
    fi
    if [ $1 = 'bg' ] ; then
        echo "copy .clang-format-bg to current folder"
        cp $djtools_path/.clang-format-bg .clang-format
        return
    fi
}

# =============================================================================
function _coding_clang_format_show()
{
    echo -e '\n               clang format naming conventions'
    echo " +-----------------------------------------------------------+"
    echo " |          Code Element | Stype                             |"
    echo " +-----------------------------------------------------------+"
    echo " |             Namespace | under_scored                      |"
    echo " |            Class name | CamelCase                         |"
    echo " |         Function name | camelCase                         |"
    echo " |     Parameters/Locals | under_scored                      |"
    echo " |      Member Variables | under_socred_with_                |"
    echo " | Enums and its mumbers | CamelCase                         |"
    echo " |               Globals | g_under_scored                    |"
    echo " |             Constants | UPPER_CASE                        |"
    echo " |            File names | Match the case of the class name  |"
    echo " +-----------------------------------------------------------+"
    echo -e "\n"
    echo -e "If you want to use Hungarian notation, refer to this page:\n"
    echo -e "  http://web.mst.edu/~cpp/common/hungarian.html\n"
    echo -e "However, this is not encouraged\n"
}

# =============================================================================
function coding()
{
    cwd_before_running=$PWD
    
    if [ $# = 0 ] ; then
        _coding_help
    elif [ $1 = '-help' ] ; then
        _coding_help
    elif [ $1 = 'replace' ] && [ $# = 4 ] ; then
        if [ $4 = '.' ] ; then
            # find . -name "*.c", how to rule out .git folder?
            find . -type f -not -path "./.git*" -print0 | xargs -0 sed -i "s/"$2"/"$3"/g"
        elif [[ -f $4 ]] ; then
            echo $4" is a file "
            sed -i "s/"$2"/"$3"/g" $4
        else
            echo " coding: not supported!"
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
        -help
        replace
        clang-format
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # no space in front or after "="
    ACTIONS[replace]+="-help "
    ACTIONS[-help]+=" "
    ACTIONS[clang-format]+="implement show "
    ACTIONS[implement]+="dj bg "
    ACTIONS[dj]+=" "
    ACTIONS[bg]+=" "
    ACTIONS[show]+=" "

    
    # ---------------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================
complete -F _coding coding
