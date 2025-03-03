#!/bin/bash 
parent_dir=/home/logesh-pt7689/script/class/
db=${parent_dir}base
markdb=${parent_dir}Marksbase
topbase=${parent_dir}toppers

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

cleanup(){
    drop_lock $db
}
trap cleanup EXIT


#Usage fetch_details [Option] [Value]
#Options:
#   n|name
#   i|id
fetch_details(){
    field=
    case $1 in
        n|name)
            field=2
            ;;
        i|id)
            field=1
            ;;
        *)
            echo "Invalid Option"
            return
            ;;
    esac
    fetch_lock $db
    line=$(cat $db| cut --fields=${field} |grep --line-number $2|cut -f 1 -d ":")
    drop_lock $db
    echo $line
}
print_record_by_line(){
    echo "Id:" $(sed -n ${1}p $db | cut -f 1)
    echo "Name:" $(sed -n ${1}p $db | cut -f 2)
    echo "Age: "$(sed -n ${1}p $db | cut -f 3)
    echo "Contact: "$(sed -n ${1}p $db | cut -f 4)
}

print_record_by_line $(fetch_details n "logesh")
# fetch_details n kamal
