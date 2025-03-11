#!/bin/bash

source properties.sh

BACKUP_SLEEP_TIME=10

cleanup(){
	drop_lock $INFO_DB
	drop_lock $SCORE_DB
	drop_lock $TOPPER_DB
}
trap cleanup EXIT


#usage: start_backend_helper backend_name frequency
start_backend_helper(){
	fetch_lock ${1}.pid

	if [ -e ${1}.pid ];then
		local pid=$(cat ${1}.pid)
	    if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			echo "${1} already started!"
			drop_lock ${1}.pid
			return
		fi
	fi
	echo "${1} Started and will happen for every $2!"
	${PARENT_DIR}/${1}.sh ${2}&
	echo "$!" > ${1}.pid

	drop_lock ${1}.pid
}

#usage: stop_backend_helper backend_name
stop_backend_helper(){
	fetch_lock ${1}.pid

	if [ -e ${1}.pid ];then
		local pid=$(cat ${1}.pid) 
		if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			kill -9 $pid
			rm ${1}.pid
			echo "${1} Stopped!"
			drop_lock ${1}.pid
			return
		else
			rm ${1}.pid
			echo "${1}.pid file contains corrupted pid!"
		fi
	fi
	drop_lock ${1}.pid
	echo "${1} not started already. First start one!"
}

start_backend_helper backup_shed