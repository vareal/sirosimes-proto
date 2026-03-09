.PHONY: lint breaking generate clean check-generate all

lint:
	buf lint

breaking:
	buf breaking --against '"'"'.git#branch=main'"'"'

generate:
	buf generate

# CQO要件: 生成コード再現性チェック
check-generate:
	buf generate
	git diff --exit-code gen/ || (echo "ERROR: Generated code is out of sync with proto definitions. Run '"'"'make generate'"'"' and commit." && exit 1)

clean:
	rm -rf gen/

all: lint generate
