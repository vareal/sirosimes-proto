# Security Policy — sirosimes-proto

## Overview

This repository contains the Protocol Buffers Single Source of Truth (SSoT) for all Sirosimes products.
All schema changes here propagate to every product, making security critical.

## Data Classification (4-Level, ISO 27001 Aligned)

| Level | Label | Encryption | Access Log | Retention | Masking |
|-------|-------|-----------|------------|-----------|---------|
| 1 | PUBLIC | Transit only (TLS) | Optional | Unlimited | None |
| 2 | INTERNAL | Transit required (TLS) | Optional | 3 years | None |
| 3 | CONFIDENTIAL | Transit + at-rest required | Required + real-time alert | 1 year | Required for external exposure |
| 4 | RESTRICTED | Transit + at-rest + field-level encryption | Required + tamper detection (SIEM) | 6 months | Always required |

Proto definitions in `proto/sirosimes/external/v1/` are designed for external-facing APIs (PUBLIC/INTERNAL).
Proto definitions in `proto/sirosimes/internal/v1/` are for internal system communication only (CONFIDENTIAL/RESTRICTED).

### Default Classification

When `ResourceMetadata.security_level` is UNSPECIFIED, domain services SHOULD treat the resource
as INTERNAL (level 2) by default.

### RESTRICTED Data Physical Deletion

RESTRICTED-level resources with `deleted_at` set (soft-deleted) MUST be physically deleted
after the retention period (6 months). Physical deletion requires:
- Confirmation that no active audit investigations reference the resource
- CISO approval for deletion of audit trail records
- Cryptographic erasure of field-level encrypted data

## External / Internal Separation (CISO Directive)

- **External protos** (`external/v1/`): Exposed via public-facing gRPC/REST gateways. Must not contain internal identifiers, infrastructure details, or RESTRICTED fields.
- **Internal protos** (`internal/v1/`): Used between Sirosimes microservices only. May reference internal actor IDs, audit fields, and system metadata.
- **Common protos** (`common/v1/`): Shared types used by both external and internal services. Must be classification-neutral — no fields that would expose internal architecture.

## Authentication & Tokens

- All API tokens MUST be opaque (no embedded claims visible to clients).
- JWT or structured tokens may be used internally but MUST NOT be exposed in external APIs.
- Token rotation policies are defined per-product.
- Token-related proto definitions (Phase 1, Mizugaki) require CISO review gate.

## Audit Log Access Control

`AuditLog` records contain fields that are themselves sensitive data:
- `ip_address` and `user_agent` are CONFIDENTIAL-level personal data
- Access to audit logs MUST be restricted to authorized security personnel
- Audit log queries MUST themselves be logged (meta-audit)
- External exposure of audit data requires masking of `ip_address` and `user_agent`

## Code Review & Merge Requirements

- All changes to `proto/` MUST go through a Pull Request.
- PRs require at least **1 approval** from a CODEOWNERS-designated reviewer.
- Breaking changes (detected by `buf breaking`) require **CTO + CISO approval**.
- Changes to RESTRICTED-classified protos require **CISO + COO approval**.
- **SecurityLevel enum changes** (adding, removing, or redefining values) are treated as
  breaking changes and require **CISO approval**, regardless of `buf breaking` detection.
- **Structural changes** to `permission.proto`, `audit.proto`, and `metadata.proto` require
  **CISO review**, as these define the security control plane.
- No force-pushes to `main`.

## Supply Chain Security

- All buf CLI and protoc plugin versions MUST be pinned in `buf.gen.yaml` and CI definitions.
- `buf.lock` MUST be committed and reviewed on dependency updates.
- CI pipelines verify generated code reproducibility (`buf generate && git diff --exit-code gen/`).
- CI MUST verify `buf.lock` integrity hashes exist for all dependencies.
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
`AuditLog.integrity_hash` provides tamper detection via HMAC-SHA256 chained hashes
(each record includes the hash of the previous record).

## External/Internal Service Separation (Phase 2b)

Mizugaki proto definitions are split into:

- **`mizugaki/v1/`** — Full service definitions (all RPCs). Used by internal microservices.
- **`mizugaki/external/v1/`** — External-only service definitions. Used by BFF/Gateway.

### Gateway Configuration Rule

External-facing gRPC gateways and REST proxies MUST load ONLY the external service definitions:
- `ExternalAuthService` (Login, Logout, RefreshToken)
- `ExternalOAuth2Service` (Authorize, Token, Userinfo)
- `ExternalJwksService` (GetJwks)

Loading `mizugaki/v1/*.proto` services directly on external gateways is a **security violation**.

### Internal-Only RPCs (MUST NOT be externally accessible)

| Service | Internal-Only RPCs |
|---------|-------------------|
| AuthService | VerifyToken, ListSessions, RevokeSession, CreateApiKey, RevokeApiKey |
| OAuth2Service | RegisterClient, GetClient, UpdateClient, DeleteClient, ListClients, RotateClientSecret |
| TokenService | IntrospectToken, RotateKeys, RevokeToken |
| IdentityService | All RPCs (CreateIdentity, GetIdentity, UpdateIdentity, DeleteIdentity, ListIdentities, ChangePassword) |
