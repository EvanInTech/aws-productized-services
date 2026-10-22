# AWS Productized Services

**Productized, tested Terraform modules and ready-to-use solutions** for common AWS pain points.

This monorepo is a living portfolio of reusable Infrastructure as Code focused on reliability, security-by-default, and clear productization. Each solution is designed so it can be consumed as a module, deployed as a complete product, or delivered as an implementation service.

## Goals

- High-quality, opinionated modules for frequent AWS needs (CI/CD, WAF, networking, storage, observability, etc.)
- Strong testing (static analysis + Terraform Test + LocalStack where practical)
- Clear documentation that doubles as a service catalog
- Secure defaults aligned with modern best practices and compliance thinking

## Repository Structure

```
.
├── modules/          # Focused, reusable Terraform modules
├── products/         # Composed, opinionated solutions ready for use
├── examples/         # Minimal working examples
├── docs/             # Architecture notes, ADRs, design decisions
└── .github/          # CI workflows for linting, validation, and tests
```

## Current Modules

| Module | Status | Description |
|--------|--------|-------------|
| [secure-s3-bucket](modules/secure-s3-bucket) | Starter | Production-oriented S3 bucket with encryption, versioning, public access block, and optional logging |
| *cicd-pipeline* | Planned | Opinionated CodePipeline + CodeBuild with OIDC, quality gates, and notifications |
| *waf-v2* | Planned | WAFv2 with managed rule groups, logging, and common associations |
| *secure-vpc* | Planned | VPC with public/private subnets, flow logs, and secure defaults |

## Products (Composed Solutions)

Coming soon — higher-level compositions that solve end-to-end pain points (e.g. secure static website, enterprise CI/CD starter, etc.).

## Testing Philosophy

We use a layered approach:

1. **Static** — `terraform fmt`, `validate`, tflint, Checkov/tfsec
2. **Configuration tests** — Native Terraform Test framework (`.tftest.hcl`) with plan assertions
3. **Integration** — LocalStack for fast local/CI feedback + selective real-AWS ephemeral tests where needed

Every module should ship with tests from day one.

## Security gates

CI scans the Terraform under `modules/` and `examples/` with [Trivy](https://github.com/aquasecurity/trivy) config mode. The job fails on HIGH or CRITICAL misconfigurations and uploads a SARIF report to the GitHub Security tab. Suppress a finding only with a resource-scoped `#trivy:ignore:<id>` comment and a one-line justification immediately above it.
CI also evaluates the Rego policies in [`policy/terraform`](policy/terraform) with [Conftest](https://www.conftest.dev/) (HCL2 parser) and fails on violations; see [policy/README.md](policy/README.md).

Every action under [`.github/workflows`](.github/workflows) is pinned to a full commit SHA, with the release tag in a trailing comment. [Dependabot](.github/dependabot.yml) opens weekly pull requests for the `github-actions` ecosystem and for the Terraform providers in `modules/secure-s3-bucket` and `examples/secure-s3-bucket`.
Each CI run generates a source SBOM with [Syft](https://github.com/anchore/syft) (`anchore/sbom-action`, Syft v1.54.0) and uploads `sbom.spdx.json` as a workflow artifact. The job has `contents: read` only: it checks out the repo and uploads the artifact, and it does not use AWS credentials, secrets, or OIDC.

## Getting Started

```bash
git clone https://github.com/EvanInTech/aws-productized-services.git
cd aws-productized-services

# Example: explore the secure S3 module
cd modules/secure-s3-bucket
terraform init
terraform test
```

## Roadmap (Initial)

- [x] Repository scaffolding + CI skeleton
- [x] First module: secure-s3-bucket (with tests)
- [ ] Second module: basic CI/CD pipeline
- [ ] First product composition
- [ ] LocalStack integration in CI
- [ ] Additional modules (WAF, VPC patterns, observability)

## License

MIT — see [LICENSE](LICENSE).

---

Built as a professional portfolio of productized AWS infrastructure solutions.
