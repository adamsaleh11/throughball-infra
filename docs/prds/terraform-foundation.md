# PRD: Terraform Foundation for GCP Deployment

## Problem Statement

The throughball infrastructure repo needs a reproducible Terraform foundation for deploying the application to GCP without undermining the repo's local-first and low-cost operating model. Today, the repo documents that it owns Terraform, Cloud Run, Docker, IAM, observability infrastructure, and deployment automation, but it does not yet provide a concrete Terraform layout or a validated dev deployment path.

This matters because the project needs to demonstrate production infrastructure thinking near interview, demo, and screenshot moments, while avoiding accidental paid or always-on resources during normal development. The immediate user is the infrastructure maintainer who needs a clear, safe dev environment that can be initialized, planned, validated, and eventually applied without creating prod resources or expensive managed services.

## Solution

Create a Terraform foundation that implements only the dev environment first and establishes reusable modules for the future staging and prod environments. The dev environment will use a single GCP region, `us-central1`, and provision a minimal Cloud Run deployment surface backed by Artifact Registry, a dedicated runtime service account, optional Secret Manager secret containers, and lightweight observability permissions.

The solution should make the safe path obvious: local development remains the default, dev is the default cloud environment, Cloud Run scales to zero, and README instructions explain how to initialize, validate, plan, and apply dev only. Staging and prod should be represented as future environment placeholders, with prod carrying an explicit warning not to apply it.

## User Stories

1. As an infrastructure maintainer, I want a dev Terraform environment, so that I can validate the GCP foundation before demo deployments.
2. As an infrastructure maintainer, I want the default environment to be dev, so that accidental production work is less likely.
3. As an infrastructure maintainer, I want staging and prod represented only as placeholders, so that the repo structure communicates the future shape without provisioning non-dev resources.
4. As an infrastructure maintainer, I want prod documentation to warn against applying prod, so that expensive or premature resources are not created.
5. As an infrastructure maintainer, I want all resources constrained to `us-central1`, so that regional sprawl and cost surprises are avoided.
6. As an infrastructure maintainer, I want Terraform variables for Cloud Run minimum and maximum instances, so that scaling policy is explicit and reviewable.
7. As an infrastructure maintainer, I want Cloud Run minimum instances to default to zero, so that idle services do not generate unnecessary cost.
8. As an infrastructure maintainer, I want nonzero Cloud Run minimum instances rejected, so that the repo's scale-to-zero rule is enforced.
9. As an infrastructure maintainer, I want Cloud Run maximum instances to default to a small value, so that demo traffic cannot accidentally scale into large spend.
10. As an infrastructure maintainer, I want a dedicated Cloud Run runtime service account, so that app runtime permissions are isolated from deployer permissions.
11. As an infrastructure maintainer, I want minimal IAM grants, so that the foundation avoids broad project-level roles.
12. As an infrastructure maintainer, I want an Artifact Registry Docker repository, so that application images have a predictable GCP target.
13. As an infrastructure maintainer, I want Secret Manager secret containers to be optional and value-free, so that Terraform state never stores secret values.
14. As an infrastructure maintainer, I want observability support to cover traces, logs, and lightweight metrics, so that demos can show production-style telemetry without enterprise-scale ingestion.
15. As an infrastructure maintainer, I want no BigQuery datasets, Vertex Vector Search, Cloud SQL, or always-on VMs, so that the foundation respects cost constraints.
16. As an infrastructure maintainer, I want Terraform formatting to pass, so that the codebase starts with consistent style.
17. As an infrastructure maintainer, I want Terraform validation to pass for dev, so that the first environment has a working configuration contract.
18. As an infrastructure maintainer, I want README instructions for init, plan, and apply, so that future operators can use the foundation without guessing.
19. As an infrastructure maintainer, I want provider and Terraform versions constrained, so that future behavior changes are less surprising.
20. As an infrastructure maintainer, I want local state for the first foundation, so that no additional backend resources are required before dev can be validated.

## Implementation Decisions

- Build the Terraform structure around `environments` and `modules`, with dev as the only implemented environment.
- Create placeholder staging and prod environments that document future intent but do not create runnable resources.
- Use the official Google Terraform provider with conservative version constraints.
- Require a `project_id` variable for dev.
- Use a `region` variable defaulted to `us-central1`, with validation that rejects other regions.
- Use local Terraform state for the foundation ticket; remote state is a follow-up decision.
- Enable only the GCP APIs required for the dev foundation.
- Create a Cloud Run v2 service through a reusable Cloud Run module.
- Require a container image input for Cloud Run instead of inventing a fake deployable image.
- Default Cloud Run `min_instances` to `0` and validate that it cannot be set higher.
- Default Cloud Run `max_instances` to a low value suitable for demos.
- Make unauthenticated Cloud Run access variable-driven and default it to disabled.
- Create one Artifact Registry Docker repository in `us-central1`.
- Create a dedicated Cloud Run runtime service account.
- Grant minimal runtime observability permissions such as log writing, metric writing, and trace writing.
- Keep deployer permissions outside the first foundation unless a later ticket explicitly adds deployment identity management.
- Create optional Secret Manager secret containers from variable input, without managing secret versions or values.
- Keep observability minimal and low-cost; do not create BigQuery sinks, dashboards, alerts, or high-volume telemetry resources in this ticket.
- Apply consistent low-cardinality labels across supported resources.

## Testing Decisions

- Validate the external Terraform contract rather than module implementation details.
- Run `terraform fmt` across the Terraform tree and require it to pass.
- Run `terraform init` and `terraform validate` from the dev environment.
- If provider download or Terraform execution is blocked by the local machine, record the exact attempted command and blocker.
- Validation should prove that dev is syntactically and semantically valid, while staging and prod remain non-runnable placeholders.
- README verification should confirm that init, plan, apply, and prod warnings are present.

## Out of Scope

- Applying production resources.
- Implementing staging resources.
- Creating BigQuery datasets or log sinks to BigQuery.
- Creating Vertex Vector Search.
- Creating Cloud SQL.
- Creating always-on VMs.
- Creating hosted observability stacks.
- Managing secret values or secret versions in Terraform.
- Creating dashboards, alerts, SLOs, or notification channels.
- Creating a remote Terraform backend bucket.
- Managing deployer or CI/CD service account permissions.
- Building Docker images or application code.

## Further Notes

- The foundation should demonstrate enterprise-grade structure while remaining cheap to initialize and safe to leave idle.
- The README should make the dev-only status impossible to miss.
- A later ticket can add remote state, deployment automation, dashboards, staging, and production once the dev foundation is proven.
- The ticket path referenced by the requester was not present in the repo at PRD time, so the request text and confirmed grill answers are the source of truth.
