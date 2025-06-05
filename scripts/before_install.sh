#!/bin/bash
set -e

sudo mkdir -p /var/log/codedeploy
sudo touch /var/log/codedeploy/before-install.log
sudo chmod 664 /var/log/codedeploy/before-install.log
exec >/var/log/codedeploy/before-install.log 2>&1

echo "Starting before_install script..."

# Update the system
sudo yum update -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create application directory if it doesn't exist
APP_DIR="/home/ec2-user/fastapi-app"
mkdir -p $APP_DIR

# Clean up old containers and images to free space
echo "Cleaning up old Docker resources..."
docker system prune -f

echo "before_install completed successfully"