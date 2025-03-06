#!/bin/bash
parent_dir=/home/logesh-tt0826/class/
db=${parent_dir}data/base
markdb=${parent_dir}data/Marksbase
topbase=${parent_dir}data/toppers
log_script=${parent_dir}dolog.sh
lock_dir=${parent_dir}locks/

# echo "$log_script"

sleep_time=2

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
	drop_lock $markdb
}
trap cleanup EXIT

find_topper_helper(){
    fetch_lock $markdb
    sort -k 6nr $markdb | awk 'NR==1,NR==3 {print}' > $topbase
    drop_lock $markdb

    $log_script "Toppers calculated and inserted to $topbase"
}

if [ -n "$1" ];then
	$log_script "$(basename $0) says Sleep time set to $1"
    sleep_time=$1
fi

if [ ! -e $markdb ];then   
    $log_script "Database[$markdb] not exists! Quitting..."
fi

while((1))
do
    find_topper_helper
    sleep $sleep_time
done
