db=base
markdb=Marksbase
# Marksbase in the format [id    s1    s2  s3  s4](\t in between) 

rand(){
    echo $((RANDOM%40+60))
}

if [ ! -e $db ];then   
    echo "Database[$db] not exists! Quitting..."
fi

ids=$(cat $db | cut -f 1 | awk 'NR==2, NR==NF {print}')

rm $markdb
for i in $ids
do
    s1=$(rand)
    s2=$(rand)
    s3=$(rand)
    s4=$(rand)
    tot=$((s1+s2+s3+s4))
    printf "%03d\t%d\t%d\t%d\t%d\t%d\n" "$i" "$s1" "$s2" "$s3" "$s4" "$tot" >> $markdb
done