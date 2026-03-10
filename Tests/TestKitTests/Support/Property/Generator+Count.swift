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



extension Generator where V : Collection
{
    /// Asserts that the generator produces collections with counts within
    /// the given range.
    /// - Parameter expected: The expected range of counts.
    internal func assertCount(
        in expected: ClosedRange<Int>
    )
    {
        for _ in 0..<1000
        {
            let value = generate(.random)
            
            XCTAssertGreaterThanOrEqual(value.count, expected.lowerBound)
            XCTAssertLessThanOrEqual(value.count, expected.upperBound)
        }
    }

}
