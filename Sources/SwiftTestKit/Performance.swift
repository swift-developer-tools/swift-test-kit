//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



/// Asserts that the given body meets performance thresholds across the
/// given number of runs.
///
/// The performance body is executed the given number of times. If any
/// assertion fails on any run, the test fails immediately.
///
/// - Important: Use only SwiftTestKit assertions inside performance bodies.
/// Native Swift Testing assertions are not intercepted.
///
/// - Parameters:
///   - runs: The number of measurement runs. The default value is `nil`,
///   which falls back to using global options.
///   - warmupRuns: The number of warmup runs before measurement begins.
///   The default value is `nil`, which falls back to using global options.
///   - timeLimit: The time limit.
///   - memoryLimit: The physical memory footprint limit, in bytes. The
///   default value is `nil`, which falls back to using global options.
///   - message: An optional description of a failure. The default value is
///   `nil`, which falls back to using global options.
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
///   - body: The performance body.
public func STKPerformance(
    runs        : @autoclosure () -> Int?       = nil,
    warmupRuns  : @autoclosure () -> Int?       = nil,
    timeLimit   : @autoclosure () -> Duration?  = nil,
    memoryLimit : @autoclosure () -> UInt64?    = nil,
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    options     : TestOptions?                  = nil,
    _ body      : () async throws -> Void
) async
{
    await TKPerformance(
        runs:           runs,
        warmupRuns:     warmupRuns,
        timeLimit:      timeLimit,
        memoryLimit:    memoryLimit,
        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options ?? TestConfiguration.global,
        body,
        context:        failureContext
    )
}
