#!/bin/bash

# =============================================================================
_terminal_help() {
    echo -e "\nterminal: supported commands\n"
    echo " "
    echo "     $ terminal host full-path"
    echo "     $ terminal host full-path no-space"
    echo "     $ terminal host short-path"
    echo "     $ terminal host short-path no-space"
    echo "     $ terminal user full/short-path (no-space)"
    echo -e "     $ terminal user@host full/short-path (no-space)\n"
}

# =============================================================================
function _terminal_format_user_host_full_path() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\u@\h\[\033[00m\]: \[\033[01;36m\]\w\[\033[00m\] $ '
}

function _terminal_format_user_host_short_path() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[02;40m\]\u@\h\[\033[00m\]: \[\033[01;36m\]\W\[\033[00m\] $ '
}

function _terminal_format_host_full_path() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\h \[\033[00m\]: \[\033[01;36m\]\w\[\033[00m\] $ '
}

function _terminal_format_host_short_path() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\h \[\033[00m\]: \[\033[01;36m\]\W\[\033[00m\] $ '
}

function _terminal_format_user_full_path() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\u \[\033[00m\]: \[\033[01;36m\]\w\[\033[00m\] $ '
}

function _terminal_format_user_short_path() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\u \[\033[00m\]: \[\033[01;36m\]\W\[\033[00m\] $ '
}
#-------------------------------------------------------------------------------------------
function _terminal_format_user_host_full_path_no_space() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]$ '
}

function _terminal_format_user_host_short_path_no_space() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\W\[\033[00m\]$ '
}

function _terminal_format_host_full_path_no_space() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]$ '
}

function _terminal_format_host_short_path_no_space() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\h\[\033[00m\]:\[\033[01;36m\]\W\[\033[00m\]$ '
}

function _terminal_format_user_full_path_no_space() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\u\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]$ '
}

function _terminal_format_user_short_path_no_space() {
    export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;29m\]\u\[\033[00m\]:\[\033[01;36m\]\W\[\033[00m\]$ '
}

# =============================================================================
function terminal {
    if [ $# -eq 0 ] ; then
        _terminal_help
    else 
        echo -e '\n' >> ~/.bashrc
        echo '# ===========================================================' >> ~/.bashrc
        echo '# terminal format setup (djtools)' >> ~/.bashrc
        if [ ${1} = 'user@host' ] ; then
            if [ $# = 1 ] ; then
                _terminal_format_user_host_short_path
                echo '_terminal_format_user_host_short_path' >> ~/.bashrc
            elif [ $2 = 'full-path' ] ; then
                _terminal_format_user_host_full_path
                echo '_terminal_format_user_host_full_path' >> ~/.bashrc
                if [ $# = 3 ] && [ $3 = 'no-space' ] ; then
                    _terminal_format_user_host_full_path_no_space
                echo '_terminal_format_user_host_full_path_no_space' >> ~/.bashrc
                fi
            elif [ $2 = 'short-path' ] ;then
                _terminal_format_user_host_short_path
                echo '_terminal_format_user_host_short_path' >> ~/.bashrc
                if [ $# = 3 ] && [ $3 = 'no-space' ] ; then
                    _terminal_format_user_host_short_path_no_space
                echo '_terminal_format_user_host_short_path_no_space' >> ~/.bashrc
                fi
            fi
        elif [ ${1} = 'host' ] ; then
            if [ $# = 1 ] ; then
                _terminal_format_host_short_path
                echo '_terminal_format_host_short_path' >> ~/.bashrc
            elif [ $2 = 'full-path' ] ; then 
                _terminal_format_host_full_path
                echo '_terminal_format_host_full_path' >> ~/.bashrc
                if [ $# = 3 ] && [ $3 = 'no-space' ] ; then
                    _terminal_format_host_full_path_no_space
                    echo '_terminal_format_host_full_path_no_space' >> ~/.bashrc
                fi
            elif [ $2 = 'short-path' ] ;then
                _terminal_format_host_short_path
                    echo '_terminal_format_host_short_path' >> ~/.bashrc
                if [ $# = 3 ] && [ $3 = 'no-space' ] ; then
                    _terminal_format_host_short_path_no_space
                    echo '_terminal_format_host_short_path_no_space' >> ~/.bashrc
                fi
            fi
        elif [ ${1} = 'user' ] ; then
            if [ $# = 1 ] ; then
                _terminal_format_user_short_path
                    echo '_terminal_format_user_short_path' >> ~/.bashrc
            elif [ $2 = 'full-path' ] ; then 
                _terminal_format_user_full_path
                if [ $# = 3 ] && [ $3 = 'no-space' ] ; then
                    _terminal_format_user_full_path_no_space
                    echo '_terminal_format_user_full_path_no_space' >> ~/.bashrc
                fi
            elif [ $2 = 'short-path' ] ;then 
                _terminal_format_user_short_path
                    echo '_terminal_format_user_short_path' >> ~/.bashrc
                if [ $# = 3 ] && [ $3 = 'no-space' ] ; then
                    _terminal_format_user_short_path_no_space
                    echo '_terminal_format_user_short_path_no_space' >> ~/.bashrc
                fi
            fi
        else
            echo 'terminal: argument not supported.'
        fi
    fi
}

# =============================================================================
# auto completion reference:
# https://blog.bouzekri.net/2017-01-28-custom-bash-autocomplete-script.html
_terminal() {

    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=(
        "user@host"
        "host"
        "user"
    )

    # declare an associative array for options
    declare -A ACTIONS
    # -------------------------------------------------------------------------
    # -------------------------------------------------------------------------
    ACTIONS[user@host]="full-path short-path " # must have a space in " "
    ACTIONS[host]="full-path short-path " # must have a space in " "
    ACTIONS[user]="full-path short-path " # must have a space in " "

    ACTIONS[full-path]=" " # must have a space in " " 
    ACTIONS[short-path]=" " # must have a space in " " 

    local cur=${COMP_WORDS[COMP_CWORD]}
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
    else
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

# =============================================================================
complete -F _terminal terminal
