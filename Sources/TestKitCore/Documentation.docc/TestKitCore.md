# ``TestKitCore``

@Metadata {
    @DisplayName("SwiftTestKit and XCTestKit Core")
}

Core types shared by SwiftTestKit and XCTestKit.

## Overview

SwiftTestKit and XCTestKit share the same core types. The core types are 
automatically available when importing either framework.

```swift
// Includes core types for SwiftTestKit.
import SwiftTestKit

// Includes core types for XCTestKit.
import XCTestKit
```

- Note: See 
[SwiftTestKit documentation](https://swift-developer-tools.github.io/swift-test-kit/documentation/swifttestkit) 
and 
[XCTestKit documentation](https://swift-developer-tools.github.io/swift-test-kit/documentation/xctestkit) 
for the complete API references.

## Topics

### Configuration

- ``TestConfiguration``
- ``TestOptions``
- ``DiffOptions``
- ``FormatOptions``
- ``PropertyOptions``
- ``TemporalOptions``
- ``PerformanceOptions``

### Performance Testing

- ``ByteCount``

### Property-Based Testing

- ``Arbitrary``
- ``Generator``
- ``GenerationContext``

### Stateful Testing

- ``Stateful``
- ``CommandStatistics``

### Errors

- ``UnwrapError``
