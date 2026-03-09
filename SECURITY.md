# Security Policy — sirosimes-proto

## Overview

This repository contains the Protocol Buffers Single Source of Truth (SSoT) for all Sirosimes products.
All schema changes here propagate to every product, making security critical.

## Data Classification (4-Level)

| Level | Label | Description |
|-------|-------|-------------|
| 1 | PUBLIC | Open data, no restrictions |
| 2 | INTERNAL | Internal use only, not for external sharing |
| 3 | CONFIDENTIAL | Business-sensitive, need-to-know basis |
| 4 | RESTRICTED | Highest sensitivity — PII, credentials, audit trails |

Proto definitions in `proto/sirosimes/external/v1/` are designed for external-facing APIs (PUBLIC/INTERNAL).
Proto definitions in `proto/sirosimes/internal/v1/` are for internal system communication only (CONFIDENTIAL/RESTRICTED).

## External / Internal Separation (CISO Directive)

- **External protos** (`external/v1/`): Exposed via public-facing gRPC/REST gateways. Must not contain internal identifiers, infrastructure details, or RESTRICTED fields.
- **Internal protos** (`internal/v1/`): Used between Sirosimes microservices only. May reference internal actor IDs, audit fields, and system metadata.
- **Common protos** (`common/v1/`): Shared types used by both external and internal services. Must be classification-neutral.

## Authentication & Tokens

- All API tokens MUST be opaque (no embedded claims visible to clients).
- JWT or structured tokens may be used internally but MUST NOT be exposed in external APIs.
- Token rotation policies are defined per-product.

## Code Review & Merge Requirements

- All changes to `proto/` MUST go through a Pull Request.
- PRs require at least **1 approval** from a CODEOWNERS-designated reviewer.
- Breaking changes (detected by `buf breaking`) require **CTO approval**.
- No force-pushes to `main`.

## Git Signing

- All commits to `main` SHOULD be signed (GPG or SSH signatures).
- CI pipelines verify signature presence on protected branches.

## Vulnerability Reporting

If you discover a security vulnerability in the proto definitions or generated code,
please report it privately to the CISO via internal channels. Do not open a public issue.

## Audit Trail

All changes to this repository are tracked via Git history and the `AuditLog` proto type.
The `AuditSeverity` enum classifies events for monitoring and alerting.
