//===----------------------------------------------------------------------===//
//
// This source file is part of the XCTestKit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
import XCTestKitCore
@testable import XCTestKit



/// The base class for testing with XCTest.
///
/// This resets the global XCTestKit configuration between test cases and
/// disables continuation after failure.
internal class XCTestKitCase: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        
        XCTKConfig.global       = TKOptions()
        continueAfterFailure    = false
    }
    
    
    
    override func tearDown()
    {
        XCTKConfig.global = TKOptions()
        
        super.tearDown()
    }
    
    
    
    /// Calls the given closure after enabling `continueAfterFailure` for the
    ///  duration of the call.
    ///
    /// `continueAfterFailure` is enabled for the duration of the call, after
    /// which it is reset to its original value.
    ///
    /// - Parameter body: The closure to call.
    /// - Returns: The return value of the given closure.
    func withContinuationAfterFailure<T>(
        _ body: () throws -> T
    ) rethrows -> T
    {
        let originalContinueAfterFailure: Bool = continueAfterFailure
        
        continueAfterFailure = true
        
        defer
        {
            continueAfterFailure = originalContinueAfterFailure
        }
        
        return try body()
    }
    
    
    
    /// Expects exactly one test failure in the given closure, and captures the
    /// failure message.
    ///
    /// Only the first failure is expected. Any subsequent failures will fail
    /// the test.
    ///
    /// - Parameter body: The closure to call.
    /// - Returns: The failure message of the given closure.
    @discardableResult
    func withOneExpectedFailure(
        _ body: () throws -> Void
    ) -> String?
    {
        return withContinuationAfterFailure
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
                    /// This ensures that the only expected failure is that of
                    /// the underlying assertion, which prevents tests from
                    /// incorrectly passing when written incorrectly.
                    ///
                    /// For example, if the `body` closure does not fail as
                    /// expected, the output-validating assertion outside the
                    /// closure would fail. Without this guard, that failure
                    /// would be incorrectly marked as expected.
                    return false
                }
                
                var message : String    = $0.compactDescription
                let prefix  : String    = "failed - "
                
                if message.hasPrefix(prefix)
                {
                    /// Remove XCTest's prefix so only XCTestKit's output is
                    /// tested.
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
    }
}
