#! /bin/bash

yum update -y
yum install java-17-amazon-corretto.${EC2_CPU_ARCHITECTURE} \
  amazon-cloudwatch-agent -y

echo "BASE_PATH=/var/www/minecraft" >> /etc/environment
echo "SERVER_DIRECTORY=/var/www/minecraft/server" >> /etc/environment

source /etc/environment
mkdir -p "$SERVER_DIRECTORY"
cd "$BASE_PATH" || exit

## Write scripts for later use
cat >start_server.sh <<__EOF__
#!/bin/bash -x

cd $SERVER_DIRECTORY

if ! [[ -f "server.jar" ]]; then
    aws s3 cp s3://${S3_BUCKET}/${MINECRAFT_VERSION}/minecraft_server_${MINECRAFT_VERSION}.zip .
    unzip minecraft_server_${MINECRAFT_VERSION}.zip
    rm -fv minecraft_server_${MINECRAFT_VERSION}.zip
fi

java -Xms${JAVA_XMS} -Xmx${JAVA_XMX} -jar server.jar nogui
__EOF__

cat >s3_backup.sh <<__EOF__
#!/bin/bash -x

cd $SERVER_DIRECTORY
zip -r minecraft_server_${MINECRAFT_VERSION}.zip .
aws s3 cp minecraft_server_${MINECRAFT_VERSION}.zip s3://${S3_BUCKET}/${MINECRAFT_VERSION}/minecraft_server_${MINECRAFT_VERSION}.zip
__EOF__

cat >minecraft.service <<__EOF__
[Unit]
Description=Minecraft Service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/usr/bin/env ./$BASE_PATH/start_server.sh

[Install]
WantedBy=multi-user.target
__EOF__

mv minecraft.service /etc/systemd/system/
chmod +x start_server.sh
chmod +x s3_backup.sh
systemctl start minecraft.service
systemctl enable minecraft.service

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-EC2MinecraftServerCWAgent -s
