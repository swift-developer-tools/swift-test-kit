# ``SwiftTestKit``

Structural diff output, expression capture, predicate assertions, and 
property-based testing for Swift Testing.



## Overview

SwiftTestKit extends the [Swift Testing](https://developer.apple.com/xcode/swift-testing)
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

Property-based testing generates random values automatically, shrinks failures 
to minimal counterexamples, and reports failing values with the same rich 
assertion output used by standalone assertions.

- Note: To test with the 
[XCTest](https://developer.apple.com/documentation/xctest) framework, use 
[XCTestKit](https://swift-developer-tools.github.io/swift-test-kit/documentation/xctestkit). 
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

STKAssertEqual(expected, actual)

// STKAssertEqual failed
///
// Outer differs at:
///
//     .inner.value
//         Expected:   100
//         Actual:     200
```

### Arrays

```swift
let expected    = [1, 2, 3, 4, 5, 6, 7, 8]
let actual      = [0, 0, 3, 4, 5, 6, 7, 0]

let options = TestOptions(formatOptions: .init(maxDiffs: 2))

STKAssertEqual(expected, actual, options: options)

// STKAssertEqual failed
///
// Array<Int> differs at:
///
//     [0]
//         Expected:   1
//         Actual:     0
///
//     [1]
//         Expected:   2
//         Actual:     0
///
//     ... and 1 more difference
```

### Multi-Line Strings

```swift
let expected    = "Line 1\nLine 2\nLine 3"
let actual      = "Line 1\nLine X\nLine 3"

STKAssertEqual(expected, actual)

// STKAssertEqual failed
///
// String differs at:
///
//     line 2
//         Expected:   "Line 2"
//         Actual:     "Line X"
//         Changed:    character 6 ("2" → "X")
```

### Sets

```swift
let expected    : Set<String>   = ["a", "b", "c"]
let actual      : Set<String>   = ["a", "e", "f"]

STKAssertEqual(expected, actual)

// STKAssertEqual failed
///
// Set<String> differs:
///
//     Missing:    "b"
//     Missing:    "c"
//     Unexpected: "e"
//     Unexpected: "f"
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
#STKAssertTrue(isValid() && hasAccess && count >= 10)
// where isValid() -> true, hasAccess == false, count == 20

// #STKAssertTrue failed
// 
// Expression: isValid() && hasAccess && count >= 10
// 
//     isValid() = true
//     hasAccess = false ←
// 
//     (1 expression not evaluated)
```

### Nested Expressions

```swift
#STKAssertFalse((a || b) && (c || d))
// where a == true, b == false, c == true, d == false

// #STKAssertFalse failed
// 
// Expression: (a || b) && (c || d)
// 
//     a = true ←
//     c = true ←
// 
//     (2 expressions not evaluated)
```

### Non-Boolean Assertions

```swift
#STKAssertNoThrow(try getValue())

// #STKAssertNoThrow failed
// 
// Expression: try getValue()
// Threw:      RequestError.timeout
```

```swift
#STKAssertNil(result.error)
// where result.error == RequestError.timeout

// #STKAssertNil failed
// 
// Expression: result.error
// Actual:     RequestError.timeout
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
STKAssertAllSatisfy([10, 15, 20, 25]) { $0.isMultiple(of: 10) }

// STKAssertAllSatisfy failed
// 
// Collection count: 4
// 
// Failed: 2 of 4
// 
//     [1]: 15
//     [3]: 25
```

### Exactly

```swift
#STKAssertExactly([30, 25, 10, 35, 15], count: 2) { $0 > 20 }

// #STKAssertExactly failed
// 
// Collection count: 5
// 
// Collection: [30, 25, 10, 35, 15]
// Predicate:  { $0 > 20 }
// 
// Expected: exactly 2 matches
// Actual:   3 matched
// 
//     Matched: [0-1], [3]
```

### Sorted

```swift
STKAssertSorted([10, 30, 20, 40], by: <)

// STKAssertSorted failed
// 
// Collection count: 4
// 
// Not sorted at:
// 
//     [1]: 30
//     [2]: 20
```

### Unique

```swift
STKAssertUnique(["aa", "bb", "c"], by: { $0.count })

// STKAssertUnique failed
// 
// Collection count: 3
// 
// Duplicates: 1 key
// 
//     Key 2:
//         [0]: "aa"
//         [1]: "bb"
```

### Error Handling

```swift
enum NumberError: Error { case invalid }

let values: [Int] = [20, -10, 40, -30, 60]

STKAssertSatisfy(values, atLeast: 4)
{
    value in

    guard value >= 0 else { throw NumberError.invalid }
    return value.isMultiple(of: 20)
}

// STKAssertSatisfy failed
// 
// Collection count: 5
// 
// Expected: at least 4 matches
// Actual:   3 matched, 2 threw errors
// 
//     Matched: [0], [2], [4]
// 
//     Threw errors:
//         [1]: -10 (threw error "invalid")
//         [3]: -30 (threw error "invalid")
```



## Property-Based Testing

Describe properties that must hold for any given value, and SwiftTestKit will 
generate random test cases automatically. 

```swift
STKForAll
{
    (a: Int, b: Int) in
    
    // Addition is commutative. The assertion passes for all values.
    STKAssertEqual(a + b, b + a)
}
```

Asynchronous and throwing tests are also supported.

```swift
await STKForAll
{
    (value: String) async throws in
    
    try await db.save(value, forKey: "test")
    let loaded: String? = try await db.load(forKey: "test")
    
    STKAssertEqual(loaded, value)
}
```

### Counterexamples

When a value causes a property to fail, SwiftTestKit will shrink the value to 
the smallest value that still fails the property (the minimal counterexample).

SwiftTestKit assertions are automatically intercepted inside property bodies, 
so counterexamples include the same diff output, expression capture, and 
formatting used by standalone assertions.

The counterexample is reported along with the seed used for generation, which 
may be used to deterministically reproduce the failure.

```swift
func customSort(_ array: [Int]) -> [Int] { /* ... */ }

STKForAll
{
    (array: [Int]) in
    
    // Assert that a custom sort function is working correctly.
    STKAssertSorted(customSort(array), by: >=)
}

// STKForAll failed after 4 iterations (shrunk in 2 steps)
// 
// Counterexample:
//     Array<Int> = [1, 0]
// 
// Seed: 2188239925673862914 (re-run with PropertyOptions.seed)
// 
// STKAssertSorted failed
// 
// Collection count: 2
// 
// Not sorted at:
// 
//     [0]: 0
//     [1]: 1
```

### Generators

Use a ``Generator`` when ``Arbitrary`` conformance of a specific type does not 
produce the necessary distribution of values. For example, a generator may be
used to test only positive integers, or only non-empty arrays.

```swift
func customSort(_ array: [Int]) -> [Int] { /* ... */ }

STKForAll(using: .nonEmptyArray(of: Int.self))
{
    (array: [Int]) in
    
    // Assert that a custom sort function is working correctly, 
    // but test with only non-empty arrays.
    STKAssertSorted(customSort(array), by: >=)
}
```

### Classification

Classification functions conditionally tag iterations with descriptive labels, 
tracking the distribution of generated values across categories. Minimum 
coverage requirements can be set to fail the test with a distribution summary 
if the requirement is not met.

```swift
STKForAll(using: generator)
{
    (array: [Int]) in
    
    // Discard empty arrays.
    try STKAssume(!array.isEmpty)
    
    // 10% of arrays must have more than 5 elements.
    // Otherwise, the test fails.
    STKCover(10, "large", when: array.count > 5)
    
    // Label single-element arrays.
    STKClassify("non-empty", when: array.count == 1)
    
    // Test properties that must hold for any non-empty array.
}
```

Tables track the distribution of generated values along independent named 
dimensions, with optional coverage requirements.

```swift
STKForAll(using: generator)
{
    (n: Int) in
    
    // Track the parity of generated integers.
    STKTabulate("parity", n.isMultiple(of: 2) ? "even" : "odd")
    
    // At least 50% of generated integers must be even.
    STKCoverTable("parity", (50, "even"))
    
    // Test properties that must hold for any integer.
}
```

### Built-In Conformance

Built-in ``Arbitrary`` conformance is provided for many standard library types:

- All integers (`Int`, `Int8` through `Int64`, `UInt`, `UInt8` through 
`UInt64`)
- Floating-point numbers (`Float`, `Float16`, `Double`, `Decimal`)
- Collections (`Array`, `Set`, `Dictionary`, `CollectionOfOne`)
- Ranges (`Range`, `ClosedRange`)
- Foundation types (`Date`, `Data`, `UUID`)
- `String`, `Substring`, `Character`, `Unicode.Scalar`
- `Bool`
- `Optional`
- `Result`

### Custom Type Conformance

Apply the ``Arbitrary()`` macro to a struct or enum to automatically generate 
``Arbitrary`` conformance for custom types.

Generic parameters that appear in stored properties or associated values are 
automatically constrained to ``Arbitrary``.

```swift
@Arbitrary
struct User<T>: Equatable where T : Equatable & Hashable
{
    let name    : String
    let id      : T
}

STKForAll
{
    (user: User<UUID>) in
    
    // Test properties that must hold for any user.
}
```

Recursive and `indirect` enums are also supported.

```swift
@Arbitrary
indirect enum Tree: Equatable
{
    case leaf
    case node(Tree, Tree)
}

STKForAll
{
    (a: Tree, b: Tree) in
    
    // Test properties that must hold for any pair of trees.
}
```



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
| Swift        | 6.3             |
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
