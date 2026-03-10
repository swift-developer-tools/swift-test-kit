//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



/// Records the given target value for guided generation.
///
/// Use this inside a property body to enable targeted property-based testing.
/// The target value is maximized across iterations, guiding generation toward
/// values that produce higher target values.
///
/// If this function is called multiple times within a single iteration, the
/// last target value is used.
///
/// - Note: This function has no effect outside a property body.
///
/// - Parameter target: The target value to maximize. Pass a negative value to
/// minimize a metric.
public func XCTKTarget(
    _ target: @autoclosure () -> Double
)
{
    TKTarget(target)
}



/// Discards the current iteration when the given condition is false.
///
/// Use this inside a property body to discard values based on conditions
/// that depend on derived values. Values that do not satisfy the condition
/// are counted against the maximum discard ratio.
///
/// - Important: Preconditions that reject most values waste iterations and
/// can lead to exhaustion. Prefer constructing valid values using a custom
/// ``Generator`` rather than discarding invalid values with a precondition.
///
/// - Note: This function has no effect outside a property body.
///
/// - Parameter condition: The condition to evaluate.
/// - Throws: An error if the given condition is false.
public func XCTKAssume(
    _ condition: @autoclosure () -> Bool
) throws
{
    try TKAssume(condition)
}



/// Tags the current iteration with the given label when the given condition
/// is true.
///
/// An iteration can receive multiple labels. Calling this function multiple
/// times with the same label within a single iteration is idempotent.
///
/// - Note: This function has no effect outside a property body.
///
/// - Parameters:
///   - label: The label to apply.
///   - condition: The condition to evaluate.
public func XCTKClassify(
    _       label       : String,
    when    condition   : @autoclosure () -> Bool
)
{
    TKClassify(
        label,
        when: condition
    )
}



/// Tags the current iteration with the given label when the given condition
/// is true, and registers a minimum coverage percentage for that label.
///
/// If the given percentage is not met after all iterations, the test fails.
///
/// If the same label is covered multiple times with different thresholds,
/// the maximum threshold is used.
///
/// - Note: This function has no effect outside a property body.
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
    TKCover(
        percentage,
        label,
        when: condition
    )
}



/// Tags the current iteration with the given label.
///
/// - Note: This function has no effect outside a property body.
///
/// - Parameter label: The label to apply.
public func XCTKLabel(
    _ label: String
)
{
    TKLabel(label)
}



/// Tags the current iteration with the string representation of the given
/// value.
///
/// - Note: This function has no effect outside a property body.
///
/// - Parameter value: The value whose string representation to apply as
/// a label.
public func XCTKCollect<T>(
    _ value: T
)
{
    TKCollect(value)
}



/// Tags the current iteration with the given label in the specified table.
///
/// An iteration can receive multiple labels. Calling this function multiple
/// times with the same table and label within a single iteration is idempotent.
///
/// - Note: This function has no effect outside a property body.
///
/// - Parameters:
///   - table: The table to update.
///   - label: The label to apply.
public func XCTKTabulate(
    _   table   : String,
    _   label   : String
)
{
    TKTabulate(
        table,
        label
    )
}



/// Registers minimum coverage percentages for the given labels in the
/// specified table.
///
/// If the specified percentage for a label is not met after all iterations,
/// the test fails.
///
/// If the same label is covered multiple times with different thresholds,
/// the maximum threshold is used.
///
/// - Note: This function has no effect outside a property body.
///
/// - Parameters:
///   - table: The table to update.
///   - requirements: The minimum coverage requirements. Each pair contains a
///   percentage and a label. The percentage represents the minimum percentage
///   of iterations that must be tagged with that label. Percentages are
///   clamped to the range `0.0...100.0`.
public func XCTKCoverTable(
    _   table           : String,
    _   requirements    : (Double, String)...
)
{
    TKCoverTable(
        table,
        requirements
    )
}
