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

## Terraform Foundation

Terraform is implemented for `dev` only. The default and only supported cloud environment is currently:

- environment: `dev`
- region: `us-central1`
- compute: four Cloud Run v2 services with `min_instances = 0`

Do not apply prod. The `environments/prod` directory is a placeholder only and intentionally contains no runnable Terraform.

### Dev Commands

```sh
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your GCP `project_id` and service container images, then run:

```sh
terraform init
terraform fmt -recursive ../..
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

On Windows, if Terraform is not installed globally, use the repo-local binary from the repo root when present:

```powershell
.\.tools\terraform\terraform.exe -chdir=environments/dev init
.\.tools\terraform\terraform.exe fmt -recursive
.\.tools\terraform\terraform.exe -chdir=environments/dev validate
.\.tools\terraform\terraform.exe -chdir=environments/dev plan -var-file=terraform.tfvars
```

Only run `terraform apply` for dev when you intentionally need cloud resources for an interview, final demo, screenshots, or traces.

To run the local foundation checks:

```powershell
.\scripts\test-terraform-foundation.ps1
```

### Cost Guardrails

- Cloud Run `min_instances` must remain `0`.
- Cloud Run `max_instances` is variable-driven and defaults to `1`.
- Only `us-central1` is allowed.
- Dev defines `throughball-platform-api`, `throughball-ai-runtime`, `throughball-mcp-server`, and `throughball-worker`.
- The worker has no implicit scheduler, Pub/Sub trigger, or continuously running trigger.
- No BigQuery datasets are created.
- No Vertex Vector Search resources are created.
- No Cloud SQL instances are created.
- No always-on VMs are created.
- Secret values and secret versions are not managed in Terraform state.
