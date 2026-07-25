.PHONY: help all build run test test-fuzz prove doc api-docs compliance ascii-check clean release publish demo

.DEFAULT_GOAL := help

help:
	@echo 'CRDT - CRDT library for Ada/SPARK'
	@echo ''
	@echo 'Usage: make <target>'
	@echo ''
	@echo '  build         Build the project and tests (alr build)'
	@echo '  run           Build and run tests'
	@echo '  test          Alias for run'
	@echo '  test-fuzz     Run chaos fuzzing (bit-flip + clock skew + OOO delta)'
	@echo '  prove         Run SPARK proofs (alr gnatprove)'
	@echo '  doc           Generate Markdown API docs (docs/api-docs/)'
	@echo '  compliance    Verify DO-178C traceability (HLR tags in source)'
	@echo '  ascii-check   Enforce ASCII-only charset across all source files'
	@echo '  release       Tag, update index+releases, push. Use VERSION=x.y.z'
	@echo '  publish       Publish to Alire community index (run after make release)'
	@echo '  test-publish  Dry-run showing what make publish would do'
	@echo '  demo          Build and run the Game of Life demo'
	@echo '  clean         Remove build artifacts'
	@echo '  help          Show this message'

build:
	tmpfile=$$(mktemp); \
	alr build > $$tmpfile 2>&1; result=$$?; \
	grep -v "no .sframe will be created" $$tmpfile; \
	rm -f $$tmpfile; exit $$result

run: build
	alr run

test: run

test-fuzz: run

prove:
	alr gnatprove

compliance:
	@echo "=== DO-178C Traceability Verification ==="; \
	errors=0; \
	srcdir=src; \
	\
	hlr_file="docs/compliance/HLR.md"; \
	llr_file="docs/compliance/LLR.md"; \
	trace_file="docs/compliance/TRACE.md"; \
	index_file="docs/compliance/index.md"; \
	\
	echo "--- HLR tag scan ---"; \
	source_hlrs=$$(grep -rn -- '--.*HLR-' $$srcdir | sed 's/.*HLR-\([A-Z0-9-]*\).*/\1/' | sort -u); \
	src_count=$$(echo "$$source_hlrs" | wc -l); \
	echo "HLR tags found in source: $$src_count"; \
	for hlr in $$source_hlrs; do \
		found=$$(grep -rl -- "--.*HLR-$$hlr" $$srcdir 2>/dev/null); \
		if [ -z "$$found" ]; then \
			echo "  MISSING: HLR-$$hlr — no source file has this tag"; \
			errors=$$((errors + 1)); \
		else \
			echo "  HLR-$$hlr -> $$(echo $$found | tr ' ' ',' | sed 's,$(CURDIR)/,,g')"; \
		fi; \
	done; \
	\
	if [ -f "$$hlr_file" ]; then \
		echo ""; \
		echo "--- HLR.md coverage ---"; \
		doc_hlrs=$$(sed -n 's/.*HLR-\([A-Z0-9-]*\).*/\1/p' "$$hlr_file" | sort -u); \
		for hlr in $$source_hlrs; do \
			if ! echo "$$doc_hlrs" | grep -q "$$hlr"; then \
				echo "  MISSING in HLR.md: HLR-$$hlr"; \
				errors=$$((errors + 1)); \
			fi; \
		done; \
		for hlr in $$doc_hlrs; do \
			if ! echo "$$source_hlrs" | grep -q "$$hlr"; then \
				echo "  STALE in HLR.md: HLR-$$hlr (not in source)"; \
				errors=$$((errors + 1)); \
			fi; \
		done; \
		if [ $$errors -eq 0 ]; then echo "  All HLRs in source match HLR.md."; \
		fi; \
	else \
		echo "  MISSING: $$hlr_file"; \
		errors=$$((errors + 1)); \
	fi; \
	\
	for f in "$$llr_file" "$$trace_file" "$$index_file"; do \
		if [ -f "$$f" ]; then echo "  $$f — present"; \
		else echo "  $$f — MISSING"; errors=$$((errors + 1)); fi; \
	done; \
	\
	echo ""; \
	if [ "$$errors" -eq 0 ]; then \
		echo "All compliance checks passed."; \
	else \
		echo "$$errors compliance issue(s) found."; \
		exit 1; \
	fi

ascii-check:
	@echo "=== ASCII Charset Verification ==="; \
	extensions="ads adb md py toml gpr yaml yml"; \
	error=0; \
	for ext in $$extensions; do \
		files=$$(find . -name "*.$$ext" -not -path "./.git/*" -not -path "./alire/*" -not -path "./config/*" -not -path "./obj/*" 2>/dev/null); \
		for f in $$files; do \
			case "$$f" in *vt100*|*README.md|*docs/api-docs/*) continue;; esac; \
	if LC_ALL=C grep -q '[^ -~	]' "$$f" 2>/dev/null; then \
				echo "  NON-ASCII: $$f"; \
				error=$$((error + 1)); \
			fi; \
		done; \
	done; \
	if [ $$error -eq 0 ]; then \
		echo "All source files are pure ASCII."; \
	else \
		echo "$$error file(s) contain non-ASCII characters."; \
		exit 1; \
	fi

doc: api-docs

api-docs:
	mkdir -p obj
	alr exec -- gnatdoc -P crdt.gpr --backend=rst --generate private --output-dir=obj/gnatdoc-rst
	python3 tools/rst2md.py obj/gnatdoc-rst docs/api-docs
	rm -f docs/api-docs/test_*.md docs/api-docs/crdt-test_support.md
	sed -i '/](test_[^)]*\.md)/d' docs/api-docs/index.md
	sed -i '/](crdt-test_support\.md)/d' docs/api-docs/index.md
	python3 tools/gen-coverage.py
	@echo "Regenerating docs/changelogs/index.md..."
	@{ \
	  echo "# CRDT Changelogs"; \
	  echo ""; \
	  echo "<!-- CHANGELOG_LIST -->"; \
	  list=""; \
	  for f in docs/changelogs/crdt-*.md; do \
	    v=$$(basename "$$f" .md | sed 's/crdt-//'); \
	    case "$$v" in *-migration|index) continue;; esac; \
	    list="$$list$$v "; \
	  done; \
	  for v in $$(echo $$list | tr ' ' '\n' | sort -t. -k1,1rn -k2,2rn -k3,3rn); do \
	    echo "- [$$v](crdt-$$v.md)"; \
	  done; \
	  echo ""; \
	  echo "## Protocol Migration"; \
	  echo ""; \
	  echo "- [V1 -> V2 Migration Guide](crdt-1.4.0-migration.md) -- how \`Read_Header\`"; \
	  echo "  auto-detects wire format, and how to write V1 for legacy peers"; \
	} > docs/changelogs/index.md
	@echo "Validating changelog links..."
	@for f in docs/changelogs/*.md; do \
	  base=$$(dirname "$$f"); \
	  for link in $$(sed -n 's/.*\[.*\](\([^)]*\.md\)).*/\1/p' "$$f"); do \
	    resolved="$$base/$$link"; \
	    if [ ! -f "$$resolved" ] && [ ! -f "docs/changelogs/$$link" ]; then \
	      echo "ERROR: broken link '$$link' in $$f"; \
	      exit 1; \
	    fi; \
	  done; \
	done; \
	echo "All changelog links OK"

dev-setup:
	@echo "Setting up development environment with dev dependencies..."; \
	cp alire-dev.toml alire.toml; \
	echo "alire.toml now has development dependencies (gnatprove, gnatdoc_bin)."; \
	echo "Run 'make prod-setup' to restore the clean publishing manifest."

prod-setup:
	@echo "Restoring clean publishing manifest..."; \
	git checkout alire.toml; \
	echo "alire.toml restored to clean publishing version."

release:
	@if [ -n "$(VERSION)" ]; then \
		version="$(VERSION)"; \
		sed -i 's/^version = ".*"/version = "'$$version'"/' alire.toml; \
		sed -i 's/^version = ".*"/version = "'$$version'"/' alire-dev.toml; \
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
	echo "Pushed commit and tag v$$version"; \
	echo ""; \
	echo "Next: run 'make publish' to submit to Alire community index."

publish:
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "Error: working tree is not clean. Commit or stash changes first."; \
		exit 1; \
	fi; \
	alr publish

test-publish:
	@version=$$(git describe --tags --abbrev=0 2>/dev/null || \
		sed -n 's/^version = "\(.*\)"/\1/p' alire.toml); \
	echo "=== test-publish dry-run ==="; \
	echo "Version:  $$version"; \
	echo "Action:   alr publish (auto-detects GitHub, test deps excluded)"; \
	echo "Requires: GitHub PAT in GITHUB_TOKEN env var or gh auth token"; \
	echo "Docs:     https://github.com/alire-project/alire/blob/master/doc/publishing.md"; \
	echo "=== end dry-run ==="

demo:
	cd demo && alr build
	stty -isig; ./demo/demo_life; stty isig

clean:
	alr clean
	rm -rf obj/ lib/ docs/
