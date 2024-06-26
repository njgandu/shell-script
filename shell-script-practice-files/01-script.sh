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
read -s mysql_root_password

validate(){
    if [ $1 -ne 0 ]
     then
        echo "$2....faulure"
     else
        echo "$2.....success"   
    fi     
}

if [ $USERID -ne 0 ]
 then
   echo "please execute this root user"
   exit1
 else
    echo "you are a superuser..continue"
fi   

dnf install mysql-server -y &>>$LOGFILE
validate $? "installing mysql"

systemctl enable mysqld &>>$LOGFILE
validate $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOGFILE
validate $? "Starting MySQL Server"

mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
validate $? "Setting up root password"

mysql -h 172.31.81.38 -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi

