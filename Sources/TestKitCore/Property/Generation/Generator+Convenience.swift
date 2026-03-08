//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - Arbitrary

extension Generator where V : Arbitrary
{
    /// Creates a generator that produces values by delegating to the type's
    /// ``Arbitrary`` conformance.
    /// - Returns: A generator that produces values by delegating to the type's
    /// ``Arbitrary`` conformance.
    public static func arbitrary() -> Generator<V>
    {
        return Generator<V>(
            generate:   { context in V.arbitrary(using: context) },
            shrink:     { value in value.shrink() },
            mutate:     { value, context in value.mutate(using: context) }
        )
    }
}



// MARK: - Sample

extension Generator
{
    /// Generates samples values.
    ///
    /// Use this to verify that a custom generator produces the expected
    /// distribution of values.
    ///
    /// - Parameters:
    ///   - count: The number of values to generate. The default value is `10`.
    ///   - seed: The seed used to initialize the random number generator.
    ///   The default value is `nil`, which generates a random seed from the
    ///   system random number generator.
    ///   - maxSize: The maximum generation size. The default value is `100`.
    /// - Returns: The sample values.
    public func sample(
        count   : Int       = 10,
        seed    : UInt64?   = nil,
        maxSize : Int       = 100
    ) -> [V]
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        precondition(
            maxSize >= 0,
            "maxSize must not be negative"
        )
        
        let seed: UInt64 = seed ?? .random(in: UInt64.min...UInt64.max)
        
        let context = GenerationContext(seed: seed)
        
        return (0..<count).map
        {
            context.size = count > 0
                ? $0 * maxSize / count
                : 0
            
            return generate(context)
        }
    }
}



// MARK: - Array

extension Generator
{
    /// Creates a generator that produces arrays with exactly the given count
    /// of elements.
    ///
    /// Since the count of elements is fixed, shrinking only applies to
    /// individual elements.
    ///
    /// - Precondition: `count` must not be negative.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The exact count of elements.
    /// - Returns: A generator that produces arrays with exactly the given
    /// count of elements.
    public static func array<E>(
        using generator : Generator<E>,
        count           : Int
    ) -> Generator<[E]> where V == [E]
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        return Generator<[E]>(
            generate:
            {
                context in
                
                return (0..<count).map
                {
                    _ in
                    
                    return generator.generate(context)
                }
            },
            shrink:
            {
                array in
                
                let shrinkElements: () -> [[E]] =
                {
                    return array.shrinkElements(by: { generator.shrink($0) })
                }
                
                return array.shrinkToward(
                    minCount:           count,
                    shrinkElements:     shrinkElements
                )
            },
            mutate:
            {
                array, context in
                
                return mutateArray(
                    array,
                    minCount:           count,
                    maxCount:           count,
                    mutateElement:      generator.mutate,
                    generateElement:    generator.generate,
                    using:              context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces arrays with a count of elements
    /// within the given range.
    ///
    /// Shrinking reduces the count of elements toward the lower bound and
    /// shrinks individual elements.
    ///
    /// - Precondition: `count` must not contain negative values.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given range.
    public static func array<E>(
        using generator : Generator<E>,
        count           : ClosedRange<Int>
    ) -> Generator<[E]> where V == [E]
    {
        precondition(
            count.lowerBound >= 0,
            "count must not contain negative values"
        )
        
        return Generator<[E]>(
            generate:
            {
                context in
                
                let length: Int = context.random(in: count)
                
                return (0..<length).map
                {
                    _ in
                    
                    return generator.generate(context)
                }
            },
            shrink:
            {
                array in
                
                let shrinkElements: () -> [[E]] =
                {
                    return array.shrinkElements(by: { generator.shrink($0) })
                }
                
                return array.shrinkToward(
                    minCount:           count.lowerBound,
                    shrinkElements:     shrinkElements
                )
            },
            mutate:
            {
                array, context in
                
                return mutateArray(
                    array,
                    minCount:           count.lowerBound,
                    maxCount:           count.upperBound,
                    mutateElement:      generator.mutate,
                    generateElement:    generator.generate,
                    using:              context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces arrays with a count of elements
    /// within the given range.
    ///
    /// Shrinking reduces the count of elements toward the lower bound and
    /// shrinks individual elements.
    ///
    /// - Precondition: `count` must not be empty or contain negative values.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given range.
    public static func array<E>(
        using generator : Generator<E>,
        count           : Range<Int>
    ) -> Generator<[E]> where V == [E]
    {
        precondition(
            !count.isEmpty,
            "count must not be empty"
        )
        
        precondition(
            count.lowerBound >= 0,
            "count must not contain negative values"
        )
        
        return array(
            using:  generator,
            count:  count.lowerBound...(count.upperBound - 1)
        )
    }
    
    
    
    /// Creates a generator that produces arrays with exactly the given count
    /// of elements.
    ///
    /// Since the count of elements is fixed, shrinking only applies to
    /// individual elements.
    ///
    /// - Precondition: `count` must not be negative.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The exact count of elements.
    /// - Returns: A generator that produces arrays with exactly the given
    /// count of elements.
    public static func array<E>(
        of type : E.Type    = E.self,
        count   : Int
    ) -> Generator<[E]> where V == [E], E : Arbitrary
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        return Generator<[E]>(
            generate:
            {
                context in
                
                return (0..<count).map
                {
                    _ in
                    
                    return E.arbitrary(using: context)
                }
            },
            shrink:
            {
                array in
                
                return array.shrinkElements()
            },
            mutate:
            {
                array, context in
                
                return mutateArray(
                    array,
                    minCount:           count,
                    maxCount:           count,
                    mutateElement:      { $0.mutate(using: $1) },
                    generateElement:    { E.arbitrary(using: $0) },
                    using:              context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces arrays with a count of elements
    /// within the given range.
    ///
    /// Shrinking reduces the count of elements toward the lower bound and
    /// shrinks individual elements.
    ///
    /// - Precondition: `count` must not contain negative values.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given range.
    public static func array<E>(
        of type : E.Type            = E.self,
        count   : ClosedRange<Int>
    ) -> Generator<[E]> where V == [E], E : Arbitrary
    {
        precondition(
            count.lowerBound >= 0,
            "count must not contain negative values"
        )
        
        return Generator<[E]>(
            generate:
            {
                context in
                
                let length: Int = context.random(in: count)
                
                return (0..<length).map
                {
                    _ in
                    
                    return E.arbitrary(using: context)
                }
            },
            shrink:
            {
                array in
                
                return array.shrinkToward(minCount: count.lowerBound)
            },
            mutate:
            {
                array, context in
                
                return mutateArray(
                    array,
                    minCount:           count.lowerBound,
                    maxCount:           count.upperBound,
                    mutateElement:      { $0.mutate(using: $1) },
                    generateElement:    { E.arbitrary(using: $0) },
                    using:              context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces arrays with a count of elements
    /// within the given range.
    ///
    /// Shrinking reduces the count of elements toward the lower bound and
    /// shrinks individual elements.
    ///
    /// - Precondition: `count` must not be empty or contain negative values.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given range.
    public static func array<E>(
        of type : E.Type        = E.self,
        count   : Range<Int>
    ) -> Generator<[E]> where V == [E], E : Arbitrary
    {
        precondition(
            !count.isEmpty,
            "count must not be empty"
        )
        
        precondition(
            count.lowerBound >= 0,
            "count must not contain negative values"
        )
        
        return array(
            of:     type,
            count:  count.lowerBound...(count.upperBound - 1)
        )
    }
    
    
    
    /// Creates a generator that produces non-empty arrays.
    ///
    /// The produced arrays have a count of elements within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameter type: The element type. The default value is inferred.
    /// - Returns: A generator that produces non-empty arrays.
    public static func nonEmptyArray<E>(
        of type: E.Type = E.self
    ) -> Generator<[E]> where V == [E], E : Arbitrary
    {
        return Generator<[E]>(
            generate:
            {
                context in
                
                let range   : ClosedRange<Int>  = 1...max(1, context.size)
                let length  : Int               = context.random(in: range)
                
                return (0..<length).map
                {
                    _ in
                    
                    return E.arbitrary(using: context)
                }
            },
            shrink:
            {
                array in
                
                return array.shrinkToward(minCount: 1)
            },
            mutate:
            {
                array, context in
                
                return mutateArray(
                    array,
                    minCount:           1,
                    maxCount:           nil,
                    mutateElement:      { $0.mutate(using: $1) },
                    generateElement:    { E.arbitrary(using: $0) },
                    using:              context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces arrays of unique elements with
    /// exactly the given count.
    ///
    /// Since the count of elements is fixed, shrinking only applies to
    /// individual elements. Shrink candidates that would introduce duplicate
    /// elements are skipped.
    ///
    /// - Precondition: `count` must not be negative.
    /// - Precondition: `generator` must produce at least `count` distinct
    /// values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The exact count of elements.
    /// - Returns: A generator that produces arrays of unique elements with
    /// exactly the given count.
    public static func uniqueArray<E>(
        using generator : Generator<E>,
        count           : Int
    ) -> Generator<[E]> where V == [E], E : Hashable
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        return Generator<[E]>(
            generate:
            {
                context in
                
                return generateUniqueElements(
                    count:      count,
                    generator:  generator,
                    context:    context
                )
            },
            shrink:
            {
                array in
                
                let shrinkElements: () -> [[E]] =
                {
                    return shrinkUniqueElements(
                        of:     array,
                        using:  generator
                    )
                }
                
                return array.shrinkToward(
                    minCount:           count,
                    shrinkElements:     shrinkElements
                )
            },
            mutate:
            {
                array, context in
                
                return mutateUniqueArray(
                    array,
                    minCount:           count,
                    maxCount:           count,
                    mutateElement:      generator.mutate,
                    generateElement:    generator.generate,
                    using:              context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces arrays of unique elements with
    /// a count within the given range.
    ///
    /// Shrinking reduces the count toward the lower bound of the given range,
    /// and shrinks individual elements. Shrink candidates that would introduce
    /// duplicate elements are skipped.
    ///
    /// - Precondition: `count.lowerBound` must not be negative.
    /// - Precondition: `generator` must produce at least `count.upperBound`
    /// distinct values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The range of element counts.
    /// - Returns: A generator that produces arrays of unique elements with
    /// a count within the given range.
    public static func uniqueArray<E>(
        using generator : Generator<E>,
        count           : ClosedRange<Int>
    ) -> Generator<[E]> where V == [E], E : Hashable
    {
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
        )
        
        return Generator<[E]>(
            generate:
            {
                context in
                
                return generateUniqueElements(
                    count:      context.random(in: count),
                    generator:  generator,
                    context:    context
                )
            },
            shrink:
            {
                array in
                
                let shrinkElements: () -> [[E]] =
                {
                    return shrinkUniqueElements(
                        of:     array,
                        using:  generator
                    )
                }
                
                return array.shrinkToward(
                    minCount:           count.lowerBound,
                    shrinkElements:     shrinkElements
                )
            },
            mutate:
            {
                array, context in
                
                return mutateUniqueArray(
                    array,
                    minCount:           count.lowerBound,
                    maxCount:           count.upperBound,
                    mutateElement:      generator.mutate,
                    generateElement:    generator.generate,
                    using:              context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces arrays of unique elements with
    /// a count within the given range.
    ///
    /// Shrinking reduces the count toward the lower bound of the given range,
    /// and shrinks individual elements. Shrink candidates that would introduce
    /// duplicate elements are skipped.
    ///
    /// - Precondition: `count` must not be empty.
    /// - Precondition: `count.lowerBound` must not be negative.
    /// - Precondition: `generator` must produce at least `count.upperBound - 1`
    /// distinct values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The range of element counts.
    /// - Returns: A generator that produces arrays of unique elements with
    /// a count within the given range.
    public static func uniqueArray<E>(
        using generator : Generator<E>,
        count           : Range<Int>
    ) -> Generator<[E]> where V == [E], E : Hashable
    {
        precondition(
            !count.isEmpty,
            "count must not be empty"
        )
        
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
        )
        
        return uniqueArray(
            using:  generator,
            count:  count.lowerBound...(count.upperBound - 1)
        )
    }
    
    
    
    /// Creates a generator that produces arrays of unique elements with
    /// exactly the given count.
    ///
    /// Since the count of elements is fixed, shrinking only applies to
    /// individual elements. Shrink candidates that would introduce duplicate
    /// elements are skipped.
    ///
    /// - Precondition: `count` must not be negative.
    /// - Precondition: `generator` must produce at least `count` distinct
    /// values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The exact count of elements.
    /// - Returns: A generator that produces arrays of unique elements with
    /// exactly the given count.
    public static func uniqueArray<E>(
        of type : E.Type    = E.self,
        count   : Int
    ) -> Generator<[E]> where V == [E], E : Arbitrary & Hashable
    {
        return uniqueArray(
            using:  .arbitrary(),
            count:  count
        )
    }
    
    
    
    /// Creates a generator that produces arrays of unique elements with
    /// a count within the given range.
    ///
    /// Shrinking reduces the count toward the lower bound of the given range,
    /// and shrinks individual elements. Shrink candidates that would introduce
    /// duplicate elements are skipped.
    ///
    /// - Precondition: `count.lowerBound` must not be negative.
    /// - Precondition: `generator` must produce at least `count.upperBound`
    /// distinct values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The range of element counts.
    /// - Returns: A generator that produces arrays of unique elements with
    /// a count within the given range.
    public static func uniqueArray<E>(
        of type : E.Type    = E.self,
        count   : ClosedRange<Int>
    ) -> Generator<[E]> where V == [E], E : Arbitrary & Hashable
    {
        return uniqueArray(
            using:  .arbitrary(),
            count:  count
        )
    }
    
    
    
    /// Creates a generator that produces arrays of unique elements with
    /// a count within the given range.
    ///
    /// Shrinking reduces the count toward the lower bound of the given range,
    /// and shrinks individual elements. Shrink candidates that would introduce
    /// duplicate elements are skipped.
    ///
    /// - Precondition: `count` must not be empty.
    /// - Precondition: `count.lowerBound` must not be negative.
    /// - Precondition: `generator` must produce at least `count.upperBound - 1`
    /// distinct values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The range of element counts.
    /// - Returns: A generator that produces arrays of unique elements with
    /// a count within the given range.
    public static func uniqueArray<E>(
        of type : E.Type    = E.self,
        count   : Range<Int>
    ) -> Generator<[E]> where V == [E], E : Arbitrary & Hashable
    {
        return uniqueArray(
            using:  .arbitrary(),
            count:  count
        )
    }
    
    
    
    /// Generates an array of unique elements.
    ///
    /// - Precondition: A valid array must be produced within
    /// `count * 10 + 1000` attempts.
    ///
    /// - Parameters:
    ///   - count: The number of unique elements to generate.
    ///   - generator: The element generator.
    ///   - context: The generation context.
    /// - Returns: An array of unique elements.
    private static func generateUniqueElements<E>(
        count       : Int,
        generator   : Generator<E>,
        context     : GenerationContext
    ) -> [E] where E : Hashable
    {
        guard count > 0
        else
        {
            return []
        }
        
        var elements    : [E]       = []
        var seen        : Set<E>    = []
        
        /// Multiply by `10` to scale with the request, and add `1000` to
        /// prevent trivially low limits when `count` is small.
        let maxAttempts: Int = count * 10 + 1000
        
        for _ in 0..<maxAttempts
        {
            let element: E = generator.generate(context)
            
            if seen.insert(element).inserted
            {
                elements.append(element)
                
                if elements.count == count
                {
                    return elements
                }
            }
        }
        
        preconditionFailure(
            "Generator.uniqueArray(of:count:) failed to produce \(count)"
            + " distinct values after \(maxAttempts) attempts. The element"
            + " generator may not produce enough distinct values."
        )
    }
    
    
    
    /// Shrinks individual elements of the given unique array, skipping
    /// candidates that would introduce duplicates.
    /// - Parameters:
    ///   - array: The array to shrink.
    ///   - generator: The element generator (for element shrinking).
    /// - Returns: The shrink candidates.
    private static func shrinkUniqueElements<E>(
        of      array       : [E],
        using   generator   : Generator<E>
    ) -> [[E]] where E : Hashable
    {
        let elements    : Set<E>    = Set(array)
        var candidates  : [[E]]     = []
        
        for index in array.indices
        {
            /// Elements other than the one being shrunk.
            var others: Set<E> = elements
            
            others.remove(array[index])
            
            for shrunken in generator.shrink(array[index])
            {
                guard !others.contains(shrunken)
                else
                {
                    continue
                }
                
                var copy: [E] = array
                
                copy[index] = shrunken
                
                candidates.append(copy)
            }
        }
        
        return candidates
    }
    
    
    
    /// Mutates the given array.
    /// - Parameters:
    ///   - array: The array to mutate.
    ///   - minCount: The minimum count of elements.
    ///   - maxCount: The maximum count of elements.
    ///   - mutateElement: The function to mutate the given element.
    ///   - generateElement: The function to generate an element.
    ///   - context: The generation context.
    /// - Returns: The mutated array.
    private static func mutateArray<E>(
        _ array         : [E],
        minCount        : Int,
        maxCount        : Int?,
        mutateElement   : (E, GenerationContext) -> E,
        generateElement : (GenerationContext) -> E,
        using context   : GenerationContext
    ) -> [E]
    {
        /// If `maxCount` is `nil`, there is no upper bound. Default to `true`.
        let canInsert: Bool = maxCount.map { array.count < $0 } ?? true
        
        guard !array.isEmpty
        else
        {
            guard canInsert
            else
            {
                return array
            }
            
            return [generateElement(context)]
        }
        
        let canRemove       : Bool  = array.count > minCount
        let mutateWeight    : Int   = 70
        let insertWeight    : Int   = canInsert ? 15 : 0
        let removeWeight    : Int   = canRemove ? 15 : 0
        let totalWeight     : Int   = mutateWeight + insertWeight + removeWeight
        let chance          : Int   = context.random(in: 1...totalWeight)
        
        var copy: [E] = array
        
        if chance <= mutateWeight
        {
            let index: Int = context.random(in: 0..<copy.count)
            
            copy[index] = mutateElement(copy[index], context)
        }
        else if chance <= mutateWeight + insertWeight
        {
            let index: Int = context.random(in: 0...copy.count)
            
            copy.insert(
                generateElement(context),
                at: index
            )
        }
        else
        {
            let index: Int = context.random(in: 0..<copy.count)
            
            copy.remove(at: index)
        }
        
        return copy
    }
    
    
    
    /// Mutates the given array.
    /// - Parameters:
    ///   - array: The array to mutate.
    ///   - minCount: The minimum count of elements.
    ///   - maxCount: The maximum count of elements.
    ///   - mutateElement: The function to mutate the given element.
    ///   - generateElement: The function to generate an element.
    ///   - context: The generation context.
    /// - Returns: The mutated array.
    private static func mutateUniqueArray<E>(
        _ array         : [E],
        minCount        : Int,
        maxCount        : Int?,
        mutateElement   : (E, GenerationContext) -> E,
        generateElement : (GenerationContext) -> E,
        using context   : GenerationContext
    ) -> [E] where E : Hashable
    {
        /// If `maxCount` is `nil`, there is no upper bound. Default to `true`.
        let canInsert: Bool = maxCount.map { array.count < $0 } ?? true
        
        guard !array.isEmpty
        else
        {
            guard canInsert
            else
            {
                return array
            }
            
            return [generateElement(context)]
        }
        
        let canRemove       : Bool  = array.count > minCount
        let mutateWeight    : Int   = 70
        let insertWeight    : Int   = canInsert ? 15 : 0
        let removeWeight    : Int   = canRemove ? 15 : 0
        let totalWeight     : Int   = mutateWeight + insertWeight + removeWeight
        let chance          : Int   = context.random(in: 1...totalWeight)
        
        var copy        : [E]       = array
        let existing    : Set<E>    = Set(array)
        
        if chance <= mutateWeight
        {
            let index   : Int       = context.random(in: 0..<copy.count)
            var others  : Set<E>    = existing
            
            others.remove(copy[index])
            
            for _ in 0..<1000
            {
                let mutated: E = mutateElement(
                    copy[index],
                    context
                )
                
                if !others.contains(mutated)
                {
                    copy[index] = mutated
                    
                    return copy
                }
            }
        }
        else if chance <= mutateWeight + insertWeight
        {
            for _ in 0..<1000
            {
                let element: E = generateElement(context)
                
                if !existing.contains(element)
                {
                    let index: Int = context.random(in: 0...copy.count)
                    
                    copy.insert(
                        element,
                        at: index
                    )
                    
                    return copy
                }
            }
        }
        else
        {
            let index: Int = context.random(in: 0..<copy.count)
            
            copy.remove(at: index)
        }
        
        return copy
    }
}



// MARK: - Optional

extension Generator
{
    /// Creates a generator that produces optional values, generating `nil`
    /// with the given  probability.
    ///
    /// Shrink candidates for non-`nil` values include `nil` followed by the
    /// shrunken wrapped values. `nil` does not shrink.
    ///
    /// - Precondition: `probability` must be in the range `0.0...1.0`.
    ///
    /// - Parameter probability: The probability of generating `nil`. The
    /// default value is `0.2`, generating `nil` 20% of the time.
    /// - Returns: A generator that produces optional values.
    public func optional(
        probability: Double = 0.2
    ) -> Generator<V?>
    {
        precondition(
            (0.0...1.0).contains(probability),
            "probability must be in the range 0.0...1.0"
        )
        
        return Generator<V?>(
            generate:
            {
                context in
                
                if context.random(in: 0.0..<1.0) < probability
                {
                    return nil
                }
                
                return self.generate(context)
            },
            shrink:
            {
                value in
                
                guard let wrapped: V = value
                else
                {
                    return []
                }
                
                return [nil] + self.shrink(wrapped).map { .some($0) }
            },
            mutate:
            {
                value, context in
                
                if context.random(in: 1...10) == 1
                {
                    if value == nil
                    {
                        return self.generate(context)
                    }
                    
                    return nil
                }
                
                guard let wrapped: V = value
                else
                {
                    return self.generate(context)
                }
                
                return self.mutate(wrapped, context)
            }
        )
    }
}



// MARK: - Character

extension Generator where V == Character
{
    /// Creates a generator that produces printable ASCII characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces printable ASCII characters.
    public static func ascii() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let value = UInt32(
                    context.random(in: Unicode.Scalar.asciiPrintableRange)
                )
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                return mutateCharacter(
                    character,
                    in:     Unicode.Scalar.asciiPrintableRange,
                    using:  context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces lowercase printable ASCII characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces lowercase printable ASCII
    /// characters.
    public static func lowercase() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let value = UInt32(
                    context.random(in: Unicode.Scalar.asciiLowercaseRange)
                )
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                return mutateCharacter(
                    character,
                    in:     Unicode.Scalar.asciiLowercaseRange,
                    using:  context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces uppercase printable ASCII characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces uppercase printable ASCII
    /// characters.
    public static func uppercase() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let value = UInt32(
                    context.random(in: Unicode.Scalar.asciiUppercaseRange)
                )
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                return mutateCharacter(
                    character,
                    in:     Unicode.Scalar.asciiUppercaseRange,
                    using:  context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces printable ASCII digit characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces printable ASCII digit characters.
    public static func digit() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let value = UInt32(
                    context.random(in: Unicode.Scalar.asciiDigitRange)
                )
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                return mutateCharacter(
                    character,
                    in:     Unicode.Scalar.asciiDigitRange,
                    using:  context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces alphanumeric characters.
    ///
    /// Shrink candidates converge toward `"a"`.
    ///
    /// - Returns: A generator that produces alphanumeric characters.
    public static func alphanumeric() -> Generator<Character>
    {
        return Generator<Character>(
            generate:
            {
                context in
                
                let range: ClosedRange<Int> = context.randomElement(
                    of:             Unicode.Scalar.alphanumericRanges,
                    weightedBy:     { $0.count }
                )!
                
                let value = UInt32(context.random(in: range))
                
                return Character(Unicode.Scalar(value)!)
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                character, context in
                
                let scalar: Int
                    = character.unicodeScalars.first.map { Int($0.value) }
                    ?? Unicode.Scalar.asciiLowercaseRange.lowerBound
                
                let range: ClosedRange<Int> = Unicode.Scalar.alphanumericRanges
                    .first { $0.contains(scalar) }
                    ?? Unicode.Scalar.asciiLowercaseRange
                
                return mutateCharacter(
                    character,
                    in:     range,
                    using:  context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that selects characters from the given string.
    ///
    /// - Precondition: `characters` must not be empty.
    ///
    /// - Parameter characters: The characters from which to select.
    /// - Returns: A generator that selects characters from the given string.
    public static func from(
        _ characters: String
    ) -> Generator<Character>
    {
        precondition(
            !characters.isEmpty,
            "characters must not be empty"
        )
        
        return Generator<Character>(
            generate:
            {
                context in
                
                return context.randomElement(of: characters)!
            },
            shrink:
            {
                character in
                
                return character.shrink()
            },
            mutate:
            {
                _, context in
                
                return context.randomElement(of: characters)!
            }
        )
    }
    
    
    
    /// Mutates the given character.
    /// - Parameters:
    ///   - character: The character to mutate.
    ///   - range: The ASCII range in which the character exists.
    ///   - context: The generation context.
    /// - Returns: The mutated character.
    private static func mutateCharacter(
        _       character   : Character,
        in      range       : ClosedRange<Int>,
        using   context     : GenerationContext
    ) -> Character
    {
        let scalar: UInt32 = character.unicodeScalars.first.map { UInt32($0) }
            ?? UInt32(range.lowerBound)
        
        let delta: Int = context.random(in: -context.size...context.size)
        
        let mutated = UInt32(min(
            range.upperBound,
            max(range.lowerBound, Int(scalar) + delta)
        ))
        
        return Character(Unicode.Scalar(mutated)!)
    }
}



// MARK: - String

extension Generator where V == String
{
    /// Creates a generator that produces strings with exactly the given count
    /// of characters.
    ///
    /// Since the count of characters is fixed, shrinking only applies to
    /// individual characters.
    ///
    /// - Precondition: `count` must not be negative.
    ///
    /// - Parameters:
    ///   - count: The exact count of characters.
    ///   - characters: The character generator to use. The default value is
    ///   ``Generator/ascii()``.
    /// - Returns: A generator that produces strings with exactly the given
    /// count of characters.
    public static func string(
        count       : Int,
        characters  : Generator<Character>  = .ascii()
    ) -> Generator<String>
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        return Generator<String>(
            generate:
            {
                context in
                
                let chars: [Character] = (0..<count).map
                {
                    _ in
                    
                    return characters.generate(context)
                }
                
                return String(chars)
            },
            shrink:
            {
                string in
                
                return string.shrinkCharacters()
            },
            mutate:
            {
                string, context in
                
                return mutateString(
                    string,
                    minCount:       count,
                    maxCount:       count,
                    characters:     characters,
                    using:          context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces strings with a count of characters
    /// within the given range.
    ///
    /// Shrinking reduces the count of characters toward the lower bound and
    /// shrinks individual characters.
    ///
    /// - Precondition: `count` must not contain negative values.
    ///
    /// - Parameters:
    ///   - count: The range of character counts.
    ///   - characters: The character generator to use. The default value is
    ///   ``Generator/ascii()``.
    /// - Returns: A generator that produces strings with a count of characters
    /// within the given range.
    public static func string(
        count       : ClosedRange<Int>,
        characters  : Generator<Character>  = .ascii()
    ) -> Generator<String>
    {
        precondition(
            count.lowerBound >= 0,
            "count must not contain negative values"
        )
        
        return Generator<String>(
            generate:
            {
                context in
                
                let length: Int = context.random(in: count)
                
                let chars: [Character] = (0..<length).map
                {
                    _ in
                    
                    return characters.generate(context)
                }
                
                return String(chars)
            },
            shrink:
            {
                string in
                
                return string.shrinkToward(minCount: count.lowerBound)
            },
            mutate:
            {
                string, context in
                
                return mutateString(
                    string,
                    minCount:       count.lowerBound,
                    maxCount:       count.upperBound,
                    characters:     characters,
                    using:          context
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces strings with a count of characters
    /// within the given range.
    ///
    /// Shrinking reduces the count of characters toward the lower bound and
    /// shrinks individual characters.
    ///
    /// - Precondition: `count` must not be empty or contain negative values.
    ///
    /// - Parameters:
    ///   - count: The range of character counts.
    ///   - characters: The character generator to use. The default value is
    ///   ``Generator/ascii()``.
    /// - Returns: A generator that produces strings with a count of characters
    /// within the given range.
    public static func string(
        count       : Range<Int>,
        characters  : Generator<Character>  = .ascii()
    ) -> Generator<String>
    {
        precondition(
            !count.isEmpty,
            "count must not be empty"
        )
        
        precondition(
            count.lowerBound >= 0,
            "count must not contain negative values"
        )
        
        return string(
            count:          count.lowerBound...(count.upperBound - 1),
            characters:     characters
        )
    }
    
    
    
    /// Creates a generator that produces non-empty strings.
    ///
    /// The produced strings have a count of characters within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameter characters: The character generator to use. The default
    /// value is ``Generator/ascii()``.
    /// - Returns: A generator that produces non-empty strings.
    public static func nonEmptyString(
        characters: Generator<Character> = .ascii()
    ) -> Generator<String>
    {
        return Generator<String>(
            generate:
            {
                context in
                
                let range   : ClosedRange<Int>  = 1...max(1, context.size)
                let length  : Int               = context.random(in: range)
                
                let chars: [Character] = (0..<length).map
                {
                    _ in
                    
                    return characters.generate(context)
                }
                
                return String(chars)
            },
            shrink:
            {
                string in
                
                return string.shrinkToward(minCount: 1)
            },
            mutate:
            {
                string, context in
                
                return mutateString(
                    string,
                    minCount:       1,
                    maxCount:       nil,
                    characters:     characters,
                    using:          context
                )
            }
        )
    }
    
    
    
    /// Mutates the given string.
    /// - Parameters:
    ///   - string: The string to mutate.
    ///   - minCount: The minimum character count.
    ///   - maxCount: The maximum character count.
    ///   - characters: The character generator.
    ///   - context: The generation context.
    /// - Returns: The mutated string.
    private static func mutateString(
        _ string        : String,
        minCount        : Int,
        maxCount        : Int?,
        characters      : Generator<Character>,
        using context   : GenerationContext
    ) -> String
    {
        /// If `maxCount` is `nil`, there is no upper bound. Default to `true`.
        let canInsert: Bool = maxCount.map { string.count < $0 } ?? true
        
        guard !string.isEmpty
        else
        {
            guard canInsert
            else
            {
                return string
            }
            
            return String(characters.generate(context))
        }
        
        let canRemove       : Bool  = string.count > minCount
        let mutateWeight    : Int   = 70
        let insertWeight    : Int   = canInsert ? 15 : 0
        let removeWeight    : Int   = canRemove ? 15 : 0
        let totalWeight     : Int   = mutateWeight + insertWeight + removeWeight
        let chance          : Int   = context.random(in: 1...totalWeight)
        
        var charArray: [Character] = Array(string)
        
        if chance <= mutateWeight
        {
            let index: Int = context.random(in: 0..<charArray.count)
            
            charArray[index] = characters.mutate(charArray[index], context)
        }
        else if chance <= mutateWeight + insertWeight
        {
            let index: Int = context.random(in: 0...charArray.count)
            
            charArray.insert(
                characters.generate(context),
                at: index
            )
        }
        else
        {
            let index: Int = context.random(in: 0..<charArray.count)
            
            charArray.remove(at: index)
        }
        
        return String(charArray)
    }
}



// MARK: - Integer

extension Generator where V : FixedWidthInteger
{
    /// Creates a generator that produces integers in the given range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The range in which to generate integers.
    /// - Returns: A generator that produces integers in the given range.
    public static func integer(
        in range: ClosedRange<V>
    ) -> Generator<V>
    {
        return Generator<V>(
            generate:
            {
                context in
                
                return context.random(in: range)
            },
            shrink:
            {
                value in
                
                return value.shrinkTowardZero(in: range)
            },
            mutate:
            {
                value, context in
                
                let maxDelta    : V     = V(clamping: max(1, context.size))
                let delta       : V     = context.random(in: 0...maxDelta)
                
                if context.randomBool()
                {
                    let (result, overflow)
                        = value.addingReportingOverflow(delta)
                    
                    return overflow
                        ? range.upperBound
                        : min(range.upperBound, result)
                }
                else
                {
                    let (result, overflow)
                        = value.subtractingReportingOverflow(delta)
                    
                    return overflow
                        ? range.lowerBound
                        : max(range.lowerBound, result)
                }
            }
        )
    }
    
    
    
    /// Creates a generator that produces integers in the given range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Precondition: `range` must not be empty.
    ///
    /// - Parameter range: The range in which to generate integers.
    /// - Returns: A generator that produces integers in the given range.
    public static func integer(
        in range: Range<V>
    ) -> Generator<V>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        return integer(in: range.lowerBound...(range.upperBound - 1))
    }
}



// MARK: - Floating

extension Generator
    where V : BinaryFloatingPoint,
          V.RawSignificand : FixedWidthInteger
{
    /// Creates a generator that produces floating-point numbers in the given
    /// range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The range in which to generate floating-point
    /// numbers.
    /// - Returns: A generator that produces floating-point numbers in the
    /// given range.
    public static func floatingPoint(
        in range: ClosedRange<V>
    ) -> Generator<V>
    {
        return Generator<V>(
            generate:
            {
                context in
                
                return context.random(in: range)
            },
            shrink:
            {
                value in
                
                return value.shrinkTowardZero(in: range)
            },
            mutate:
            {
                value, context in
                
                return mutateFloatingPoint(
                    value,
                    lowerBound:     range.lowerBound,
                    upperBound:     range.upperBound,
                    using:          context,
                    generate:       { context.random(in: range) }
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces integers in the given range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Precondition: `range` must not be empty.
    ///
    /// - Parameter range: The range in which to generate integers.
    /// - Returns: A generator that produces integers in the given range.
    public static func floatingPoint(
        in range: Range<V>
    ) -> Generator<V>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        return Generator<V>(
            generate:
            {
                context in
                
                return context.random(in: range)
            },
            shrink:
            {
                value in
                
                /// Shrink with a closed range and filter out the upper bound.
                let closed: ClosedRange<V>
                    = range.lowerBound...range.upperBound
                
                return value.shrinkTowardZero(in: closed)
                    .filter { range.contains($0) }
            },
            mutate:
            {
                value, context in
                
                return mutateFloatingPoint(
                    value,
                    lowerBound:     range.lowerBound,
                    upperBound:     range.upperBound.nextDown,
                    using:          context,
                    generate:   {    context.random(in: range) }
                )
            }
        )
    }
    
    
    
    /// Mutates the given floating-point number.
    /// - Parameters:
    ///   - value: The floating-point number to mutate.
    ///   - lowerBound: The lower bound of the range.
    ///   - upperBound: The upper bound of the range.
    ///   - context: The generation context.
    ///   - generate: The function to generate a value.
    /// - Returns: The mutated floating-point number.
    private static func mutateFloatingPoint(
        _ value         : V,
        lowerBound      : V,
        upperBound      : V,
        using context   : GenerationContext,
        generate        : () -> V
    ) -> V
    {
        guard value.isFinite
        else
        {
            return generate()
        }
        
        if context.random(in: 1...5) == 1
        {
            let factor  : V     = context.random(in: 0.5...1.5)
            let scaled  : V     = value * factor
            
            let clamped: V = min(
                upperBound,
                max(lowerBound, scaled)
            )
            
            return clamped.isFinite
                ? clamped
                : generate()
        }
        else
        {
            let magnitude   : V     = max(1.0, abs(value) * 0.1)
            let delta       : V     = context.random(in: -magnitude...magnitude)
            
            let result: V = min(
                upperBound,
                max(lowerBound, value + delta)
            )
            
            return result.isFinite
                ? result
                : generate()
        }
    }
}
