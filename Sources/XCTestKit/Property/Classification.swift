//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import OSLog



private let logger = Logger(
    subsystem:  "swift-test-kit",
    category:   "Classification"
)



// MARK: - XCTKClassify

/// Tags the current iteration with the given label when the given condition
/// is true.
///
/// An iteration can receive multiple labels. Calling this function multiple
/// times with the same label within a single iteration is idempotent.
///
/// - Note: This function does nothing when called outside a property body.
///
/// - Parameters:
///   - label: The label to apply.
///   - condition: The condition to evaluate.
public func XCTKClassify(
    _       label       : String,
    when    condition   : @autoclosure () -> Bool
)
{
    guard let interceptor = PropertyInterceptor.current
    else
    {
        logger.warning("XCTKClassify called outside a property body (no-op)")
        return
    }
    
    if condition()
    {
        interceptor.recordLabel(label)
    }
}



// MARK: - XCTKCover

/// Tags the current iteration with the given label when the given condition
/// is true, and registers a minimum coverage percentage for that label.
///
/// If the given percentage is not met after all iterations, the test fails.
///
/// If the same label is covered multiple times with different thresholds,
/// the maximum threshold is used.
///
/// - Note: This function does nothing when called outside a property body.
///
/// - Parameters:
///   - percentage: The minimum percentage of iterations that must be tagged
///   with this label. This is clamped to the range `0.0...100.0`.
///   - label: The label to apply.
///   - condition: The condition to evaluate.
public func XCTKCover(
    _       percentage  : Double,
    _       label       : String,
    when    condition   : @autoclosure () -> Bool
)
{
    guard let interceptor = PropertyInterceptor.current
    else
    {
        logger.warning("XCTKCover called outside a property body (no-op)")
        return
    }
    
    interceptor.recordCoverageRequirement(
        percentage,
        for: label
    )
    
    if condition()
    {
        interceptor.recordLabel(label)
    }
}



// MARK: - XCTKLabel

/// Tags the current iteration with the given label.
///
/// - Note: This function does nothing when called outside a property body.
///
/// - Parameter label: The label to apply.
public func XCTKLabel(
    _ label: String
)
{
    guard let interceptor = PropertyInterceptor.current
    else
    {
        logger.warning("XCTKLabel called outside a property body (no-op)")
        return
    }
    
    interceptor.recordLabel(label)
}



// MARK: - XCTKCollect

/// Tags the current iteration with the string representation of the given
/// value.
///
/// - Note: This function does nothing when called outside a property body.
///
/// - Parameter value: The value whose string representation to apply as
/// a label.
public func XCTKCollect<T>(
    _ value: T
)
{
    XCTKLabel("\(value)")
}
