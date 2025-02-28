#!/bin/bash

parent_dir=/home/logesh-pt7689/script/class/
db=${parent_dir}base
id=

# echo "$db"

if [ ! -e $db ];then 
	id=1000
fi

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


add_record(){
	
	if [ -z $id ];then
		id=$(tail -n 1 ${db} | cut -f 1)
		id=$((id+1))
	fi

	read -p "Enter the name	   	: " name
	read -p "Enter the age	   	: " age
	if [ $(echo $age | grep --count --word-regexp '[0-9]*') -eq 0 ];then
		echo "Enter a valid age (Integer) value!"
		return
	fi
	read -p "Enter the contact 	: " contact

	fetch_lock_db
	printf "%03d\t%s\t%s\t%s\n" "$id" "$name" "$age" "$contact">> $db
	drop_lock_db

	id=$((id+1))
	
	echo "Student detail [ $name $age $contact ] added successfully!"
	
}

choice=y

while [ $choice == y -o $choice == Y ];
do
	add_record
	read -p "Want to continue?[y/n]" choice
done
