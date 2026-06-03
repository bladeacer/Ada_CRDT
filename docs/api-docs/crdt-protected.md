# CRDT.Protected

Thread-safe protected-object wrappers for CRDT types. Multiple tasks can concurrently mutate and query CRDT structures without external locking. Built on Ada's native protected objects.

## Types

### type Shared_PN_Counter
