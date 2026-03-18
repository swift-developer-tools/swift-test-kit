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



internal final class ClassificationOutputTests: TestKitCase
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKCover(100, "negative", when: n < 0)
            }
        }
        
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKCover(100, "negative", when: n < 0)
                TKCover(100, "positive", when: n > 0)
            }
        }
        
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
    func testCoverageNotMetMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                message:    "hello world",
                options:    options
            )
            {
                (n: Int) async in
                
                TKCover(100, "negative", when: n < 0)
            }
        }
        
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
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKCover(100, "negative", when: n < 0)
            }
        }
        
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
            await TKForAll(
                using:      Generator<Int>.constant(0),
                options:    options
            )
            {
                (n: Int) async in
                
                TKCover(50, "negative", when: n < 0)
                TKCover(50, "positive", when: n > 0)
            }
        }
        
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
    func testCoverageNotMetNonIntegerRequirement() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKCover(2.5, "negative", when: n < 0)
            }
        }
        
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
    func testCoverageNotMetClassifyLabels() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKClassify("positive", when: n > 0)
                TKCover(100, "negative", when: n < 0)
            }
        }
        
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
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKCover(50, "small", when: n < 30)
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            small: 30% (required: 50%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetSingleTable() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("sign", n > 0 ? "positive" : "non-positive")
                TKCoverTable("sign", (50, "positive"), (50, "negative"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            Table "sign":
                negative:   0% (required: 50%) ←
                positive: 100%
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetTableMultipleUnmetLabels() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(0),
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("sign", n > 0
                    ? "positive" : n < 0
                    ? "negative" : "zero"
                )
                
                TKCoverTable("sign", (50, "positive"), (50, "negative"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            Table "sign":
                negative:   0% (required: 50%) ←
                positive:   0% (required: 50%) ←
                zero:     100%
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetTableAndFlatCoverage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKCover(100, "negative", when: n < 0)
                TKTabulate("size", n < 100 ? "small" : "large")
                TKCoverTable("size", (50, "small"), (50, "large"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            negative: 0% (required: 100%) ←
        
            Table "size":
                large:   0% (required: 50%) ←
                small: 100%
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetMultipleTables() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("parity", n % 2 == 0 ? "even" : "odd")
                TKCoverTable("parity", (50, "even"), (50, "odd"))
                
                TKTabulate("size", n > 0 ? "positive" : "negative")
                TKCoverTable("size", (50, "positive"), (50, "negative"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            Table "parity":
                even:   0% (required: 50%) ←
                odd:  100%
        
            Table "size":
                negative:   0% (required: 50%) ←
                positive: 100%
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetTableMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                message:    "hello world",
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("size", n > 0 ? "positive" : "negative")
                TKCoverTable("size", (100, "negative"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 1 iteration
        
        Coverage:
            Table "size":
                negative:   0% (required: 100%) ←
                positive: 100%
        
        \(Self.seedMessage)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetTablePartialCoverage() async
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
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("size", n < 30 ? "small" : "large")
                TKCoverTable("size", (50, "small"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            Table "size":
                large: 70%
                small: 30% (required: 50%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetTableNonIntegerRequirement() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("sign", n > 0 ? "positive" : "negative")
                TKCoverTable("sign", (2.5, "negative"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            Table "sign":
                negative:   0% (required: 2.5%) ←
                positive: 100%
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetTableWithoutTabulate() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        /// The requirements are registered, but there are no calls to record
        /// the labels, so the table has 0% for both labels.
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (_: Int) async in
                
                TKCoverTable("sign", (50, "positive"), (50, "negative"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            Table "sign":
                negative: 0% (required: 50%) ←
                positive: 0% (required: 50%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCoverageNotMetTableSingleIteration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("sign", n > 0 ? "positive" : "negative")
                TKCoverTable("sign", (100, "negative"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 1 iteration
        
        Coverage:
            Table "sign":
                negative:   0% (required: 100%) ←
                positive: 100%
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Counterexample
    
    @Reasync
    func testCounterexampleDistribution() async
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
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKLabel("tracked")
                TKAssertLessThan(n, 50)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        XCTKAssertLessThan failed: ("50") is not less than ("50")
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleMultipleDistributionLabels() async
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
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKClassify("small", when: n < 30)
                TKClassify("large", when: n >= 30)
                TKAssertLessThan(n, 60)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 4 iterations
        
        Counterexample:
            Int = 60
        
        XCTKAssertLessThan failed: ("60") is not less than ("60")
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            large: 1 (25%)
            small: 2 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleShrinkingAndDistribution() async
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
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKLabel("tracked")
                TKAssertLessThan(n, 10)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations (shrunk in 4 steps)
        
        Counterexample:
            Int = 10
        
        XCTKAssertLessThan failed: ("10") is not less than ("10")
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleDistributionNonIntegerPercentage() async
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
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKLabel("tracked")
                TKAssertLessThan(n, 50)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 3 iterations
        
        Counterexample:
            Int = 66
        
        XCTKAssertLessThan failed: ("66") is not less than ("50")
        
        \(Self.seedMessage)
        
        Distribution (3 iterations):
            tracked: 2 (66.7%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleThrownErrorAndDistribution() async
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
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                TKLabel("tracked")
                
                if n >= 50
                {
                    throw TestError()
                }
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleFirstFailureOmitsDistribution() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (_: Int) async in
                
                TKLabel("tracked")
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleDistributionLabelsAfterAssertion() async
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
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKLabel("before")
                TKAssertLessThan(n, 60)
                TKLabel("after")
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 3 iterations
        
        Counterexample:
            Int = 66
        
        XCTKAssertLessThan failed: ("66") is not less than ("60")
        
        \(Self.seedMessage)
        
        Distribution (3 iterations):
            after:  2 (66.7%)
            before: 2 (66.7%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleDistributionLabelsAfterThrow() async
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
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                TKLabel("before")
                
                if n >= 60
                {
                    throw TestError()
                }
                
                TKLabel("after")
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 3 iterations
        
        Counterexample:
            Int = 66
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Distribution (3 iterations):
            after:  2 (66.7%)
            before: 2 (66.7%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleTableDistribution() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("size", n < 30 ? "small" : "large")
                TKAssertLessThan(n, 50)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        XCTKAssertLessThan failed: ("50") is not less than ("50")
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            Table "size":
                small: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleFlatAndTableDistribution() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKLabel("tracked")
                TKTabulate("size", n < 30 ? "small" : "large")
                TKAssertLessThan(n, 50)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        XCTKAssertLessThan failed: ("50") is not less than ("50")
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 1 (50%)
        
            Table "size":
                small: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleMultipleTableDistributions() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("parity", n % 2 == 0 ? "even" : "odd")
                TKTabulate("size", n < 30 ? "small" : "large")
                TKAssertLessThan(n, 50)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        XCTKAssertLessThan failed: ("50") is not less than ("50")
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            Table "parity":
                even: 1 (50%)
        
            Table "size":
                small: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleFirstFailureOmitsTableDistribution() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (_: Int) async in
                
                TKTabulate("sign", "positive")
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleShrinkingAndTableDistribution() async
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
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("size", n < 10 ? "small" : "large")
                TKAssertLessThan(n, 10)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations (shrunk in 4 steps)
        
        Counterexample:
            Int = 10
        
        XCTKAssertLessThan failed: ("10") is not less than ("10")
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            Table "size":
                small: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleThrownErrorAndTableDistribution() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                TKTabulate("size", n < 30 ? "small" : "large")
                
                if n >= 50
                {
                    throw TestError()
                }
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            Table "size":
                small: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleTableDistributionLabelsAfterAssertion() async
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
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                TKTabulate("position", "before")
                TKAssertLessThan(n, 60)
                TKTabulate("position", "after")
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 3 iterations
        
        Counterexample:
            Int = 66
        
        XCTKAssertLessThan failed: ("66") is not less than ("60")
        
        \(Self.seedMessage)
        
        Distribution (3 iterations):
            Table "position":
                after:  2 (66.7%)
                before: 2 (66.7%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleTableDistributionLabelsAfterThrow() async
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
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                TKTabulate("position", "before")
                
                if n >= 60
                {
                    throw TestError()
                }
                
                TKTabulate("position", "after")
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 3 iterations
        
        Counterexample:
            Int = 66
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Distribution (3 iterations):
            Table "position":
                after:  2 (66.7%)
                before: 2 (66.7%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Exhaustion
    
    @Reasync
    func testExhaustionDistribution() async
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
            await TKForAll(
                using:      generator,
                where:      { $0 < 30 },
                options:    options
            )
            {
                (n: Int) async in
                
                TKLabel("tracked")
            }
        }
        
        let expected: String =
        """
        XCTKForAll exhausted after 2 successful iterations
        
            6 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 2 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testExhaustionTableDistribution() async
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
            await TKForAll(
                using:      generator,
                where:      { $0 < 30 },
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("size", n < 15 ? "small" : "medium")
            }
        }
        
        let expected: String =
        """
        XCTKForAll exhausted after 2 successful iterations
        
            6 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            Table "size":
                medium: 1 (50%)
                small:  1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testExhaustionFlatAndTableDistribution() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         5,
            maxSize:            100,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                where:      { $0 < 30 },
                options:    options
            )
            {
                (n: Int) async in
                
                TKLabel("tracked")
                TKTabulate("size", n < 15 ? "small" : "medium")
            }
        }
        
        let expected: String =
        """
        XCTKForAll exhausted after 2 successful iterations
        
            6 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 2 (100%)
        
            Table "size":
                medium: 1 (50%)
                small:  1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testExhaustionByAssumption() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         5,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (_: Int) async throws in
                
                try TKAssume(false)
            }
        }
        
        let expected: String =
        """
        XCTKForAll exhausted after 0 successful iterations
        
            6 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testExhaustionByAssumptionWithDistribution() async
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
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                try TKAssume(n < 30)
                
                TKLabel("tracked")
            }
        }
        
        let expected: String =
        """
        XCTKForAll exhausted after 2 successful iterations
        
            6 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 2 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testExhaustionByAssumptionWithTableDistribution() async
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
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                try TKAssume(n < 30)
                
                TKTabulate("size", n < 15 ? "small" : "medium")
            }
        }
        
        let expected: String =
        """
        XCTKForAll exhausted after 2 successful iterations
        
            6 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            Table "size":
                medium: 1 (50%)
                small:  1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testExhaustionByAssumptionWithMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         5,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                message:    "hello world",
                options:    options
            )
            {
                (_: Int) async throws in
                
                try TKAssume(false)
            }
        }
        
        let expected: String =
        """
        XCTKForAll exhausted after 0 successful iterations
        
            6 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testExhaustionByAssumptionSingleSuccessfulIteration() async
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
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                try TKAssume(n < 5)
            }
        }
        
        let expected: String =
        """
        XCTKForAll exhausted after 1 successful iteration
        
            6 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Failed iteration
    
    @Reasync
    func testFailedIterationLabelsNotInDistribution() async
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
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKLabel("tracked")
                TKClassify("large", when: n >= 50)
                TKAssertLessThan(n, 50)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        XCTKAssertLessThan failed: ("50") is not less than ("50")
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            tracked: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testFailedIterationTableLabelsNotInDistribution() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     2,
            seed:           Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                TKTabulate("size", n < 30 ? "small" : "large")
                TKAssertLessThan(n, 50)
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 2 iterations
        
        Counterexample:
            Int = 50
        
        XCTKAssertLessThan failed: ("50") is not less than ("50")
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            Table "size":
                small: 1 (50%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Collect
    
    @Reasync
    func testCoverageNotMetCollect() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKCollect(n)
                TKCover(100, "negative", when: n < 0)
            }
        }
        
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
    
    
    
    @Reasync
    func testCoverageNotMetTableCollect() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(
                using:      Generator<Int>.constant(5),
                options:    options
            )
            {
                (n: Int) async in
                
                TKCollect(n)
                TKTabulate("sign", n > 0 ? "positive" : "negative")
                TKCoverTable("sign", (100, "negative"))
            }
        }
        
        let expected: String =
        """
        XCTKForAll coverage not met after 10 iterations
        
        Coverage:
            5: 100%
        
            Table "sign":
                negative:   0% (required: 100%) ←
                positive: 100%
        
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
    private static let seed: UInt64 = 12345
    
    /// The seed re-run message.
    private static let seedMessage: String = "Seed: \(seed) (XCTKForAll)"
}
