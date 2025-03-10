#!/bin/bash
PARENT_DIR="/home/logesh-tt0826/class"

source ${PARENT_DIR}/properties.sh

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

do_backup_helper(){
    fetch_lock ${INFO_DB}
    fetch_lock ${SCORE_DB}
    fetch_lock ${TOPPER_DB}
    
    tar zcf - -C "$DATA_DIR" . | ssh "${S_USERNAME}@${S_REMOTE_HOST_NAME}" "cat > ${S_REMOTE_BACKUP_DIR}/base-$(date +%Y%m%d%H%M%S).tar.gz"

    drop_lock ${INFO_DB}
    drop_lock ${SCORE_DB}
    drop_lock ${TOPPER_DB}
    $LOG_SCRIPT "Done backup"
}

do_backup_helper