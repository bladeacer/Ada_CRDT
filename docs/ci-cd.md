# CI/CD

Ada_CRDT runs three GitHub Actions workflows. All of them use
`actions/checkout@v7` and run on `ubuntu-latest`. They consume the
published `bladeacer/adacovex@v1` action or the local `make` targets. CI
needs no adacovex source checkout or local development setup.

| Workflow | File | Trigger | Jobs |
|----------|------|---------|------|
| CI | `.github/workflows/ci.yml` | push to `main`, all PRs | `assessment`, `native-tests`, `static-gates`, `spark-off-check`, `coverage-gate` (push only), `summary` |
| PR compliance gate | `.github/workflows/pr-check.yml` | all PRs | `coverage-delta` |
| Release | `.github/workflows/release.yml` | `v*` tags | `release`, `summary` |

The action reference is the floating `@v1` tag, which resolves to the newest
`v1.x.y` release. Ada_CRDT is a consumer of the action, so `build: false`
applies: the action downloads the published adacovex release binary. The value
`build: true` is only valid when the checked-out repository is adacovex itself,
because in a consumer workspace it runs `alr build` on this project and
produces no `bin/adacovex`.

The compiler comes from the action's `gnat-version` input (`15.2.1` here). The
prover is separate: `alire-dev.toml` declares `gnatprove = "^16.1.0"`, and the
`prove` subcommand resolves it, so the proof campaign runs on gnatprove 16.1.0
against a 15.2.1 compiler. That is the combination the
[proof ledger](proof/16.1.0-ledger.md) records.

## CI (`ci.yml`)

Runs on every push to `main` and every pull request. Superseded runs are
cancelled through the `ci-${{ github.ref }}` concurrency group, because a
proof run costs minutes and a push makes the open pull-request run obsolete.

- **assessment** -- SPARK proof and DO-178C DAL-C assessment run via the
  `bladeacer/adacovex@v1` action (`target: .`, `dal: C`, `build: false`,
  `prove: true`, `prove-no-loop-unrolling: true`, `verbose: true`,
  `gnat-version: 15.2.1`). The four threshold inputs are set: `require-spark:
  Platinum`, `require-docstrings: 100`, `require-tests: 10332`, and
  `require-proof: 100`. Without them the assessment only reports, and a dropped
  docstring, a lower proof level, an unproved check, or a lost test would reach
  `main` and surface for the first time on a release tag.
- **native-tests** -- `alr build` then `./test_crdt`, the 10332-test native
  suite.
- **static-gates** -- the pure-Python gates, with no Alire and no toolchain:
  `make ascii-check`, `make changelog-check`, `make link-check`,
  `make docs-check`, and `python3 tools/update-doc-links.py --check`. The same
  set runs locally inside `make check`, so this job stops prose that fails the
  gate from being merged.
- **spark-off-check** -- Also pure-static (Python 3 only). Run
  `make spark-off-check`. It fails when any `SPARK_Mode => Off` location in the
  source is missing from the committed spark-coverage report
  (`docs/api-docs/crdt-spark-coverage.md`). New Off locations cannot land
  undocumented.
- **coverage-gate** -- A docstring-coverage gate against the last release tag.
  It mirrors the local `make coverage-gate` target. It resolves the previous
  `vX.Y.Z` tag (`git tag --sort=-version:refname`) and runs the action with
  `coverage-delta: <prev-tag>`. The job is skipped on pull requests and when no
  previous release tag exists, because the pull-request delta in
  `pr-check.yml` already covers the regression that a pull request can
  introduce.
- **summary** -- Writes the job table to the workflow summary and fails the
  run if any job failed.

## PR compliance gate (`pr-check.yml`)

Runs on every pull request.

- **coverage-delta** -- A docstring-coverage delta against the pull-request
  base commit. Run `bladeacer/adacovex@v1` with `coverage-delta: ${{
  github.event.pull_request.base.sha }}`. Any pull request that drops docstring
  coverage below the base revision fails.

## Release (`release.yml`)

Runs on `v*` tags. Builds and publishes the release artifacts:

1. Build + run the native test suite.
2. SPARK proof + assessment via the `bladeacer/adacovex@v1` action
   (`build: true`, because the tag build packages adacovex from source). The
   same four thresholds apply: Platinum, 100% docstrings, 10332 tests, and
   100% proved checks. A follow-up step re-checks the `spark-level` output, so
   a threshold regression fails with a message that names the level.
3. Generate the proof-aware SBOM.
4. Attest the release artifacts with Sigstore (`actions/attest@v4`).
5. Create the GitHub release (`gh release create`).
6. Update floating version tags.
7. `summary` job aggregates the result into the workflow summary.

The release-note step lists the changelog entries
(`docs/changelogs/crdt-*.md`). It shows entries available in the tree
between the previous release tag and the released version, newest first.
The list is derived from the changelog files present, not from git tags.
Each entry links to the changelog page on the deployed manual
(<https://ada-crdt.readthedocs.io/>), not to the file on GitHub.

## Local equivalents

Every CI gate has a local `make` target. `make check` runs the full local
quality gate in the same order as CI. See the
[quality gates page](contributing/quality-gates.md) for every target and what
it proves.

| CI job | Local target |
|--------|--------------|
| assessment / release SPARK gate | `make prove` + `make compliance` |
| native-tests | `make test` |
| static-gates | `make ascii-check changelog-check link-check docs-check` + `python3 tools/update-doc-links.py --check` |
| spark-off-check | `make spark-off-check` |
| coverage-gate / coverage-delta | `make coverage-gate` |
