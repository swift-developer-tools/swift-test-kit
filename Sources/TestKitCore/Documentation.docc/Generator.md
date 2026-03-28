# ``Generator``

A custom generator for producing values of a specific type.

Use a generator when ``Arbitrary`` conformance of a specific type does
not produce the necessary distribution of values. For example, a
generator may be used to test only positive integers, or only non-empty
arrays.

## Convenience Generators

Factory methods are provided for common scenarios.

```swift
// Integers in a specific range.
let percentage: Generator<Int> = .integer(in: 0...100)

// Non-empty arrays.
let nonEmpty: Generator<[Int]> = .nonEmptyArray()

// Fixed-length strings of digits.
let value: Generator<String> = .string(count: 4, characters: .digit())
```

## Composing Generators

Use combinators to build complex generators.

```swift
// Even integers.
let evenInts: Generator<Int> = .integer(in: 0...50).map { $0 * 2 }

// Pairs of integers.
let pairs: Generator<(Int, Int)> = .zip(
    .integer(in: 0...100),
    .integer(in: 0...100)
)

// Weighted distribution.
let weightedInts: Generator<Int> = .frequency(
    (9, .integer(in: 0...10)),      // 90% small values
    (1, .integer(in: 100...1000))   // 10% large values
)

// Positive integers.
let positiveInts: Generator<Int> = .integer(in: Int.min...Int.max)
    .filter { $0 > 0 }

// String floating-point numbers.
let stringDoubles: Generator<String> = Generator<Double>
    .floatingPoint(in: 0..<100)
    .map { String($0) }
```

## Custom Generators

For full control, initialize a generator with custom generation and
shrinking.

```swift
let evenIntGenerator = Generator<Int>(
    generate:
    {
        (context: GenerationContext) in

        let value: Int = context.random(in: 0...context.size)

        return value * 2
    },
    shrink:
    {
        (value: Int) in

        let candidates: [Int] = value.shrink()

        return candidates.filter { $0.isMultiple(of: 2) }
    },
    mutate:
    {
        (value: Int, context: GenerationContext) in

        let delta: Int = context.random(in: -context.size...context.size)

        return max(0, value + delta * 2)
    }
)
```

## Topics

### Initializers

- ``Generator/init(generate:shrink:mutate:)``

### Creating Generators

- ``Generator/constant(_:)``
- ``Generator/elements(of:)``
- ``Generator/sized(_:)``

### Composing Generators

- ``Generator/oneOf(_:)-([Generator<G>])``
- ``Generator/oneOf(_:)-(Generator<G>...)``
- ``Generator/frequency(_:)-1llzo``
- ``Generator/frequency(_:)-6i7rh``
- ``Generator/recursive(base:recurse:)``
- ``Generator/zip(_:)``

### Transforming Generators

- ``Generator/map(_:)``
- ``Generator/flatMap(_:)``
- ``Generator/filter(_:)``

### Generating Integers

- ``Generator/integer(in:)-(ClosedRange<G>)``
- ``Generator/integer(in:)-(Range<G>)``

### Generating Floating-Point Numbers

- ``Generator/floatingPoint(in:)-(ClosedRange<G>)``
- ``Generator/floatingPoint(in:)-(Range<G>)``

### Generating Characters

- ``Generator/ascii()``
- ``Generator/lowercase()``
- ``Generator/uppercase()``
- ``Generator/digit()``
- ``Generator/alphanumeric()``
- ``Generator/from(_:)``

### Generating Strings

- ``Generator/string(count:characters:)-(Int,_)``
- ``Generator/string(count:characters:)-(ClosedRange<Int>,_)``
- ``Generator/string(count:characters:)-(Range<Int>,_)``
- ``Generator/nonEmptyString(characters:)``

### Generating Arrays

- ``Generator/array(using:count:)-(_,Int)``
- ``Generator/array(using:count:)-(_,ClosedRange<Int>)``
- ``Generator/array(using:count:)-(_,Range<Int>)``
- ``Generator/array(of:count:)-(_,Int)``
- ``Generator/array(of:count:)-(_,ClosedRange<Int>)``
- ``Generator/array(of:count:)-(_,Range<Int>)``
- ``Generator/nonEmptyArray(using:)``
- ``Generator/nonEmptyArray(of:)``
- ``Generator/uniqueArray(using:count:)-(_,Int)``
- ``Generator/uniqueArray(using:count:)-(_,ClosedRange<Int>)``
- ``Generator/uniqueArray(using:count:)-(_,Range<Int>)``
- ``Generator/uniqueArray(of:count:)-(_,Int)``
- ``Generator/uniqueArray(of:count:)-(_,ClosedRange<Int>)``
- ``Generator/uniqueArray(of:count:)-(_,Range<Int>)``

### Generating Sets

- ``Generator/set(using:count:)-(_,Int)``
- ``Generator/set(using:count:)-(_,ClosedRange<Int>)``
- ``Generator/set(using:count:)-(_,Range<Int>)``
- ``Generator/set(of:count:)-(_,Int)``
- ``Generator/set(of:count:)-(_,ClosedRange<Int>)``
- ``Generator/set(of:count:)-(_,Range<Int>)``
- ``Generator/nonEmptySet(using:)``
- ``Generator/nonEmptySet(of:)``

### Generating Dictionaries

- ``Generator/dictionary(keys:values:count:)-(_,_,Int)``
- ``Generator/dictionary(keys:values:count:)-(_,_,ClosedRange<Int>)``
- ``Generator/dictionary(keys:values:count:)-(_,_,Range<Int>)``
- ``Generator/dictionary(key:value:count:)-(_,_,Int)``
- ``Generator/dictionary(key:value:count:)-(_,_,ClosedRange<Int>)``
- ``Generator/dictionary(key:value:count:)-(_,_,Range<Int>)``
- ``Generator/nonEmptyDictionary(keys:values:)``
- ``Generator/nonEmptyDictionary(key:value:)``

### Generating Data

- ``Generator/data(using:count:)-(_,Int)``
- ``Generator/data(using:count:)-(_,ClosedRange<Int>)``
- ``Generator/data(using:count:)-(_,Range<Int>)``
- ``Generator/data(count:)-(Int)``
- ``Generator/data(count:)-(ClosedRange<Int>)``
- ``Generator/data(count:)-(Range<Int>)``
- ``Generator/nonEmptyData(using:)``
- ``Generator/nonEmptyData()``

### Generating Dates

- ``Generator/date(in:)-(ClosedRange<Date>)``
- ``Generator/date(in:)-(Range<Date>)``

### Generating Optional Values

- ``Generator/optional(probability:)``

### Generating Arbitrary Values

- ``Generator/arbitrary()``

### Sampling Values

- ``Generator/sample(count:seed:maxSize:)``
