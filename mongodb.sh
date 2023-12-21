#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0- $TIMESTAMP.log"
echo "script started executing at $TIMESTAMP" &>> $LOGFILE
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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied MongoDB Repo"
dnf install mongodb-org -y   &>> $LOGFILE
VALIDATE $? "Installing MongoDB"
systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabling MonogDB"
systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting MongoDB" 
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Editing remote access to MongoDB"
systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting MongoDB"