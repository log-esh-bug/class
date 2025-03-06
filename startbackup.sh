#!/bin/bash -x

source properties.sh

fetch_lock(){
	while [ -e ${LOCK_DIR}$(basename $1).lock ];
	do
		# echo "waiting!"
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

    # tar_file_name=$(date +%Y%m%d%H%M%S)
    # tar --create --file ${backup_dir}/base_${tar_file_name}.tar $(basename $INFO_DB) $(basename $SCORE_DB) $(basename $TOPPER_DB)
    tar zcvf - ${DATA_DIR} | ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME} "cat > ${S_REMOTE_BACKUP_DIR}/base-$(date +%Y%m%d%H%M%S).tar.gz"

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

if [ ! -d $REMOTE_BACKUP_DIR ];then
    if [[ $(ssh ${S_USERNAME}@${S_REMOTE_HOST_NAME} "mkdir ${S_REMOTE_BACKUP_DIR}")==0 ]];then
        $LOG_SCRIPT "No backup directory found.Created one at $S_REMOTE_BACKUP_DIR"
    else
        $LOG_SCRIPT "Unable to create backup directory at $S_REMOTE_BACKUP_DIR"
    fi
fi

while ((1))
do
    backups_found=$(ls -l $REMOTE_BACKUP_DIR | wc -l)
    if(($backups_found > $BACKUP_THRESHOLD));then

        # $LOG_SCRIPT "More than $BACKUP_THRESHOLD backups found in $backup_dir.Deleting oldest backup"

        oldest_backup=$(ls -t $backup_dir | tail -1)
        rm $backup_dir/$oldest_backup
    fi
    start_backup_helper

    sleep $BACKUP_SLEEP_TIME
done