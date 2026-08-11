# Modules

Focused, reusable Terraform modules. Each module is designed to be:

- **Secure by default**
- Well-documented
- Tested with the Terraform Test framework
- Parameterized with sensible defaults for common use cases

## Available Modules

| Module | Description |
|--------|-------------|
| [secure-s3-bucket](./secure-s3-bucket) | Production-oriented S3 bucket (encryption, versioning, public access block, optional access logging) |

## Module Guidelines

- Keep modules small and focused on a single concern.
- Prefer clear input variables with descriptions and validation where useful.
- Always provide outputs that consumers actually need.
- Include a `README.md`, `versions.tf`, and at least one `.tftest.hcl`.
- Use semantic versioning via Git tags when releasing.
