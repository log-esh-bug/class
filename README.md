# <strong>Student's School Register - A shell Script</strong>
# Script files
### class.sh 
It contains main script to add,remove the record from base(A typical database) as well as routines to create,destroy the base.
### as.sh [ Add Student ]
Calling this will prompt you to recurrently add the student details untill you press n(no).
### remove.sh [ Remove a record from the database ]
-> It will ask for the user name , if the name is    not availabe it will throughs an error and exists.
-> If the db contains multipla names of the same record it will ask for the id.
### startexam.sh
Routines to conduct examination(i.e to find random marks between 40 to 100) and insert the mark for record found in base and add them to Marksbase.     
-> Will recurrently do this untill killed by another process with an interval mentioned as sleep_time.
### findtopper.sh
Routines to find toppers based on the marks available from Marksbase.sh.
-> Will recurrently do this untill killed by another process with an interval mentioned as sleep_time.
### backup
Routine to copy the files in the current directory to a directory specified.
-> Will do backup only called manually by the user.
-> Will suppress the stdout and sterr by redirecting it to /dev/null.
# Databases(Text files)
### base
A typical database to store student records in the format.

        id Name Age Contacts
-> Delimated througn tab(\t)
### Marksbase
A typical database to store student's id,name with there obtained marks in the format,

        id Name S1 S2 S3 S4 Total
        where,
            S1 -> Subject 1 Marks
            S2 -> Subject 2 Marks
            S3 -> Subject 3 Marks
            S4 -> Subject 4 Marks
         Total -> Equivalent to S1+S2+S3+
### toppers
A db to store the top scorers from Marksbase.Usually limited to 3 toppers.
### Logfile
A logfile which id getting updated for every time the startexam.sh wakes up and update the database, as well as during changes made by findtopper.sh. 