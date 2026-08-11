# Basic configuration tests for the secure-s3-bucket module.
# These use command = plan so they run quickly without creating real resources.

variables {
  bucket_name = "test-secure-bucket-example-12345"
}

run "default_configuration" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.bucket == var.bucket_name
    error_message = "Bucket name did not match the provided variable."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "Public ACLs should be blocked by default."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == true
    error_message = "Public bucket policies should be blocked by default."
  }

  assert {
    condition     = length(aws_s3_bucket_versioning.this) == 1
    error_message = "Versioning should be enabled by default."
  }

  assert {
    condition     = length(aws_s3_bucket_server_side_encryption_configuration.this) == 1
    error_message = "Server-side encryption should be enabled by default."
  }
}

run "versioning_disabled" {
  command = plan

  variables {
    enable_versioning = false
  }

  assert {
    condition     = length(aws_s3_bucket_versioning.this) == 0
    error_message = "Versioning resource should not be created when enable_versioning is false."
  }
}

run "encryption_disabled" {
  command = plan

  variables {
    enable_encryption = false
  }

  assert {
    condition     = length(aws_s3_bucket_server_side_encryption_configuration.this) == 0
    error_message = "Encryption configuration should not be created when enable_encryption is false."
  }
}
