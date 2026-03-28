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



extension PerformanceResult
{
    /// Asserts that the performance test had no metrics to test.
    internal func assertNoMetrics()
    {
        guard case .noMetrics = self
        else
        {
            XCTFail("Expected .noMetrics, got \(self)")
            return
        }
    }
    
    
    
    /// Asserts that the performance test was canceled.
    internal func assertCanceled()
    {
        guard case .canceled = self
        else
        {
            XCTFail("Expected .canceled, got \(self)")
            return
        }
    }
    
    
    
    /// Asserts that the performance test was completed, and returns the
    /// performance measurements.
    /// - Returns: The performance measurements.
    @discardableResult
    internal func assertCompleted() -> PerformanceMeasurements?
    {
        guard case let .completed(measurements) = self
        else
        {
            XCTFail("Expected .completed, got \(self)")
            return nil
        }
        
        return measurements
    }
    
    
    
    /// Asserts that given performance result failed, and returns the
    /// associated values.
    /// - Returns: The associated values of the failed result, `nil` if the
    /// result did not fail.
    @discardableResult
    internal func assertFailed() -> FailedPerformanceValues?
    {
        guard case let .failed(failures, run, warmup, error) = self
        else
        {
            XCTFail("Expected .failed, got \(self)")
            return nil
        }
        
        return FailedPerformanceValues(
            failures:   failures,
            run:        run,
            warmup:     warmup,
            error:      error
        )
    }
}



/// The associated values of a failed ``PerformanceResult``.
internal struct FailedPerformanceValues
{
    let failures    : [InterceptedFailure]
    let run         : Int
    let warmup      : Bool
    let error       : Error?
}
