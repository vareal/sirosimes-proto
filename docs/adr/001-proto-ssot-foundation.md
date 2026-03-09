# ADR-001: Protocol Buffers as Single Source of Truth

## Status

Accepted

## Date

2026-03-09

## Context

The Sirosimes platform consists of multiple products (Tsukasa, Hataori, Mizugaki, Michishirube, Mikura)
that need to communicate with each other and share common data structures. Without a central schema
definition, each product would define its own types, leading to:

- Inconsistent data models across products
- Manual synchronization of API contracts
- Type mismatches causing runtime errors
- Difficulty enforcing security classifications across boundaries

## Decision

We will use **Protocol Buffers (protobuf)** as the Single Source of Truth (SSoT) for all
cross-product data types and API definitions, managed in the `sirosimes-proto` repository.

Key design decisions:

1. **Buf toolchain**: Use `buf` for linting, breaking change detection, and code generation
   instead of raw `protoc`.

2. **External/Internal separation** (CISO directive): Proto definitions are split into
   `external/v1/` (public API surface) and `internal/v1/` (inter-service communication)
   to enforce data classification boundaries.

3. **Common types**: Shared types (Actor, Organization, Pagination, Error, etc.) live in
   `common/v1/` and are available to both external and internal protos.

4. **Multi-language generation**: Code is generated for Go (primary backend), TypeScript
   (frontend/tooling), and OpenAPI (REST gateway documentation).

5. **Semantic versioning via packages**: Each proto package includes a version suffix (v1)
   to support future breaking changes via new versions (v2, v3).

## Consequences

### Positive

- Single source of truth for all data types across all products
- Automated breaking change detection via `buf breaking`
- Generated code ensures type safety across language boundaries
- Security classification enforced at the schema level
- Git history provides complete audit trail of schema changes

### Negative

- Additional tooling requirement (buf CLI)
- Developers must learn Protocol Buffers syntax
- Code generation step required before building products
- Cross-repo dependency management needed

### Risks

- Remote buf plugins may have availability issues → mitigated by supporting local protoc-gen-* fallback
- Large proto changes may break multiple products simultaneously → mitigated by breaking change CI checks

## References

- [Buf Documentation](https://buf.build/docs/)
- [Protocol Buffers Language Guide](https://protobuf.dev/programming-guides/proto3/)
- Sirosimes Architecture Design Document (internal)
