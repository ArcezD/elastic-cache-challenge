#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y

sudo mkdir -p /etc/acg-app/config

cat <<EOF | sudo tee /etc/acg-app/config/database.ini
[postgresql]
host=${postgresql_host}
database=${postgresql_database}
user=${postgresql_username}
password=${postgresql_password}
EOF

sudo docker run -d -p 80:5000 -v /etc/acg-app/config:/usr/src/app/config --restart always --name acg-app ghcr.io/arcezd/elastic-cache-challenge:v1