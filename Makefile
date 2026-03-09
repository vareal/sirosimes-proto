.PHONY: lint breaking generate verify clean all

lint:
	buf lint

breaking:
	buf breaking --against '.git#branch=main'

generate:
	buf generate

# Verify that generated code matches proto definitions (CI reproducibility check)
verify: generate
	git diff --exit-code gen/ || (echo "ERROR: Generated code is out of sync. Run make generate and commit." && exit 1)

clean:
	rm -rf gen/

all: lint generate
