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



internal final class PropertyRunnerTests: TestKitCase
{
    // MARK: - Passing
    
    @Reasync
    func testPassingPropertyReturnsPassed() async throws
    {
        let iterations  : Int       = 50
        let seed        : UInt64    = 99
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    options
            )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
        XCTAssertEqual(passed.seed, seed)
    }
    
    
    
    @Reasync
    func testZeroIterationsReturnsPassed() async throws
    {
        let iterations: Int = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    options
            )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    @Reasync
    func testSinglePassingIterationReturnsPassed() async throws
    {
        let iterations: Int = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    options
            )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    @Reasync
    func testLargeIterationCountCompletes() async throws
    {
        let iterations: Int = 1000
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        1000,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    options
            )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    // MARK: - Failing
    
    @Reasync
    func testFailureOnFirstIteration() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.iteration, 1)
    }
    
    
    
    @Reasync
    func testConditionallyFailingPropertyReturnsFailed() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     200,
            maxSize:        50,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > 25
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        /// The failure should not be on the first iteration, since early
        /// iterations have small sizes and generate small values.
        XCTAssertGreaterThan(counterexample.iteration, 0)
    }
    
    
    
    @Reasync
    func testThrowingPropertyReturnsFailed() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:   { _ async throws in throw TestError() },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertNotNil(counterexample.error)
        XCTAssertTrue(counterexample.error is TestError)
        XCTAssertTrue(counterexample.failures.isEmpty)
    }
    
    
    
    @Reasync
    func testFailureAndThrowCapturesBoth() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                FailureInterceptor.current?.recordFailure()
                
                throw TestError()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertNotNil(counterexample.error)
        XCTAssertTrue(counterexample.error is TestError)
        XCTAssertEqual(counterexample.failures.count, 1)
    }
    
    
    
    @Reasync
    func testMultipleFailuresCaptures() async throws
    {
        let records: [(String, StaticString, StaticString, UInt, UInt)] =
        [
            ("Message1", "ID1", "1.swift", 1, 10),
            ("Message2", "ID2", "2.swift", 2, 20),
            ("Message3", "ID3", "3.swift", 3, 30)
        ]
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                for record in records
                {
                    FailureInterceptor.current?.recordFailure(
                        message:    record.0,
                        fileID:     record.1,
                        file:       record.2,
                        line:       record.3,
                        column:     record.4
                    )
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.failures.count, records.count)
        
        for (i, failure) in counterexample.failures.enumerated()
        {
            XCTAssertEqual(failure.message, records[i].0)
            XCTAssertEqual(failure.fileID.description, records[i].1.description)
            XCTAssertEqual(failure.file.description, records[i].2.description)
            XCTAssertEqual(failure.line, records[i].3)
            XCTAssertEqual(failure.column, records[i].4)
        }
    }
    
    
    
    @Reasync
    func testConditionalThrowWithDifferentThresholdFromFailure() async throws
    {
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async throws in
                
                if boundInt.value > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
                
                if boundInt.value > target * 2
                {
                    throw TestError()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        XCTAssertNil(counterexample.error)
        XCTAssertEqual(counterexample.failures.count, 1)
    }
    
    
    
    @Reasync
    func testIterationPropertyReflectsExactFailurePoint() async throws
    {
        let target: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                if capture.size >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<SizeCapture>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.iteration, target + 1)
        XCTAssertEqual(counterexample.value.size, target)
    }
    
    
    
    @Reasync
    func testInterceptorIsolationBetweenIterations() async throws
    {
        /// If the interceptor from one iteration bled into the next iteration,
        /// the runner would falsely report a failure on the first iteration,
        /// since the first iteration generates a small value that passes the
        /// property. Verify that the failure is reported on a later iteration
        /// and that each iteration uses an independent interceptor.
        
        let target: Int = 50
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertGreaterThan(counterexample.iteration, 1)
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
    }
    
    
    
    // MARK: - Exhaustion/Precondition
    
    @Reasync
    func testPreconditionAcceptingAllValuesReturnsPassed() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            where:      { _ in true },
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    @Reasync
    func testPreconditionFilteringSomeValueReturnsPassed() async throws
    {
        /// A precondition that filters some values still passes when
        /// enough values exist within the discard ratio. With ``BoundInt``
        /// generating values in the range `0...context.size`, about half
        /// the values are even.
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            where:      { boundInt in boundInt.value % 2 == 0 },
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    @Reasync
    func testPreconditionRejectingAllValuesReturnsExhausted() async throws
    {
        let maxDiscardRatio: Int = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertGreaterThan(exhausted.discarded, 0)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
        XCTAssertEqual(exhausted.dist, [:])
    }
    
    
    
    @Reasync
    func testExhaustionThresholdBasedOnDiscardRatio() async throws
    {
        let iterations      : Int   = 10
        let maxDiscardRatio : Int   = 2
        let threshold       : Int   = maxDiscardRatio * iterations
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, threshold + 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
        XCTAssertEqual(exhausted.dist, [:])
    }
    
    
    
    @Reasync
    func testMaxDiscardRatioZeroExhaustsOnFirstDiscard() async throws
    {
        let maxDiscardRatio: Int = 0
        
        let options: TestOptions = .propertyOptions(
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            where:      { boundInt in boundInt.value > 1000 },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
        XCTAssertEqual(exhausted.dist, [:])
    }
    
    
    
    @Reasync
    func testConditionalPropertyWithFailingValuesReturnsFailed() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            where: { boundInt in boundInt.value % 2 == 0 },
            property:
            {
                boundInt async in
                
                if boundInt.value > 20
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        /// The minimal even ``BoundInt`` greater than `20` is `22`, but the
        /// halving shrink stategy converges to `26` since from that point,
        /// the shrink candidates are `[0, 13, 20, 23, 25]`, which is filtered
        /// to `[0, 20]` by the precondition. Both these candidates pass the
        /// property, so the minimal even value is `26`.
        XCTAssertEqual(counterexample.value, BoundInt(26))
    }
    
    
    
    @Reasync
    func testExhaustionAfterPartialSuccess() async throws
    {
        let target          : Int   = 5
        let maxSize         : Int   = 100
        let iterations      : Int   = 100
        let maxDiscardRatio : Int   = 1
        let threshold       : Int   = maxDiscardRatio * iterations
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxSize:            maxSize,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            where:      { capture in capture.size <= target },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, target + 1)
        XCTAssertEqual(exhausted.discarded, threshold + 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
        XCTAssertEqual(exhausted.dist, [:])
    }
    
    
    
    @Reasync
    func testSingleIterationWithPreconditionRejectionExhauts() async throws
    {
        let maxDiscardRatio: Int = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
        XCTAssertEqual(exhausted.dist, [:])
    }
    
    
    
    // MARK: - Seed
    
    @Reasync
    func testSameSeedDeterminism() async
    {
        let target  : Int           = 7
        let options : TestOptions   = .propertyOptions(seed: Self.seed)
        
        let resultA: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value == target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let resultB: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value == target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        switch (resultA, resultB)
        {
            case let (
                .passed(iterA, seedA, _, _),
                .passed(iterB, seedB, _, _)
            ):
                
                XCTAssertEqual(iterA, iterB)
                XCTAssertEqual(seedA, seedB)
                
            case let (
                .failed(counterA, _, _),
                .failed(counterB, _, _)
            ):
                
                XCTAssertEqual(counterA.iteration, counterB.iteration)
                XCTAssertEqual(counterA.seed, counterB.seed)
                XCTAssertEqual(counterA.value, counterB.value)
                
            default:
                
                XCTFail("Expected same kind, got \(resultA) and \(resultB)")
        }
    }
    
    
    
    @Reasync
    func testRandomSeeds() async throws
    {
        for _ in 0..<1000
        {
            let result: PropertyResult<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    .propertyOptions(seed: nil)
            )
            
            let passed: PassedValues = try XCTUnwrap(result.assertPassed())
            
            XCTAssertNotNil(passed.seed)
        }
    }
    
    
    
    @Reasync
    func testDifferentSeedsProduceDifferentSequences() async throws
    {
        var valuesA     : [Int]         = []
        var valuesB     : [Int]         = []
        let optionsA    : TestOptions   = .propertyOptions(seed: 111)
        let optionsB    : TestOptions   = .propertyOptions(seed: 222)
        
        let resultA: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:   { boundInt async in valuesA.append(boundInt.value) },
            options:    optionsA
        )
        
        let resultB: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:   { boundInt async in valuesB.append(boundInt.value) },
            options:    optionsB
        )
        
        _ = try XCTUnwrap(resultA.assertPassed())
        _ = try XCTUnwrap(resultB.assertPassed())
        
        XCTAssertEqual(valuesA.count, valuesB.count)
        XCTAssertNotEqual(valuesA, valuesB)
    }
    
    
    
    @Reasync
    func testCounterexampleSeedMatchesConfiguredSeed() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.seed, Self.seed)
    }
    
    
    
    @Reasync
    func testExhaustionSeedMatchesConfiguredSeed() async throws
    {
        let maxDiscardRatio: Int = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.seed, Self.seed)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    @Reasync
    func testFailureWithNilSeed() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: nil)
        )
        
        _ = try XCTUnwrap(result.assertFailed())
    }
    
    
    
    // MARK: - Shrinking
    
    @Reasync
    func testShrinkingReducesToMinimalCounterexample() async throws
    {
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testNoShrinkReturnsOriginalValue() async throws
    {
        let result: PropertyResult<BoundIntNoShrink>
            = await PropertyRunner.run(
                property:
                {
                    boundInt async in
                    
                    if boundInt.value > 10
                    {
                        FailureInterceptor.current?.recordFailure()
                    }
                },
                options: .propertyOptions(seed: Self.seed)
            )
        
        let counterexample: Counterexample<BoundIntNoShrink>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, counterexample.originalValue)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testMaxShrinkStepsLimitsShrinking() async throws
    {
        let generator = Generator<Int>(
            generate:   { _ in 1000 },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     3,
            seed:               Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int > 0
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        /// The initial value is always `1000`. After three halving steps:
        /// `1000` → `500` (first failing candidate) → `250` → `125`.
        /// `125` is far from the true minimum of `1`, which means shrinking
        /// was truncated.
        XCTAssertLessThanOrEqual(counterexample.shrinkSteps, 3)
        XCTAssertEqual(counterexample.value, 125)
    }
    
    
    
    @Reasync
    func testZeroMaxShrinkStepsDisablesShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            seed:               Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > 5
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, counterexample.originalValue)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testShrunkCounterexampleCapturesAssertionOutput() async throws
    {
        let target: Int = 0
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > target
                {
                    FailureInterceptor.current?.recordFailure(
                        message:    "value \(boundInt.value) is positive",
                        fileID:     "ID",
                        file:       "File.swift",
                        line:       99,
                        column:     77
                    )
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        let failure: InterceptedFailure
            = try XCTUnwrap(counterexample.failures.first)
        
        XCTAssertEqual(failure.message, "value \(target + 1) is positive")
        XCTAssertEqual(failure.fileID.description, "ID")
        XCTAssertEqual(failure.file.description, "File.swift")
        XCTAssertEqual(failure.line, 99)
        XCTAssertEqual(failure.column, 77)
    }
    
    
    
    @Reasync
    func testThrowDuringShrinkingContinuesShrinking() async throws
    {
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async throws in
                
                if boundInt.value > target
                {
                    throw TestError()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        XCTAssertNotNil(counterexample.error)
        XCTAssertTrue(counterexample.error is TestError)
        XCTAssertTrue(counterexample.failures.isEmpty)
    }
    
    
    
    @Reasync
    func testShrinkCandidatesAllPassReturnsOriginal() async throws
    {
        let target: Int = 50
        
        let generator = Generator<Int>(
            generate:   { _ in target },
            shrink:     { _ in [1, 2, 3] }
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, target)
        XCTAssertEqual(counterexample.originalValue, target)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testMaxShrinkStepsOnePerformsExactlyOneStep() async throws
    {
        let generator = Generator<Int>(
            generate:   { _ in 1000 },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     1,
            seed:               Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int > 0
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        /// From `1000`, the shrink candidates are `[0, 500, 750,...]`.
        /// The first candidate (`0`) passes, since `0 > 0` is `false`.
        /// The second candidate (`500`) fails. Shrinking stops after one step.
        XCTAssertEqual(counterexample.shrinkSteps, 1)
        XCTAssertEqual(counterexample.value, 500)
    }
    
    
    
    @Reasync
    func testSingleFailingIterationReturnsFailed() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.iteration, 1)
        XCTAssertGreaterThan(counterexample.failures.count, 0)
    }
    
    
    
    @Reasync
    func testShrinkingSkipsCandidatesFailingPrecondition() async throws
    {
        /// The generator always produces `100`. Shrink candidates are a fixed
        /// descending list, filtered to values less than the current value.
        ///
        /// The precondition of `value >= 20` excludes `10` from the shrink
        /// candidates. Without precondition filtering, the minimal failing
        /// value would be `10`. With filtering, it is `20`.
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in [50, 30, 20, 10].filter { $0 < value }}
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using:  generator,
            where:  { $0 >= 20 },
            property:
            {
                int async in
                
                if int > 5
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, 20)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testShrunkenCounterexampleCapturesBothFailureAndThrow() async throws
    {
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async throws in
                
                if boundInt.value > target
                {
                    FailureInterceptor.current?.recordFailure(
                        message:    "value \(boundInt.value) is too large",
                        fileID:     "ID",
                        file:       "File.swift",
                        line:       1,
                        column:     2
                    )
                    
                    throw TestError()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        XCTAssertNotNil(counterexample.error)
        XCTAssertTrue(counterexample.error is TestError)
        XCTAssertEqual(counterexample.failures.count, 1)
        XCTAssertNotNil(counterexample.failures.first?.message)
        
        XCTAssertEqual(
            counterexample.failures.first?.message,
            "value \(target + 1) is too large"
        )
    }
    
    
    
    @Reasync
    func testBrokenShrinkReturningCurrentValueRespectsStepLimit() async throws
    {
        let generated       : Int   = 30
        let maxShrinkSteps  : Int   = 10
        
        let generator = Generator<Int>(
            generate:   { _ in generated },
            shrink:     { value in [value] }
        )
        
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     maxShrinkSteps,
            seed:               Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        /// The value never changes, but each iteration is considered improved
        /// since each candidate still fails. It should stop after exactly
        /// `maxShrinkSteps` steps.
        XCTAssertEqual(counterexample.value, generated)
        XCTAssertEqual(counterexample.shrinkSteps, maxShrinkSteps)
    }
    
    
    
    @Reasync
    func testOriginalValueDiffersFromShrunkenValue() async throws
    {
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        
        /// The original value should be whatever was first generated at a
        /// size large enough to produce a value `> target`, which is larger
        /// than the shrunken value of `target + 1`.
        XCTAssertGreaterThan(
            counterexample.originalValue.value,
            counterexample.value.value
        )
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testShrinkingWithPreconditionRejectingAllCandidates() async throws
    {
        /// The generator always produces `100`. Shrink candidates are
        /// `[0, 50, 75...]`, all of which fail the precondtion `>= 100`.
        /// Since no candidate both satisfies the precondition and fails the
        /// property, shrinking makes no progress.
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using:  generator,
            where:  { int in int >= 100 },
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.originalValue, counterexample.value)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testShrinkingRestartsFromImprovedValue() async throws
    {
        /// A generator with a controlled shrink tree that requires multiple
        /// restarts to reach the minimum. If the process restarts correctly,
        /// the path is `100` → `60` (first failing candidate) → `20` → `10`.
        /// If the process continues with stale candidates instead of
        /// restarting, it would try `80` and `60`, missing the shorter path.
        let generator = Generator<Int>(
            generate: { _ in 100 },
            shrink:
            {
                value in
                
                switch value
                {
                    case 100    : return [60, 80]
                    case 80     : return [40, 60]
                    case 60     : return [20, 40]
                    case 40     : return [20]
                    case 20     : return [10]
                    default     : return []
                }
            }
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int > 5
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        /// `10` is the minimal failing counterexample. The path is
        /// `100` → `60` (first failing candidate) → `20` → `10`. 3 restarts.
        XCTAssertEqual(counterexample.value, 10)
        XCTAssertEqual(counterexample.shrinkSteps, 3)
    }
    
    
    
    // MARK: - Custom generator
    
    @Reasync
    func testCustomGeneratorProducesAndShrinks() async throws
    {
        let target: Int = 0
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, target + 1)
    }
    
    
    
    @Reasync
    func testCustomGeneratorWithoutShrinking() async throws
    {
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 50...100) },
            shrink:     { _ in [] }
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, counterexample.originalValue)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testCustomGeneratorWithPreconditionReturnsPassed() async throws
    {
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using:      generator,
            where:      { int in int % 2 == 0 },
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    @Reasync
    func testCustomGeneratorWithPreconditionRespectsFilter() async throws
    {
        let target: Int = 10
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using:      generator,
            where:      { int in int % 2 == 0 },
            property:
            {
                int async in
                
                if int > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value % 2, 0)
        XCTAssertGreaterThan(counterexample.value, target)
    }
    
    
    
    @Reasync
    func testCustomGeneratorWithPreconditionExhaustion() async throws
    {
        let iterations      : Int   = 10
        let maxDiscardRatio : Int   = 2
        let threshold       : Int   = maxDiscardRatio * iterations
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] }
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using:      generator,
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, threshold + 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    // MARK: - Size
    
    @Reasync
    func testSizeStartsAtZero() async throws
    {
        var firstSize: Int? = nil
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                if firstSize == nil
                {
                    firstSize = capture.size
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        _ = try XCTUnwrap(result.assertPassed())
        
        XCTAssertNotNil(firstSize)
        XCTAssertEqual(firstSize, 0)
    }
    
    
    
    @Reasync
    func testSizeGrowsAcrossIterations() async throws
    {
        var sizes       : [Int]     = []
        let iterations  : Int       = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(sizes.count, iterations)
        
        for index in 1..<sizes.count
        {
            XCTAssertGreaterThanOrEqual(sizes[index], sizes[index - 1])
        }
        
        XCTAssertEqual(sizes.first, 0)
        XCTAssertGreaterThan(sizes.last ?? 0, iterations)
    }
    
    
    
    @Reasync
    func testMaxSizeControlsUpperBound() async throws
    {
        let maxSize : Int       = 25
        var sizes   : [Int]     = []
        
        let options: TestOptions = .propertyOptions(
            maxSize:    maxSize,
            seed:       Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
        
        for size in sizes
        {
            XCTAssertLessThanOrEqual(size, maxSize)
        }
    }
    
    
    
    @Reasync
    func testMaxSizeZeroKeepsSizeAtZero() async throws
    {
        let maxSize : Int       = 0
        var sizes   : [Int]     = []
        
        let options: TestOptions = .propertyOptions(
            maxSize:    maxSize,
            seed:       Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
        
        for size in sizes
        {
            XCTAssertLessThanOrEqual(size, maxSize)
        }
    }
    
    
    
    @Reasync
    func testSizeNeverReachesMaxSize() async throws
    {
        let maxSize     : Int       = 100
        let iterations  : Int       = 100
        var sizes       : [Int]     = []
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        maxSize,
            seed:           Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
        
        for size in sizes
        {
            XCTAssertLessThan(size, maxSize)
        }
        
        XCTAssertEqual(sizes.last, maxSize - 1)
    }
    
    
    
    @Reasync
    func testFailureAtSizeZero() async throws
    {
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                if capture.size == 0
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<SizeCapture>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.size, 0)
        XCTAssertEqual(counterexample.iteration, 1)
        
        /// ``SizeCapture`` does not shrink.
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testSizeStaircaseWhenIterationsExceedMaxSize() async throws
    {
        let maxSize     : Int       = 3
        let iterations  : Int       = 10
        var sizes       : [Int]     = []
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        maxSize,
            seed:           Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
        
        /// Size formula: `succeeded * maxSize / iterations`
        /// Expected: `[0, 0, 0, 0, 1, 1, 1, 2, 2, 2]`
        /// Integer division truncation causes multiple iterations to share
        /// the same size.
        let expected: [Int]
            = (0..<iterations).map { $0 * maxSize / iterations }
        
        XCTAssertEqual(sizes, expected)
        
        XCTAssertTrue(
            zip(sizes, sizes.dropFirst()).contains(where: { $0 == $1 })
        )
    }
    
    
    
    @Reasync
    func testSizeJumpsWhenMaxSizeExceedsIterations() async throws
    {
        let maxSize     : Int       = 100
        let iterations  : Int       = 5
        var sizes       : [Int]     = []
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        maxSize,
            seed:           Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
        
        /// Size formula: `succeeded * maxSize / iterations`
        /// Expected: `[0, 20, 40, 60, 80]`
        /// The size jumps by `20` between successive iterations.
        let expected: [Int]
            = (0..<iterations).map { $0 * maxSize / iterations }
        
        XCTAssertEqual(sizes, expected)
        
        XCTAssertTrue(
            zip(sizes, sizes.dropFirst()).contains(where: { $1 - $0 > 1 })
        )
    }
    
    
    
    @Reasync
    func testSizeProgressionUsesSucceededNotIteration() async throws
    {
        let maxSize     : Int       = 100
        let iterations  : Int       = 10
        var sizes       : [Int]     = []
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxSize:            maxSize,
            maxDiscardRatio:    100,
            seed:               Self.seed
        )
        
        /// Discard odd-sized iterations. Since the size formula uses
        /// `succeeded`, not `iteration`, discarded values do not advance the
        /// size. The expected progression is:
        ///
        /// - Iteration 1: `size = 0 * 100 / 10` → `0` → accepted
        /// - Iteration 1: `size = 1 * 100 / 10` → `10` → accepted
        /// - Iteration 1: `size = 2 * 100 / 10` → `20` → accepted
        /// ...
        ///
        /// Since `size` is always a multiple of 10, all sizes are even, and
        /// none are discarded. Use ``SizeCapture`` to observe any discards,
        /// and reject specific sizes that the formula were produced if
        /// `iteration` were used incorrectly.
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            where:
            {
                capture in
                
                sizes.append(capture.size)
                
                return capture.size % 2 == 0
            },
            property:   { _ async in },
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
        
        let acceptedSizes: [Int] = sizes.filter { $0 % 2 == 0 }
        
        XCTAssertEqual(acceptedSizes.count, iterations)
        
        /// Size formula: `succeeded * maxSize / iterations`
        /// Expected: `[0, 10, 20, 30, 40, 50, 60, 70, 80, 90]`
        /// The size grows based on `succeeded`, not `iteration`.
        let expected: [Int]
            = (0..<iterations).map { $0 * maxSize / iterations }
        
        XCTAssertEqual(acceptedSizes, expected)
    }
    
    
    
    @Reasync
    func testSizeProgressionWithGenuineDiscards() async throws
    {
        let maxSize     : Int       = 100
        let iterations  : Int       = 10
        var accepted    : [Int]     = []
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxSize:            maxSize,
            maxDiscardRatio:    100,
            seed:               Self.seed
        )
        
        /// The precondition rejects odd values. Since ``BoundInt`` generates
        /// values in the range `0...context.size`, half the values are odd
        /// and discarded.
        ///
        /// Discards do not advance `succeeded`, so the size formula
        /// `succeeded * maxSize / iterations` should produce the same
        /// progression regardless of how many discards occur.
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            where:      { boundInt in  boundInt.value % 2 == 0 },
            property:   { _ async in accepted.append(accepted.count) },
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(accepted.count, iterations)
    }
}



// MARK: - Support

extension PropertyRunnerTests
{
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 12345
}
