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



extension PropertyResult
{
    /// Asserts that the property check result passed, and returns the
    /// associated values.
    /// - Returns: The associated values of the passed result, or `nil` if
    /// the result did not pass.
    @discardableResult
    internal func assertPassed() -> PassedValues?
    {
        guard case let .passed(iterations, seed, dist, tableDist) = self
        else
        {
            XCTFail("Expected .passed, got \(self)")
            return nil
        }
        
        return PassedValues(
            iterations:     iterations,
            seed:           seed,
            dist:           dist,
            tableDist:      tableDist
        )
    }
    
    
    
    /// Asserts that given property check result failed, and returns the
    /// counterexample.
    /// - Returns: The counterexample of the failed result, `nil` if the
    /// result did not fail.
    @discardableResult
    internal func assertFailed() -> Counterexample<T>?
    {
        guard case let .failed(counterexample, _, _) = self
        else
        {
            XCTFail("Expected .failed, got \(self)")
            return nil
        }
        
        return counterexample
    }
    
    
    
    /// Asserts that the property check result was exhausted, and returns the
    /// associated values.
    /// - Returns: The associated values, `nil` if the result was not exhausted.
    @discardableResult
    internal func assertExhausted() -> ExhaustedValues?
    {
        guard case let .exhausted(
            discarded, succeeded, ratio, seed, dist, tableDist
        ) = self
        else
        {
            XCTFail("Expected .exhausted, got \(self)")
            return nil
        }
        
        return ExhaustedValues(
            discarded:  discarded,
            succeeded:  succeeded,
            ratio:      ratio,
            seed:       seed,
            dist:       dist,
            tableDist:  tableDist
        )
    }
    
    
    
    /// Asserts that the property check result has unmet coverage, and returns
    /// the associated values.
    /// - Returns: The associated values, `nil` if the result did not have
    /// unmet coverage.
    @discardableResult
    internal func assertCoverageNotMet() -> CoverageNotMetValues?
    {
        guard case let .coverageNotMet(
            unmet, iterations, seed, dist, tableDist
        ) = self
        else
        {
            XCTFail("Expected .coverageNotMet, got \(self)")
            return nil
        }
        
        return CoverageNotMetValues(
            unmet:          unmet,
            iterations:     iterations,
            seed:           seed,
            dist:           dist,
            tableDist:      tableDist
        )
    }
}



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
