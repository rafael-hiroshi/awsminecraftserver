#!/bin/bash

cd /home/ec2-user/server/
zip -r minecraft_vanilla_server_1.19.2.zip .
aws s3 cp minecraft_vanilla_server_1.19.2.zip s3://hiroshi-minecraft-servers-data/1.19.2/minecraft_vanilla_server_1.19.2.zip
