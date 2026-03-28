//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTest



extension Generator where G : Equatable
{
    /// Asserts that output of the generator is deterministic.
    /// - Parameter size: The generation size to use. The default value is
    /// `nil`, which falls back to using random sizes.
    internal func assertDeterministic(
        size: Int? = nil
    )
    {
        for _ in 0..<1000
        {
            let context1    : GenerationContext
            let context2    : GenerationContext
            let context3    : GenerationContext
            let context4    : GenerationContext
            
            if let size
            {
                let seed: UInt64 = GenerationContext.randomSeed
                
                context1    = GenerationContext(seed: seed, size: size)
                context2    = GenerationContext(seed: seed, size: size)
                context3    = GenerationContext(seed: seed, size: size)
                context4    = GenerationContext(seed: seed, size: size)
            }
            else
            {
                (context1, context2) = GenerationContext.sameRandomContexts
                (context3, context4) = GenerationContext.sameRandomContexts
            }
            
            let value1  : G     = self.generate(context1)
            let value2  : G     = self.generate(context2)
            
            if value1.isNaN
            {
                XCTAssertTrue(value2.isNaN)
            }
            else
            {
                XCTAssertEqual(value1, value2)
            }
            
            /// Mutate the same value to handle unordered collections.
            /// See comment in ``assertArbitraryDeterminism(of:)``.
            let mutated1    : G     = mutate(value1, context3)
            let mutated2    : G     = mutate(value1, context4)
            
            if mutated1.isNaN
            {
                XCTAssertTrue(mutated2.isNaN)
            }
            else
            {
                XCTAssertEqual(mutated1, mutated2)
            }
        }
    }
}
