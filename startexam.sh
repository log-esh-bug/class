#!/bin/bash 
parent_dir=/home/logesh-pt7689/script/class/

db=${parent_dir}base
markdb=${parent_dir}Marksbase
logfile=${parent_dir}logfile
temp=${parent_dir}temp

sleep_time=1

if [ -n $1 ];then
    sleep_time=$1
fi

trap cleanup EXIT

if [ ! -e $db ];then   
        echo "Database[$db] not exists! Quitting..."
fi

rand(){
    echo $((RANDOM%30+70))
}

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

    echo "$(date) --> Marks generated and inserted to $markdb" >> $logfile
}

while((1))
do
    update_marks
    sleep $sleep_time
done

cleanup(){
    drop_lock $db
    drop_lock $markdb
    drop_lock $temp
}