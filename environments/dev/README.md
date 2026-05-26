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

Copy `terraform.tfvars.example` to `terraform.tfvars` and set `project_id` and `container_image` before planning or applying.

## Cost Guardrails

- `min_instances` must remain `0`.
- `max_instances` defaults to `2`.
- No prod resources are implemented here.
- No BigQuery datasets, Vertex Vector Search, Cloud SQL, or always-on VMs are created.
- Secret values are not managed by Terraform.
