# ``TestKitBase``

@Metadata {
    @DisplayName("SwiftTestKit and XCTestKit Base")
}

Shared types used by both SwiftTestKit and XCTestKit.

## Overview

SwiftTestKit and XCTestKit share some of the same base types.
The base types are automatically available when importing either framework.

```swift
// Includes base types for SwiftTestKit.
import SwiftTestKit

// Includes base types for XCTestKit.
import XCTestKit
```

- Note: See specific framework documentation for additional usage information.

## Topics

### Testing Options

- ``TKOptions``
- ``TKDiffOptions``
- ``TKFormatOptions``
- ``TKPropertyOptions``

### Property-Based Testing

- ``Arbitrary``
- ``GenerationContext``
