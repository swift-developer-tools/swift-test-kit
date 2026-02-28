# Temporal Testing

Poll assertions over a configurable duration to verify continuous invariants 
or eventual convergence.

## Overview

Temporal tests wrap XCTestKit assertions and poll continuously for a given 
duration, or until all assertions pass within a single execution. Any XCTestKit 
assertion can be used inside a temporal test.

### Assertion Interception

XCTestKit assertions used inside a temporal body are automatically intercepted 
rather than reported directly to XCTest. This allows XCTestKit to re-poll 
without producing intermediate test failures. After polling completes, any 
failures are reported along with the intercepted assertion output.

- Important: Native XCTest assertions are not intercepted by XCTestKit. If a 
native XCTest assertion fails inside a temporal test, it bypasses polling and 
produces an immediate test failure. Use only XCTestKit assertions inside 
temporal tests.

## Topics

### Temporal Tests

- ``XCTKAlways(timeout:interval:_:fileID:file:line:column:options:_:)``
- ``XCTKEventually(timeout:interval:_:fileID:file:line:column:options:_:)``
