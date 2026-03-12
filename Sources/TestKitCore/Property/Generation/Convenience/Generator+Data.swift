//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Foundation



extension Generator where G == Data
{
    // MARK: - Generator exact
    
    /// Creates a generator that produces `Data` instances with exactly the
    /// given count of bytes.
    ///
    /// Since the count of bytes is fixed, shrinking only applies to
    /// individual bytes.
    ///
    /// - Precondition: `count` must not be negative.
    ///
    /// - Parameters:
    ///   - generator: The byte generator.
    ///   - count: The exact count of bytes.
    /// - Returns: A generator that produces `Data` instances with exactly the
    /// given count of bytes.
    public static func data(
        using generator : Generator<UInt8>,
        count           : Int
    ) -> Generator<Data>
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        return Generator<Data>(
            generate:
            {
                context in
                
                let bytes: [UInt8] = (0..<count).map
                {
                    _ in
                    
                    return generator.generate(context)
                }
                
                return Data(bytes)
            },
            shrink:
            {
                data in
                
                return Array(data)
                    .shrinkElements(by: { generator.shrink($0) })
                    .map { Data($0) }
            },
            mutate:
            {
                data, context in
                
                return Data(mutateData(
                    Array(data),
                    minCount:   count,
                    maxCount:   count,
                    bytes:      generator,
                    using:      context
                ))
            }
        )
    }
    
    
    
    // MARK: - Generator range
    
    /// Creates a generator that produces `Data` instances with a count of
    /// bytes within the given range.
    ///
    /// Shrinking reduces the count of bytes toward the lower bound and
    /// shrinks individual bytes.
    ///
    /// - Precondition: `range.lowerBound` must not be negative.
    ///
    /// - Parameters:
    ///   - generator: The byte generator.
    ///   - range: The range of valid byte counts.
    /// - Returns: A generator that produces `Data` instances with a count of
    /// bytes within the given range.
    public static func data(
        using   generator   : Generator<UInt8>,
        count   range       : ClosedRange<Int>
    ) -> Generator<Data>
    {
        precondition(
            range.lowerBound >= 0,
            "range.lowerBound must not be negative"
        )
        
        return Generator<Data>(
            generate:
            {
                context in
                
                let count: Int = context.random(in: range)
                
                let bytes: [UInt8] = (0..<count).map
                {
                    _ in
                    
                    return generator.generate(context)
                }
                
                return Data(bytes)
            },
            shrink:
            {
                data in
                
                let bytes: [UInt8] = Array(data)
                
                let shrinkElements: () -> [[UInt8]] =
                {
                    return bytes.shrinkElements(by: { generator.shrink($0) })
                }
                
                return bytes.shrinkToward(
                    minCount:           range.lowerBound,
                    shrinkElements:     shrinkElements
                ).map { Data($0) }
            },
            mutate:
            {
                data, context in
                
                return Data(mutateData(
                    Array(data),
                    minCount:   range.lowerBound,
                    maxCount:   range.upperBound,
                    bytes:      generator,
                    using:      context
                ))
            }
        )
    }
    
    
    
    /// Creates a generator that produces `Data` instances with a count of
    /// bytes within the given range.
    ///
    /// Shrinking reduces the count of bytes toward the lower bound and
    /// shrinks individual bytes.
    ///
    /// - Precondition: `range` must not be empty.
    /// - Precondition: `range.lowerBound` must not be negative.
    ///
    /// - Parameters:
    ///   - generator: The byte generator.
    ///   - range: The range of valid byte counts.
    /// - Returns: A generator that produces `Data` instances with a count of
    /// bytes within the given range.
    public static func data(
        using   generator   : Generator<UInt8>,
        count   range       : Range<Int>
    ) -> Generator<Data>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        precondition(
            range.lowerBound >= 0,
            "range.lowerBound must not be negative"
        )
        
        return data(
            using:  generator,
            count:  range.lowerBound...(range.upperBound - 1)
        )
    }
    
    
    
    // MARK: - Arbitrary exact
    
    /// Creates a generator that produces `Data` instances with exactly the
    /// given count of bytes.
    ///
    /// Since the count of bytes is fixed, shrinking only applies to
    /// individual bytes.
    ///
    /// - Precondition: `count` must not be negative.
    ///
    /// - Parameter count: The exact count of bytes.
    /// - Returns: A generator that produces `Data` instances with exactly the
    /// given count of bytes.
    public static func data(
        count: Int
    ) -> Generator<Data>
    {
        return data(
            using:  .arbitrary(),
            count:  count
        )
    }
    
    
    
    // MARK: - Arbitrary range
    
    /// Creates a generator that produces `Data` instances with a count of
    /// bytes within the given range.
    ///
    /// Shrinking reduces the count of bytes toward the lower bound and
    /// shrinks individual bytes.
    ///
    /// - Precondition: `range.lowerBound` must not be negative.
    ///
    /// - Parameter range: The range of valid byte counts.
    /// - Returns: A generator that produces `Data` instances with a count of
    /// bytes within the given range.
    public static func data(
        count range: ClosedRange<Int>
    ) -> Generator<Data>
    {
        return data(
            using:  .arbitrary(),
            count:  range
        )
    }
    
    
    
    /// Creates a generator that produces `Data` instances with a count of
    /// bytes within the given range.
    ///
    /// Shrinking reduces the count of bytes toward the lower bound and
    /// shrinks individual bytes.
    ///
    /// - Precondition: `range` must not be empty.
    /// - Precondition: `range.lowerBound` must not be negative.
    ///
    /// - Parameter range: The range of valid byte counts.
    /// - Returns: A generator that produces `Data` instances with a count of
    /// bytes within the given range.
    public static func data(
        count range: Range<Int>
    ) -> Generator<Data>
    {
        return data(
            using:  .arbitrary(),
            count:  range
        )
    }
    
    
    
    // MARK: - Non-empty
    
    /// Creates a generator that produces non-empty `Data` instances.
    ///
    /// The produced `Data` instances have a count of bytes within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Parameter generator: The byte generator.
    /// - Returns: A generator that produces non-empty `Data` instances.
    public static func nonEmptyData(
        using generator: Generator<UInt8>
    ) -> Generator<Data>
    {
        return Generator<Data>(
            generate:
            {
                context in
                
                let range   : ClosedRange<Int>  = 1...max(1, context.size)
                let count   : Int               = context.random(in: range)
                
                let bytes: [UInt8] = (0..<count).map
                {
                    _ in
                    
                    return generator.generate(context)
                }
                
                return Data(bytes)
            },
            shrink:
            {
                data in
                
                let bytes: [UInt8] = Array(data)
                
                let shrinkElements: () -> [[UInt8]] =
                {
                    return bytes.shrinkElements(by: { generator.shrink($0) })
                }
                
                return bytes.shrinkToward(
                    minCount:           1,
                    shrinkElements:     shrinkElements
                ).map { Data($0) }
            },
            mutate:
            {
                data, context in
                
                return Data(mutateData(
                    Array(data),
                    minCount:   1,
                    maxCount:   nil,
                    bytes:      generator,
                    using:      context
                ))
            }
        )
    }
    
    
    
    /// Creates a generator that produces non-empty `Data` instances.
    ///
    /// The produced `Data` instances have a count of bytes within the range
    /// `1...max(1, context.size)`.
    ///
    /// - Returns: A generator that produces non-empty `Data` instances.
    public static func nonEmptyData() -> Generator<Data>
    {
        return nonEmptyData(using: .arbitrary())
    }
    
    
    
    // MARK: - Support
    
    /// Mutates the given bytes.
    /// - Parameters:
    ///   - bytes: The bytes to mutate.
    ///   - minCount: The minimum count of bytes.
    ///   - maxCount: The maximum count of bytes.
    ///   - generator: The byte generator.
    ///   - context: The generation context.
    /// - Returns: The mutated bytes.
    private static func mutateData(
        _           bytes       : [UInt8],
        minCount                : Int,
        maxCount                : Int?,
        bytes       generator   : Generator<UInt8>,
        using       context     : GenerationContext
    ) -> [UInt8]
    {
        /// If `maxCount` is `nil`, there is no upper bound. Default to `true`.
        let canInsert: Bool = maxCount.map { bytes.count < $0 } ?? true
        
        guard !bytes.isEmpty
        else
        {
            guard canInsert
            else
            {
                return bytes
            }
            
            return [generator.generate(context)]
        }
        
        let canRemove       : Bool  = bytes.count > minCount
        let mutateWeight    : Int   = 70
        let insertWeight    : Int   = canInsert ? 15 : 0
        let removeWeight    : Int   = canRemove ? 15 : 0
        let totalWeight     : Int   = mutateWeight + insertWeight + removeWeight
        let chance          : Int   = context.random(in: 1...totalWeight)
        
        var copy: [UInt8] = bytes
        
        if chance <= mutateWeight
        {
            let index: Int = context.random(in: 0..<copy.count)
            
            copy[index] = generator.mutate(copy[index], context)
        }
        else if chance <= mutateWeight + insertWeight
        {
            let index: Int = context.random(in: 0...copy.count)
            
            copy.insert(
                generator.generate(context),
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
}
