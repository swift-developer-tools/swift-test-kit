//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension String: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: A string with a length in the range `0...context.size`,
    /// filled with arbitrary characters.
    public static func arbitrary(
        using context: GenerationContext
    ) -> String
    {
        let count: Int = context.random(in: 0...context.size)
        
        return String(
            (0..<count).map { _ in Character.arbitrary(using: context) }
        )
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates include the empty string, each of the string, the string
    /// with individual characters removed, and the string with individual
    /// characters shrunk.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [String]
    {
        return shrinkTowardEmpty()
    }
    
    
    
    /// Shrinks the string by removing characters and shrinking individual
    /// characters.
    /// - Returns: The shrink candidates.
    internal func shrinkTowardEmpty() -> [String]
    {
        return shrinkToward(minCount: 0)
    }
    
    
    
    // MARK: - Support
    
    /// Shrinks the string by removing characters (down to the given minimum
    /// count) and shrinking individual characters.
    ///
    /// Candidates include the empty string, each of the string, the string
    /// with individual characters removed, and the string with individual
    /// characters shrunk.
    ///
    /// - Parameter minCount: The minimum number of characters.
    /// - Returns: The shrink candidates.
    internal func shrinkToward(
        minCount: Int
    ) -> [String]
    {
        let characters: [Character] = Array(self)
        
        guard !characters.isEmpty
        else
        {
            return []
        }
        
        var candidates: [String] = []
        
        if minCount == 0
        {
            candidates.append("")
        }
        
        
        
        /// Minimum count.
        if
            minCount != 0,
            characters.count > minCount
        {
            candidates.append(String(prefix(minCount)))
        }
        
        
        
        /// Halves, clamped to the minimum count.
        if characters.count > minCount + 1
        {
            let halfCount: Int = Swift.max(characters.count / 2, minCount)
            
            if
                halfCount != minCount,
                halfCount != characters.count
            {
                /// If the count is odd, the middle character is dropped here,
                /// but will be included in the individual removal step.
                candidates.append(String(prefix(halfCount)))
                candidates.append(String(suffix(halfCount)))
            }
            
            /// Remove individual characters.
            for index in characters.indices
            {
                var copy: [Character] = characters
                
                copy.remove(at: index)
                
                candidates.append(String(copy))
            }
        }
        
        
        
        /// Shrink individual characters.
        candidates.append(contentsOf: shrinkCharacters())
        
        
        
        return candidates
    }
    
    
    
    /// Shrinks individual characters of the array, holding the others constant.
    /// - Returns: The shrink candidates.
    internal func shrinkCharacters() -> [String]
    {
        let characters  : [Character]   = Array(self)
        var candidates  : [String]      = []
        
        for index in characters.indices
        {
            for shrunkenCharacter in characters[index].shrink()
            {
                var copy: [Character] = characters
                
                copy[index] = shrunkenCharacter
                
                candidates.append(String(copy))
            }
        }
        
        return candidates
    }
}
