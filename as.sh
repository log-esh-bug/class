#!/bin/bash

db=base
id=

if [ ! -e $db ];then 
	read -p "$db[Database] not exists.Want to create one?[y/n/q]" choice
	case $choice in
		y|Y)
			echo -e "Id\tName\tAge\tContact" > $db
			id=1
			echo "Database($db) created successfully!"
			;;
		*)
			exit
			;;
	esac
fi

add_record(){
	if [ -z $id ];then
		echo "Finding id"
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

	printf "%03d\t%s\t%s\t%s\n" "$id" "$name" "$age" "$contact">> $db
	id=$((id+1))
	
	echo "Student detail [ $name $age $contact ] added successfully!"
}

choice=y

while [ $choice == y -o $choice == Y ];
do
	add_record
	read -p "Want to continue?[y/n]" choice
done
