#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io postgresql-client-common postgresql-client-12 -y

sudo mkdir -p /etc/acg-app/config

cat <<EOF | sudo tee /etc/acg-app/config/database.ini
[postgresql]
host=${postgresql_host}
database=${postgresql_database}
user=${postgresql_username}
password=${postgresql_password}
EOF

# Install sql procedure
curl ${postgresql_init_script_url} -o install.sql
export PGPASSWORD="${postgresql_password}"
psql -h ${postgresql_host} -U ${postgresql_username} -f install.sql ${postgresql_database}

sudo docker run -d -p 80:5000 -v /etc/acg-app/config:/usr/src/app/config --restart always --name acg-app ghcr.io/arcezd/elastic-cache-challenge:v1