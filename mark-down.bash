#!/bin/bash 

# =============================================================================================
function _mark-down_help()
{
    echo -e "\n-------------------- mark-down -----------------------"
    echo " Author      : Dingjiang Zhou"
    echo " Email       : zhoudingjiang@gmail.com "
    echo " Create Date : June 8th, 2020 "
    echo -e "-----------------------------------------------------\n"
    echo " TODO\n"
}

# =============================================================================================
function _mark_down_help_insert_figure()
{
    echo -e '\n <img src="./figures/sample-figure.png" width="500px"> \n'
}

# =============================================================================================
function _mark_down_help_insert_table()
{
    echo ' '
    echo '|              |               |          | '
    echo '| :----------: | :-----------: | :------: | '
    echo '|              |               |          | '
    echo ' '
}

# =============================================================================================
function _mark_down_help_color_text()
{
    echo -e '\n  <span style="color:blue">this content is blue.</span>'
    echo -e '  <span style="color:red">this content is red.</span>\n'
    echo -e '   available colors:\n     blue, red, green, cyan, yellow, purple, white, etc.'
}

# =============================================================================================
function _mark_down_help_table_of_content()
{
    echo -e "\n {:toc}\n"
}

# =============================================================================================
function mark-down()
{
    current_folder=${PWD}

    # ------------------------------
    if [ $# -eq 0 ] ; then
        _mark-down_help
        return
    fi

    # ------------------------------
    if [ $1 = 'help' ] ; then
        if [ $2 = 'insert-figure' ] ; then
            _mark_down_help_insert_figure
            return
        fi
        if [ $2 = 'insert-table' ] ; then
            _mark_down_help_insert_table
            return
        fi
        if [ $2 = 'color-text' ] ; then
            _mark_down_help_color_text
            return
        fi
        if [ $2 = 'table-of-content' ] ; then
            _mark_down_help_table_of_content
            return
        fi
        return
    fi

    echo -e '\nrepo : "'$1 '"command not supported\n'
    _mark-down_help

    # ------------------------------
    cd $current_folder
    unset current_folder
}

# =============================================================================================
function _mark-down()
{
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        help
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ---------------------------------------------------------------------------------
    ACTIONS[help]+="insert-figure insert-table color-text table-of-content "
    ACTIONS[insert-figure]=" "
    ACTIONS[insert-table]=" "
    ACTIONS[color-text]=" "
    ACTIONS[table-of-content]=" "
    
    # ---------------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================================
complete -F _mark-down mark-down
