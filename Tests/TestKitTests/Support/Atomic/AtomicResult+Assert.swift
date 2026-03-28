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



extension AtomicResult
{
    /// Asserts that the temporal test passed.
    internal func assertPassed()
    {
        guard case .passed = self
        else
        {
            XCTFail("Expected .passed, got \(self)")
            return
        }
    }
    
    
    
    /// Asserts that given temporal test failed, and returns the associated
    /// values.
    /// - Returns: The associated values of the failed result, `nil` if the
    /// result did not fail.
    @discardableResult
    internal func assertFailed() -> FailedAtomicValues?
    {
        guard case let .failed(failures, error) = self
        else
        {
            XCTFail("Expected .failed, got \(self)")
            return nil
        }
        
        return FailedAtomicValues(
            failures:   failures,
            error:      error
        )
    }
}



/// The associated values of a failed ``AtomicResult``.
internal struct FailedAtomicValues
{
    let failures    : [InterceptedFailure]
    let error       : Error?
}
