#!/bin/bash
PARENT_DIR="/home/logesh-tt0826/class"

source ${PARENT_DIR}/properties.sh

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