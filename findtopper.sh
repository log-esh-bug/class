#!/bin/bash

source properties.sh

# echo "$LOG_SCRIPT"

sleep_time=2

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
	drop_lock $SCORE_DB
}
trap cleanup EXIT

find_topper_helper(){
    fetch_lock $SCORE_DB
    sort -k 6nr $SCORE_DB | awk 'NR==1,NR==3 {print}' > $TOPPER_DB
    drop_lock $SCORE_DB

    $LOG_SCRIPT "Toppers calculated and inserted to $TOPPER_DB"
}

if [ -n "$1" ];then
	$LOG_SCRIPT "$(basename $0) says Sleep time set to $1"
    sleep_time=$1
fi

if [ ! -e $SCORE_DB ];then   
    $LOG_SCRIPT "Database[$SCORE_DB] not exists! Quitting..."
fi

while((1))
do
    find_topper_helper
    sleep $sleep_time
done
