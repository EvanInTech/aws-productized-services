package main_test

import rego.v1

import data.main

# Paths passed to parse_config_file are relative to this file's directory.
#   conftest verify --policy policy/terraform --show-builtin-errors

no_violations if count(main.deny) == 0

has_prefix(prefix) if {
	some msg in main.deny
	startswith(msg, prefix)
}

secure_hcl := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
`

kms_hcl := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/example"
    }
  }
}
`

count_gated_hcl := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
`

missing_encryption_hcl := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}
`

encryption_without_algorithm_hcl := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = true
  }
}
`

unlinked_encryption_hcl := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "other" {
  bucket = "some-other-bucket"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
`

missing_public_access_block_hcl := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
`

public_access_template := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = %s
  block_public_policy     = %s
  ignore_public_acls      = %s
  restrict_public_buckets = %s
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
`

missing_versioning_hcl := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
`

suspended_versioning_hcl := `resource "aws_s3_bucket" "this" {
  bucket = "example"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
`

bare_bucket_hcl := `resource "aws_s3_bucket" "bare" {
  bucket = "example"
}
`

two_bucket_hcl := `resource "aws_s3_bucket" "good" {
  bucket = "good"
}

resource "aws_s3_bucket_public_access_block" "good" {
  bucket                  = aws_s3_bucket.good.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "good" {
  bucket = aws_s3_bucket.good.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "good" {
  bucket = aws_s3_bucket.good.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "bad" {
  bucket = "bad"
}
`

test_module_main_is_accepted if {
	no_violations with input as parse_config_file("../../modules/secure-s3-bucket/main.tf")
}

test_module_variables_are_accepted if {
	no_violations with input as parse_config_file("../../modules/secure-s3-bucket/variables.tf")
}

test_module_outputs_are_accepted if {
	no_violations with input as parse_config_file("../../modules/secure-s3-bucket/outputs.tf")
}

test_module_versions_are_accepted if {
	no_violations with input as parse_config_file("../../modules/secure-s3-bucket/versions.tf")
}

test_example_is_accepted if {
	no_violations with input as parse_config_file("../../examples/secure-s3-bucket/main.tf")
}

test_secure_configuration_is_accepted if {
	no_violations with input as parse_config("hcl2", secure_hcl)
}

test_kms_encryption_and_bucket_attribute_are_accepted if {
	no_violations with input as parse_config("hcl2", kms_hcl)
}

# Documents the static-analysis limit: count is not evaluated, so the declared
# status and sse_algorithm still satisfy the rules.
test_count_gated_resources_are_accepted if {
	no_violations with input as parse_config("hcl2", count_gated_hcl)
}

test_empty_input_is_accepted if {
	no_violations with input as {}
}

test_missing_encryption_is_rejected if {
	cfg := parse_config("hcl2", missing_encryption_hcl)
	violations := main.deny with input as cfg
	count(violations) == 1
	has_prefix("S3-ENCRYPTION:") with input as cfg
}

test_encryption_without_algorithm_is_rejected if {
	cfg := parse_config("hcl2", encryption_without_algorithm_hcl)
	violations := main.deny with input as cfg
	count(violations) == 1
	some msg in violations
	contains(msg, "sse_algorithm")
}

test_encryption_for_a_different_bucket_is_rejected if {
	cfg := parse_config("hcl2", unlinked_encryption_hcl)
	violations := main.deny with input as cfg
	count(violations) == 1
	some msg in violations
	contains(msg, "aws_s3_bucket.this")
	startswith(msg, "S3-ENCRYPTION:")
}

test_missing_public_access_block_is_rejected if {
	cfg := parse_config("hcl2", missing_public_access_block_hcl)
	violations := main.deny with input as cfg
	count(violations) == 1
	has_prefix("S3-PUBLIC-ACCESS-BLOCK:") with input as cfg
}

test_block_public_acls_false_is_rejected if {
	cfg := parse_config("hcl2", sprintf(public_access_template, ["false", "true", "true", "true"]))
	violations := main.deny with input as cfg
	count(violations) == 1
	some msg in violations
	contains(msg, "must set block_public_acls to true")
}

test_block_public_policy_false_is_rejected if {
	cfg := parse_config("hcl2", sprintf(public_access_template, ["true", "false", "true", "true"]))
	violations := main.deny with input as cfg
	count(violations) == 1
	some msg in violations
	contains(msg, "must set block_public_policy to true")
}

test_ignore_public_acls_false_is_rejected if {
	cfg := parse_config("hcl2", sprintf(public_access_template, ["true", "true", "false", "true"]))
	violations := main.deny with input as cfg
	count(violations) == 1
	some msg in violations
	contains(msg, "must set ignore_public_acls to true")
}

test_restrict_public_buckets_false_is_rejected if {
	cfg := parse_config("hcl2", sprintf(public_access_template, ["true", "true", "true", "false"]))
	violations := main.deny with input as cfg
	count(violations) == 1
	some msg in violations
	contains(msg, "must set restrict_public_buckets to true")
}

test_public_access_string_true_is_rejected if {
	cfg := parse_config("hcl2", sprintf(public_access_template, ["\"true\"", "true", "true", "true"]))
	violations := main.deny with input as cfg
	count(violations) == 1
	some msg in violations
	contains(msg, "must set block_public_acls to true")
}

test_missing_versioning_is_rejected if {
	cfg := parse_config("hcl2", missing_versioning_hcl)
	violations := main.deny with input as cfg
	count(violations) == 1
	has_prefix("S3-VERSIONING:") with input as cfg
}

test_suspended_versioning_is_rejected if {
	cfg := parse_config("hcl2", suspended_versioning_hcl)
	violations := main.deny with input as cfg
	count(violations) == 1
	some msg in violations
	contains(msg, "versioning_configuration.status to \"Enabled\"")
}

test_bare_bucket_violates_every_rule if {
	cfg := parse_config("hcl2", bare_bucket_hcl)
	violations := main.deny with input as cfg
	count(violations) == 3
	has_prefix("S3-ENCRYPTION:") with input as cfg
	has_prefix("S3-PUBLIC-ACCESS-BLOCK:") with input as cfg
	has_prefix("S3-VERSIONING:") with input as cfg
}

test_sibling_bucket_is_not_blamed if {
	violations := main.deny with input as parse_config("hcl2", two_bucket_hcl)
	count(violations) == 3
	every msg in violations {
		contains(msg, "aws_s3_bucket.bad")
		not contains(msg, "aws_s3_bucket.good")
	}
}

test_insecure_fixture_violates_every_rule if {
	cfg := parse_config_file("../tests/insecure_s3_bucket.tf")
	violations := main.deny with input as cfg
	has_prefix("S3-ENCRYPTION:") with input as cfg
	has_prefix("S3-PUBLIC-ACCESS-BLOCK:") with input as cfg
	has_prefix("S3-VERSIONING:") with input as cfg
	every setting in {"block_public_acls", "block_public_policy", "ignore_public_acls", "restrict_public_buckets"} {
		some msg in violations
		contains(msg, sprintf("must set %s to true", [setting]))
	}
	some msg in violations
	contains(msg, "status to \"Enabled\"")
}
