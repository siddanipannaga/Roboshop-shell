#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


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
curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip  &>> $LOGFILE
VALIDATE $? " downloading cart application " 
cd /app 
unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? " unzipping cart " 
npm install &>> $LOGFILE
VALIDATE $? " installing dependencies " 
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? " copying cartservice file " 
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " cart daemon reload " 
systemctl enable cart &>> $LOGFILE
VALIDATE $? " cart daemon enabled " 
systemctl start cart &>> $LOGFILE
VALIDATE $? " start the cart  " 
  
  





