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



internal final class AtomicOutputTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Single failure
    
    @Reasync
    func testSingleFailure() async
    {
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testSingleFailureWithMessage() async
    {
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic("hello world")
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKAssertTrue failed
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Multiple failures
    
    @Reasync
    func testMultipleFailures() async
    {
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
            TKAssertFalse(true)
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testMultipleFailuresWithThrownErrorAndMessage() async
    {
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
            TKAssertFalse(true)
            throw TestError()
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic("hello world")
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        
        Threw error: TestError()
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Thrown error
    
    @Reasync
    func testThrownErrorOnly() async
    {
        let body: () async throws -> Void =
        {
            throw TestError()
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testThrownErrorOnlyWithMessage() async
    {
        let body: () async throws -> Void =
        {
            throw TestError()
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic("hello world")
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed
        
        Threw error: TestError()
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Failures and thrown error
    
    @Reasync
    func testSingleFailureAndThrownError() async
    {
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
            throw TestError()
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKAssertTrue failed
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testMultipleFailuresAndThrownError() async
    {
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
            TKAssertFalse(true)
            throw TestError()
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Multiline failures
    
    @Reasync
    func testMultilineSingleFailure() async
    {
        let body: () async throws -> Void =
        {
            TKAssertEqual(User(name: "a"), User(name: "b"))
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKAssertEqual failed
        
        User differs at:
        
            .name, character 1
                Expected:   "a"
                Actual:     "b"
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testMultilineMultipleFailures() async
    {
        let body: () async throws -> Void =
        {
            TKAssertEqual(User(name: "a"), User(name: "b"))
            TKAssertTrue(false)
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertEqual failed
            
            User differs at:
            
                .name, character 1
                    Expected:   "a"
                    Actual:     "b"
        
        Failure 2:
            XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Nested
    
    @Reasync
    func testAtomicInsideForAll() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
            TKAssertFalse(true)
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (_: Int) async in
                
                await TKAtomic
                {
                    try await body()
                }
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        
        Seed: 12345 (XCTKForAll)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAtomicInsideStateful() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKStateful(
                model:      { 0 },
                system:     { 0 },
                command:    IncrementCommand.self,
                options:    options
            )
            {
                _, _ in
                
                TKAtomic
                {
                    TKAssertTrue(false)
                    TKAssertFalse(true)
                }
            }
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        
        Seed: 12345 (XCTKStateful)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAtomicInsideAlways() async
    {
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways
            {
                TKAtomic
                {
                    TKAssertTrue(false)
                    TKAssertFalse(true)
                }
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAtomicInsideEventually() async
    {
        let options: TestOptions = .temporalOptions(
            timeout:    .milliseconds(50),
            interval:   .milliseconds(10)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKEventually(
                options:    options,
                context:    context
            )
            {
                TKAtomic
                {
                    TKAssertTrue(false)
                    TKAssertFalse(true)
                }
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 50 ms
        
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAtomicInsidePerformance() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKPerformance(options: options)
            {
                TKAtomic
                {
                    TKAssertTrue(false)
                    TKAssertFalse(true)
                }
            }
        }
        
        let expected: String =
        """
        XCTKPerformance failed (run 1 of 3)
        
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    @Reasync
    func testForAllInsideAtomic() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let body: () async throws -> Void =
        {
            await TKForAll(options: options)
            {
                (_: Int) async in
                
                TKAssertTrue(false)
                TKAssertFalse(true)
            }
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                try await body()
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAssertTrue failed
        
        Seed: 12345 (XCTKForAll)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testStatefulInsideAtomic() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                await TKStateful(
                    model:      { 0 },
                    system:     { 0 },
                    command:    IncrementCommand.self,
                    options:    options
                )
                {
                    _, _ in
                    
                    TKAssertTrue(false)
                    TKAssertFalse(true)
                }
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKAssertTrue failed
        
        Seed: 12345 (XCTKStateful)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAlwaysInsideAtomic() async
    {
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                await TKAlways
                {
                    TKAssertTrue(false)
                    TKAssertFalse(true)
                }
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKAlways failed after <T>
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testEventuallyInsideAtomic() async
    {
        let options: TestOptions = .temporalOptions(
            timeout:    .milliseconds(50),
            interval:   .milliseconds(10)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKAtomic(context: context)
            {
                await TKEventually(options: options)
                {
                    TKAssertTrue(false)
                    TKAssertFalse(true)
                }
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKEventually failed after 50 ms
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testPerformanceInsideAtomic() async
    {
        let options: TestOptions = .performanceOptions(
            runs:           3,
            warmupRuns:     0,
            timeLimit:      .seconds(10)
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                await TKPerformance(options: options)
                {
                    TKAssertTrue(false)
                    TKAssertFalse(true)
                }
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKPerformance failed (run 1 of 3)
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAtomicInsideAlwaysInsideForAll() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (_: Int) async in
                
                await TKAlways
                {
                    TKAtomic
                    {
                        TKAssertTrue(false)
                        TKAssertFalse(true)
                    }
                }
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAlways failed after <T>
        
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        
        Seed: 12345 (XCTKForAll)
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    @Reasync
    func testAtomicInsideAtomic() async
    {
        let body: () async throws -> Void =
        {
            TKAssertTrue(false)
            TKAssertFalse(true)
        }
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAtomic
            {
                await TKAtomic
                {
                    try await body()
                }
            }
        }
        
        let expected: String =
        """
        XCTKAtomic failed (1 failed assertion)
        
        XCTKAtomic failed (2 failed assertions)
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        """
        
        XCTAssertEqual(expected, actual)
    }
}



// MARK: - Support

extension AtomicOutputTests
{
    private struct User: Equatable
    {
        let name: String
    }
}
