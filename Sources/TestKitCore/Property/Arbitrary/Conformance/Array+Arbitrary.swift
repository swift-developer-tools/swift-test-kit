//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Array: Arbitrary where Element : Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An array of with a length in the range `0...context.size`,
    /// filled with arbitrary elements.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Array
    {
        let count: Int = context.random(in: 0...context.size)
        
        return (0..<count).map { _ in Element.arbitrary(using: context) }
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates include the empty array, each half of the array, the array
    /// with individual elements removed, and the array with individual
    /// elements shrunk.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Array]
    {
        return shrinkTowardEmpty()
    }
    
    
    
    // MARK: - Support
    
    /// Shrinks the array by removing elements and shrinking individual
    /// elements.
    /// - Returns: The shrink candidates.
    internal func shrinkTowardEmpty() -> [[Element]]
    {
        return shrinkToward(minCount: 0)
    }
    
    
    
    /// Shrinks the array by removing elements (down to the given minimum
    /// count) and shrinking individual elements.
    ///
    /// Candidates include the minimum-length prefix, halves clamped to the
    /// minimum count, individual element removals, and individual element
    /// shrinks.
    ///
    /// - Parameter minCount: The minimum number of elements.
    /// - Returns: The shrink candidates.
    internal func shrinkToward(
        minCount: Int
    ) -> [[Element]]
    {
        guard !isEmpty
        else
        {
            return []
        }
        
        var candidates: [[Element]] = []
        
        if minCount == 0
        {
            candidates.append([])
        }
        
        
        
        /// Minimum count.
        if
            minCount != 0,
            count > minCount
        {
            candidates.append(Array(prefix(minCount)))
        }
        
        
        
        /// Halves, clamped to the minimum count.
        if count > minCount + 1
        {
            let halfCount: Int = Swift.max(count / 2, minCount)
            
            if
                halfCount != minCount,
                halfCount != count
            {
                /// If the count is odd, the middle element is dropped here,
                /// but will be included in the individual removal step.
                candidates.append(Array(prefix(halfCount)))
                candidates.append(Array(suffix(halfCount)))
            }
            
            /// Remove individual elements.
            for index in indices
            {
                var copy: [Element] = self
                
                copy.remove(at: index)
                
                candidates.append(copy)
            }
        }
        
        
        
        /// Shrink individual elements.
        candidates.append(contentsOf: shrinkElements())
        
        
        
        return candidates
    }
    
    
    
    /// Shrinks individual elements of the array, holding the others constant.
    /// - Returns: The shrink candidates.
    internal func shrinkElements() -> [[Element]]
    {
        var candidates: [[Element]] = []
        
        for index in indices
        {
            for shrunkenElement in self[index].shrink()
            {
                var copy: [Element] = self
                
                copy[index] = shrunkenElement
                
                candidates.append(copy)
            }
        }
        
        return candidates
    }
}
