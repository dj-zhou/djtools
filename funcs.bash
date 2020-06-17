#!/bin/bash 

# ===========================================================================================
function _random_wallpaper()
{
    current_folder=${PWD}

    cd $wallpaper_folder
    set -- *
    length=$#
    random_num=$((( $RANDOM % ($length) ) + 1))
    gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_folder/${!random_num}"
    
    cd $current_folder
}

# ===========================================================================================
function _random_wallpaper_pickup()
{
    _random_wallpaper
    time_sec=0
    up_limit=120
    while true ; do
        time_sec=$((time_sec+1))
        if [ "$time_sec" -eq "$up_limit" ] ; then
            time_sec=0
            _random_wallpaper
            sleep 1
        fi
        echo $time_sec ": wallpaper_folder :"$wallpaper_folder
        sleep 5
    done
}

# ===========================================================================================
function _ask_to_remove_a_file()
{
    gdialog --title 'Remove a File (djtools)' --yesno 'Do you want to remove file "'$1'"?' 9 50
    if [ $? != 0 ] ; then
        gdialog --infobox 'File "'$1'" is NOT removed!' 9 50
    else
        rm $1
        gdialog --infobox 'File "'$1'" is removed!' 9 50
    fi
    gdialog --clear
}

# ===========================================================================================
function _ask_to_remove_a_folder()
{
    gdialog --title 'Remove a Folder (djtools)' --yesno 'Do you want to remove folder "'$1'"?' 9 50
    if [ $? != 0 ] ; then
        gdialog --infobox 'Folder "'$1'" is NOT removed!' 9 50
    else
        rm -rf $1
        gdialog --infobox 'Folder "'$1'" is removed!' 9 50
    fi
    gdialog --clear
}

# ===========================================================================================
function _ask_to_execute_cmd()
{
    echo "command: "$1
    echo " "
    echo 'Do you want to execute command "'${1}'"?'
    echo " "
    read answer
    if [[ ($answer = 'n') || ($answer = 'N') || ($answer = 'NO') || ($answer = 'No') || ($answer = 'no') ]] ; then
        echo 'Command "'$1'" is NOT executed!'
    elif [[ ($answer = 'y') || ($answer = 'Y') || ($answer = 'YES') || ($answer = 'Yes') || ($answer = 'yes') ]] ; then
        echo 'Command "'$1'" is going to be executed!'
        $1
    else
        echo "Wrong answer! No action was taken!"
    fi
}

# ===========================================================================================
function _write_to_text_file_with_width()
{
    str=$1
    width=$2
    file="$3"
    str_len=${#str}
    if [[ str_len > width ]] ; then
        echo " "
        echo " "
        echo "_write_to_text_file_with_width: width set too short!"
        echo " "
        echo " "
        for ((c=1;c<=$width;c++ )) ; do
            single_char=${str:${c}-1:1}
            echo -ne "$single_char" >> $file
        done
        return 1
    fi
    echo -ne "$str" >> $file
    for ((c=1;c<=$width-$str_len+1;c++ )) ; do
        echo -ne " " >> $file
    done
}

# ===========================================================================================
function _press_enter_to_continue()
{
    echo 'Press [ENTER] to continue'
    echo " "
    read answer
    echo $answer
}

# ===========================================================================================
function _display_section()
{
    echo '----------------------------------------------------'
}

# =============================================================================================
# example:
#    _find_argument_after_option -b aa bb -b cc dd
#                                $1 $2 $3 $4 $5 $6 
# it will compare the first "-b" with all others, and it will find out $4 matches
# so the output is $5
function _find_argument_after_option()
{
    # $1 is the one to find in all arguments from $2 to $9
    find_option=0
    find_argument=0
    for var in "$@"
    do
        # echo "$var"
        if [ $var = $1 ] ; then
            find_option=$((find_option+1))
            # echo "find_option = "$find_option
            # echo "find_argument = "$find_argument
        elif [ $find_option = 2 ] && [ $find_argument = 0 ] ; then
            arg=$var
            find_argument=1
            # echo "arg = "$arg
            # echo "find_argument = "$find_argument
        fi
        # echo "argument_no = "$argument_no
    done
    # echo "final result = "$arg
    echo $arg
}
