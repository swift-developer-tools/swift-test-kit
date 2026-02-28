//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTestKit
import Synchronization
import XCTest



/// The base class for testing with XCTest.
///
/// This resets the global XCTestKit configuration between test cases and
/// disables continuation after failure.
internal class TestKitCase: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    
    
    /// Calls the given closure after enabling `continueAfterFailure` for the
    ///  duration of the call.
    ///
    /// `continueAfterFailure` is enabled for the duration of the call, after
    /// which it is reset to its original value.
    ///
    /// - Parameter body: The closure to call.
    /// - Returns: The return value of the given closure.
    @Reasync
    func withContinuationAfterFailure<T>(
        _ body: () async throws -> T
    ) async rethrows -> T
    {
        let originalContinueAfterFailure: Bool = continueAfterFailure
        
        continueAfterFailure = true
        
        defer
        {
            continueAfterFailure = originalContinueAfterFailure
        }
        
        return try await body()
    }
    
    
    
    /// Expects exactly one test failure in the given closure, and captures the
    /// failure message.
    ///
    /// Only the first failure is expected. Any subsequent failures will fail
    /// the test.
    ///
    /// - Parameter body: The closure to call.
    /// - Returns: The failure message of the given closure.
    @Reasync
    @discardableResult
    func withOneExpectedFailure(
        _ body: () async throws -> Void
    ) async -> String?
    {
        return await withContinuationAfterFailure
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
            try? await body()
            isInsideBodyClosure = false
            
            return capturedMessage
        }
    }
    
    
    
    /// Calls the given closure with an XCTestKit failure context, and captures
    /// the failure message.
    ///
    /// - Important: Only use this when testing the `eventually` temporal
    /// evaluator with expected failures. All other expected failures should
    /// use ``withOneExpectedFailure(_:)`` to fully test the framework failure
    /// path. See the mirrored test utility function for more information.
    ///
    /// - Parameter body: The closure to call.
    /// - Returns: The failure message of the given closure.
    @Reasync
    @discardableResult
    func withCapturedFailure(
        _ body: (FailureContext) async throws -> Void
    ) async -> String?
    {
        let captured = Mutex<String?>(nil)
        
        let context = FailureContext(framework: .xctk)
        {
            message, _, _, _, _ in
            
            captured.withLock { $0 = message }
        }
        
        try? await body(context)
        
        return captured.withLock { $0 }
    }
}
