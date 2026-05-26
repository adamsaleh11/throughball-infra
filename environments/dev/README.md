# Dev Terraform Environment

This is the only implemented Terraform environment. It is constrained to `us-central1` and keeps Cloud Run scaled to zero when idle.

## Commands

```sh
cd environments/dev
terraform init
terraform fmt -recursive ../..
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

On Windows, if Terraform is not installed globally, run the repo-local binary from the repo root when present:

```powershell
.\.tools\terraform\terraform.exe -chdir=environments/dev init
.\.tools\terraform\terraform.exe fmt -recursive
.\.tools\terraform\terraform.exe -chdir=environments/dev validate
.\.tools\terraform\terraform.exe -chdir=environments/dev plan -var-file=terraform.tfvars
```

Copy `terraform.tfvars.example` to `terraform.tfvars`, then set `project_id` and each service image before planning or applying.

## Cloud Run Services

Dev defines four Cloud Run services:

- `throughball-platform-api`
- `throughball-ai-runtime`
- `throughball-mcp-server`
- `throughball-worker`

The worker is only a scale-to-zero service definition. Terraform does not create a scheduler, Pub/Sub trigger, or any other continuously running worker trigger.

## Cost Guardrails

- `min_instances` must remain `0`.
- `max_instances` defaults to `1`.
- No prod resources are implemented here.
- No BigQuery datasets, Vertex Vector Search, Cloud SQL, or always-on VMs are created.
- Secret values and secret versions are not managed by Terraform.
