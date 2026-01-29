//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest



/// Expects exactly one test failure in the given closure, and captures the
/// failure message.
///
/// Only the first failure is expected. Any subsequent failures will fail the
/// test.
///
/// - Parameter body: The closure to call.
/// - Returns: The failure message of the given closure.
@discardableResult
internal func withOneExpectedFailure(
    _ body: () throws -> Void
) -> String?
{
    var capturedMessage     : String?   = nil
    var isInsideBodyClosure : Bool      = false
    
    XCTExpectFailure
    {
        guard
            isInsideBodyClosure,
            capturedMessage == nil
        else
        {
            /// Only mark failures as expected when the failure occurs
            /// inside the `body` closure, and it is the first failure.
            ///
            /// This ensures that the only expected failure is that of the
            /// underlying assertion, which prevents tests from incorrectly
            /// passing when written incorrectly.
            ///
            /// For example, if the `body` closure does not fail as
            /// expected, the output-validating assertion outside the
            /// closure would fail. Without this guard, that failure would
            /// be incorrectly marked as expected.
            return false
        }
        
        var message : String    = $0.compactDescription
        let prefix  : String    = "failed - "
        
        if message.hasPrefix(prefix)
        {
            /// Remove XCTest's prefix so only XCTestKit's output is tested.
            message = String(message.dropFirst(prefix.count))
        }
        
        capturedMessage = message
        
        return true
    }
    
    isInsideBodyClosure = true
    try? body()
    isInsideBodyClosure = false
    
    return capturedMessage
}
