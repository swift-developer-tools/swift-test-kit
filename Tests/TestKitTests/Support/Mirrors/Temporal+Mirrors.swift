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
        context:    XCTestKit.failureContext
    )
}



/// This mirror accepts a ``FailureContext`` so it can be used with
/// ``TestKitCase/withCapturedFailure(_:)``. This is necessary when expecting
/// failures from the `eventually` temporal evaluator.
///
/// `XCTExpectFailure()` likely uses thread-local storage to track
/// active failure expectations. Since temporal tests poll repeatedly
/// using `Task.sleep(for:)`, the task likely resumes on a different
/// thread. At that point, the `XCTExpectFailure()` scope is no longer
/// active on that thread, so XCTest records it as an unmatched failure.
/// This is possibly related to the XCTest bug that requires
/// `continueAfterFailure = true` when testing in an async context.
///
/// Test instead with a custom failure context that does not cause an
/// assertion failure, but still allows capturing the failure message.
///
/// Other temporal tests do not have this problem:
/// - Always success: No failure emitted, nothing to intercept.
/// - Always failure: Fails on the first poll, before sleeping.
/// - Eventually success: No failure emitted, passes on the first poll.
/// - Eventually failure: Polls repeatedly between sleep cycles until timeout.
///
/// The assumption above is that when expecting a failure in the `always`
/// evaluator, the body is simply an assertion that immediately fails. Even
/// if this is done in the `eventually` evaluator, that evaluator is designed
/// to sleep and re-poll until timeout, meaning even simple test bodies cannot
/// be tested with a regular failure expectation.
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
