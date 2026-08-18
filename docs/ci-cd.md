# CI/CD

Ada_CRDT runs three GitHub Actions workflows. All of them use
`actions/checkout@v7`, run on `ubuntu-latest`, and consume the published
`bladeacer/adacovex@v1` action (or the local `make` targets) -- no
adacovex source checkout or local dev setup is required on CI.

| Workflow | File | Trigger | Jobs |
|----------|------|---------|------|
| CI | `.github/workflows/ci.yml` | push to `main`, all PRs | `assessment`, `native-tests`, `spark-off-check`, `coverage-gate` |
| PR compliance gate | `.github/workflows/pr-check.yml` | all PRs | `coverage-delta` |
| Release | `.github/workflows/release.yml` | `v*` tags | `release`, `release-summary` |

## CI (`ci.yml`)

Runs on every push to `main` and every pull request.

- **assessment** -- SPARK proof + DO-178C DAL-C assessment via the
  `bladeacer/adacovex@v1` action (`target: .`, `dal: C`, `build: false`,
  `prove: true`, `gnat-version: 15.2.1`). `build: false` makes the action
  download the adacovex release binary: `build: true` is only valid when the
  checked-out repository *is* adacovex (self-assessment), and would otherwise
  just run `alr build` on this project without producing a `bin/adacovex`.
- **native-tests** -- `alr build` + `./test_crdt` (the 10290-test native
  suite).
- **spark-off-check** -- pure-static gate (Python 3 only, no Alire/toolchain):
  `make spark-off-check`. Fails when any `SPARK_Mode => Off` location in the
  source is missing from the committed spark-coverage report
  (`docs/api-docs/crdt-spark-coverage.md`), so new Off locations cannot land
  undocumented.
- **coverage-gate** -- docstring-coverage gate vs the last release tag,
  mirroring the local `make coverage-gate` target. Resolves the previous
  `vX.Y.Z` tag (`git tag --sort=-version:refname`), then runs the action with
  `coverage-delta: <prev-tag>`. The job is skipped when no previous release
  tag exists.

## PR compliance gate (`pr-check.yml`)

Runs on every pull request.

- **coverage-delta** -- docstring-coverage delta vs the PR base commit:
  `bladeacer/adacovex@v1` with `coverage-delta: ${{ github.event.pull_request.base.sha }}`.
  Any PR that drops docstring coverage below the base revision fails.

## Release (`release.yml`)

Runs on `v*` tags. Builds and publishes the release artifacts:

1. Build + run the native test suite.
2. SPARK proof + assessment via the `bladeacer/adacovex@v1` action
   (Platinum level required, 100% docstrings, 0 unproved VCs).
3. Generate the proof-aware SBOM.
4. Attest the release artifacts with Sigstore (`actions/attest@v4`).
5. Create the GitHub release (`gh release create`).
6. Update floating version tags.
7. `release-summary` job aggregates the results into the workflow summary.

The release-note step lists the changelog entries
(`docs/changelogs/crdt-*.md`) available in the tree between the previous
release tag and the released version -- derived from the changelog files
present, not from git tags.

## Local equivalents

Every CI gate has a local `make` target, and `make check` runs the full
local quality gate in the same order as CI (see the [Makefile targets
table](../AGENTS.md) in AGENTS.md):

| CI job | Local target |
|--------|--------------|
| assessment / release SPARK gate | `make prove` + `make compliance` |
| native-tests | `make test` |
| spark-off-check | `make spark-off-check` |
| coverage-gate / coverage-delta | `make coverage-gate` |

`make link-check` (markdown link + anchor verification, `tools/check-links.py`)
is a local-only static gate, mirroring adacovex -- it runs inside `make check`
but has no dedicated CI job.
