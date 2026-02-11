//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Array where Element : Arbitrary
{
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
    func shrinkElements() -> [[Element]]
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
