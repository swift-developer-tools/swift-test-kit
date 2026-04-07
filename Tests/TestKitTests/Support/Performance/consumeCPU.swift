//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// Consumes CPU time by performing a deterministic amount of arithmetic.
///
/// Standard arithmetic loops may be elided by the optimizer when their
/// results are unused. This function is never inlined, and returns a value
/// derived from the work to prevent dead-code elimination of the loop body.
///
/// Use this to test performance tests that exceed the CPU time threshold,
/// or to distinguish CPU time from wall-clock time in tests where sleeping
/// would produce the wrong measurement.
///
/// - Parameter iterations: The number of arithmetic iterations to perform.
/// The defaul value is `10_000_000`.
/// - Returns: An accumulator value derived from the work.
@inline(never)
@discardableResult
internal func consumeCPU(
    iterations: Int = 10_000_000
) -> UInt64
{
    var accumulator: UInt64 = 0
    
    for iteration in 0..<iterations
    {
        /// Mix operations to discourage the optimizer from collapsing to
        /// a closed-form expression.
        accumulator     = accumulator &+ UInt64(iteration)
        accumulator     = accumulator ^ (accumulator &<< 13)
        accumulator     = accumulator ^ (accumulator &>> 7)
    }
    
    return accumulator
}
