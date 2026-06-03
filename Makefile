.PHONY: help all build run test prove doc api-docs clean release publish demo

.DEFAULT_GOAL := help

help:
	@echo 'CRDT - CRDT library for Ada/SPARK'
	@echo ''
	@echo 'Usage: make <target>'
	@echo ''
	@echo '  build    Build the project and tests (alr build)'
	@echo '  run      Build and run tests'
	@echo '  test     Alias for run'
	@echo '  prove    Run SPARK proofs (alr gnatprove)'
	@echo '  doc      Generate Markdown API docs (docs/api-docs/)'
	@echo '  release  Tag, update index+releases, push. Use VERSION=x.y.z'
	@echo '  publish  Publish to Alire community index (run after make release)'
	@echo '  demo     Build and run the Game of Life demo'
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
	alr exec -- gnatdoc -P crdt.gpr --backend=rst --output-dir=obj/gnatdoc-rst
	python3 tools/rst2md.py obj/gnatdoc-rst docs/api-docs

release:
	@if [ -n "$(VERSION)" ]; then \
		version="$(VERSION)"; \
		sed -i 's/^version = ".*"/version = "'$$version'"/' alire.toml; \
	else \
		version=$$(sed -n 's/^version = "\(.*\)"/\1/p' alire.toml); \
	fi; \
	commit=$$(git rev-parse HEAD); \
	index_file="index/ad/crdt/crdt-$$version.toml"; \
	if [ ! -f "$$index_file" ]; then \
		cp index/ad/crdt/crdt-0.1.0-dev.toml "$$index_file"; \
	fi; \
	sed -i 's/^version = ".*"/version = "'$$version'"/' "$$index_file"; \
	release_file="alire/releases/crdt-$$version.toml"; \
	if [ ! -f "$$release_file" ]; then \
		sed 's/^version = ".*"/version = "'$$version'"/' alire/releases/crdt-0.0.0.toml > "$$release_file"; \
	fi; \
	sed -i 's/^version = ".*"/version = "'$$version'"/' "$$release_file"; \
	if git rev-parse "v$$version" >/dev/null 2>&1; then \
		git tag -d "v$$version" >/dev/null 2>&1 || true; \
		git push origin :refs/tags/"v$$version" >/dev/null 2>&1 || true; \
		echo "  Replaced existing tag v$$version"; \
	fi; \
	git add -A; \
	git commit -m "Release $$version" || true; \
	git tag -a "v$$version" -m "Release $$version"; \
	echo "Tagged v$$version at $$commit"; \
	git push origin HEAD && git push origin "v$$version"; \
	echo "Pushed commit and tag v$$version"

publish:
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "Error: working tree is not clean. Commit or stash changes first."; \
		exit 1; \
	fi; \
	version=$$(sed -n 's/^version = "\(.*\)"/\1/p' alire/releases/crdt-latest.toml); \
	if [ -z "$$version" ]; then \
		echo "Error: could not detect version from alire/releases/crdt-latest.toml"; \
		exit 1; \
	fi; \
	echo "Publishing crdt $$version to Alire community index..."; \
	publish_dir="$$HOME/.local/share/alire/publish/community"; \
	orig_dir=$$(pwd); \
	if [ ! -d "$$publish_dir" ]; then \
		echo "Error: $$publish_dir not found"; \
		exit 1; \
	fi; \
	cd "$$publish_dir" && git pull && cd "$$orig_dir"; \
	alr publish "https://codeberg.org/bladeacer/Ada_CRDT/archive/v$$version.tar.gz" || true; \
	cd "$$publish_dir" && \
	git reset --soft HEAD~1 && \
	index_file="index/cr/crdt/crdt-$$version.toml"; \
	if [ -f "$$index_file" ]; then \
		sed -i \
			-e '/^executables = /d' \
			-e '/^\[\[depends-on\]\]/d' \
			-e '/^gnatprove = /d' \
			-e '/^gnatdoc_bin = /d' \
			"$$index_file"; \
		git add -A && \
		git commit -m "crdt $$version (via alr publish)" && \
		git push origin && \
		cd "$$orig_dir"; \
		echo "Published crdt $$version to community index."; \
	else \
		echo "Error: $$index_file not found in $$publish_dir"; \
		cd "$$orig_dir"; \
		exit 1; \
	fi

demo:
	alr exec -- gprbuild -Pdemo/demo.gpr
	stty -isig; ./demo/demo_life; stty isig

clean:
	alr clean
	rm -rf obj/ lib/ docs/
