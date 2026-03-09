# sirosimes-proto

Sirosimes Protocol Buffers definitions — Single Source of Truth (SSoT) for all Sirosimes product gRPC APIs.

## Structure

```
proto/
├── common/v1/       # Shared types (UUID, Timestamp, Pagination, Error, Metadata)
├── tsukasa/v1/      # 司 (Tsukasa) — Employee/Wiki management
├── mizugaki/v1/     # 瑞垣 (Mizugaki) — Authentication/Authorization
├── hataori/v1/      # 機織 (Hataori) — Workflow engine
├── mikura/v1/       # 御蔵 (Mikura) — Document/Storage
└── michishirube/v1/ # 道標 (Michishirube) — Service discovery/routing
```

## Prerequisites

- [buf](https://buf.build/docs/installation) CLI installed
- Go 1.21+ (for generated code)

## Usage

### Lint proto files

```bash
make lint
```

### Generate Go code

```bash
make generate
```

### Check breaking changes (against main branch)

```bash
make breaking
```

### Clean generated code

```bash
make clean
```

## CI/CD

GitHub Actions runs `buf lint` on every push to `main` and checks for breaking changes on pull requests.

## Adding New Proto Definitions

1. Create a new `.proto` file in the appropriate `proto/sirosimes/<service>/v1/` directory
2. Use `package sirosimes.<service>.v1;`
3. Set `option go_package = "github.com/vareal/sirosimes-proto/gen/go/<service>/v1;<service>v1";`
4. Import shared types from `common/v1/` as needed
5. Run `make lint` to validate
6. Run `make generate` to regenerate Go code
7. Commit both `.proto` and generated `gen/go/` files

## Common Types

| Type | Package | Description |
|------|---------|-------------|
| `UUID` | `common.v1` | Wrapper for UUID string values |
| `Timestamp` | `common.v1` | Unix timestamp with nanosecond precision |
| `Pagination` | `common.v1` | Page-based pagination parameters and totals |
| `SortOrder` | `common.v1` | Sort field and direction |
| `Error` | `common.v1` | Standardized error response with trace ID |
| `RequestMetadata` | `common.v1` | Request context (actor, tenant, trace) |
| `AuditEntry` | `common.v1` | Audit log entry with change tracking |

## License

Proprietary — Vareal Group
