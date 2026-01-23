# XCTestKit

XCTestKit Summary



## Overview

XCTestKit Overview

### Diff Output

XCTestKit produces path-based diff output for assertion failures, providing 
clear insight into where values differ within complex data structures.

Below are examples of diff output for several common data types. The number 
of diffs shown, truncation behavior, and other formatting options may be 
configured at the global or assertion level.

**Nested Structs**

```swift
struct Inner: Equatable
{
    let id      : Int
    let value   : Int
    let label   : String
}

struct Outer: Equatable
{
    let tag     : String
    let inner   : Inner
}

let expected    = Outer(tag: "a", inner: Inner(id: 1, value: 100, label: "x"))
let actual      = Outer(tag: "a", inner: Inner(id: 1, value: 200, label: "x"))

XCTKAssertEqual(expected, actual)

/// XCTKAssertEqual failed:
///
/// Outer differs at:
///
///     .inner.value
///         Expected:   100
///         Actual:     200
```

**Arrays**

```swift
let expected    = [1, 2, 3, 4, 5, 6, 7, 8]
let actual      = [0, 0, 3, 4, 5, 6, 7, 0]

let options = XCTKOptions(formatOptions: .init(maxDiffs: 2))

XCTKAssertEqual(expected, actual, options: options)

/// XCTKAssertEqual failed:
///
/// Array<Int> differs at:
///
///     [0]
///         Expected:   1
///         Actual:     0
///
///     [1]
///         Expected:   2
///         Actual:     0
///
///     ... and 1 more difference
```

**Multi-Line Strings**

```swift
let expected    = "Line 1\nLine 2\nLine 3"
let actual      = "Line 1\nLine X\nLine 3"

XCTKAssertEqual(expected, actual)

/// XCTKAssertEqual failed:
///
/// String differs at:
///
///     line 2
///         Expected:   "Line 2"
///         Actual:     "Line X"
///         Changed:    character 6 ("2" → "X")
```

**Sets**

```swift
let expected    : Set<String>   = ["a", "b", "c"]
let actual      : Set<String>   = ["a", "e", "f"]

XCTKAssertEqual(expected, actual)

/// XCTKAssertEqual failed:
///
/// Set<String> differs:
///
///     Missing:    "b"
///     Missing:    "c"
///     Unexpected: "e"
///     Unexpected: "f"
```



## Documentation

See [XCTestKit documentation](https://swift-developer-tools.github.io/xctestkit/documentation/xctestkit) 
for the complete API reference. 



## Installation

### Swift Package Manager

XCTestKit may be installed using 
[Swift Package Manager](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/).

See [Xcode documentation](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) 
for instructions on how to add package dependencies.

### Requirements

| Platform     | Minimum Version |
|--------------|-----------------|
| Swift        | 6.1             |
| iOS          | 18.0            |
| iPadOS       | 18.0            |
| Mac Catalyst | 18.0            |
| macOS        | 15.0            |
| tvOS         | 18.0            |
| visionOS     | 2.0             |
| watchOS      | 11.0            |



## Usage

XCTestKit Usage



## License

XCTestKit is licensed under the Apache License, Version 2.0.

See [LICENSE](https://github.com/swift-developer-tools/XCTestKit/blob/main/LICENSE.txt) 
for the complete license terms.



## Attribution

See [Licenses](https://github.com/swift-developer-tools/XCTestKit/tree/main/Licenses) 
for the complete third-party license terms.

### Swift.org

XCTestKit includes source code and documentation adapted from the 
[Swift.org](https://www.swift.org) open source project under the Apache License, 
Version 2.0, with Runtime Library Exception.

Copyright &copy; 2014 - 2016 Apple Inc. and the Swift project authors.

See [https://swift.org/LICENSE.txt](https://swift.org/LICENSE.txt) for license 
information.

See [https://swift.org/CONTRIBUTORS.txt](https://swift.org/CONTRIBUTORS.txt) 
for the list of Swift project authors.
