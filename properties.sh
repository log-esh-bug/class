#!/bin/bash

#Directories
PARENT_DIR="/home/logesh-tt0826/class"
LOCK_DIR="${PARENT_DIR}/locks"
DATA_DIR="${PARENT_DIR}/data"

#Databases(ASCII File Format)
INFO_DB=${DATA_DIR}/base
SCORE_DB=${DATA_DIR}/Marksbase
TOPPER_DB=${DATA_DIR}/toppers

#Logfile
LOG_FILE=${PARENT_DIR}/logfile

#Script Files
LOG_SCRIPT=${PARENT_DIR}/dolog.sh

#Frequency values
EXAM_FREQUENCY=4
TOPPER_FINDING_FREQUENCY=5
BACKUP_FREQUENCY=5

#Backup related stuffs
BACKUP_THRESHOLD=5
S_REMOTE_BACKUP_HOME_DIR="/home/test2/backup_class"
S_REMOTE_BACKUP_DIR="${S_REMOTE_BACKUP_HOME_DIR}/backups"
S_REMOTE_BACKUP_SERVER_SCRIPT="${S_REMOTE_BACKUP_HOME_DIR}/bp_server.sh"

#Remote details
S_REMOTE_HOST_NAME="zlabs-auto3"

#Credentials S_ ->ssh
S_USERNAME=test2


#LOCK_ROUTINES


fetch_lock(){
	while [ -e ${LOCK_DIR}/$(basename $1).lock ];
	do
		sleep 1		
	done
	touch ${LOCK_DIR}/$(basename $1).lock 
}

drop_lock(){
	if [ -e ${LOCK_DIR}/$(basename $1).lock  ];then
		rm ${LOCK_DIR}/$(basename $1).lock 
	fi
}
