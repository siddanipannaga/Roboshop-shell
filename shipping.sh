#!/bin/bash
set -e
set -o pipefail

# Install Maven
dnf install maven -y

# Add application user if it doesn't exist
if ! id -u roboshop &> /dev/null; then
    useradd roboshop
fi

# Setup app directory if it doesn't exist
if [ ! -d "/app" ]; then
    mkdir /app
fi

# Download application code
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
cd /app
unzip /tmp/shipping.zip

# Build the application with Maven
cd /app
mvn clean package
mv target/shipping-1.0.jar shipping.jar

# Setup SystemD Shipping Service
cat <<EOF > /etc/systemd/system/shipping.service
[Unit]
Description=Shipping Service

[Service]
User=roboshop
Environment=CART_ENDPOINT=cart.allmydevops.online:8080
Environment=DB_HOST=mysql.allmydevops.online
ExecStart=/usr/bin/java -jar /app/shipping.jar
SyslogIdentifier=shipping

[Install]
WantedBy=multi-user.target
EOF

# Load the service
systemctl daemon-reload

# Enable and start the service
systemctl enable shipping
systemctl start shipping

# Install MySQL client
dnf install mysql -y

# Load Schema
mysql -h mysql.allmydevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql

# Restart the Shipping service after loading schema
systemctl restart shipping
