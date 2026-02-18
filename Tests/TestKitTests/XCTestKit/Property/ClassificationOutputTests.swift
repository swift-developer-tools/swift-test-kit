//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTestKit
import XCTest



internal final class ClassificationOutputTests: XCTestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Coverage not met
    
    @Reasync
    func testCoverageNotMetSingleLabel() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKCover(100, "negative", when: n < 0)
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            negative: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetMultipleLabels() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKCover(100, "negative", when: n < 0)
                XCTKCover(100, "positive", when: n > 0)
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            negative:   0% (required: 100%) ←
            positive: 100%
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetWithMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                message:    "hello world",
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKCover(100, "negative", when: n < 0)
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            negative: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetSingleIteration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKCover(100, "negative", when: n < 0)
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll coverage not met after 1 iteration
        
        Coverage:
            negative: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetMultipleUnmetLabels() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(0),
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKCover(50, "negative", when: n < 0)
                XCTKCover(50, "positive", when: n > 0)
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            negative: 0% (required: 50%) ←
            positive: 0% (required: 50%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetNonIntegerReq() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKCover(2.5, "negative", when: n < 0)
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            negative: 0% (required: 2.5%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetWithClassifyLabels() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKClassify("positive", when: n > 0)
                XCTKCover(100, "negative", when: n < 0)
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            negative:   0% (required: 100%) ←
            positive: 100%
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetPartialCoverage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The sizes produced are `0`, `10`, `20`, ... `90`. Only values
        /// below `30` satisfy the `small` condition.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKCover(50, "small", when: n < 30)
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            small: 30% (required: 50%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Counterexample
    
    @Reasync
    func testCounterexampleWithDist() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The first iteration has size `0` and passes. The second has size
        /// `50` and fails.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKLabel("tracked")
                XCTKAssertLessThan(n, 50)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 1 (50%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleWithMultipleDistLabels() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     5,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The first three iterations produces sizes `0`, `20`, and `40`
        /// (all pass). The fourth iteration produces size `60` (fails).
        /// Classification executes before the assertion, so the failing
        /// iteration's labels are recorded but not finalized. The
        /// distribution reflects the three finalized iterations.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKClassify("small", when: n < 30)
                XCTKClassify("large", when: n >= 30)
                XCTKAssertLessThan(n, 60)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 4 iterations
        
        Counterexample:
            Int = 60
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            large: 1 (25%)
            small: 2 (50%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleWithShrinkingAndDist() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The first iteration produces size `0` and generates `0`, and
        /// passes with a label. The second iteration produces size `50` and
        /// generates `100`, fails, and shrinks.
        let generator = Generator<Int>(
            generate:   { context in context.size >= 50 ? 100 : 0 },
            shrink:     { value in value.shrink() }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKLabel("tracked")
                XCTKAssertLessThan(n, 10)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations (shrunk in 4 steps)
        
        Counterexample:
            Int = 10
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 1 (50%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleDistWithNonIntegerPercentage() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     3,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The first three iterations produces sizes of `0`, `33`, and `66`,
        /// with the first two passing and the third failing.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKLabel("tracked")
                XCTKAssertLessThan(n, 50)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 3 iterations
        
        Counterexample:
            Int = 66
        
        \(Self.seedMessage)
        
        Distribution (3 iterations):
            tracked: 2 (66.7%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleWithThrownErrorAndDist() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The first iteration produces a size of `0` and passes with a label.
        /// The second iteration produces a size of `50` and throws an error.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                XCTKLabel("tracked")
                
                if n >= 50
                {
                    throw TestError()
                }
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 1 (50%)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleFirstIterationFailureOmitsDist() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            seed:           Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(options: options)
            {
                (_: Int) async in
                
                XCTKLabel("tracked")
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        XCTAssertFalse(output?.contains("Distribution") ?? true)
        XCTAssertFalse(output?.contains("tracked") ?? true)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleDistWithLabelsAfterAssertion() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     3,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The first two iterations produce sizes of `0` and `33` (both pass).
        /// The third iteration produces a size of `66` and fails. Non-throwing
        /// assertions record the failure, but do not stop execution, so any
        /// labels placed after the assertion still execute on every iteration.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKLabel("before")
                XCTKAssertLessThan(n, 60)
                XCTKLabel("after")
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 3 iterations
        
        Counterexample:
            Int = 66
        
        \(Self.seedMessage)
        
        Distribution (3 iterations):
            after:  2 (66.7%)
            before: 2 (66.7%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleDistWithLabelsAfterThrow() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     3,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The first two iterations produce sizes of `0` and `33` (both pass).
        /// The third iteration produces a size of `66` and fails. Thrown
        /// errors stop execution, so any labels placed after the `throw` do
        /// not execute on the throwing iteration. Labels from passing
        /// iterations are still finalized.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                XCTKLabel("before")
                
                if n >= 60
                {
                    throw TestError()
                }
                
                XCTKLabel("after")
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll failed after 3 iterations
        
        Counterexample:
            Int = 66
        
        \(Self.seedMessage)
        
        Distribution (3 iterations):
            after:  2 (66.7%)
            before: 2 (66.7%)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Exhaustion
    
    @Reasync
    func testExhaustionWithDist() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         5,
            maxSize:            100,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        /// The first two iterations produce sizes `0` and `20` (both pass the
        /// precondition). The third iteration produces a size `40` (fails the
        /// precondition), and all subsequent iterations remain at size `40`,
        /// since the number of successful iterations does not advance. After
        /// six discards, the test exhausts.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                where:      { $0 < 30 },
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKLabel("tracked")
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll exhausted after 2 successful iterations
        
            6 inputs discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 2 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Failed iteration
    
    @Reasync
    func testFailedIterationLabelsNotInDist() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// The first two iteration produces size `0`, passes, and finalizes.
        /// The second iteration produces size `50` and fails. `tracked` and
        /// `large` are recorded but never finalized, so only the first
        /// iteration's `tracked` appears in the distribution.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKLabel("tracked")
                XCTKClassify("large", when: n >= 50)
                XCTKAssertLessThan(n, 50)
            }
        }
        
        XCTAssertNotNil(output)
        XCTAssertFalse(output?.contains("large") ?? true)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 1 (50%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Collect
    
    @Reasync
    func testCoverageNotMetWithCollect() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKCollect(n)
                XCTKCover(100, "negative", when: n < 0)
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            5:        100%
            negative:   0% (required: 100%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
}



// MARK: - Support

extension ClassificationOutputTests
{
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 50
    
    /// The re-run message.
    private static let seedMessage: String =
        "Seed: \(seed) (re-run with PropertyOptions.seed)"
}
