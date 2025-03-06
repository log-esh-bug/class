#!/bin/bash
parent_dir=/home/logesh-tt0826/class/
db=${parent_dir}data/base
markdb=${parent_dir}data/Marksbase
topbase=${parent_dir}data/toppers
log_script=${parent_dir}dolog.sh
lock_dir=${parent_dir}locks/
temp=${parent_dir}temp

sleep_time=3

rand(){
    echo $((RANDOM%30+70))
}

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
    drop_lock $db
    drop_lock $markdb
    drop_lock $temp
}
trap cleanup EXIT

update_marks(){    
    
    fetch_lock $db
    ids=$(cat $db | cut -f 1 | awk '{print}')
    drop_lock $db

    
    for i in $ids
    do
        s1=$(rand)
        s2=$(rand)
        s3=$(rand)
        s4=$(rand)
        tot=$((s1+s2+s3+s4))
        printf "%03d\t%d\t%d\t%d\t%d\t%d\n" "$i" "$s1" "$s2" "$s3" "$s4" "$tot" >> $temp
    done
    

    # join -t$'\t' -j 1 $db $temp | cut -f 1,2,5,6,7,8,9 > t1
    fetch_lock $markdb
    mv $temp $markdb
    drop_lock $markdb

    $log_script "Marks generated and inserted to $markdb"

}

if [ -n "$1" ];then
    $log_script "$(basename $0) says sleep time set to $1"
    sleep_time=$1
fi

if [ ! -e $db ];then   
    $log_script "Database[$db] not exists! Quitting..."
fi

while((1))
do
    update_marks
    sleep $sleep_time
done

