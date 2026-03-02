//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - PerformanceResult

/// The result of running a performance test.
internal enum PerformanceResult: Sendable
{
    /// No metrics were enabled.
    case noMetrics
    
    /// The enclosing task was canceled.
    case canceled
    
    /// All runs completed.
    /// - Parameter measurements: Performance measurements.
    case completed(
        measurements: PerformanceMeasurements
    )
    
    /// The performance test failed due to an assertion failure.
    /// - Parameters:
    ///   - failures: The intercepted failures.
    ///   - run: The 1-indexed run during which the failure occurred.
    ///   - warmup: Whether the failure occurred during a warmup run.
    ///   - error: The error thrown by the assertion.
    case failed(
        failures    : [InterceptedFailure],
        run         : Int,
        warmup      : Bool,
        error       : Error?
    )
}



// MARK: - PerformanceMeasurements

/// Measurements from a performance test.
internal struct PerformanceMeasurements: Equatable, Sendable
{
    /// The number of measurement runs.
    internal let runs           : Int
    
    /// The per-run time measurements.
    internal let time           : [Duration]?
    
    /// The median time.
    internal let medianTime     : Duration?
    
    /// The time limit.
    internal let timeLimit      : Duration?
    
    /// The per-run memory measurements, in bytes.
    internal let memory         : [UInt64]?
    
    /// The median memory usage difference, in bytes.
    internal let medianMemory   : UInt64?
    
    /// The physical memory footprint limit, in bytes.
    internal let memoryLimit    : UInt64?
    
    
    
    /// Whether the time limit was exceeded.
    internal var timeLimitExceeded: Bool
    {
        guard
            let medianTime,
            let timeLimit
        else
        {
            return false
        }
        
        return medianTime > timeLimit
    }
    
    
    
    /// Whether the memory limit was exceeded.
    internal var memoryLimitExceeded: Bool
    {
        guard
            let medianMemory,
            let memoryLimit
        else
        {
            return false
        }
        
        return medianMemory > memoryLimit
    }
    
    
    
    /// Whether all thresholds were met.
    internal var success: Bool
    {
        return !timeLimitExceeded
            && !memoryLimitExceeded
    }
}
