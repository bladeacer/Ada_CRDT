# Ada_CRDT.Rgas

## Types

### RGA_Array

```ada
type RGA_Array is array (Positive range <>) of RGA_Entry;
```

### RGA_Entry

```ada
subtype RGA_Entry is RGA_Pkg.RGA (Max_RGA_Size);
```

### RGAs

```ada
type RGAs (Count : Positive) is private;
```

## Functions

### Get

```ada
function Get (RS : Ada_CRDT.Rgas.RGAs; Index : Standard.Positive) return Ada_CRDT.Rgas.RGA_Entry
```

| Parameter | Description |
|-----------|-------------|
| `RS` |  |
| `Index` |  |

### Size

```ada
function Size (RS : Ada_CRDT.Rgas.RGAs) return Standard.Natural
```

| Parameter | Description |
|-----------|-------------|
| `RS` |  |

## Procedures

### Append

```ada
procedure Append (RS : Ada_CRDT.Rgas.RGAs; R : Ada_CRDT.Rgas.RGA_Entry)
```

| Parameter | Description |
|-----------|-------------|
| `RS` |  |
| `R` |  |

### Merge_All

```ada
procedure Merge_All (RS : Ada_CRDT.Rgas.RGAs)
```

| Parameter | Description |
|-----------|-------------|
| `RS` |  |
