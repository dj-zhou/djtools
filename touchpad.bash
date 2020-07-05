#!/bin/bash 

# ===========================================================================================
_touchpad_help() {
    echo -e "\ntouchpad usage:\n"
    echo "    touchpad thinkpad enable "
    echo "       -- enable the touchpad on ThinkPad laptops"
    echo "    touchpad thinkpad disable " 
    echo -e "       -- disable the touchpad on ThinkPad laptops\n"
}

# ===========================================================================================
function _touchpad_thinkpad_control() {
    # xinput list | grep TouchPad
    touchpad=$(xinput list | grep TouchPad | tr -dc '0-9')
    # the number is not a constant number, for example it was 13, and it then 14 at some time
    touchpadID=${touchpad:1:2}
    xinput set-prop $touchpadID "Device Enabled" $1
    # for my new P52 computer, it is "Touchpad" instead of "TouchPad"
    # xinput list | grep Touchpad
    touchpad=$(xinput list | grep Touchpad | tr -dc '0-9')
    # the number is not a constant number, for example it was 13, and it then 14 at some time
    touchpadID=${touchpad:1:2}
    xinput set-prop $touchpadID "Device Enabled" $1
}

# ===========================================================================================
# ⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
# ⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
# ⎜   ↳ ASUSTeK Computer Inc. N-KEY Device Consumer Control	id=14	[slave  pointer  (2)]
# ⎜   ↳ Logitech M510                           	id=15	[slave  pointer  (2)]
# ⎜   ↳ Logitech M510                           	id=16	[slave  pointer  (2)]
# ⎜   ↳ ELAN1205:00 04F3:30E9 Touchpad          	id=17	[slave  pointer  (2)]
# ⎣ Virtual core keyboard                   	id=3	[master keyboard (2)]
#     ↳ Virtual core XTEST keyboard             	id=5	[slave  keyboard (3)]
#     ↳ Power Button                            	id=6	[slave  keyboard (3)]
#     ↳ Asus Wireless Radio Control             	id=7	[slave  keyboard (3)]
#     ↳ Video Bus                               	id=8	[slave  keyboard (3)]
#     ↳ Video Bus                               	id=9	[slave  keyboard (3)]
#     ↳ Power Button                            	id=10	[slave  keyboard (3)]
#     ↳ Sleep Button                            	id=11	[slave  keyboard (3)]
#     ↳ ASUSTeK Computer Inc. N-KEY Device      	id=12	[slave  keyboard (3)]
#     ↳ ASUSTeK Computer Inc. N-KEY Device      	id=13	[slave  keyboard (3)]
#     ↳ Asus WMI hotkeys                        	id=18	[slave  keyboard (3)]
#     ↳ AT Translated Set 2 keyboard            	id=19	[slave  keyboard (3)]
#     ↳ ASUSTeK Computer Inc. N-KEY Device Consumer Control	id=20	[slave  keyboard (3)]
function _touchpad_roc_control() {
    # xinput list | grep TouchPad
    touchpad=$(xinput list | grep Touchpad)
    # echo "touchpad = " $touchpad
    # to find the number of the id ---------------------------
    str_len=${#touchpad}
    # echo "str_len = " $str_len
    found_equal_pos=0
    found_space=0
    for ((c=1;c<=$str_len;c++ )) ; do
        single_char=${touchpad:${c}-1:1}
        # echo "single_char = " $single_char
        if [[ $single_char == '=' ]] && [[ $found_equal_pos == 0 ]] ; then
            equal_pos=${c}
            found_equal_pos=1
        fi
        # it is not a space!!
        if [[ $single_char == '	' ]] && [[ $found_equal_pos == 1 ]] && [[ $found_space == 0 ]] ; then
            first_space_after_equal=${c}
            found_space=1
        fi
    done
    # echo "equal_pos = " $equal_pos
    # echo "first_space_after_equal = " $first_space_after_equal
    touchpadID=${touchpad:$equal_pos:$first_space_after_equal-$equal_pos}
    # echo $touchpadID
    # enable or disable the ROC touchpad
    xinput set-prop $touchpadID "Device Enabled" $1
}

# ===========================================================================================
function touchpad {
    # --------------------------------
    if [ $# = 0 ] ; then
        _touchpad_help
        return 1
    fi
    # --------------------------------
    if [ $# = 1 ] ; then
        _touchpad_help
        return 1
    fi
    # --------------------------------
    if [ $# = 2 ] ; then
        if [ $1 = 'thinkpad' ] ; then
            if [ $2 = 'enable' ] ; then
                _touchpad_thinkpad_control 1
                echo ' '
                echo 'Touch Pad on ThinkPad laptop is enabled '
                echo ' '
            elif [ $2 = 'disable' ] ; then
                _touchpad_thinkpad_control 0
                echo ' '
                echo 'Touch Pad on ThinkPad laptop is disabled '
                echo ' '
            else
                echo 'touchpad thinkpad: argument not supported.'
            fi
        fi
        if [ $1 = 'roc' ] || [ $1 = 'precision' ] ; then
            if [ $2 = 'enable' ] ; then
                _touchpad_roc_control 1
                echo ' '
                if [ $1 = 'roc' ] ; then
                    echo 'Touch Pad on ROC Zephyrus laptop is enabled '
                elif [ $1 = 'precision' ] ; then
                    echo 'Touch Pad on Dell Precision laptop is enabled '
                fi
                echo ' '
            elif [ $2 = 'disable' ] ; then
                _touchpad_roc_control 0
                echo ' '
                if [ $1 = 'roc' ] ; then
                    echo 'Touch Pad on ROC Zephyrus laptop is disabled '
                elif [ $1 = 'precision' ] ; then
                    echo 'Touch Pad on Dell Precision laptop is disabled '
                fi
                echo ' '
            else
                echo 'touchpad roc/precision: argument not supported.'
            fi
        fi
    fi
}

# ===========================================================================================
# auto completion reference:
# https://blog.bouzekri.net/2017-01-28-custom-bash-autocomplete-script.html
_touchpad() {
    COMPREPLY=()

    # All possible first values in command line
    local SERVICES=("
        thinkpad
        roc
        precision
    ")

    # declare an associative array for options
    declare -A ACTIONS
    # -------------------------------------------------------------------------
    # -------------------------------------------------------------------------
    ACTIONS[thinkpad]="enable disable " # must have a space in " " 
    ACTIONS[roc]="enable disable " # must have a space in " " 
    ACTIONS[precision]="enable disable " # must have a space in " " 
    ACTIONS[enable]=" " # must have a space in " " 
    ACTIONS[disable]=" " # must have a space in " " 

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

# ===========================================================================================
complete -F _touchpad touchpad
