#!/bin/bash
parent_dir=/home/logesh-pt7689/script/class/
backup_dir=${parent_dir}backup_dir
log_script=${parent_dir}dolog.sh

backup_sleep_time=5

if [ -n "$1" ]; then
    $log_script "$(basename $0) says Backup sleep time is set to $1"
    backup_sleep_time=$1
fi

start_backup_helper(){
    $log_script "Starting backup"
    
    $log_script "Backup completed"
}

while((1))
do
    start_backup_helper
    sleep $backup_sleep_time
done