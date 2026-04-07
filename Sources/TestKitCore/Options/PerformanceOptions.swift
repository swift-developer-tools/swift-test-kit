//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

/// The options for performance testing.
public struct PerformanceOptions: Equatable, Sendable
{
    /// The number of measurement runs.
    ///
    /// The default value is `10`.
    public var runs             : Int
    
    /// The number of warmup runs before measurement begins.
    ///
    /// The default value is `1`.
    ///
    /// Warmup runs execute the body without recording measurements. Use this
    /// to prime caches and other system state to reduce noise in the
    /// measured runs.
    public var warmupRuns       : Int
    
    /// The wall-clock time limit.
    ///
    /// The default value is `nil` (wall-clock time measurement disabled).
    /// When non-`nil`, the test fails if the median wall-clock time across
    /// measurement runs exceeds this limit.
    ///
    /// Wall-clock time measures elapsed real time, including the time the
    /// process spends descheduled, blocked on I/O, or waiting on locks.
    public var wallTimeLimit    : Duration?
    
    /// The CPU time limit.
    ///
    /// The default value is `nil` (CPU time measurement disabled). When
    /// non-`nil`, the test fails if the median CPU time across measurement
    /// runs exceeds this limit.
    ///
    /// CPU time measures only the time during which the process was actually
    /// executing on a CPU core.
    ///
    /// - Note: CPU time is measured at process granularity, and is not scoped
    /// to the measured block. When tests run in parallel within a single
    /// process, the CPU time consumed by other concurrently-executing tests is
    /// included in the measurement. For reliable CPU time assertions, run
    /// tests serially or in isolation.
    ///
    /// - Note: CPU time is the incorrect measurement for I/O-bound or
    /// lock-contended code, since the time spent blocked does not advance the
    /// CPU clock. Use ``wallTimeLimit`` instead, or use both limits together.
    public var cpuTimeLimit     : Duration?
    
    /// The physical memory footprint limit.
    ///
    /// The default value is `nil` (memory measurement disabled). When
    /// non-`nil`, the test fails if the median memory usage difference
    /// across measurement runs exceeds this limit.
    ///
    /// - Note: This measures the physical memory footprint of the entire
    /// process, not memory scoped to the measured block. Measurements may
    /// vary between runs due to system-level allocations.
    public var memoryLimit      : ByteCount?
    
    
    
    /// Initializes a ``PerformanceOptions`` instance, optionally specifying
    /// values for its properties.
    ///
    /// - Precondition: `runs` must be positive.
    /// - Precondition: `warmupRuns` must not be negative.
    /// - Precondition: `wallTimeLimit`, `cpuTimeLimit`, and `memoryLimit`
    /// must be positive or `nil`.
    public init(
        runs            : Int           = 10,
        warmupRuns      : Int           = 1,
        wallTimeLimit   : Duration?     = nil,
        cpuTimeLimit    : Duration?     = nil,
        memoryLimit     : ByteCount?    = nil
    )
    {
        precondition(
            runs > 0,
            "runs must be positive"
        )
        
        precondition(
            warmupRuns >= 0,
            "warmupRuns must not be negative"
        )
        
        if let wallTimeLimit
        {
            precondition(
                wallTimeLimit > .zero,
                "wallTimeLimit must be positive"
            )
        }
        
        if let cpuTimeLimit
        {
            precondition(
                cpuTimeLimit > .zero,
                "cpuTimeLimit must be positive"
            )
        }
        
        if let memoryLimit
        {
            precondition(
                memoryLimit > .zero,
                "memoryLimit must be positive"
            )
        }
        
        self.runs           = runs
        self.warmupRuns     = warmupRuns
        self.wallTimeLimit  = wallTimeLimit
        self.cpuTimeLimit   = cpuTimeLimit
        self.memoryLimit    = memoryLimit
    }
}
