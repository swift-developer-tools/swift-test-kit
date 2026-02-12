//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitBase
import TKTestSupport
import XCTest
@testable import XCTestKit



internal final class ForAllOutputTests: XCTestKitCase
{
    // MARK: - Counterexample
    
    func testCounterexampleNoShrinking() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (_: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithShrinking() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value.shrink() }
        )
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleAtLaterIteration() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     10,
            maxSize:        100,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        /// With `10` iterations and a max size of `100`, the size after five
        /// successful iterations is `50`. The property fails at the sixth
        /// iteration.
        let generator = Generator<Int>(
            generate:   { context in context.size >= 50 ? 100 : 0 },
            shrink:     { value in value.shrink() }
        )
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithThrownError() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let actual: String? = withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (_: Int) in
                
                throw TestError()
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithMessage() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let actual: String? = withOneExpectedFailure
        {
            XCTKForAll(
                "hello world",
                options: options
            )
            {
                (_: Int) in
                
                throw TestError()
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        Threw error: TestError()
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithMessageAndAssertionFailure() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                "hello world",
                options: options
            )
            {
                (_: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPreconditionGeneratorCounterexample() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value.shrink() }
        )
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                where:      { $0 >= 50 },
                options:    options
            )
            {
                (_: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPreconditionCounterexample() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                where:      { _ in true },
                options:    options
            )
            {
                (_: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTwoParameterArbitraryCounterexample() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (_: Int, _: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTwoParameterCounterexampleNoShrinking() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let gen1    = Generator<Int>.constant(50)
        let gen2    = Generator<String>.constant("abc")
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      gen1, gen2,
                options:    options
            )
            {
                (_: Int, _: String) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTwoParameterCounterexampleWithShrinking() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let gen1 = Generator<Int>(
            generate:   { _ in 20 },
            shrink:     { value in value.shrink() }
        )
        
        let gen2 = Generator<String>.constant("abc")
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      gen1, gen2,
                options:    options
            )
            {
                (a: Int, _: String) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testThreeParameterCounterexampleNoShrinking() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let gen1    = Generator<Int>.constant(50)
        let gen2    = Generator<String>.constant("abc")
        let gen3    = Generator<Bool>.constant(true)
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      gen1, gen2, gen3,
                options:    options
            )
            {
                (_: Int, _: String, _: Bool) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testThreeParameterCounterexampleWithShrinking() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let gen1 = Generator<Int>(
            generate:   { _ in 20 },
            shrink:     { value in value.shrink() }
        )
        
        let gen2    = Generator<String>.constant("abc")
        let gen3    = Generator<Bool>.constant(true)
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      gen1, gen2, gen3,
                options:    options
            )
            {
                (a: Int, _: String, _: Bool) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAssertionFailurePriorityOverThrownError() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (_: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testFirstAssertionFailureShown() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (_: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCollectionCounterexample() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let generator = Generator<[Int]>.constant([1, 2, 3])
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (_: [Int]) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMaxShrinkStepsLimitsSearch() throws
    {
        /// Each shrink step decrements by one. Without the limit, this would
        /// shrink from `100` down to `10`. With `maxShrinkSteps` of `2`,
        /// shrinking stops at `98`.
        
        let propertyOptions = TKPropertyOptions(
            iterations:         1,
            maxShrinkSteps:     2,
            seed:               Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value > 0 ? [value - 1] : [] }
        )
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testUserDefinedTypeCounterexample() throws
    {
        struct Point: Equatable
        {
            let x   : Int
            let y   : Int
        }
        
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let generator = Generator<Point>.constant(Point(x: 5, y: 10))
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (_: Point) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCollectionCounterexampleWithShrinking() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let generator = Generator<[Int]>(
            generate: { _ in [1, 2, 3] },
            shrink:
            {
                array in
                
                return array.count > 1 ? [Array(array.dropLast())] : []
            }
        )
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (_: [Int]) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testThrownErrorShrinks() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let generator = Generator<Int>(
            generate:   { _ in 100 },
            shrink:     { value in value > 0 ? [value / 2] : [] }
        )
        
        let actual: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                options:    options
            )
            {
                (n: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultiParameterBothShrink() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
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
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      gen1, gen2,
                options:    options
            )
            {
                (a: Int, b: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPreconditionGeneratorCounterexampleIncludesDiscards() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:         1,
            maxSize:            100,
            maxDiscardRatio:    10,
            seed:               Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
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
        
        let output: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                where:      { $0 >= 10 },
                options:    options
            )
            {
                (_: Int) in
                
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
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Exhaustion
    
    func testExhaustion() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let actual: String? = withOneExpectedFailure
        {
            XCTKForAll(
                where:      { _ in false },
                options:    options
            )
            {
                (_: Int) in
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll exhausted after 0 successful iterations
        
            2 inputs discarded (max ratio: 1)
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testExhaustionWithMessage() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let actual: String? = withOneExpectedFailure
        {
            XCTKForAll(
                where:      { _ in false },
                message:    "hello world",
                options:    options
            )
            {
                (_: Int) in
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll exhausted after 0 successful iterations
        
            2 inputs discarded (max ratio: 1)
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testExhaustionAfterPartialSuccess() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:         5,
            maxSize:            100,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        /// Size grows as `succeeded * 100 / 5`. After 2 successes (sizes `0`
        /// and `20`), subsequent values are `40`, which fail the precondition.
        let generator = Generator<Int>(
            generate:   { context in context.size },
            shrink:     { _ in [] }
        )
        
        let actual: String? = withOneExpectedFailure
        {
            XCTKForAll(
                using:      generator,
                where:      { $0 < 30 },
                options:    options
            )
            {
                (_: Int) in
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll exhausted after 2 successful iterations
        
            6 inputs discarded (max ratio: 1)
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSingularInputDiscarded() throws
    {
        /// With a `maxDiscardRatio` of `0` and `iterations` of `1`, the
        /// discard limit is `0 * 1 = 0`. The first discarded input exceeds
        /// this limit.
        
        let propertyOptions = TKPropertyOptions(
            iterations:         1,
            maxDiscardRatio:    0,
            seed:               Self.seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
        let actual: String? = withOneExpectedFailure
        {
            XCTKForAll(
                where:      { _ in false },
                options:    options
            )
            {
                (_: Int) in
            }
        }
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKForAll exhausted after 0 successful iterations
        
            1 input discarded (max ratio: 0)
        
        Seed: \(Self.seed) (re-run with TKPropertyOptions.seed)
        """
        
        XCTAssertEqual(expected, actual)
    }
}



// MARK: - Extensions

extension ForAllOutputTests
{
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 50
    
    
    
    /// Extracts the property-related component of the given output, excluding
    /// the embedded assertion failure message.
    /// - Parameters:
    ///   - output: The full property evaluator output.
    ///   - marker: The text on which to split the given output.
    /// - Returns: The property-related component of the given output.
    /// - Throws: An error if the given marker is not found.
    private func getPropertyOutput(
        from    output  : String,
        before  marker  : String
    ) throws -> String
    {
        guard let range: Range<String.Index> = output.range(of: "\n\(marker)")
        else
        {
            XCTFail("Expected marker \"\(marker)\" not found in output")
            
            throw TestError()
        }
        
        return String(output[..<range.lowerBound])
    }
}
