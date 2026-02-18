//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKit
import XCTest
@testable import TestKitCore



internal final class PropertyRunnerTests: XCTestCaseStopOnFail
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    options
            )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    options
            )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    options
            )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    options
            )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    // MARK: - Failing
    
    @Reasync
    func testFailureOnFirstIteration() async throws
    {
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordFailure(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > 25
                {
                    PropertyInterceptor.current?.recordFailure(
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
    
    
    
    @Reasync
    func testThrowingPropertyReturnsFailed() async throws
    {
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:   { _ async throws in throw TestError() },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
        XCTAssertTrue(counterexample.failures.isEmpty)
    }
    
    
    
    @Reasync
    func testFailureAndThrowCapturesBoth() async throws
    {
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                PropertyInterceptor.current?.recordFailure(
                    message:    "recorded failure",
                    file:       "File.swift",
                    line:       1
                )
                
                throw TestError()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
        XCTAssertEqual(counterexample.failures.count, 1)
    }
    
    
    
    @Reasync
    func testMultipleFailuresCaptures() async throws
    {
        let records: [(String, StaticString, UInt)] =
        [
            ("failure 1", "File1.swift", 1),
            ("failure 2", "File2.swift", 2),
            ("failure 3", "File3.swift", 3)
        ]
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                for record in records
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    record.0,
                        file:       record.1,
                        line:       record.2
                    )
                }
            },
            options: .propertyOptions(seed: Self.seed)
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
    
    
    
    @Reasync
    func testConditionalThrowWithDifferentThresholdFromFailure() async throws
    {
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async throws in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.recordFailure(
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
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        XCTAssertNil(counterexample.thrownError)
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
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.recordFailure(
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.recordFailure(
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
        
        XCTAssertGreaterThan(counterexample.iteration, 1)
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
    }
    
    
    
    // MARK: - Exhaustion/Precondition
    
    @Reasync
    func testPreconditionAcceptingAllInputsReturnsPassed() async throws
    {
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where:      { _ in true },
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
    }
    
    
    
    @Reasync
    func testPreconditionFilteringSomeInputReturnsPassed() async throws
    {
        /// A precondition that filters some inputs still passes when
        /// enough inputs exist within the discard ratio. With ``BoundInt``
        /// generating values in the range `0...context.size`, about half
        /// the values are even.
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where:      { boundInt in boundInt.value % 2 == 0 },
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
    }
    
    
    
    @Reasync
    func testPreconditionRejectingAllInputsReturnsExhausted() async throws
    {
        let maxDiscardRatio: Int = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where:      { boundInt in boundInt.value > 1000 },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
        XCTAssertEqual(exhausted.dist, [:])
    }
    
    
    
    @Reasync
    func testConditionalPropertyWithFailingInputsReturnsFailed() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where: { boundInt in boundInt.value % 2 == 0 },
            property:
            {
                boundInt async in
                
                if boundInt.value > 20
                {
                    PropertyInterceptor.current?.recordFailure(
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
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            where:      { capture in capture.size <= target },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
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
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
        XCTAssertEqual(exhausted.dist, [:])
    }
    
    
    
    // MARK: - Classification
    
    @Reasync
    func testPassedResultIncludesDistribution() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordLabel("always")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["always"], iterations)
    }
    
    
    
    @Reasync
    func testPassedResultWithMultipleLabelsPerIteration() async throws
    {
        let target      : Int   = 50
        let iterations  : Int   = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                PropertyInterceptor.current?.recordLabel("all")
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.recordLabel("large")
                }
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["all"], iterations)
        XCTAssertEqual(passed.dist["large"], target)
    }
    
    
    
    @Reasync
    func testPassedResultWithNoLabelsHasEmptyDist() async throws
    {
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertTrue(passed.dist.isEmpty)
    }
    
    
    
    @Reasync
    func testFailureOnFirstIterationHasEmptyDist() async
    {
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordLabel("labeled")
                
                PropertyInterceptor.current?.recordFailure(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        guard case let .failed(counterexample, distribution, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.iteration, 1)
        XCTAssertTrue(distribution.isEmpty)
    }
    
    
    
    @Reasync
    func testCounterexampleDistReflectsSuccessfulIterations() async
    {
        /// Labels from successful iterations before the failure must appear
        /// in the distribution. The failing iteration's labels are not
        /// finalized and must not be counted.
        
        let target: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                PropertyInterceptor.current?.recordLabel("tested")
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, distribution, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.iteration, target + 1)
        XCTAssertEqual(distribution["tested"], target)
    }
    
    
    
    @Reasync
    func testExhaustionIncludesDistFromSuccessfulIterations() async throws
    {
        let target      : Int   = 5
        let iterations  : Int   = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxSize:            100,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            where: { capture in capture.size <= target },
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordLabel("accepted")
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.succeeded, target + 1)
        XCTAssertEqual(exhausted.dist["accepted"], target + 1)
    }
    
    
    
    @Reasync
    func testCoverageMetReturnsPassed() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// Every iteration is labeled `always`, and the requirement is 100%.
        /// Since all iterations receive the label, the coverage is exactly met.
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(100, for: "always")
                
                PropertyInterceptor.current?.recordLabel("always")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["always"], iterations)
    }
    
    
    
    @Reasync
    func testCoverageNotMetReturnsCoverageNotMet() async throws
    {
        let target      : Int       = 50
        let required    : Double    = 90
        let iterations  : Int       = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// Require 90% `large`, but only iterations with `size >= 50` are
        /// labeled. With `100` as the iterations and max size, the sizes
        /// are in the range `0...99`. Only 50% qualify as `large`.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(required, for: "large")
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.recordLabel("large")
                }
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(Self.assertCoverageNotMet(result))
        
        XCTAssertEqual(coverageNotMet.iterations, iterations)
        XCTAssertEqual(coverageNotMet.seed, Self.seed)
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "large")
        XCTAssertEqual(coverageNotMet.unmet.first?.required, required)
        XCTAssertEqual(coverageNotMet.unmet.first?.actual, Double(target))
        XCTAssertEqual(coverageNotMet.dist["large"], target)
    }
    
    
    
    @Reasync
    func testMultipleUnmetCoverageReqs() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// 80% required for both labels, but each gets only about 50%.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(80, for: "small")
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(80, for: "large")
                
                if capture.size < 50
                {
                    PropertyInterceptor.current?.recordLabel("small")
                }
                else
                {
                    PropertyInterceptor.current?.recordLabel("large")
                }
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(Self.assertCoverageNotMet(result))
        
        XCTAssertEqual(coverageNotMet.unmet.count, 2)
        
        let labels: Set<String> = Set(coverageNotMet.unmet.map { $0.label })
        
        XCTAssertEqual(labels, ["small", "large"])
    }
    
    
    
    @Reasync
    func testCoveragePartiallyMetReportsOnlyUnmet() async throws
    {
        let target      : Int   = 50
        let iterations  : Int   = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// `all` gets 100% (always met). `large` gets 50%, but requires 90%.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(50, for: "all")
                
                PropertyInterceptor.current?.recordLabel("all")
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(90, for: "large")
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.recordLabel("large")
                }
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(Self.assertCoverageNotMet(result))
        
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "large")
        XCTAssertEqual(coverageNotMet.dist["all"], iterations)
        XCTAssertEqual(coverageNotMet.dist["large"], target)
    }
    
    
    
    @Reasync
    func testFailureOverridesCoverageNotMet() async
    {
        let target: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(99, for: "never")
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, distribution, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value.size, target)
        XCTAssertNil(distribution["never"])
    }
    
    
    
    @Reasync
    func testCoverageZeroPercentAlwaysMet() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        /// A 0% requirement vacuously passes, even if the label is
        /// never recorded.
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(0, for: "never-labeled")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    @Reasync
    func testClassificationWithPreconditionCountOnlyAccepted() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxSize:            100,
            maxDiscardRatio:    100,
            seed:               Self.seed
        )
        
        /// The precondition rejects odd sizes. Classification must count only
        /// the accepted iterations. Since iterations are finalized only for
        /// successful iterations, the distribution should match the number of
        /// iterations.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            where: { capture in capture.size % 2 == 0 },
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordLabel("accepted")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["accepted"], iterations)
    }
    
    
    
    @Reasync
    func testClassificationAfterFailingAssertionNotCounted() async
    {
        let target: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The label is recorded after the failure. Since the property body
        /// continues executing, the label is added to the per-iteration set.
        /// Since the iteration is marked as failure, it is never finalized.
        /// Only the first `target` iterations succeed and are finalized.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
                
                PropertyInterceptor.current?.recordLabel("after-failure")
            },
            options: options
        )
        
        guard case let .failed(counterexample, distribution, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value.size, target)
        XCTAssertEqual(distribution["after-failure"], target)
    }
    
    
    
    @Reasync
    func testDistributionPreservedDuringShrinking() async throws
    {
        /// The distribution should reflect only the successful iterations.
        /// Shrinking re-runs the property but uses fresh interceptors, so
        /// shrink iterations should not pollute the distribution.
        
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            maxSize:        200,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                bountInt async in
                
                PropertyInterceptor.current?.recordLabel("tested")
                
                if bountInt.value > target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, distribution, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        /// The distribution count for `tested` must equal the number of
        /// successful iterations before the failure, and must not be inflated
        /// by shrinking.
        let testedCount: Int = try XCTUnwrap(distribution["tested"])
        
        XCTAssertEqual(testedCount, counterexample.iteration - 1)
    }
    
    
    
    @Reasync
    func testCoverageNotMetSeedMatchesConfiguredSeed() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(100, for: "never-labeled")
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(Self.assertCoverageNotMet(result))
        
        XCTAssertEqual(coverageNotMet.seed, Self.seed)
        XCTAssertEqual(coverageNotMet.iterations, iterations)
    }
    
    
    
    @Reasync
    func testDuplicateLabelWithinIterationCountedOnce() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordLabel("duplicate")
                PropertyInterceptor.current?.recordLabel("duplicate")
                PropertyInterceptor.current?.recordLabel("duplicate")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["duplicate"], iterations)
    }
    
    
    
    @Reasync
    func testZeroIterationsWithCoverageReqsReturnsCovergeNotMet() async throws
    {
        let iterations: Int = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        /// With zero iterations, no labels are ever recorded. A non-zero
        /// coverage requirement produces 0% actual, which is unmet.
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(10, for: "something")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    @Reasync
    func testExhaustionWithCoverageReqDoesNotCheckCoverage() async throws
    {
        let maxDiscardRatio: Int = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        /// The precondition rejects everything, leading to exhaustion.
        /// A coverage requirement is registered, but the property body never
        /// runs, since the precondition is checked first. The result must be
        /// an exhaustion error, not unmet coverage.
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where: { _ in false },
            property:
            {
                _ async in
                
                PropertyInterceptor.current?
                    .recordCoverageRequirement(100, for: "unreachable")
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertTrue(exhausted.dist.isEmpty)
    }
    
    
    
    @Reasync
    func testClassifyIntegration() async throws
    {
        let target      : Int   = 50
        let iterations  : Int   = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                XCTKClassify("small", when: capture.size < target)
                XCTKClassify("large", when: capture.size >= target)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["small"], target)
        XCTAssertEqual(passed.dist["large"], target)
    }
    
    
    
    @Reasync
    func testClassifyFalseConditionDoesNotRecord() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                XCTKClassify("never", when: false)
                XCTKClassify("always", when: true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertNil(passed.dist["never"])
        XCTAssertEqual(passed.dist["always"], iterations)
    }
    
    
    
    @Reasync
    func testCoverMetReturnsPassed() async throws
    {
        let target      : Double    = 50
        let iterations  : Int       = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                XCTKCover(target, "small", when: capture.size < Int(target))
                XCTKCover(target, "large", when: capture.size >= Int(target))
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["small"], Int(target))
        XCTAssertEqual(passed.dist["large"], Int(target))
    }
    
    
    
    @Reasync
    func testCoverNotMetReturnsCoverageNotMet() async throws
    {
        let target      : Int   = 50
        let iterations  : Int   = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                XCTKCover(80, "small", when: capture.size < target)
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(Self.assertCoverageNotMet(result))
        
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "small")
        XCTAssertEqual(coverageNotMet.unmet.first?.required, 80)
        XCTAssertEqual(coverageNotMet.unmet.first?.actual, Double(target))
    }
    
    
    
    @Reasync
    func testCoverMaximumThresholdOverrides() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// `small` gets 50%. The first call requires 40% (met), and the
        /// second call requires 90% (unmet). The result is coverage not met.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                XCTKCover(40, "small", when: capture.size < 50)
                XCTKCover(90, "small", when: capture.size < 50)
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(Self.assertCoverageNotMet(result))
        
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "small")
        XCTAssertEqual(coverageNotMet.unmet.first?.required, 90)
    }
    
    
    
    @Reasync
    func testLabelAndCollectIntegration() async throws
    {
        let iterations  : Int   = 100
        let maxSize     : Int   = 10
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        maxSize,
            seed:           Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                XCTKLabel("all")
                XCTKCollect(capture.size)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["all"], iterations)
        
        /// Collect records the string representation of each size. With a
        /// max size of `10`, and `100` iterations, sizes are in the range
        /// `0...9`. Each size string must appear in the distribution.
        let sizeLabels: [String] = (0..<maxSize).map { String($0) }
        
        for label in sizeLabels
        {
            XCTAssertNotNil(passed.dist[label])
        }
        
        let sizeTotal: Int = sizeLabels.reduce(0)
        {
            return $0 + (passed.dist[$1] ?? 0)
        }
        
        XCTAssertEqual(sizeTotal, iterations)
    }
    
    
    
    @Reasync
    func testClassificationWithCustomGenerator() async throws
    {
        let iterations: Int = 100
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                XCTKClassify("low", when: int <= 50)
                XCTKClassify("high", when: int > 50)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        let low     : Int   = passed.dist["low"]    ?? 0
        let high    : Int   = passed.dist["high"]   ?? 0
        
        XCTAssertEqual(low + high, iterations)
    }
    
    
    
    @Reasync
    func testClassificationWithCustomGeneratorAndFailure() async
    {
        let target: Int = 50
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            seed:           Self.seed
        )
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                XCTKClassify("low", when: int <= target)
                XCTKClassify("high", when: int > target)
                
                if int > target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, distribution, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value, target + 1)
        
        /// The failing iteration is not finalized. Only successful iterations
        /// contribute to the distribution. `high` must not appear, since any
        /// iteration with that label must trigger a failure.
        let low     : Int   = distribution["low"]    ?? 0
        let high    : Int   = distribution["high"]   ?? 0
        
        XCTAssertEqual(low, counterexample.iteration - 1)
        XCTAssertEqual(high, 0)
    }
    
    
    
    @Reasync
    func testCoverageWithSingleIteration() async throws
    {
        let iterations: Int = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                XCTKCover(100, "present", when: true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["present"], iterations)
    }
    
    
    
    @Reasync
    func testCoverageNotMetWithSingleIteration() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                XCTKCover(50, "absent", when: false)
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(Self.assertCoverageNotMet(result))
        
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "absent")
        XCTAssertEqual(coverageNotMet.unmet.first?.actual, 0)
    }
    
    
    
    @Reasync
    func testMixedClassifyCoverAndLabel() async throws
    {
        let target      : Int   = 50
        let iterations  : Int   = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                XCTKLabel("all")
                XCTKClassify("small", when: capture.size < target)
                XCTKCover(10, "large", when: capture.size >= target)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["all"], iterations)
        XCTAssertEqual(passed.dist["small"], target)
        XCTAssertEqual(passed.dist["large"], target)
    }
    
    
    
    @Reasync
    func testCoverageWithConditionalPropertyAndDiscards() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxSize:            100,
            maxDiscardRatio:    100,
            seed:               Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where: { boundInt in boundInt.value % 2 == 0 },
            property:
            {
                _ async in
                
                XCTKCover(100, "even", when: true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(passed.dist["even"], iterations)
    }
    
    
    
    // MARK: - Seed
    
    @Reasync
    func testSameSeedDeterminism() async
    {
        let target  : Int           = 7
        let options : TestOptions   = .propertyOptions(seed: Self.seed)
        
        let resultA: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value == target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "found target",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        let resultB: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value == target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "found target",
                        file:       "File.swift",
                        line:       1
                    )
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
            let result: PCR<BoundInt> = await PropertyRunner.run(
                property:   { _ async in },
                options:    .propertyOptions(seed: nil)
            )
            
            let passed: PassedValues = try XCTUnwrap(Self.assertPassed(result))
            
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
        
        let resultA: PCR<BoundInt> = await PropertyRunner.run(
            property:   { boundInt async in valuesA.append(boundInt.value) },
            options:    optionsA
        )
        
        let resultB: PCR<BoundInt> = await PropertyRunner.run(
            property:   { boundInt async in valuesB.append(boundInt.value) },
            options:    optionsB
        )
        
        _ = try XCTUnwrap(Self.assertPassed(resultA))
        _ = try XCTUnwrap(Self.assertPassed(resultB))
        
        XCTAssertEqual(valuesA.count, valuesB.count)
        XCTAssertNotEqual(valuesA, valuesB)
    }
    
    
    
    @Reasync
    func testCounterexampleSeedMatchesConfiguredSeed() async throws
    {
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordFailure(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.seed, Self.seed)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    @Reasync
    func testFailureWithNilSeed() async throws
    {
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordFailure(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: .propertyOptions(seed: nil)
        )
        
        _ = try XCTUnwrap(Self.assertFailed(result))
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.recordFailure(
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
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testNoShrinkReturnsOriginalValue() async throws
    {
        let result: PCR<BoundIntNoShrink> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > 10
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundIntNoShrink>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int > 0
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "positive",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
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
    
    
    
    @Reasync
    func testZeroMaxShrinkStepsDisablesShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            seed:               Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > 5
                {
                    PropertyInterceptor.current?.recordFailure(
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "value \(boundInt.value) is positive",
                        file:       "File.swift",
                        line:       99
                    )
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        let failure: InterceptedFailure
            = try XCTUnwrap(counterexample.failures.first)
        
        XCTAssertEqual(failure.message, "value \(target + 1) is positive")
        XCTAssertEqual(failure.file.description, "File.swift")
        XCTAssertEqual(failure.line, 99)
    }
    
    
    
    @Reasync
    func testThrowDuringShrinkingContinuesShrinking() async throws
    {
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
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
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int >= target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int > 0
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "positive",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordFailure(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using:  generator,
            where:  { $0 >= 20 },
            property:
            {
                int async in
                
                if int > 5
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async throws in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "value \(boundInt.value) is too large",
                        file:       "File.swift",
                        line:       1
                    )
                    
                    throw TestError()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordFailure(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "positive",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using:  generator,
            where:  { int in int >= 100 },
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordFailure(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int > 5
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                if int > target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "positive",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
        XCTAssertEqual(counterexample.value, target + 1)
    }
    
    
    
    @Reasync
    func testCustomGeneratorWithoutShrinking() async throws
    {
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 50...100) },
            shrink:     { _ in [] }
        )
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                _ async in
                
                PropertyInterceptor.current?.recordFailure(
                    message:    "always fails",
                    file:       "File.swift",
                    line:       1
                )
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using:      generator,
            where:      { int in int % 2 == 0 },
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
    }
    
    
    
    @Reasync
    func testCustomGeneratorWithPreconditionRespectsFilter() async throws
    {
        let target: Int = 10
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let result: PCR<Int> = await PropertyRunner.run(
            using:      generator,
            where:      { int in int % 2 == 0 },
            property:
            {
                int async in
                
                if int > target
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "too large",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<Int> = await PropertyRunner.run(
            using:      generator,
            where:      { _ in false },
            property:   { _ async in },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(Self.assertExhausted(result))
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, threshold + 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    // MARK: - Size
    
    @Reasync
    func testSizeStartsAtZero() async throws
    {
        var firstSize: Int? = nil
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
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
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
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
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
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
    
    
    
    @Reasync
    func testMaxSizeControlsUpperBound() async throws
    {
        let maxSize : Int       = 25
        var sizes   : [Int]     = []
        
        let options: TestOptions = .propertyOptions(
            maxSize:    maxSize,
            seed:       Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
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
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
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
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
        for size in sizes
        {
            XCTAssertLessThan(size, maxSize)
        }
        
        XCTAssertEqual(sizes.last, maxSize - 1)
    }
    
    
    
    @Reasync
    func testFailureAtSizeZero() async throws
    {
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                if capture.size == 0
                {
                    PropertyInterceptor.current?.recordFailure(
                        message:    "size zero fails",
                        file:       "File.swift",
                        line:       1
                    )
                }
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<SizeCapture>
            = try XCTUnwrap(Self.assertFailed(result))
        
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
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
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
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:   { capture async in sizes.append(capture.size) },
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
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            where:
            {
                capture in
                
                sizes.append(capture.size)
                
                return capture.size % 2 == 0
            },
            property:   { _ async in },
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
        let result: PCR<BoundInt> = await PropertyRunner.run(
            where:      { boundInt in  boundInt.value % 2 == 0 },
            property:   { _ async in accepted.append(accepted.count) },
            options:    options
        )
        
        _ = try XCTUnwrap(Self.assertPassed(result))
        
        XCTAssertEqual(accepted.count, iterations)
    }
}



// MARK: - Support

extension PropertyRunnerTests
{
    private typealias PCR = PropertyCheckResult
    
    
    
    /// A wrapper around `Int` that provides controllable shrinking.
    ///
    /// This is different from `Int: Arbitrary` since `Int.arbitrary(using:)`
    /// generates values in the range `-context.size...context.size`, which
    /// makes it harder to reason about value distributions in tests. This
    /// wrapper always generates values in the range `0...context.size`.
    private struct BoundInt: Arbitrary, Equatable, CustomStringConvertible
    {
        let value: Int
        
        init(
            _ value: Int
        )
        {
            self.value = value
        }
        
        var description: String
        {
            return "BoundInt: \(value)"
        }
        
        static func arbitrary(
            using context: GenerationContext
        ) -> BoundInt
        {
            return BoundInt(context.random(in: 0...max(1, context.size)))
        }
        
        func shrink() -> [BoundInt]
        {
            return value.shrinkTowardZero().map { BoundInt($0) }
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
    private static let seed: UInt64 = 12345
    
    
    
    /// The associated values of a passed ``PropertyCheckResult``.
    private struct PassedValues
    {
        let iterations  : Int
        let seed        : UInt64
        let dist        : [String : Int]
        let tableDist   : [String : [String : Int]]
    }
    
    
    
    /// Asserts that the given property check result passed, and returns the
    /// associated values.
    /// - Parameter result: The property check result to evaluate.
    /// - Returns: The associated values of the passed result, or `nil` if
    /// the result did not pass.
    @discardableResult
    private static func assertPassed<T>(
        _ result: PCR<T>
    ) -> PassedValues?
    {
        guard case let .passed(iterations, seed, dist, tableDist) = result
        else
        {
            XCTFail("Expected .passed, got \(result)")
            return nil
        }
        
        return PassedValues(
            iterations:     iterations,
            seed:           seed,
            dist:           dist,
            tableDist:      tableDist
        )
    }
    
    
    
    /// Asserts that the given property check result failed, and returns the
    /// counterexample.
    /// - Parameter result: The property check result to evaluate.
    /// - Returns: The counterexample of the failed result, `nil` if the
    /// result did not fail.
    @discardableResult
    private static func assertFailed<T>(
        _ result: PCR<T>
    ) -> Counterexample<T>?
    {
        guard case let .failed(counterexample, _, _) = result
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
        let dist        : [String : Int]
        let tableDist   : [String : [String : Int]]
    }
    
    
    
    /// Asserts that the given property check result was exhausted, and returns
    /// the associated values.
    /// - Parameter result: The property check result to evaluate.
    /// - Returns: The associated values, `nil` if the result was not exhausted.
    @discardableResult
    private static func assertExhausted<T>(
        _ result: PCR<T>
    ) -> ExhaustedValues?
    {
        guard case let .exhausted(
            discarded, succeeded, ratio, seed, dist, tableDist
        ) = result
        else
        {
            XCTFail("Expected .exhausted, got \(result)")
            return nil
        }
        
        return ExhaustedValues(
            discarded:  discarded,
            succeeded:  succeeded,
            ratio:      ratio,
            seed:       seed,
            dist:       dist,
            tableDist:  tableDist
        )
    }
    
    
    
    /// The associated values of a coverage-not-met ``PropertyCheckResult``.
    private struct CoverageNotMetValues
    {
        let unmet       : [UnmetCoverage]
        let iterations  : Int
        let seed        : UInt64
        let dist        : [String : Int]
        let tableDist   : [String : [String : Int]]
    }
    
    
    
    /// Asserts that the given property check result has unmet coverage,
    /// and returns the associated values.
    /// - Parameter result: The property check result to evaluate.
    /// - Returns: The associated values, `nil` if the result did not have
    /// unmet coverage.
    @discardableResult
    private static func assertCoverageNotMet<T>(
        _ result: PCR<T>
    ) -> CoverageNotMetValues?
    {
        guard case let .coverageNotMet(
            unmet, iterations, seed, dist, tableDist
        ) = result
        else
        {
            XCTFail("Expected .coverageNotMet, got \(result)")
            return nil
        }
        
        return CoverageNotMetValues(
            unmet:          unmet,
            iterations:     iterations,
            seed:           seed,
            dist:           dist,
            tableDist:      tableDist
        )
    }
}
