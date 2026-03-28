//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import Reasync
import XCTest



internal final class PropertyRunnerTargetTests: TestKitCase
{
    // MARK: - Activation
    
    @Reasync
    func testTargetConvergesWithMutation() async
    {
        /// Targeting the value with a determinism generator that adds `10` on
        /// each mutation causes the pool to accumulate high-target-value
        /// entries, and exploitation drives values toward the maximum of `100`.
        
        var values: [Int] = []
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { value, _ in min(100, value + 10) }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            seed:           Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                values.append(int)
                TKTarget(Double(int))
            },
            options: options
        )
        
        result.assertPassed()
        
        XCTAssertEqual(values.count, 100)
        
        let atMax: Int = values.filter { $0 == 100 }.count
        
        XCTAssertGreaterThanOrEqual(atMax, 30)
    }
    
    
    
    // MARK: - Activation
    
    @Reasync
    func testTargetWithZeroIterationsVacuouslyPasses() async throws
    {
        let iterations: Int = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async in
                
                TKTarget(99.0)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    // MARK: - Exploration ratio
    
    @Reasync
    func testExplorationRatioOneNeverMutates() async
    {
        /// With an exploration ratio of `1.0`, every iteration generates a
        /// new value. The mutated `sentinel` value must never appear.
        
        let sentinel    : Int       = -999
        var values      : [Int]     = []
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { _, _ in sentinel }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            explorationRatio:   1.0,
            seed:               Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                values.append(int)
                TKTarget(Double(int))
            },
            options: options
        )
        
        result.assertPassed()
        
        for value in values
        {
            XCTAssertNotEqual(value, sentinel)
        }
    }
    
    
    
    @Reasync
    func testExplorationRatioZeroAlwaysMutatesAfterPoolSeeds() async
    {
        /// With an exploration ratio of `0.0`, every iteration after the
        /// first mutates a pooled value. The first iteration generates a new
        /// value, since the pool is empty.
        
        let sentinel    : Int       = -999
        var values      : [Int]     = []
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { _, _ in sentinel }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            explorationRatio:   0.0,
            seed:               Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                values.append(int)
                TKTarget(Double(int))
            },
            options: options
        )
        
        result.assertPassed()
        
        for (index, value) in values.enumerated()
        {
            if index == 0
            {
                XCTAssertNotEqual(value, sentinel)
            }
            else
            {
                XCTAssertEqual(value, sentinel)
            }
        }
    }
    
    
    
    // MARK: - Shrinking
    
    @Reasync
    func testShrinkingAfterTargetedFailure() async throws
    {
        /// Targeting drives values upward through the `+5` mutation. Once a
        /// value exceeds `threshold`, the property fails. Shrinking must still
        /// produces the minimal counterexample, despite the failure
        /// originating from exploitation.
        
        let threshold: Int = 10
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { value in value.shrinkTowardZero() },
            mutate:     { value, _ in min(100, value + 5) }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     200,
            seed:           Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                TKTarget(Double(int))
                
                if int > threshold
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<Int>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, threshold + 1)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    // MARK: - Pool size
    
    @Reasync
    func testPoolSizeOneConverges() async
    {
        /// A pool size of `1` retains only the single highest-scoring entry.
        /// Exploitation always mutates that entry, creating a narrow
        /// convergence path. The `+1` mutation must still drive values higher.
        
        var values: [Int] = []
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { value, _ in min(100, value + 1) }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            poolSize:       1,
            seed:           Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                values.append(int)
                TKTarget(Double(int))
            },
            options: options
        )
        
        result.assertPassed()
        
        let atMax: Int = values.filter { $0 == 100 }.count
        
        XCTAssertGreaterThanOrEqual(atMax, 20)
    }
    
    
    
    // MARK: - Pool insertion
    
    @Reasync
    func testDiscardedIterationDoesNotAddToPool() async throws
    {
        /// With an exploration ratio of `0.0`, exploitation would always be
        /// attempted. Since no iteration succeeds,the pool must remain empty
        /// and never be used.
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxDiscardRatio:    1,
            explorationRatio:   0.0,
            seed:               Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                TKTarget(99.0)
                try TKAssume(false)
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
    }
    
    
    
    @Reasync
    func testFailedIterationDoesNotAddToPool() async throws
    {
        /// With an exploration ratio of `0.0`, exploitation would always be
        /// attempted. Since no iteration succeeds,the pool must remain empty
        /// and never be used.
        
        let options: TestOptions = .propertyOptions(
            explorationRatio:   0.0,
            seed:               Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            property:
            {
                _ async throws in
                
                TKTarget(99.0)
                FailureInterceptor.current?.recordFailure()
            },
            options: options
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.iteration, 1)
    }
    
    
    
    // MARK: - Precondition
    
    @Reasync
    func testPreconditionFiltering() async throws
    {
        /// Exploited values that fail the precondition must be discarded as
        /// usual. The mutation from an even base produces odd values
        /// two-thirds of the time, whereas the precondition requires only
        /// even values.
        
        let iterations  : Int       = 100
        var values      : [Int]     = []
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { value, context in value + context.random(in: 1...3) }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxDiscardRatio:    100,
            seed:               Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using:  generator,
            where:  { $0 % 2 == 0 },
            property:
            {
                int async in
                
                values.append(int)
                TKTarget(Double(int))
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
        
        for value in values
        {
            XCTAssertEqual(value % 2, 0)
        }
    }
    
    
    
    // MARK: - Arbitrary mutation
    
    @Reasync
    func testArbitraryMutateUsedForExploitation() async
    {
        /// With an exploration ratio of `0.0`, every iteration after the
        /// first mutates a pooled value. The first iteration generates a new
        /// value, since the pool is empty. Mutation of an ``Arbitrary`` type
        /// without a generator defaults to the type's conformance.
        
        var mutatedFlags: [Bool] = []
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            explorationRatio:   0.0,
            seed:               Self.seed
        )
        
        let result: PropertyResult<TargetInt> = await PropertyRunner.run(
            property:
            {
                targetInt async in
                
                mutatedFlags.append(targetInt.mutated)
                TKTarget(Double(targetInt.value))
            },
            options: options
        )
        
        result.assertPassed()
        
        for (index, mutated) in mutatedFlags.enumerated()
        {
            if index == 0
            {
                XCTAssertFalse(mutated)
            }
            else
            {
                XCTAssertTrue(mutated)
            }
        }
    }
    
    
    
    @Reasync
    func testArbitraryWithPreconditionAndTargeting() async
    {
        var values: [Int] = []
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxSize:            200,
            maxDiscardRatio:    100,
            seed:               Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            where: { $0.value % 2 == 0 },
            property:
            {
                boundInt async in
                
                values.append(boundInt.value)
                TKTarget(Double(boundInt.value))
            },
            options: options
        )
        
        result.assertPassed()
        
        for value in values
        {
            XCTAssertEqual(value % 2, 0)
        }
    }
    
    
    
    // MARK: - Multiple targets
    
    @Reasync
    func testMultipleTargetCallsUsesLastValue() async
    {
        /// The last target call must be used, by which exploitation drives
        /// toward larger sizes. If the first target value of `0.0` were used,
        /// the pool would contain only zero-target-value entries, and
        /// exploitation would not favor larger sizes. The last quarter of
        /// iterations must show exploitation driving values higher.
        
        var values: [Int] = []
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                TKTarget(0.0)
                TKTarget(Double(capture.size))
                
                values.append(capture.size)
            },
            options: options
        )
        
        result.assertPassed()
        
        let lastQuarter: ArraySlice<Int> = values.suffix(25)
        
        let average
            = Double(lastQuarter.reduce(0, +)) / Double(lastQuarter.count)
        
        XCTAssertGreaterThan(average, 30.0)
    }
    
    
    
    // MARK: - Conditional target
    
    @Reasync
    func testConditionalTargetActivatesOnFirstCall() async throws
    {
        /// A target is only recorded when the value exceeds `threshold`.
        /// With an exploration ratio of `0.0`, every iteration after the
        /// first mutates a pooled value. The first iteration generates a new
        /// value, since the pool is empty. All mutations return `sentinel`,
        /// and all iterations before mutation must not return `sentinel`.
        
        let sentinel    : Int       = -999
        let threshold   : Int       = 50
        var values      : [Int]     = []
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { _, _ in sentinel }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            explorationRatio:   0.0,
            seed:               Self.seed
        )
        
        let result: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                values.append(int)
                
                if int > threshold
                {
                    TKTarget(Double(int))
                }
            },
            options: options
        )
        
        result.assertPassed()
        
        /// The first index that seeded the pool.
        let seedIndex: Int
            = try XCTUnwrap(values.firstIndex { $0 > threshold })
        
        for index in 0...seedIndex
        {
            XCTAssertNotEqual(values[index], sentinel)
        }
        
        for index in (seedIndex + 1)..<values.count
        {
            XCTAssertEqual(values[index], sentinel)
        }
    }
    
    
    
    // MARK: - Determinism
    
    @Reasync
    func testSameSeedDeterminism() async
    {
        var valuesA : [Int]     = []
        var valuesB : [Int]     = []
        
        let generator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { value, context in value + context.random(in: 1...5) }
        )
        
        let options: TestOptions = .propertyOptions(
            iterations:     100,
            seed:           Self.seed
        )
        
        let resultA: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                valuesA.append(int)
                TKTarget(Double(int))
            },
            options: options
        )
        
        let resultB: PropertyResult<Int> = await PropertyRunner.run(
            using: generator,
            property:
            {
                int async in
                
                valuesB.append(int)
                TKTarget(Double(int))
            },
            options: options
        )
        
        resultA.assertPassed()
        resultB.assertPassed()
        
        XCTAssertEqual(valuesA, valuesB)
    }
    
    
    
    // MARK: - Classification
    
    @Reasync
    func testLabelAndClassify() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                TKTarget(Double(capture.size))
                TKLabel("all")
                TKClassify("small", when: capture.size < 50)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["all"], iterations)
        XCTAssertGreaterThan(passed.dist["small"] ?? 0, 0)
    }
    
    
    
    @Reasync
    func testCoverageRequirements() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let result: PropertyResult<SizeCapture> = await PropertyRunner.run(
            property:
            {
                capture async in
                
                TKTarget(Double(capture.size))
                TKCover(90, "small", when: capture.size < 50)
            },
            options: options
        )
        
        let covergeNotMet: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
        XCTAssertEqual(covergeNotMet.iterations, iterations)
        XCTAssertEqual(covergeNotMet.unmet.count, 1)
        XCTAssertEqual(covergeNotMet.unmet.first?.label, "small")
    }
}



// MARK: - Support

extension PropertyRunnerTargetTests
{
    private typealias PassedValues          = PassedPropertyValues
    private typealias ExhaustedValues       = ExhaustedPropertyValues
    private typealias CoverageNotMetValues  = CoverageNotMetPropertyValues
    
    
    
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 12345
}



/// A wrapper around `Int` that does not shrink, but does mutate, and tracks
/// whether it was produced by mutation.
///
/// See ``BoundInt`` for more information regarding the range of values.
private struct TargetInt: Arbitrary, Equatable
{
    let value   : Int
    let mutated : Bool
    
    static func arbitrary(
        using context: GenerationContext
    ) -> TargetInt
    {
        return TargetInt(
            value:      context.random(in: 0...max(1, context.size)),
            mutated:    false
        )
    }
    
    func shrink() -> [TargetInt]
    {
        return []
    }
    
    func mutate(
        using context: GenerationContext
    ) -> TargetInt
    {
        return TargetInt(
            value:      value + 1,
            mutated:    true
        )
    }
}
