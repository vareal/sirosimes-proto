# sirosimes-proto

**Sirosimes Protocol Buffers Single Source of Truth (SSoT)**

All product schemas are defined here and code is generated for Go, TypeScript, and OpenAPI.

## Products Using This Schema

| Product | Description |
|---------|-------------|
| Tsukasa (司) | Integrated employee management system |
| Hataori (機織) | AI workflow orchestration engine |
| Mizugaki (瑞垣) | Authentication & authorization gateway |
| Michishirube (道標) | Knowledge graph & navigation |
| Mikura (御倉) | Secure document vault |

## Directory Structure

```
sirosimes-proto/
├── buf.yaml              # Buf module configuration
├── buf.gen.yaml          # Code generation configuration
├── proto/sirosimes/
│   ├── common/v1/        # Shared types (8 files)
│   ├── external/v1/      # External-facing API types
│   └── internal/v1/      # Internal service types
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

# Clean generated code
make clean

# Lint + generate
make all
```

## Common Types (proto/sirosimes/common/v1/)

| File | Description |
|------|-------------|
| `timestamps.proto` | TimeRange, DateRange |
| `pagination.proto` | PaginationRequest/Response, SortOrder |
| `error.proto` | Structured Error, ErrorDetail |
| `actor.proto` | Actor, ActorRef, ActorType, ActorStatus |
| `organization.proto` | Organization, OrganizationType |
| `permission.proto` | Permission, Role, AccessDecision |
| `audit.proto` | AuditLog, AuditSeverity |
| `metadata.proto` | ResourceMetadata, SecurityLevel |

## Contributing

1. Create a feature branch from `main`
2. Add or modify `.proto` files
3. Run `make lint` to verify
4. Run `make breaking` to check for breaking changes
5. Run `make generate` to update generated code
6. Open a Pull Request

### Proto Style Guide

- Follow [Buf Style Guide](https://buf.build/docs/best-practices/style-guide/)
- All messages and enums MUST have comments
- Enum zero values MUST be `*_UNSPECIFIED`
- Use `google.protobuf.Timestamp` for time fields
- Use `string` with UUID format for identifiers

## License

Proprietary — Vareal Group. All rights reserved.
