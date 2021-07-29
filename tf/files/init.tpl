#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y

sudo mkdir -p /etc/acg-app/config

cat <<EOF | sudo tee /etc/acg-app/config/database.ini
[postgresql]
host=${postgresql_host}
database=edu
user=edu
password=65e671f5-46b4-4ff2-a0a0-2bda570972a2
EOF

sudo docker run -d -p 80:5000 -v /etc/acg-app/config:/usr/src/app/config --restart always --name acg-app ghcr.io/arcezd/elastic-cache-challenge:v1