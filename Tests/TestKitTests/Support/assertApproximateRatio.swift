//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest



/// Asserts that the given actual value is within the specified number of
/// standard deviations as the given expected value.
/// - Parameters:
///   - actual: The actual proportion.
///   - expected: The expected proportion.
///   - n: The sample size.
///   - sigmas: The number of standard deviations to tolerate. The default
///   value is `4`.
internal func assertApproximateRatio(
    _ actual    : Double,
    _ expected  : Double,
    n           : Int,
    sigmas      : Double    = 4
)
{
    let stddev: Double = (expected * (1 - expected) / Double(n)).squareRoot()
    
    let tolerance: Double = sigmas * stddev
    
    XCTAssertGreaterThan(actual, expected - tolerance)
    XCTAssertLessThan(actual, expected + tolerance)
}
