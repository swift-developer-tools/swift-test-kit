//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Range: Arbitrary where Bound : Arbitrary & Comparable
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: A range formed from two arbitrary bounds.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Range
    {
        let a   = Bound.arbitrary(using: context)
        let b   = Bound.arbitrary(using: context)
        
        if a <= b
        {
            return a..<b
        }
        
        return b..<a
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates include versions with the lower bound shrunk upward, the
    /// upper bound shrunk downward, and both bounds shrunk toward each other.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Range]
    {
        var candidates: [Range] = []
        
        /// Shrink the lower bound upward.
        for lower in lowerBound.shrink()
        {
            if lower <= upperBound
            {
                candidates.append(lower..<upperBound)
            }
        }
        
        /// Shrink the upper bound downward.
        for upper in upperBound.shrink()
        {
            if lowerBound <= upper
            {
                candidates.append(lowerBound..<upper)
            }
        }
        
        /// Shrink both bounds toward each other.
        for lower in lowerBound.shrink()
        {
            for upper in upperBound.shrink()
            {
                if lower <= upper
                {
                    candidates.append(lower..<upper)
                }
            }
        }
        
        return candidates
    }
}
