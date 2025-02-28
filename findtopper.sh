#!/bin/bash
parent_dir=/home/logesh-pt7689/script/class/

markdb=${parent_dir}Marksbase
topbase=${parent_dir}toppers
logfile=${parent_dir}logfile

if [ ! -e $markdb ];then   
    echo "Database[$markdb] not exists! Quitting..."
fi

sort -k 7nr $markdb | awk 'NR==1,NR==3 {print}' > $topbase

echo "$(date) --> Toppers calculated and inserted to $topbase" >> $logfile

#chd