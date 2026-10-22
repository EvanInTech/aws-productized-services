# Products

Opinionated, composed solutions built from the modules in this repository.

This folder has no Terraform yet (this README only). CI still walks `products/` for `.tf` files, and Trivy does not skip the directory. A product directory that contains `.tf` files is formatted, validated, tested, scanned, and checked by Conftest the same way as a module or example. See [Security pipeline](../docs/security-pipeline.md). Dependabot does not update this folder until a product directory exists and `.github/dependabot.yml` includes `/products/*`.

These are the higher-level “productized” offerings — ready-to-deploy patterns that solve a complete common pain point rather than a single resource type.

Examples of planned products:

- Secure static website (S3 + CloudFront + WAF + HTTPS)
- Enterprise CI/CD starter (pipeline + quality gates + OIDC + notifications)
- Observability baseline
- Secure multi-tier application networking

Each product should include:

- Clear problem statement and target audience
- Architecture overview
- Required inputs and recommended defaults
- Deployment example
- Security and cost notes
