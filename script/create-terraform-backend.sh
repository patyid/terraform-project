#!/bin/bash
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=



AWS_REGION="us-east-1"
BACKEND_BUCKET="terraform-backend-bucket-452271769418"

# Create S3 Bucket for Terraform State
echo "Creating S3 bucket: $BACKEND_BUCKET..."
aws s3api create-bucket --bucket "$BACKEND_BUCKET" --region "$AWS_REGION"

echo "Backend infrastructure created successfully!"
