.PHONY: lint breaking generate clean all

lint:
	buf lint

breaking:
	buf breaking --against '.git#branch=main'

generate:
	buf generate

clean:
	rm -rf gen/

all: lint generate
