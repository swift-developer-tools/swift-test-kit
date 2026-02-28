//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore



extension StatefulResult
{
    /// Asserts that the property check result passed, and returns the
    /// associated values.
    /// - Returns: The associated values of the passed result, or `nil` if
    /// the result did not pass.
    @discardableResult
    internal func assertPassed() -> PassedValues?
    {
        return property.assertPassed()
    }
    
    
    
    /// Asserts that given property check result failed, and returns the
    /// counterexample.
    /// - Returns: The counterexample of the failed result, `nil` if the
    /// result did not fail.
    @discardableResult
    internal func assertFailed() -> Counterexample<[C]>?
    {
        return property.assertFailed()
    }
    
    
    
    /// Asserts that the property check result was exhausted, and returns the
    /// associated values.
    /// - Returns: The associated values, `nil` if the result was not exhausted.
    @discardableResult
    internal func assertExhausted() -> ExhaustedValues?
    {
        return property.assertExhausted()
    }
    
    
    
    /// Asserts that the property check result has unmet coverage, and returns
    /// the associated values.
    /// - Returns: The associated values, `nil` if the result did not have
    /// unmet coverage.
    @discardableResult
    internal func assertCoverageNotMet() -> CoverageNotMetValues?
    {
        return property.assertCoverageNotMet()
    }
}
