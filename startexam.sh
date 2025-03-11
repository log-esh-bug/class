#!/bin/bash
source properties.sh

temp=${PARENT_DIR}/temp

sleep_time=3

rand(){
    echo $((RANDOM%30+70))
}

cleanup(){
    drop_lock $INFO_DB
    drop_lock $SCORE_DB
    drop_lock $temp
}
trap cleanup EXIT

update_marks(){    
    
    fetch_lock $INFO_DB
    ids=$(cat $INFO_DB | cut -f 1 | awk '{print}')
    drop_lock $INFO_DB

    
    for i in $ids
    do
        s1=$(rand)
        s2=$(rand)
        s3=$(rand)
        s4=$(rand)
        tot=$((s1+s2+s3+s4))
        printf "%03d\t%d\t%d\t%d\t%d\t%d\n" "$i" "$s1" "$s2" "$s3" "$s4" "$tot" >> $temp
    done
    

    # join -t$'\t' -j 1 $INFO_DB $temp | cut -f 1,2,5,6,7,8,9 > t1
    fetch_lock $SCORE_DB
    mv $temp $SCORE_DB
    drop_lock $SCORE_DB

    $LOG_SCRIPT "Marks generated and inserted to $SCORE_DB"

}

if [ -n "$1" ];then
    $LOG_SCRIPT "$(basename $0) says sleep time set to $1"
    sleep_time=$1
fi

if [ ! -e $INFO_DB ];then   
    $LOG_SCRIPT "Database[$INFO_DB] not exists! Quitting..."
fi

while((1))
do
    update_marks
    sleep $sleep_time
done

