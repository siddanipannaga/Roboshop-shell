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

dnf install python36 gcc python3-devel -y

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip
VALIDATE $? " downloading payment "
cd /app 
VALIDATE $? " goto app directory "
unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? " unzipping payments "
cd /app 
VALIDATE $? " goto app directory "
pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? " Installing pip3.6 "

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service
VALIDATE $? " copying payment service "
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " reloading the daemon "
systemctl enable payment  &>> $LOGFILE
VALIDATE $? " enabling payment "
systemctl start payment &>> $LOGFILE
VALIDATE $? " starting payment "


