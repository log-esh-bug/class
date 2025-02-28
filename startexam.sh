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

update_marks(){    
    
    if [ -e $markdb ];then   
        rm $markdb
    fi

    ids=$(cat $db | cut -f 1 | awk '{print}')

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
    echo "$(date) --> Marks generated and inserted to $markdb" >> $logfile
}

update_marks

