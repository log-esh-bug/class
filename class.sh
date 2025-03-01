#!/bin/bash
parent_dir=/home/logesh-pt7689/script/class/
db=${parent_dir}base
id=

#Initializing database if there is nothing!
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

display_help(){
	cat <<- _eof_
		Usage: $0 [Option]
			-i (or) --interactive	Interactive mode
			-a (or) --add		Add Record to Database[$db]
			-r (or) --remove	To remove student From Database[$db]
			-p (or) --printdb	Print the Database
			-d (or) --destroy	To Destroy the Database[$db]
			-h (or) --help		Display help
	_eof_
}


display_help_interactive(){
	cat <<- _eof_
		Help------------------------------------
		a 	Add Record to Database[$db]
		r	To remove student From Database[$db]
		p 	Print the Database
		d 	To Destroy the Database[$db]
		h 	Display help
		q	To quit the program
		----------------------------------------
	_eof_
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

empty_database(){
	read -p "Are you sure want to destroy the database![y/n/q]:" choice
	echo "Your choice $choice"
	case $choice in
		y | Y)
			rm $db
			echo "$db(DataBase) destroyed successfully!"
			;;
		q | Q)
			echo "Program Terminated successfully!"
			exit
			;;
		*)
			;;
	esac
}

print_db(){
	cat $db	
}

start_exam(){
	bash start_exam_helper
}

stop_exam(){
	bash stop_exam_helper
}

interactive_mode(){
	local choice=
	display_help_interactive
	read -p "Enter the choice	: " choice
	while [ true ];
	do
		case $choice in
			r)
				remove_record
				;;
			d)
				empty_database
				;;
			h)
				display_help_interactive
				;;		
			p)
				print_db
				;;
			a)
				add_record
				;;
			q)
				exit 0
				;;
			*)
				echo "$0: inavlid option -- '$choice'"
				display_help_interactive
				;;
		esac
		read -p "Enter the choice	: " choice
	done
}

if [ $# -eq 0 ];then
	display_help
fi

while [ $1 ];
do
	#echo "$1"
	case $1 in
		-i | --interactive)
			interactive_mode
			;;
		-r | --remove)
			remove_record
			;;
		-d | --destroy)
			empty_database
			;;
		-h | --help)
			display_help
			;;		
		-p | --printdb)
			print_db
			;;
		-a | --add)
			add_record
			;;
		-ste | --start-exam)
			start_exam
			;;
		-spe | --stop-exam)
			start_exam
			;;
		*)
			echo "$0: inavlid option -- '$1'"
			display_help
			;;
	esac
	shift
done