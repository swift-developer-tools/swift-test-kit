//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Result: Arbitrary
    where Success : Arbitrary, Failure : Arbitrary & Error
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: `.success` of `.failure` with equal probability, each
    /// containing an arbitrary associated value.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Result
    {
        if context.randomBool()
        {
            return .success(Success.arbitrary(using: context))
        }
        
        return .failure(Failure.arbitrary(using: context))
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Candidates are produced by shrinking shrinking the associated value
    /// while preserving the case.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Result]
    {
        switch self
        {
            case let .success(value):
                
                return value.shrink().map { .success($0) }
                
            case let .failure(error):
                
                return error.shrink().map { .failure($0) }
        }
    }
}
