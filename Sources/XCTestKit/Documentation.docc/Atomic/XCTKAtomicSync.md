# ``XCTKAtomic(_:fileID:file:line:column:_:)-aham``

Asserts that all assertions in the given body pass.

The atomic body is executed once, running all assertions regardless of
individual failures. All assertion failures are reported together.

- Important: Use only XCTestKit assertions inside atomic bodies.
Native XCTest assertions are not intercepted.

- Parameters:
  - message: An optional description of a failure.
  - fileID: The ID of the file where the failure occurs. The default value
  is the ID of the file of the test case in which this function was called.
  - file: The file where the failure occurs. The default value is the
  filename of the test case in which this function was called.
  - line: The line where the failure occurs. The default value is the line
  number where this function was called.
  - column: The column where the failure occurs. The default value is the
  column number where this function was called.
  - body: The atomic body.
