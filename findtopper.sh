#!/bin/bash
parent_dir=/home/logesh-pt7689/script/class/

markdb=${parent_dir}Marksbase
topbase=${parent_dir}toppers
logfile=${parent_dir}logfile

sleep_time=2

if [ -n $1 ];then
    sleep_time=$1
fi

trap cleanup EXIT

fetch_lock(){
	while [ -e ${1}.lock ];
	do
		echo "waiting!"
		sleep 1		
	done
	touch ${1}.lock
}

drop_lock(){
	if [ -e ${1}.lock ];then
		rm ${1}.lock
	fi
}

if [ ! -e $markdb ];then   
    echo "Database[$markdb] not exists! Quitting..."
fi

find_topper_helper(){
    fetch_lock $markdb
    sort -k 6nr $markdb | awk 'NR==1,NR==3 {print}' > $topbase
    drop_lock $markdb

    echo "$(date) --> Toppers calculated and inserted to $topbase" >> $logfile
}

while((1))
do
    find_topper_helper
    sleep $sleep_time
done


cleanup(){
	drop_lock $markdb
}