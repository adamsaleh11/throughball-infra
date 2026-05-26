# Plan: Cost-Optimized Cloud Run Services

> Source PRD: `docs/prds/cloud-run-services.md`

## Architectural decisions

Durable decisions that apply across all phases:

- **Environment model**: Dev remains the only implemented Terraform environment.
- **Service model**: Dev Cloud Run services are composed from one map-driven service configuration.
- **Module boundary**: The Cloud Run module remains a single-service module; the dev environment uses `for_each` to create multiple services.
- **Service names**: Dev defines `throughball-platform-api`, `throughball-ai-runtime`, `throughball-mcp-server`, and `throughball-worker`.
- **Naming**: The renamed product uses throughball naming only.
- **Region**: All implemented services stay constrained to `us-central1`.
- **Scaling policy**: Every dev service must use `min_instances = 0` and `max_instances = 1`.
- **CPU policy**: Dev services use request-scoped CPU only, with no always-on CPU and startup CPU boost disabled by default.
- **Runtime identity**: Dev services share the existing runtime service account unless a later environment requires service-specific identities.
- **Secrets**: Terraform may create secret containers and wire secret references, but must not manage secret values or versions.
- **Worker execution**: The worker is only a scale-to-zero service definition. Scheduler, Pub/Sub, and other triggers are out of scope.
- **Observability**: Structured logging support stays lightweight through Cloud Run log capture, runtime permissions, labels, and application-emitted JSON logs.

---

## Phase 1: Four-Service Dev Surface

**User stories**: 1, 2, 3, 4, 5, 6, 7, 8, 20, 23, 25

### What to build

Replace the current single-service dev Cloud Run configuration with a map-driven service model that defines the four required throughball services. Preserve the existing single-service Cloud Run module boundary and compose multiple services from the dev environment. Update service outputs so operators can inspect names and URIs for all services.

### Acceptance criteria

- [ ] Dev service configuration contains `throughball-platform-api`.
- [ ] Dev service configuration contains `throughball-ai-runtime`.
- [ ] Dev service configuration contains `throughball-mcp-server`.
- [ ] Dev service configuration contains `throughball-worker`.
- [ ] All service definitions use throughball naming.
- [ ] The Cloud Run module remains usable for one service.
- [ ] The dev environment creates Cloud Run services from a service map.
- [ ] Each service can define its own placeholder container image.
- [ ] Dev outputs expose Cloud Run service names as a map.
- [ ] Dev outputs expose Cloud Run service URIs as a map.
- [ ] Terraform validation still enforces the single allowed region.

---

## Phase 2: Dev Cost Guardrails

**User stories**: 5, 6, 7, 8, 9, 10, 11, 12, 23, 24

### What to build

Make the multi-service configuration enforce the repo's dev cost policy for every service. Tighten defaults and validation so all services scale to zero, cap at one instance, use low resource defaults, and avoid always-on CPU.

### Acceptance criteria

- [ ] Every dev service defaults to `min_instances = 0`.
- [ ] Terraform validation rejects any dev service with `min_instances` greater than zero.
- [ ] Every dev service defaults to `max_instances = 1`.
- [ ] Terraform validation rejects any dev service with `max_instances` greater than one.
- [ ] Startup CPU boost is disabled by default.
- [ ] Services expose low default CPU and memory limits.
- [ ] Services expose low default request concurrency.
- [ ] Cloud Run resource configuration models request-scoped CPU behavior.
- [ ] No always-on compute resources are introduced.

---

## Phase 3: Runtime Configuration And Secrets

**User stories**: 13, 14, 15, 16, 21, 22, 24

### What to build

Extend service configuration so each Cloud Run service can receive plain environment variables and Secret Manager-backed environment variables. Keep secret values out of Terraform while granting the shared runtime service account access only to referenced secret containers. Preserve service-specific labels and access defaults.

### Acceptance criteria

- [ ] Each service can define plain environment variables.
- [ ] Each service can define Secret Manager-backed environment variables.
- [ ] Secret references include a secret identifier and version, defaulting to `latest` when not specified.
- [ ] Terraform does not manage secret values.
- [ ] Terraform does not create secret versions.
- [ ] Runtime secret access is limited to referenced secrets.
- [ ] Services receive service-specific labels.
- [ ] Unauthenticated access remains service-specific.
- [ ] Unauthenticated access remains disabled by default.

---

## Phase 4: Health Checks And Worker Constraints

**User stories**: 17, 18, 19, 21, 24

### What to build

Add Cloud Run health check configuration to the service module and expose simple per-service health settings through the service map. Keep request-serving services aligned around HTTP health checks while ensuring the worker definition does not imply continuous execution or add a trigger.

### Acceptance criteria

- [ ] Request-serving services support a default HTTP health check path.
- [ ] Health check settings can be overridden per service.
- [ ] Cloud Run service definitions include startup probe support.
- [ ] Cloud Run service definitions include liveness probe support where appropriate.
- [ ] Worker health configuration does not require the worker to run continuously.
- [ ] No Cloud Scheduler job is created.
- [ ] No Pub/Sub topic or event trigger is created.
- [ ] Structured logging support remains limited to labels, IAM, and Cloud Run log capture.

---

## Phase 5: Documentation And Validation

**User stories**: 19, 20, 24, 25

### What to build

Update operator documentation and local validation checks to reflect the four-service Cloud Run deployment surface. Verify formatting and Terraform validation from the dev environment, and make the worker and secret-value boundaries clear.

### Acceptance criteria

- [ ] Documentation lists all four dev Cloud Run services.
- [ ] Documentation explains that all dev services scale to zero.
- [ ] Documentation states that dev services cap at one instance.
- [ ] Documentation states that the worker has no implicit scheduler or trigger.
- [ ] Documentation explains that secret values and versions are not managed by Terraform.
- [ ] Local validation checks assert the four throughball service names.
- [ ] Local validation checks assert the max-instance cap of one.
- [ ] Local validation checks assert Cloud Run health probe support.
- [ ] Local validation checks assert secret environment variable support.
- [ ] `terraform fmt` passes.
- [ ] `terraform init` and `terraform validate` pass from the dev environment, or any local blocker is reported with the exact command attempted.
