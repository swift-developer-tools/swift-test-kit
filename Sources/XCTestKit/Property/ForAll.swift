//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



/// Asserts that the given property holds for all generated values.
///
/// - Important: Use only XCTestKit assertions inside property bodies.
/// Native XCTest assertions are not intercepted.
///
/// - Parameters:
///   - examples: The pinned values to test first. These values are not shrunk.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - property: The property to evaluate.
@Reasync
public func XCTKForAll<each T>(
    examples    : @autoclosure () -> [(repeat each T)]  = [],
    message     : @autoclosure () -> String             = "",
    fileID      : StaticString                          = #fileID,
    file        : StaticString                          = #filePath,
    line        : UInt                                  = #line,
    column      : UInt                                  = #column,
    options     : TestOptions?                          = nil,
    _ property  : (repeat each T) async throws -> Void
) async where repeat each T : Arbitrary
{
    await TKForAll(
        examples:   examples,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.global,
        property,
        context:    failureContext
    )
}



/// Asserts that the given property holds for all values produced by the
/// given generators.
///
/// Use a generator when ``Arbitrary`` conformance of a specific type does
/// not produce the necessary distribution of values. For example, a
/// generator may be used to test only positive integers, or only non-empty
/// arrays.
///
/// - Important: Use only XCTestKit assertions inside property bodies.
/// Native XCTest assertions are not intercepted.
///
/// - Parameters:
///   - generators: The generators to use to produce values.
///   - examples: The pinned values to test first. These values are not shrunk.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - property: The property to evaluate.
@Reasync
public func XCTKForAll<each T>(
    using generators    : repeat Generator<each T>,
    examples            : @autoclosure () -> [(repeat each T)]  = [],
    message             : @autoclosure () -> String             = "",
    fileID              : StaticString                          = #fileID,
    file                : StaticString                          = #filePath,
    line                : UInt                                  = #line,
    column              : UInt                                  = #column,
    options             : TestOptions?                          = nil,
    _ property          : (repeat each T) async throws -> Void
) async
{
    await TKForAll(
        using:      repeat each generators,
        examples:   examples,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.global,
        property,
        context:    failureContext
    )
}



/// Asserts that the given property holds for all generated values that satisfy
/// the given precondition.
///
/// Values that do not satisfy the precondition are discarded. If too many
/// values are discarded relative to the max discard ratio, the test fails
/// with an exhaustion error.
///
/// - Important: Preconditions that reject most values waste iterations and
/// can lead to exhaustion. Prefer constructing valid values using a custom
/// ``Generator`` rather than discarding invalid values with a precondition.
///
/// - Important: Use only XCTestKit assertions inside property bodies.
/// Native XCTest assertions are not intercepted.
///
/// - Parameters:
///   - precondition: The condition which generated values must satisfy.
///   - examples: The pinned values to test first. These values are not shrunk.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - property: The property to evaluate.
@Reasync
public func XCTKForAll<each T>(
    where precondition  : @escaping (repeat each T) -> Bool,
    examples            : @autoclosure () -> [(repeat each T)]  = [],
    message             : @autoclosure () -> String             = "",
    fileID              : StaticString                          = #fileID,
    file                : StaticString                          = #filePath,
    line                : UInt                                  = #line,
    column              : UInt                                  = #column,
    options             : TestOptions?                          = nil,
    _ property          : (repeat each T) async throws -> Void
) async where repeat each T : Arbitrary
{
    await TKForAll(
        where:      precondition,
        examples:   examples,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.global,
        property,
        context:    failureContext
    )
}



/// Asserts that the given property holds for all values produced by the given
/// generators that satisfy the given precondition.
///
/// Values that do not satisfy the precondition are discarded. If too many
/// values are discarded relative to the max discard ratio, the test fails
/// with an exhaustion error.
///
/// - Important: Preconditions that reject most values waste iterations and
/// can lead to exhaustion. Prefer constructing valid values using
/// generator-level filtering rather than discarding invalid values with a
/// precondition.
///
/// - Important: Use only XCTestKit assertions inside property bodies.
/// Native XCTest assertions are not intercepted.
///
/// - Parameters:
///   - generators: The generators to use to produce values.
///   - precondition: The condition which generated values must satisfy.
///   - examples: The pinned values to test first. These values are not shrunk.
///   - message: An optional description of a failure.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to using global options.
///   - property: The property to evaluate.
@Reasync
public func XCTKForAll<each T>(
    using generators    : repeat Generator<each T>,
    where precondition  : @escaping (repeat each T) -> Bool,
    examples            : @autoclosure () -> [(repeat each T)]  = [],
    message             : @autoclosure () -> String             = "",
    fileID              : StaticString                          = #fileID,
    file                : StaticString                          = #filePath,
    line                : UInt                                  = #line,
    column              : UInt                                  = #column,
    options             : TestOptions?                          = nil,
    _ property          : (repeat each T) async throws -> Void
) async
{
    await TKForAll(
        using:      repeat each generators,
        where:      precondition,
        examples:   examples,
        message:    message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.global,
        property,
        context:    failureContext
    )
}
