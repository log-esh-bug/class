#!/bin/bash

db=base

remove_record(){
	read -p "Enter the student name to remove:" name
	ct=$(grep --count --word-regexp "$name" "$db")
	echo $ct

	if ((ct==0));then
		echo "Match not found!"
		return
	fi

	if ((ct==1));then
		sed -i /${name}/d $db
		echo "$name record deleted succesfully"
		return
	fi

	read -p "Multiple matches found with $name !Did you want to delete all ?[y/n]" ch
	echo $ch

	if [[ $ch==y ]];then	
		echo "Inside y block"
		echo "$ch"
		# sed -i /${name}/d $db
		return
	fi
	echo "$choice"

	read -p "Enter the age : " age
	sed -i /${name}\t${age}/d $db
}

remove_record
