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

## Rejected Alternatives

### OpenAPI First (Swagger)
- **Considered**: Define APIs in OpenAPI v3 YAML/JSON, generate server stubs and client SDKs.
- **Rejected because**:
  - No native support for binary serialization (JSON only, higher latency for inter-service)
  - Limited type system compared to protobuf (no enums with explicit numbering, no oneof)
  - Code generation quality varies widely across languages
  - Breaking change detection requires external tools with inconsistent support
  - Does not support gRPC, which is essential for low-latency service communication
- **Mitigation**: OpenAPI specs are auto-generated FROM proto definitions via grpc-gateway,
  providing the best of both worlds.

### GraphQL
- **Considered**: Use GraphQL as the unified API layer across products.
- **Rejected because**:
  - Adds query complexity and N+1 risks for backend services
  - Not well-suited for service-to-service communication (designed for client-facing APIs)
  - Schema stitching across products adds operational complexity
  - No native gRPC support for high-performance internal communication
  - AI employee development workflow prefers strongly-typed, generated code over resolver logic
- **Note**: GraphQL may be added as a client-facing gateway layer in the future, consuming
  the same proto-defined types.

### Manual API Contracts (Go structs + JSON tags)
- **Considered**: Continue with the existing approach of defining APIs directly in Go.
- **Rejected because**:
  - No automatic cross-language code generation (TypeScript types must be manually synced)
  - Breaking changes are only detected at runtime
  - No formal schema documentation generation
  - API contracts are scattered across product repositories instead of centralized
  - Directly caused the inconsistency issues that motivated this ADR

### JSON Schema
- **Considered**: Use JSON Schema for type definitions with validators.
- **Rejected because**:
  - Verbose and less expressive than protobuf
  - No gRPC support
  - Code generation ecosystem is fragmented
  - Weaker typed than protobuf (no guaranteed enum stability, no field numbering)

## Consequences

### Positive

- Single source of truth for all data types across all products
- Automated breaking change detection via `buf breaking`
- Generated code ensures type safety across language boundaries
- Security classification enforced at the schema level
- Git history provides complete audit trail of schema changes
- OpenAPI specs auto-generated for REST compatibility

### Negative

- Additional tooling requirement (buf CLI, ~64h learning investment per AI employee)
- Developers must learn Protocol Buffers syntax
- Code generation step required before building products
- Cross-repo dependency management needed

### Risks

- Remote buf plugins may have availability issues → mitigated by supporting local protoc-gen-* fallback
- Large proto changes may break multiple products simultaneously → mitigated by breaking change CI checks
- Vendor lock-in on buf toolchain → mitigated by protobuf being an open standard with many tools

## References

- [Buf Documentation](https://buf.build/docs/)
- [Protocol Buffers Language Guide](https://protobuf.dev/programming-guides/proto3/)
- Sirosimes Architecture Design Document (internal)
- [CXO Review Synthesis](https://tsukasa.vareal.group/wiki/ee687446-1198-49ef-9ee4-deec677b0aff)
