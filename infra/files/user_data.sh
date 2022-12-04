#! /bin/bash

yum update -y
yum install java-17-amazon-corretto.x86_64 \
  amazon-cloudwatch-agent -y

{
  echo "MINECRAFT_VERSION=1.19.2"
  echo "S3_BUCKET=hiroshi-minecraft-servers-data"
  echo "BASE_PATH=/var/www/minecraft"
  echo "SERVER_DIRECTORY=/var/www/minecraft/server"
} >> /etc/environment
source /etc/environment

mkdir -p "$SERVER_DIRECTORY"
cd "$BASE_PATH" || exit

cat >start_server.sh <<__EOF__
#!/bin/bash -x

cd $SERVER_DIRECTORY
aws s3 cp s3://hiroshi-minecraft-servers-data/1.19.2/minecraft_server_1.19.2.zip .
unzip minecraft_server_1.19.2.zip
rm -fv minecraft_server_1.19.2.zip
java -Xms1024M -Xmx3584M -jar server.jar nogui
__EOF__

cat >s3_backup.sh <<__EOF__
#!/bin/bash -x

cd $SERVER_DIRECTORY
zip -r minecraft_server_$MINECRAFT_VERSION.zip .
aws s3 cp minecraft_server_$MINECRAFT_VERSION.zip s3://hiroshi-minecraft-servers-data/1.19.2/minecraft_server_$MINECRAFT_VERSION.zip
__EOF__

chmod +x start_server.sh
chmod +x s3_backup.sh

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-EC2MinecraftServerCWAgent -s

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
systemctl start minecraft.service
systemctl enable minecraft.service
