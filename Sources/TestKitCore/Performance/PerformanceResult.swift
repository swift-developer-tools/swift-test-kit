//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

// MARK: - PerformanceResult

/// The result of a performance test.
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
    
    /// The performance test failed.
    /// - Parameters:
    ///   - failures: The intercepted failures.
    ///   - run: The 1-indexed run during which the failure occurred.
    ///   - warmup: Whether the failure occurred during a warmup run.
    ///   - error: The thrown error.
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
    
    /// The per-run wall-clock time measurements.
    internal let wallTime       : [Duration]?
    
    /// The median wall-clock time.
    internal let medianWallTime : Duration?
    
    /// The wall-clock time limit.
    internal let wallTimeLimit  : Duration?
    
    /// The per-run memory measurements.
    internal let memory         : [ByteCount]?
    
    /// The median memory usage difference.
    internal let medianMemory   : ByteCount?
    
    /// The physical memory footprint limit.
    internal let memoryLimit    : ByteCount?
    
    
    
    /// Whether the wall-clock time limit was exceeded.
    internal var wallTimeLimitExceeded: Bool
    {
        guard
            let medianWallTime,
            let wallTimeLimit
        else
        {
            return false
        }
        
        return medianWallTime > wallTimeLimit
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
        return !wallTimeLimitExceeded
            && !memoryLimitExceeded
    }
}
