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
    echo -e "method 1: "
    echo -e '  <img src="./figures/sample-figure.png" width="500px">'
    echo -e "method 2:"
    echo -e "  ![image description](https://image-link.jpg)"
}

# =============================================================================
function _mark_down_help_insert_table() {
    echo '|              |               |          | '
    echo '| :----------: | :-----------: | :------: | '
    echo '|              |               |          | '
}

# =============================================================================
function _mark_down_help_color_text() {
    echo -e '<span style="color:blue">this content is blue.</span>'
    echo -e '<span style="color:red">this content is red.</span>\n'
    echo -e 'available colors:\n     blue, red, green, cyan, yellow, purple, white, etc.'
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

_mark_down_help_list="insert-figure insert-table color-text table-of-content "

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
    ACTIONS[help]+="$_mark_down_help_list "
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
function _mark-down_darwin() {
    # Getting the current word and previous word in the command-line
    local curcontext="$curcontext" state line
    typeset -A opt_args

    # Array of options for the custom command
    custom_options=(
        help
    )
    # ------------
    read -r -A help_options <<<"$_mark_down_help_list"

    # Defining states for the completion
    _arguments -C \
        '1: :->first' \
        '2: :->second' && return 0

    case $state in
    first)
        _wanted fl_options expl 'main option' compadd -a custom_options
        ;;
    second)
        case $words[2] in
        help)
            _wanted help_sl_options expl 'subcommand for help' compadd -a help_options
            ;;
        esac
        ;;
    esac
}

# =============================================================================
if [ $system = 'Linux' ]; then
    complete -F _mark-down_linux mark-down
elif [ $system = 'Darwin' ]; then
    compdef _mark-down_darwin mark-down
fi
