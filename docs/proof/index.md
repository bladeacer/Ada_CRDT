# Proof records

This section holds the formal-verification evidence for the CRDT library. The
records here answer one question: which code did gnatprove check, which code did
it skip, and why.

## The current ledger

- [Proof ledger (gnatprove 16.1.0)](16.1.0-ledger.md) -- the verified-condition
  history for the current proof campaign, and the audit of every skipped unit
  with its reason.

The ledger is a historical record. It states the totals for one gnatprove
release, so a later campaign can be compared with it.

## The current numbers

The live numbers come from the gate output, not from a page that a human
edited. `make prove` writes `obj/gnatprove/gnatprove.out`, and `make compliance`
renders it into [VERIFICATION.md](../compliance/VERIFICATION.md), which also
carries the test results and the compliance summary.

| Metric | Value |
|--------|-------|
| Total checks | 972 |
| Proved | 972 (100%) |
| Justified | 0 |
| Unproved | 0 |
| Analysed subprograms | 189 |
| Skipped | 10 generic units, and 102 subprograms under a `SPARK_Mode => Off` annotation |
| SPARK level | Platinum |

Two numbers describe the same gap from different sides. The proof output
reports 102 subprograms skipped for `SPARK_Mode => Off`, and the
[coverage report](../api-docs/crdt-spark-coverage.md) lists 34 annotations
that switch SPARK off, because one annotation on a package or a protected type
covers several subprograms.

## Why a unit is skipped

The proof covers every unit that SPARK can analyse. The skipped units are
listed with one reason each in the
[coverage report](../api-docs/crdt-spark-coverage.md), and the reasons fall into
four groups:

| Reason | Examples | Why it is excluded |
|--------|----------|--------------------|
| Generic packages | `CRDT.Rga`, `CRDT.Lww_Sets`, the sequence engines | SPARK analyses a generic instance, not the generic itself, and the library has no single instance to prove |
| Wall-clock access | `CRDT.HLC.Create`, `Tick`, `Recv` | The value comes from outside the program, so no contract can bound it |
| Stream input and output | The `Read_Clock`, `Write_Clock`, and serialisation routines | The stream is a run-time object with an unbounded buffer |
| Random numbers | `New_Replica_Id` and the random-number package | A random value has no provable bound |
| Access types | The RGA, Naive, and Fugue engine bodies | Access values escape into the heap, and SPARK does not analyse that shape |

A new skipped unit needs an inline justification comment and an entry in the
coverage report. `make spark-off-check` fails the build when a location is
missing from the report.

## How to read the numbers

A justified check is a check that gnatprove could not discharge and that a
person accepted with a written argument. A justified check is a claim, not a
proof, so the project holds that number at zero.

An unproved check is a check that gnatprove could not discharge. The project
holds that number at zero as well, which is the Gold and Platinum baseline. The
[test results](../compliance/VERIFICATION.md) cover the code that the proof does
not reach.

## See also

- [Verification results](../compliance/VERIFICATION.md) -- proof metrics, test
  results, and the compliance summary.
- [SPARK coverage](../api-docs/crdt-spark-coverage.md) -- every skipped location
  with its justification.
- [Quality gates and make targets](../contributing/quality-gates.md) -- how the
  proof runs and how the reports are regenerated.
- [DO-178C compliance](../compliance/index.md) -- the safety case that the
  evidence supports.
