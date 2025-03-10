#!/bin/bash

##usage: ./dolog.sh "Comments to log"

PARENT_DIR=/home/logesh-tt0826/class
LOG_FILE=${PARENT_DIR}/logfile

log(){
    echo "$(date +%F' '%T' '%Z) [$(ps -p $PPID --format comm=) $PPID] LOG: $1" >> $LOG_FILE
}

if [ -z "$1" ]; then
    log "No Comments Sent by the calling process"
    exit 1
fi

log "$@"