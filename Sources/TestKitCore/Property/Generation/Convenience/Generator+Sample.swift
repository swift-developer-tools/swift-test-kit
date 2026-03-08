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
    /// Generates samples values.
    ///
    /// Use this to verify that a custom generator produces the expected
    /// distribution of values.
    ///
    /// - Parameters:
    ///   - count: The number of values to generate. The default value is `10`.
    ///   - seed: The seed used to initialize the random number generator.
    ///   The default value is `nil`, which generates a random seed from the
    ///   system random number generator.
    ///   - maxSize: The maximum generation size. The default value is `100`.
    /// - Returns: The sample values.
    public func sample(
        count   : Int       = 10,
        seed    : UInt64?   = nil,
        maxSize : Int       = 100
    ) -> [V]
    {
        precondition(
            count >= 0,
            "count must not be negative"
        )
        
        precondition(
            maxSize >= 0,
            "maxSize must not be negative"
        )
        
        let seed: UInt64 = seed ?? .random(in: UInt64.min...UInt64.max)
        
        let context = GenerationContext(seed: seed)
        
        return (0..<count).map
        {
            context.size = count > 0
                ? $0 * maxSize / count
                : 0
            
            return generate(context)
        }
    }
}
