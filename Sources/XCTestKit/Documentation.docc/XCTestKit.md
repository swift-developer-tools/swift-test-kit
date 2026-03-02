# ``XCTestKit``

Property-based, stateful, performance, and temporal testing, with structural 
diffs and advanced assertions for the XCTest framework.



## Overview

XCTestKit extends the [XCTest](https://developer.apple.com/documentation/xctest) 
framework with property-based testing, stateful testing, and advanced assertions 
with structural diffs and expression capture.

When assertions fail, structural diffs pinpoint exactly where values diverge 
within complex data structures, using path-based output that scales from flat 
primitives to deeply-nested structs, collections, and multi-line strings. 

Macro assertions capture the literal source text of expressions and decompose 
compound boolean logic to identify which sub-expression caused the failure, 
making CI/CD logs actionable without needing access to the source code.

Predicate assertions verify conditions across collection elements and produce 
element-level failure output, identifying which elements failed, which matched 
unexpectedly, and which threw errors.

Performance tests measure execution time and physical memory footprint across
multiple runs, and verify that median values stay within configurable limits.

Temporal tests poll assertions continuously for a given duration, or until all 
assertions pass within a single execution.

Property-based testing generates random values automatically and shrinks 
failures to minimal counterexamples. Stateful testing extends this to systems 
with mutable state, generating random command sequences and verifying the 
system against a simplified model.

Temporal, property-based, and stateful testing all report failures with the 
same rich output used by standalone assertions.

- Note: To test with the 
[Swift Testing](https://developer.apple.com/xcode/swift-testing) framework, use 
[SwiftTestKit](https://swift-developer-tools.github.io/swift-test-kit/documentation/swifttestkit). 
SwiftTestKit and XCTestKit provide identical APIs.


## Structural Diffs

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

// XCTKAssertEqual failed
//
// Outer differs at:
//
//     .inner.value
//         Expected:   100
//         Actual:     200
```

### Arrays

```swift
let expected    = [1, 2, 3, 4, 5, 6, 7, 8]
let actual      = [0, 0, 3, 4, 5, 6, 7, 0]

let options = TestOptions(formatOptions: .init(maxDiffs: 2))

XCTKAssertEqual(expected, actual, options: options)

// XCTKAssertEqual failed
//
// Array<Int> differs at:
//
//     [0]
//         Expected:   1
//         Actual:     0
//
//     [1]
//         Expected:   2
//         Actual:     0
//
//     ... and 1 more difference
```

### Multi-Line Strings

```swift
let expected    = "Line 1\nLine 2\nLine 3"
let actual      = "Line 1\nLine X\nLine 3"

XCTKAssertEqual(expected, actual)

// XCTKAssertEqual failed
//
// String differs at:
//
//     line 2
//         Expected:   "Line 2"
//         Actual:     "Line X"
//         Changed:    character 6 ("2" → "X")
```

### Sets

```swift
let expected    : Set<String>   = ["a", "b", "c"]
let actual      : Set<String>   = ["a", "e", "f"]

XCTKAssertEqual(expected, actual)

// XCTKAssertEqual failed
//
// Set<String> differs:
//
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
#XCTKAssertTrue(isValid() && hasAccess && count >= 10)
// where isValid() -> true, hasAccess == false, count == 20

// #XCTKAssertTrue failed
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
#XCTKAssertFalse((a || b) && (c || d))
// where a == true, b == false, c == true, d == false

// #XCTKAssertFalse failed
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
#XCTKAssertNoThrow(try getValue())

// #XCTKAssertNoThrow failed
// 
// Expression: try getValue()
// Threw:      RequestError.timeout
```

```swift
#XCTKAssertNil(result.error)
// where result.error == RequestError.timeout

// #XCTKAssertNil failed
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
XCTKAssertAllSatisfy([10, 15, 20, 25]) { $0.isMultiple(of: 10) }

// XCTKAssertAllSatisfy failed
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
#XCTKAssertExactly([30, 25, 10, 35, 15], count: 2) { $0 > 20 }

// #XCTKAssertExactly failed
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
XCTKAssertSorted([10, 30, 20, 40], by: <)

// XCTKAssertSorted failed
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
XCTKAssertUnique(["aa", "bb", "c"], by: { $0.count })

// XCTKAssertUnique failed
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

XCTKAssertSatisfy(values, atLeast: 4)
{
    value in

    guard value >= 0 else { throw NumberError.invalid }
    return value.isMultiple(of: 20)
}

// XCTKAssertSatisfy failed
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



## Performance Testing

Performance tests measure execution time and physical memory footprint across
multiple runs, and verify that median values stay within configurable limits.

### Time

Verify the execution time:

```swift
// Assert that a custom sort function is working correctly,
// and that it sorts within 50 milliseconds.
await XCTKPerformance(timeLimit: .milliseconds(50))
{
    XCTKAssertSorted(customSort(array), by: >=)
}

// XCTKPerformance failed
// 
// Time:
//     Threshold:   50 ms
//     Median:    77.2 ms (10 runs) ←
```

### Memory

Verify the physical memory footprint:

```swift
// Assert that a tokenizer's memory footprint is less than 5 MB.
await XCTKPerformance(memoryLimit: 5_000_000)
{
    _ = try await tokenize(source)
}

// XCTKPerformance failed
// 
// Memory:
//     Threshold: 4.8 MB
//     Median:    9.5 MB (10 runs) ←
```



## Temporal Testing

Temporal tests poll assertions over a configurable duration to verify 
continuous invariants or eventual convergence.

Verify an eventual outcome:

```swift
let service = DataService()
service.startLoading()

// Assert that the service eventually loads.
await XCTKEventually(timeout: .seconds(2))
{
    XCTKAssertEqual(.loaded, service.state)
}

// XCTKEventually failed after 2 sec
// 
// XCTKAssertEqual failed
// 
// Expected:   loaded
// Actual:     processing
```

Verify a continuous invariant:

```swift
let buffer = Buffer(capacity: 10)
buffer.startProducing()

// Assert that the buffer never exceeds capacity.
await XCTKAlways(interval: .milliseconds(10))
{
    XCTKAssertLessThanOrEqual(buffer.count, buffer.capacity)
}

// XCTKAlways failed after 77.7 ms
// 
// XCTKAssertLessThanOrEqual failed: ("12") is not less than or equal to ("10")
```



## Property-Based Testing

Describe properties that must hold for any given value, and XCTestKit will 
generate random test cases automatically. 

```swift
XCTKForAll
{
    (a: Int, b: Int) in
    
    // Addition is commutative. The assertion passes for all values.
    XCTKAssertEqual(a + b, b + a)
}
```

Asynchronous and throwing tests are also supported.

```swift
await XCTKForAll
{
    (value: String) async throws in
    
    try await db.save(value, forKey: "test")
    let loaded: String? = try await db.load(forKey: "test")
    
    XCTKAssertEqual(loaded, value)
}
```

### Counterexamples

When a value causes a property to fail, XCTestKit will shrink the value to the 
smallest value that still fails the property (the minimal counterexample).

XCTestKit assertions are automatically intercepted inside property bodies, 
so counterexamples include the same diff output, expression capture, and 
formatting used by standalone assertions.

The counterexample is reported along with the seed used for generation, which 
may be used to deterministically reproduce the failure.

```swift
func customSort(_ array: [Int]) -> [Int] { /* ... */ }

XCTKForAll
{
    (array: [Int]) in
    
    // Assert that a custom sort function is working correctly.
    XCTKAssertSorted(customSort(array), by: >=)
}

// XCTKForAll failed after 4 iterations (shrunk in 2 steps)
// 
// Counterexample:
//     Array<Int> = [1, 0]
// 
// XCTKAssertSorted failed
// 
// Collection count: 2
// 
// Not sorted at:
// 
//     [0]: 0
//     [1]: 1
// 
// Seed: 2188239925673862914 (XCTKForAll)
```

### Generators

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

### Classification

Classification functions conditionally tag iterations with descriptive labels, 
tracking the distribution of generated values across categories. Minimum 
coverage requirements can be set to fail the test with a distribution summary 
if the requirement is not met.

```swift
XCTKForAll(using: generator)
{
    (array: [Int]) in
    
    // Discard empty arrays.
    try XCTKAssume(!array.isEmpty)
    
    // 10% of arrays must have more than 5 elements.
    // Otherwise, the test fails.
    XCTKCover(10, "large", when: array.count > 5)
    
    // Label single-element arrays.
    XCTKClassify("non-empty", when: array.count == 1)
    
    // Test properties that must hold for any non-empty array.
}
```

Tables track the distribution of generated values along independent named 
dimensions, with optional coverage requirements.

```swift
XCTKForAll(using: generator)
{
    (n: Int) in
    
    // Track the parity of generated integers.
    XCTKTabulate("parity", n.isMultiple(of: 2) ? "even" : "odd")
    
    // At least 50% of generated integers must be even.
    XCTKCoverTable("parity", (50, "even"))
    
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

Apply the ``Arbitrary()`` macro to a struct or enum to automatically synthesize 
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

XCTKForAll
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

XCTKForAll
{
    (a: Tree, b: Tree) in
    
    // Test properties that must hold for any pair of trees.
}
```

### Stateful Testing

Stateful testing extends property-based testing to systems with mutable state. 
Rather than testing individual values against a property, stateful testing 
generates random sequences of commands and executes them against both a 
simplified model and the real system, verifying consistency at each step.

Commands conform to the ``Stateful`` protocol, which defines how to generate 
random commands, execute them against the model and system, and advance the 
model independently. Optional preconditions filter commands based on the model 
state, and optional postconditions verify system behavior after each command 
is executed.

When a failing command sequence is found, it is shrunk to the minimal 
counterexample in two phases: removal shrinking removes unnecessary commands, 
and argument shrinking reduces individual command parameters.

```swift
// A stack with a subtle bug that is discovered by stateful testing.
struct Stack<T>
{
    private var storage: [T] = []
    
    var count: Int
    {
        return storage.count
    }
    
    mutating func push(
        _ element: T
    )
    {
        storage.append(element)
    }
    
    mutating func pop() -> T
    {
        // Bug: This should be removeLast()
        return storage.removeFirst()
    }
}

// Commands that test the Stack against a simple array model.
@Stateful
enum StackCommand
{
    // The system under test, and the model used to test it.
    typealias System    = Stack<Int>
    typealias Model     = [Int]
    
    // The commands to use in randomly-generated command sequences.
    // Weighted so push is selected 3 times more often than pop and count.
    @Weight(3) case push(Int)
    @Weight(1) case pop
    @Weight(1) case count
    
    // Generated by the @Stateful macro automatically:
    // - arbitrary(using:model:)
    // - shrink()
    
    // Checks whether this command is valid under the given model state.
    func precondition(
        model: Model
    ) -> Bool
    {
        switch self
        {
            case .pop   : return !model.isEmpty
            default     : return true
        }
    }
    
    // Executes the command on both the given model and system.
    func run(
        model   : inout Model,
        system  : inout System
    ) async
    {
        switch self
        {
            case .push(let value):
                
                model.append(value)
                system.push(value)
                
            case .pop:
                
                let expected    : Int   = model.removeLast()
                let actual      : Int   = system.pop()
                
                XCTKAssertEqual(expected, actual)
                
            case .count:
                
                XCTKAssertEqual(model.count, system.count)
        }
    }
    
    // Advances to the next model state without executing against the system.
    func advance(
        model: inout Model
    )
    {
        switch self
        {
            case .push(let value)   : model.append(value)
            case .pop               : model.removeLast()
            case .count             : break
        }
    }
}

await XCTKStateful(
    model:      { [] },
    system:     { Stack() },
    command:    StackCommand.self
)

// XCTKStateful failed after 5 iterations (shrunk to 3 commands)
// 
// Command sequence:
//     1. push(0)
//     2. push(1)
//     3. pop ←
// 
// XCTKAssertEqual failed
// 
// Expected:   1
// Actual:     0
// 
// Seed: 6549428853488321548 (XCTKStateful)
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
| Swift        | 6.2             |
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
- <doc:PerformanceTesting>
- <doc:TemporalTesting>
- <doc:PropertyBasedTesting>
