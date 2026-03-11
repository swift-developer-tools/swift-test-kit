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
    // MARK: - Generator exact
    
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
    ) -> Generator<[E]> where G == [E]
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
    
    
    
    // MARK: - Generator range
    
    /// Creates a generator that produces arrays with a count of elements
    /// within the given range.
    ///
    /// Shrinking reduces the count of elements toward the lower bound and
    /// shrinks individual elements.
    ///
    /// - Precondition: `count.lowerBound` must not be negative.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given range.
    public static func array<E>(
        using generator : Generator<E>,
        count           : ClosedRange<Int>
    ) -> Generator<[E]> where G == [E]
    {
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
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
    /// - Precondition: `count` must not be empty.
    /// - Precondition: `count.lowerBound` must not be negative.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given range.
    public static func array<E>(
        using generator : Generator<E>,
        count           : Range<Int>
    ) -> Generator<[E]> where G == [E]
    {
        precondition(
            !count.isEmpty,
            "count must not be empty"
        )
        
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
        )
        
        return array(
            using:  generator,
            count:  count.lowerBound...(count.upperBound - 1)
        )
    }
    
    
    
    // MARK: - Arbitrary exact
    
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
    ) -> Generator<[E]> where G == [E], E : Arbitrary
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
    
    
    
    // MARK: - Arbitrary range
    
    /// Creates a generator that produces arrays with a count of elements
    /// within the given range.
    ///
    /// Shrinking reduces the count of elements toward the lower bound and
    /// shrinks individual elements.
    ///
    /// - Precondition: `count.lowerBound` must not be negative.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given range.
    public static func array<E>(
        of type : E.Type            = E.self,
        count   : ClosedRange<Int>
    ) -> Generator<[E]> where G == [E], E : Arbitrary
    {
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
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
    /// - Precondition: `count` must not be empty.
    /// - Precondition: `count.lowerBound` must not be negative.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The range of valid element counts.
    /// - Returns: A generator that produces arrays with a count of elements
    /// within the given range.
    public static func array<E>(
        of type : E.Type        = E.self,
        count   : Range<Int>
    ) -> Generator<[E]> where G == [E], E : Arbitrary
    {
        precondition(
            !count.isEmpty,
            "count must not be empty"
        )
        
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
        )
        
        return array(
            of:     type,
            count:  count.lowerBound...(count.upperBound - 1)
        )
    }
    
    
    
    // MARK: - Non-empty
    
    /// Creates a generator that produces non-empty arrays.
    ///
    /// The produced arrays have a count of elements within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameter generator: The element generator.
    /// - Returns: A generator that produces non-empty arrays.
    public static func nonEmptyArray<E>(
        using generator: Generator<E>
    ) -> Generator<[E]> where G == [E]
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
                    minCount:           1,
                    shrinkElements:     shrinkElements
                )
            },
            mutate:
            {
                array, context in
                
                return mutateArray(
                    array,
                    minCount:           1,
                    maxCount:           nil,
                    mutateElement:      generator.mutate,
                    generateElement:    generator.generate,
                    using:              context
                )
            }
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
    ) -> Generator<[E]> where G == [E], E : Arbitrary
    {
        return nonEmptyArray(using: .arbitrary())
    }
    
    
    
    // MARK: - Unique Generator exact
    
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
    ) -> Generator<[E]> where G == [E], E : Hashable
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
    
    
    
    // MARK: - Unique Generator range
    
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
    ) -> Generator<[E]> where G == [E], E : Hashable
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
    ) -> Generator<[E]> where G == [E], E : Hashable
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
    
    
    
    // MARK: - Unique Arbitrary exact
    
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
    ) -> Generator<[E]> where G == [E], E : Arbitrary & Hashable
    {
        return uniqueArray(
            using:  .arbitrary(),
            count:  count
        )
    }
    
    
    
    // MARK: - Unique Arbitrary range
    
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
    ) -> Generator<[E]> where G == [E], E : Arbitrary & Hashable
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
    ) -> Generator<[E]> where G == [E], E : Arbitrary & Hashable
    {
        return uniqueArray(
            using:  .arbitrary(),
            count:  count
        )
    }
    
    
    
    // MARK: - Support
    
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
    internal static func generateUniqueElements<E>(
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
    internal static func shrinkUniqueElements<E>(
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
    internal static func mutateUniqueArray<E>(
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
