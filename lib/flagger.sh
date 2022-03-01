#!/bin/bash

# Get value next to a given flag
# $1 flag to search
# $* parameters list to look
function getFlagValue() {
    wantedFlag="$1" && shift
    while [ -n "$1" ]; do
        if [ "$1" = "$wantedFlag" ]; then
            if [ -z "$(echo $2 | grep "^-")" ]; then
                echo "$2"
            else
                echo ""
            fi
            break
        else
            shift
        fi
    done
    unset wantedFlag
}

# Check if a flag is given
# $1 flag to check
# $* parameters list to look
function hasFlag() {
    wantedFlag="$1" && shift
    while [ -n "$1" ]; do
        if [ "$1" = "$wantedFlag" ]; then
            echo 1 && break
        else
            shift
        fi
    done
    [ -z "$1" ] && echo 0
    unset wantedFlag
}

# Delete a flag with its value from list
# $1 flag to delete
# $* original parameters list
function pruneFlagValue() {
    wantedFlag="$1" && shift
    prunedParameters=""
    while [ -n "$1" ]; do
        if [ "$1" != "$wantedFlag" ]; then
            if [ -z "$prunedParameters" ]; then
                prunedParameters="$1"
            else
                prunedParameters="$prunedParameters $1"
            fi
        else
            shift
        fi
        shift
    done
    echo "$prunedParameters"
    unset wantedFlag prunedParameters
}

# Delete a flag from list
# $1 flag to delete
# $* original parameters list
function pruneFlag() {
    wantedFlag="$1" && shift
    prunedParameters=""
    while [ -n "$1" ]; do
        if [ "$1" != "$wantedFlag" ]; then
            if [ -z "$prunedParameters" ]; then
                prunedParameters="$1"
            else
                prunedParameters="$prunedParameters $1"
            fi
        fi
        shift
    done
    echo "$prunedParameters"
    unset wantedFlag prunedParameters
}
