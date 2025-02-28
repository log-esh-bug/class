#!/bin/bash 
parent_dir=/home/logesh-pt7689/script/class/

db=${parent_dir}base
markdb=${parent_dir}Marksbase
logfile=${parent_dir}logfile

if [ ! -e $db ];then   
        echo "Database[$db] not exists! Quitting..."
fi

rand(){
    echo $((RANDOM%60+40))
}

fetch_lock_db(){
	while [ -e ${db}.lock ];
	do
        echo "waiting! for db"
		sleep 1		
	done
	touch ${db}.lock
}

drop_lock_db(){
	if [ -e ${db}.lock ];then
		rm ${db}.lock
	fi
}

fetch_lock_markdb(){
	while [ -e ${markdb}.lock ];
	do
        echo "waiting! for markdb"
		sleep 1		
	done
    # sleep 10
	touch ${markdb}.lock
}

drop_lock_markdb(){
	if [ -e ${markdb}.lock ];then
		rm ${markdb}.lock
	fi
}

update_marks(){    
    
    fetch_lock_markdb
    if [ -e $markdb ];then   
        rm $markdb
    fi
    drop_lock_markdb

    fetch_lock_db
    ids=$(cat $db | cut -f 1 | awk '{print}')
    drop_lock_db

    fetch_lock_markdb
    for i in $ids
    do
        s1=$(rand)
        s2=$(rand)
        s3=$(rand)
        s4=$(rand)
        tot=$((s1+s2+s3+s4))
        printf "%03d\t%d\t%d\t%d\t%d\t%d\n" "$i" "$s1" "$s2" "$s3" "$s4" "$tot" >> $markdb
    done
    

    join -t$'\t' -j 1 $db $markdb | cut -f 1,2,5,6,7,8,9 > temp

    mv temp $markdb
    drop_lock_markdb

    echo "$(date) --> Marks generated and inserted to $markdb" >> $logfile
}

update_marks