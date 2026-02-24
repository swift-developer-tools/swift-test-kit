//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest
@testable import struct TestKitCore.PropertyRunner



internal final class PropertyRunnerClassificationTests: TestKitCase
{
    // MARK: - Assume
    
    @Reasync
    func testAssumeTruePassesThrough() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                try TKAssume(true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    @Reasync
    func testAssumeFalseExhausts() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                try TKAssume(false)
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
    }
    
    
    
    @Reasync
    func testAssumeBasedOnDerivedValue() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxSize:            100,
            maxDiscardRatio:    100,
            seed:               Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async throws in
                
                try TKAssume(capture.size % 2 == 0)
                
                TKLabel("accepted")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["accepted"], iterations)
    }
    
    
    
    @Reasync
    func testAssumeExhaustionRespectsDiscardRatio() async throws
    {
        let iterations      : Int   = 100
        let maxDiscardRatio : Int   = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                try TKAssume(false)
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertGreaterThan(exhausted.discarded, maxDiscardRatio * iterations)
    }
    
    
    
    @Reasync
    func testLabelsBeforeASsumeDiscardNotFinalized() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        /// A label recorded before a discarding assumption must not appear
        /// in the distribution, since the discarded iteration is never
        /// finalized.
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                TKLabel("ghost")
                
                try TKAssume(false)
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertTrue(exhausted.dist.isEmpty)
    }
    
    
    
    @Reasync
    func testTableLabelsBeforeASsumeDiscardNotFinalized() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        /// A label recorded before a discarding assumption must not appear
        /// in the distribution, since the discarded iteration is never
        /// finalized.
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                TKTabulate("table", "ghost")
                
                try TKAssume(false)
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertTrue(exhausted.tableDist.isEmpty)
    }
    
    
    
    @Reasync
    func testCoverageWithAssumeCountsOnlyAccepted() async throws
    {
        let iterations: Int = 100
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// Assumption discards odd sizes. The coverage requirement of 100%
        /// is met since every non-discarded iteration receives the label.
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async throws in
                
                try TKAssume(int % 2 == 0)
                
                TKCover(100, "accepted", when: true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["accepted"], iterations)
    }
    
    
    
    @Reasync
    func testAssumeTrueThenFailureProducesFailure() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                try TKAssume(true)
                
                PropertyInterceptor.current?.recordFailure()
            },
            options: options
        )
        
        guard case let .failed(counterexample, _, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.iteration, 1)
    }
    
    
    
    @Reasync
    func testShrinkingSkipsCandidatesFailingAssumption() async
    {
        let target: Int = 20
        
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            maxSize:        200,
            seed:           Self.seed
        )
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async throws in
                
                try TKAssume(int % 2 == 0)
                
                if int > target
                {
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, _, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value % 2, 0)
        XCTAssertGreaterThan(counterexample.value, target)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testDistributionNotInflatedByDiscardedAssumptions() async
    {
        let target: Int = 10
        
        /// Generate only even values so the main loop never discards them.
        /// The odd candidates are discarded by the assumption. Discarded
        /// values during shrinking must not inflate the distribution.
        let generator = Generator<Int>(
            generate:
            {
                context in
                
                return context.random(in: 0...max(1, context.size) * 2)
            },
            shrink: { value in value.shrinkTowardZero() }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            maxSize:        200,
            seed:           Self.seed
        )
        
        let result: PCR<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async throws in
                
                try TKAssume(int % 2 == 0)
                
                PropertyInterceptor.current?.recordLabel("tested")
                
                if int > target
                {
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, dist, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        let testedCount: Int? = dist["tested"]
        
        XCTAssertNotNil(testedCount)
        XCTAssertLessThan(testedCount!, counterexample.iteration)
    }
    
    
    
    @Reasync
    func testAssumeWithZeroIterationsVacuouslyPasses() async throws
    {
        let iterations: Int = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                try TKAssume(false)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    @Reasync
    func testAssumeWithPrecondition() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxSize:            100,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        /// The precondition rejects odd sizes and the assumption rejects
        /// everything else. Discards from both paths contribute to the
        /// discard count and trigger exhaustion.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            where: { capture in capture.size % 2 == 0 },
            property:
            {
                _ async throws in
                
                try TKAssume(false)
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
    }
    
    
    
    @Reasync
    func testAssumeWithPreconditionPartialAcceptance() async throws
    {
        let iterations: Int = 50
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The precondition rejects odd sizes and the assumption rejects
        /// sizes not divisible by `4`. Discards from both paths contribute to
        /// the discard count, but enough iterations pass to complete.
        let result: PCR<Int> = await PropertyRunner.run(
            using:  generator,
            where:  { int in int % 2 == 0 },
            property:
            {
                int async throws in
                
                try TKAssume(int % 4 == 0)
                
                TKLabel("accepted")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["accepted"], iterations)
    }
    
    
    
    // MARK: - Non-table
    
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
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
                PropertyInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        guard case let .failed(counterexample, dist, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.iteration, 1)
        XCTAssertTrue(dist.isEmpty)
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
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, dist, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.iteration, target + 1)
        XCTAssertEqual(dist["tested"], target)
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
            = try XCTUnwrap(result.assertExhausted())
        
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
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
            = try XCTUnwrap(result.assertCoverageNotMet())
        
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
            = try XCTUnwrap(result.assertCoverageNotMet())
        
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
            = try XCTUnwrap(result.assertCoverageNotMet())
        
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
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, dist, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value.size, target)
        XCTAssertNil(dist["never"])
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
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
                    PropertyInterceptor.current?.recordFailure()
                }
                
                PropertyInterceptor.current?.recordLabel("after-failure")
            },
            options: options
        )
        
        guard case let .failed(counterexample, dist, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value.size, target)
        XCTAssertEqual(dist["after-failure"], target)
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
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, dist, _) = result
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
        let testedCount: Int = try XCTUnwrap(dist["tested"])
        
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
            = try XCTUnwrap(result.assertCoverageNotMet())
        
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
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
            = try XCTUnwrap(result.assertExhausted())
        
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
                
                TKClassify("small", when: capture.size < target)
                TKClassify("large", when: capture.size >= target)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
                
                TKClassify("never", when: false)
                TKClassify("always", when: true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
                
                TKCover(target, "small", when: capture.size < Int(target))
                TKCover(target, "large", when: capture.size >= Int(target))
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
                
                TKCover(80, "small", when: capture.size < target)
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
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
                
                TKCover(40, "small", when: capture.size < 50)
                TKCover(90, "small", when: capture.size < 50)
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
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
                
                TKLabel("all")
                TKCollect(capture.size)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
                
                TKClassify("low", when: int <= 50)
                TKClassify("high", when: int > 50)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
                
                TKClassify("low", when: int <= target)
                TKClassify("high", when: int > target)
                
                if int > target
                {
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, dist, _) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value, target + 1)
        
        /// The failing iteration is not finalized. Only successful iterations
        /// contribute to the distribution. `high` must not appear, since any
        /// iteration with that label must trigger a failure.
        let low     : Int   = dist["low"]   ?? 0
        let high    : Int   = dist["high"]  ?? 0
        
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
                
                TKCover(100, "present", when: true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
                
                TKCover(50, "absent", when: false)
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
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
                
                TKLabel("all")
                TKClassify("small", when: capture.size < target)
                TKCover(10, "large", when: capture.size >= target)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
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
                
                TKCover(100, "even", when: true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["even"], iterations)
    }
    
    
    
    // MARK: - Table
    
    @Reasync
    func testTabulateIntegration() async throws
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
                capture async in
                
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertTrue(passed.dist.isEmpty)
        
        let parity: [String : Int]? = passed.tableDist["parity"]
        
        XCTAssertNotNil(parity)
        
        let even    : Int   = parity?["even"]   ?? 0
        let odd     : Int   = parity?["odd"]    ?? 0
        
        XCTAssertEqual(even + odd, iterations)
        XCTAssertGreaterThan(even, 0)
        XCTAssertGreaterThan(odd, 0)
    }
    
    
    
    @Reasync
    func testTabulateMultipleTables() async throws
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
                capture async in
                
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
                TKTabulate("size", capture.size < 50 ? "small" : "large")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        let parity  : [String : Int]?   = passed.tableDist["parity"]
        let size    : [String : Int]?   = passed.tableDist["size"]
        
        XCTAssertNotNil(parity)
        XCTAssertNotNil(size)
        
        let even    : Int   = parity?["even"]   ?? 0
        let odd     : Int   = parity?["odd"]    ?? 0
        
        XCTAssertEqual(even + odd, iterations)
        XCTAssertGreaterThan(even, 0)
        XCTAssertGreaterThan(odd, 0)
        
        let small   : Int   = size?["small"]    ?? 0
        let large   : Int   = size?["large"]    ?? 0
        
        XCTAssertEqual(small + large, iterations)
        XCTAssertGreaterThan(small, 0)
        XCTAssertGreaterThan(large, 0)
    }
    
    
    
    @Reasync
    func testTabulateDuplicateLabelWithinIteration() async throws
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
                
                TKTabulate("t", "a")
                TKTabulate("t", "a")
                TKTabulate("t", "a")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.tableDist["t"]?["a"], iterations)
    }
    
    
    
    @Reasync
    func testTabulateWithFailureReflectsSuccessfulIteration() async
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
                
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, _, tableDist) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value.size, target)
        
        let parity  : [String : Int]    = tableDist["parity"]   ?? [:]
        let even    : Int               = parity["even"]        ?? 0
        let odd     : Int               = parity["odd"]         ?? 0
        
        XCTAssertEqual(even + odd, target)
    }
    
    
    
    @Reasync
    func testTabulateWithPreconditionCountsOnlyAccepted() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxSize:            100,
            maxDiscardRatio:    100,
            seed:               Self.seed
        )
        
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            where: { capture in capture.size % 2 == 0 },
            property:
            {
                _ async in
                
                TKTabulate("group", "accepted")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.tableDist["group"]?["accepted"], iterations)
    }
    
    
    
    @Reasync
    func testTableDistributionPreservedDuringShrinking() async
    {
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            maxSize:        200,
            seed:           Self.seed
        )
        
        let result: PCR<BoundInt> = await PropertyRunner.run(
            property:
            {
                boundInt async in
                
                TKTabulate("sign", boundInt.value > 0 ? "positive" : "zero")
                
                if boundInt.value > target
                {
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, _, tableDist) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value, BoundInt(target + 1))
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        let sign    : [String : Int]    = tableDist["sign"] ?? [:]
        let total   : Int               = sign.values.reduce(0, +)
        
        /// The table distribution must equal the number of successful
        /// iterations before the failure, and must not be inflated by
        /// shrinking.
        XCTAssertEqual(total, counterexample.iteration - 1)
    }
    
    
    
    @Reasync
    func testCoverTableMetReturnsPassed() async throws
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
                capture async in
                
                TKCoverTable("parity", (40, "even"), (40, "odd"))
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
            },
            options: options
        )
        
        let passed  : PassedValues      = try XCTUnwrap(result.assertPassed())
        let parity  : [String : Int]    = passed.tableDist["parity"] ?? [:]
        
        XCTAssertEqual(parity.values.reduce(0, +), iterations)
    }
    
    
    
    @Reasync
    func testCoverTableNotMetReturnsCoverageNotMet() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// Require 90% even, but only about 50% are even.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                TKCoverTable("parity", (90, "even"))
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
        XCTAssertEqual(coverageNotMet.iterations, iterations)
        XCTAssertEqual(coverageNotMet.seed, Self.seed)
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "even")
        XCTAssertEqual(coverageNotMet.unmet.first?.table, "parity")
        XCTAssertEqual(coverageNotMet.unmet.first?.required, 90)
    }
    
    
    
    @Reasync
    func testCoverTableMultipleRequirementsPartiallyMet() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// Require 90% odd, but only about 50% are odd.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                TKCoverTable("parity", (40, "even"), (90, "odd"))
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
        XCTAssertEqual(coverageNotMet.iterations, iterations)
        XCTAssertEqual(coverageNotMet.seed, Self.seed)
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "odd")
        XCTAssertEqual(coverageNotMet.unmet.first?.table, "parity")
        XCTAssertEqual(coverageNotMet.unmet.first?.required, 90)
    }
    
    
    
    @Reasync
    func testCoverTableMaximumThresholdOverrides() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// `even` gets 50%. The first call requires 40% (met), and the
        /// second call requires 90% (unmet). The result is coverage not met.
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                TKCoverTable("parity", (40, "even"))
                TKCoverTable("parity", (90, "even"))
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
        XCTAssertEqual(coverageNotMet.iterations, iterations)
        XCTAssertEqual(coverageNotMet.seed, Self.seed)
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "even")
        XCTAssertEqual(coverageNotMet.unmet.first?.table, "parity")
        XCTAssertEqual(coverageNotMet.unmet.first?.required, 90)
    }
    
    
    
    @Reasync
    func testCoverTableZeroPercentageVacuouslyPasses() async throws
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
                
                TKCoverTable("t", (0, "never"))
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    @Reasync
    func testFailureOverridesTableCoverageNotMet() async
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
                
                TKCoverTable("t", (99, "never"))
                
                if capture.size >= target
                {
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, _, tableDist) = result
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertEqual(counterexample.value.size, target)
        XCTAssertNil(tableDist["t"])
    }
    
    
    
    @Reasync
    func testExhaustionIncludesTableDistributionFromSuccesses() async throws
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
                capture async in
                
                TKTabulate("group", "accepted")
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, target + 1)
        XCTAssertEqual(exhausted.tableDist["group"]?["accepted"], target + 1)
    }
    
    
    
    @Reasync
    func testMixedFlatAndTableCoverageBothMet() async throws
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
                capture async in
                
                TKCover(40, "small", when: capture.size < 50)
                TKCoverTable("parity", (40, "even"), (40, "odd"))
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["small"], 50)
        
        let parity: [String : Int] = passed.tableDist["parity"] ?? [:]
        
        XCTAssertEqual(parity.values.reduce(0, +), iterations)
    }
    
    
    
    @Reasync
    func testMixedFlatMetTableUnmetReturnsCoverageNotMet() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The flat coverage is met (40% `small`, actual 50%). The table
        /// coverage is unmet (90% `even`, actual 50%).
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                TKCover(40, "small", when: capture.size < 50)
                TKCoverTable("parity", (90, "even"))
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "even")
        XCTAssertEqual(coverageNotMet.unmet.first?.table, "parity")
    }
    
    
    
    @Reasync
    func testMixedFlatUnmetTableMetReturnsCoverageNotMet() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The flat coverage is unmet (90% `small`, actual 50%). The table
        /// coverage is met (40% `even`, actual 50%).
        let result: PCR<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                TKCover(90, "small", when: capture.size < 50)
                TKCoverTable("parity", (40, "even"))
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
            },
            options: options
        )
        
        let coverageNotMet: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
        XCTAssertEqual(coverageNotMet.unmet.count, 1)
        XCTAssertEqual(coverageNotMet.unmet.first?.label, "small")
        XCTAssertNil(coverageNotMet.unmet.first?.table)
    }
    
    
    
    @Reasync
    func testMixedTableClassificationIntegration() async throws
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
                
                TKLabel("all")
                TKClassify("small", when: capture.size < target)
                TKCover(10, "large", when: capture.size >= target)
                TKCoverTable("parity", (40, "even"), (40, "odd"))
                TKTabulate("parity", capture.size % 2 == 0 ? "even" : "odd")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["all"], iterations)
        XCTAssertEqual(passed.dist["small"], target)
        XCTAssertEqual(passed.dist["large"], target)
        
        let parity: [String : Int] = passed.tableDist["parity"] ?? [:]
        
        XCTAssertEqual(parity.values.reduce(0, +), iterations)
        XCTAssertGreaterThan(parity["even"] ?? 0, 0)
        XCTAssertGreaterThan(parity["odd"] ?? 0, 0)
    }
}



// MARK: - Support

extension PropertyRunnerClassificationTests
{
    private typealias PCR = PropertyCheckResult
    
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 12345
}
