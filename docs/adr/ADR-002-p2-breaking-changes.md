# ADR-002: Phase 2 Breaking Change Policy — ResourceMetadata Unification

| Field       | Value                                    |
|-------------|------------------------------------------|
| Status      | Accepted                                 |
| Date        | 2026-03-10                               |
| Authors     | COO (fujiwara.ai)                        |
| Reviewers   | CQO (nabeshima.toru), CEXO (hanamiya.yuzuki), CISO (katsuragi.makoto) |
| Priority    | HIGH                                     |

## Context

Phase 1 introduced 13 domain proto files across 司 (Tsukasa), 機織 (Hataori), and 瑞垣 (Mizugaki).
During the Phase 1 review, all three reviewers identified that ResourceMetadata usage is inconsistent:

- **瑞垣** (Identity, OAuth2Client): Embeds `ResourceMetadata` from common/v1.
- **司** (Employee, Task, Project, WikiDocument, DailyReport): Uses individual `id`, `created_at`, `updated_at` fields.
- **機織** (Workflow, Execution, Trigger, Approval): Uses individual fields.

This inconsistency means frontend developers must handle two different patterns for accessing
entity metadata, increasing cognitive load and error potential.

## Decision

Phase 2 will unify all domain entities to embed `ResourceMetadata`, with a controlled
migration plan that minimizes breaking changes.

### Breaking Change Scope

| Entity            | Current Fields Affected          | Migration Impact |
|-------------------|----------------------------------|------------------|
| Employee          | id(1), created_at(16), updated_at(17) | HIGH — field numbers change |
| Task              | id(1), created_at(17), updated_at(18) | HIGH |
| Project           | id(1), created_at(17), updated_at(18) | HIGH |
| WikiDocument      | id(1), created_at(10), updated_at(11) | HIGH |
| DailyReport       | id(1), created_at(14), updated_at(15) | MEDIUM |
| Workflow          | id(1), created_at(8), updated_at(9)   | MEDIUM |
| Execution         | id(1), created_at(11)                 | MEDIUM |
| Trigger           | id(1), created_at(7), updated_at(8)   | MEDIUM |
| ApprovalRequest   | id(1), created_at(11)                 | MEDIUM |

### Migration Strategy

1. **Phase 2a — Dual-write period (2 weeks):**
   - Add `ResourceMetadata metadata = N` as a NEW field (preserving old fields).
   - Servers populate BOTH old individual fields AND the new metadata field.
   - Clients may read from either pattern.
   - `buf breaking` will NOT flag this (additive change only).

2. **Phase 2b — Client migration (2 weeks):**
   - All product teams migrate to reading from `metadata` field.
   - Verified via integration tests that no client reads old fields.

3. **Phase 2c — Old field deprecation (1 week):**
   - Old individual fields marked `deprecated = true` with comments.
   - Servers stop populating old fields (set to default values).
   - `buf breaking` exception added for these specific fields.

4. **Phase 2d — Cleanup (deferred):**
   - Old fields marked `reserved` in a future major version.
   - Not done in Phase 2 to maintain wire compatibility during rollback window.

### Backward Compatibility Guarantees

- **72-hour rollback window** per phase (per CTRO directive).
- During Phase 2a-2b, old and new patterns coexist — no client breaks.
- Phase 2c is the only potentially breaking step, gated by integration test verification.
- **No field number reuse**: Old field numbers are reserved, never reassigned.
- **Wire format compatibility**: protobuf wire format is backward-compatible
  as long as field numbers are not reused.

### SecurityLevel Application

As part of ResourceMetadata unification, all entities gain `security_level`:

| Entity          | Default SecurityLevel | Rationale                       |
|-----------------|----------------------|---------------------------------|
| Employee        | CONFIDENTIAL         | PII (email, position)           |
| Task            | INTERNAL             | Business operations data        |
| Project         | INTERNAL             | Business operations data        |
| WikiDocument    | INTERNAL             | Mixed sensitivity (per-doc override) |
| DailyReport     | INTERNAL             | Employee work records           |
| Workflow        | INTERNAL             | Automation definitions          |
| Execution       | CONFIDENTIAL         | May contain sensitive I/O data  |
| Trigger         | INTERNAL             | Event routing config            |
| ApprovalRequest | CONFIDENTIAL         | Decision audit trail            |

### BFF/Gateway Opaque Token Design (CISO A-1)

For Phase 2 implementation of the opaque token architecture:

- **BFF layer** intercepts all external API responses.
- JWT `access_token` / `refresh_token` in AuthSession → replaced with opaque session reference ID.
- Opaque ID format: `mzk_<base62(32 bytes)>` — no embedded structure.
- Internal services continue using JWT for service-to-service auth via `VerifyToken` RPC.
- Mapping: `opaque_id → JWT` stored in Redis with session TTL.

## Alternatives Considered

| Alternative | Rejected Because |
|-------------|-----------------|
| Keep individual fields forever | DX inconsistency grows with each new product |
| Big-bang migration (one commit) | Too risky, no rollback path |
| Per-product opt-in | Defeats the purpose of SSoT standardization |
| Wrapper messages | Adds indirection without solving the core problem |

## Consequences

- Phase 2 will take ~5 weeks (2a: 2wk + 2b: 2wk + 2c: 1wk).
- All product teams must allocate client migration effort during 2b.
- After Phase 2c, all entities have a uniform metadata access pattern.
- SecurityLevel on all entities enables field-level access control in Phase 3.

## Appendix: Field Naming Exception

### Project.resource_metadata

`Project` uses `resource_metadata` (field 19) instead of the standard `metadata` name
because `Project` already has a `map<string, string> metadata` field (field 16) for
arbitrary key-value project metadata.

Protobuf does not allow two fields with the same name in one message, so the
ResourceMetadata field is named `resource_metadata` for this entity only.

All other entities use `metadata` as the field name.

This naming divergence is documented here to prevent developer confusion.
In Phase 2c (old field deprecation), the `map<string, string> metadata` field will
be renamed to `labels` (aligning with ResourceMetadata.labels), and
`resource_metadata` will be renamed back to `metadata` for full consistency.
