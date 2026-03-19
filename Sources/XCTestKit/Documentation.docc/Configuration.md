# Configuration

Configurable testing options.

## Overview

Options may be configured at three precedence levels:

1. The global level: Applies everywhere by default.
2. The closure level: Applies within a closure.
3. The API level: Applies to a single API.

### Global Configuration

Use ``TestConfiguration`` to set options that apply everywhere by default.

```swift
TestConfiguration.global.diffOptions.maxRecursionDepth  = 20
TestConfiguration.global.formatOptions.maxDiffs         = 5
```

- Important: ``TestConfiguration`` is thread-safe, but modifying global
options during parallel test executions may cause logical races. Use
scoped configuration, or set global options once before tests begin.

### Scoped Configuration

Use ``TestConfiguration`` scoping methods to apply options to a closure. All 
tests executed within the given closure use the scoped options instead of the 
global options, unless those tests explicitly specify options.

```swift
let options = TestOptions(formatOptions: .init(maxDiffs: 10))

TestConfiguration.withOptions(options)
{
    // Test with scoped options.
    XCTKAssertEqual(expected, actual)
}
```

Provide a modification closure to modify individual properties without 
replacing the entire options:

```swift
TestConfiguration.withOptions({ $0.formatOptions.maxDiffs = 10 })
{
    // Test with scoped options.
    XCTKAssertEqual(expected, actual)
}
```

### API-Level Configuration

Pass options directly to any API to override all other configurations for 
that call.

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
