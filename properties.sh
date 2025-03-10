#!/bin/bash

#Directories
PARENT_DIR="/home/logesh-tt0826/class"
LOCK_DIR="${PARENT_DIR}/locks"
DATA_DIR="${PARENT_DIR}/data"
# BACKUP_DIR="${PARENT_DIR}backup_dir"

#Databases(ASCII File Format)
INFO_DB=${DATA_DIR}/base
SCORE_DB=${DATA_DIR}/Marksbase
TOPPER_DB=${DATA_DIR}/toppers

#Script Files
LOG_SCRIPT=${PARENT_DIR}/dolog.sh

#Frequency values
EXAM_FREQUENCY=4
TOPPER_FINDING_FREQUENCY=5
BACKUP_FREQUENCY=5

#Backup related stuffs
BACKUP_THRESHOLD=5
S_REMOTE_BACKUP_DIR="/home/test2/backup_class/backups"

#Remote details
S_REMOTE_HOST_NAME="zlabs-auto3"

#Credentials S_ ->ssh
S_USERNAME=test2

