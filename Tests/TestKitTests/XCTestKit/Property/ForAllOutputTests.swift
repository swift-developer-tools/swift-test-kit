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



internal final class ForAllOutputTests: XCTestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Counterexample
    
    @Reasync
    func testCounterexampleNoShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(options: options)
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
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
    func testCounterexampleWithShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { _ in 100 },
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
                
                XCTKAssertLessThan(n, 10)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration (shrunk in 4 steps)
        
        Counterexample:
            Int = 10
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleAtLaterIteration() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            maxSize:        100,
            seed:           Self.seed
        )
        
        /// With `10` iterations and a max size of `100`, the size after five
        /// successful iterations is `50`. The property fails at the sixth
        /// iteration.
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
                
                XCTKAssertLessThan(n, 10)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 6 iterations (shrunk in 4 steps)
        
        Counterexample:
            Int = 10
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleWithThrownError() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(options: options)
            {
                (_: Int) async throws in
                
                throw TestError()
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        \(Self.seedMessage)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleWithMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                "hello world",
                options: options
            )
            {
                (_: Int) async throws in
                
                throw TestError()
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        \(Self.seedMessage)
        
        Threw error: TestError()
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCounterexampleWithMessageAndAssertionFailure() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                "hello world",
                options: options
            )
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        XCTAssertTrue(output!.hasSuffix("\nhello world"))
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
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
    func testPreconditionGeneratorCounterexample() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value.shrink() }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                where:      { $0 >= 50 },
                options:    options
            )
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration (shrunk in 1 step)
        
        Counterexample:
            Int = 50
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testPreconditionCounterexample() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                where:      { _ in true },
                options:    options
            )
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
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
    func testTwoParameterArbitraryCounterexample() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(options: options)
            {
                (_: Int, _: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
            Int = 0
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testTwoParameterCounterexampleNoShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let gen1    = Generator<Int>.constant(50)
        let gen2    = Generator<String>.constant("abc")
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      gen1, gen2,
                options:    options
            )
            {
                (_: Int, _: String) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 50
            String = abc
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testTwoParameterCounterexampleWithShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let gen1 = Generator<Int>(
            generate:   { _ in 20 },
            shrink:     { value in value.shrink() }
        )
        
        let gen2 = Generator<String>.constant("abc")
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      gen1, gen2,
                options:    options
            )
            {
                (a: Int, _: String) async in
                
                XCTKAssertLessThan(a, 10)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration (shrunk in 1 step)
        
        Counterexample:
            Int = 10
            String = abc
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testThreeParameterCounterexampleNoShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let gen1    = Generator<Int>.constant(50)
        let gen2    = Generator<String>.constant("abc")
        let gen3    = Generator<Bool>.constant(true)
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      gen1, gen2, gen3,
                options:    options
            )
            {
                (_: Int, _: String, _: Bool) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 50
            String = abc
            Bool = true
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testThreeParameterCounterexampleWithShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let gen1 = Generator<Int>(
            generate:   { _ in 20 },
            shrink:     { value in value.shrink() }
        )
        
        let gen2    = Generator<String>.constant("abc")
        let gen3    = Generator<Bool>.constant(true)
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      gen1, gen2, gen3,
                options:    options
            )
            {
                (a: Int, _: String, _: Bool) async in
                
                XCTKAssertLessThan(a, 10)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration (shrunk in 1 step)
        
        Counterexample:
            Int = 10
            String = abc
            Bool = true
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testAssertionFailurePriorityOverThrownError() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(options: options)
            {
                (_: Int) async throws in
                
                XCTKAssertTrue(false)
                
                throw TestError()
            }
        }
        
        XCTAssertNotNil(output)
        XCTAssertFalse(output!.contains("Threw error:"))
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
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
    func testFirstAssertionFailureShown() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(options: options)
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
                XCTKAssertEqual(1, 2)
            }
        }
        
        XCTAssertNotNil(output)
        XCTAssertFalse(output!.contains("XCTKAssertEqual"))
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
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
    func testCollectionCounterexample() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let generator = Generator<[Int]>.constant([1, 2, 3])
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (_: [Int]) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Array<Int> = [1, 2, 3]
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testMaxShrinkStepsLimitsSearch() async throws
    {
        /// Each shrink step decrements by one. Without the limit, this would
        /// shrink from `100` down to `10`. With `maxShrinkSteps` of `2`,
        /// shrinking stops at `98`.
        
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     2,
            seed:               Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value > 0 ? [value - 1] : [] }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async in
                
                XCTKAssertLessThan(n, 10)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertLessThan"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration (shrunk in 2 steps)
        
        Counterexample:
            Int = 98
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testUserDefinedTypeCounterexample() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let generator = Generator<Point>.constant(Point(x: 5, y: 10))
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (_: Point) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Point = Point(x: 5, y: 10)
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testCollectionCounterexampleWithShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let generator = Generator<[Int]>(
            generate: { _ in [1, 2, 3] },
            shrink:
            {
                array in
                
                return array.count > 1 ? [Array(array.dropLast())] : []
            }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (_: [Int]) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration (shrunk in 2 steps)
        
        Counterexample:
            Array<Int> = [1]
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testThrownErrorShrinks() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value > 0 ? [value / 2] : [] }
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) async throws in
                
                if n >= 10
                {
                    throw TestError()
                }
            }
        }
        
        XCTAssertNotNil(actual)
        
        
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration (shrunk in 3 steps)
        
        Counterexample:
            Int = 12
        
        \(Self.seedMessage)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testMultiParameterBothShrink() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        /// Both generators start at `10` and shrink to their respective
        /// thresholds. The property fails when both values meet or exceed
        /// their threshold, so both parameters must shrink to the boundary.
        let gen1 = Generator<Int>(
            generate: { _ in 10 },
            shrink:
            {
                value in
                
                if value > 5
                {
                    return [5]
                }
                else if value > 0
                {
                    return [0]
                }
                
                return []
            }
        )
        
        let gen2 = Generator<Int>(
            generate: { _ in 10 },
            shrink:
            {
                value in
                
                if value > 3
                {
                    return [3]
                }
                else if value > 0
                {
                    return [0]
                }
                
                return []
            }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      gen1, gen2,
                options:    options
            )
            {
                (a: Int, b: Int) async in
                
                XCTKAssertTrue(a < 5 || b < 3)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration (shrunk in 2 steps)
        
        Counterexample:
            Int = 5
            Int = 3
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testPreconditionGeneratorCounterexampleIncludesDiscards() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxSize:            100,
            maxDiscardRatio:    10,
            seed:               Self.seed
        )
        
        var attempts: Int = 0
        
        let generator = Generator<Int>(
            generate:
            {
                _ in
                
                defer
                {
                    attempts += 1
                }
                
                /// First two attempts return `0` (discarded), then `50`
                /// (accepted, but fails the property). The iteration count
                /// (`3`) must included the discarded count (`2`) plus the
                /// failure count (`1`).
                return attempts < 2 ? 0 : 50
            },
            shrink: { value in value.shrink() }
        )
        
        let output: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                using:      generator,
                where:      { $0 >= 10 },
                options:    options
            )
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output!,
            before:     "XCTKAssertTrue"
        )
        
        let expected: String =
        """
        XCTKForAll failed after 3 iterations (shrunk in 3 steps)
        
        Counterexample:
            Int = 10
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Exhaustion
    
    @Reasync
    func testExhaustion() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                where:      { _ in false },
                options:    options
            )
            {
                (_: Int) async in
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll exhausted after 0 successful iterations
        
            2 inputs discarded (max ratio: 1)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testExhaustionWithMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                where:      { _ in false },
                message:    "hello world",
                options:    options
            )
            {
                (_: Int) async in
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll exhausted after 0 successful iterations
        
            2 inputs discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testExhaustionAfterPartialSuccess() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         5,
            maxSize:            100,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        /// Size grows as `succeeded * 100 / 5`. After 2 successes (sizes `0`
        /// and `20`), subsequent values are `40`, which fail the precondition.
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
                (_: Int) async in
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll exhausted after 2 successful iterations
        
            6 inputs discarded (max ratio: 1)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testSingularInputDiscarded() async
    {
        /// With a `maxDiscardRatio` of `0` and `iterations` of `1`, the
        /// discard limit is `0 * 1 = 0`. The first discarded input exceeds
        /// this limit.
        
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    0,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await XCTKForAll(
                where:      { _ in false },
                options:    options
            )
            {
                (_: Int) async in
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll exhausted after 0 successful iterations
        
            1 input discarded (max ratio: 0)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
}



// MARK: - Support

extension ForAllOutputTests
{
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 50
    
    /// The re-run message.
    private static let seedMessage: String =
        "Seed: \(seed) (re-run with PropertyOptions.seed)"
    
    
    
    /// A user defined type used to test output.
    private struct Point: Equatable
    {
        let x   : Int
        let y   : Int
    }
}
