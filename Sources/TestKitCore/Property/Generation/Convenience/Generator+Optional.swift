//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator
{
    /// Creates a generator that produces optional values, generating `nil`
    /// with the given  probability.
    ///
    /// Shrink candidates for non-`nil` values include `nil` followed by the
    /// shrunken wrapped values. `nil` does not shrink.
    ///
    /// - Precondition: `probability` must be in the range `0.0...1.0`.
    ///
    /// - Parameter probability: The probability of generating `nil`. The
    /// default value is `0.2`, generating `nil` 20% of the time.
    /// - Returns: A generator that produces optional values.
    public func optional(
        probability: Double = 0.2
    ) -> Generator<G?>
    {
        precondition(
            (0.0...1.0).contains(probability),
            "probability must be in the range 0.0...1.0"
        )
        
        return Generator<G?>(
            generate:
            {
                context in
                
                if context.random(in: 0.0..<1.0) < probability
                {
                    return nil
                }
                
                return self.generate(context)
            },
            shrink:
            {
                value in
                
                guard let wrapped: G = value
                else
                {
                    return []
                }
                
                return [nil] + self.shrink(wrapped).map { .some($0) }
            },
            mutate:
            {
                value, context in
                
                if context.random(in: 1...10) == 1
                {
                    if value == nil
                    {
                        return self.generate(context)
                    }
                    
                    return nil
                }
                
                guard let wrapped: G = value
                else
                {
                    return self.generate(context)
                }
                
                return self.mutate(wrapped, context)
            }
        )
    }
}
