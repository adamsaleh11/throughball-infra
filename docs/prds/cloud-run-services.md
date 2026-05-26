# PRD: Cost-Optimized Cloud Run Services

## Problem Statement

The throughball infrastructure repo currently has a dev-only Terraform foundation with one Cloud Run service definition. The product now needs four Cloud Run service definitions for demo and interview deployments: `throughball-platform-api`, `throughball-ai-runtime`, `throughball-mcp-server`, and `throughball-worker`.

This matters because the project needs to demonstrate a realistic multi-service production architecture while preserving the repo's local-first, low-cost operating model. The infrastructure maintainer needs Terraform that can define all required services, inject configuration safely, integrate with Secret Manager, expose health checks, and keep every dev service scaled to zero when idle.

## Solution

Extend the dev Terraform foundation so it can define the four throughball Cloud Run services through a shared, cost-constrained service configuration model. The existing Cloud Run module should remain focused on one service, while the dev environment composes multiple services from a map-driven interface.

Each dev service should use Cloud Run v2, a single allowed region, minimum instances of zero, maximum instances of one, request-scoped CPU, no always-on CPU, low default resources, and lightweight observability support. Services should accept plain environment variables and Secret Manager-backed environment variables without storing secret values in Terraform state. The worker should be defined as an idle Cloud Run service only; it must not receive an implicit always-running trigger or scheduler.

## User Stories

1. As an infrastructure maintainer, I want Terraform to define `throughball-platform-api`, so that the main API can be deployed for demos.
2. As an infrastructure maintainer, I want Terraform to define `throughball-ai-runtime`, so that AI runtime deployment has a dedicated service surface.
3. As an infrastructure maintainer, I want Terraform to define `throughball-mcp-server`, so that MCP server deployment has a dedicated service surface.
4. As an infrastructure maintainer, I want Terraform to define `throughball-worker`, so that background worker deployment can be demonstrated without running continuously.
5. As an infrastructure maintainer, I want all dev Cloud Run services to use minimum instances of zero, so that idle services do not generate unnecessary cost.
6. As an infrastructure maintainer, I want all dev Cloud Run services capped at one maximum instance, so that demo traffic cannot scale into unexpected spend.
7. As an infrastructure maintainer, I want nonzero minimum instances rejected, so that the scale-to-zero rule is enforced by Terraform validation.
8. As an infrastructure maintainer, I want maximum instances above one rejected in dev, so that the service limits are enforced consistently.
9. As an infrastructure maintainer, I want CPU allocated only during request handling, so that services do not pay for always-on CPU.
10. As an infrastructure maintainer, I want startup CPU boost disabled by default, so that service defaults stay conservative.
11. As an infrastructure maintainer, I want low default memory and CPU limits, so that placeholder and demo services stay inexpensive.
12. As an infrastructure maintainer, I want low but configurable request concurrency, so that demo services remain predictable.
13. As an infrastructure maintainer, I want each service to support plain environment variables, so that non-secret runtime configuration can be injected through Terraform.
14. As an infrastructure maintainer, I want each service to support Secret Manager-backed environment variables, so that secret references can be wired without storing secret values in state.
15. As an infrastructure maintainer, I want Terraform to grant secret access only for referenced secrets, so that runtime IAM remains narrow.
16. As an infrastructure maintainer, I want Secret Manager secret containers to remain value-free, so that Terraform state never contains secret material.
17. As an infrastructure maintainer, I want each service to expose health check configuration, so that Cloud Run can verify containers before routing traffic.
18. As an infrastructure maintainer, I want the worker health behavior to avoid implying continuous execution, so that it remains manually invoked or explicitly scheduled later.
19. As an infrastructure maintainer, I want structured logging support to remain lightweight, so that demos can show logs without adding expensive logging infrastructure.
20. As an infrastructure maintainer, I want Cloud Run outputs for all service names and URIs, so that operators can find deployed endpoints after apply.
21. As an infrastructure maintainer, I want service-specific labels, so that logs, metrics, and resources can be filtered by service.
22. As an infrastructure maintainer, I want unauthenticated access to remain service-specific and disabled by default, so that internal services are not accidentally exposed.
23. As an infrastructure maintainer, I want a single dev region to remain enforced, so that service definitions do not introduce regional sprawl.
24. As an infrastructure maintainer, I want Terraform validation and local foundation checks to cover the new service model, so that future edits do not weaken cost controls.
25. As an infrastructure maintainer, I want placeholder container images to be configurable per service, so that services can be planned and deployed before final application images exist.

## Implementation Decisions

- Keep the existing Cloud Run module as a single-service module.
- Compose the four dev services from a map-driven service configuration in the dev environment.
- Use one module invocation with `for_each` for the service map rather than four manually duplicated module blocks.
- Name the AI runtime service `throughball-ai-runtime`.
- Define exactly these dev service names: `throughball-platform-api`, `throughball-ai-runtime`, `throughball-mcp-server`, and `throughball-worker`.
- Require or configure container images per service rather than relying on one global service image.
- Keep using Cloud Run v2.
- Preserve the single-region dev constraint.
- Enforce `min_instances = 0` for every dev service.
- Enforce `max_instances = 1` for every dev service.
- Default request concurrency to a low demo-safe value, with per-service override if needed.
- Default memory and CPU to low values, with per-service override if needed.
- Disable startup CPU boost by default.
- Explicitly model request-scoped CPU behavior and avoid always-on CPU.
- Support plain environment variables as per-service key-value maps.
- Support Secret Manager-backed environment variables as per-service references to secret containers and versions.
- Continue creating only Secret Manager secret containers, not secret values or secret versions.
- Grant the runtime service account access only to secrets referenced by service configuration.
- Use one shared dev runtime service account unless a later environment requires service-specific identities.
- Add health check configuration to the Cloud Run module, including a default HTTP health path for request-serving services.
- Model the worker as a scale-to-zero Cloud Run service without adding Cloud Scheduler, Pub/Sub, or any other trigger in this PRD.
- Keep structured logging support lightweight by relying on Cloud Run log capture, runtime logging permissions, service labels, and application-emitted JSON logs.
- Expose service names and URIs as maps keyed by logical service key.
- Keep Artifact Registry as a shared Docker repository for all service images.

## Testing Decisions

- Test the Terraform contract and cost guardrails rather than internal implementation details.
- Run Terraform formatting checks across the repo.
- Run Terraform initialization and validation from the dev environment.
- Extend local foundation checks so they assert that all four service names are present in the dev service configuration.
- Validate that dev rejects `min_instances` values above zero.
- Validate that dev rejects `max_instances` values above one.
- Verify the Cloud Run module supports health probes.
- Verify the Cloud Run module supports plain environment variables and Secret Manager-backed environment variables.
- Verify the Cloud Run module exposes resource limits and request-scoped CPU configuration.
- Verify outputs expose service name and URI maps rather than a single service output.
- Verify documentation reflects four services, scale-to-zero behavior, worker trigger constraints, and the absence of managed secret values.

## Out of Scope

- Building application Docker images.
- Implementing application health endpoints.
- Implementing deployment automation or CI/CD.
- Applying Terraform to GCP.
- Creating staging or production Cloud Run services.
- Creating Cloud Scheduler jobs.
- Creating Pub/Sub topics or event triggers for the worker.
- Creating BigQuery log sinks, dashboards, alerts, SLOs, or hosted observability stacks.
- Managing secret values or secret versions in Terraform.
- Splitting runtime identities by service.
- Creating one Artifact Registry repository per service.
- Load testing or tuning for production traffic.

## Further Notes

- The worker must remain idle by default. Any future scheduled demo job should be explicit and reviewable in a separate ticket.
- The service map should be easy to extend later for staging or prod, but this PRD only implements dev.
- The requested ticket path was not present in the repo at PRD time, so the user-provided ticket text and confirmed grill decisions are the source of truth.
- Future service definitions should use throughball naming only.
