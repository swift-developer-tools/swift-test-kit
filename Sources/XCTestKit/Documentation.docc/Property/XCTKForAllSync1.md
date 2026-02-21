# ``XCTKForAll(_:fileID:file:line:column:options:_:)-8p99k``

Asserts that the given property holds for all generated inputs.

XCTestKit assertions used inside a property body are automatically
intercepted rather than reported directly to XCTest.

- Important: Native XCTest assertions are not intercepted by XCTestKit.
If a native XCTest assertion fails inside a property body, it bypasses
shrinking and produces an immediate test failure. Use only XCTestKit
assertions inside property bodies.

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
  - options: The options for testing. The default value is `nil`, which
  falls back to using global options.
  - property: The property to evaluate.
