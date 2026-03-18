# Configuration

Configurable testing options.

## Overview

XCTestKit may be configured at the global or assertion level. Options passed 
to individual assertions take precedence over global options.

### Global Configuration

Use ``TestConfiguration`` to set options that apply to all assertions by 
default.

```swift
TestConfiguration.global.diffOptions.maxRecursionDepth  = 20
TestConfiguration.global.formatOptions.maxDiffs         = 5
```

### Assertion Configuration

Pass options directly to any assertion to override global options for that 
function call.

```swift
let options = TestOptions(formatOptions: .init(maxDiffs: 10))

XCTKAssertEqual(expected, actual, options: options)
```

## Topics

- ``TestConfiguration``
- ``TestOptions``
- ``DiffOptions``
- ``FormatOptions``
- ``PropertyOptions``
- ``TemporalOptions``
- ``PerformanceOptions``
