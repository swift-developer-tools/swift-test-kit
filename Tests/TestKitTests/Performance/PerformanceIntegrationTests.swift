//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import Synchronization
import XCTest



internal final class PerformanceIntegrationTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Passing
    
    func testNoMetricsPasses() async
    {
        let options: TestOptions = .performanceOptions(
            wallTimeLimit:  nil,
            memoryLimit:    nil
        )
        
        await TKPerformance(options: options) { }
    }
    
    
    
    func testWallTimeLimitPasses() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10_000)
        )
        
        await TKPerformance(options: options) { }
    }
    
    
    
    func testMemoryLimitPasses() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            memoryLimit:    .gigabytes(50)
        )
        
        await TKPerformance(options: options) { }
    }
    
    
    
    func testMultipleLimitsPass() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10_000),
            memoryLimit:    .gigabytes(50)
        )
        
        await TKPerformance(options: options) { }
    }
    
    
    
    // MARK: - Options
    
    func testRunsParameterOverridesDefaultOptions() async
    {
        let count = Mutex<Int>(0)
        
        let runs: Int = 3
        
        let options: TestOptions = .performanceOptions(
            runs:           10,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10_000)
        )
        
        await TKPerformance(
            runs:       runs,
            options:    options
        )
        {
            count.withLock { $0 += 1 }
        }
        
        XCTAssertEqual(runs, count.withLock { $0 })
    }
    
    
    
    func testWarmupRunsParameterOverridesDefaultOptions() async
    {
        let count = Mutex<Int>(0)
        
        let runs        : Int   = 1
        let warmupRuns  : Int   = 2
        
        let options: TestOptions = .performanceOptions(
            runs:           runs,
            warmupRuns:     5,
            wallTimeLimit:  .seconds(10_000)
        )
        
        await TKPerformance(
            warmupRuns:     warmupRuns,
            options:        options
        )
        {
            count.withLock { $0 += 1 }
        }
        
        XCTAssertEqual(warmupRuns + runs, count.withLock { $0 })
    }
    
    
    
    func testWallTimeLimitParameterOverridesDefaultOptions() async throws
    {
        try skipCI()
        
        let wallTimeLimit: Duration = .milliseconds(1)
        
        let options: TestOptions = .performanceOptions(
            runs:           1,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10_000)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKPerformance(
                wallTimeLimit:  wallTimeLimit,
                options:        options,
                context:        context
            )
            {
                try await Task.sleep(for: .milliseconds(50))
            }
        }
        
        XCTAssertNotNil(actual)
    }
    
    
    
    func testMemoryLimitParameterOverridesDefaultOptions() async throws
    {
        try skipCI()
        
        let holder = MemoryHolder()
        
        let options: TestOptions = .performanceOptions(
            runs:           1,
            warmupRuns:     0,
            memoryLimit:    .gigabytes(50)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(
                memoryLimit:    .bytes(1),
                options:        options
            )
            {
                holder.allocate()
            }
            
            withExtendedLifetime(holder) { }
        }
        
        XCTAssertNotNil(actual)
    }
}
