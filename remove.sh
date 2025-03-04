#!/bin/bash 
parent_dir=/home/logesh-pt7689/script/class/
db=${parent_dir}data/base
lock_dir=${parent_dir}locks/

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
    drop_lock $db
}
trap cleanup EXIT

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
    sed -i "${d_line}d" "$db"
    drop_lock $db

	echo "$name with $d_id deleted successfully!"
    
}

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

remove_record_by_name

