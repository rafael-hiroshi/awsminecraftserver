#! /bin/bash

yum update -y
yum install java-17-amazon-corretto.x86_64 \
  amazon-cloudwatch-agent -y

{
  echo "MINECRAFT_VERSION=1.19.2"
  echo "S3_BUCKET=hiroshi-minecraft-servers-data"
  echo "SERVER_BASE_PATH=/var/www/minecraft"
} >> /etc/environment
source /etc/environment

mkdir -p "$SERVER_BASE_PATH"
cd "$SERVER_BASE_PATH" || exit

cat >start_server.sh <<__EOF__
#!/bin/bash -x

java -Xms1024M -Xmx3584M -jar server.jar nogui
__EOF__

cat >s3_backup.sh <<__EOF__
#!/bin/bash -x

cd $SERVER_BASE_PATH
zip -r minecraft_server_$MINECRAFT_VERSION.zip .
aws s3 cp minecraft_server_$MINECRAFT_VERSION.zip s3://hiroshi-minecraft-servers-data/1.19.2/minecraft_server_$MINECRAFT_VERSION.zip
__EOF__

chmod +x start_server.sh
chmod +x s3_backup.sh
