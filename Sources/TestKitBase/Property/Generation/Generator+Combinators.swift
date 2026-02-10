//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator
{
    // MARK: - map
    
    /// Transforms generated values using the given function.
    ///
    /// - Note: The returned generator does not shrink. To enable shrinking
    /// after transformation, create a generator with a custom shrink function.
    ///
    /// - Parameter transform: The transform function.
    /// - Returns: A generator that applies the given transform function to
    /// each generated value.
    public func map<T>(
        _ transform: @escaping (V) -> T
    ) -> Generator<T>
    {
        return Generator<T>(
            generate:
            {
                context in
                
                return transform(self.generate(context))
            },
            shrink: { _ in return [] }
        )
    }
    
    
    
    // MARK: - flatMap
    
    /// Generates a value, then uses it to select another generator.
    ///
    /// - Note: The returned generator does not shrink. To enable shrinking
    /// after transformation, create a generator with a custom shrink function.
    ///
    /// - Parameter transform: The transform function.
    /// - Returns: A generator that uses each generated value to select and
    /// run another generator.
    public func flatMap<T>(
        _ transform: @escaping (V) -> Generator<T>
    ) -> Generator<T>
    {
        return Generator<T>(
            generate:
            {
                context in
                
                let value       : V             = self.generate(context)
                let generator   : Generator<T>  = transform(value)
                
                return generator.generate(context)
            },
            shrink: { _ in return [] }
        )
    }
    
    
    
    // MARK: - filter
    
    /// Filters generated values, retrying until the given predicate passes.
    ///
    /// Shrink candidates from the underlying generator are also filtered,
    /// so only candidates satisfying the predicate are considered during
    /// shrinking.
    ///
    /// - Important: Precidates that reject most inputs slow down generation.
    /// Prefer constructing valid values directly.
    ///
    /// - Precondition: The method must produce at least one matching value
    /// in 1,000 attempts.
    ///
    /// - Parameter predicate: The predicate to call with each generated value.
    /// - Returns: A generator that only produces values satisfying the given
    /// predicate.
    public func filter(
        _ predicate: @escaping (V) -> Bool
    ) -> Generator<V>
    {
        return Generator<V>(
            generate:
            {
                context in
                
                for _ in 0..<1000
                {
                    let value: V = self.generate(context)
                    
                    if predicate(value)
                    {
                        return value
                    }
                }
                
                preconditionFailure(
                    "Generator.filter(_:) failed to produce a matching value"
                    + " after 1000 attempts. The predicate may be too"
                    + " restrictive for this generator."
                )
            },
            shrink:
            {
                value in
                
                return self.shrink(value).filter(predicate)
            }
        )
    }
    
    
    
    // MARK: - constant
    
    /// Creates a generator that always produces the given value.
    ///
    /// - Note: The returned generator does not shrink.
    ///
    /// - Parameter value: The value to produce.
    /// - Returns: A generator that always produces the given value.
    public static func constant(
        _ value: V
    ) -> Generator<V>
    {
        return Generator<V>(
            generate:   { _ in return value },
            shrink:     { _ in return [] }
        )
    }
    
    
    
    // MARK: - oneOf
    
    /// Creates a generator that randomly selects from the given generators
    /// with equal probability.
    ///
    /// Each generator has equal probability of being selected on each
    /// invocation.
    ///
    /// - Note: The returned generator does not shrink.
    ///
    /// - Precondition: `generators` must not be empty.
    ///
    /// - Parameter generators: The generators from which to select.
    /// - Returns: A generator that randomly selects from the given generators
    /// with equal probability.
    public static func oneOf(
        _ generators: [Generator<V>]
    ) -> Generator<V>
    {
        precondition(
            !generators.isEmpty,
            "generators must not be empty"
        )
        
        return Generator<V>(
            generate:
            {
                context in
                
                let generator: Generator<V>
                    = context.randomElement(of: generators)!
                
                return generator.generate(context)
            },
            shrink: { _ in return [] }
        )
    }
    
    
    
    /// Creates a generator that randomly selects from the given generators
    /// with equal probability.
    ///
    /// Each generator has equal probability of being selected on each
    /// invocation.
    ///
    /// - Note: The returned generator does not shrink.
    ///
    /// - Precondition: `generators` must not be empty.
    ///
    /// - Parameter generators: The generators from which to select.
    /// - Returns: A generator that randomly selects from the given generators
    /// with equal probability.
    public static func oneOf(
        _ generators: Generator<V>...
    ) -> Generator<V>
    {
        return oneOf(generators)
    }
    
    
    
    // MARK: - frequency
    
    /// Creates a generator that randomly selects from the given generators
    /// with weighted probability.
    ///
    /// Higher weights increase the probability of the associated generator
    /// being selected.
    ///
    /// ```swift
    /// let generator: Generator<Int> = .frequency(
    ///     (9, .integer(in: 0...10)),      // 90% small values
    ///     (1, .integer(in: 100...1000))   // 10% large values
    /// )
    /// ```
    ///
    /// - Note: The returned generator does not shrink.
    ///
    /// - Precondition: `weighted` must not be empty.
    /// - Precondition: All weights must be positive.
    ///
    /// - Parameter weighted: The weighted generators. Each element represents
    /// a weight and a generator.
    /// - Returns: A generator that randomly selects from the given generators
    /// with weighted probability.
    public static func frequency(
        _ weighted: [(Int, Generator<V>)]
    ) -> Generator<V>
    {
        precondition(
            !weighted.isEmpty,
            "weighted must not be empty"
        )
        
        return Generator<V>(
            generate:
            {
                context in
                
                let result: (Int, Generator<V>) = context.randomElement(
                    of:             weighted,
                    weightedBy:     { $0.0 }
                )!
                
                return result.1.generate(context)
            },
            shrink: { _ in return [] }
        )
    }
    
    
    
    /// Creates a generator that randomly selects from the given generators
    /// with weighted probability.
    ///
    /// Higher weights increase the probability of the associated generator
    /// being selected.
    ///
    /// ```swift
    /// let generator: Generator<Int> = .frequency(
    ///     (9, .integer(in: 0...10)),      // 90% small values
    ///     (1, .integer(in: 100...1000))   // 10% large values
    /// )
    /// ```
    ///
    /// - Note: The returned generator does not shrink.
    ///
    /// - Precondition: `weighted` must not be empty.
    /// - Precondition: All weights must be positive.
    ///
    /// - Parameter weighted: The weighted generators. Each element represents
    /// a weight and a generator.
    /// - Returns: A generator that randomly selects from the given generators
    /// with weighted probability.
    public static func frequency(
        _ weighted: (Int, Generator<V>)...
    ) -> Generator<V>
    {
        return frequency(weighted)
    }
    
    
    
    // MARK: - elements
    
    /// Creates a generator that randomly selects from the given collection.
    ///
    /// - Note: The returned generator does not shrink.
    ///
    /// - Precondition: `collection` must not be empty.
    ///
    /// - Parameter collection: The collection from which to select.
    /// - Returns: A generator that randomly selects from the given collection.
    public static func elements<C>(
        of collection: C
    ) -> Generator<V> where C : Collection, C.Element == V
    {
        precondition(
            !collection.isEmpty,
            "collection must not be empty"
        )
        
        return Generator<V>(
            generate:
            {
                context in
                
                return context.randomElement(of: collection)!
            },
            shrink: { _ in return [] }
        )
    }
    
    
    
    // MARK: - sized
    
    /// Creates a generator whose strategy depends on the current generation
    /// size.
    ///
    /// Use this to build size-dependent generators without accessing
    /// ``GenerationContext`` directly.
    ///
    /// ```swift
    /// let generator = Generator<Int>.sized
    /// {
    ///      size in
    ///
    ///      return .array(of: Int.self, count: 0...size)
    /// }
    /// ```
    ///
    /// - Note: The returned generator does not shrink.
    ///
    /// - Parameter make: A closure that receives the current size and returns
    /// a generator.
    /// - Returns: A generator whose strategy depends on the current generation
    /// size.
    public static func sized(
        _ make: @escaping (Int) -> Generator<V>
    ) -> Generator<V>
    {
        return Generator<V>(
            generate:
            {
                context in
                
                let generator: Generator<V> = make(context.size)
                
                return generator.generate(context)
            },
            shrink: { _ in return [] }
        )
    }
    
    
    
    // MARK: - zip
    
    /// Combines the two given generators into a generator of pairs.
    ///
    /// - Note: The returned generator preserves shrinking from both
    /// underlying generators. Each position is shrunk independently, while
    /// the other is held constant.
    ///
    /// - Parameters:
    ///   - first: The first generator.
    ///   - second: The second generator.
    /// - Returns: A generator of pairs.
    public static func zip<A, B>(
        _ first     : Generator<A>,
        _ second    : Generator<B>
    ) -> Generator<(A, B)> where V == (A, B)
    {
        return Generator<(A, B)>(
            generate:
            {
                context in
                
                return (
                    first.generate(context),
                    second.generate(context)
                )
            },
            shrink:
            {
                pair in
                
                var candidates: [(A, B)] = []
                
                for a in first.shrink(pair.0)
                {
                    candidates.append((a, pair.1))
                }
                
                for b in second.shrink(pair.1)
                {
                    candidates.append((pair.0, b))
                }
                
                return candidates
            }
        )
    }
    
    
    
    /// Combines the three given generators into a generator of triples.
    ///
    /// - Note: The returned generator preserves shrinking from all three
    /// underlying generators. Each position is shrunk independently, while
    /// the others are held constant.
    ///
    /// - Parameters:
    ///   - first: The first generator.
    ///   - second: The second generator.
    ///   - third: The third generator.
    /// - Returns: A generator of triples.
    public static func zip<A, B, C>(
        _ first     : Generator<A>,
        _ second    : Generator<B>,
        _ third     : Generator<C>
    ) -> Generator<(A, B, C)> where V == (A, B, C)
    {
        return Generator<(A, B, C)>(
            generate:
            {
                context in
                
                return (
                    first.generate(context),
                    second.generate(context),
                    third.generate(context)
                )
            },
            shrink:
            {
                triple in
                
                var candidates: [(A, B, C)] = []
                
                for a in first.shrink(triple.0)
                {
                    candidates.append((a, triple.1, triple.2))
                }
                
                for b in second.shrink(triple.1)
                {
                    candidates.append((triple.0, b, triple.2))
                }
                
                for c in third.shrink(triple.2)
                {
                    candidates.append((triple.0, triple.1, c))
                }
                
                return candidates
            }
        )
    }
    
    
    
    /// Combines four or more generators into a generator of tuples.
    ///
    /// - Note: The returned generator does not shrink. To enable shrinking
    /// for four or more generators, implement an overload accepting the
    /// necessary number of generators.
    ///
    /// - Parameter generators: The generators to combine.
    /// - Returns: A generator of tuples.
    public static func zip<each T>(
        _ generators: repeat Generator<each T>
    ) -> Generator<(repeat each T)> where V == (repeat each T)
    {
        return Generator<(repeat each T)>(
            generate:
            {
                context in
                
                return (repeat (each generators).generate(context))
            },
            shrink: { _ in [] }
        )
    }
}
