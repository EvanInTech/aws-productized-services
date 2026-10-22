# Policy as code

Conftest evaluates the Rego policies in [`policy/terraform`](terraform) against Terraform HCL. The `Policy as Code` CI job fails when a `.tf` file under `modules/`, `examples/`, or `products/` violates a rule. `products/` has no `.tf` files today. Conftest only parses HCL: the job uses no AWS credentials, secrets, or OIDC.

CI pins [Conftest 0.71.1](https://github.com/open-policy-agent/conftest/releases/tag/v0.71.1) and the `hcl2` parser. Each `.tf` file is evaluated on its own, so a bucket and the resources that protect it must be declared in the same file. A control counts only when its `bucket` argument references `aws_s3_bucket.<name>.id` or `aws_s3_bucket.<name>.bucket`.

The parser does not evaluate Terraform variables, `count`, or `dynamic` blocks. `modules/secure-s3-bucket` gates encryption and versioning with `count = var.enable_* ? 1 : 0`. Those resources are still declared with `sse_algorithm = "AES256"` and `status = "Enabled"`, so these policies pass. A caller can still set `enable_encryption` or `enable_versioning` to false; this gate does not see that choice.

## Rules

### S3-ENCRYPTION

Every `aws_s3_bucket` must have an `aws_s3_bucket_server_side_encryption_configuration` in the same file that sets `rule.apply_server_side_encryption_by_default.sse_algorithm` to a non-empty string. `AES256` and `aws:kms` both pass. A missing configuration, an empty algorithm, or a configuration that points at a different bucket fails.

### S3-PUBLIC-ACCESS-BLOCK

Every bucket must have an `aws_s3_bucket_public_access_block` that sets all four of these attributes to the boolean `true`:

- `block_public_acls`
- `block_public_policy`
- `ignore_public_acls`
- `restrict_public_buckets`

`false`, a missing attribute, or the string `"true"` fails.

### S3-VERSIONING

Every bucket must have an `aws_s3_bucket_versioning` whose `versioning_configuration.status` is `"Enabled"`. A missing resource or `"Suspended"` fails.

Files with no `aws_s3_bucket` pass. `examples/secure-s3-bucket` only calls the module, so it passes until someone declares a bucket resource there.

## Run locally

Install Conftest 0.71.1, the version CI pins, and run these commands from the repository root.

```bash
version=0.71.1
archive="conftest_${version}_Linux_x86_64.tar.gz"
curl -fsSL -o "$archive" "https://github.com/open-policy-agent/conftest/releases/download/v${version}/${archive}"
# linux/amd64 sha256: c3f6b2a753bd56e377a1e51a95ae3e057f926f2e9139f7d5b5dfbbaf810f7985
tar -xzf "$archive" conftest

find modules examples products -type f -name '*.tf' -print0 \
  | sort -z \
  | xargs -0 ./conftest test --parser hcl2 --no-color --policy policy/terraform

./conftest verify --policy policy/terraform --show-builtin-errors

# This must exit 1. The fixture is rejected on purpose.
./conftest test --parser hcl2 --policy policy/terraform policy/tests/insecure_s3_bucket.tf
```

`policy/tests/insecure_s3_bucket.tf` is the negative fixture: no server-side encryption, Block Public Access left open, and versioning suspended. Unit tests in `policy/terraform/s3_test.rego` cover each rule. Paths passed to `parse_config_file` are relative to that test file.

The fixture carries resource-scoped `#trivy:ignore` comments so the existing Trivy job does not treat it as deployable infrastructure. Those ignores do not apply to `modules/` or `examples/`.
