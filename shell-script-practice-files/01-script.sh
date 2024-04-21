#!/bin/bash

USERID=$(id -u)
TIMESTAMP=(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0|cut -d "." -f1)
LOGFILE=/tmp/SCRIPTNAME-TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "please enter DB password"
read -s mysql-root-password

validate{
    if ($1 -ne 0)
     then
        echo "$2....faulure"
     else
        echo "$2.....success"   
    fi     
}

if ($USERID -ne 0)
 then
   echo "please execute this root user"
   exit1
 else
    echo "you are a superuser..continue"
fi   

dnf install mysql &>> LOGFILE
validate $? "installing mysql"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MySQL Server"

mysql_secure_installation --set-root-pass ${mysql-root-password} &>>$LOGFILE
VALIDATE $? "Setting up root password"

mysql -h 172.31.81.38 -uroot -p${mysql-root-password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi

