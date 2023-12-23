#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt-get install gnupg curl
sudo wget -qO- https://pgp.mongodb.com/server-6.0.asc | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/mongodb-server-6.0.gpg
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

wget -q https://artifacts.elastic.co/GPG-KEY-elasticsearch -O myKey
sudo apt-key add myKey
echo "deb https://artifacts.elastic.co/packages/oss-7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install elasticsearch-oss

sudo tee -a /etc/elasticsearch/elasticsearch.yml > /dev/null <<EOT
cluster.name: graylog
action.auto_create_index: false
EOT

sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service
# Make sure that the graylog is running!
sudo systemctl --type=service --state=active | grep elasticsearch

wget https://packages.graylog2.org/repo/packages/graylog-5.0-repository_latest.deb
sudo dpkg -i graylog-5.0-repository_latest.deb
sudo apt-get update && sudo apt-get install graylog-server 

wget https://packages.graylog2.org/repo/packages/graylog-5.0-repository_latest.deb
sudo dpkg -i graylog-5.0-repository_latest.deb
sudo apt-get update && sudo apt-get install graylog-enterprise

PASSWORD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c${1:-96};echo;)

echo "Generated password: $PASSWORD"

HASH=$(echo $PASSWORD | sha256sum | cut -d" " -f1)

echo "Generated hash: $HASH"

sed -i "s/password_secret =/password_secret = $PASSWORD/" /etc/graylog/server/server.conf
sed -i "s/root_password_sha2 =/root_password_sha2 = $HASH/" /etc/graylog/server/server.conf

sudo systemctl daemon-reload
sudo systemctl enable graylog-server.service
sudo systemctl start graylog-server.service
sudo systemctl --type=service --state=active | grep graylog