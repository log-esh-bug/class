#!/bin/bash
parent_dir=/home/logesh-pt7689/script/class/
db=${parent_dir}base

fetch_lock_db(){
	while [ -e ${db}.lock ];
	do
		echo "waiting!"
		sleep 1		
	done
	touch ${db}.lock
}

drop_lock_db(){
	if [ -e ${db}.lock ];then
		rm ${db}.lock
	fi
}

remove_record(){
    read -p "Enter the student name to remove: " name
	fetch_lock_db
    ct=$(grep --count --word-regexp "$name" "$db")
    echo "Matches found: $ct"

    if ((ct == 0)); then
        echo "Match not found!"
        return
    fi

    if ((ct == 1)); then
        sed -i "/${name}/d" "$db"
        echo "$name record deleted successfully"
        return
    fi

    read -p "Multiple matches found with $name! Do you want to delete all? [y/n] " ch

    if [[ $ch == y ]]; then
        sed -i "/${name}/d" "$db"
        echo "All records with $name have been deleted."
        return
    fi

	read -p "Enter the Id of the student record to be deleted(XXX format) : " d_id
	sed -i "/${d_id}/d" "$db"
	echo "$name with $d_id deleted successfully!"
	drop_lock_db
}

remove_record
