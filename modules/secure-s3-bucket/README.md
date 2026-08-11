# Secure S3 Bucket Module

A production-oriented S3 bucket module with secure defaults:

- Public access blocked
- Versioning enabled by default
- Server-side encryption (SSE-S3 / AES256) enabled by default
- BucketOwnerEnforced ownership controls
- Common tags applied

## Usage

```hcl
module "secure_bucket" {
  source = "../../modules/secure-s3-bucket"   # or git source + tag

  bucket_name = "my-unique-app-artifacts-prod"

  tags = {
    Environment = "prod"
    Application = "my-app"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket. Must be globally unique. | `string` | n/a | yes |
| enable_versioning | Enable versioning on the bucket. | `bool` | `true` | no |
| enable_encryption | Enable server-side encryption (SSE-S3). | `bool` | `true` | no |
| force_destroy | Allow Terraform to destroy the bucket even if it contains objects. | `bool` | `false` | no |
| tags | Additional tags to apply to the bucket. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the bucket. |
| bucket_arn | The ARN of the bucket. |
| bucket_domain_name | The bucket domain name. |
| bucket_regional_domain_name | The bucket region-specific domain name. |

## Testing

```bash
cd modules/secure-s3-bucket
terraform init
terraform test
```

The included tests use `command = plan` so they run quickly without creating real resources.
