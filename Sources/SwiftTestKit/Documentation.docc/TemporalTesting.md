# Temporal Testing

Poll assertions over a configurable duration to verify continuous invariants 
or eventual convergence.

## Overview

Temporal tests wrap SwiftTestKit assertions and poll continuously for a given 
duration, or until all assertions pass within a single execution.

## Topics

### Temporal Tests

- ``STKAlways(timeout:interval:_:fileID:file:line:column:options:_:)``
- ``STKEventually(timeout:interval:_:fileID:file:line:column:options:_:)``
