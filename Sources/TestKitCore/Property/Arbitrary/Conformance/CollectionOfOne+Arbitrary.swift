//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension CollectionOfOne: Arbitrary where Element : Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: A collection containing a single arbitrary element.
    public static func arbitrary(
        using context: GenerationContext
    ) -> CollectionOfOne
    {
        return CollectionOfOne(Element.arbitrary(using: context))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates are produced by shrinking the contained element.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [CollectionOfOne]
    {
        return self[startIndex].shrink().map { CollectionOfOne($0) }
    }
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated collection.
    public func mutate(
        using context: GenerationContext
    ) -> CollectionOfOne
    {
        return CollectionOfOne(self[startIndex].mutate(using: context))
    }
}
