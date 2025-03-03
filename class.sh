#!/bin/bash
trap cleanup EXIT
parent_dir=/home/logesh-pt7689/script/class/
db=${parent_dir}base
markdb=${parent_dir}Marksbase
topbase=${parent_dir}toppers
id=

exam_freq=1
topper_finding_freq=2


#Initializing database id if there is nothing!
if [ ! -e $db ];then 
	id=1000
fi

#Usage: fetch_lock dbname
fetch_lock(){
	# echo "$1 lock created"
	while [ -e ${1}.lock ];
	do
		echo "waiting!"
		sleep 1		
	done
	touch ${1}.lock
}
#usage drop_lock dbname
drop_lock(){
	if [ -e ${1}.lock ];then
		rm ${1}.lock
	fi
}

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

    read -p "Enter the Id of the student record you want to delete(XXX format) : " d_id
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
	read -p "Find by Name/Id[n/i]" choice
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

start_exam_helper(){

	fetch_lock startexam.pid

	if [ -e startexam.pid ];then
		local pid=$(cat startexam.pid)
	    if [[ $(ps -p $pid --format comm=) == "startexam.sh" ]];then
			echo "Exam already started!"
			drop_lock startexam.pid
			return
		fi
	fi
	echo "Exam Started and will happen for every $exam_freq!"
	${parent_dir}startexam.sh $exam_freq&
	echo "$!" > startexam.pid

	drop_lock startexam.pid
}

stop_exam_helper(){
	fetch_lock startexam.pid

	if [ -e startexam.pid ];then
		local pid=$(cat startexam.pid) 
		if [[ $(ps -p $pid --format comm=) == "startexam.sh" ]];then
			kill -9 $pid
			rm startexam.pid
			echo "Exam Stopped!"
			drop_lock startexam.pid
			return
		else
			rm startexam.pid
			echo "startexam.pid file contains corrupted pid!"
		fi
	fi
	drop_lock startexam.pid
	echo "Exam not started already. First start one!"
}

start_finding_topper_helper(){
	fetch_lock findtopper.pid

	if [ -e findtopper.pid ];then
		local pid=$(cat findtopper.pid)
	    if [[ $(ps -p $pid --format comm=) == "findtopper.sh" ]];then
			echo "Find topper already started!"
			drop_lock findtopper.pid
			return
		fi
	fi

	echo "Finding topper process started and will happen for every $topper_finding_freq!"
	${parent_dir}findtopper.sh $topper_finding_freq&
	echo "$!" > findtopper.pid

	drop_lock findtopper.pid
}

stop_finding_topper_helper(){
	fetch_lock findtopper.pid

	if [ -e findtopper.pid ];then
		local pid=$(cat findtopper.pid)
		if [[ $(ps -p $pid --format comm=) == "findtopper.sh" ]];then
			kill -9 $pid
			rm findtopper.pid
			echo "Find topper stopped!"

			drop_lock findtopper.pid
			return
		else
			rm findtopper.pid
			echo "findtopper.pid file contains corrupted pid!"
		fi
	fi
	drop_lock findtopper.pid
	echo "Find topper process not found. First start one!"
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
		*)
			echo "$0: inavlid option -- '$1'"
			display_help
			;;
	esac
	shift
done

cleanup(){
	drop_lock $db
	drop_lock $markdb
	drop_lock $topbase
	drop_lock startexam.pid	
	drop_lock findtopper.pid
}