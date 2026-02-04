# ``XCTestKit``

XCTestKit Summary



## Overview

XCTestKit Overview



## Diff Output

XCTestKit produces path-based diff output for assertion failures, providing 
clear insight into where values differ within complex data structures.

Below are examples of diff output for several common data types. The number 
of diffs shown, truncation behavior, and other formatting options may be 
configured at the global or assertion level.

### Nested Structs

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

/// XCTKAssertEqual failed
///
/// Outer differs at:
///
///     .inner.value
///         Expected:   100
///         Actual:     200
```

### Arrays

```swift
let expected    = [1, 2, 3, 4, 5, 6, 7, 8]
let actual      = [0, 0, 3, 4, 5, 6, 7, 0]

let options = XCTKOptions(formatOptions: .init(maxDiffs: 2))

XCTKAssertEqual(expected, actual, options: options)

/// XCTKAssertEqual failed
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

### Multi-Line Strings

```swift
let expected    = "Line 1\nLine 2\nLine 3"
let actual      = "Line 1\nLine X\nLine 3"

XCTKAssertEqual(expected, actual)

/// XCTKAssertEqual failed
///
/// String differs at:
///
///     line 2
///         Expected:   "Line 2"
///         Actual:     "Line X"
///         Changed:    character 6 ("2" → "X")
```

### Sets

```swift
let expected    : Set<String>   = ["a", "b", "c"]
let actual      : Set<String>   = ["a", "e", "f"]

XCTKAssertEqual(expected, actual)

/// XCTKAssertEqual failed
///
/// Set<String> differs:
///
///     Missing:    "b"
///     Missing:    "c"
///     Unexpected: "e"
///     Unexpected: "f"
```



## Expression Capture

Macro assertions capture the literal source text of expressions for use in 
failure output. For boolean macro assertions, compound expressions using `&&` 
and `||` are decomposed to show the value of each sub-expression and identify 
which caused the assertion failure, respecting short-circuit evaluation so only 
evaluated operands appear in the output. Other macro assertions capture the 
expression text without decomposition.

Below are examples of expression capture output for several common scenarios. 
The expression evaluation, short-circuiting behavior, and other formatting 
options may be configured at the global or assertion level.

### Boolean Decomposition

```swift
#XCTKAssertTrue(isValid() && hasAccess && count >= 10)
/// where isValid() -> true, hasAccess == false, count == 20

/// #XCTKAssertTrue failed
/// 
/// Expression: isValid() && hasAccess && count >= 10
/// 
///     isValid() = true
///     hasAccess = false ←
/// 
///     (1 expression not evaluated)
```

### Nested Expressions

```swift
#XCTKAssertFalse((a || b) && (c || d))
/// where a == true, b == false, c == true, d == false

/// #XCTKAssertFalse failed
/// 
/// Expression: (a || b) && (c || d)
/// 
///     a = true ←
///     c = true ←
/// 
///     (2 expressions not evaluated)
```

### Non-Boolean Assertions

```swift
#XCTKAssertNoThrow(try getValue())

/// #XCTKAssertNoThrow failed
/// 
/// Expression: try getValue()
/// Threw:      RequestError.timeout
```

```swift
#XCTKAssertNil(result.error)
/// where result.error == RequestError.timeout

/// #XCTKAssertNil failed
/// 
/// Expression: result.error
/// Actual:     RequestError.timeout
```



## Predicate Assertions

Predicate assertions verify conditions across collection elements and produce 
element-level failure output, identifying which elements failed, which were 
matched unexpectedly, and which threw errors.

Below are examples of predicate assertion output for several common scenarios. 
The number of elements shown, truncation behavior, and other formatting options 
may be configured at the global or assertion level.

### All Satisfy

```swift
XCTKAssertAllSatisfy([10, 15, 20, 25]) { $0.isMultiple(of: 10) }

/// XCTKAssertAllSatisfy failed
/// 
/// Collection count: 4
/// 
/// Failed: 2 of 4
/// 
///     [1]: 15
///     [3]: 25
```

### Exactly

```swift
#XCTKAssertExactly([30, 25, 10, 35, 15], count: 2) { $0 > 20 }

/// #XCTKAssertExactly failed
/// 
/// Collection count: 5
/// 
/// Collection: [30, 25, 10, 35, 15]
/// Predicate:  { $0 > 20 }
/// 
/// Expected: exactly 2 matches
/// Actual:   3 matched
/// 
///     Matched: [0-1], [3]
```

### Sorted

```swift
XCTKAssertSorted([10, 30, 20, 40], by: <)

/// XCTKAssertSorted failed
/// 
/// Collection count: 4
/// 
/// Not sorted at:
/// 
///     [1]: 30
///     [2]: 20
```

### Unique

```swift
XCTKAssertUnique(["aa", "bb", "c"], by: { $0.count })

/// XCTKAssertUnique failed
/// 
/// Collection count: 3
/// 
/// Duplicates: 1 key
/// 
///     Key 2:
///         [0]: "aa"
///         [1]: "bb"
```

### Error Handling

```swift
enum NumberError: Error { case invalid }

let values: [Int] = [20, -10, 40, -30, 60]

XCTKAssertSatisfy(values, atLeast: 4)
{
    value in

    guard value >= 0 else { throw NumberError.invalid }
    return value.isMultiple(of: 20)
}

/// XCTKAssertSatisfy failed
/// 
/// Collection count: 5
/// 
/// Expected: at least 4 matches
/// Actual:   3 matched, 2 threw errors
/// 
///     Matched: [0], [2], [4]
/// 
///     Threw errors:
///         [1]: -10 (threw error "invalid")
///         [3]: -30 (threw error "invalid")
```



## Documentation

See [SwiftTestKit documentation](https://swift-developer-tools.github.io/swift-test-kit/documentation/swifttestkit) 
and [XCTestKit documentation](https://swift-developer-tools.github.io/swift-test-kit/documentation/xctestkit) 
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

See [LICENSE](https://github.com/swift-developer-tools/swift-test-kit/blob/main/LICENSE.txt) 
for the complete license terms.



## Attribution

See [Licenses](https://github.com/swift-developer-tools/swift-test-kit/tree/main/Licenses) 
for the complete third-party license terms.

### Swift.org

XCTestKit includes a numeric equality utility adapted from the 
[Swift.org](https://www.swift.org) open source project under the Apache License, 
Version 2.0, with Runtime Library Exception.

Copyright &copy; 2014 - 2016 Apple Inc. and the Swift project authors.

See [https://swift.org/LICENSE.txt](https://swift.org/LICENSE.txt) for license 
information.

See [https://swift.org/CONTRIBUTORS.txt](https://swift.org/CONTRIBUTORS.txt) 
for the list of Swift project authors.



## Topics

### Articles

- <doc:Configuration>
- <doc:FunctionAssertions>
- <doc:MacroAssertions>
