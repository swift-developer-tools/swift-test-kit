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
        let generate: (GenerationContext) -> T =
        {
            context in
            
            return transform(self.generate(context))
        }
        
        return Generator<T>(
            generate:   generate,
            shrink:     { _ in return [] },
            mutate:     { _, context in generate(context) }
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
        let generate: (GenerationContext) -> T =
        {
            context in
            
            let value       : V             = self.generate(context)
            let generator   : Generator<T>  = transform(value)
            
            return generator.generate(context)
        }
        
        return Generator<T>(
            generate:   generate,
            shrink:     {  _ in return [] },
            mutate:     { _, context in generate(context) }
        )
    }
    
    
    
    // MARK: - filter
    
    /// Filters generated values, retrying until the given predicate passes.
    ///
    /// Shrink candidates from the underlying generator are also filtered,
    /// so only candidates satisfying the predicate are considered during
    /// shrinking.
    ///
    /// - Important: Precidates that reject most values slow down generation.
    /// Prefer constructing valid values directly.
    ///
    /// - Precondition: A matching value must be produced within 1,000 attempts,
    /// or within 2,000 attempts for mutation.
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
                    + " restrictive for this generator"
                )
            },
            shrink:
            {
                value in
                
                return self.shrink(value).filter(predicate)
            },
            mutate:
            {
                value, context in
                
                for _ in 0..<1000
                {
                    let mutated: V = self.mutate(value, context)
                    
                    if predicate(mutated)
                    {
                        return mutated
                    }
                }
                
                for _ in 0..<1000
                {
                    let generated: V = self.generate(context)
                    
                    if predicate(generated)
                    {
                        return generated
                    }
                }
                
                preconditionFailure(
                    "Generator.filter(_:) failed to produce a mutated value"
                    + " after 2000 attempts. The predicate may be too"
                    + " restrictive for this generator"
                )
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
            shrink:     { _ in return [] },
            mutate:     { _, _ in return value }
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
        
        let generate: (GenerationContext) -> V =
        {
            context in
            
            let generator: Generator<V>
                = context.randomElement(of: generators)!
            
            return generator.generate(context)
        }
        
        return Generator<V>(
            generate:   generate,
            shrink:     { _ in return [] },
            mutate:     { _, context in generate(context) }
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
        
        let generate: (GenerationContext) -> V =
        {
            context in
            
            let result: (Int, Generator<V>) = context.randomElement(
                of:             weighted,
                weightedBy:     { $0.0 }
            )!
            
            return result.1.generate(context)
        }
        
        return Generator<V>(
            generate:   generate,
            shrink:     { _ in return [] },
            mutate:     { _, context in generate(context) }
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
        
        let generate: (GenerationContext) -> V =
        {
            context in
            
            return context.randomElement(of: collection)!
        }
        
        return Generator<V>(
            generate:   generate,
            shrink:     { _ in return [] },
            mutate:     { _, context in generate(context) }
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
        let generate: (GenerationContext) -> V =
        {
            context in
            
            let generator: Generator<V> = make(context.size)
            
            return generator.generate(context)
        }
        
        return Generator<V>(
            generate:   generate,
            shrink:     { _ in return [] },
            mutate:     { _, context in generate(context) }
        )
    }
    
    
    
    // MARK: - zip
    
    /// Combines generators into a generator of tuples.
    ///
    /// - Note: The returned generator preserves shrinking from all underlying
    /// generators. Each value is shrunk independently, while holding the
    /// others constant.
    ///
    /// - Parameter generators: The generators to combine.
    /// - Returns: A generator of tuples.
    public static func zip<each T>(
        _ generators: repeat Generator<each T>
    ) -> Generator<(repeat each T)> where V == (repeat each T)
    {
        var shrinkers   : [AnyShrinker]     = []
        var mutators    : [AnyMutator]      = []
        
        for generator in repeat each generators
        {
            shrinkers.append(AnyShrinker(generator.shrink))
            mutators.append(AnyMutator(generator.mutate))
        }
        
        return Generator<(repeat each T)>(
            generate:
            {
                context in
                
                return (repeat (each generators).generate(context))
            },
            shrink:
            {
                tuple in
                
                /// Decompose the typed tuple into `[Any]` for index operations,
                /// shrink one value while holding others constant, then
                /// reconstruct the typed tuple by expanding each pack element
                /// with the corresponding array index. Force-casting is safe
                /// since array construction is controlled.
                
                let rawCandidates: [[Any]] = AnyShrinker.shrinkCandidates(
                    of:     tuple,
                    with:   shrinkers
                )
                
                return rawCandidates.map
                {
                    copy in
                    
                    let packIndex = PackIndex()
                    
                    return (repeat copy[packIndex.next()] as! each T)
                }
            },
            mutate:
            {
                tuple, context in
                
                let copy: [Any] = AnyMutator.mutateSingleElement(
                    of:     tuple,
                    with:   mutators,
                    using:  context
                )
                
                let packIndex = PackIndex()
                
                return (repeat copy[packIndex.next()] as! each T)
            }
        )
    }
}
