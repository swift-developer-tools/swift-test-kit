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
    /// Asserts that the property check passed, and returns the associated
    /// values.
    /// - Returns: The associated values of the passed result, or `nil` if
    /// the result did not pass.
    @discardableResult
    internal func assertPassed() -> PassedPropertyValues?
    {
        guard case let .passed(iterations, seed, dist, tableDist) = self
        else
        {
            XCTFail("Expected .passed, got \(self)")
            return nil
        }
        
        return PassedPropertyValues(
            iterations:     iterations,
            seed:           seed,
            dist:           dist,
            tableDist:      tableDist
        )
    }
    
    
    
    /// Asserts that given property check failed, and returns the
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
    
    
    
    /// Asserts that the property check was exhausted, and returns the
    /// associated values.
    /// - Returns: The associated values, `nil` if the result was not exhausted.
    @discardableResult
    internal func assertExhausted() -> ExhaustedPropertyValues?
    {
        guard case let .exhausted(
            discarded, succeeded, ratio, seed, dist, tableDist
        ) = self
        else
        {
            XCTFail("Expected .exhausted, got \(self)")
            return nil
        }
        
        return ExhaustedPropertyValues(
            discarded:  discarded,
            succeeded:  succeeded,
            ratio:      ratio,
            seed:       seed,
            dist:       dist,
            tableDist:  tableDist
        )
    }
    
    
    
    /// Asserts that the property check had unmet coverage, and returns
    /// the associated values.
    /// - Returns: The associated values, `nil` if the result did not have
    /// unmet coverage.
    @discardableResult
    internal func assertCoverageNotMet() -> CoverageNotMetPropertyValues?
    {
        guard case let .coverageNotMet(
            unmet, iterations, seed, dist, tableDist
        ) = self
        else
        {
            XCTFail("Expected .coverageNotMet, got \(self)")
            return nil
        }
        
        return CoverageNotMetPropertyValues(
            unmet:          unmet,
            iterations:     iterations,
            seed:           seed,
            dist:           dist,
            tableDist:      tableDist
        )
    }
}



/// The associated values of a passed ``PropertyResult``.
internal struct PassedPropertyValues
{
    let iterations  : Int
    let seed        : UInt64
    let dist        : [String : Int]
    let tableDist   : [String : [String : Int]]
}



/// The associated values of an exhausted ``PropertyResult``.
internal struct ExhaustedPropertyValues
{
    let discarded   : Int
    let succeeded   : Int
    let ratio       : Int
    let seed        : UInt64
    let dist        : [String : Int]
    let tableDist   : [String : [String : Int]]
}



/// The associated values of a coverage-not-met ``PropertyResult``.
internal struct CoverageNotMetPropertyValues
{
    let unmet       : [UnmetCoverage]
    let iterations  : Int
    let seed        : UInt64
    let dist        : [String : Int]
    let tableDist   : [String : [String : Int]]
}
