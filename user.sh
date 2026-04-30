#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.narasimhadevops.online

if [ $USERID -ne 0 ]; then 
   echo "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
   exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
if [ $1 -ne 0 ]; then 
   echo "$2... $R FAILURE $N" | tee -a $LOGS_FILE
   exit 1
else
   echo "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
fi

}

dnf module disable nodejs -y
VALIDATE $? "Disabling NodeJS Default version"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y
VALIDATE $? "Install NodeJS"

id roboshop
if [ $? -ne 0 ]; then

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating system user"
else 
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi    

mkdir  -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
VALIDATE $? "Downloading user code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip
VALIDATE $? "Unzip user code"

npm install
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying user service file"

systemctl daemon-reload
systemctl enable user 
systemctl start user
VALIDATE $? "Starting and enabling user"

