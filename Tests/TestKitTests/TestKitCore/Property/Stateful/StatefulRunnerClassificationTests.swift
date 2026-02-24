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



internal final class StatefulRunnerClassificationTests: TestKitCase
{
    func testClassifyLabelsAccumulateInPassedResult() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                PropertyInterceptor.current?.recordLabel("always")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["always"], iterations)
    }
    
    
    
    func testCoverageNotMet() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                TKCover(50, "never", when: false)
            },
            options: options
        )
        
        let coverage: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
        XCTAssertEqual(coverage.iterations, iterations)
        XCTAssertEqual(coverage.unmet.count, 1)
        XCTAssertEqual(coverage.unmet.first?.label, "never")
        XCTAssertEqual(coverage.unmet.first?.required, 50)
        XCTAssertEqual(coverage.unmet.first?.actual, 0)
        XCTAssertEqual(coverage.seed, Self.seed)
    }
    
    
    
    func testTableCoverageNotMet() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                TKCoverTable("table", (50, "never"))
            },
            options: options
        )
        
        let coverage: CoverageNotMetValues
            = try XCTUnwrap(result.assertCoverageNotMet())
        
        XCTAssertEqual(coverage.iterations, iterations)
        XCTAssertEqual(coverage.unmet.count, 1)
        XCTAssertEqual(coverage.unmet.first?.table, "table")
        XCTAssertEqual(coverage.unmet.first?.label, "never")
        XCTAssertEqual(coverage.unmet.first?.required, 50)
        XCTAssertEqual(coverage.unmet.first?.actual, 0)
        XCTAssertEqual(coverage.seed, Self.seed)
    }
    
    
    
    func testCoverageNotMetReturnsPassed() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                TKCover(50, "always", when: true)
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
        XCTAssertEqual(passed.dist["always"], iterations)
    }
    
    
    
    func testTableCoverageNotMetReturnsPassed() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                TKCoverTable("table", (50, "always"))
                TKTabulate("table", "always")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
        XCTAssertEqual(passed.tableDist["table"]?["always"], iterations)
    }
    
    
    
    func testDifferentLabelsWithinSingleIteration() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                PropertyInterceptor.current?.recordLabel("a")
                PropertyInterceptor.current?.recordLabel("b")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist["a"], iterations)
        XCTAssertEqual(passed.dist["b"], iterations)
    }
    
    
    
    func testMultipleTablesAccumulateIndependently() async throws
    {
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                TKTabulate("a", "x")
                TKTabulate("b", "y")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.tableDist["a"]?["x"], iterations)
        XCTAssertEqual(passed.tableDist["b"]?["y"], iterations)
        XCTAssertNil(passed.tableDist["a"]?["y"])
        XCTAssertNil(passed.tableDist["b"]?["x"])
    }
    
    
    
    func testClassificationFromRunBody() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[ClassifyCommand]> = await StatefulRunner.run(
            command:    ClassifyCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist[ClassifyCommand.text], iterations)
        
        XCTAssertEqual(
            passed.tableDist[ClassifyCommand.table]?[ClassifyCommand.text],
            iterations
        )
    }
    
    
    
    func testExhaustionIncludesSuccessfulDistributions() async throws
    {
        /// Early iterations have single-command sequences. The invariant
        /// labels those iterations and discards them when the `model >= 2`.
        /// Once sequences grow long enough, all iterations are discarded,
        /// causing exhaustion. The successful iterations' labels must appear
        /// in the distribution.
        
        let iterations      : Int   = 100
        let maxDiscardRatio : Int   = 1
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxDiscardRatio:    maxDiscardRatio,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                PropertyInterceptor.current?.recordLabel("ran")
                
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
        XCTAssertEqual(exhausted.dist["ran"], exhausted.succeeded)
    }
    
    
    
    func testInvariantDiscardOnFirstCommandExhausts() async throws
    {
        /// The invariant discards at `model >= 1`. Since every sequence is
        /// discarded on its first command, none can succeed.
        
        let maxDiscardRatio: Int = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async throws in
                
                PropertyInterceptor.current?.recordLabel("ran")
                
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
        XCTAssertEqual(exhausted.seed, Self.seed)
    }
    
    
    
    func testClassifyLabelsAccumulate() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[LabelCommand]> = await StatefulRunner.run(
            command:    LabelCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.dist[LabelCommand.text], iterations)
    }
    
    
    
    func testTableDistribution() async throws
    {
        /// With these options, each sequence has exactly one increment, so
        /// the model is always `1` in the invariant.
        
        let iterations: Int = 100
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                TKTabulate("model", model == 1 ? "one" : "other")
            },
            options: options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        let modelTable: [String : Int]? = passed.tableDist["model"]
        
        XCTAssertNotNil(modelTable)
        XCTAssertEqual(modelTable?["one"], iterations)
        XCTAssertNil(modelTable?["other"])
    }
    
    
    
    func testTableDistributionOnFailedResult() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                TKTabulate("model", model == 1 ? "one" : "other")
                
                if model >= 3
                {
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, _, tableDist) = result
        else
        {
            XCTFail("Expected failed, got \(result)")
            return
        }
        
        XCTAssertGreaterThan(counterexample.iteration, 1)
        
        let modelTable: [String : Int]? = tableDist["model"]
        
        XCTAssertNotNil(modelTable)
        XCTAssertGreaterThan(modelTable?["one"] ?? 0, 0)
    }
    
    
    
    func testDistributionExcludesFailingIteration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:
            {
                model, _ async in
                
                PropertyInterceptor.current?.recordLabel("ran")
                
                if model >= 3
                {
                    PropertyInterceptor.current?.recordFailure()
                }
            },
            options: options
        )
        
        guard case let .failed(counterexample, dist, _) = result
        else
        {
            XCTFail("Expected failed, got \(result)")
            return
        }
        
        let ranCount: Int = dist["ran"] ?? 0
        
        XCTAssertGreaterThan(ranCount, 0)
        XCTAssertEqual(ranCount, counterexample.iteration - 1)
    }
    
    
    
    func testClassifyLabelsFromRunAccumulateAcrossCommands() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    5,
            seed:               Self.seed
        )
        
        let result: PCR<[LabelCommand]> = await StatefulRunner.run(
            command:    LabelCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        /// Labels are idempotent within an iteration, so even multi-command
        /// sequences count as one label per iteration.
        XCTAssertEqual(passed.dist[LabelCommand.text], iterations)
    }
    
    
    
    func testAssumeInRunCausesExhaustion() async throws
    {
        let maxDiscardRatio: Int = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PCR<[AssumeCommand]> = await StatefulRunner.run(
            command:    AssumeCommand.self,
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
    
    
    
    func testAssumeInInvariantCausesExhaustion() async throws
    {
        let maxDiscardRatio: Int = 2
        
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    maxDiscardRatio,
            seed:               Self.seed
        )
        
        let result: PCR<[IncrementCommand]> = await StatefulRunner.run(
            command:    IncrementCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  { _, _ async throws in try TKAssume(false) },
            options:    options
        )
        
        let exhausted: ExhaustedValues
            = try XCTUnwrap(result.assertExhausted())
        
        XCTAssertEqual(exhausted.succeeded, 0)
        XCTAssertGreaterThan(exhausted.discarded, 0)
        XCTAssertEqual(exhausted.ratio, maxDiscardRatio)
        XCTAssertEqual(exhausted.seed, Self.seed)
    }
    
    
    
    func testCollectInRunRecordsDistribution() async throws
    {
        let iterations: Int = 10
        
        let options: TestOptions = .propertyOptions(
            iterations:         iterations,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let result: PCR<[CollectCommand]> = await StatefulRunner.run(
            command:    CollectCommand.self,
            model:      { 0 },
            system:     { 0 },
            invariant:  nil,
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        /// Each iteration has a single command that increments to `1` and
        /// is collected/labeled as such.
        XCTAssertEqual(passed.dist, ["1": iterations])
    }
}



// MARK: - Support

extension StatefulRunnerClassificationTests
{
    private typealias PCR = PropertyCheckResult
    
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 12345
}
