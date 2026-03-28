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



extension Generator where G : Collection
{
    /// Asserts that the generator produces collections with counts within
    /// the given range.
    /// - Parameters:
    ///   - expected: The expected range of counts.
    ///   - size: The generation size to use. The default value is `nil`,
    ///   which falls back to using random sizes.
    internal func assertCount(
        in expected : ClosedRange<Int>,
        size        : Int?              = nil
    )
    {
        for _ in 0..<1000
        {
            let value: G = size == nil
                ? generate(.random)
                : generate(.randomSeed(size: size!))
            
            XCTAssertGreaterThanOrEqual(value.count, expected.lowerBound)
            XCTAssertLessThanOrEqual(value.count, expected.upperBound)
        }
    }
}
