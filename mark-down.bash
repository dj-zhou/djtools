#!/bin/bash

# =============================================================================
function _mark-down_help() {
    echo -e "\n -------------------- mark-down -----------------------"
    echo "  Author      : Dingjiang Zhou"
    echo "  Email       : zhoudingjiang@gmail.com "
    echo "  Create Date : June 8th, 2020 "
    echo -e " -----------------------------------------------------\n"
    echo -e " TODO\n"
}

# =============================================================================
function _mark_down_help_insert_figure() {
    echo -e "\n method 1: "
    echo -e '  <img src="./figures/sample-figure.png" width="500px">'
    echo -e "\n method 2:"
    echo -e "  ![image description](https://image-link.jpg)\n"
}

# =============================================================================
function _mark_down_help_insert_table() {
    echo -e "\n"
    echo '|              |               |          | '
    echo '| :----------: | :-----------: | :------: | '
    echo '|              |               |          | '
    echo -e "\n"
}

# =============================================================================
function _mark_down_help_color_text() {
    echo -e '\n  <span style="color:blue">this content is blue.</span>'
    echo -e '  <span style="color:red">this content is red.</span>\n'
    echo -e '   available colors:\n     blue, red, green, cyan, yellow, purple, white, etc.'
}

# =============================================================================
function _mark_down_help_table_of_content() {
    echo -e "\n {:toc}\n"
}

# =============================================================================
function mark-down() {
    _pushd_quiet ${PWD}

    # ------------------------------
    if [ $# -eq 0 ]; then
        _mark-down_help
        return
    fi

    # ------------------------------
    if [ $1 = 'help' ]; then
        if [ $2 = 'insert-figure' ]; then
            _mark_down_help_insert_figure
            return
        fi
        if [ $2 = 'insert-table' ]; then
            _mark_down_help_insert_table
            return
        fi
        if [ $2 = 'color-text' ]; then
            _mark_down_help_color_text
            return
        fi
        if [ $2 = 'table-of-content' ]; then
            _mark_down_help_table_of_content
            return
        fi
        return
    fi

    echo -e 'mark-down: "'$1 '"command not supported'
    _mark-down_help

    _popd_quiet
}

# =============================================================================
function _mark-down_linux() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        help
    ")

    # declare an associative array for options
    declare -A ACTIONS

    # ------------------------------------------------------------------------
    ACTIONS[help]+="insert-figure insert-table color-text table-of-content "
    ACTIONS["insert-figure"]=" "
    ACTIONS["insert-table"]=" "
    ACTIONS["color-text"]=" "
    ACTIONS["table-of-content"]=" "

    # ------------------------------------------------------------------------
    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ]; then
        COMPREPLY=($(compgen -W "${ACTIONS[$3]}" -- $cur))
    else
        COMPREPLY=($(compgen -W "${SERVICES[*]}" -- $cur))
    fi
}

# =============================================================================
if [ $system = 'Linux' ]; then
    complete -F _mark-down_linux mark-down
# elif [ $system = 'Darwin' ]; then
#     echo "todo"
fi