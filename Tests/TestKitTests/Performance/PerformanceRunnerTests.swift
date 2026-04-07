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



internal final class PerformanceRunnerTests: TestKitCase
{
    private typealias FailedValues = FailedPerformanceValues
    
    
    
    // MARK: - No metrics
    
    func testAllMetricsNilReturnsNoMetrics() async
    {
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           10,
            warmupRuns:     1,
            wallTimeLimit:  nil,
            memoryLimit:    nil,
            body:           { }
        )
        
        result.assertNoMetrics()
    }
    
    
    
    // MARK: - Warmup (passing)
    
    func testWarmupRunsNotIncludedInMeasurements() async throws
    {
        let counter     : Counter   = .init()
        let warmupRuns  : Int       = 3
        let runs        : Int       = 2
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           runs,
            warmupRuns:     warmupRuns,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { await counter.increment() }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        let totalCalls: Int = await counter.value
        
        XCTAssertEqual(totalCalls, warmupRuns + runs)
        XCTAssertEqual(measurements.wallTime?.count, runs)
        XCTAssertEqual(measurements.runs, runs)
    }
    
    
    
    func testZeroWarmupRunsSkipsWarmup() async throws
    {
        let counter = Counter()
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           1,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { await counter.increment() }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        let totalCalls: Int = await counter.value
        
        XCTAssertEqual(totalCalls, 1)
        XCTAssertTrue(measurements.success)
    }
    
    
    
    // MARK: - Warmup (failing)
    
    func testAssertionFalureDuringWarmupReturnsFailed() async throws
    {
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     2,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { FailureInterceptor.current?.recordFailure() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertTrue(failed.warmup)
        XCTAssertEqual(failed.run, 1)
        XCTAssertFalse(failed.failures.isEmpty)
        XCTAssertNil(failed.error)
    }
    
    
    
    func testThrownErrorDuringWarmupReturnsFailed() async throws
    {
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     2,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { throw TestError() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertTrue(failed.warmup)
        XCTAssertEqual(failed.run, 1)
        XCTAssertTrue(failed.failures.isEmpty)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    func testFailureAndThrownErrorDuringWarmupCaptured() async throws
    {
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     2,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:
            {
                FailureInterceptor.current?.recordFailure()
                throw TestError()
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertTrue(failed.warmup)
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    func testWarmupFailureStopsBeforeMeasurement() async throws
    {
        let counter = Counter()
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     1,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:
            {
                await counter.increment()
                FailureInterceptor.current?.recordFailure()
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertTrue(failed.warmup)
        XCTAssertFalse(failed.failures.isEmpty)
        XCTAssertNil(failed.error)
        
        let totalCalls: Int = await counter.value
        
        XCTAssertEqual(totalCalls, 1)
    }
    
    
    
    func testWarmupFailureOnSecondWarmupRun() async throws
    {
        let counter : Counter   = .init()
        let target  : Int       = 2
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     3,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:
            {
                let count: Int = await counter.increment()
                
                if count == target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertTrue(failed.warmup)
        XCTAssertEqual(failed.run, target)
        XCTAssertNil(failed.error)
        
        let totalCalls: Int = await counter.value
        
        XCTAssertEqual(totalCalls, target)
    }
    
    
    
    func testMultipleFailuresCapturedInSingleWarmupRun() async throws
    {
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     2,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:
            {
                FailureInterceptor.current?.recordFailure(
                    message:    "first",
                    fileID:     "ID1",
                    file:       "File1.swift",
                    line:       1,
                    column:     2
                )
                
                FailureInterceptor.current?.recordFailure(
                    message:    "second",
                    fileID:     "ID2",
                    file:       "File2.swift",
                    line:       3,
                    column:     4
                )
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertTrue(failed.warmup)
        XCTAssertEqual(failed.failures.count, 2)
        XCTAssertEqual(failed.failures[0].message, "first")
        XCTAssertEqual(failed.failures[1].message, "second")
    }
    
    
    
    // MARK: - Measurement (passing)
    
    func testMultipleMetricsEnabledAllPassing() async throws
    {
        let runs: Int = 3
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           runs,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    .bytes(UInt64.max),
            body:           { }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        XCTAssertTrue(measurements.success)
        
        XCTAssertNotNil(measurements.wallTime)
        XCTAssertEqual(measurements.wallTime?.count, runs)
        XCTAssertNotNil(measurements.medianWallTime)
        XCTAssertNotNil(measurements.wallTimeLimit)
        XCTAssertFalse(measurements.wallTimeLimitExceeded)
        
        XCTAssertNotNil(measurements.memory)
        XCTAssertEqual(measurements.memory?.count, runs)
        XCTAssertNotNil(measurements.medianMemory)
        XCTAssertNotNil(measurements.memoryLimit)
        XCTAssertFalse(measurements.memoryLimitExceeded)
    }
    
    
    
    func testMultipleMetricsEnabledOnlyWallTimeExceeded() async throws
    {
        try skipCI()
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           3,
            warmupRuns:     0,
            wallTimeLimit:  .nanoseconds(1),
            memoryLimit:    .bytes(UInt64.max),
            body:           { try? await Task.sleep(for: .milliseconds(5)) }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        XCTAssertFalse(measurements.success)
        
        XCTAssertTrue(measurements.wallTimeLimitExceeded)
        XCTAssertFalse(measurements.memoryLimitExceeded)
        
        XCTAssertNotNil(measurements.memory)
        XCTAssertNotNil(measurements.medianMemory)
    }
    
    
    
    func testMedianWallTimeWithOddRunCount() async throws
    {
        let runs: Int = 3
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           runs,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        XCTAssertNotNil(measurements.medianWallTime)
        XCTAssertEqual(measurements.wallTime?.count, runs)
        
        let sorted: [Duration] = measurements.wallTime!.sorted()
        
        /// The median is the middle element.
        XCTAssertEqual(measurements.medianWallTime, sorted[1])
    }
    
    
    
    func testMedianWallTimeWithEvenRunCount() async throws
    {
        let runs: Int = 4
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           runs,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        XCTAssertNotNil(measurements.medianWallTime)
        XCTAssertEqual(measurements.wallTime?.count, runs)
        
        let sorted: [Duration] = measurements.wallTime!.sorted()
        
        /// The median is the lower-middle element.
        XCTAssertEqual(measurements.medianWallTime, sorted[1])
    }
    
    
    
    func testSingleRunMedianEqualsOnlyMeasurement() async throws
    {
        let runs: Int = 1
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           runs,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        XCTAssertEqual(measurements.wallTime?.count, runs)
        
        XCTAssertEqual(
            measurements.medianWallTime,
            measurements.wallTime?.first
        )
    }
    
    
    
    func testWallTimeWithinLimitPasses() async throws
    {
        let runs: Int = 3
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           runs,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        XCTAssertTrue(measurements.success)
        
        XCTAssertNotNil(measurements.wallTime)
        XCTAssertEqual(measurements.wallTime?.count, runs)
        XCTAssertNotNil(measurements.medianWallTime)
        XCTAssertNotNil(measurements.wallTimeLimit)
        XCTAssertFalse(measurements.wallTimeLimitExceeded)
        
        XCTAssertNil(measurements.memory)
        XCTAssertNil(measurements.medianMemory)
        XCTAssertNil(measurements.memoryLimit)
        XCTAssertFalse(measurements.memoryLimitExceeded)
    }
    
    
    
    func testWallTimeMeasurementReflectsSleep() async throws
    {
        try skipCI()
        
        let sleepDuration: Duration = .milliseconds(20)
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           3,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { try? await Task.sleep(for: sleepDuration) }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        XCTAssertTrue(measurements.success)
        XCTAssertNotNil(measurements.medianWallTime)
        
        XCTAssertGreaterThanOrEqual(
            measurements.medianWallTime!,
            sleepDuration
        )
        
        XCTAssertLessThan(
            measurements.medianWallTime!,
            sleepDuration + .milliseconds(200)
        )
    }
    
    
    
    func testMemoryMeasurementProducesMeasurableDifference() async throws
    {
        try skipCI()
        
        let runs    : Int           = 3
        let holder  : MemoryHolder  = .init()
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           runs,
            warmupRuns:     0,
            wallTimeLimit:  nil,
            memoryLimit:    .bytes(UInt64.max),
            body:           { holder.allocate() }
        )
        
        withExtendedLifetime(holder) { }
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        XCTAssertTrue(measurements.success)
        
        XCTAssertNil(measurements.wallTime)
        XCTAssertNil(measurements.medianWallTime)
        XCTAssertNil(measurements.wallTimeLimit)
        XCTAssertFalse(measurements.wallTimeLimitExceeded)
        
        XCTAssertNotNil(measurements.memory)
        XCTAssertEqual(measurements.memory?.count, runs)
        XCTAssertNotNil(measurements.medianMemory)
        XCTAssertNotNil(measurements.memoryLimit)
        XCTAssertFalse(measurements.memoryLimitExceeded)
        
        for measurement in measurements.memory ?? []
        {
            XCTAssertGreaterThan(measurement, .zero)
        }
    }
    
    
    
    // MARK: - Measurement (failing)
    
    func testAssertionFalureDuringMeasurementReturnsFailed() async throws
    {
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { FailureInterceptor.current?.recordFailure() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertFalse(failed.warmup)
        XCTAssertEqual(failed.run, 1)
        XCTAssertFalse(failed.failures.isEmpty)
        XCTAssertNil(failed.error)
    }
    
    
    
    func testThrownErrorDuringMeasurementReturnsFailed() async throws
    {
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:           { throw TestError() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertFalse(failed.warmup)
        XCTAssertEqual(failed.run, 1)
        XCTAssertTrue(failed.failures.isEmpty)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    func testFailureAndThrownErrorDuringMeasurementCaptured() async throws
    {
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:
            {
                FailureInterceptor.current?.recordFailure()
                throw TestError()
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertFalse(failed.warmup)
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    func testFailureOnLaterMeasurementRun() async throws
    {
        let counter : Counter   = .init()
        let target  : Int       = 3
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:
            {
                let count: Int = await counter.increment()
                
                if count == target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertFalse(failed.warmup)
        XCTAssertEqual(failed.run, target)
        XCTAssertFalse(failed.failures.isEmpty)
        XCTAssertNil(failed.error)
    }
    
    
    
    func testMultipleFailuresCapturedInSingleMeasurementRun() async throws
    {
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           5,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:
            {
                FailureInterceptor.current?.recordFailure(
                    message:    "first",
                    fileID:     "ID1",
                    file:       "File1.swift",
                    line:       1,
                    column:     2
                )
                
                FailureInterceptor.current?.recordFailure(
                    message:    "second",
                    fileID:     "ID2",
                    file:       "File2.swift",
                    line:       3,
                    column:     4
                )
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertFalse(failed.warmup)
        XCTAssertEqual(failed.failures.count, 2)
        XCTAssertEqual(failed.failures[0].message, "first")
        XCTAssertEqual(failed.failures[1].message, "second")
    }
    
    
    
    // MARK: - Cancelation
    
    func testCancelationBeforeAnyRuns() async throws
    {
        try skipCI()
        
        let task = Task
        {
            await PerformanceRunner.run(
                runs:           5,
                warmupRuns:     1,
                wallTimeLimit:  .seconds(10),
                memoryLimit:    nil,
                body:
                {
                    try? await Task.sleep(for: .milliseconds(100))
                }
            )
        }
        
        task.cancel()
        
        let result: PerformanceResult = await task.value
        
        result.assertCanceled()
    }
    
    
    
    func testCancelationDuringMeasurement() async throws
    {
        try skipCI()
        
        let task = Task
        {
            await PerformanceRunner.run(
                runs:           100,
                warmupRuns:     0,
                wallTimeLimit:  .seconds(60),
                memoryLimit:    nil,
                body:
                {
                    try? await Task.sleep(for: .milliseconds(50))
                }
            )
        }
        
        try? await Task.sleep(for: .milliseconds(80))
        
        task.cancel()
        
        let result: PerformanceResult = await task.value
        
        result.assertCanceled()
    }
    
    
    
    func testWallTimeExceedsLimitFails() async throws
    {
        try skipCI()
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           3,
            warmupRuns:     0,
            wallTimeLimit:  .nanoseconds(1),
            memoryLimit:    nil,
            body:           { try? await Task.sleep(for: .milliseconds(5)) }
        )
        
        let measurements: PerformanceMeasurements
            = try XCTUnwrap(result.assertCompleted())
        
        XCTAssertFalse(measurements.success)
        XCTAssertTrue(measurements.wallTimeLimitExceeded)
    }
    
    
    
    // MARK: - Nested
    
    func testInnerFailuresDoNotLeakToOuterInterceptor() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            let result: PerformanceResult = await PerformanceRunner.run(
                runs:           3,
                warmupRuns:     0,
                wallTimeLimit:  .seconds(10),
                memoryLimit:    nil,
                body:           { FailureInterceptor.current?.recordFailure() }
            )
            
            result.assertFailed()
        }
        
        XCTAssertFalse(outer.didFail)
        XCTAssertTrue(outer.failures.isEmpty)
    }
    
    
    
    func testOuterInterceptorRestoredAfterRun() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            _ = await PerformanceRunner.run(
                runs:           1,
                warmupRuns:     0,
                wallTimeLimit:  .seconds(10),
                memoryLimit:    nil,
                body:           { }
            )
            
            XCTAssertIdentical(FailureInterceptor.current, outer)
        }
    }
    
    
    
    func testBodySeesPerformanceInterceptor() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            _ = await PerformanceRunner.run(
                runs:           1,
                warmupRuns:     0,
                wallTimeLimit:  .seconds(10),
                memoryLimit:    nil,
                body:
                {
                    XCTAssertNotNil(FailureInterceptor.current)
                    XCTAssertNotIdentical(FailureInterceptor.current, outer)
                    
                    XCTAssertTrue(
                        FailureInterceptor.current is PerformanceInterceptor
                    )
                }
            )
        }
    }
    
    
    func testInterceptorResetBetweenMeasurementRuns() async throws
    {
        let counter : Counter   = .init()
        let target  : Int       = 3
        let runs    : Int       = 5
        
        let result: PerformanceResult = await PerformanceRunner.run(
            runs:           runs,
            warmupRuns:     0,
            wallTimeLimit:  .seconds(10),
            memoryLimit:    nil,
            body:
            {
                let count: Int = await counter.increment()
                
                if count == target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        /// The failure must occur exactly on run `target`, not earlier, which
        /// would indicate leaked state from a previous run.
        XCTAssertEqual(failed.run, target)
        XCTAssertFalse(failed.warmup)
        
        let totalCalls: Int = await counter.value
        
        XCTAssertEqual(totalCalls, target)
    }
}
