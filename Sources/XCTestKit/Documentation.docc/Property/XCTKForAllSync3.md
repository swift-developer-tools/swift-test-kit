# ``XCTKForAll(where:message:fileID:file:line:column:options:_:)-4xj6q``

Asserts that the given property holds for all generated inputs that satisfy
the given precondition.

Inputs that do not satisfy the precondition are discarded. If too many
inputs are discarded relative to the max discard ratio, the test fails
with an exhaustion error.

- Important: Preconditions that reject most inputs waste iterations and
can lead to exhaustion. Prefer constructing valid inputs using a custom
``Generator`` rather than discarding invalid inputs with a precondition.

XCTestKit assertions used inside a property body are automatically
intercepted rather than reported directly to XCTest.

- Important: Native XCTest assertions are not intercepted by XCTestKit.
If a native XCTest assertion fails inside a property body, it bypasses
shrinking and produces an immediate test failure. Use only XCTestKit
assertions inside property bodies.

- Parameters:
  - precondition: The condition which generated inputs must satisfy.
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
