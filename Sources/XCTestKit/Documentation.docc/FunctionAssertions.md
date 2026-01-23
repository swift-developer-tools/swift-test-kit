# Function Assertions

Assert that certain conditions are satisfied during code execution, and record 
test failures with configurable diff output.

## Overview

<!-- TODO: Overview -->
XCTestKit assertions produce detailed path-based diffs for test failures, 
providing clear and actionable insight.

See <doc:Configuration> for information on configuring diffs.

<!-- TODO: Diff examples -->

## Topics

### Boolean Assertions

- ``XCTKAssert(_:_:file:line:)``
- ``XCTKAssertTrue(_:_:file:line:)``
- ``XCTKAssertFalse(_:_:file:line:)``

### Nil and Non-Nil Assertions

- ``XCTKAssertNil(_:_:file:line:)``
- ``XCTKAssertNotNil(_:_:file:line:)``
- ``XCTKUnwrap(_:_:file:line:)``
- ``XCTKUnwrapError``

### Equality and Inequality Assertions

- ``XCTKAssertEqual(_:_:_:file:line:options:)``
- ``XCTKAssertNotEqual(_:_:_:file:line:)``
- ``XCTKAssertIdentical(_:_:_:file:line:)``
- ``XCTKAssertNotIdentical(_:_:_:file:line:)``
- ``XCTKAssertEqual(_:_:accuracy:_:file:line:)-jeg2``
- ``XCTKAssertEqual(_:_:accuracy:_:file:line:)-13agy``
- ``XCTKAssertNotEqual(_:_:accuracy:_:file:line:)-4ufkt``
- ``XCTKAssertNotEqual(_:_:accuracy:_:file:line:)-4v5x3``
