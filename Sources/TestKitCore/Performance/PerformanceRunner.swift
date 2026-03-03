//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Darwin
import OSLog



/// Runs performance tests.
internal struct PerformanceRunner
{
    /// Runs a performance test.
    /// - Parameters:
    ///   - runs: The number of measurement runs.
    ///   - warmupRuns: The number of warmup runs before measurement begins.
    ///   - timeLimit: The time limit.
    ///   - memoryLimit: The physical memory footprint limit.
    ///   - body: The performance body.
    /// - Returns: The result of running the performance test.
    internal static func run(
        runs        : Int,
        warmupRuns  : Int,
        timeLimit   : Duration?,
        memoryLimit : ByteCount?,
        body        : () async throws -> Void
    ) async -> PerformanceResult
    {
        let timeEnabled     : Bool  = timeLimit != nil
        var memoryEnabled   : Bool  = memoryLimit != nil
        
        if
            memoryEnabled,
            physicalMemoryFootprint() == nil
        {
            memoryEnabled = false
            
            logger.warning("Memory measurement unavailable")
        }
        
        guard
            timeEnabled
            || memoryEnabled
        else
        {
            logger.warning(
                "Test passed vacuously - No measurements are enabled"
            )
            
            return .noMetrics
        }
        
        
        
        let interceptor = PerformanceInterceptor()
        
        for warmupRun in 0..<warmupRuns
        {
            guard !Task.isCancelled
            else
            {
                return .canceled
            }
            
            interceptor.reset()
            
            var thrownError: Error? = nil
            
            await FailureInterceptor.$current.withValue(interceptor)
            {
                do
                {
                    try await body()
                }
                catch
                {
                    thrownError = error
                }
            }
            
            if
                interceptor.didFail
                || thrownError != nil
            {
                return .failed(
                    failures:   interceptor.failures,
                    run:        warmupRun + 1,
                    warmup:     true,
                    error:      thrownError
                )
            }
        }
        
        
        
        
        var timeMeasurements    : [Duration]    = []
        var memoryMeasurements  : [ByteCount]   = []
        
        for measurementRun in 0..<runs
        {
            guard !Task.isCancelled
            else
            {
                return .canceled
            }
            
            interceptor.reset()
            
            /// Measure the memory footprint before starting the clock, and
            /// then again after stopping the clock, so any memory measurement
            /// overhead is not included in the time measurement.
            let preMemory: ByteCount? = memoryEnabled
                ? physicalMemoryFootprint()
                : nil
            
            let start       : ContinuousClock.Instant   = .now
            var thrownError : Error?                    = nil
            
            await FailureInterceptor.$current.withValue(interceptor)
            {
                do
                {
                    try await body()
                }
                catch
                {
                    thrownError = error
                }
            }
            
            let elapsed: Duration = start.elapsed
            
            let postMemory: ByteCount? = memoryEnabled
                ? physicalMemoryFootprint()
                : nil
            
            if
                interceptor.didFail
                || thrownError != nil
            {
                return .failed(
                    failures:   interceptor.failures,
                    run:        measurementRun + 1,
                    warmup:     false,
                    error:      thrownError
                )
            }
            
            if timeEnabled
            {
                timeMeasurements.append(elapsed)
            }
            
            if
                memoryEnabled,
                let preMemory,
                let postMemory
            {
                /// Prefer zero to an underflow if the footprint decreases
                /// between pre- and post-clock-start.
                let difference: UInt64
                    = postMemory.rawValue > preMemory.rawValue
                        ? postMemory.rawValue - preMemory.rawValue
                        : 0
                
                memoryMeasurements.append(.bytes(difference))
            }
        }
        
        
        
        let measurements = PerformanceMeasurements(
            runs:         runs,
            time:         timeEnabled ? timeMeasurements : nil,
            medianTime:   timeEnabled ? median(of: timeMeasurements) : nil,
            timeLimit:    timeLimit,
            memory:       memoryEnabled ? memoryMeasurements : nil,
            medianMemory: memoryEnabled ? median(of: memoryMeasurements) : nil,
            memoryLimit:  memoryLimit
        )
        
        return .completed(measurements: measurements)
    }
    
    
    
    // MARK: - Support
    
    private static let logger = Logger(
        subsystem:  "swift-test-kit",
        category:   "PerformanceRunner"
    )
    
    
    
    /// Gets the physical memory footprint of the process.
    /// - Returns: The physical memory footprint of the process.
    private static func physicalMemoryFootprint() -> ByteCount?
    {
        var info = task_vm_info_data_t()
        
        /// Buffer capacity in 4-byte (`integer_t`) units.
        var count: UInt32 = mach_msg_type_number_t(
            MemoryLayout<task_vm_info_data_t>.size
        ) / 4
        
        let result: Int32 = withUnsafeMutablePointer(to: &info)
        {
            guard count <= Int.max
            else
            {
                return KERN_FAILURE
            }
            
            return $0.withMemoryRebound(
                to:         integer_t.self,
                capacity:   Int(count)
            )
            {
                return task_info(
                    mach_task_self_,
                    task_flavor_t(TASK_VM_INFO),
                    $0,
                    &count
                )
            }
        }
        
        guard result == KERN_SUCCESS
        else
        {
            return nil
        }
        
        return .bytes(info.phys_footprint)
    }
    
    
    
    /// Computes the median of the given durations.
    ///
    /// If the given array has an even number of elements, the lower-middle
    /// value is used.
    ///
    /// - Parameter values: The durations.
    /// - Returns: The median of the given durations, or `nil` if the array
    /// is empty.
    private static func median(
        of values: [Duration]
    ) -> Duration?
    {
        guard !values.isEmpty
        else
        {
            return nil
        }
        
        let sorted: [Duration] = values.sorted()
        
        return sorted[(sorted.count - 1) / 2]
    }
    
    
    
    /// Computes the median of the given byte counts.
    ///
    /// If the given array has an even number of elements, the lower-middle
    /// value is used.
    ///
    /// - Parameter values: The byte counts.
    /// - Returns: The median of the given values, or `nil` if the array
    /// is empty.
    private static func median(
        of values: [ByteCount]
    ) -> ByteCount?
    {
        guard !values.isEmpty
        else
        {
            return nil
        }
        
        let sorted: [ByteCount] = values.sorted()
        
        return sorted[(sorted.count - 1) / 2]
    }
}
