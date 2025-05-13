terraform {
  required_version = ">= 1.0"
  backend "s3" {
    bucket         = "terraform-backend-bucket-452271769418"
    key            = "state/app-infrastructure.tfstate"
    region         =  "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}