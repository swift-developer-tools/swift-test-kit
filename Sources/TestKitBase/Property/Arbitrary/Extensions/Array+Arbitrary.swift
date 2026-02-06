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
        let count: Int = context.randomInt(in: 0...context.size)
        
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
        guard !isEmpty
        else
        {
            return []
        }
        
        var candidates: [Array] = []
        
        candidates.append([])
        
        
        
        if count > 1
        {
            /// If the count is odd, the middle element is dropped here,
            /// but will be included in the individual removal step.
            let firstHalf   = Array(prefix(count / 2))
            let secondHalf  = Array(suffix(count / 2))
            
            candidates.append(firstHalf)
            candidates.append(secondHalf)
        }
        
        
        
        /// Remove individual elements.
        for index in indices
        {
            var copy: [Element] = self
            
            copy.remove(at: index)
            
            guard !copy.isEmpty
            else
            {
                /// Skip if this produces an empty array, which is already
                /// the first candidate.
                continue
            }
            
            candidates.append(copy)
        }
        
        
        
        /// Shrink individual elements.
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
