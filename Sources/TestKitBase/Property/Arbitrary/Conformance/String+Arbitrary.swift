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
}
