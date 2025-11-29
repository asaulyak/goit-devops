#!/bin/bash

set -e

# Отримуємо AWS регіон та ECR URL з Terraform outputs
# Переконайтеся, що ви знаходитесь в директорії lesson-7
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$PROJECT_DIR/.." && pwd)"

echo "Getting ECR repository URL from Terraform..."
cd "$PROJECT_DIR"

# Отримуємо ECR URL та регіон
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null || echo "")
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-west-2")

if [ -z "$ECR_URL" ]; then
    echo "Error: Could not get ECR repository URL from Terraform outputs."
    echo "Please run 'terraform apply' first to create the ECR repository."
    exit 1
fi

echo "ECR Repository URL: $ECR_URL"
echo "AWS Region: $AWS_REGION"

# Авторизуємося в ECR
echo "Authenticating with ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_URL"

# Переходимо до кореневої директорії проєкту (де знаходиться Dockerfile)
echo "Building Docker image..."
cd "$ROOT_DIR"

# Побудова образу
docker build -t django-app:latest .

# Тегуємо образ для ECR
echo "Tagging image for ECR..."
docker tag django-app:latest "$ECR_URL:latest"

# Завантажуємо образ до ECR
echo "Pushing image to ECR..."
docker push "$ECR_URL:latest"

echo "Successfully pushed django-app:latest to $ECR_URL"

