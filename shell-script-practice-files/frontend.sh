#!/bin/bash

USERID=$(id -u)
TIMESTAMP=(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0|cut -d "." -f1)
LOGFILE=/tmp/SCRIPTNAME-TIMESTAMP.log

VALIDATE(){
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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

cp /shell-script/shell-script-practice-files/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"