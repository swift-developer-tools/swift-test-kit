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
    }
}
