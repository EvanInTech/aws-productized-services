package main

import rego.v1

# Static checks for S3 buckets declared in a single Terraform file.
# Conftest's hcl2 parser does not evaluate variables or count, so a resource
# still counts as declared when it is gated by count = var.enable_* ? 1 : 0.
# Companion resources must reference the bucket as aws_s3_bucket.<name>.id
# or aws_s3_bucket.<name>.bucket in the same file.

public_access_block_settings := {
	"block_public_acls",
	"block_public_policy",
	"ignore_public_acls",
	"restrict_public_buckets",
}

resources_of_type(type) := object.get(object.get(input, "resource", {}), type, {})

resource_refs_bucket(resource_body, bucket_name) if {
	object.get(resource_body, "bucket", "") == sprintf("${aws_s3_bucket.%s.id}", [bucket_name])
}

resource_refs_bucket(resource_body, bucket_name) if {
	object.get(resource_body, "bucket", "") == sprintf("${aws_s3_bucket.%s.bucket}", [bucket_name])
}

has_typed_resource(type, bucket_name) if {
	some _, bodies in resources_of_type(type)
	some resource_body in bodies
	resource_refs_bucket(resource_body, bucket_name)
}

encryption_configured(enc) if {
	some rule in object.get(enc, "rule", [])
	some algo in object.get(rule, "apply_server_side_encryption_by_default", [])
	sse := object.get(algo, "sse_algorithm", "")
	is_string(sse)
	sse != ""
}

setting_is_true(block, setting) if {
	block[setting] == true
}

versioning_enabled(ver) if {
	some cfg in object.get(ver, "versioning_configuration", [])
	object.get(cfg, "status", "") == "Enabled"
}

# S3-ENCRYPTION: every bucket needs a server-side encryption configuration
# whose rule sets sse_algorithm. Any non-empty algorithm (AES256 or aws:kms)
# satisfies the rule.

deny contains msg if {
	some bucket_name, _ in resources_of_type("aws_s3_bucket")
	not has_typed_resource("aws_s3_bucket_server_side_encryption_configuration", bucket_name)
	msg := sprintf("S3-ENCRYPTION: aws_s3_bucket.%s must have server-side encryption configured via aws_s3_bucket_server_side_encryption_configuration", [bucket_name])
}

deny contains msg if {
	some bucket_name, _ in resources_of_type("aws_s3_bucket")
	some enc_name, bodies in resources_of_type("aws_s3_bucket_server_side_encryption_configuration")
	some enc in bodies
	resource_refs_bucket(enc, bucket_name)
	not encryption_configured(enc)
	msg := sprintf("S3-ENCRYPTION: aws_s3_bucket_server_side_encryption_configuration.%s for aws_s3_bucket.%s must set rule.apply_server_side_encryption_by_default.sse_algorithm", [enc_name, bucket_name])
}

# S3-PUBLIC-ACCESS-BLOCK: all four Block Public Access flags must be the
# boolean true on aws_s3_bucket_public_access_block.

deny contains msg if {
	some bucket_name, _ in resources_of_type("aws_s3_bucket")
	not has_typed_resource("aws_s3_bucket_public_access_block", bucket_name)
	msg := sprintf("S3-PUBLIC-ACCESS-BLOCK: aws_s3_bucket.%s must set block_public_acls, block_public_policy, ignore_public_acls, and restrict_public_buckets to true", [bucket_name])
}

deny contains msg if {
	some bucket_name, _ in resources_of_type("aws_s3_bucket")
	some pab_name, bodies in resources_of_type("aws_s3_bucket_public_access_block")
	some pab in bodies
	resource_refs_bucket(pab, bucket_name)
	some setting in public_access_block_settings
	not setting_is_true(pab, setting)
	msg := sprintf("S3-PUBLIC-ACCESS-BLOCK: aws_s3_bucket_public_access_block.%s for aws_s3_bucket.%s must set %s to true", [pab_name, bucket_name, setting])
}

# S3-VERSIONING: aws_s3_bucket_versioning must set status to "Enabled".
# "Suspended" and a missing versioning resource are both violations.

deny contains msg if {
	some bucket_name, _ in resources_of_type("aws_s3_bucket")
	not has_typed_resource("aws_s3_bucket_versioning", bucket_name)
	msg := sprintf("S3-VERSIONING: aws_s3_bucket.%s must have versioning enabled via aws_s3_bucket_versioning", [bucket_name])
}

deny contains msg if {
	some bucket_name, _ in resources_of_type("aws_s3_bucket")
	some ver_name, bodies in resources_of_type("aws_s3_bucket_versioning")
	some ver in bodies
	resource_refs_bucket(ver, bucket_name)
	not versioning_enabled(ver)
	msg := sprintf("S3-VERSIONING: aws_s3_bucket_versioning.%s for aws_s3_bucket.%s must set versioning_configuration.status to \"Enabled\"", [ver_name, bucket_name])
}
