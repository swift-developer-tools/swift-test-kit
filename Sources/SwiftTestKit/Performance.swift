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
/// The performance body is executed the given number of times. All assertions
/// are executed on each run, regardless of individual failures. If any
/// assertion fails during a run, measurement stops and all failures from that
/// run are reported together.
///
/// - Important: Use only SwiftTestKit assertions inside performance bodies.
/// Native Swift Testing assertions are not intercepted.
///
/// - Parameters:
///   - runs: The number of measurement runs. The default value is `nil`,
///   which falls back to the resolved options.
///   - warmupRuns: The number of warmup runs before measurement begins.
///   The default value is `nil`, which falls back to the resolved options.
///   - wallTimeLimit: The wall-clock time limit.
///   - memoryLimit: The physical memory footprint limit. The default value
///   is `nil`, which falls back to the resolved options.
///   - message: An optional description of a failure. The default value is
///   `nil`, which falls back to the resolved options.
///   - fileID: The ID of the file where the failure occurs. The default value
///   is the ID of the file of the test case in which this function was called.
///   - file: The file where the failure occurs. The default value is the
///   filename of the test case in which this function was called.
///   - line: The line where the failure occurs. The default value is the line
///   number where this function was called.
///   - column: The column where the failure occurs. The default value is the
///   column number where this function was called.
///   - options: The options for testing. The default value is `nil`, which
///   falls back to the resolved options.
///   - body: The performance body.
public func STKPerformance(
    runs            : @autoclosure () -> Int?           = nil,
    warmupRuns      : @autoclosure () -> Int?           = nil,
    wallTimeLimit   : @autoclosure () -> Duration?      = nil,
    memoryLimit     : @autoclosure () -> ByteCount?     = nil,
    _ message       : @autoclosure () -> String         = "",
    fileID          : StaticString                      = #fileID,
    file            : StaticString                      = #filePath,
    line            : UInt                              = #line,
    column          : UInt                              = #column,
    options         : TestOptions?                      = nil,
    _ body          : () async throws -> Void
) async
{
    await TKPerformance(
        runs:           runs,
        warmupRuns:     warmupRuns,
        wallTimeLimit:  wallTimeLimit,
        memoryLimit:    memoryLimit,
        message,
        fileID:         fileID,
        file:           file,
        line:           line,
        column:         column,
        options:        options ?? TestConfiguration.current,
        body,
        context:        failureContext
    )
}
