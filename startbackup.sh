#!/bin/bash

source properties.sh

#Default backup frequency set to 10s
BACKUP_SLEEP_TIME=10

fetch_lock(){
	while [ -e ${LOCK_DIR}$(basename $1).lock ];
	do
		sleep 1		
	done
	touch ${LOCK_DIR}$(basename $1).lock 
}

drop_lock(){
	if [ -e ${LOCK_DIR}$(basename $1).lock  ];then
		rm ${LOCK_DIR}$(basename $1).lock 
	fi
}

cleanup(){
	drop_lock $INFO_DB
	drop_lock $SCORE_DB
	drop_lock $TOPPER_DB
}
trap cleanup EXIT

start_backup_helper(){
    fetch_lock ${INFO_DB}
    fetch_lock ${SCORE_DB}
    fetch_lock ${TOPPER_DB}

    current_dir=$(pwd)
    cd ${PARENT_DIR}/data

    tar zcf - ${DATA_DIR} | ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME} "cat > ${S_REMOTE_BACKUP_DIR}/base-$(date +%Y%m%d%H%M%S).tar.gz"

    cd $current_dir

    drop_lock ${INFO_DB}
    drop_lock ${SCORE_DB}
    drop_lock ${TOPPER_DB}
    $LOG_SCRIPT "Done backup"
}

if [ -n "$1" ]; then
    $LOG_SCRIPT "$(basename $0) says Backup sleep time is set to $1"
    BACKUP_SLEEP_TIME=$1
fi

ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME} "if [ ! -d $S_REMOTE_BACKUP_DIR ];then
                                            mkdir $S_REMOTE_BACKUP_DIR
                                        fi"

while ((1))
do
    backups_found=$(ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME} "ls ${S_REMOTE_BACKUP_DIR}| wc -l")
    if(($backups_found >= $BACKUP_THRESHOLD));then

        # $LOG_SCRIPT "More than $BACKUP_THRESHOLD backups found in $backup_dir.Deleting oldest backup"

        oldest_backup=$(ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME}  "ls -t $S_REMOTE_BACKUP_DIR | tail -1")
        ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME} "rm ${S_REMOTE_BACKUP_DIR}/${oldest_backup}"
    fi
    start_backup_helper

    sleep $BACKUP_SLEEP_TIME
done