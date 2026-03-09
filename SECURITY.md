# Security Policy — sirosimes-proto

## Overview

This repository contains the Protocol Buffers Single Source of Truth (SSoT) for all Sirosimes products.
All schema changes here propagate to every product, making security critical.

## Data Classification (4-Level)

| Level | Label | Encryption | Access Log | Retention | Masking |
|-------|-------|-----------|------------|-----------|---------|
| 1 | PUBLIC | Optional | Optional | Standard | None |
| 2 | INTERNAL | In-transit (TLS) | Required | 1 year | None |
| 3 | CONFIDENTIAL | In-transit + at-rest | Required + real-time alert | 5 years | Required for logs |
| 4 | RESTRICTED | In-transit + at-rest + field-level | Required + SIEM integration | 10 years | Required everywhere |

Proto definitions in `proto/sirosimes/external/v1/` are designed for external-facing APIs (PUBLIC/INTERNAL).
Proto definitions in `proto/sirosimes/internal/v1/` are for internal system communication only (CONFIDENTIAL/RESTRICTED).

## External / Internal Separation (CISO Directive)

- **External protos** (`external/v1/`): Exposed via public-facing gRPC/REST gateways. Must not contain internal identifiers, infrastructure details, or RESTRICTED fields.
- **Internal protos** (`internal/v1/`): Used between Sirosimes microservices only. May reference internal actor IDs, audit fields, and system metadata.
- **Common protos** (`common/v1/`): Shared types used by both external and internal services. Must be classification-neutral — no fields that would expose internal architecture.

## Authentication & Tokens

- All API tokens MUST be opaque (no embedded claims visible to clients).
- JWT or structured tokens may be used internally but MUST NOT be exposed in external APIs.
- Token rotation policies are defined per-product.
- Token-related proto definitions (Phase 1, Mizugaki) require CISO review gate.

## Code Review & Merge Requirements

- All changes to `proto/` MUST go through a Pull Request.
- PRs require at least **1 approval** from a CODEOWNERS-designated reviewer.
- Breaking changes (detected by `buf breaking`) require **CTO + CISO approval**.
- Changes to RESTRICTED-classified protos require **CISO + COO approval**.
- No force-pushes to `main`.

## Supply Chain Security

- All buf CLI and protoc plugin versions MUST be pinned in `buf.gen.yaml` and CI definitions.
- `buf.lock` MUST be committed and reviewed on dependency updates.
- CI pipelines verify generated code reproducibility (`buf generate && git diff --exit-code gen/`).
- Plugin binary hashes SHOULD be verified in CI (SBOM tracking planned).

## Git Signing

- All commits to `main` SHOULD be signed (GPG or SSH signatures).
- CI pipelines verify signature presence on protected branches.

## Vulnerability Reporting

If you discover a security vulnerability in the proto definitions or generated code,
report it privately to the CISO (@katsuragi.makoto) via the #sirosimes-alert channel.
Do not open a public issue.

## Audit Trail

All changes to this repository are tracked via Git history and the `AuditLog` proto type.
The `AuditSeverity` enum classifies events for monitoring and alerting.
`AuditLog.integrity_hash` provides tamper detection via chained SHA-256 hashes.
