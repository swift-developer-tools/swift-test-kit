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
    
    func testSingleCommandNoShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultiCommandNoShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testRemovalShrinking() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
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
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. step ←
        
        \(Self.seedMessage)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithMessage() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        XCTAssertTrue(output?.hasSuffix("\nhello world") ?? false)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        \(Self.seedMessage)
        
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
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. step ←
        
        \(Self.seedMessage)
        
        Threw error: TestError()
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testFailurePriorityOverThrownError() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         1,
            maxShrinkSteps:     0,
            maxCommandCount:    1,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDistributionCounterexample() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            always: 3 (75%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testTableDistributionCounterexample() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            Table "type":
                always: 3 (75%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMixedFlatAndTableDistributionCounterexample() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
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
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            ran: 3 (75%)
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleWithDistributionAndMessage() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        XCTAssertTrue(output?.hasSuffix("\nhello world") ?? false)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            ran: 3 (75%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleMultipleTables() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            Table "a":
                x: 3 (75%)
        
            Table "b":
                y: 3 (75%)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testCounterexampleMultipleTableEntries() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxShrinkSteps:     0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
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
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        \(Self.seedMessage)
        
        Distribution (4 iterations):
            ran: 3 (75%)
        
        Threw error: TestError()
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKStateful exhausted after 1 successful iteration
        
            3 values discarded (max ratio: 1)
        
        \(Self.seedMessage)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDistributionExhaustion() async throws
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
    
    func testStepPaddingWithMidSequenceArrow() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxDiscardRatio:    0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testDoubleDigitsStepPadding() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         100,
            maxDiscardRatio:    0,
            maxCommandCount:    100,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
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
        
        \(Self.seedMessage)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testShrunkToSingularCommand() async throws
    {
        let options: TestOptions = .propertyOptions(
            iterations:         10,
            maxSize:            100,
            maxCommandCount:    10,
            seed:               Self.seed
        )
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 3 iterations (shrunk to 1 command)
        
        Command sequence:
            1. add(20) ←
        
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
        
        XCTAssertNotNil(actual)
        
        /// The `message` comes from the ``PropertyInterceptor/recordFailure()``
        /// test utility method.
        let expected: String =
        """
        XCTKStateful failed after 4 iterations
        
        Command sequence:
            1. step
            2. step
            3. step ←
        
        \(Self.seedMessage)
        
        message
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testRunFailureAfterShrinking() async throws
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
        
        XCTAssertNotNil(actual)
        
        /// The `message` comes from the ``PropertyInterceptor/recordFailure()``
        /// test utility method.
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. step
            2. step
            3. step ←
        
        \(Self.seedMessage)
        
        message
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        XCTAssertNotNil(actual)
        
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
        
        \(Self.seedMessage)
        
        Postcondition failed after command: step (step 3)
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
        
        XCTAssertNotNil(actual)
        
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. step
            2. step
            3. step ←
        
        \(Self.seedMessage)
        
        Postcondition failed after command: step (step 3)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - ForAll
    
    func testForAllFailure() async throws
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
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        \(Self.seedMessage)
        
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        Seed: 99 (re-run with PropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testForAllFailureWithShrinking() async throws
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
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 2 iterations (shrunk to 3 commands)
        
        Command sequence:
            1. increment
            2. increment
            3. increment ←
        
        \(Self.seedMessage)
        
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        Seed: 99 (re-run with PropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleForAllsFirstPassingSecondFailing() async throws
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
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        \(Self.seedMessage)
        
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        Seed: 99 (re-run with PropertyOptions.seed)
        
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testMultipleForAllsBothFailing() async throws
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
        
        let output: String? = await withOneExpectedFailure
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
        
        XCTAssertNotNil(output)
        
        
        
        let actual: String = try getPropertyOutput(
            from:       output,
            before:     .true
        )
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        \(Self.seedMessage)
        
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        Seed: 99 (re-run with PropertyOptions.seed)
        
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
    private static let seed: UInt64 = 50
    
    /// The re-run message.
    private static let seedMessage: String =
        "Seed: \(seed) (re-run with PropertyOptions.seed)"
}
