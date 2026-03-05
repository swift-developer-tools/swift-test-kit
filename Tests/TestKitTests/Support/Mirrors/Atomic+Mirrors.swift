//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
@testable import XCTestKit



/// This function is a mirror wrapping the actual internal function,
/// allowing tests to benefit from autoclosures and default parameters.
/// The XCTestKit failure context is used since tests are run with XCTest.
@Reasync
internal func TKAtomic(
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    context     : FailureContext                = XCTestKit.failureContext,
    _ body      : () async throws -> Void
) async
{
    await TestKitCore.TKAtomic(
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        body,
        context:    context
    )
}
