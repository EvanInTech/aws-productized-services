# Negative fixture for policy/terraform. Conftest must reject this file.
# It is not a module and must not be applied. It stays non-compliant on purpose:
# no server-side encryption, Block Public Access left open, versioning suspended.
#
# The Trivy ignores below are only here so this fixture does not fail the IaC
# scan. They do not apply to modules or examples. Conftest still denies the file.

# Negative Conftest fixture, not a deployable bucket, so the missing customer-managed key is intentional.
#trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket" "insecure" {
  bucket = "insecure-fixture-do-not-apply"
}

# Negative Conftest fixture, not a deployable bucket. AWS-0086, AWS-0087, AWS-0091, and AWS-0093 are intentional so the policy gate must reject this file.
#trivy:ignore:AVD-AWS-0086
#trivy:ignore:AVD-AWS-0087
#trivy:ignore:AVD-AWS-0091
#trivy:ignore:AVD-AWS-0093
resource "aws_s3_bucket_public_access_block" "insecure" {
  bucket = aws_s3_bucket.insecure.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "insecure" {
  bucket = aws_s3_bucket.insecure.id

  versioning_configuration {
    status = "Suspended"
  }
}
