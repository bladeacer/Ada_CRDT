--  Root package for clock strategy selection.
--  Provides interchangeable Lamport, Vector, and Matrix clock strategies.
--
--  Requirements traceability:
--  - HLR-CORE-CLOCKS: Clock strategy interface and selection
package CRDT.Clocks with
  SPARK_Mode
is

   --  Identifies which clock strategy serialized data uses.
   --  Embedded in V3 wire protocol header for auto-detection.
   --  Prefix avoids ambiguity with child package names.
   --  @field Clock_Lamport  Lamport logical clock (lightweight, total order).
   --  @field Clock_Vector   Vector clock (causal history, recommended default).
   --  @field Clock_Matrix   Matrix clock (full peer knowledge tracking).
   type Clock_Kind is (Clock_Lamport, Clock_Vector, Clock_Matrix);

end CRDT.Clocks;
