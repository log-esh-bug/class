#!/bin/bash

##usage: ./dolog.sh "Comments to log"

parent_dir=/home/logesh-tt0826/class/
log_file=${parent_dir}logfile

log(){
    echo "$(date +%F' '%T' '%Z) [$(ps -p $PPID --format comm=) $PPID] LOG: $1" >> $log_file
}

if [ -z "$1" ]; then
    log "No Comments Sent by the calling process"
    exit 1
fi

log "$@"