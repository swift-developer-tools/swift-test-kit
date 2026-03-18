# ``XCTKForAll(examples:message:fileID:file:line:column:options:_:)-7wpbg``

Asserts that the given property holds for all generated values.

- Important: Use only XCTestKit assertions inside property bodies. 
Native XCTest assertions are not intercepted.

- Parameters:
  - examples: The pinned values to test first. These values are not shrunk
  and are not mutated during targeted property-based testing.
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
