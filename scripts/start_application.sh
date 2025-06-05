#!/bin/bash
set -e

# Log all output
exec > >(tee -a /var/log/codedeploy-start.log) 2>&1

APP_DIR="/home/ec2-user/fastapi-app"

echo "Starting application deployment..."

# Source environment variables from CodeBuild artifacts
if [ -f "${APP_DIR}/deployment.env" ]; then
    echo "Loading environment variables from deployment.env..."
    source ${APP_DIR}/deployment.env
    echo "Loaded variables:"
    echo "  ECR_REPOSITORY_URL: $ECR_REPOSITORY_URL"
    echo "  IMAGE_TAG: $IMAGE_TAG"
    echo "  AWS_REGION: $AWS_REGION"
else
    echo "Warning: deployment.env not found, using fallback values"
    # Fallback to environment variables from appspec.yml
    AWS_REGION=${AWS_DEFAULT_REGION:-"ap-southeast-1"}
    ECR_REPOSITORY_URL=${ECR_REPOSITORY_URL:-""}
fi

# Validate required variables
if [ -z "$ECR_REPOSITORY_URL" ]; then
    echo "Error: ECR_REPOSITORY_URL is not set"
    exit 1
fi

# Fetch configuration from Parameter Store
# echo "Fetching configuration from Parameter Store..."
# DB_HOST=$(
#     aws ssm get-parameter --name "/${PROJECT_NAME}/${ENVIRONMENT}/database/url" \
#         --with-decryption --query "Parameter.Value" --output text
# )
# DB_USER=$(
#     aws ssm get-parameter --name "/${PROJECT_NAME}/${ENVIRONMENT}/database/user" \
#         --with-decryption --query "Parameter.Value" --output text
# )
# DB_PASSWORD=$(
#     aws ssm get-parameter --name "/${PROJECT_NAME}/${ENVIRONMENT}/database/password" \
#         --with-decryption --query "Parameter.Value" --output text
# )
# DB_NAME=$(
#     aws ssm get-parameter --name "/${PROJECT_NAME}/${ENVIRONMENT}/database/name" \
#         --with-decryption --query "Parameter.Value" --output text
# )

# # Create/update .env file
# echo "Creating .env file..."
# cat <<EOF >${APP_DIR}/.env
# DATABASE_URL=postgresql+psycopg2://$DB_USER:$DB_PASSWORD@$DB_HOST:5432/$DB_NAME
# EOF

# ECR Authentication
echo "Authenticating with ECR..."
aws ecr get-login-password --region ${AWS_REGION} | \
    docker login --username AWS --password-stdin $(echo $ECR_REPOSITORY_URL | cut -d':' -f1)

# Start application
echo "Starting application with Docker Compose..."
echo "Using image: $ECR_REPOSITORY_URL"
cd ${APP_DIR}

# Export variables for docker-compose
export ECR_REPOSITORY_URL
export IMAGE_TAG

docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# Verify services are running
echo "Verifying services..."
if ! docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
    echo "Error: Services failed to start"
    docker-compose -f docker-compose.prod.yml logs
    exit 1
fi

# Verify SSM agent and Docker are running
echo "Verifying system services..."
sudo systemctl status amazon-ssm-agent --no-pager || true
sudo systemctl status docker --no-pager || true

echo "Application started successfully"