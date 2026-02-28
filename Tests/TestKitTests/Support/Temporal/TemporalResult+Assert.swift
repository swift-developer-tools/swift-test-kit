//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTest



extension TemporalResult
{
    /// Asserts that the temporal result canceled.
    internal func assertCanceled()
    {
        guard case .canceled = self
        else
        {
            XCTFail("Expected .canceled, got \(self)")
            return
        }
    }
    
    
    
    /// Asserts that the temporal result passed.
    internal func assertPassed()
    {
        guard case .passed = self
        else
        {
            XCTFail("Expected .passed, got \(self)")
            return
        }
    }
    
    
    
    /// Asserts that given temporal result failed, and returns the associated
    /// values.
    /// - Returns: The associated values of the failed result, `nil` if the
    /// result did not fail.
    @discardableResult
    internal func assertFailed() -> FailedValues?
    {
        guard case let .failed(failures, elapsed, error) = self
        else
        {
            XCTFail("Expected .failed, got \(self)")
            return nil
        }
        
        return FailedValues(
            failures:   failures,
            elapsed:    elapsed,
            error:      error
        )
    }
}


/// The associated values of a failed ``TemporalResult``.
internal struct FailedValues
{
    let failures    : [InterceptedFailure]
    let elapsed     : Duration
    let error       : Error?
}
