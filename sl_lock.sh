#!/bin/bash
parent_dir=/home/logesh-pt7689/script/class/
log_script=${parent_dir}dolog.sh
lock_dir=${parent_dir}locks/

fetch_lock(){

	while [ -e ${lock_dir}${1}.lock ];
	do
		# echo "waiting!"
		sleep 1		
	done
	touch ${lock_dir}${1}.lock
}

drop_lock(){
	if [ -e ${lock_dir}${1}.lock ];then
		rm ${lock_dir}${1}.lock
	fi
}

if [ ! -d $lock_dir ];then
	if [[ $(mkdir $lock_dir)==0 ]];then
		$log_script "Lock directory Not found.Created one!"
	else
		$log_script "Lock directory not found.Also creation failed with exit status $?"
		exit 1
	fi
fi

fetch_lock logesh
sleep 10
drop_lock logesh