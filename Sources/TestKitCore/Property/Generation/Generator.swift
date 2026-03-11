//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// A custom generator for producing values of a specific type.
///
/// Use a generator when ``Arbitrary`` conformance of a specific type does
/// not produce the necessary distribution of values. For example, a
/// generator may be used to test only positive integers, or only non-empty
/// arrays.
///
/// ## Convenience Generators
///
/// Factory methods are provided for common scenarios.
///
/// ```swift
/// // Integers in a specific range.
/// let percentage: Generator<Int> = .integer(in: 0...100)
///
/// // Non-empty arrays.
/// let nonEmpty: Generator<[Int]> = .nonEmptyArray()
///
/// // Fixed-length strings of digits.
/// let value: Generator<String> = .string(count: 4, characters: .digit())
/// ```
///
/// ## Composing Generators
///
/// Use combinators to build complex generators.
///
/// ```swift
/// // Even integers.
/// let evenInts: Generator<Int> = .integer(in: 0...50).map { $0 * 2 }
///
/// // Pairs of integers.
/// let pairs: Generator<(Int, Int)> = .zip(
///     .integer(in: 0...100),
///     .integer(in: 0...100)
/// )
///
/// // Weighted distribution.
/// let weightedInts: Generator<Int> = .frequency(
///     (9, .integer(in: 0...10)),      // 90% small values
///     (1, .integer(in: 100...1000))   // 10% large values
/// )
///
/// // Positive integers.
/// let positiveInts: Generator<Int> = .integer(in: Int.min...Int.max)
///     .filter { $0 > 0 }
///
/// // String floating-point numbers.
/// let stringDoubles: Generator<String> = Generator<Double>
///     .floatingPoint(in: 0..<100)
///     .map { String($0) }
/// ```
///
/// ## Custom Generators
///
/// For full control, initialize a generator with custom generation and
/// shrinking.
///
/// ```swift
/// let evenIntGenerator = Generator<Int>(
///     generate:
///     {
///         (context: GenerationContext) in
///
///         let value: Int = context.random(in: 0...context.size)
///
///         return value * 2
///     },
///     shrink:
///     {
///         (value: Int) in
///
///         let candidates: [Int] = value.shrink()
///
///         return candidates.filter { $0.isMultiple(of: 2) }
///     },
///     mutate:
///     {
///         (value: Int, context: GenerationContext) in
///
///         let delta: Int = context.random(in: -context.size...context.size)
///
///         return max(0, value + delta * 2)
///     }
/// )
/// ```
public struct Generator<G>
{
    /// Generates a value from the given context.
    internal let generate   : (GenerationContext) -> G
    
    /// Shrinks the given value.
    internal let shrink     : (G) -> [G]
    
    /// Mutates the given value, using the given context.
    internal let mutate     : (G, GenerationContext) -> G
    
    
    
    /// Initializes a ``Generator`` instance from the given values.
    /// - Parameters:
    ///   - generate: The function to generate a value from the given context.
    ///   - shrink: The function to shrink the given value.
    ///   - mutate: The function to mutate the given value, using the given
    ///   context.
    public init(
        generate    : @escaping (GenerationContext) -> G,
        shrink      : @escaping (G) -> [G],
        mutate      : @escaping (G, GenerationContext) -> G
    )
    {
        self.generate   = generate
        self.shrink     = shrink
        self.mutate     = mutate
    }
}
