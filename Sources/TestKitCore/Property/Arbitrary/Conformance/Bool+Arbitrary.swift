//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Bool: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: A uniformly random Boolean.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Bool
    {
        return context.randomBool()
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// `true` shrinks to `false`. `false` does not shrink.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Bool]
    {
        if self
        {
            return [false]
        }
        
        return []
    }
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    ///
    /// `true` mutates to `false`. `false` mutates to `true`.
    ///
    /// - Parameter context: The generation context.
    /// - Returns: A mutated Boolean.
    public func mutate(
        using context: GenerationContext
    ) -> Bool
    {
        return !self
    }
}
