# ``XCTestKit``

Structural diff output, expression capture, predicate assertions, and 
property-based testing for XCTest.



## Overview

XCTestKit extends the [XCTest](https://developer.apple.com/documentation/xctest) 
framework with advanced assertions and property-based testing.

When assertions fail, structural diffs pinpoint exactly where values diverge 
within complex data structures, using path-based output that scales from flat 
primitives to deeply-nested structs, collections, and multi-line strings. 

Macro assertions capture the literal source text of expressions and decompose 
compound boolean logic to identify which sub-expression caused the failure, 
making CI/CD logs actionable without needing access to the source code.

Predicate assertions verify conditions across collection elements and produce 
element-level failure output, identifying which elements failed, which matched 
unexpectedly, and which threw errors.

Property-based testing generates random inputs automatically, shrinks failures 
to minimal counterexamples, and reports failing inputs with the same rich 
assertion output used by standalone assertions.

- Note: To test with the 
[Swift Testing](https://developer.apple.com/xcode/swift-testing) framework, use 
[SwiftTestKit](https://swift-developer-tools.github.io/swift-test-kit/documentation/swifttestkit). 
SwiftTestKit and XCTestKit provide identical APIs.


## Diff Output

Assertion failures produce path-based diff output providing clear insight into 
where values differ within complex data structures.

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

let expected    = Outer(tag: "a", inner: Inner(id: 1, value: 100, label: "b"))
let actual      = Outer(tag: "a", inner: Inner(id: 1, value: 200, label: "b"))

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

let options = TestOptions(formatOptions: .init(maxDiffs: 2))

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



## Property-Based Testing

Describe properties that must hold for any given input, and XCTestKit will 
generate random test cases automatically. When an input causes a property to 
fail, XCTestKit will shrink the input to the smallest value that still fails 
the property (the minimal counterexample), and report it along with the full 
assertion output.

```swift
XCTKForAll
{
    (a: Int, b: Int) in
    
    // Addition is commutative. The assertion passes for all inputs.
    XCTKAssertEqual(a + b, b + a)
}
```

XCTestKit assertions are automatically intercepted inside property bodies, 
so counterexamples include the same diff output, expression capture, and 
formatting used by standalone assertions.

```swift
func customSort(_ array: [Int]) -> [Int] { /* ... */ }

XCTKForAll
{
    (array: [Int]) in
    
    // Assert that a custom sort function is working correctly.
    XCTKAssertSorted(customSort(array), by: >=)
}

/// XCTKForAll failed after 4 iterations (shrunk in 2 steps)
/// 
/// Counterexample:
///     Array<Int> = [1, 0]
/// 
/// Seed: 2188239925673862914 (re-run with PropertyOptions.seed)
/// 
/// XCTKAssertSorted failed
/// 
/// Collection count: 2
/// 
/// Not sorted at:
/// 
///     [0]: 0
///     [1]: 1
```

Use a ``Generator`` when ``Arbitrary`` conformance of a specific type does not 
produce the necessary distribution of values. For example, a generator may be
used to test only positive integers, or only non-empty arrays.

```swift
func customSort(_ array: [Int]) -> [Int] { /* ... */ }

XCTKForAll(using: .nonEmptyArray(of: Int.self))
{
    (array: [Int]) in
    
    // Assert that a custom sort function is working correctly, 
    // but test with only non-empty arrays.
    XCTKAssertSorted(customSort(array), by: >=)
}
```

Built-in ``Arbitrary`` conformance is provided for many Swift standard library 
types, including integers, floating-point numbers, strings, collections, 
optionals, and more.

<!-- TODO: @Arbitrary macro example -->



## Installation

### Swift Package Manager

swift-test-kit may be installed using 
[Swift Package Manager](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/). 
The package includes both SwiftTestKit and XCTestKit.

```swift
// Use SwiftTestKit.
import SwiftTestKit

// Use XCTestKit.
import XCTestKit
```

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



## License

swift-test-kit is licensed under the Apache License, Version 2.0.

See [LICENSE](https://github.com/swift-developer-tools/swift-test-kit/blob/main/LICENSE.txt) 
for the complete license terms.



## Topics

### Articles

- <doc:Configuration>
- <doc:FunctionAssertions>
- <doc:MacroAssertions>
- <doc:PropertyBasedTesting>
