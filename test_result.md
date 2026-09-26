
  | Category                                           | Tests | Status |
  |----------------------------------------------------|-------|--------|
  | Basic: PN+LWW+RGA+RGAs                             |    34 | PASS   |
  | Clocks: Lamport+Vector+Matrix+Lww_Sets             |    40 | PASS   |
  | Lattice Properties: law check                      |     8 | PASS   |
  | RGA Features: interleave+split+delta+GC            |    56 | PASS   |
  | Serialization: V1+V2+byte-boundary                 |    62 | PASS   |
  | Engines: Yjs+Naive+Sync                            |    34 | PASS   |
  | Convergence: merge+skew+saturation                 |    21 | PASS   |
  | Fuzz: chaos+10k+partitions                         | 10038 | PASS   |
  | Game of Life: neighbors+blinker+sync+conv+mode     |    24 | PASS   |
  | Security: sha256+hmac+lms                          |    15 | PASS   |
  |----------------------------------------------------|-------|--------|

  Passed: 10332  Failed: 0
