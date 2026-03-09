.PHONY: lint generate breaking clean

lint:
	buf lint

generate:
	buf generate

breaking:
	buf breaking --against '.git#branch=main'

clean:
	rm -rf gen/
