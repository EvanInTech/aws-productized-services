terraform {
  # tests/basic.tftest.hcl uses mock_provider, added in Terraform 1.7.0.
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
