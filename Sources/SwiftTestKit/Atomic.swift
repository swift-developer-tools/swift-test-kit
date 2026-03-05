//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



/// Asserts that all assertions in the given body pass.
///
/// If any assertion fails, the test fails immediately.
///
/// - Important: Use only SwiftTestKit assertions inside atomic bodies.
/// Native Swift Testing assertions are not intercepted.
///
/// - Parameters:
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
///   - body: The atomic body.
@Reasync
package func STKAtomic(
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    options     : TestOptions?                  = nil,
    _ body      : () async throws -> Void
) async
{
    await TKAtomic(
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
