# sirosimes-proto

**Sirosimes Protocol Buffers Single Source of Truth (SSoT)**

All product schemas are defined here and code is generated for Go, TypeScript, and OpenAPI.

## Quick Start

```bash
git clone <repo-url> && cd sirosimes-proto && make all
```

## Products Using This Schema

| Product | Description |
|---------|-------------|
| Tsukasa (司) | Integrated employee management system |
| Hataori (機織) | AI workflow orchestration engine |
| Mizugaki (瑞垣) | Authentication & authorization gateway |
| Michishirube (道標) | LLM routing & service mesh proxy |
| Mikura (御倉) | Secure document vault |
| Mitama (御魂) | AI agent lifecycle engine |
| Kotodama (言霊) | LLM inference & embedding service |
| Kaji (鍛冶) | CI/CD pipeline management |
| Tamanoya (玉の舎) | Learning & training platform |
| Tamayura (玉響) | Real-time messaging & communication |
| Amatsukagami (天津鏡) | Integrated monitoring & observability |
| Kotonoha (言の葉) | NLP & document processing |
| Omokage (面影) | Memory & RAG retrieval |
| Chakai (茶会) | Meeting & collaboration |
| Sonae (備) | Backup & disaster recovery |
| Imonori (斎垣) | Security perimeter, WAF & closed network |
| Sakimori (防人) | Endpoint protection & vulnerability mgmt |
| Yorishiro (依代) | IoT device management |
| Aoi (碧) | Vision & video analytics |
| Matoi (纏) | Service integration & data connectors |
| Tokoyo (常世) | Archive & long-term storage |
| Tokowana (常若) | Release & version management |
| Musubi (産霊) | AI content generation |
| Mokusa (御草) | Knowledge base & documentation |
| Nexia PAWS | Quadruped robot control & telemetry |
| Nexia Voice | Voice conversation & speech AI |
| Nexia ERP | CRM, invoicing & business management |
| Kaigo (介護のこころ) | Care planning & resident management |

## Directory Structure

```
sirosimes-proto/
├── buf.yaml              # Buf module configuration
├── buf.gen.yaml          # Code generation configuration
├── buf.lock              # Dependency lock file
├── proto/sirosimes/
│   ├── common/v1/        # Shared types (classification-neutral)
│   ├── external/v1/      # External-facing API types (PUBLIC/INTERNAL)
│   └── internal/v1/      # Internal service types (CONFIDENTIAL/RESTRICTED)
├── gen/
│   ├── go/               # Generated Go code
│   ├── ts/               # Generated TypeScript code
│   └── openapi/          # Generated OpenAPI specs
└── docs/adr/             # Architecture Decision Records
```

## Getting Started

### Prerequisites

- [buf](https://buf.build/docs/installation) (v1.28+)
- Go 1.21+ (for Go code generation)
- Node.js 18+ (for TypeScript code generation)

### Install buf

```bash
# macOS
brew install bufbuild/buf/buf

# Linux
curl -sSL https://github.com/bufbuild/buf/releases/latest/download/buf-Linux-$(uname -m) -o /usr/local/bin/buf
chmod +x /usr/local/bin/buf
```

### Development Workflow

```bash
# Lint proto files
make lint

# Check for breaking changes against main
make breaking

# Generate code (Go, TypeScript, OpenAPI)
make generate

# Verify generated code matches committed code (CI check)
make verify

# Clean generated code
make clean

# Lint + generate
make all
```

## Common Types (proto/sirosimes/common/v1/)

| File | Purpose | Key Types |
|------|---------|-----------|
| `timestamps.proto` | Time utilities | TimeRange, DateRange |
| `pagination.proto` | List API pagination & sorting | PaginationRequest/Response, PageToken/PageTokenResponse, SortOrder |
| `error.proto` | Structured errors | Error, ErrorDetail |
| `actor.proto` | Action performers | Actor, ActorRef, ActorType, ActorStatus |
| `organization.proto` | Organizational structure | Organization, OrganizationType |
| `permission.proto` | Access control | Permission, Role, AccessDecision |
| `audit.proto` | Audit trail (immutable) | AuditLog, AuditSeverity |
| `metadata.proto` | Resource metadata & security | ResourceMetadata, SecurityLevel |

### Pagination Patterns

This repository provides **two pagination patterns**. Each domain service chooses per endpoint:

| Pattern | Type | Best For | Trade-offs |
|---------|------|----------|------------|
| **Offset-based** | `PaginationRequest` / `PaginationResponse` | UI with page numbers, admin dashboards, small-to-medium datasets | Requires total count (can be expensive), skip+limit performance degrades on large datasets |
| **Cursor-based** | `PageToken` / `PageTokenResponse` | Infinite scroll, real-time feeds, large datasets, high-performance APIs | No total count, no random page access |

### Error Handling

- **gRPC endpoints**: Return standard gRPC status codes. Attach `Error` as detail metadata.
- **REST endpoints**: `Error` is serialized as JSON body. `http_status` maps to HTTP status.
- **Frontend**: Use `code` (machine-readable) for logic, `message` (human-readable) for display.

See `error.proto` header comments for detailed guidance.

## Security Classification

All resources have a `SecurityLevel` (defined in `metadata.proto`):

| Level | Label | Access |
|-------|-------|--------|
| 1 | PUBLIC | No restrictions |
| 2 | INTERNAL | Internal use only |
| 3 | CONFIDENTIAL | Need-to-know, CXO approval |
| 4 | RESTRICTED | Highest sensitivity — PII, credentials |

See [SECURITY.md](SECURITY.md) for full policy.

## Contributing

1. Create a feature branch from `main`
2. Add or modify `.proto` files in `proto/`
3. Run `make lint` to verify
4. Run `make breaking` to check backward compatibility
5. Run `make generate` to update generated code
6. Run `make verify` to confirm reproducibility
7. Open a Pull Request

### Proto Style Guide

- Follow [Buf Style Guide](https://buf.build/docs/best-practices/style-guide/)
- All messages and enums MUST have doc comments
- Each `.proto` file MUST have a header comment explaining purpose and relationships
- Enum zero values MUST be `*_UNSPECIFIED`
- Use `google.protobuf.Timestamp` for time fields
- Use `string` with UUID format for identifiers

## Architecture Decision Records

- [ADR-001: Proto SSoT Foundation](docs/adr/001-proto-ssot-foundation.md) — Why protobuf, rejected alternatives

## License

Proprietary — Vareal Group. All rights reserved.
