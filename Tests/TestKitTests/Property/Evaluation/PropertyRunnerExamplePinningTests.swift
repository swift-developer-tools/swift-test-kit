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



internal final class PropertyRunnerExamplePinningTests: TestKitCase
{
    // MARK: - Passing
    
    @Reasync
    func testEmptyExamplesReturnsPassed() async
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples:   [],
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        result.assertPassed()
    }
    
    
    
    @Reasync
    func testSinglePassingExampleReturnsPassed() async
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples:   [BoundInt(5)],
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        result.assertPassed()
    }
    
    
    
    @Reasync
    func testMultiplePassingExamplesReturnsPassed() async
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples:   [BoundInt(0), BoundInt(1), BoundInt(2)],
            property:   { _ async in },
            options:    .propertyOptions(seed: Self.seed)
        )
        
        result.assertPassed()
    }
    
    
    
    @Reasync
    func testPassingExamplesDoNotAffectIterationCount() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples:   [BoundInt(0), BoundInt(1), BoundInt(2)],
            property:   { _ async in },
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        XCTAssertEqual(passed.iterations, iterations)
    }
    
    
    
    // MARK: - Failing
    
    @Reasync
    func testSingleFailingExampleReturnsFailed() async
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples: [BoundInt(50)],
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        result.assertFailed()
    }
    
    
    
    @Reasync
    func testFailedExampleIterationIsZero() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples: [BoundInt(50)],
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.iteration, 0)
    }
    
    
    
    @Reasync
    func testFailedExamplShrinkStepsIsZero() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples: [BoundInt(50)],
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.shrinkSteps, 0)
    }
    
    
    
    @Reasync
    func testFailedExampleValueEqualsOriginalValue() async throws
    {
        let example = BoundInt(50)
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples: [example],
            property:
            {
                _ async in
                
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        XCTAssertEqual(counterexample.value, example)
        XCTAssertEqual(counterexample.originalValue, example)
    }
    
    
    
    @Reasync
    func testFailedExampleCapturesAssertionFailure() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples: [BoundInt(50)],
            property:
            {
                boundInt async in
                
                FailureInterceptor.current?.recordFailure(
                    message:    "\(boundInt)",
                    fileID:     "ID",
                    file:       "File.swift",
                    line:       1,
                    column:     2
                )
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        let counterexample: Counterexample<BoundInt>
            = try XCTUnwrap(result.assertFailed())
        
        let failure: InterceptedFailure
            = try XCTUnwrap(counterexample.failures.first)
        
        XCTAssertEqual(counterexample.failures.count, 1)
        XCTAssertEqual(failure.message, "BoundInt: 50")
        XCTAssertEqual(failure.fileID.description, "ID")
        XCTAssertEqual(failure.file.description, "File.swift")
        XCTAssertEqual(failure.line, 1)
        XCTAssertEqual(failure.column, 2)
    }
    
    
    
    @Reasync
    func testFailedExampleCapturesThrownError() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples:   [BoundInt(50)],
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
    func testFailedExampleCapturesFailureAndThrownError() async throws
    {
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples: [BoundInt(50)],
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
    func testFailedExampleShortCircuits() async
    {
        var evaluatedCount: Int = 0
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples: [BoundInt(1), BoundInt(2), BoundInt(3)],
            property:
            {
                _ async in
                
                evaluatedCount += 1
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        result.assertFailed()
        
        /// The evaluation runs twice: once to detect the failure and once to
        /// capture assertion output. Random iterations never run since the
        /// examples fail first.
        XCTAssertEqual(evaluatedCount, 2)
    }
    
    
    
    @Reasync
    func testFailedExampleBypassesRandomIterations() async
    {
        var values: [Int] = []
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples: [BoundInt(99)],
            property:
            {
                boundInt async in
                
                values.append(boundInt.value)
                FailureInterceptor.current?.recordFailure()
            },
            options: .propertyOptions(seed: Self.seed)
        )
        
        result.assertFailed()
        
        /// The only values evaluated must be the pinned example, called
        /// twice: once to detect the failure and once to capture assertion
        /// output. Random iterations never run since the example fails first.
        XCTAssertEqual(values, [99, 99])
    }
    
    
    
    // MARK: - Discarded
    
    @Reasync
    func testDiscardedExampleDoesNotCauseFailure() async
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples:   [BoundInt(0)],
            property:   { _ async throws in try TKAssume(false) },
            options:    options
        )
        
        result.assertExhausted()
    }
    
    
    
    // MARK: - Distribution
    
    @Reasync
    func testPassingExamplesContributeToDistribution() async throws
    {
        let iterations: Int = 50
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples:   [BoundInt(0), BoundInt(1)],
            property:   { _ async in TKLabel("all") },
            options:    options
        )
        
        let passed: PassedValues = try XCTUnwrap(result.assertPassed())
        
        /// The two pinned examples plus `iterations` all record the same label.
        XCTAssertEqual(passed.dist["all"], iterations + 2)
    }
    
    
    
    // MARK: - Ordering
    
    @Reasync
    func testExamplesRunBeforeRandomIterations() async
    {
        let iterations  : Int       = 10
        let maxSize     : Int       = 100
        var values      : [Int]     = []
        
        let examples: [BoundInt] =
        [
            .init(1000),
            .init(2000),
            .init(3000)
        ]
        
        let options: TestOptions = .propertyOptions(
            iterations:     iterations,
            maxSize:        maxSize,
            seed:           Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples:   examples,
            property:   { boundInt async in values.append(boundInt.value) },
            options:    options
        )
        
        result.assertPassed()
        
        XCTAssertEqual(values.count, examples.count + iterations)
        XCTAssertEqual(values[0], 1000)
        XCTAssertEqual(values[1], 2000)
        XCTAssertEqual(values[2], 3000)
        
        for index in examples.count..<values.count
        {
            XCTAssertLessThanOrEqual(values[index], maxSize)
        }
    }
    
    
    
    @Reasync
    func testPassingExamplesFollowedByRandomFailure() async throws
    {
        let target: Int = 10
        
        let options: TestOptions = .propertyOptions(
            maxSize:    200,
            seed:       Self.seed
        )
        
        let result: PropertyResult<BoundInt> = await PropertyRunner.run(
            examples: [BoundInt(0), BoundInt(1)],
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
        XCTAssertGreaterThan(counterexample.iteration, 0)
        XCTAssertGreaterThan(counterexample.shrinkSteps, 0)
    }
}



// MARK: - Support

extension PropertyRunnerExamplePinningTests
{
    private typealias PassedValues = PassedPropertyValues
    
    
    
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 12345
}
