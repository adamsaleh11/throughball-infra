# Plan: Terraform Foundation for GCP Deployment

> Source PRD: `docs/prds/terraform-foundation.md`

## Architectural decisions

Durable decisions that apply across all phases:

- **Environment model**: Dev is the only implemented Terraform environment. Staging and prod are placeholders only.
- **Region**: All implemented GCP resources are constrained to `us-central1`.
- **State**: The first foundation uses local Terraform state. Remote backend setup is out of scope.
- **Cloud runtime**: Cloud Run v2 is the deployment target and must scale to zero.
- **Scaling policy**: `min_instances` and `max_instances` are Terraform variables. `min_instances` defaults to `0` and nonzero values are rejected.
- **Artifact storage**: Dev uses a single Artifact Registry Docker repository.
- **Identity**: Cloud Run runs as a dedicated runtime service account with minimal runtime permissions.
- **Secrets**: Terraform may create secret containers but must not manage secret values or versions.
- **Observability**: Observability is lightweight and limited to low-cost runtime support for logs, metrics, and traces.
- **Excluded services**: No BigQuery datasets, Vertex Vector Search, Cloud SQL, always-on VMs, hosted observability products, dashboards, alerts, or prod resources.

---

## Phase 1: Safe Terraform Skeleton

**User stories**: 1, 2, 3, 4, 5, 19, 20

### What to build

Create the Terraform directory structure and the dev environment shell with provider constraints, required variables, region validation, consistent labels, and clear staging/prod placeholders. Establish the local-first baseline without creating expensive service resources yet.

### Acceptance criteria

- [ ] The repo contains environment directories for dev, staging, and prod.
- [ ] The repo contains module directories for Cloud Run, secrets, IAM, Artifact Registry, and observability.
- [ ] Dev has Terraform provider and version constraints.
- [ ] Dev requires `project_id`.
- [ ] Dev defaults to `us-central1` and rejects other regions.
- [ ] Staging and prod contain warning documentation only, not runnable infrastructure.
- [ ] Prod documentation clearly warns not to apply prod.

---

## Phase 2: Dev Artifact And Runtime Identity

**User stories**: 10, 11, 12, 19

### What to build

Add the first complete dev infrastructure slice: required API enablement, Artifact Registry, a dedicated Cloud Run runtime service account, and minimal runtime permissions. This creates the foundation Cloud Run will depend on without deploying the service yet.

### Acceptance criteria

- [ ] Dev enables only the GCP APIs required by the foundation.
- [ ] Dev creates one Docker Artifact Registry repository in `us-central1`.
- [ ] Dev creates a dedicated runtime service account for Cloud Run.
- [ ] Runtime IAM avoids broad editor, owner, or project-wide administrative roles.
- [ ] Resource names and labels include the app and dev environment identity.

---

## Phase 3: Scale-To-Zero Cloud Run

**User stories**: 6, 7, 8, 9, 10, 11, 15

### What to build

Add the Cloud Run v2 module and connect it to the dev environment, using the dedicated runtime service account and requiring an operator-provided container image. Make ingress and unauthenticated access configurable while defaulting to a conservative deployment posture.

### Acceptance criteria

- [ ] Dev can configure a Cloud Run v2 service.
- [ ] `container_image` is required rather than defaulting to a fake image.
- [ ] `min_instances` defaults to `0`.
- [ ] Nonzero `min_instances` values are rejected.
- [ ] `max_instances` is variable-driven and defaults to a small demo-safe value.
- [ ] Unauthenticated access is variable-driven and disabled by default.
- [ ] No always-on VM or non-Cloud Run compute resources are created.

---

## Phase 4: Optional Secrets And Lightweight Observability

**User stories**: 13, 14, 15

### What to build

Add optional Secret Manager secret container creation and lightweight observability support. Keep secret values out of Terraform state and avoid ingestion-heavy telemetry resources.

### Acceptance criteria

- [ ] Secret containers can be declared through variable input.
- [ ] Terraform does not create secret versions or store secret values.
- [ ] Runtime identity can write logs, metrics, and traces as needed for Cloud Run demos.
- [ ] No BigQuery datasets or BigQuery log sinks are created.
- [ ] No dashboards, alerts, Cloud SQL, Vertex Vector Search, or hosted observability tools are created.

---

## Phase 5: Operator Documentation And Validation

**User stories**: 16, 17, 18

### What to build

Document the foundation and verify it from the dev environment. The documentation should make the safe path obvious and the prod danger explicit.

### Acceptance criteria

- [ ] The top-level README explains dev-only Terraform usage.
- [ ] Documentation includes `terraform init`, `terraform plan`, and `terraform apply` commands for dev.
- [ ] Documentation clearly warns not to apply prod.
- [ ] Documentation summarizes the cost constraints and excluded services.
- [ ] `terraform fmt` passes.
- [ ] `terraform init` and `terraform validate` pass from the dev environment, or any local blocker is reported with the exact command attempted.
