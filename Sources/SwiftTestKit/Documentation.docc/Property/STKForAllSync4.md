# ``STKForAll(using:where:examples:message:fileID:file:line:column:options:_:)-79unz``

Asserts that the given property holds for all values produced by the given
generators that satisfy the given precondition.

Values that do not satisfy the precondition are discarded. If too many
values are discarded relative to the max discard ratio, the test fails
with an exhaustion error.

- Important: Preconditions that reject most values waste iterations and
can lead to exhaustion. Prefer constructing valid values using
generator-level filtering rather than discarding invalid values with a
precondition.

- Important: Use only SwiftTestKit assertions inside property bodies. 
Native Swift Testing assertions are not intercepted.

- Parameters:
  - generators: The generators to use to produce values.
  - precondition: The condition which generated values must satisfy.
  - examples: The pinned values to test first. These values are not shrunk,
  are not mutated during targeted property-based testing, and do not
  respect the given precondition.
  - message: An optional description of a failure.
  - fileID: The ID of the file where the failure occurs. The default value
  is the ID of the file of the test case in which this function was called.
  - file: The file where the failure occurs. The default value is the
  filename of the test case in which this function was called.
  - line: The line where the failure occurs. The default value is the line
  number where this function was called.
  - column: The column where the failure occurs. The default value is the
  column number where this function was called.
  - options: The options for testing. The default value is `nil`, which
  falls back to the resolved options.
  - property: The property to evaluate.
