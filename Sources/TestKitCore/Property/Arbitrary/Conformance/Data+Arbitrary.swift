//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Foundation



extension Data: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary data value with a count in the range
    /// `0...context.size`, filled with arbitrary bytes.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Data
    {
        let count: Int = context.random(in: 0...context.size)
        
        let bytes: [UInt8] = (0..<count).map
        {
            _ in
            
            return UInt8.arbitrary(using: context)
        }
        
        return Data(
            bytes:  bytes,
            count:  count
        )
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates are produces by converting to an array of bytes, shrinking
    /// that array, and converting back to data.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Data]
    {
        return Array(self).shrinkTowardEmpty().map { Data($0) }
    }
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated data value.
    public func mutate(
        using context: GenerationContext
    ) -> Data
    {
        return Data(Array(self).mutateElements(
            using:          context,
            mutateElement:  { $0.mutate(using: $1 )},
            makeElement:    { Element.arbitrary(using: $0) }
        ))
    }
}
