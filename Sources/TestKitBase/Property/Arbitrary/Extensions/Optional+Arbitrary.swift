//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Optional: Arbitrary where Wrapped : Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: `nil` approximately 20% of the time. Otherwise, an arbitrary
    /// wrapped value.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Optional
    {
        if context.random(in: 1...5) == 1
        {
            return nil
        }
        
        return Wrapped.arbitrary(using: context)
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// Non-`nil` values shrink to `nil` first, then to shrunken wrapped
    /// values. `nil` does not shrink.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Optional]
    {
        switch self
        {
            case .none:
                
                return []
                
            case let .some(wrapped):
                
                return [nil] + wrapped.shrink().map { .some($0) }
        }
    }
}
