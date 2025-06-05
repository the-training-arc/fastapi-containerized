#!/bin/bash
set -e

sudo mkdir -p /var/log/codedeploy
sudo touch /var/log/codedeploy/stop-application.log
sudo chmod 664 /var/log/codedeploy/stop-application.log
exec >/var/log/codedeploy/stop-application.log 2>&1

APP_DIR="/home/ec2-user/fastapi-app"

echo "Stopping application..."

# Stop application if docker-compose file exists
if [ -f "${APP_DIR}/docker-compose.prod.yml" ]; then
    cd ${APP_DIR}
    docker-compose -f docker-compose.prod.yml down
else
    echo "No docker-compose file found, stopping any running containers..."
    running_containers=$(docker ps -q)
    if [ ! -z "$running_containers" ]; then
        docker stop $running_containers
    fi
fi

echo "Application stopped successfully"