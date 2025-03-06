#!/bin/bash

#Directories
PARENT_DIR="/home/logesh-tt0826/class/"
LOCK_DIR="${PARENT_DIR}locks/"
DATA_DIR="${PARENT_DIR}data/"
# BACKUP_DIR="${PARENT_DIR}backup_dir"

#Databases(ASCII File Format)
INFO_DB=${parent_dir}data/base
SCORE_DB=${parent_dir}data/Marksbase
TOPPER_DB=${parent_dir}data/toppers

#Script Files
LOG_SCRIPT=${parent_dir}dolog.sh

#Consatants
BACKUP_SLEEP_TIME=5
BACKUP_THRESHOLD=5

#Backup related stuffs
S_REMOTE_BACKUP_DIR="/home/test2/backup_class"

#Remote details
S_REMOTE_HOST_NAME="zlabs-auto3"

#Credentials S_ ->ssh
S_USERNAME=test2

