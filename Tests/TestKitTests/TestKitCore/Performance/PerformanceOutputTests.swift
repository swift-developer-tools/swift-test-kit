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



internal final class PerformanceOutputTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Assertion failures
    
    func testAssertionFailureDuringWarmup() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     1,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (warmup run 1 of 1)
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertionFailureDuringMeasurementRun() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 1 of 3)
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertionFailureDuringMeasurementRunWithMessage() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(
                "hello world",
                options: options
            )
            {
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 1 of 3)
        
        XCTKAssertTrue failed
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertionFailureOnLaterMeasurementRun() async
    {
        let count = Mutex<Int>(0)
        
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                let n: Int = count.withLock
                {
                    $0 += 1
                    return $0
                }
                
                if n >= 2
                {
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 2 of 3)
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertionFailureWithMultipleWarmupRuns() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     3,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (warmup run 1 of 3)
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Thrown errors
    
    func testThrownErrorDuringWarmup() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     1,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (warmup run 1 of 1)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testThrownErrorDuringMeasurementRun() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 1 of 3)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testThrownErrorWithMessage() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(
                "hello world",
                options: options
            )
            {
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 1 of 3)
        
        Threw error: TestError()
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertionFailureAndThrownError() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                TKAssertTrue(false)
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 1 of 3)
        
        XCTKAssertTrue failed
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Time
    
    func testTimeLimitExceeded() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           1,
            warmupRuns:     0,
            timeLimit:      .milliseconds(1)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKPerformance(
                options:    options,
                context:    context
            )
            {
                try await Task.sleep(for: .milliseconds(50))
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Time:
            Threshold: 1 ms
            Median: <M> (1 run) ←
        """
        
        XCTAssertEqual(expected, actual?.medianless)
    }
    
    
    
    func testTimeLimitExceededWithMessage() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           1,
            warmupRuns:     0,
            timeLimit:      .milliseconds(1)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKPerformance(
                "hello world",
                options:    options,
                context:    context
            )
            {
                try await Task.sleep(for: .milliseconds(50))
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Time:
            Threshold: 1 ms
            Median: <M> (1 run) ←
        
        hello world
        """
        
        XCTAssertEqual(expected, actual?.medianless)
    }
    
    
    
    // MARK: - Memory
    
    func testMemoryLimitExceeded() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           1,
            warmupRuns:     0,
            memoryLimit:    .bytes(1)
        )
        
        let holder = MemoryHolder()
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                holder.allocate()
            }
            
            withExtendedLifetime(holder) { }
        }
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Memory:
            Threshold: 1 B
            Median: <M> (1 run) ←
        """
        
        XCTAssertEqual(expected, actual?.medianless)
    }
    
    
    
    // MARK: - Both metrics
    
    func testBothMetricsBothExceeded() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .milliseconds(1),
            memoryLimit:    .bytes(1)
        )
        
        let holder = MemoryHolder()
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKPerformance(
                options:    options,
                context:    context
            )
            {
                holder.allocate()
                try await Task.sleep(for: .milliseconds(50))
            }
            
            withExtendedLifetime(holder) { }
        }
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Time:
            Threshold: 1 ms
            Median: <M> (3 runs) ←
        
        Memory:
            Threshold: 1 B
            Median: <M> (3 runs) ←
        """
        
        XCTAssertEqual(expected, actual?.medianless)
    }
    
    
    
    func testBothMetricsTimeExceeded() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .milliseconds(1),
            memoryLimit:    .gigabytes(50)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKPerformance(
                options:    options,
                context:    context
            )
            {
                try await Task.sleep(for: .milliseconds(50))
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Time:
            Threshold: 1 ms
            Median: <M> (3 runs) ←
        
        Memory:
            Threshold: 50 GB
            Median: <M> (3 runs)
        """
        
        XCTAssertEqual(expected, actual?.medianless)
    }
    
    
    
    func testBothMetricsMemoryExceeded() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10),
            memoryLimit:    .bytes(1)
        )
        
        let holder = MemoryHolder()
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                holder.allocate()
            }
            
            withExtendedLifetime(holder) { }
        }
        
        let expected: String =
        """
        XCTKPerformance failed
        
        Time:
            Threshold: 10 sec
            Median: <M> (3 runs)
        
        Memory:
            Threshold: 1 B
            Median: <M> (3 runs) ←
        """
        
        XCTAssertEqual(expected, actual?.medianless)
    }
    
    
    
    // MARK: - Show all failures
    
    func testShowAllFailures() async
    {
        let options: TestOptions = .performanceOptions(
            runs:               3,
            warmupRuns:         0,
            timeLimit:          .seconds(10),
            showAllFailures:    true
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                TKAssertTrue(false)
                TKAssertFalse(true)
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 1 of 3)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testShowAllFailuresDuringWarmup() async
    {
        let options: TestOptions = .performanceOptions(
            runs:               3,
            warmupRuns:         1,
            timeLimit:          .seconds(10),
            showAllFailures:    true
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                TKAssertTrue(false)
                TKAssertFalse(true)
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (warmup run 1 of 1)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testShowAllFailuresIndentedMulipleLines() async
    {
        struct User: Equatable
        {
            let name: String
        }
        
        let options: TestOptions = .performanceOptions(
            runs:               3,
            warmupRuns:         0,
            timeLimit:          .seconds(10),
            showAllFailures:    true
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                TKAssertEqual(User(name: "a"), User(name: "b"))
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 1 of 3)

        Failure 1:
            XCTKAssertEqual failed
            
            User differs at:
            
                .name, character 1
                    Expected:   "a"
                    Actual:     "b"

        Failure 2:
            XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Nested
    
    func testPerformanceInsidePerformance() async
    {
        let options1: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let options2: TestOptions = .performanceOptions(
            runs:           1,
            warmupRuns:     0,
            timeLimit:      .milliseconds(1)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKPerformance(
                options:    options1,
                context:    context
            )
            {
                await TKPerformance(
                    options:    options2,
                    context:    context
                )
                {
                    try await Task.sleep(for: .milliseconds(50))
                }
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 1 of 3)

        XCTKPerformance failed
        
        Time:
            Threshold: 1 ms
            Median: <M> (1 run) ←
        """
        
        XCTAssertEqual(expected, actual?.medianless)
    }
    
    
    
    func testPerformanceInsideAlways() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways
            {
                await TKPerformance(options: options)
                {
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        XCTKPerformance failed (run 1 of 3)

        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testPerformanceInsideEventually() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKEventually(
                timeout:    .milliseconds(50),
                interval:   .milliseconds(10),
                context:    context
            )
            {
                await TKPerformance(options: options)
                {
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 50 ms
        
        XCTKPerformance failed (run 1 of 3)

        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPerformanceInsideForAll() async
    {
        let propertyOptions: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let performanceOptions: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(options: propertyOptions)
            {
                (_: Int) async in
                
                await TKPerformance(options: performanceOptions)
                {
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKPerformance failed (run 1 of 3)

        XCTKAssertTrue failed
        
        Seed: 12345 (XCTKForAll)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPerformanceInsideStateful() async
    {
        let propertyOptions: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let performanceOptions: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    propertyOptions
            )
            {
                _, _ async in
                
                await TKPerformance(options: performanceOptions)
                {
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Counterexample:
            1. increment ←
        
        XCTKPerformance failed (run 1 of 3)

        XCTKAssertTrue failed
        
        Seed: 12345 (XCTKStateful)
        """
        
        XCTAssertEqual(expected, actual)
    }
}
