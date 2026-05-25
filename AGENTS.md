# AGENTS.md — throughball-infra

# PURPOSE

This repo owns:

- Terraform

- Cloud Run deployment

- Docker

- IAM

- observability infra

- deployment automation

This repo is intentionally:

LOW-COST and LOCAL-FIRST.

---

# INFRASTRUCTURE PHILOSOPHY

Most development runs:

locally via Docker.

Cloud deployment happens:

- near interview

- near final demo

- for screenshots/traces only

---

# COST OPTIMIZATION RULES

## Cloud Run

ALWAYS:

minimum instances = 0

Never leave idle services running unnecessarily.

---

## Logging

Avoid:

- giant logs

- prompt dumps

- verbose telemetry

Prefer:

- summaries

- sampled traces

- lightweight metrics

---

## Vertex Usage

Use:

Gemini Flash ONLY.

Avoid:

expensive models.

---

# DEPLOYMENT PHILOSOPHY

The goal is:

enterprise-grade architecture

without enterprise-grade spend.

---

# TERRAFORM RULES

Infrastructure must remain:

- modular

- reproducible

- minimal

- observable

---

# OBSERVABILITY RULES

Expose enough telemetry to demonstrate:

- traces

- retries

- evals

- latency

- degraded execution

Avoid:

enterprise-scale telemetry ingestion.

---

# ARCHITECTURE PHILOSOPHY

This repo demonstrates:

production infrastructure thinking

with aggressive cost optimization.
