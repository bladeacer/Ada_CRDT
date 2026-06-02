.PHONY: help all build run test prove doc api-docs clean

.DEFAULT_GOAL := help

help:
	@echo 'Ada_CRDT - CRDT library for Ada/SPARK'
	@echo ''
	@echo 'Usage: make <target>'
	@echo ''
	@echo '  build    Build the project and tests (alr build)'
	@echo '  run      Build and run tests'
	@echo '  test     Alias for run'
	@echo '  prove    Run SPARK proofs (alr gnatprove)'
	@echo '  doc      Generate Markdown API docs (docs/api-docs/)'
	@echo '  clean    Remove build artifacts'
	@echo '  help     Show this message'

build:
	alr build

run: build
	alr run

test: run

prove:
	alr gnatprove

doc: api-docs

api-docs:
	mkdir -p obj
	alr exec -- gnatdoc -P ada_crdt.gpr --backend=rst --output-dir=obj/gnatdoc-rst
	python3 tools/rst2md.py obj/gnatdoc-rst docs/api-docs

clean:
	alr clean
	rm -rf obj/ lib/ docs/
