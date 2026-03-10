//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKit
import XCTest



/// Validates that the given type's ``Arbitrary`` conformance is deterministic.
/// - Parameter type: The type to evaluate.
internal func assertArbitraryDeterminism<T>(
    of type: T.Type
) where T : Arbitrary & Equatable
{
    for _ in 0..<1000
    {
        let (context1, context2) = GenerationContext.sameRandomContexts
        
        let value1  = T.arbitrary(using: context1)
        let value2  = T.arbitrary(using: context2)
        
        if value1.isNaN
        {
            XCTAssertTrue(value2.isNaN)
        }
        else
        {
            XCTAssertEqual(value1, value2)
        }
        
        let (context3, context4) = GenerationContext.sameRandomContexts
        
        /// Mutate the same value twice, with different contexts. Using the
        /// same value is necessary for unordered collections like dictionaries
        /// and sets, which may have the same elements (and therefore pass the
        /// equality assertion above), but in a different order. Mutation of
        /// these types converts the keys of a dictionary and the elements of
        /// a set to arrays, at which point the order matters.
        let mutated1    : T     = value1.mutate(using: context3)
        let mutated2    : T     = value1.mutate(using: context4)
        
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
