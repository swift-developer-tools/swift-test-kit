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
@testable import struct TestKitCore.StatefulRunner
@testable import struct TestKitCore.StatefulResult



internal final class StatefulRunnerTests: TestKitCase
{
    // MARK: - Passing
    
    func testPassingPropertyReturnsPassed() async throws
    {
        let iterations  : Int       = 50
        let seed        : UInt64    = 99
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
        XCTAssertEqual(passed.seed, seed)
    }
    
    
    
    func testZeroIterationsVacuouslyPasses() async throws
    {
        let iterations: Int = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    func testSinglePassingIterationReturnsPassed() async throws
    {
        let iterations: Int = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    func testMaxCommandCountOneLimitsSequenceCount() async throws
    {
        /// With these options, the sequence count formula produces sequences
        /// with counts of `1` for all iterations. The invariant fails at
        /// `model > 1`, so the failure is never triggered.
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model > 1
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    func testNewModelSystemPerIteration() async throws
    {
        /// Each iteration receives new model and system instances from the
        /// given factories. With these options, the model reachs at most `5`
        /// per iteration. If state leaks across iterations, the model would
        /// grow past this threshold and trigger the invariant.
        
        let maxCommandCount: Int = 5
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxCommandCount:    maxCommandCount,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, system async in
                
                if
                    model > maxCommandCount
                    || system > maxCommandCount
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    func testLargeIterationCount() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    func testModelSystemConsistencyAcrossSequence() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxShrinkSteps:     0,
            maxCommandCount:    20,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, system async in
                
                if model != system
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    // MARK: - Failing
    
    func testInvariantFailureOnFirstCommandReturnsFailed() async throws
    {
        let target: Int = 1
        
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.iteration, target)
        XCTAssertEqual(counterexample.failingStep, target)
    }
    
    
    
    func testInvariantFailureReportsCorrectStep() async throws
    {
        /// With these options, the sequence count formula produces sequences
        /// with counts of `1, 1, 2, 3, 4, ...`. The invariant fails at
        /// `model >= 3`, so the first sequence of count `3` fails at step `3`.
        
        let target: Int = 3
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.failingStep, target)
        XCTAssertGreaterThanOrEqual(counterexample.value.count, target)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testThrowingInvariantReturnFailed() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  { _, _ async throws in throw TestError() },
            options:    options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
        XCTAssertTrue(counterexample.failures.isEmpty)
    }
    
    
    
    func testInvariantFailureAndThrowCapturesBoth() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                _, _ async throws in
                
                FailureInterceptor.current?.recordFailure()
                
                throw TestError()
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
        XCTAssertEqual(counterexample.failures.count, 1)
    }
    
    
    
    func testSingleFailingIteration() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                _, _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.iteration, 1)
        XCTAssertEqual(counterexample.value.count, 1)
        XCTAssertGreaterThan(counterexample.failures.count, 0)
    }
    
    
    
    // MARK: - Seed
    
    func testSameSeedDeterminism() async
    {
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            seed:               Self.seed
        )
        
        let invariant: (Int,  Int) async -> Void =
        {
            model, _ async in
            
            if model >= 3
            {
                FailureInterceptor.current?.recordFailure()
            }
        }
        
        let resultA: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  invariant,
            options:    options
        )
        
        let resultB: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  invariant,
            options:    options
        )
        
        switch (resultA.propertyCheck, resultB.propertyCheck)
        {
            case let (
                .failed(counterA, _, _),
                .failed(counterB, _, _)
            ):
            
                XCTAssertEqual(counterA.iteration, counterB.iteration)
                XCTAssertEqual(counterA.seed, counterB.seed)
                XCTAssertEqual(counterA.value, counterB.value)
                XCTAssertEqual(counterA.failingStep, counterB.failingStep)
                
            default:
                
                XCTFail("Expected both .failed, got \(resultA) and \(resultB)")
        }
    }
    
    
    
    func testCounterexampleSeedMatchesConfiguredSeed() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                _, _ async throws in
                
                FailureInterceptor.current?.recordFailure()
                
                throw TestError()
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.seed, Self.seed)
    }
    
    
    
    func testFailureWithNilSeed() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               nil
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                _, _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: options
        )
        
        _ = try XCTUnwrap(result.assertFailed())
    }
    
    
    
    // MARK: - Exhaustion
    
    func testExhaustionFromInvariantDiscards() async throws
    {
        let iterations      : Int   = 10
        let maxDiscardRatio : Int   = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  { _, _ async throws in throw DiscardError() },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertGreaterThan(exhausted.discarded, 0)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
    }
    
    
    
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
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunDiscardCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, threshold + 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
    }
    
    
    
    func testMaxDiscardRatioZeroExhaustsOnFirstDiscard() async throws
    {
        let maxDiscardRatio: Int = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunDiscardCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertEqual(exhausted.discarded, 1)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    func testDivergentAdvanceAndRunTreatedAsDiscard() async throws
    {
        /// During shrinking reply, the model advances by `2` per step rather
        /// than `1`, causing a divergence. Candidates that were valid during
        /// generation may become invalid during shrinking, since the
        /// precondition requires `model < 5`. However, shrinking must still
        /// produce a valid counterexample.
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    DivergentCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
            
                if model >= DivergentCommand.threshold
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[DivergentCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertGreaterThan(counterexample.value.count, 0)
    }
    
    
    
    // MARK: - Shrinking
    
    func testRemovalShrinkingReducesSequenceCount() async throws
    {
        let target      : Int   = 3
        let iterations  : Int   = 10
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, target)
        XCTAssertEqual(counterexample.originalValue.count, iterations)
        XCTAssertEqual(counterexample.shrinkSteps, 2)
        XCTAssertEqual(counterexample.failingStep, target)
    }
    
    
    
    func testZeroMaxShrinkStepsDisablesShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= 3
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, counterexample.originalValue)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testMaxShrinkStepsLimitsRemovalShrinking() async throws
    {
        /// Starting from 10 commands, one rmeoval step with a chunk size of
        /// 5 shrinks to 5 commands. The step limit prevents further reduction.
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     1,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= 3
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, 5)
        XCTAssertEqual(counterexample.shrinkSteps, 1)
    }
    
    
    
    func testArgShrinkingReducesAmounts() async throws
    {
        /// With these options, all sequences are single commands. Removal
        /// shrinking cannot help since the chunk size is zero. Argument
        /// shrinking converges from the initial large amount to the minimal
        /// failing value of `.add(6)`.
        
        let target: Int = 5
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    AmountCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[AmountCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, [.add(target + 1)])
        XCTAssertEqual(counterexample.value.count, 1)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testShrunkenSequenceSatisfiesPrecondition() async throws
    {
        /// Removal shrinking may produces candidates where a `.pop` appears
        /// at a depth of zero, triggering the `.invalid` replay path. The
        /// shrunken sequence must still satisfy all the preconditions.
        
        let target: Int = 3
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxCommandCount:    20,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    StackCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[StackCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        var model: Int = 0
        
        for command in counterexample.value
        {
            XCTAssertTrue(command.precondition(model: model))
            
            command.advance(model: &model)
        }
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testCombinedRemovalAndArgShrinking() async throws
    {
        let target: Int = 5
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    AmountCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[AmountCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, [.add(target + 1)])
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        /// The original sequence must have more commands and/or larger
        /// amounts than the shrunken sequence.
        XCTAssertTrue(
            counterexample.originalValue.count > 1
            || counterexample.originalValue != counterexample.value
        )
    }
    
    
    
    func testRunFailureShrinkingReducesSequence() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunFailCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let counterexample: Counterexample<[RunFailCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, RunFailCommand.threshold)
        XCTAssertEqual(counterexample.failingStep, RunFailCommand.threshold)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        XCTAssertGreaterThan(
            counterexample.originalValue.count,
            counterexample.value.count
        )
    }
    
    
    
    func testRemovalShrinkingSkipsInvalidCandidates() async throws
    {
        let target: Int = 5
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxCommandCount:    20,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    StackCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[StackCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        XCTAssertLessThan(
            counterexample.value.count,
            counterexample.originalValue.count
        )
        
        /// The shrunken sequence must be the minimal path to reach the target,
        /// which is exactly `target` pushes.
        XCTAssertEqual(
            counterexample.value,
            Array(repeating: .push, count: target)
        )
    }
    
    
    
    func testArgShrinkingRestartsFromStart() async throws
    {
        /// With these options, later iterations produce two-command sequences.
        /// The invariant fails when the cumulative model exceeds `target`.
        /// Both commands must be shrunk to their minimums. If the restart did
        /// not occur, only the second command would be shrunk. The minimal
        /// failing sequence is `[.add(2)]`, since removal shrinks to one
        /// command, and argument shrinking converges to `target + 1`.
        
        let target: Int = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxCommandCount:    2,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    AmountCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[AmountCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, [.add(target + 1)])
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testOriginalValuePreservedAfterShrinking() async throws
    {
        let target: Int = 3
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, target)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        XCTAssertGreaterThan(
            counterexample.originalValue.count,
            counterexample.value.count
        )
    }
    
    
    
    func testFailingStepMatchesShrunkenSequence() async throws
    {
        let target: Int = 3
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        XCTAssertEqual(counterexample.value.count, target)
        XCTAssertEqual(counterexample.failingStep, target)
        
        /// The original sequence was longer. If the failing step referred to
        /// the original position, it would exceed the count of the shrunken
        /// sequence.
        XCTAssertLessThanOrEqual(
            counterexample.failingStep!,
            counterexample.value.count
        )
    }
    
    
    
    func testBoundCommandRemovalShrinkingRemovesNoOps() async throws
    {
        let target: Int = BoundCommand.bound
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    BoundCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[BoundCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        XCTAssertEqual(
            counterexample.value,
            Array(repeating: .increment, count: target)
        )
        
        /// The original sequence must have contained some no-ops.
        XCTAssertGreaterThan(
            counterexample.originalValue.count,
            counterexample.value.count
        )
    }
    
    
    
    func testShrunkenCounterexampleCapturesThrownError() async throws
    {
        /// With long sequences, removal shrinking reduces to a single command.
        /// The final replay must capture the thrown error.
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunThrowCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let counterexample: Counterexample<[RunThrowCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, RunThrowCommand.threshold)
        XCTAssertEqual(counterexample.shrinkSteps, 0)
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
        XCTAssertTrue(counterexample.failures.isEmpty)
    }
    
    
    
    func testMaxShrinkStepsSharedBetweenRemovalAndArgShrinking() async throws
    {
        /// The shrinking budget is consumed before argument shrinking can
        /// be performed. The sequence count is reduced, but arguments are not.
        
        let target          : Int   = 5
        let maxShrinkSteps  : Int   = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     maxShrinkSteps,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    AmountCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model > target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[AmountCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.shrinkSteps, maxShrinkSteps)
        XCTAssertNotEqual(counterexample.value, [.add(target + 1)])
    }
    
    
    
    func testMinimalStackSequencesRequiresOnlyPush() async throws
    {
        let target: Int = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxCommandCount:    20,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    StackCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[StackCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    func testMaxShrinkStepsOnePerformsExactlyOneRemoval() async throws
    {
        let maxShrinkSteps: Int = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     maxShrinkSteps,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= 3
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, 5)
        XCTAssertEqual(counterexample.shrinkSteps, maxShrinkSteps)
    }
    
    
    
    func testNewModelAndSystemPerShrinkReplay() async throws
    {
        let target: Int = 3
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, system async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
                
                if model != system
                {
                    /// If state leaked, the model and system will diverge.
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, target)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        XCTAssertEqual(counterexample.failures.count, 1)
    }
    
    
    
    func testArgShrinkingSkipsUnimprovedCandidates() async throws
    {
        /// Since the invariant fails at `model >= target`, replacing any
        /// `.increment` with `.noOp` reduces the model below the threshold,
        /// so no argument shrinking candidate reproduces the failure. Removal
        /// shrinking reduces the sequence to exactly `target` commands, then
        /// argument shrinking tries but cannot further improve. The shrunken
        /// sequence must contain only `.increment` commands.
        
        let target: Int = 3
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    ShrinkableIncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[ShrinkableIncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, target)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        XCTAssertEqual(
            counterexample.value,
            Array(repeating: .increment, count: target)
        )
        
        XCTAssertGreaterThan(
            counterexample.originalValue.count,
            counterexample.value.count
        )
    }
    
    
    
    // MARK: Model-aware shrinking
    
    func testModelAwareShrinkUsesModelState() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     100,
            maxSize:            100,
            maxCommandCount:    5,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    ModelAwareShrinkCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        guard case let .failed(counterexample, _, _) = result.propertyCheck
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        var model: Int = 0
        
        for command in counterexample.value
        {
            guard case let .add(n) = command
            else
            {
                XCTFail("Expected .add, got \(command)")
                return
            }
            
            let expected: Int
                = max(1, ModelAwareShrinkCommand.threshold - model)
            
            /// Each command's value must be exactly what the model-aware
            /// shrink method produces: `max(1, threshold - modelAtIndex)`.
            XCTAssertEqual(n, expected)
            
            model += n
        }
    }
    
    
    
    func testModelAwareShrinkDefaultDelegation() async
    {
        let maxCommandCount: Int = 10
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     100,
            maxSize:            100,
            maxCommandCount:    maxCommandCount,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    AmountCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, system in
                
                if model >= maxCommandCount
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, _, _) = result.propertyCheck
        else
        {
            XCTFail("Expected .failed, got \(result)")
            return
        }
        
        let shrunkenTotal: Int = counterexample.value.reduce(0)
        {
            guard case let .add(n) = $1
            else
            {
                return $0
            }
            
            return $0 + n
        }
        
        XCTAssertGreaterThanOrEqual(shrunkenTotal, maxCommandCount)
        
        let originalTotal: Int = counterexample.originalValue.reduce(0)
        {
            guard case let .add(n) = $1
            else
            {
                return $0
            }
            
            return $0 + n
        }
        
        XCTAssertLessThanOrEqual(shrunkenTotal, originalTotal)
        
        XCTAssertLessThanOrEqual(
            counterexample.value.count,
            counterexample.originalValue.count
        )
    }
    
    
    
    // MARK: - Run failure
    
    func testCommandRunFailureReportsCorrectStep() async throws
    {
        /// Failures originating in ``Stateful/run(model:system:)`` rather
        /// than in the invariant must be detected and report the correct step.
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunFailCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let counterexample: Counterexample<[RunFailCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.failingStep, RunFailCommand.threshold)
        XCTAssertEqual(counterexample.failures.count, 1)
        XCTAssertNil(counterexample.thrownError)
        
        XCTAssertGreaterThanOrEqual(
            counterexample.value.count,
            RunFailCommand.threshold
        )
    }
    
    
    
    func testRunDiscardCausesExhaustion() async throws
    {
        let maxDiscardRatio: Int = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunDiscardCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertGreaterThan(exhausted.discarded, 0)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
    }
    
    
    
    func testRunThrowReturnsFailed() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunThrowCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let counterexample: Counterexample<[RunThrowCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.failingStep, RunThrowCommand.threshold)
        XCTAssertTrue(counterexample.failures.isEmpty)
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
    }
    
    
    
    func testRunFailThrowCapturesBoth() async throws
    {
        let options: TestOptions = .propertyOptions(
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunFailThrowCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let counterexample: Counterexample<[RunFailThrowCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.failures.count, 1)
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
    }
    
    
    
    // MARK: - Invariant
    
    func testInvariantReceivesPostCommandState() async throws
    {
        /// The invariant must receive the model and system states after the
        /// command is executed. If it received the pre-command state, the
        /// model would be zero after the first increment, causing the
        /// invariant to fail.
        
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, system async in
                
                if
                    model < 1
                    || system < 1
                    || model != system
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    func testInvariantSkippedAfterRunFailure() async throws
    {
        /// A failure is recorded at step `3`. The invariant would record an
        /// additional failure if it were called. The counterexample must have
        /// exactly one failure, since the invariant must be skipped for the
        /// failing step.
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunFailCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= RunFailCommand.threshold
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[RunFailCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.failures.count, 1)
        XCTAssertEqual(counterexample.failingStep, RunFailCommand.threshold)
    }
    
    
    
    func testFirstCommandInvariantDiscardCausesExhaustion() async throws
    {
        /// The invariant discards at `model >= 1`, causing exhaustion since
        /// every sequence is discarded on its first command.
        
        let maxDiscardRatio: Int = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= 1
                {
                    throw DiscardError()
                }
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertGreaterThan(exhausted.discarded, 0)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    func testMidSequenceInvariantDiscardCausesExhaustion() async throws
    {
        /// Single-command sequences succeed. The invariant discards at
        /// `model >= 2`, causing exhaustion.
        
        let iterations      : Int   = 100
        let maxDiscardRatio : Int   = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxDiscardRatio:    maxDiscardRatio,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= 2
                {
                    throw DiscardError()
                }
            },
            options: options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertGreaterThan(exhausted.succeeded, 0)
        XCTAssertGreaterThan(exhausted.discarded, 0)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
    }
    
    
    
    func testInvariantThrowDuringShrinkingContinuesShrinking() async throws
    {
        let target: Int = 3
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= target
                {
                    throw TestError()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, target)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        XCTAssertNotNil(counterexample.thrownError)
        XCTAssertTrue(counterexample.thrownError is TestError)
    }
    
    
    
    func testRunAndInvariantSimultaneousFailure() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    RunFailCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                if model >= RunFailCommand.threshold
                {
                    FailureInterceptor.current?.recordFailure(
                        message:    "invariant",
                        fileID:     "ID",
                        file:       "File.swift",
                        line:       1,
                        column:     2
                    )
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[RunFailCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        /// The invariant failure must be skipped.
        XCTAssertEqual(counterexample.failures.count, 1)
        XCTAssertNotEqual(counterexample.failures.first?.message, "invariant")
    }
    
    
    
    // MARK: - Command count
    
    func testSequenceCountScalesWithIterations() async throws
    {
        /// With these options, the first iteration generates one command,
        /// and command sequences grow gradually. The threshold of `model >= 5`
        /// is unreachable in early iterations, so the failure must occur at
        /// a later iteration.
        
        let target: Int = 5
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    20,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertGreaterThan(counterexample.iteration, 1)
        XCTAssertEqual(counterexample.value.count, target)
    }
    
    
    
    func testSequenceCountMinimumIsOne() async throws
    {
        /// Even at `succeeded = 0`, the sequence count is `max(1, 0)`. The
        /// threshold of `model >= 1` fails on the first iteration.
        
        let target: Int = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.iteration, target)
        XCTAssertEqual(counterexample.value.count, target)
    }
    
    
    
    func testMaxCommandCountZeroGeneratesOneCommand() async throws
    {
        /// There is at least one command per sequence. With these options,
        /// all sequences have exactly one command. The invariant fails at
        /// `model > 1`, which is unreachable with single-command sequences.
        
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxCommandCount:    0,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model > 1
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    // MARK: - Assertion output
    
    func testShrunkenCounterexampleCapturesAssertionOutput() async throws
    {
        /// The final replay after shrinking must capture the assertion output
        /// associated with the shrunken sequence, not the original sequence.
        
        let target: Int = 3
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure(
                        message:    "model \(model)",
                        fileID:     "ID",
                        file:       "File.swift",
                        line:       1,
                        column:     2
                    )
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[IncrementCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, target)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        
        let failure: InterceptedFailure
            = try XCTUnwrap(counterexample.failures.first)
        
        XCTAssertEqual(failure.message, "model \(target)")
        XCTAssertEqual(failure.fileID.description, "ID")
        XCTAssertEqual(failure.file.description, "File.swift")
        XCTAssertEqual(failure.line, 1)
        XCTAssertEqual(failure.column, 2)
    }
    
    
    
    // MARK: - Precondition
    
    func testPreconditionFiltersDuringGeneration() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxShrinkSteps:     0,
            maxCommandCount:    20,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    BoundCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, system async in
                
                if
                    model > BoundCommand.bound
                    || system > BoundCommand.bound
                    || model != system
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    // MARK: - Postcondition
    
    func testDefaultPostconditionPasses() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     50,
            seed:           Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    func testPostconditionFailureCausesFailedResult() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    PostCFailCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let counterexample: Counterexample<[PostCFailCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.failingStep, PostCFailCommand.threshold)
        
        XCTAssertGreaterThanOrEqual(
            counterexample.value.count,
            PostCFailCommand.threshold
        )
    }
    
    
    
    func testPostconditionMessageContainsStep() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    PostCFailCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let counterexample: Counterexample<[PostCFailCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        let failure: InterceptedFailure
            = try XCTUnwrap(counterexample.failures.first)
        
        XCTAssertTrue(failure.message.contains("Postcondition failed"))
        
        XCTAssertTrue(
            failure.message.contains("step \(PostCFailCommand.threshold)")
        )
    }
    
    
    
    func testPostconditionReceivesPostRunState() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         20,
            maxCommandCount:    5,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    PostCStateCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        _ = try XCTUnwrap(result.assertPassed())
    }
    
    
    
    func testRunFailureSkipsPostcondition() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    PostCAfterRunFailCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let counterexample: Counterexample<[PostCAfterRunFailCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        /// The postcondition must not have been called during either the
        /// initial failing run or the final replay after shrinking.
        XCTAssertEqual(PostCAfterRunFailCommand.postconditionCallCount, 0)
        
        let failure: InterceptedFailure
            = try XCTUnwrap(counterexample.failures.first)
        
        /// The failure must be from the failing run, not the postcondition.
        XCTAssertEqual(failure.message, PostCAfterRunFailCommand.message)
        XCTAssertFalse(failure.message.contains("Postcondition failed"))
    }
    
    
    
    func testPostconditionFailureSkipsInvariant() async throws
    {
        var invariantCallCount: Int = 0
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    PostCSkipsInvariantCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                _, _ async in
                
                invariantCallCount += 1
            },
            options: options
        )
        
        _ = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(invariantCallCount, 0)
    }
    
    
    
    func testPostconditionFailureShrinkable() async throws
    {
        let target: Int = PostCFailCommand.threshold
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    PostCFailCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let counterexample: Counterexample<[PostCFailCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value.count, target)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
        XCTAssertEqual(counterexample.failingStep, target)
        
        XCTAssertGreaterThan(
            counterexample.originalValue.count,
            counterexample.value.count
        )
    }
    
    
    
    // MARK: - Size
    
    func testSizeProgressionScalesWithIterations() async throws
    {
        /// With these options, each iteraiton has exactly one command, so
        /// the model equals the generation size for that iteration. The
        /// first iteration where `size >= target` is `succeeded = 5`, or
        /// the 6th iteration.
        
        let target      : Int   = 50
        let iterations  : Int   = 10
        let maxSize     : Int   = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxShrinkSteps:     0,
            maxSize:            maxSize,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: StatefulResult = await StatefulRunner.run(
            command:    SizeCaptureCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= target
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let counterexample: Counterexample<[SizeCaptureCommand]>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.iteration, 6)
        XCTAssertEqual(counterexample.value, [.size(target)])
    }
    
    
    
    // MARK: - Concurrency
    
    func testConcurrentIsolationBothPassing() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         50,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        async let resultA: StatefulResult = StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, system async in
                
                if model != system
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        async let resultB: StatefulResult = StatefulRunner.run(
            command:    StackCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, system async in
                
                if
                    model != system
                    || model < 0
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        let (a, b) = await (resultA, resultB)
        
        _ = try XCTUnwrap(a.assertPassed())
        _ = try XCTUnwrap(b.assertPassed())
    }
    
    
    
    func testConcurrentIsolationOneFailing() async throws
    {
        /// If interceptor state leaks between tasks, one run's failures
        /// would contaminate the other.
        
        let optionsA: TestOptions = .propertyOptions(
            iterations:         50,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        let optionsB: TestOptions = .propertyOptions(
            iterations:         50,
            maxShrinkSteps:     0,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        async let resultA: StatefulResult = StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                if model >= 3
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: optionsA
        )
        
        async let resultB: StatefulResult = StatefulRunner.run(
            command:    StackCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, system async in
                
                if model != system
                {
                    FailureInterceptor.current?.recordFailure()
                }
            },
            options: optionsB
        )
        
        let (a, b) = await (resultA, resultB)
        
        _ = try XCTUnwrap(a.assertFailed())
        _ = try XCTUnwrap(b.assertPassed())
    }
}



// MARK: - Support

extension StatefulRunnerTests
{
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 12345
}
