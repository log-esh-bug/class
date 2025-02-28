#!/bin/bash
parent_dir=/home/logesh-pt7689/script/class/

markdb=${parent_dir}Marksbase
topbase=${parent_dir}toppers
logfile=${parent_dir}logfile

fetch_lock_markdb(){
	while [ -e ${markdb}.lock ];
	do
        # echo "waiting!"
		sleep 1		
	done
	touch ${markdb}.lock
}

drop_lock_markdb(){
	if [ -e ${markdb}.lock ];then
		rm ${markdb}.lock
	fi
}

if [ ! -e $markdb ];then   
    echo "Database[$markdb] not exists! Quitting..."
fi

find_topper_helper(){
    fetch_lock_markdb
    sort -k 7nr $markdb | awk 'NR==1,NR==3 {print}' > $topbase
    drop_lock_markdb

    echo "$(date) --> Toppers calculated and inserted to $topbase" >> $logfile
}

find_topper_helper