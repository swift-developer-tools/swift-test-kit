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



internal final class TemporalRunnerTests: TestKitCase
{
    // MARK: - Eventually (passing)
    
    func testEventuallyPassesOnFirstPoll() async
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .microseconds(200),
            interval:   .milliseconds(10),
            body:       { }
        )
        
        result.assertPassed()
    }
    
    
    
    func testEventuallyPassesAfterFailures() async
    {
        let start: ContinuousClock.Instant = .now
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                if start.elapsed < .milliseconds(50)
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        result.assertPassed()
    }
    
    
    
    func testEventuallyPassesAfterThrownErrors() async
    {
        let start: ContinuousClock.Instant = .now
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                if start.elapsed < .milliseconds(50)
                {
                    throw TestError()
                }
            }
        )
        
        result.assertPassed()
    }
    
    
    
    func testEventuallyPassesAfterFailuresAndThrownErrors() async
    {
        let start: ContinuousClock.Instant = .now
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                if start.elapsed < .milliseconds(30)
                {
                    FailureInterceptor.current?.recordFailure()
                }
                if start.elapsed < .milliseconds(50)
                {
                    throw TestError()
                }
            }
        )
        
        result.assertPassed()
    }
    
    
    
    func testEventuallyWithTimeoutEqualToInterval() async
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(50),
            interval:   .milliseconds(50),
            body:       { }
        )
        
        result.assertPassed()
    }
    
    
    
    func testEventuallyWithAlternatingPassFail() async
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                if count % 2 == 1
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        result.assertPassed()
    }
    
    
    
    func testEventuallyInterceptorIsNonNilOnEveryPoll() async
    {
        let counter         : Counter   = .init()
        let requiredPolls   : Int       = 5
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                XCTAssertNotNil(FailureInterceptor.current)
                
                XCTAssertTrue(
                    FailureInterceptor.current is TemporalInterceptor
                )
                
                let count: Int = await counter.increment()
                
                if count < requiredPolls
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        result.assertPassed()
        
        let finalCount: Int = await counter.value
        
        XCTAssertGreaterThanOrEqual(finalCount, requiredPolls)
    }
    
    
    
    // MARK: - Eventually (failing)
    
    func testEventuallyFailsOnTimeout() async throws
    {
        let timeout: Duration = .milliseconds(100)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    timeout,
            interval:   .milliseconds(10),
            body:       { FailureInterceptor.current?.recordFailure() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertGreaterThanOrEqual(failed.elapsed, timeout)
        XCTAssertFalse(failed.failures.isEmpty)
        XCTAssertNil(failed.error)
    }
    
    
    
    func testEventuallyFailsWithLastPollFailures() async throws
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                FailureInterceptor.current?.recordFailure(
                    message:    "poll \(count)",
                    fileID:     "ID",
                    file:       "File.swift",
                    line:       1,
                    column:     2
                )
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        
        let message: String = failed.failures[0].message
        
        XCTAssertTrue(message.hasPrefix("poll "))
        
        let pollNumber: Int? = Int(message.dropFirst("poll ".count))
        
        /// The poll number must be from the last poll, not the first.
        XCTAssertNotNil(pollNumber)
        XCTAssertGreaterThan(pollNumber ?? 0, 1)
    }
    
    
    
    func testEventuallyFailsWhenBodyAlwaysThrows() async throws
    {
        let timeout: Duration = .milliseconds(100)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    timeout,
            interval:   .milliseconds(10),
            body:       { throw TestError() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertGreaterThanOrEqual(failed.elapsed, timeout)
        XCTAssertTrue(failed.failures.isEmpty)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    func testEventuallyFailsCapturesBothFailureAndThrownError() async throws
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
            body:
            {
                FailureInterceptor.current?.recordFailure()
                throw TestError()
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    func testEventuallyFailsWithMultipleAssertions() async throws
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
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
        
        XCTAssertEqual(failed.failures.count, 2)
        XCTAssertEqual(failed.failures[0].message, "first")
        XCTAssertEqual(failed.failures[1].message, "second")
    }
    
    
    
    func testEventuallyWithShortTimeout() async
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(5),
            interval:   .milliseconds(5),
            body:       { FailureInterceptor.current?.recordFailure() }
        )
        
        result.assertFailed()
    }
    
    
    
    // MARK: - Always (passing)
    
    func testAlwaysPassesAfterTimeout() async
    {
        let timeout: Duration = .milliseconds(100)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    timeout,
            interval:   .milliseconds(10),
            body:       { }
        )
        
        result.assertPassed()
    }
    
    
    
    func testAlwaysPassesWithNonFailingAssertions() async
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
            body:
            {
                if false
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        result.assertPassed()
    }
    
    
    
    func testAlwaysWithTimeoutEqualToInterval() async
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(50),
            interval:   .milliseconds(50),
            body:       { }
        )
        
        result.assertPassed()
    }
    
    
    
    // MARK: - Always (failing)
    
    func testAlwaysFailsOnFirstPoll() async throws
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(200),
            interval:   .milliseconds(10),
            body:       { FailureInterceptor.current?.recordFailure() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertLessThan(failed.elapsed, .milliseconds(50))
        XCTAssertNil(failed.error)
    }
    
    
    
    func testAlwaysFailsAfterPassingPolls() async throws
    {
        let start   : ContinuousClock.Instant   = .now
        let timeout : Duration                  = .milliseconds(500)
        let target  : Duration                  = .milliseconds(50)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    timeout,
            interval:   .milliseconds(10),
            body:
            {
                if start.elapsed >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertGreaterThanOrEqual(failed.elapsed, target)
        XCTAssertLessThan(failed.elapsed, timeout)
        XCTAssertNil(failed.error)
    }
    
    
    
    func testAlwaysFailsOnFirstPollThrownError() async throws
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(200),
            interval:   .milliseconds(10),
            body:       { throw TestError() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertTrue(failed.failures.isEmpty)
        XCTAssertLessThan(failed.elapsed, .milliseconds(50))
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    func testAlwaysFailsAfterPassingPollsThenThrownError() async throws
    {
        let start   : ContinuousClock.Instant   = .now
        let timeout : Duration                  = .milliseconds(500)
        let target  : Duration                  = .milliseconds(50)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    timeout,
            interval:   .milliseconds(10),
            body:
            {
                if start.elapsed >= target
                {
                    throw TestError()
                }
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertTrue(failed.failures.isEmpty)
        XCTAssertGreaterThanOrEqual(failed.elapsed, target)
        XCTAssertLessThan(failed.elapsed, timeout)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    func testAlwaysFailsCapturesBothFailureAndThrownError() async throws
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
            body:
            {
                FailureInterceptor.current?.recordFailure()
                throw TestError()
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertNotNil(failed.error)
        XCTAssertTrue(failed.error is TestError)
    }
    
    
    
    func testAlwaysFailsWithMultipleAssertions() async throws
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
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
        
        XCTAssertEqual(failed.failures.count, 2)
        XCTAssertEqual(failed.failures[0].message, "first")
        XCTAssertEqual(failed.failures[1].message, "second")
    }
    
    
    
    func testAlwaysCapturesAllAssertionsFromFailingPoll() async throws
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                if count >= 3
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
            }
        )
            
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 2)
        XCTAssertEqual(failed.failures[0].message, "first")
        XCTAssertEqual(failed.failures[1].message, "second")
    }
    
    
    
    func testAlwaysCapturesOnlyFailingPoll() async throws
    {
        let counter : Counter   = .init()
        let target  : Int       = 4
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                if count >= target
                {
                    FailureInterceptor.current?.recordFailure(
                        message:    "poll \(count)",
                        fileID:     "ID2",
                        file:       "File2.swift",
                        line:       1,
                        column:     1
                    )
                }
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertEqual(failed.failures[0].message, "poll \(target)")
    }
    
    
    
    // MARK: - Canceled
    
    func testEventuallyCancelsWhenTaskCanceled() async
    {
        let task = Task
        {
            await TemporalRunner.run(
                kind:       .eventually,
                timeout:    .milliseconds(500),
                interval:   .milliseconds(10),
                body:       { FailureInterceptor.current?.recordFailure() }
            )
        }
        
        /// Allow a few polls before canceling.
        try? await Task.sleep(for: .milliseconds(30))
        
        task.cancel()
        
        let result: TemporalResult = await task.value
        
        result.assertCanceled()
    }
    
    
    
    func testAlwaysCancelsWhenTaskCanceled() async
    {
        let task = Task
        {
            await TemporalRunner.run(
                kind:       .always,
                timeout:    .milliseconds(500),
                interval:   .milliseconds(10),
                body:       { }
            )
        }
        
        /// Allow a few polls before canceling.
        try? await Task.sleep(for: .milliseconds(30))
        
        task.cancel()
        
        let result: TemporalResult = await task.value
        
        result.assertCanceled()
    }
    
    
    
    func testEventuallyCancelsOnPreCanceledTask() async
    {
        let task = Task
        {
            await TemporalRunner.run(
                kind:       .eventually,
                timeout:    .milliseconds(200),
                interval:   .milliseconds(10),
                body:       { FailureInterceptor.current?.recordFailure() }
            )
        }
        
        task.cancel()
        
        let result: TemporalResult = await task.value
        
        result.assertCanceled()
    }
    
    
    
    func testAlwaysCancelsOnPreCanceledTask() async
    {
        let task = Task
        {
            await TemporalRunner.run(
                kind:       .always,
                timeout:    .milliseconds(200),
                interval:   .milliseconds(10),
                body:       { }
            )
        }
        
        task.cancel()
        
        let result: TemporalResult = await task.value
        
        result.assertCanceled()
    }
    
    
    
    func testEventuallyCancelationMidBody() async
    {
        let task = Task
        {
            await TemporalRunner.run(
                kind:       .eventually,
                timeout:    .milliseconds(500),
                interval:   .milliseconds(10),
                body:
                {
                    FailureInterceptor.current?.recordFailure()
                    try? await Task.sleep(for: .milliseconds(200))
                }
            )
        }
        
        /// Cancel while the body is likely sleeping.
        try? await Task.sleep(for: .milliseconds(50))
        
        task.cancel()
        
        let result: TemporalResult = await task.value
        
        /// The runner must detect the cancelation at the top of the next
        /// iteration rather than continuing to poll.
        result.assertCanceled()
    }
    
    
    
    func testAlwaysCancelationMidBody() async
    {
        let task = Task
        {
            await TemporalRunner.run(
                kind:       .always,
                timeout:    .milliseconds(500),
                interval:   .milliseconds(10),
                body:
                {
                    try? await Task.sleep(for: .milliseconds(200))
                }
            )
        }
        
        /// Cancel while the body is likely sleeping.
        try? await Task.sleep(for: .milliseconds(50))
        
        task.cancel()
        
        let result: TemporalResult = await task.value
        
        /// The runner must detect the cancelation at the top of the next
        /// iteration rather than continuing to poll.
        result.assertCanceled()
    }
    
    
    
    // MARK: - Nested
    
    func testEventuallyNestedDoesNotLeak() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            let result: TemporalResult = await TemporalRunner.run(
                kind:       .eventually,
                timeout:    .milliseconds(100),
                interval:   .milliseconds(10),
                body:       { FailureInterceptor.current?.recordFailure() }
            )
            
            result.assertFailed()
        }
        
        XCTAssertFalse(outer.didFail)
        XCTAssertTrue(outer.failures.isEmpty)
    }
    
    
    
    func testAlwaysNestedDoesNotLeak() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            let start: ContinuousClock.Instant = .now
            
            let result: TemporalResult = await TemporalRunner.run(
                kind:       .always,
                timeout:    .milliseconds(100),
                interval:   .milliseconds(10),
                body:
                {
                    if start.elapsed >= .milliseconds(50)
                    {
                        FailureInterceptor.current?.recordFailure()
                    }
                }
            )
            
            result.assertFailed()
        }
        
        XCTAssertFalse(outer.didFail)
        XCTAssertTrue(outer.failures.isEmpty)
    }
    
    
    
    func testOuterInterceptorRestoredAfterEventually() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            _ = await TemporalRunner.run(
                kind:       .eventually,
                timeout:    .milliseconds(100),
                interval:   .milliseconds(10),
                body:       { }
            )
            
            XCTAssertIdentical(FailureInterceptor.current, outer)
        }
    }
    
    
    
    func testOuterInterceptorRestoredAfterAlways() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            _ = await TemporalRunner.run(
                kind:       .always,
                timeout:    .milliseconds(100),
                interval:   .milliseconds(10),
                body:       { }
            )
            
            XCTAssertIdentical(FailureInterceptor.current, outer)
        }
    }
    
    
    
    func testNestedTemporalRunnersIdempotency() async
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                /// The inner always-runner fails immediately, but from the
                /// outer eventually-runner's perspective, the body completes
                /// without recording any failures on its interceptor, since
                /// the inner runner uses its own interceptor.
                _ = await TemporalRunner.run(
                    kind:       .always,
                    timeout:    .milliseconds(50),
                    interval:   .milliseconds(10),
                    body:       { FailureInterceptor.current?.recordFailure() }
                )
            }
        )
        
        result.assertPassed()
    }
    
    
    
    func testNestedAlways() async
    {
        let resultOuter: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
            body:
            {
                /// The inner runner always passes, so the outer runner must
                /// see a clean poll.
                let resultInner: TemporalResult = await TemporalRunner.run(
                    kind:       .always,
                    timeout:    .milliseconds(20),
                    interval:   .milliseconds(10),
                    body:       { }
                )
                
                if case .failed = resultInner
                {
                    /// Propagate any failures (must not occur).
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        resultOuter.assertPassed()
    }
    
    
    
    func testNestedEventually() async
    {
        let outerStart: ContinuousClock.Instant = .now
        
        let resultOuter: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                /// The inner runner succeeds immediately, so the outer runner
                /// must see a clean poll.
                let resultInner: TemporalResult = await TemporalRunner.run(
                    kind:       .eventually,
                    timeout:    .milliseconds(50),
                    interval:   .milliseconds(5),
                    body:
                    {
                        if outerStart.elapsed < .milliseconds(50)
                        {
                            FailureInterceptor.current?.recordFailure()
                        }
                    }
                )
                
                if case .failed = resultInner
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        resultOuter.assertPassed()
    }
    
    
    
    func testNestedEventuallyInsideAlways() async throws
    {
        let resultOuter: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(200),
            interval:   .milliseconds(10),
            body:
            {
                /// The inner eventually-runner always times out and propagates
                /// a failure to the outer always-runner, which must fail
                /// immediately.
                let resultInner: TemporalResult = await TemporalRunner.run(
                    kind:       .eventually,
                    timeout:    .milliseconds(20),
                    interval:   .milliseconds(5),
                    body:       { FailureInterceptor.current?.recordFailure() }
                )
                
                if case .failed = resultInner
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(resultOuter.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
    }
    
    
    
    func testNestedAlwaysInsideEventuallyWithInnerFailures() async
    {
        let outerCounter = Counter()
        
        let resultOuter: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                let outerPoll: Int = await outerCounter.increment()
                
                let resultInner: TemporalResult = await TemporalRunner.run(
                    kind:       .always,
                    timeout:    .milliseconds(20),
                    interval:   .milliseconds(5),
                    body:
                    {
                        if outerPoll < 3
                        {
                            /// Fail for the first few outer polls, then pass.
                            FailureInterceptor.current?.recordFailure()
                        }
                    }
                )
                
                if case .failed = resultInner
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        resultOuter.assertPassed()
    }
    
    
    
    // MARK: - Concurrency
    
    func testConcurrentIsolation() async
    {
        /// If interceptor state leaks between tasks, one run's failures
        /// would contaminate the other.
        
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            async let resultA: TemporalResult = TemporalRunner.run(
                kind:       .eventually,
                timeout:    .milliseconds(200),
                interval:   .milliseconds(10),
                body:       { FailureInterceptor.current?.recordFailure() }
            )
            
            async let resultB: TemporalResult = TemporalRunner.run(
                kind:       .always,
                timeout:    .milliseconds(100),
                interval:   .milliseconds(10),
                body:       { }
            )
            
            let (a, b) = await (resultA, resultB)
            
            a.assertFailed()
            b.assertPassed()
        }
    }
    
    
    
    func testManyConcurrentRunners() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            await withTaskGroup(of: TemporalResult.self)
            {
                group in
                
                for index in 0..<10
                {
                    group.addTask
                    {
                        if index % 2 == 0
                        {
                            return await TemporalRunner.run(
                                kind:       .eventually,
                                timeout:    .milliseconds(50),
                                interval:   .milliseconds(5),
                                body:       { }
                            )
                        }
                        else
                        {
                            return await TemporalRunner.run(
                                kind:       .always,
                                timeout:    .milliseconds(50),
                                interval:   .milliseconds(5),
                                body:       { }
                            )
                        }
                    }
                }
                
                for await result in group
                {
                    result.assertPassed()
                }
            }
        }
        
        XCTAssertFalse(outer.didFail)
        XCTAssertTrue(outer.failures.isEmpty)
    }
    
    
    
    // MARK: - Polling
    
    func testEventuallyRequiresAllAssertionsPassInSamePoll() async
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                /// Assertion A passes on odd polls, and B passes on even polls.
                /// They never both pass on the same poll.
                if count % 2 == 0
                {
                    FailureInterceptor.current?.recordFailure(
                        message:    "A",
                        fileID:     "ID",
                        file:       "File.swift",
                        line:       1,
                        column:     1
                    )
                }
                else
                {
                    FailureInterceptor.current?.recordFailure(
                        message:    "B",
                        fileID:     "ID",
                        file:       "File.swift",
                        line:       2,
                        column:     2
                    )
                }
            }
        )
        
        result.assertFailed()
    }
    
    
    
    func testEventuallyPollCount() async
    {
        let counter : Counter   = .init()
        let target  : Int       = 5
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                if count < target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        result.assertPassed()
        
        let finalCount: Int = await counter.value
        
        XCTAssertGreaterThanOrEqual(finalCount, target)
    }
    
    
    
    func testAlwaysPollCount() async
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
            body:       { await counter.increment() }
        )
        
        result.assertPassed()
        
        let finalCount: Int = await counter.value
        
        XCTAssertGreaterThan(finalCount, 1)
    }
    
    
    
    // MARK: - Slow body
    
    func testEventuallyWithSlowBody() async
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                try? await Task.sleep(for: .milliseconds(30))
                
                if count < 3
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        result.assertPassed()
    }
    
    
    
    func testAlwaysWithSlowBody() async throws
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(200),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                try? await Task.sleep(for: .milliseconds(30))
                
                if count >= 4
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
    }
    
    
    
    func testEventuallyWithBodySlowerThanTimeout() async throws
    {
        let timeout: Duration = .milliseconds(30)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    timeout,
            interval:   .milliseconds(10),
            body:
            {
                FailureInterceptor.current?.recordFailure()
                
                /// Body execution exceeds the entire timeout. The runner must
                /// still detect the timeout after the body executes.
                try? await Task.sleep(for: .milliseconds(100))
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertFalse(failed.failures.isEmpty)
    }
    
    
    
    // MARK: - Reset
    
    func testEventuallyResetsFailuresBetweenPolls() async throws
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(100),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                FailureInterceptor.current?.recordFailure(
                    message:    "poll \(count)",
                    fileID:     "ID",
                    file:       "File.swift",
                    line:       1,
                    column:     1
                )
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        /// Only failures from the final poll must be present.
        XCTAssertEqual(failed.failures.count, 1)
        
        let finalCount: Int = await counter.value
        
        /// Multiple polls must have occurred.
        XCTAssertGreaterThan(finalCount, 2)
    }
    
    
    
    // MARK: - Visibility
    
    func testEventuallyBodySeesTemporalInterceptor() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            _ = await TemporalRunner.run(
                kind:       .eventually,
                timeout:    .milliseconds(100),
                interval:   .milliseconds(10),
                body:
                {
                    /// Inside the body, the current interceptor must be the
                    /// temporal interceptor, not the outer one.
                    XCTAssertNotNil(FailureInterceptor.current)
                    XCTAssertNotIdentical(FailureInterceptor.current, outer)
                    
                    XCTAssertTrue(
                        FailureInterceptor.current is TemporalInterceptor
                    )
                }
            )
        }
    }
    
    
    
    func testAlwaysBodySeesTemporalInterceptor() async
    {
        let outer = FailureInterceptor()
        
        await FailureInterceptor.$current.withValue(outer)
        {
            _ = await TemporalRunner.run(
                kind:       .always,
                timeout:    .milliseconds(100),
                interval:   .milliseconds(10),
                body:
                {
                    /// Inside the body, the current interceptor must be the
                    /// temporal interceptor, not the outer one.
                    XCTAssertNotNil(FailureInterceptor.current)
                    XCTAssertNotIdentical(FailureInterceptor.current, outer)
                    
                    XCTAssertTrue(
                        FailureInterceptor.current is TemporalInterceptor
                    )
                }
            )
        }
    }
    
    
    
    // MARK: - Errors
    
    func testEventuallyFailurePreservesError() async throws
    {
        let expected = IdentifiableError(id: 50)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(50),
            interval:   .milliseconds(10),
            body:       { throw expected }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        let actual: IdentifiableError
            = try XCTUnwrap(failed.error as? IdentifiableError)
        
        XCTAssertEqual(expected.id, actual.id)
    }
    
    
    
    func testEventuallyTimeoutPreservesError() async throws
    {
        let expected = IdentifiableError(id: 50)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(50),
            interval:   .milliseconds(10),
            body:
            {
                FailureInterceptor.current?.recordFailure(
                    message:    "hello world",
                    fileID:     "ID",
                    file:       "File.swift",
                    line:       1,
                    column:     1
                )
                
                throw expected
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(failed.failures.count, 1)
        XCTAssertEqual(failed.failures[0].message, "hello world")
        
        let actual: IdentifiableError
            = try XCTUnwrap(failed.error as? IdentifiableError)
        
        XCTAssertEqual(expected.id, actual.id)
    }
    
    
    
    // MARK: - Early termination
    
    func testAlwaysStopsEarlyOnFailure() async throws
    {
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:       { FailureInterceptor.current?.recordFailure() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        XCTAssertLessThan(failed.elapsed, .milliseconds(125))
    }
    
    
    
    func testEventuallyStopsEarlyOnSuccess() async
    {
        let start: ContinuousClock.Instant = .now
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:       { }
        )
        
        result.assertPassed()
        
        XCTAssertLessThan(start.elapsed, .milliseconds(125))
    }
    
    
    
    func testEventuallyStopsOnFirstSuccess() async
    {
        let counter : Counter   = .init()
        let target  : Int       = 2
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                let count: Int = await counter.increment()
                
                if count != target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        result.assertPassed()
        
        let finalCount: Int = await counter.value
        
        XCTAssertEqual(finalCount, target)
    }
    
    
    
    // MARK: - Progression
    
    func testEventuallyPassesAfterErrorFailureSuccess() async
    {
        let start: ContinuousClock.Instant = .now
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                let elapsed: Duration = start.elapsed
                
                if elapsed < .milliseconds(30)
                {
                    throw TestError()
                }
                
                if elapsed < .milliseconds(60)
                {
                    FailureInterceptor.current?.recordFailure()
                    return
                }
                
                /// Passes.
            }
        )
        
        result.assertPassed()
    }
    
    
    
    func testEventuallyPassesWhenErrorClearsBeforeFailure() async
    {
        let start: ContinuousClock.Instant = .now
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                let elapsed: Duration = start.elapsed
                
                if elapsed < .milliseconds(30)
                {
                    throw TestError()
                }
                
                if elapsed < .milliseconds(60)
                {
                    FailureInterceptor.current?.recordFailure()
                }
                
                /// Passes.
            }
        )
        
        result.assertPassed()
    }
    
    
    
    // MARK: - Elapsed accuracy
    
    func testAlwaysElapsedAccuracyOnDelayedFailure() async throws
    {
        let start   : ContinuousClock.Instant   = .now
        let target  : Duration                  = .milliseconds(80)
        let timeout : Duration                  = .milliseconds(500)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    timeout,
            interval:   .milliseconds(10),
            body:
            {
                if start.elapsed >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        /// `elapsed` must be close to `target`, not `timeout`.
        XCTAssertGreaterThanOrEqual(failed.elapsed, target)
        XCTAssertLessThan(failed.elapsed, target + .milliseconds(50))
    }
    
    
    
    func testEventuallyElapsedAccuracy() async throws
    {
        let timeout: Duration = .milliseconds(100)
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    timeout,
            interval:   .milliseconds(10),
            body:       { FailureInterceptor.current?.recordFailure() }
        )
        
        let failed: FailedValues = try XCTUnwrap(result.assertFailed())
        
        /// `elapsed` must be close to `target`.
        XCTAssertGreaterThanOrEqual(failed.elapsed, timeout)
        XCTAssertLessThan(failed.elapsed, timeout + .milliseconds(50))
    }
    
    
    
    // MARK: - Post-resolution
    
    func testEventuallyDoesNotPollAfterSuccess() async
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .eventually,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:       { await counter.increment() }
        )
        
        result.assertPassed()
        
        let countAtSuccess: Int = await counter.value
        
        XCTAssertEqual(countAtSuccess, 1)
        
        try? await Task.sleep(for: .milliseconds(100))
        
        let countAfterSleep: Int = await counter.value
        
        XCTAssertEqual(countAfterSleep, countAtSuccess)
    }
    
    
    
    func testAlwaysDoesNotPollAfterSuccess() async
    {
        let counter = Counter()
        
        let result: TemporalResult = await TemporalRunner.run(
            kind:       .always,
            timeout:    .milliseconds(500),
            interval:   .milliseconds(10),
            body:
            {
                await counter.increment()
                FailureInterceptor.current?.recordFailure()
            }
        )
        
        result.assertFailed()
        
        let countAtFailure: Int = await counter.value
        
        XCTAssertEqual(countAtFailure, 1)
        
        try? await Task.sleep(for: .milliseconds(100))
        
        let countAfterSleep: Int = await counter.value
        
        XCTAssertEqual(countAfterSleep, countAtFailure)
    }
}



// MARK: - Support

extension TemporalRunnerTests
{
    private typealias FailedValues = FailedTemporalValues
    
    
    
    private actor Counter
    {
        private var count: Int = 0
        
        var value: Int
        {
            return count
        }
        
        @discardableResult
        func increment() -> Int
        {
            count += 1
            return count
        }
    }
    
    
    
    struct IdentifiableError: Error
    {
        let id: Int
    }
}
