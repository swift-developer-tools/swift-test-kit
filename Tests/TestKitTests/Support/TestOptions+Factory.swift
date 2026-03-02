//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore



internal extension TestOptions
{
    /// Initializes a ``TestOptions`` instance, optionally specifying values
    /// for its property-based testing options property.
    static func propertyOptions(
        iterations      : Int                   = 100,
        maxShrinkSteps  : Int                   = 100,
        maxSize         : Int                   = 100,
        maxDiscardRatio : Int                   = 10,
        maxCommandCount : Int                   = 100,
        statistics      : CommandStatistics     = [],
        seed            : UInt64?               = nil
    ) -> TestOptions
    {
        let propertyOptions = PropertyOptions(
            iterations:         iterations,
            maxShrinkSteps:     maxShrinkSteps,
            maxSize:            maxSize,
            maxDiscardRatio:    maxDiscardRatio,
            maxCommandCount:    maxCommandCount,
            statistics:         statistics,
            seed:               seed
        )
        
        return TestOptions(propertyOptions: propertyOptions)
    }
    
    
    
    /// Initializes a ``TestOptions`` instance, optionally specifying values
    /// for its temporal testing options property.
    static func temporalOptions(
        timeout         : Duration  = .seconds(2),
        interval        : Duration  = .milliseconds(50),
        showAllFailures : Bool      = false
    ) -> TestOptions
    {
        let temporalOptions = TemporalOptions(
            timeout:            timeout,
            interval:           interval,
            showAllFailures:    showAllFailures
        )
        
        return TestOptions(temporalOptions: temporalOptions)
    }
    
    
    
    /// Initializes a ``TestOptions`` instance, optionally specifying values
    /// for its performance testing options property.
    static func performanceOptions(
        runs            : Int           = 10,
        warmupRuns      : Int           = 1,
        timeLimit       : Duration?     = nil,
        memoryLimit     : UInt64?       = nil,
        showAllFailures : Bool          = false
    ) -> TestOptions
    {
        let performanceOptions = PerformanceOptions(
            runs:               runs,
            warmupRuns:         warmupRuns,
            timeLimit:          timeLimit,
            memoryLimit:        memoryLimit,
            showAllFailures:    showAllFailures
        )
        
        return TestOptions(performanceOptions: performanceOptions)
    }
}
