#!/usr/bin/env bash

#open script
function vi-which { vim $(which $1); }
function which-vi { vim $(which $1); }

function atop-now() {
    today=$(date "+%Y%m%d");
    now=$(date "+%H:%M")
    echo "atop -r /var/log/atop/atop_$today -b $now ${@:2}"
    eval 'atop -r /var/log/atop/atop_$today -b $now "${@:2}"'
}

function ssh-diff() {

    source_file=$1
    host=$2
    if [[ $# -eq 3 ]]; then
        destination_file=$3
    else
        destination_file=$1
    fi

    eval 'diff $source_file <(ssh $host cat $destination_file)'
}

function tailfs() {
    tail_cmd=""
    for file in "$@"
    do
        tail_cmd+="tail -f $file && "
    done
    eval "${tail_cmd::-3}";
}
