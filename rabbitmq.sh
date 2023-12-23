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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
VALIDATE $? " downloading erlangscript "
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
VALIDATE $? "downloading rabbitmq server "

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? " installing rabbitmq server "
systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE " enabling rabbitmq server "
systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? " starting rabbitmq server "
rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? " addding user roboshop "
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? " setting permissions "