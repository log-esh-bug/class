#!/bin/bash
parent_dir=/home/logesh-pt7689/script/class/
db=${parent_dir}data/base
markdb=${parent_dir}data/Marksbase
topbase=${parent_dir}data/toppers
log_script=${parent_dir}dolog.sh
lock_dir=${parent_dir}locks/
backup_dir=${parent_dir}backup_dir

backup_sleep_time=5
backup_threshold=5

fetch_lock(){
	while [ -e ${lock_dir}$(basename $1).lock ];
	do
		# echo "waiting!"
		sleep 1		
	done
	touch ${lock_dir}$(basename $1).lock 
}

drop_lock(){
	if [ -e ${lock_dir}$(basename $1).lock  ];then
		rm ${lock_dir}$(basename $1).lock 
	fi
}

cleanup(){
	drop_lock $db
	drop_lock $markdb
	drop_lock $topbase
}
trap cleanup EXIT

start_backup_helper(){
    fetch_lock ${db}
    fetch_lock ${markdb}
    fetch_lock ${topbase}

    current_dir=$(pwd)
    cd ${parent_dir}/data
    tar --create --file ${backup_dir}/base_$(date +%Y%m%d%H%M%S).tar $(basename $db) $(basename $markdb) $(basename $topbase)
    cd $current_dir

    drop_lock ${db}
    drop_lock ${markdb}
    drop_lock ${topbase}
    $log_script "Done backup"
}

if [ -n "$1" ]; then
    $log_script "$(basename $0) says Backup sleep time is set to $1"
    backup_sleep_time=$1
fi

if [ ! -d $backup_dir ];then
    if [[ $(mkdir $backup_dir)==0 ]];then
        $log_script "No backup directory found.Created one at $backup_dir"
    else
        $log_script "Unable to create backup directory at $backup_dir"
    fi
fi

while ((1))
do
    backups_found=$(ls -l $backup_dir | wc -l)
    if(($backups_found > $backup_threshold));then

        # $log_script "More than $backup_threshold backups found in $backup_dir.Deleting oldest backup"

        oldest_backup=$(ls -t $backup_dir | tail -1)
        rm $backup_dir/$oldest_backup
    fi
    start_backup_helper
    sleep $backup_sleep_time
done