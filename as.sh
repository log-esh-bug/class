#!/bin/bash

db=base

if [ ! -e $db ];then 
	read -p "$db[Database] not exists.Want to create one?[y/n/q]" choice
	case $choice in
		y|Y)
			echo -e "Name\tAge\tContact" > $db
			echo "Database($db) created successfully!"
			;;
		*)
			exit
			;;
	esac
fi

add_record(){
	read -p "Enter the name	   	: " name
	read -p "Enter the age	   	: " age
	if [ $(echo $age | grep --count --word-regexp '[0-9]*') -eq 0 ];then
		echo "Enter a valid age (Integer) value!"
		return
	fi
	read -p "Enter the contact 	: " contact

	printf "%s\t%s\t%s\n" "$name" "$age" "$contact">> $db
	
	echo "Student detail [ $name $age $contact ] added successfully!"
}

choice=y

while [ $choice == y -o $choice == Y ];
do
	add_record
	read -p "Want to continue?[y/n]" choice
done
