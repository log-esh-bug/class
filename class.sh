#!/bin/bash 

#######################################################
# Script Variables
# parent_dir: Parent directory of the script
# db: Database file path
# markdb: Marks Database file path
# topbase: Toppers Database file path
# id: Student id
# exam_frequency: Exam frequency	
# topper_finding_frequency: Topper finding frequency

parent_dir=/home/logesh-tt0826/class
lock_dir=${parent_dir}locks/
dat_dir=${parent_dir}data/

db=${parent_dir}data/base
markdb=${parent_dir}data/Marksbase
topbase=${parent_dir}data/toppers

log_script=${parent_dir}dolog.sh


id=
exam_frequency=1
topper_finding_frequency=2
backup_frequency=10

#######################################################
# Script Functions
# fetch_lock: Lock the file	
# drop_lock: Drop the lock
# cleanup: Cleanup the lock
# display_help: Display help
# display_help_interactive: Display help for interactive mode
# fetch_details: Fetch the details of the student
# print_record_by_line: Print the record by line number
# add_record: Add record to the database
# remove_record_by_name: Remove record by name
# find_record: Find record by name/id
# empty_database: Empty the database
# print_db: Print the database
# start_exam_helper: Start the exam
# stop_exam_helper: Stop the exam
# start_finding_topper_helper: Start the topper finding
# stop_finding_topper_helper: Stop the topper finding
# interactive_mode: Interactive mode
# start_backend_helper: Start the backend helper
# stop_backend_helper: Stop the backend helper

fetch_lock(){
	while [ -e ${lock_dir}$(basename $1).lock ];
	do
		# echo "waiting!"
		sleep 1		
	done
	touch ${lock_dir}$(basename $1).lock 
}

drop_lock(){
	if [ -e ${lock_dir}$(basename $1).lock  ];then
		rm ${lock_dir}$(basename $1).lock 
	fi
}

cleanup(){
	# echo "Cleanup called"
	drop_lock $db
	drop_lock $markdb
	drop_lock $topbase
	drop_lock startexam.pid	
	drop_lock findtopper.pid
	drop_lock startbackup.pid
}
trap cleanup EXIT

display_help(){
	cat <<- _eof_
		Usage: $0 [Option]
			-i (or) --interactive	Interactive mode
			-a (or) --add		Add Record to Database[$db]
			-r (or) --remove	To remove student From Database[$db]
			-f (or) --find-record	To Find student From Database[$db]
			-p (or) --printdb	Print the Database
			-d (or) --destroy	To Destroy the Database[$db]
			-h (or) --help		Display help
			-stex (or) --start-exam	Start Exam
			-spex (or) --stop-exam	Stop Exam
			-sttop (or) --start-topper	Start Topper Finding
			-sptop (or) --stop-topper	Stop Topper Finding
			-stbp (or) --start-backup	Start Backup
			-spbp (or) --stop-backup	Stop Backup
	_eof_
}

display_help_interactive(){
	cat <<- _eof_
		Help------------------------------------
		a 	Add Record to Database[$db]
		r	To remove student From Database[$db]
		f	To Find student From Database[$db]
		p 	Print the Database
		d 	To Destroy the Database[$db]
		h 	Display help
		q	To quit the program
		stex	Start Exam
		spex	Stop Exam
		sttop	Start Topper Finding
		sptop	Stop Topper Finding
		stbp	Start Backup
		spbp	Stop Backup
		----------------------------------------
	_eof_
}

#Usage fetch_details n(name)/i(id) [Value]
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

# usage: print_record_by_line [line_number]
print_record_by_line(){
    echo "Id:" $(sed -n ${1}p $db | cut -f 1)
    echo "Name:" $(sed -n ${1}p $db | cut -f 2)
    echo "Age: "$(sed -n ${1}p $db | cut -f 3)
    echo "Contact: "$(sed -n ${1}p $db | cut -f 4)
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

	fetch_lock $db
	printf "%03d\t%s\t%s\t%s\n" "$id" "$name" "$age" "$contact">> $db
	drop_lock $db

	id=$((id+1))
	
	echo "Student detail [ $name $age $contact ] added successfully!"
	
}

remove_record_by_name(){
    read -p "Enter the name: " name
	fetch_lock $db
    matches=$(cat $db | cut --fields=2 | grep -n --word-regexp "$name")
    if [ -z "$matches" ]; then
        drop_lock $db
        echo "Match not found!"
        return
    fi
    ct=$(echo "$matches"|wc -l)
    echo "Matches found: $ct "

    if ((ct == 0)); then
        drop_lock $db
        echo "Match not found!"
        return
    fi

    if ((ct == 1)); then
        drop_lock $db
        echo "Record to be deleted:"
        line=$(fetch_details n $name)
        sed -n ${line}p $db
        read -p "Do you want to continue?[y/n]:" ch
        case $ch in
            y|Y)
                fetch_lock $db
                sed -i "/${name}/d" "$db"
                drop_lock $db
                echo "$name record deleted successfully"
                ;;
            n|N)
                echo "Record not deleted"
                ;;        
        esac
        return
    fi

    read -p "Multiple matches found with $name! Do you want to delete all? [y/n] " ch

    if [[ $ch == y ]]; then
        sed -i "/${name}/d" "$db"
        echo "All records with $name have been deleted."
        drop_lock $db
        return
    fi

    echo -e "Matches Found\nId\tName\tAge\tContact"
    for i in $matches
    do
        line=$(echo $i|cut -f 1 -d ":")
        sed -n ${line}p $db
    done

    read -p "Enter the Id of the student record you want to delete(XXXX format) : " d_id
    drop_lock $db

    d_line=$(fetch_details i $d_id)

    if [ -z "$d_line" ]; then
        echo "No record found with id $d_id"
        return
    fi
    
    fetch_lock $db
    # sed -i "${d_line}d" "$db"
	sed -i "${d_line}d" "$db"
    drop_lock $db

	echo "$name with $d_id deleted successfully!"
    
}

find_record(){
	read -p "Find by Name/Id[n/i] : " choice
	case $choice in
		n|name)
			read -p "Enter the name: " name
			fetch_lock $db
			matches=$(cat $db | cut --fields=2 | grep -n --word-regexp "$name")
			if [ -z "$matches" ]; then
				drop_lock $db
				echo "Match not found!"
				return
			fi
			drop_lock $db
			echo -e "Matches Found\nId\tName\tAge\tContact"
			for i in $matches
			do
				line=$(echo $i|cut -f 1 -d ":")
				sed -n ${line}p $db
			done
			;;
		i|id)
			read -p "Enter the id: " id
			line=$(fetch_details i $id)
			print_record_by_line $line
			;;
		*)
			echo "Invalid choice!"
			;;
	esac
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
	read -p "Enter the database to print [db/markdb/topbase](space separated choices):" choice
	for i in $choice
	do
		case $i in
			db)
				fetch_lock $db
				cat $db
				drop_lock $db
				;;
			markdb)
				fetch_lock $markdb
				cat $markdb
				drop_lock $markdb
				;;
			topbase)
				fetch_lock $topbase
				cat $topbase
				drop_lock $topbase
				;;
			*)
				echo "Invalid choice!"
				;;
		esac
		echo "---------------------------------------------"
	done
}


#usage: start_backend_helper backend_name frequency
start_backend_helper(){
	fetch_lock ${1}.pid

	if [ -e ${1}.pid ];then
		local pid=$(cat ${1}.pid)
	    if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			echo "${1} already started!"
			drop_lock ${1}.pid
			return
		fi
	fi
	echo "${1} Started and will happen for every $2!"
	${parent_dir}${1}.sh ${2}&
	echo "$!" > ${1}.pid

	drop_lock ${1}.pid
}

#usage: stop_backend_helper backend_name
stop_backend_helper(){
	fetch_lock ${1}.pid

	if [ -e ${1}.pid ];then
		local pid=$(cat ${1}.pid) 
		if [[ $(ps -p $pid --format comm=) == "${1}.sh" ]];then
			kill -9 $pid
			rm ${1}.pid
			echo "${1} Stopped!"
			drop_lock ${1}.pid
			return
		else
			rm ${1}.pid
			echo "${1}.pid file contains corrupted pid!"
		fi
	fi
	drop_lock ${1}.pid
	echo "${1} not started already. First start one!"
}

start_exam_helper(){
	start_backend_helper startexam $exam_frequency
}

stop_exam_helper(){
	stop_backend_helper startexam
}

start_finding_topper_helper(){
	start_backend_helper findtopper $topper_finding_frequency
}

stop_finding_topper_helper(){
	stop_backend_helper findtopper
}

start_backup_helper(){
	start_backend_helper startbackup $backup_frequency
}

stop_backup_helper(){
	stop_backend_helper startbackup
}

interactive_mode(){
	local choice=
	display_help_interactive
	read -p "Enter the choice	: " choice
	while [ true ];
	do
		case $choice in
			r)
				remove_record_by_name
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
			f)
				find_record
				;;
			stex)
				start_exam_helper 
				;;
			spex)
				stop_exam_helper
				;;
			sttop)
				start_finding_topper_helper
				;;
			sptop)
				stop_finding_topper_helper
				;;
			stbp)
				start_backup_helper
				;;
			spbp)
				stop_backup_helper
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
############################################################################################################
# Main Script
############################################################################################################

#Initializing database id if there is nothing!
if [ ! -e $db ];then 
	id=1000
fi

if [ $# -eq 0 ];then
	display_help
fi

if [ ! -d $lock_dir ];then
	mkdir $lock_dir
fi

if [ ! -d $dat_dir ];then
	mkdir $dat_dir
fi

if [ ! -e $log_script ];then
	echo "Log script not found!"
	exit 1
fi


while [ $1 ];
do
	#echo "$1"
	case $1 in
		-i | --interactive)
			interactive_mode
			;;
		-r | --remove)
			remove_record_by_name
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
		-stex | --start-exam)
			start_exam_helper
			;;
		-spex | --stop-exam)
			stop_exam_helper
			;;
		-sttop | --start-topper)
			start_finding_topper_helper
			;;
		-sptop | --stop-topper)
			stop_finding_topper_helper
			;;
		-f | --find-record)
			find_record
			;;
		-stbp | --start-backup)
			start_backup_helper
			;;
		-spbp | --stop-backup)
			stop_backup_helper
			;;
		*)
			echo "$0: inavlid option -- '$1'"
			display_help
			;;
	esac
	shift
done
