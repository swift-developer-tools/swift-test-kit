//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TKTestSupport
import XCTest
@testable import TestKitBase
@testable import TestKitCore



internal final class PropertyRunnerTests: XCTestCaseStopOnFail
{
    // MARK: - Passing
    
    func testPassingPropertyReturnsPassed() throws
    {
        let iterations  : Int       = 50
        let seed        : UInt64    = 99
        
        let options: TKOptions = Self.makeOptions(
            iterations:     iterations,
            seed:           seed
        )
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:   { _ in },
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.iterations, iterations)
        XCTAssertEqual(passed.seed, seed)
    }
    
    
    
    func testZeroIterationsReturnsPased() throws
    {
        let iterations: Int = 0
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:   { _ in },
            options:    Self.makeOptions(iterations: iterations)
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    func testSinglePassingIterationReturnsPassed() throws
    {
        let iterations: Int = 1
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:   { _ in },
            options:    Self.makeOptions(iterations: iterations)
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    func testLargeIterationCountCompletes() throws
    {
        let iterations: Int = 1000
        
        let options: TKOptions = Self.makeOptions(
            iterations:     iterations,
            maxSize:        1000
        )
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:   { _ in },
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    // MARK: - Failing
    
    func testFailureOnFirstIteration() throws
    {
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                _ in
                
                PropertyInterceptor.current?.record(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: Self.makeOptions()
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.iteration, 1)
    }
    
    
    
    func testConditionallyFailingPropertyReturnsFailed() throws
    {
        let options: TKOptions = Self.makeOptions(
            iterations:     200,
            maxSize:        50
        )
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value > 25
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        /// The failure should not be on the first iteration, since early
        /// iterations have small sizes and generate small values.
        XCTAssertGreaterThan(counterexample.iteration, 0)
    }
    
    
    
    func testThrowingPropertyReturnsFailed() throws
    {
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:   { _ in throw TestError() },
            options:    Self.makeOptions()
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
        XCTAssertTrue(counterexample.failures.isEmpty)
    }
    
    
    
    func testFailureAndThrowCapturesBoth() throws
    {
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                _ in
                
                PropertyInterceptor.current?.record(
                    message:    "recorded failure",
                    file:       "File.swift",
                    line:       1
                )
                
                throw TestError()
            },
            options: Self.makeOptions()
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
        XCTAssertEqual(counterexample.failures.count, 1)
    }
    
    
    
    func testMultipleFailuresCaptures() throws
    {
        let records: [(String, StaticString, UInt)] =
        [
            ("failure 1", "File1.swift", 1),
            ("failure 2", "File2.swift", 2),
            ("failure 3", "File3.swift", 3)
        ]
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                _ in
                
                for record in records
                {
                    PropertyInterceptor.current?.record(
                        message:    record.0,
                        file:       record.1,
                        line:       record.2
                    )
                }
            },
            options: Self.makeOptions()
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.failures.count, records.count)
        
        for (i, failure) in counterexample.failures.enumerated()
        {
            XCTAssertEqual(failure.message, records[i].0)
            XCTAssertEqual(failure.file.description, records[i].1.description)
            XCTAssertEqual(failure.line, records[i].2)
        }
    }
    
    
    
    func testConditionalThrowWithDifferentThresholdFromFailure() throws
    {
        let target: Int = 10
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
                
                if boundInt.value > target * 2
                {
                    throw TestError()
                }
            },
            options: Self.makeOptions(maxSize: 200)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, BoundInt(value: target + 1))
        XCTAssertNil(counterexample.thrownError)
        XCTAssertEqual(counterexample.failures.count, 1)
    }
    
    
    
    func testIterationPropertyReflectsExactFailurePoint() throws
    {
        let target: Int = 50
        
        let options: TKOptions = Self.makeOptions(
            iterations:         100,
            maxSize:            100
        )
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            property:
            {
                capture in
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<SizeCapture>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.iteration, target + 1)
        XCTAssertEqual(counterexample.value.size, target)
    }
    
    
    
    func testInterceptorIsolationBetweenIterations() throws
    {
        /// If the interceptor from one iteration bled into the next iteration,
        /// the runner would falsely report a failure on the first iteration,
        /// since the first iteration generates a small value that passes the
        /// property. Verify that the failure is reported on a later iteration
        /// and that each iteration uses an independent interceptor.
        
        let target: Int = 50
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions(maxSize: 200)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertGreaterThan(counterexample.iteration, 1)
        XCTAssertEqual(counterexample.value, BoundInt(value: target + 1))
    }
    
    
    
    // MARK: - Exhaustion/Precondition
    
    func testPreconditionAcceptingAllInputsReturnsPassed() throws
    {
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            where:      { _ in true },
            property:   { _ in },
            options:    Self.makeOptions()
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
    }
    
    
    
    func testPreconditionFilteringSomeInputReturnsPassed() throws
    {
        /// A precondition that filters some inputs still passes when
        /// enough inputs exist within the discard ratio. With ``BoundInt``
        /// generating values in the range `0...context.size`, about half
        /// the values are even.
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            where:      { boundInt in boundInt.value % 2 == 0 },
            property:   { _ in },
            options:    Self.makeOptions()
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
    }
    
    
    
    func testPreconditionRejectingAllInputsReturnsExhausted() throws
    {
        let maxDiscardRatio: Int = 2
        
        let options: TKOptions = Self.makeOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio
        )
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            where:      { _ in false },
            property:   { _ in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertGreaterThan(exhausted.discarded, 0)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.defaultSeed)
    }
    
    
    
    func testExhaustionThresholdBasedOnDiscardRatio() throws
    {
        let iterations      : Int   = 10
        let maxDiscardRatio : Int   = 2
        let threshold       : Int   = maxDiscardRatio * iterations
        
        let options: TKOptions = Self.makeOptions(
            iterations:         iterations,
            maxDiscardRatio:    maxDiscardRatio
        )
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            where:      { _ in false },
            property:   { _ in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.discarded, threshold + 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    func testMaxDiscardRatioZeroExhaustsOnFirstDiscard() throws
    {
        let maxDiscardRatio: Int = 0
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            where:      { boundInt in boundInt.value > 1000 },
            property:   { _ in },
            options:    Self.makeOptions(maxDiscardRatio: maxDiscardRatio)
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.discarded, 1)
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    func testConditionalPropertyWithFailingInputsReturnsFailed() throws
    {
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            where: { boundInt in boundInt.value % 2 == 0 },
            property:
            {
                boundInt in
                
                if boundInt.value > 20
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions(maxSize: 200)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        /// The minimal even ``BoundInt`` greater than `20` is `22`, but the
        /// halving shrink stategy converges to `26` since from that point,
        /// the shrink candidates are `[0, 13, 20, 23, 25]`, which is filtered
        /// to `[0, 20]` by the precondition. Both these candidates pass the
        /// property, so the minimal even value is `26`.
        XCTAssertEqual(counterexample.value, BoundInt(value: 26))
    }
    
    
    
    func testExhaustionAfterPartialSuccess() throws
    {
        let target          : Int   = 5
        let maxSize         : Int   = 100
        let iterations      : Int   = 100
        let maxDiscardRatio : Int   = 1
        let threshold       : Int   = maxDiscardRatio * iterations
        
        let options: TKOptions = Self.makeOptions(
            iterations:         iterations,
            maxSize:            maxSize,
            maxDiscardRatio:    maxDiscardRatio
        )
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            where:      { capture in capture.size <= target },
            property:   { _ in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.succeeded, target + 1)
        XCTAssertEqual(exhausted.discarded, threshold + 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    func testSingleIterationWithPreconditionRejectionExhauts() throws
    {
        let maxDiscardRatio: Int = 0
        
        let options: TKOptions = Self.makeOptions(
            iterations:         1,
            maxDiscardRatio:    maxDiscardRatio
        )
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            where:      { _ in false },
            property:   { _ in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    // MARK: - Seed
    
    func testSameSeedDeterminism() throws
    {
        let target: Int = 7
        
        let resultA: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value == target
                {
                    PropertyInterceptor.current?.record(
                        message:    "found target",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions()
        )
        
        let resultB: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value == target
                {
                    PropertyInterceptor.current?.record(
                        message:    "found target",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions()
        )
        
        switch (resultA, resultB)
        {
            case let (.passed(iterA, seedA), .passed(iterB, seedB)):
                
                XCTAssertEqual(iterA, iterB)
                XCTAssertEqual(seedA, seedB)
                
            case let (.failed(counterA), .failed(counterB)):
                
                XCTAssertEqual(counterA.iteration, counterB.iteration)
                XCTAssertEqual(counterA.seed, counterB.seed)
                XCTAssertEqual(counterA.value, counterB.value)
                
            default:
                
                XCTFail("Expected same kind, got \(resultA) and \(resultB)")
        }
    }
    
    
    
    func testRandomSeeds() throws
    {
        for _ in 0..<1000
        {
            let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
                property:   { _ in },
                options:    Self.makeOptions(seed: nil)
            )
            
            let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
            
            XCTAssertNotNil(passed.seed)
        }
    }
    
    
    
    func testDifferentSeedsProduceDifferentSequences() throws
    {
        var valuesA     : [Int]         = []
        var valuesB     : [Int]         = []
        let optionsA    : TKOptions     = Self.makeOptions(seed: 111)
        let optionsB    : TKOptions     = Self.makeOptions(seed: 222)
        
        let resultA: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:   { boundInt in valuesA.append(boundInt.value) },
            options:    optionsA
        )
        
        let resultB: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:   { boundInt in valuesB.append(boundInt.value) },
            options:    optionsB
        )
        
        _ = try XCTUnwrap(Self.assertPassed(resultA))
        _ = try XCTUnwrap(Self.assertPassed(resultB))
        
        XCTAssertEqual(valuesA.count, valuesB.count)
        XCTAssertNotEqual(valuesA, valuesB)
    }
    
    
    
    func testCounterexampleSeedMatchesConfiguredSeed() throws
    {
        let seed: UInt64 = 64
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                _ in
                
                PropertyInterceptor.current?.record(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: Self.makeOptions(seed: seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.seed, seed)
    }
    
    
    
    
    
    func testExhaustionSeedMatchesConfiguredSeed() throws
    {
        let seed            : UInt64    = 64
        let maxDiscardRatio : Int       = 1
        
        let options: TKOptions = Self.makeOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               seed
        )
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            where:      { _ in false },
            property:   { _ in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.seed, seed)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    func testFailureWithNilSeed() throws
    {
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                _ in
                
                PropertyInterceptor.current?.record(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: Self.makeOptions(seed: nil)
        )
        
        _ = try XCTUnwrap(Self.assertFailed(result))
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkingReducesToMinimalCounterexample() throws
    {
        let target: Int = 10
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions(maxSize: 200)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, BoundInt(value: target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testNoShrinkReturnsOriginalValue() throws
    {
        let result: PropertyCheckResult<BoundIntNoShrink>
            = PropertyRunner.run(
                property:
                {
                    boundInt in
                    
                    if boundInt.value > 10
                    {
                        PropertyInterceptor.current?.record(
                            message:    "too large",
                            file:       "File.swift",
                            line:       1
                        )
                    }
                },
                options: Self.makeOptions()
            )
        
        let counterexample: Counterexample<BoundIntNoShrink>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, counterexample.originalValue)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testMaxShrinkStepsLimitsShrinking() throws
    {
        let generator = Generator<Int>(
            generate:   { _ in 1000 },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using: generator,
            property:
            {
                int in
                
                if int > 0
                {
                    PropertyInterceptor.current?.record(
                        message:    "positive",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions(maxShrinkSteps: 3)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        /// The initial value is always `1000`. After three halving steps:
        /// `1000` → `500` (first failing candidate) → `250` → `125`.
        /// `125` is far from the true minimum of `1`, which means shrinking
        /// was truncated.
        XCTAssertLessThanOrEqual(counterexample.shrinkSteps, 3)
        XCTAssertEqual(counterexample.value, 125)
    }
    
    
    
    func testZeroMaxShrinkStepsDisablesShrinking() throws
    {
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value > 5
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions(maxShrinkSteps: 0)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, counterexample.originalValue)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testShrunkCounterexampleCapturesAssertionOutput() throws
    {
        let target: Int = 0
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.record(
                        message:    "value \(boundInt.value) is positive",
                        file:       "File.swift",
                        line:       99
                    )
                }
            },
            options: Self.makeOptions(maxSize: 200)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        let failure: InterceptedFailure
            = try XCTUnwrap(counterexample.failures.first)
        
        XCTAssertEqual(failure.message, "value \(target + 1) is positive")
        XCTAssertEqual(failure.file.description, "File.swift")
        XCTAssertEqual(failure.line, 99)
    }
    
    
    
    func testThrowDuringShrinkingContinuesShrinking() throws
    {
        let target: Int = 10
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value > target
                {
                    throw TestError()
                }
            },
            options: Self.makeOptions(maxSize: 200)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, BoundInt(value: target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
        XCTAssertTrue(counterexample.failures.isEmpty)
    }
    
    
    
    func testShrinkCandidatesAllPassReturnsOriginal() throws
    {
        let target: Int = 50
        
        let generator = Generator<Int>(
            generate:   { _ in target },
            shrink:     { _ in [1, 2, 3] }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using: generator,
            property:
            {
                int in
                
                if int >= target
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions()
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, target)
        XCTAssertEqual(counterexample.originalValue, target)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testMaxShrinkStepsOnePerformsExactlyOneStep() throws
    {
        let generator = Generator<Int>(
            generate:   { _ in 1000 },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using: generator,
            property:
            {
                int in
                
                if int > 0
                {
                    PropertyInterceptor.current?.record(
                        message:    "positive",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions(maxShrinkSteps: 1)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        /// From `1000`, the shrink candidates are `[0, 500, 750,...]`.
        /// The first candidate (`0`) passes, since `0 > 0` is `false`.
        /// The second candidate (`500`) fails. Shrinking stops after one step.
        XCTAssertEqual(counterexample.shrinkSteps, 1)
        XCTAssertEqual(counterexample.value, 500)
    }
    
    
    
    func testSingleFailingIterationReturnsFailed() throws
    {
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                _ in
                
                PropertyInterceptor.current?.record(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: Self.makeOptions(iterations: 1)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.iteration, 1)
        XCTAssertGreaterThan(counterexample.failures.count, 0)
    }
    
    
    
    func testShrinkingSkipsCandidatesFailingPrecondition() throws
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
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using:  generator,
            where:  { $0 >= 20 },
            property:
            {
                int in
                
                if int > 5
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions(iterations: 1)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, 20)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testShrunkenCounterexampleCapturesBothFailureAndThrow() throws
    {
        let target: Int = 10
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.record(
                        message:    "value \(boundInt.value) is too large",
                        file:       "File.swift",
                        line:       1
                    )
                    
                    throw TestError()
                }
            },
            options: Self.makeOptions(maxSize: 200)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, BoundInt(value: target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
        XCTAssertEqual(counterexample.failures.count, 1)
        XCTAssertNotNil(counterexample.failures.first?.message)
        
        XCTAssertEqual(
            counterexample.failures.first?.message,
            "value \(target + 1) is too large"
        )
    }
    
    
    
    func testBrokenShrinkReturningCurrentValueRespectsStepLimit() throws
    {
        let generated       : Int   = 30
        let maxShrinkSteps  : Int   = 10
        
        let generator = Generator<Int>(
            generate:   { _ in generated },
            shrink:     { value in [value] }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using: generator,
            property:
            {
                _ in
                
                PropertyInterceptor.current?.record(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: Self.makeOptions(maxShrinkSteps: maxShrinkSteps)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        /// The value never changes, but each iteration is considered improved
        /// since each candidate still fails. It should stop after exactly
        /// `maxShrinkSteps` steps.
        XCTAssertEqual(counterexample.value, generated)
        XCTAssertEqual(counterexample.shrinkSteps, maxShrinkSteps)
    }
    
    
    
    func testOriginalValueDiffersFromShrunkenValue() throws
    {
        let target: Int = 10
        
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            property:
            {
                boundInt in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.record(
                        message:    "positive",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions(maxSize: 200)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, BoundInt(value: target + 1))
        
        /// The original value should be whatever was first generated at a
        /// size large enough to produce a value `> target`, which is larger
        /// than the shrunken value of `target + 1`.
        XCTAssertGreaterThan(
            counterexample.originalValue.value,
            counterexample.value.value
        )
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testShrinkingWithPreconditionRejectingAllCandidates() throws
    {
        /// The generator always produces `100`. Shrink candidates are
        /// `[0, 50, 75...]`, all of which fail the precondtion `>= 100`.
        /// Since no candidate both satisfies the precondition and fails the
        /// property, shrinking makes no progress.
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using:  generator,
            where:  { int in int >= 100 },
            property:
            {
                _ in
                
                PropertyInterceptor.current?.record(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: Self.makeOptions(iterations: 1)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.originalValue, counterexample.value)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testShrinkingRestartsFromImprovedValue() throws
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
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using: generator,
            property:
            {
                int in
                
                if int > 5
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions()
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        /// `10` is the minimal failing counterexample. The path is
        /// `100` → `60` (first failing candidate) → `20` → `10`. 3 restarts.
        XCTAssertEqual(counterexample.value, 10)
        XCTAssertEqual(counterexample.shrinkSteps, 3)
    }
    
    
    
    // MARK: - Custom generator
    
    func testCustomGeneratorProducesAndShrinks() throws
    {
        let target: Int = 0
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using: generator,
            property:
            {
                int in
                
                if int > target
                {
                    PropertyInterceptor.current?.record(
                        message:    "positive",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions()
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, target + 1)
    }
    
    
    
    func testCustomGeneratorWithoutShrinking() throws
    {
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 50...100) },
            shrink:     { _ in [] }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using: generator,
            property:
            {
                _ in
                
                PropertyInterceptor.current?.record(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: Self.makeOptions()
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, counterexample.originalValue)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testCustomGeneratorWithPreconditionReturnsPassed() throws
    {
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using:      generator,
            where:      { int in int % 2 == 0 },
            property:   { _ in },
            options:    Self.makeOptions()
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
    }
    
    
    
    func testCustomGeneratorWithPreconditionRespectsFilter() throws
    {
        let target: Int = 10
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using:      generator,
            where:      { int in int % 2 == 0 },
            property:
            {
                int in
                
                if int > target
                {
                    PropertyInterceptor.current?.record(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions()
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value % 2, 0)
        XCTAssertGreaterThan(counterexample.value, target)
    }
    
    
    
    func testCustomGeneratorWithPreconditionExhaustion() throws
    {
        let iterations      : Int   = 10
        let maxDiscardRatio : Int   = 2
        let threshold       : Int   = maxDiscardRatio * iterations
        
        let options: TKOptions = Self.makeOptions(
            iterations:         iterations,
            maxDiscardRatio:    maxDiscardRatio
        )
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] }
        )
        
        let result: PropertyCheckResult<Int> = PropertyRunner.run(
            using:      generator,
            where:      { _ in false },
            property:   { _ in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, threshold + 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    // MARK: - Size
    
    func testSizeStartsAtZero() throws
    {
        var firstSize: Int? = nil
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            property:
            {
                capture in
                
                if firstSize == nil
                {
                    firstSize = capture.size
                }
            },
            options: Self.makeOptions()
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertNotNil(firstSize)
        XCTAssertEqual(firstSize, 0)
    }
    
    
    
    func testSizeGrowsAcrossIterations() throws
    {
        var sizes       : [Int]     = []
        let iterations  : Int       = 50
        
        let options: TKOptions = Self.makeOptions(
            iterations:     iterations,
            maxSize:        100
        )
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            property:   { capture in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(sizes.count, iterations)
        
        for index in 1..<sizes.count
        {
            XCTAssertGreaterThanOrEqual(sizes[index], sizes[index - 1])
        }
        
        XCTAssertEqual(sizes.first, 0)
        XCTAssertGreaterThan(sizes.last ?? 0, iterations)
    }
    
    
    
    func testMaxSizeControlsUpperBound() throws
    {
        let maxSize : Int       = 25
        var sizes   : [Int]     = []
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            property:   { capture in sizes.append(capture.size) },
            options:    Self.makeOptions(maxSize: maxSize)
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
        for size in sizes
        {
            XCTAssertLessThanOrEqual(size, maxSize)
        }
    }
    
    
    
    func testMaxSizeZeroKeepsSizeAtZero() throws
    {
        let maxSize : Int       = 0
        var sizes   : [Int]     = []
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            property:   { capture in sizes.append(capture.size) },
            options:    Self.makeOptions(maxSize: maxSize)
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
        for size in sizes
        {
            XCTAssertLessThanOrEqual(size, maxSize)
        }
    }
    
    
    
    func testSizeNeverReachesMaxSize() throws
    {
        let maxSize     : Int       = 100
        let iterations  : Int       = 100
        var sizes       : [Int]     = []
        
        let options: TKOptions = Self.makeOptions(
            iterations:     iterations,
            maxSize:        maxSize
        )
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            property:   { capture in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
        for size in sizes
        {
            XCTAssertLessThan(size, maxSize)
        }
        
        XCTAssertEqual(sizes.last, maxSize - 1)
    }
    
    
    
    func testFailureAtSizeZero() throws
    {
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            property:
            {
                capture in
                
                if capture.size == 0
                {
                    PropertyInterceptor.current?.record(
                        message:    "size zero fails",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: Self.makeOptions()
        )
        
        let counterexample: Counterexample<SizeCapture>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value.size, 0)
        XCTAssertEqual(counterexample.iteration, 1)
        
        /// ``SizeCapture`` does not shrink.
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testSizeStaircaseWhenIterationsExceedMaxSize() throws
    {
        let maxSize     : Int       = 3
        let iterations  : Int       = 10
        var sizes       : [Int]     = []
        
        let options: TKOptions = Self.makeOptions(
            iterations:     iterations,
            maxSize:        maxSize
        )
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            property:   { capture in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
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
    
    
    
    func testSizeJumpsWhenMaxSizeExceedsIterations() throws
    {
        let maxSize     : Int       = 100
        let iterations  : Int       = 5
        var sizes       : [Int]     = []
        
        let options: TKOptions = Self.makeOptions(
            iterations:     iterations,
            maxSize:        maxSize
        )
        
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            property:   { capture in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
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
    
    
    
    func testSizeProgressionUsesSucceededNotIteration() throws
    {
        let maxSize     : Int       = 100
        let iterations  : Int       = 10
        var sizes       : [Int]     = []
        
        let options: TKOptions = Self.makeOptions(
            iterations:         iterations,
            maxSize:            maxSize,
            maxDiscardRatio:    100
        )
        
        /// Discard odd-sized iterations. Since the size formula uses
        /// `succeeded`, not `iteration`, discarded inputs do not advance the
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
        let result: PropertyCheckResult<SizeCapture> = PropertyRunner.run(
            where:
            {
                capture in
                
                sizes.append(capture.size)
                
                return capture.size % 2 == 0
            },
            property:   { _ in },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
        let acceptedSizes: [Int] = sizes.filter { $0 % 2 == 0 }
        
        XCTAssertEqual(acceptedSizes.count, iterations)
        
        /// Size formula: `succeeded * maxSize / iterations`
        /// Expected: `[0, 10, 20, 30, 40, 50, 60, 70, 80, 90]`
        /// The size grows based on `succeeded`, not `iteration`.
        let expected: [Int]
            = (0..<iterations).map { $0 * maxSize / iterations }
        
        XCTAssertEqual(acceptedSizes, expected)
    }
    
    
    
    func testSizeProgressionWithGenuineDiscards() throws
    {
        let maxSize     : Int       = 100
        let iterations  : Int       = 10
        var accepted    : [Int]     = []
        
        let options: TKOptions = Self.makeOptions(
            iterations:         iterations,
            maxSize:            maxSize,
            maxDiscardRatio:    100
        )
        
        /// The precondition rejects odd values. Since ``BoundInt`` generates
        /// values in the range `0...context.size`, half the values are odd
        /// and discarded.
        ///
        /// Discards do not advance `succeeded`, so the size formula
        /// `succeeded * maxSize / iterations` should produce the same
        /// progression regardless of how many discards occur.
        let result: PropertyCheckResult<BoundInt> = PropertyRunner.run(
            where:      { boundInt in  boundInt.value % 2 == 0 },
            property:   { _ in accepted.append(accepted.count) },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(accepted.count, iterations)
    }
}



// MARK: - Extensions

extension PropertyRunnerTests
{
    /// A wrapper around `Int` that provides controllable shrinking.
    ///
    /// This is different from `Int: Arbitrary` since `Int.arbitrary(using:)`
    /// generates values in the range `-context.size...context.size`, which
    /// makes it harder to reason about value distributions in tests. This
    /// wrapper always generates values in the range `0...context.size`.
    private struct BoundInt: Arbitrary, Equatable, CustomStringConvertible
    {
        let value: Int
        
        var description: String
        {
            return "BoundInt - \(value)"
        }
        
        static func arbitrary(
            using context: GenerationContext
        ) -> BoundInt
        {
            return BoundInt(value:
                context.random(in: 0...max(1, context.size))
            )
        }
        
        func shrink() -> [BoundInt]
        {
            return value.shrinkTowardZero().map { BoundInt(value: $0) }
        }
    }
    
    
    
    /// A wrapper around `Int` that does not shrink.
    ///
    /// See ``BoundInt`` for more information regarding the range of values.
    private struct BoundIntNoShrink:
        Arbitrary, Equatable, CustomStringConvertible
    {
        let value: Int
        
        var description: String
        {
            return "BoundIntNoShrink - \(value)"
        }
        
        static func arbitrary(
            using context: GenerationContext
        ) -> BoundIntNoShrink
        {
            return BoundIntNoShrink(value:
                context.random(in: 0...max(1, context.size))
            )
        }
    }
    
    
    
    /// Captures the generation size directly for testing size progression.
    private struct SizeCapture: Arbitrary, Equatable
    {
        let size: Int
        
        static func arbitrary(
            using context: GenerationContext
        ) -> SizeCapture
        {
            return SizeCapture(size: context.size)
        }
    }
    
    
    
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let defaultSeed: UInt64 = 12345
    
    
    
    /// Initializes a ``TKOptions`` instance, optionally specifying values
    /// for its property-based testing options property.
    private static func makeOptions(
        iterations      : Int       = 100,
        maxShrinkSteps  : Int       = 100,
        maxSize         : Int       = 100,
        maxDiscardRatio : Int       = 10,
        seed            : UInt64?   = defaultSeed
    ) -> TKOptions
    {
        let propertyOptions = TKPropertyOptions(
            iterations:         iterations,
            maxShrinkSteps:     maxShrinkSteps,
            maxSize:            maxSize,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               seed
        )
        
        return TKOptions(propertyOptions: propertyOptions)
    }
    
    
    
    /// The associated values of a passed ``PropertyCheckResult``.
    private struct PassedValues
    {
        let iterations  : Int
        let seed        : UInt64
    }
    
    
    
    /// Asserts that the given property check result passed, and returns the
    /// associated values.
    /// - Parameter result: The property check result to evaluate.
    /// - Returns: The associated values of the passed result, or `nil` if
    /// the result did not pass.
    @discardableResult
    private static func assertPassed<T>(
        _ result: PropertyCheckResult<T>
    ) -> PassedValues?
    {
        guard case let .passed(iterations, seed) = result
        else
        {
            XCTFail("Expected .passed, got \(result)")
            return nil
        }
        
        return PassedValues(
            iterations:     iterations,
            seed:           seed
        )
    }
    
    
    
    /// Asserts that the given property check result failed, and returns the
    /// counterexample.
    /// - Parameter result: The property check result to evaluate.
    /// - Returns: The counterexample of the failed result, `nil` if the
    /// result did not fail.
    @discardableResult
    private static func assertFailed<T>(
        _ result: PropertyCheckResult<T>
    ) -> Counterexample<T>?
    {
        guard case let .failed(counterexample) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return nil
        }
        
        return counterexample
    }
    
    
    
    /// The associated values of an exhausted ``PropertyCheckResult``.
    private struct ExhaustedValues
    {
        let discarded   : Int
        let succeeded   : Int
        let ratio       : Int
        let seed        : UInt64
    }
    
    
    
    /// Asserts that the given property check result failed, and returns the
    /// counterexample.
    /// - Parameter result: The property check result to evaluate.
    /// - Returns: The counterexample of the failed result, `nil` if the
    /// result did not fail.
    @discardableResult
    private static func assertExhausted<T>(
        _ result: PropertyCheckResult<T>
    ) -> ExhaustedValues?
    {
        guard case let .exhausted(discarded, succeeded, ratio, seed) = result
        else
        {
            XCTFail("Expected .exhausted, got \(result)")
            return nil
        }
        
        return ExhaustedValues(
            discarded:  discarded,
            succeeded:  succeeded,
            ratio:      ratio,
            seed:       seed
        )
    }
}
