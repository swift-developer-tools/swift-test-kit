# Temporal Testing

Poll assertions over a configurable duration to verify continuous invariants 
or eventual convergence.

## Overview

Temporal tests wrap SwiftTestKit assertions and poll continuously for a given 
duration, or until all assertions pass within a single execution. Any 
SwiftTestKit assertion can be used inside a temporal test.

### Assertion Interception

SwiftTestKit assertions used inside a temporal body are automatically 
intercepted rather than reported directly to Swift Testing. This allows 
SwiftTestKit to re-poll without producing intermediate test failures. After 
polling completes, any failures are reported along with the intercepted 
assertion output.

- Important: Native Swift Testing assertions are not intercepted by 
SwiftTestKit. If a native Swift Testing assertion fails inside a temporal test, 
it bypasses polling and produces an immediate test failure. Use only 
SwiftTestKit assertions inside temporal tests.

## Topics

### Temporal Tests

- ``STKAlways(timeout:interval:_:fileID:file:line:column:options:_:)``
- ``STKEventually(timeout:interval:_:fileID:file:line:column:options:_:)``
