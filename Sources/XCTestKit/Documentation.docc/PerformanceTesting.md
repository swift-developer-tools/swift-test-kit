# Performance Testing

Measure execution time and physical memory footprint across multiple runs, 
and verify that median values stay within configurable limits.

## Overview

Performance tests measure a closure across multiple runs, with optional 
warmup runs, and fail if the median time or median physical memory footprint 
exceeds the configured limits.

## Topics

### Measuring Performance

- ``XCTKPerformance(runs:warmupRuns:timeLimit:memoryLimit:_:fileID:file:line:column:options:_:)``
- ``ByteCount``
