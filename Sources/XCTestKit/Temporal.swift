//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



/// Asserts that the given body passes continuously for the given duration.
///
/// The temporal body is polled at the given interval. If any assertion fails
/// on any poll, the test fails immediately.
///
/// XCTestKit assertions used inside a temporal body are automatically
/// intercepted rather than reported directly to XCTest.
///
/// - Important: Native XCTest assertions are not intercepted by XCTestKit.
/// If a native XCTest assertion fails inside a temporal body, it bypasses
/// polling and produces an immediate test failure. Use only XCTestKit
/// assertions inside temporal bodies.
///
/// - Parameters:
///   - timeout: The timeout duration. The default value is `nil`, which falls
///   back to using global options.
///   - interval: The polling interval. The default value is `nil`, which falls
///   back to using global options.
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
///   - body: The temporal body.
public func XCTKAlways(
    timeout     : @autoclosure () -> Duration?  = nil,
    interval    : @autoclosure () -> Duration?  = nil,
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    options     : TestOptions?                  = nil,
    _ body      : () async throws -> Void
) async
{
    await TKAlways(
        timeout:    timeout,
        interval:   interval,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.global,
        body,
        context:    failureContext
    )
}



/// Asserts that the given body passes within the given duration.
///
/// The temporal body is polled at the given interval until all assertions
/// pass in a single execution, or the timeout is reached.
///
/// XCTestKit assertions used inside a temporal body are automatically
/// intercepted rather than reported directly to XCTest.
///
/// - Important: Native XCTest assertions are not intercepted by XCTestKit.
/// If a native XCTest assertion fails inside a temporal body, it bypasses
/// polling and produces an immediate test failure. Use only XCTestKit
/// assertions inside temporal bodies.
///
/// - Parameters:
///   - timeout: The timeout duration. The default value is `nil`, which falls
///   back to using global options.
///   - interval: The polling interval. The default value is `nil`, which falls
///   back to using global options.
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
///   - body: The temporal body.
public func XCTKEventually(
    timeout     : @autoclosure () -> Duration?  = nil,
    interval    : @autoclosure () -> Duration?  = nil,
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    options     : TestOptions?                  = nil,
    _ body      : () async throws -> Void
) async
{
    await TKEventually(
        timeout:    timeout,
        interval:   interval,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options ?? TestConfiguration.global,
        body,
        context:    failureContext
    )
}
