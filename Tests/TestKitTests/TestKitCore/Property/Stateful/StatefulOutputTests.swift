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
@testable import struct TestKitCore.DiscardError



internal final class StatefulOutputTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Counterexample
    
    func testSingleCommandNoShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKAssertTrue(false)
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultiCommandNoShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    if model >= 3
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testRemovalShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    if model >= 3
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithThrownError() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunThrowCommand.self,
                options:    options
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. step ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                "hello world",
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKAssertTrue(false)
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithMessageAndThrownError() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                "hello world",
                model:      { 0 },
                system:     { 0 },
                command:    RunThrowCommand.self,
                options:    options
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. step ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testFailurePriorityOverThrownError() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async throws in
                    
                    TKAssertTrue(false)
                    
                    throw TestError()
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDistributionCounterexample() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    TKLabel("always")
                    
                    if model >= 3
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            always: 3 (75%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTableDistributionCounterexample() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    TKTabulate("type", "always")
                    
                    if model >= 3
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            Table "type":
                always: 3 (75%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMixedFlatAndTableDistributionCounterexample() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    TKLabel("flat")
                    TKTabulate("type", "always")
                    
                    if model >= 3
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            flat: 3 (75%)
        
            Table "type":
                always: 3 (75%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithDistributionAndThrownError() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    TKLabel("ran")
                    
                    if model >= 3
                    {
                        throw TestError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            ran: 3 (75%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithDistributionAndMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                "hello world",
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    TKLabel("ran")
                    
                    if model >= 3
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            ran: 3 (75%)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleMultipleTables() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    TKTabulate("a", "x")
                    TKTabulate("b", "y")
                    
                    if model >= 3
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            Table "a":
                x: 3 (75%)
        
            Table "b":
                y: 3 (75%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleMultipleTableEntries() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    TKTabulate("table", "a")
                    TKTabulate("table", "b")
                    
                    if model >= 3
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            Table "table":
                a: 3 (75%)
                b: 3 (75%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithDistributionMessageAndThrownError() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                "hello world",
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    TKLabel("ran")
                    
                    if model >= 3
                    {
                        throw TestError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            ran: 3 (75%)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Exhaustion
    
    func testExhaustion() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunDiscardCommand.self,
                options:    options
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 0 successful iterations
        
            2 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testExhaustionWithMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                "hello world",
                model:      { 0 },
                system:     { 0 },
                command:    RunDiscardCommand.self,
                options:    options
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 0 successful iterations
        
            2 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testSingleValueDiscarded() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    0,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunDiscardCommand.self,
                options:    options
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 0 successful iterations
        
            1 value discarded (max ratio: 0)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testExhaustionSingleSuccessfulIteration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         2,
            maxDiscardRatio:    1,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    if model >= 2
                    {
                        throw DiscardError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 1 successful iteration
        
            3 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDistributionExhaustion() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:     1,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    TKLabel("always")
                    
                    if model >= 2
                    {
                        throw DiscardError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 2 successful iterations
        
            11 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (2 iterations):
            always: 2 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTableDistributionExhaustion() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         2,
            maxDiscardRatio:    1,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    TKTabulate("type", "always")
                    
                    if model >= 2
                    {
                        throw DiscardError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 1 successful iteration
        
            3 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (1 iteration):
            Table "type":
                always: 1 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMixedFlatAndTableDistributionExhaustion() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         2,
            maxDiscardRatio:    1,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    TKLabel("flat")
                    TKTabulate("type", "always")
                    
                    if model >= 2
                    {
                        throw DiscardError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 1 successful iteration
        
            3 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (1 iteration):
            flat: 1 (100%)
        
            Table "type":
                always: 1 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testExhaustionWithMessageAndDistribution() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         2,
            maxDiscardRatio:    1,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                "hello world",
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    TKLabel("always")
                    
                    if model >= 2
                    {
                        throw DiscardError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 1 successful iteration
        
            3 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Distribution (1 iteration):
            always: 1 (100%)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Step
    
    func testStepPaddingWithMidSequenceArrow() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    if model >= 3
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDoubleDigitsStepPadding() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxDiscardRatio:    0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    if model >= 10
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 11 iterations
        
        Command sequence:
             1. increment
             2. increment
             3. increment
             4. increment
             5. increment
             6. increment
             7. increment
             8. increment
             9. increment
            10. increment ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testShrunkToSingularCommand() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxSize:            100,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    ScaledStepCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async in
                    
                    if model > 15
                    {
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 3 iterations (shrunk to 1 command)
        
        Command sequence:
            1. add(20) ←
        
        XCTKAssertTrue failed
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Run failure
    
    func testRunFailureReportsCorrectStep() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunFailCommand.self,
                options:    options
            )
        }
        
        /// The `message` comes from the ``FailureInterceptor/recordFailure()``
        /// test utility method.
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. step
            2. step
            3. step ←
        
        message
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testRunFailureAfterShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunFailCommand.self,
                options:    options
            )
        }
        
        /// The `message` comes from the ``FailureInterceptor/recordFailure()``
        /// test utility method.
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. step
            2. step
            3. step ←
        
        message
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Coverage
    
    func testCoverageNotMet() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCover(100, "never", when: false)
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 10 iterations
        
        Coverage:
            never: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTableCoverageNotMet() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCoverTable("scores", (100, "perfect"))
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 10 iterations
        
        Coverage:
            Table "scores":
                perfect: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMixedFlatAndTableCoverageNotMet() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCover(100, "a", when: false)
                    TKCoverTable("table", (50, "b"))
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 10 iterations
        
        Coverage:
            a: 0% (required: 100%) ←
        
            Table "table":
                b: 0% (required: 50%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCoverageNotMetWithMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                "hello world",
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCover(100, "never", when: false)
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 10 iterations
        
        Coverage:
            never: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCoverageNotMetAlignedPercentages() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCover(100, "always", when: true)
                    TKCover(100, "never", when: false)
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 10 iterations
        
        Coverage:
            always: 100%
            never:    0% (required: 100%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCoverageNonIntegerRequiredPercentage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCover(33.3, "third", when: false)
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 10 iterations
        
        Coverage:
            third: 0% (required: 33.3%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCoverageNotMetSingleIteration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCover(100, "never", when: false)
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 1 iteration
        
        Coverage:
            never: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCoverageNotMetMultipleTables() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCoverTable("a", (100, "x"))
                    TKCoverTable("b", (100, "y"))
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 10 iterations
        
        Coverage:
            Table "a":
                x: 0% (required: 100%) ←
        
            Table "b":
                y: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Postcondition
    
    func testPostconditionFailureNoShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    PostCFailCommand.self,
                options:    options
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 2 iterations
        
        Command sequence:
             1. step
             2. step
             3. step ←
             4. step
             5. step
             6. step
             7. step
             8. step
             9. step
            10. step
        
        Postcondition failed after command: step (step 3)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPostconditionFailureWithShrinking() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         5,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    PostCFailCommand.self,
                options:    options
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. step
            2. step
            3. step ←
        
        Postcondition failed after command: step (step 3)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Statistics
    
    func testStatisticsNotShownWhenDisabled() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            statistics:         [],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    if model >= 3
                    {
                        throw TestError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsNotShownWithNoSuccessfulIterations() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxDiscardRatio:    0,
            statistics:         [.presence, .frequency, .sequenceCount],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    RunDiscardCommand.self,
                options:    options
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 0 successful iterations
        
            1 value discarded (max ratio: 0)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsPresence() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            statistics:         [.presence],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    if model >= 3
                    {
                        throw TestError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Command presence (3 iterations):
            increment: 3 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsPresenceMultipleCommands() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         3,
            maxCommandCount:    9,
            statistics:         [.presence],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    CycleCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCover(100, "never", when: false)
                }
            )
        }
        
        /// Command sequences:
        /// - `alpha`
        /// - `alpha, beta, gamma`
        /// - `alpha, beta, gamma, alpha, beta, gamma`
        let expected: String =
        """
        XCTKStateful coverage not met after 3 iterations
        
        Coverage:
            never: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        
        Command presence (3 iterations):
            alpha: 3 (100%)
            beta:  2 (66.7%)
            gamma: 2 (66.7%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsFrequency() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            statistics:         [.frequency],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    if model >= 3
                    {
                        throw TestError()
                    }
                }
            )
        }
        
        /// Command sequence counts: 1, 1, 2.
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)

        Command frequency (4 commands):
            increment: 4 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsFrequencyMultipleCommands() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         3,
            maxCommandCount:    9,
            statistics:         [.frequency],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    CycleCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCover(100, "never", when: false)
                }
            )
        }
        
        /// Command sequences:
        /// - `alpha`
        /// - `alpha, beta, gamma`
        /// - `alpha, beta, gamma, alpha, beta, gamma`
        let expected: String =
        """
        XCTKStateful coverage not met after 3 iterations
        
        Coverage:
            never: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        
        Command frequency (10 commands):
            alpha: 4 (40%)
            beta:  3 (30%)
            gamma: 3 (30%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsSequenceCount() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            statistics:         [.sequenceCount],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    if model >= 3
                    {
                        throw TestError()
                    }
                }
            )
        }
        
        /// Command sequence counts: 1, 1, 2.
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Command sequence count (3 iterations):
            Minimum:   1
            Maximum:   2
            Average: 1.3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsSequenceCountSingleIteration() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxCommandCount:    1,
            statistics:         [.sequenceCount],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async in
                    
                    TKCover(100, "never", when: false)
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 1 iteration
        
        Coverage:
            never: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        
        Command sequence count (1 iteration):
            Minimum: 1
            Maximum: 1
            Average: 1
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsAllEnabled() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            statistics:         [.presence, .frequency, .sequenceCount],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    if model >= 3
                    {
                        throw TestError()
                    }
                }
            )
        }
        
        /// Command sequence counts: 1, 1, 2.
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Command presence (3 iterations):
            increment: 3 (100%)
        
        Command frequency (4 commands):
            increment: 4 (100%)
        
        Command sequence count (3 iterations):
            Minimum:   1
            Maximum:   2
            Average: 1.3
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsWithClassification() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            statistics:         [.presence],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    TKLabel("always")
                    
                    if model >= 3
                    {
                        throw TestError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            always: 3 (75%)
        
        Command presence (3 iterations):
            increment: 3 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsExhaustion() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         2,
            maxDiscardRatio:    1,
            maxCommandCount:    100,
            statistics:         [.presence],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    if model >= 2
                    {
                        throw DiscardError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful exhausted after 1 successful iteration
        
            3 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        
        Command presence (1 iteration):
            increment: 1 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsCoverageNotMet() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    1,
            statistics:         [.presence],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    _, _ async throws in
                    
                    TKCover(100, "never", when: false)
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful coverage not met after 10 iterations
        
        Coverage:
            never: 0% (required: 100%) ←
        
        \(Self.seedMessage)
        
        Command presence (10 iterations):
            increment: 10 (100%)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatisticsWithMessage() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            statistics:         [.presence],
            seed:               Self.seed
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                "hello world",
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options,
                invariant:
                {
                    model, _ async throws in
                    
                    if model >= 3
                    {
                        throw TestError()
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        Threw error: TestError()
        
        \(Self.seedMessage)
        
        Command presence (3 iterations):
            increment: 3 (100%)
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - ForAll
    
    func testForAllFailure() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let forAllOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            seed:               99
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    statefulOptions,
                invariant:
                {
                    _, _ async in
                    
                    await TKForAll(options: forAllOptions)
                    {
                        (_: Int) async in
                        
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAssertTrue failed
        
        Seed: 99 (XCTKForAll)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testForAllFailureWithShrinking() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let forAllOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            seed:               99
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    statefulOptions,
                invariant:
                {
                    model, _ async in
                    
                    if model >= 3
                    {
                        await TKForAll(options: forAllOptions)
                        {
                            (_: Int) async in
                            
                            TKAssertTrue(false)
                        }
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAssertTrue failed
        
        Seed: 99 (XCTKForAll)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleForAllsFirstPassingSecondFailing() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let forAllOptions1: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           99
        )
        
        let forAllOptions2: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            seed:               99
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    statefulOptions,
                invariant:
                {
                    _, _ async in
                    
                    await TKForAll(options: forAllOptions1)
                    {
                        (n: Int) async in
                        
                        TKAssertEqual(n + 0, n)
                    }
                    
                    await TKForAll(options: forAllOptions2)
                    {
                        (_: Int) async in
                        
                        TKAssertTrue(false)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAssertTrue failed
        
        Seed: 99 (XCTKForAll)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleForAllsBothFailing() async
    {
        let statefulOptions: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let forAllOptions: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           99
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    statefulOptions,
                invariant:
                {
                    _, _ async in
                    
                    await TKForAll(options: forAllOptions)
                    {
                        (_: Int) async in
                        
                        TKAssertTrue(false)
                    }
                    
                    await TKForAll(options: forAllOptions)
                    {
                        (_: Int) async in
                        
                        TKAssertEqual(1, 2)
                    }
                }
            )
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAssertTrue failed
        
        Seed: 99 (XCTKForAll)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
}



// MARK: - Support

extension StatefulOutputTests
{
    /// The seed used to initialize the random number generator.
    ///
    /// Use a fixed seed rather than a random seed for deterministic tests.
    private static let seed: UInt64 = 12345
    
    /// The seed re-run message.
    private static let seedMessage: String = "Seed: \(seed) (XCTKStateful)"
}
