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

dnf install maven -y 
VALIDATE $? " Installing maven "

if [ $? -ne 0 ]
then
   useradd roboshop
   VALIDATE $? "ROBOSHOP USER CREATION"
else
   echo -e " roboshop user already exits $Y SKIPPING $N "
fi      

mkdir -p /app 
VALIDATE $? " creating app directory " 

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
VALIDATE $? "downloading shipping "
cd /app
VALIDATE $? " moving to app directory "
unzip -o /tmp/shipping.zip
VALIDATE $? " unzipping shipping "

#cd /app
#VALIDATE $? " moving to app directory "
mvn clean package
VALIDATE $? " installing dependencies "
mv target/shipping-1.0.jar shipping.jar
VALIDATE $? " renaming jar files "
cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? " copying shipping service "
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " reloading the daemon "
systemctl enable shipping  &>> $LOGFILE
VALIDATE $? " enabling the shipping "
systemctl start shipping &>> $LOGFILE
VALIDATE $? " starting shipping "

dnf install mysql -y &>> $LOGFILE
VALIDATE $? " installing my sql "

mysql -h mysql.allmydevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? " loading mysql data "

systemctl restart shipping &>> $LOGFILE
VALIDATE $? " restrating shipping "