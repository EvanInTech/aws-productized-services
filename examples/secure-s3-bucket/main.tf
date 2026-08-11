terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "secure_bucket" {
  source = "../../modules/secure-s3-bucket"

  bucket_name = "example-secure-bucket-change-me"

  tags = {
    Environment = "example"
    Project     = "aws-productized-services"
  }
}

output "bucket_arn" {
  value = module.secure_bucket.bucket_arn
}
