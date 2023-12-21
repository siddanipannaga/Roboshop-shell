#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
 # MONGODB_HOST=mongodb.allmydevops.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0- $TIMESTAMP.log"
exec &>$LOGFILE
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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 

dnf module enable redis:remi-6.2 -y  
VALIDATE $? "enabling redis"

dnf install redis -y 
VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "allowing remote connections"
systemctl enable redis
VALIDATE $? " enable redis "
systemctl start redis
VALIDATE $? " start redis "
