#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.allmydevops.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0- $TIMESTAMP.log"
echo " script started executing at $TIMESTAMP " &>> $LOGFILE
VALIDATE (){
   if [ $1 -ne 0 ]
   then
      echo -e "$2... $R failed $N " 
      exit 1  
   else
      echo -e "$2...$G sucess $N "
      fi
}
if [ $ID -ne 0 ]
then
   echo -e  "$R ERROR: Please run this script with root user $N"
   exit 1 # 
else
   echo "You are a root user"
fi
# echo "all arguments passed $@"
dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? " Disabling current nodejs " 
dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? " Enabling nodejs:18 " 
dnf install nodejs -y &>> $LOGFILE
VALIDATE $? " Installing nodejs:18 "  
id roboshop
if [ $? -ne 0 ]
then
   useradd roboshop
   VALIDATE $? "ROBOSHOP USER CREATION"
else
   echo -e " roboshop user already exits $Y SKIPPING $N "
fi      

mkdir -p /app 
VALIDATE $? " creating app directory " 
curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip  &>> $LOGFILE
VALIDATE $? " downloading user application " 
cd /app 
unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? " unzipping user " 
npm install &>> $LOGFILE
VALIDATE $? " installing dependencies " 

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service
VALIDATE $? " copying userservice file "

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " user daemon reload " 
systemctl enable user &>> $LOGFILE
VALIDATE $? " user daemon enabled " 
systemctl start user &>> $LOGFILE
VALIDATE $? " start the user  " 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? " copying mongodb repo " 
dnf install mongodb-org-shell -y  
VALIDATE $? " Installing mongodb client " 
# mongo --host mongodb.allmydevops.online </app/schema/user.js
mongo --host $MONGODB_HOST </app/schema/user.js 
VALIDATE $? " Loading user data into Mongodb " 