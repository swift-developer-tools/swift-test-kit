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

- Note: See specific framework documentation for additional usage information.

## Topics

### Testing Options

- ``TestOptions``
- ``DiffOptions``
- ``FormatOptions``
- ``PropertyOptions``

### Property-Based Testing

- ``Arbitrary``
- ``Generator``
- ``GenerationContext``
