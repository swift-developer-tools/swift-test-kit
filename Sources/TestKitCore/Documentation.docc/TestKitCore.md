# ``TestKitCore``

@Metadata {
    @DisplayName("SwiftTestKit and XCTestKit Core")
}

Core types shared by SwiftTestKit and XCTestKit.

## Overview

[SwiftTestKit](https://swift-developer-tools.github.io/swift-test-kit/documentation/swifttestkit) 
and [XCTestKit](https://swift-developer-tools.github.io/swift-test-kit/documentation/xctestkit) 
extend Swift's testing frameworks with composable test evaluators, advanced 
assertions, structural diffs, and expression capture. Both libraries are 
included in the swift-test-kit package.

SwiftTestKit integrates directly with 
[Swift Testing](https://developer.apple.com/xcode/swift-testing), and XCTestKit 
integrates directly with 
[XCTest](https://developer.apple.com/documentation/xctest). Both libraries 
provide identical APIs.

This module contains the core types shared by both SwiftTestKit and XCTestKit. 
These types are automatically available when importing either library.

```swift
// Includes core types for SwiftTestKit.
import SwiftTestKit

// Includes core types for XCTestKit.
import XCTestKit
```

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
