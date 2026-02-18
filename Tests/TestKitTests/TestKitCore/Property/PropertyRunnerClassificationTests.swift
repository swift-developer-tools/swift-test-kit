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



internal final class PropertyRunnerClassificationTests: XCTestCaseStopOnFail
{
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
                
                XCTKClassify("small", when: capture.size < target)
                XCTKClassify("large", when: capture.size >= target)
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
                
                XCTKClassify("never", when: false)
                XCTKClassify("always", when: true)
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
                
                XCTKCover(target, "small", when: capture.size < Int(target))
                XCTKCover(target, "large", when: capture.size >= Int(target))
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
                
                XCTKCover(80, "small", when: capture.size < target)
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
                
                XCTKCover(40, "small", when: capture.size < 50)
                XCTKCover(90, "small", when: capture.size < 50)
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
                
                XCTKLabel("all")
                XCTKCollect(capture.size)
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
                
                XCTKClassify("low", when: int <= 50)
                XCTKClassify("high", when: int > 50)
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
                
                XCTKCover(50, "absent", when: false)
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
                
                XCTKLabel("all")
                XCTKClassify("small", when: capture.size < target)
                XCTKCover(10, "large", when: capture.size >= target)
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
                
                XCTKCover(100, "even", when: true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["even"], iterations)
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
