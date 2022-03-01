#!/bin/bash

# Get a variable from a .ini file.
#   In case variable or .ini file doesn't exists returns 'undefined'.
# $1 .ini file path
# $2 variable name
function getINIVar() {
    if [ ! -f "$1" ] || [ -z "$(cat "$1" | grep "^$2=")" ]; then
        echo "undefined"
    else
        echo $(cat "$1" | grep "^$2=" | sed -e "s/$2=//")
    fi
}

# List current variables defined at .ini file
# $1 .ini file path
function getAllINIVars() {
    if [ ! -f "$1" ]; then
        echo -e "\nNo file found holding any variable at '$1'.\n"
    else
        echo -e "\nDEFINED VARIABLES"
        cat "$1"
        echo ""
    fi
}

# Set a variable on an .ini file.
# $1 .ini file path
# $2 variable name.
# $3 [Optional] variable value. If not defined is set to an empty value.
function setINIVar() {
    if [ ! -f "$1" ]; then
        touch "$1"
    fi
    current_value=$(getINIVar "$1" "$2")
    if [ "$current_value" = "undefined" ]; then
        echo "$2=$3" >>"$1"
    else
        sed -i -e "s|$2=\(.*\)|$2=$3|" "$1"
    fi
    unset current_value
}

# Drop a defined variable
# $1 .ini file path
# $2 variable name
# returns
#   0 : Nothing to drop
#   1 : Drop was done
function dropINIVar() {
    if [ "$(getINIVar "$1" "$2")" = "indefined" ]; then
        echo 0
    else
        sed -i "\!$2=!d" "$1"
        echo 1
    fi
}
