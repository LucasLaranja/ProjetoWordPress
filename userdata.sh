#!/bin/bash

set -euxo pipefail
exec > /var/log/user-data.log 2>&1

EFS_ID="fs-xxxxxxxxx"
REGIAO="us-east-1"
EFS_MOUNT_DIR="/mnt/efs"
DB_HOST="database-xxxxxxxxxxxxxxxxx"
DB_NAME="xxxxxxxxx"
DB_USER="xxxxxxxxx"
DB_PASSWORD="xxxxxxxxx"
PROJECT_DIR="/home/ec2-user/wordpress-docker"
DOCKER_COMPOSE_VERSION="v2.24.0"

sudo dnf update -y
sudo dnf install -y docker curl amazon-efs-utils

sudo curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

sudo mkdir -p ${EFS_MOUNT_DIR}
sudo mount -t nfs4 -o nfsvers=4.1 ${EFS_ID}.efs.${REGIAO}.amazonaws.com:/ ${EFS_MOUNT_DIR}
echo "${EFS_ID}.efs.${REGIAO}.amazonaws.com:/ ${EFS_MOUNT_DIR} nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab
sudo chown -R 33:33 ${EFS_MOUNT_DIR}

sudo mkdir -p ${PROJECT_DIR}
sudo chown ec2-user:ec2-user ${PROJECT_DIR}
cd ${PROJECT_DIR}

cat > .env <<EOF
WORDPRESS_DB_HOST=${DB_HOST}
WORDPRESS_DB_NAME=${DB_NAME}
WORDPRESS_DB_USER=${DB_USER}
WORDPRESS_DB_PASSWORD=${DB_PASSWORD}
EOF

cat > docker-compose.yml <<EOF
version: '3.7'
services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress
    restart: always
    ports:
      - "80:80"
    env_file:
      - .env
    volumes:
      - ${EFS_MOUNT_DIR}:/var/www/html
EOF

sudo docker-compose up -d
echo "WordPress iniciado em: $(date)" | sudo tee /var/log/wordpress-init.log
