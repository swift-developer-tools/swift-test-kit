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
    
    /// Creates a generator that produces sets with exactly the given count
    /// of elements.
    ///
    /// Since the count of elements is fixed, shrinking only applies to
    /// individual elements.
    ///
    /// - Precondition: `count` must not be negative.
    /// - Precondition: `generator` must produce at least `count` distinct
    /// values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The exact count of elements.
    /// - Returns: A generator that produces sets with exactly the given
    /// count of elements.
    public static func set<E>(
        using generator : Generator<E>,
        count           : Int
    ) -> Generator<Set<E>> where G == Set<E>, E : Hashable
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        return Generator<Set<E>>(
            generate:
            {
                context in
                
                return Set(generateUniqueElements(
                    count:      count,
                    generator:  generator,
                    context:    context
                ))
            },
            shrink:
            {
                set in
                
                let array: [E] = Array(set)
                
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
                ).map { Set($0) }
            },
            mutate:
            {
                set, context in
                
                return Set(mutateUniqueArray(
                    Array(set),
                    minCount:           count,
                    maxCount:           count,
                    mutateElement:      generator.mutate,
                    generateElement:    generator.generate,
                    using:              context
                ))
            }
        )
    }
    
    
    
    // MARK: - Generator range
    
    /// Creates a generator that produces sets of unique elements with
    /// a count within the given range.
    ///
    /// Shrinking reduces the count toward the lower bound of the given range,
    /// and shrinks individual elements.
    ///
    /// - Precondition: `count.lowerBound` must not be negative.
    /// - Precondition: `generator` must produce at least `count.upperBound`
    /// distinct values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The range of element counts.
    /// - Returns: A generator that produces sets of unique elements with
    /// a count within the given range.
    public static func set<E>(
        using generator : Generator<E>,
        count           : ClosedRange<Int>
    ) -> Generator<Set<E>> where G == Set<E>, E : Hashable
    {
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
        )
        
        return Generator<Set<E>>(
            generate:
            {
                context in
                
                return Set(generateUniqueElements(
                    count:      context.random(in: count),
                    generator:  generator,
                    context:    context
                ))
            },
            shrink:
            {
                set in
                
                let array: [E] = Array(set)
                
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
                ).map { Set($0) }
            },
            mutate:
            {
                set, context in
                
                return Set(mutateUniqueArray(
                    Array(set),
                    minCount:           count.lowerBound,
                    maxCount:           count.upperBound,
                    mutateElement:      generator.mutate,
                    generateElement:    generator.generate,
                    using:              context
                ))
            }
        )
    }
    
    
    
    /// Creates a generator that produces sets of unique elements with
    /// a count within the given range.
    ///
    /// Shrinking reduces the count toward the lower bound of the given range,
    /// and shrinks individual elements.
    ///
    /// - Precondition: `count` must not be empty.
    /// - Precondition: `count.lowerBound` must not be negative.
    /// - Precondition: `generator` must produce at least `count.upperBound - 1`
    /// distinct values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - generator: The element generator.
    ///   - count: The range of element counts.
    /// - Returns: A generator that produces sets of unique elements with
    /// a count within the given range.
    public static func set<E>(
        using generator : Generator<E>,
        count           : Range<Int>
    ) -> Generator<Set<E>> where G == Set<E>, E : Hashable
    {
        precondition(
            !count.isEmpty,
            "count must not be empty"
        )
        
        precondition(
            count.lowerBound >= 0,
            "count.lowerBound must not be negative"
        )
        
        return set(
            using:  generator,
            count:  count.lowerBound...(count.upperBound - 1)
        )
    }
    
    
    
    // MARK: - Arbitrary exact
    
    /// Creates a generator that produces sets of unique elements with
    /// exactly the given count.
    ///
    /// Since the count of elements is fixed, shrinking only applies to
    /// individual elements.
    ///
    /// - Precondition: `count` must not be negative.
    /// - Precondition: `generator` must produce at least `count` distinct
    /// values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The exact count of elements.
    /// - Returns: A generator that produces sets of unique elements with
    /// exactly the given count.
    public static func set<E>(
        of type : E.Type    = E.self,
        count   : Int
    ) -> Generator<Set<E>> where G == Set<E>, E : Arbitrary & Hashable
    {
        return set(
            using:  .arbitrary(),
            count:  count
        )
    }
    
    
    
    // MARK: - Arbitrary range
    
    /// Creates a generator that produces sets of unique elements with
    /// a count within the given range.
    ///
    /// Shrinking reduces the count toward the lower bound of the given range,
    /// and shrinks individual elements.
    ///
    /// - Precondition: `count.lowerBound` must not be negative.
    /// - Precondition: `generator` must produce at least `count.upperBound`
    /// distinct values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The range of element counts.
    /// - Returns: A generator that produces sets of unique elements with
    /// a count within the given range.
    public static func set<E>(
        of type : E.Type    = E.self,
        count   : ClosedRange<Int>
    ) -> Generator<Set<E>> where G == Set<E>, E : Arbitrary & Hashable
    {
        return set(
            using:  .arbitrary(),
            count:  count
        )
    }
    
    
    
    /// Creates a generator that produces sets of unique elements with
    /// a count within the given range.
    ///
    /// Shrinking reduces the count toward the lower bound of the given range,
    /// and shrinks individual elements.
    ///
    /// - Precondition: `count` must not be empty.
    /// - Precondition: `count.lowerBound` must not be negative.
    /// - Precondition: `generator` must produce at least `count.upperBound - 1`
    /// distinct values within a reasonable number of attempts.
    ///
    /// - Parameters:
    ///   - type: The element type. The default value is inferred.
    ///   - count: The range of element counts.
    /// - Returns: A generator that produces sets of unique elements with
    /// a count within the given range.
    public static func set<E>(
        of type : E.Type    = E.self,
        count   : Range<Int>
    ) -> Generator<Set<E>> where G == Set<E>, E : Arbitrary & Hashable
    {
        return set(
            using:  .arbitrary(),
            count:  count
        )
    }
    
    
    
    // MARK: - Non-empty
    
    /// Creates a generator that produces non-empty sets.
    ///
    /// The produced sets have a count of elements within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameter generator: The element generator.
    /// - Returns: A generator that produces non-empty sets.
    public static func nonEmptySet<E>(
        using generator: Generator<E>
    ) -> Generator<Set<E>> where G == Set<E>, E : Hashable
    {
        return Generator<Set<E>>(
            generate:
            {
                context in
                
                let range   : ClosedRange<Int>  = 1...max(1, context.size)
                let count   : Int               = context.random(in: range)
                
                return Set(generateUniqueElements(
                    count:      count,
                    generator:  generator,
                    context:    context
                ))
            },
            shrink:
            {
                set in
                
                let array: [E] = Array(set)
                
                let shrinkElements: () -> [[E]] =
                {
                    return shrinkUniqueElements(
                        of:     array,
                        using:  generator
                    )
                }
                
                return array.shrinkToward(
                    minCount:           1,
                    shrinkElements:     shrinkElements
                ).map { Set($0) }
            },
            mutate:
            {
                set, context in
                
                return Set(mutateUniqueArray(
                    Array(set),
                    minCount:           1,
                    maxCount:           nil,
                    mutateElement:      generator.mutate,
                    generateElement:    generator.generate,
                    using:              context
                ))
            }
        )
    }
    
    
    
    /// Creates a generator that produces non-empty sets.
    ///
    /// The produced sets have a count of elements within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameter type: The element type. The default value is inferred.
    /// - Returns: A generator that produces non-empty sets.
    public static func nonEmptySet<E>(
        of type: E.Type = E.self
    ) -> Generator<Set<E>> where G == Set<E>, E : Arbitrary & Hashable
    {
        return nonEmptySet(using: .arbitrary())
    }
}
