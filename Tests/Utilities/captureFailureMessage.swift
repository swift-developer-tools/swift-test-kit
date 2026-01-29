//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest



/// Captures the failure message of the given closure.
/// - Parameter body: The closure to call.
/// - Returns: The failure message of the given closure.
internal func captureFailureMessage(
    _ body: () -> Void
) -> String?
{
    var captured            : String?   = nil
    var isInsideBodyClosure : Bool      = false
    
    XCTExpectFailure
    {
        guard
            isInsideBodyClosure,
            captured == nil
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
        
        captured = message
        
        return true
    }
    
    isInsideBodyClosure = true
    body()
    isInsideBodyClosure = false
    
    return captured
}
