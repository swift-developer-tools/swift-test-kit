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
    ///   - wallTimeLimit: The wall-clock time limit.
    ///   - cpuTimeLimit: The CPU time limit.
    ///   - memoryLimit: The physical memory footprint limit.
    ///   - body: The performance body.
    /// - Returns: The result of the performance test.
    internal static func run(
        runs            : Int,
        warmupRuns      : Int,
        wallTimeLimit   : Duration?,
        cpuTimeLimit    : Duration?,
        memoryLimit     : ByteCount?,
        body            : () async throws -> Void
    ) async -> PerformanceResult
    {
        let wallTimeEnabled : Bool  = wallTimeLimit != nil
        var cpuTimeEnabled  : Bool  = cpuTimeLimit != nil
        var memoryEnabled   : Bool  = memoryLimit != nil
        
        if
            cpuTimeEnabled,
            cpuTime() == nil
        {
            cpuTimeEnabled = false
            
            logger.warning("CPU time measurement unavailable")
        }
        
        if
            memoryEnabled,
            physicalMemoryFootprint() == nil
        {
            memoryEnabled = false
            
            logger.warning("Memory measurement unavailable")
        }
        
        guard
            wallTimeEnabled
            || cpuTimeEnabled
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
        
        
        
        
        var wallTimeMeasurements    : [Duration]    = []
        var cpuTimeMeasurements     : [Duration]    = []
        var memoryMeasurements      : [ByteCount]   = []
        
        for measurementRun in 0..<runs
        {
            guard !Task.isCancelled
            else
            {
                return .canceled
            }
            
            interceptor.reset()
            
            /// Bracket the body in nesting order from outermost to innermost:
            /// memory, CPU time, wall-clock time. The wall-clock time is the
            /// tightest measurement, so it excludes the CPU time and memory
            /// measurement overhead. CPU time also excludes the memory
            /// measurement overhead.
            let preMemory: ByteCount? = memoryEnabled
                ? physicalMemoryFootprint()
                : nil
            
            let preCPU: Duration? = cpuTimeEnabled
                ? cpuTime()
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
            
            let postCPU: Duration? = cpuTimeEnabled
                ? cpuTime()
                : nil
            
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
            
            if wallTimeEnabled
            {
                wallTimeMeasurements.append(elapsed)
            }
            
            if
                cpuTimeEnabled,
                let preCPU,
                let postCPU
            {
                /// Prefer zero to an underflow if the clock time decreases
                /// between pre- and post-clock start.
                let difference: Duration = postCPU > preCPU
                    ? postCPU - preCPU
                    : .zero
                
                cpuTimeMeasurements.append(difference)
            }
            
            if
                memoryEnabled,
                let preMemory,
                let postMemory
            {
                /// Prefer zero to an underflow if the footprint decreases
                /// between pre- and post-clock start.
                let difference: UInt64
                    = postMemory.rawValue > preMemory.rawValue
                        ? postMemory.rawValue - preMemory.rawValue
                        : .zero
                
                memoryMeasurements.append(.bytes(difference))
            }
        }
        
        
        
        let measurements = PerformanceMeasurements(
            runs:           runs,
            wallTime:       wallTimeEnabled ? wallTimeMeasurements : nil,
            medianWallTime: wallTimeEnabled ? median(of: wallTimeMeasurements) : nil,
            wallTimeLimit:  wallTimeLimit,
            cpuTime:        cpuTimeEnabled ? cpuTimeMeasurements : nil,
            medianCPUTime:  cpuTimeEnabled ? median(of: cpuTimeMeasurements) : nil,
            cpuTimeLimit:   cpuTimeLimit,
            memory:         memoryEnabled ? memoryMeasurements : nil,
            medianMemory:   memoryEnabled ? median(of: memoryMeasurements) : nil,
            memoryLimit:    memoryLimit
        )
        
        return .completed(measurements: measurements)
    }
    
    
    
    // MARK: - Support
    
    private static let logger = Logger(
        subsystem:  "swift-test-kit",
        category:   "PerformanceRunner"
    )
    
    
    
    /// Gets the CPU time consumed by the process.
    /// - Returns: The CPU time consumed by the process.
    private static func cpuTime() -> Duration?
    {
        var spec = timespec()
        
        guard clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &spec) == 0
        else
        {
            return nil
        }
        
        return .seconds(spec.tv_sec) + .nanoseconds(spec.tv_nsec)
    }
    
    
    
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
    
    
    
    /// Computes the median of the given values.
    ///
    /// If the given array has an even number of elements, the lower-middle
    /// value is used.
    ///
    /// - Parameter values: The values.
    /// - Returns: The median of the given values, or `nil` if the array
    /// is empty.
    private static func median<T>(
        of values: [T]
    ) -> T? where T : Comparable
    {
        guard !values.isEmpty
        else
        {
            return nil
        }
        
        let sorted: [T] = values.sorted()
        
        return sorted[(sorted.count - 1) / 2]
    }
}
