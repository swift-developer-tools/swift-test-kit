# ``STKForAll(using:message:fileID:file:line:column:options:_:)-6h5i2``

Asserts that the given property holds for all inputs produced by the
given generators.

Use a generator when ``Arbitrary`` conformance of a specific type does
not produce the necessary distribution of values. For example, a
generator may be used to test only positive integers, or only non-empty
arrays.

SwiftTestKit assertions used inside a property body are automatically
intercepted rather than reported directly to Swift Testing.

- Important: Native Swift Testing assertions are not intercepted by
SwiftTestKit. If a native Swift Testing assertion fails inside a property
body, it bypasses shrinking and produces an immediate test failure. Use
only SwiftTestKit assertions inside property bodies.

- Parameters:
  - generators: The generators to use to produce values.
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
  falls back to using global options.
  - property: The property to evaluate.
