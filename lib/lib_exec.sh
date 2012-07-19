#!/bin/bash
#
# Lib functions for imt build and analysis
#

alias echo='echo -e'


# how to use this lib
function help_msg
{
    cat <<_EOH_
Usage: source $0
    
    Lib for imt tools. It provides some lib functions for imt iso build and analysis.
    If you want to use them in your scripts, simply source this file.


_EOH_
}


# format the error info
function fmt_msg
{
    # FIXME: add support for the terminal on Mac OS X
    local red="\e[1;31m"
    local off="\e[0m"

    echo "$red ERROR: $@ $off"
}


# run the expression and output the error if it fails
function exec_expr
{
    echo "in exec_expr: \$# --- $#"
    echo "              \$@ --- $@"
    
    $1

    local err=$?

    if [ "$err" != "0" ]
    then
        fmt_msg $2
        exit $err
    fi    
}

