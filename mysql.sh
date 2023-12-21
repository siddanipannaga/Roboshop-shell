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
dnf module disable mysql -y &>> $LOGFILE
VALIDATE $? " disable present mysql version "

cp mysql.repo /etc/yum.repos.d/mysql.repo
VALIDATE $? " copying Mysql repo "

dnf install mysql-community-server -y &>> $LOGFILE
VALIDATE $? " installing my sql new "

systemctl enable mysqld 
VALIDATE $? " enabling mysql "

systemctl start mysqld
VALIDATE $? " starting mysql "

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? " setting root password for MY sql server "




