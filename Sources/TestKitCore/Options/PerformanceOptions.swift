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
    
    /// The time limit.
    ///
    /// The default value is `nil` (time measurement disabled). When non-`nil`,
    /// the test fails if the median time across measurement runs exceeds this
    /// limit.
    public var timeLimit        : Duration?
    
    /// The memory limit, in bytes.
    ///
    /// The default value is `nil` (memory measurement disabled). When
    /// non-`nil`, the test fails if the median memory usage difference
    /// across measurement runs exceeds this limit.
    ///
    /// - Note: This measures the physical memory footprint of the entire
    /// process, not memory scoped to the measured block. Measurements may
    /// vary between runs due to system-level allocations.
    public var memoryLimit      : UInt64?
    
    /// Whether to show all assertion failures from the failing run.
    ///
    /// The default value is `false`. When `false`, only the first assertion
    /// failure is shown.
    public var showAllFailures  : Bool
    
    
    
    /// Initializes a ``PerformanceOptions`` instance, optionally specifying
    /// values for its properties.
    ///
    /// - Precondition: `runs` must be positive.
    /// - Precondition: `warmupRuns` must not be negative.
    /// - Precondition: `timeLimit` and `memoryLimit` must be positive
    /// or `nil`.
    public init(
        runs            : Int           = 10,
        warmupRuns      : Int           = 1,
        timeLimit       : Duration?     = nil,
        memoryLimit     : UInt64?       = nil,
        showAllFailures : Bool          = false
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
        
        if let timeLimit
        {
            precondition(
                timeLimit > .zero,
                "timeLimit must be positive"
            )
        }
        
        if let memoryLimit
        {
            precondition(
                memoryLimit > .zero,
                "memoryLimit must be positive"
            )
        }
        
        self.runs               = runs
        self.warmupRuns         = warmupRuns
        self.timeLimit          = timeLimit
        self.memoryLimit        = memoryLimit
        self.showAllFailures    = showAllFailures
    }
}
