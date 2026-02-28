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

/// These functions are mirrors wrapping the actual internal functions,
/// allowing tests to benefit from autoclosures and default parameters.
/// The XCTestKit failure context is used since tests are run with XCTest.



internal func TKAlways(
    timeout     : Duration?                     = nil,
    interval    : Duration?                     = nil,
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    options     : TestOptions                   = .init(),
    context     : FailureContext                = XCTestKit.failureContext,
    _ body      : () async throws -> Void
) async
{
    await TestKitCore.TKAlways(
        timeout:    timeout,
        interval:   interval,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        body,
        context:    context
    )
}



internal func TKEventually(
    timeout     : Duration?                     = nil,
    interval    : Duration?                     = nil,
    _ message   : @autoclosure () -> String     = "",
    fileID      : StaticString                  = #fileID,
    file        : StaticString                  = #filePath,
    line        : UInt                          = #line,
    column      : UInt                          = #column,
    options     : TestOptions                   = .init(),
    context     : FailureContext                = XCTestKit.failureContext,
    _ body      : () async throws -> Void,
) async
{
    await TestKitCore.TKEventually(
        timeout:    timeout,
        interval:   interval,
        message,
        fileID:     fileID,
        file:       file,
        line:       line,
        column:     column,
        options:    options,
        body,
        context:    context
    )
}
