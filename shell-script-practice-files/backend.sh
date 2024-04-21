#!/bin/bash

USERID=$(id -u)
TIMESTAMP=(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0|cut -d "." -f1)
LOGFILEB=/tmp/SCRIPTNAME-TIMESTAMP.log

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

dnf module disable nodejs -y &>>$LOGFILEB
validate $? "disabling node js"

dnf module enable nodejs:20 -y &>>$LOGFILEB
validate $? "enabling node js"

dnf install nodejs -y &>>$LOGFILEB
validate $? "installing node js"

id expense &>>$LOGFILEB
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILEB
    validate $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILEB
validate $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILEB
validate $? "Downloading backend code"
 
cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILEB
validate $? "Extracted backend code" 

npm install &>>$LOGFILEB
validate $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILEB
validate $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILEB
validate $? "Daemon Reload"

systemctl start backend &>>$LOGFILEB
validate $? "Starting backend"

systemctl enable backend &>>$LOGFILEB
validate $? "Enabling backend"

dnf install mysql -y &>>$LOGFILEB
validate $? "Installing MySQL Client"

mysql -h 172.31.81.38 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILEB
validate $? "Schema loading"

systemctl restart backend &>>$LOGFILEB
validate $? "Restarting Backend"