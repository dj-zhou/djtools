#!/bin/bash 

# ===========================================================================================
_keyremap_help() {
    echo " "
    echo "keyremap usage: " 
    echo " "
    echo "    keyremap enable "
    echo "       -- swap Alt and Ctrl keys" 
    echo "    keyremap disable " 
    echo "       -- set Alt and Ctrl keys to default" 
    echo " "
}

# ===========================================================================================
_keyremap_enable() {
    xmodmap $djtools_path/keyremap-enable.txt
    echo " "
    echo "keyremap enabled"
    echo " "
}

# ===========================================================================================
_keyremap_disable() {
    xmodmap $djtools_path/keyremap-disable.txt
    echo " "
    echo "keyremap disabled"
    echo " "
}

# ===========================================================================================
function keyremap {
    if [ $# -eq 0 ] ; then
        _keyremap_enable
    else 
        if [ ${1} = 'enable' ] ; then
            _keyremap_enable
        elif [ ${1} = 'disable' ] ; then
            _keyremap_disable
        elif [ ${1} = 'help' ] ; then
            _keyremap_help
        else
            echo " "
            echo 'keyremap: argument not supported.'
            echo " "
        fi
    fi
}

# ===========================================================================================
# auto completion reference:
# https://blog.bouzekri.net/2017-01-28-custom-bash-autocomplete-script.html
_keyremap() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=(
        "enable"
          "disable"
      "help"
    )

    # declare an associative array for options
    declare -A ACTIONS
    # -------------------------------------------------------------------------
    # -------------------------------------------------------------------------
    ACTIONS[enable]=" " # must have a space in " " 
    ACTIONS[disable]=" " # must have a space in " " 
    ACTIONS[help]=" " # must have a space in " " 

    # -------------------------------------------------------------------------
    # -------------------------------------------------------------------------

    # All possible options at the end of the line
    #   local OPTIONS=("-d" "-q")

    # current word being autocompleted
    local cur=${COMP_WORDS[COMP_CWORD]}

    # If previous arg is -v it means that we remove -v from SERVICES for autocompletion
    #   if [ $3 = "-v" ] ; then
    #     SERVICES=${SERVICES[@]:1}
    #   fi

    # If previous arg is a key of ACTIONS (so it is a service).
    # It means that we must display action choices
    if [ ${ACTIONS[$3]+1} ] ; then
        COMPREPLY=( `compgen -W "${ACTIONS[$3]}" -- $cur` )
        # If previous arg is one of the actions or previous arg is an option
        # We are at the end of the command and only options are available
        #   elif [[ "${ACTIONS[*]}" == *"$3"* ]] || [[ "${OPTIONS[*]}" == *"$3"*  ]]; then
        #     # SPecial use case : help does not support options
        #     if [ "$3" != "help" ] ; then
        #       COMPREPLY=( `compgen -W "${OPTIONS[*]}" -- $cur` )
        #     fi
    else
        # if everything else does not match, we are either :
        # - first arg waiting for -v or a service code
        # - second arg with first being -v. waiting for a service code.
        COMPREPLY=( `compgen -W "${SERVICES[*]}" -- $cur` )
    fi
}

complete -F _keyremap keyremap
