# throughball-infra

Infrastructure repo for local-first demo development.

## Scope

- Terraform
- Cloud Run deployment
- Docker
- IAM
- observability infrastructure
- deployment automation

## Development Principles

- Keep local development as the default.
- Do not provision always-on infrastructure by default.
- Do not add paid SaaS tools by default.
- Do not add hosted observability tools by default.
- Cloud deployment should be explicit and demo-driven.

## Getting Started

```sh
cp .env.example .env
```

Add implementation-specific setup commands as infrastructure choices are introduced.
