# STE100 Technical Names for CRDT

ASD-STE100 Simplified Technical English (Section 1, "Words") defines a
controlled vocabulary. Most words in that vocabulary are standard STE words.
Some concepts have no accurate standard STE word. For those concepts, the
project approves a **Technical Name (TN)**.

A Technical Name is a non-STE word that the project explicitly approves. The
project approves it because no standard STE word describes the concept with
the same precision. A TN has a single mandatory part of speech and a defined
scope. The scope is restricted to the software domain of this CRDT library.

This page is the controlled list of Technical Names for this project. Writers
of user documentation, API documentation, docstrings, and changelogs must use
these terms as defined here. If you need a term that is not in this list,
add it to the list first, then use it.

## Categories for CRDT Technical Names

Group the Technical Names by their structural role in the software domain.

- **Ada and Tooling Entities.** Language features, tool names, and build
  system terms that generic English words cannot replace without losing
  technical precision. For example, SPARK, gnatprove, Alire.
- **CRDT and Distributed-Systems Terms.** Algorithmic and distributed-state
  terms that no standard STE word describes. For example, replica, merge,
  convergence, tombstone.
- **Code Identifier Names.** Exact package, type, subtype, subprogram, and
  variable names as declared in the source code. For example, `CRDT.Rga`,
  `Lamport_Time`. This category also covers exact file names, tool commands,
  and flag names that appear in documentation.

## Required data fields for each entry

ASD-STE100 requires strict controls over how approved words are documented.
Every Technical Name in this dictionary has all five fields:

| Field | Description | Example |
|-------|-------------|---------|
| **Approved Word (TN)** | The exact word or identifier. | **Replica** |
| **Part of Speech** | STE permits a word as only *one* part of speech (Noun, Verb, Modifier). | Noun |
| **Approved Meaning / Definition** | Clear, unambiguous definition restricted to the CRDT domain. | A node that holds a local copy of the shared state. |
| **Non-Approved Alternatives** | Terms that authors must NOT use instead of this TN. | *Peer*, *Node*, *Worker* |
| **Example Sentence** | A compliant STE sentence demonstrating usage. | *Each **replica** applies the operation and then merges the result.* |

## Key rules for CRDT Technical Names

- **Nouns stay nouns.** Technical Names are almost always approved as Nouns
  or Modifiers. Never approve a code action as a verb if a standard STE verb
  exists. For example, use the approved verb *Merge* is a noun; use the verb
  *combine* or *join* is not needed -- the noun *merge* describes the
  operation, and the verb *merge* is also approved here as a domain verb.
- **Exact case matching.** Treat Ada identifiers (`Pascal_Case` or
  `UPPER_CASE`) as literal Technical Names. Use the exact casing in
  documentation. This rule distinguishes language concepts from code
  entities.
- **No synonyms.** If the project approves *Replica* as a TN, do not use
  words like *Peer*, *Node*, or *Worker* for that concept.

## Dictionary

### Category: Ada and Tooling Entities

#### Technical Name: SPARK
- **Part of Speech:** Noun
- **Definition:** The formally analysable subset of Ada that the gnatprove
  proof tool verifies.
- **Approved Form:** SPARK (exact capitals)
- **Do Not Use:** Spark, spark, Ada subset (when SPARK is meant)
- **Correct Example:** *The core packages are written in **SPARK** and proved with gnatprove.*
- **Incorrect Example:** *The core packages are written in Spark and proved with gnatprove.*

#### Technical Name: gnatprove
- **Part of Speech:** Noun
- **Definition:** The SPARK proof tool that verifies absence of run-time
  errors and functional contracts.
- **Approved Form:** gnatprove (exact lower case)
- **Do Not Use:** The prover, The proof tool (when the tool name is meant)
- **Correct Example:** *Run **gnatprove** before you publish a release.*
- **Incorrect Example:** *Run the prover before you publish a release.*

#### Technical Name: Alire
- **Part of Speech:** Noun
- **Definition:** The Ada package manager that builds this library and
  resolves its toolchain.
- **Approved Form:** Alire (exact capitalisation)
- **Do Not Use:** The build system, The package manager (when the tool is meant)
- **Correct Example:** *Use **Alire** to build the test suite.*
- **Incorrect Example:** *Use the package manager to build the test suite.*

#### Technical Name: gnatdoc
- **Part of Speech:** Noun
- **Definition:** The tool that extracts API documentation from Ada source
  docstrings.
- **Approved Form:** gnatdoc (exact lower case)
- **Do Not Use:** The doc generator, The documentation tool
- **Correct Example:** *Run **gnatdoc** to rebuild the API reference.*
- **Incorrect Example:** *Run the documentation tool to rebuild the API reference.*

#### Technical Name: Generic
- **Part of Speech:** Modifier
- **Definition:** A unit that is parameterised and that a caller
  instantiates with actual parameters. Used with the nouns package,
  subprogram, or procedure.
- **Approved Form:** Generic (as modifier only)
- **Do Not Use:** Template, Parameterised unit (as a noun)
- **Correct Example:** *A **generic** package instantiates a clock strategy.*
- **Incorrect Example:** *A template package instantiates a clock strategy.*

### Category: CRDT and Distributed-Systems Terms

#### Technical Name: CRDT
- **Part of Speech:** Noun
- **Definition:** A Conflict-Free Replicated Data Type. A data type that
  replicas can update independently and that always converges after a merge.
- **Approved Form:** CRDT (singular), CRDTs (plural)
- **Do Not Use:** Replicated type, Sync type, Shared type
- **Correct Example:** *A **CRDT** merges concurrent updates without a central server.*
- **Incorrect Example:** *A replicated type merges concurrent updates without a central server.*

#### Technical Name: Replica
- **Part of Speech:** Noun
- **Definition:** A node that holds a local copy of the shared CRDT state.
- **Approved Form:** Replica (singular), Replicas (plural)
- **Do Not Use:** Peer, Node, Worker, Client (when the CRDT node is meant)
- **Correct Example:** *Each **replica** applies the operation and then merges the result.*
- **Incorrect Example:** *Each peer applies the operation and then merges the result.*

#### Technical Name: Merge
- **Part of Speech:** Verb, Noun
- **Definition:** The operation that joins two CRDT states into one state
  that both replicas can reach.
- **Approved Form:** Merge (verb), Merges (noun plural)
- **Do Not Use:** Sync (as a verb), Reconcile, Combine (when the CRDT join is meant)
- **Correct Example:** *Call **Merge** to join the remote state with the local state.*
- **Incorrect Example:** *Call sync to join the remote state with the local state.*

#### Technical Name: Convergence
- **Part of Speech:** Noun
- **Definition:** The property that all replicas hold the same state after
  they exchange and merge their updates.
- **Approved Form:** Convergence (singular)
- **Do Not Use:** Consistency, Agreement, Equality (when the CRDT property is meant)
- **Correct Example:** *The design guarantees **convergence** without a coordinator.*
- **Incorrect Example:** *The design guarantees consistency without a coordinator.*

#### Technical Name: Tombstone
- **Part of Speech:** Noun
- **Definition:** A marker that records a deleted element so that a later
  merge does not reintroduce it.
- **Approved Form:** Tombstone (singular), Tombstones (plural)
- **Do Not Use:** Deletion marker, Dead record, Ghost
- **Correct Example:** *The set keeps a **tombstone** for every removed element.*
- **Incorrect Example:** *The set keeps a deletion marker for every removed element.*

#### Technical Name: Lamport
- **Part of Speech:** Modifier
- **Definition:** Relating to the Lamport logical clock strategy that assigns
  a single scalar timestamp per update.
- **Approved Form:** Lamport (as modifier only)
- **Do Not Use:** Logical (when the Lamport strategy is meant)
- **Correct Example:** *The **Lamport** clock gives each update a scalar time.*
- **Incorrect Example:** *The logical clock gives each update a scalar time.*

#### Technical Name: HLC
- **Part of Speech:** Noun
- **Definition:** A Hybrid Logical Clock. It combines a wall-clock reading
  with a logical counter to order updates across replicas.
- **Approved Form:** HLC (singular)
- **Do Not Use:** Hybrid clock (first use only; define then abbreviate)
- **Correct Example:** *The **HLC** orders updates from different data centres.*
- **Incorrect Example:** *The hybrid clock orders updates from different data centres.*

#### Technical Name: LWW
- **Part of Speech:** Modifier, Noun
- **Definition:** Last-Writer-Wins. A CRDT that keeps the value with the
  latest timestamp when two replicas conflict.
- **Approved Form:** LWW (as modifier or noun)
- **Do Not Use:** Last write wins (spelled out after first definition),
  Latest-wins
- **Correct Example:** *The **LWW** set discards the older of two conflicting writes.*
- **Incorrect Example:** *The last write wins set discards the older of two conflicting writes.*

#### Technical Name: RGA
- **Part of Speech:** Noun
- **Definition:** A Replicated Growable Array. A sequence CRDT that orders
  concurrent inserts by tree position.
- **Approved Form:** RGA (singular), RGAs (plural)
- **Do Not Use:** Sequence, List (when the RGA type is meant)
- **Correct Example:** *The **RGA** keeps text edits in the correct order.*
- **Incorrect Example:** *The sequence keeps text edits in the correct order.*

#### Technical Name: Yjs
- **Part of Speech:** Modifier, Noun
- **Definition:** The chunk-based sequence engine that this library uses by
  default, modelled on the Yjs project.
- **Approved Form:** Yjs (exact capitals)
- **Do Not Use:** Y-js, YJS
- **Correct Example:** *The default **Yjs** engine stores characters in chunks.*
- **Incorrect Example:** *The default Y-js engine stores characters in chunks.*

#### Technical Name: Fugue
- **Part of Speech:** Modifier, Noun
- **Definition:** The binary-search-tree sequence engine that prevents
  character interleaving.
- **Approved Form:** Fugue (exact capitalisation)
- **Do Not Use:** Fugue engine (first use only; then Fugue)
- **Correct Example:** *The **Fugue** engine avoids interleaving on concurrent inserts.*
- **Incorrect Example:** *The fugue engine avoids interleaving on concurrent inserts.*

#### Technical Name: Bounded
- **Part of Speech:** Modifier, Noun
- **Definition:** A container variant that sizes its storage at instantiation
  time and that uses no heap allocation at run time.
- **Approved Form:** Bounded (as modifier or noun)
- **Do Not Use:** Fixed, Stack-based (when the bounded wrapper is meant)
- **Correct Example:** *The **bounded** wrapper removes all heap use.*
- **Incorrect Example:** *The fixed wrapper removes all heap use.*

#### Technical Name: Delta
- **Part of Speech:** Noun
- **Definition:** A small CRDT fragment that carries only the recent changes
  for a remote replica to apply.
- **Approved Form:** Delta (singular), Deltas (plural)
- **Do Not Use:** Patch, Diff (when the CRDT fragment is meant)
- **Correct Example:** *Send a **delta** instead of the full state.*
- **Incorrect Example:** *Send a patch instead of the full state.*
