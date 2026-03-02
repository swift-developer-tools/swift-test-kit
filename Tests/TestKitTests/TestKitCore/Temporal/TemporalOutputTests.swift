//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import Synchronization
import XCTest



internal final class TemporalOutputTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Always
    
    func testAlwaysSingleFailure() async
    {
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways
            {
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAlwaysSingleFailureWithMessage() async
    {
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways("hello world")
            {
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        XCTKAssertTrue failed
        
        hello world
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAlwaysThrownError() async
    {
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways
            {
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAlwaysThrownErrorWithMessage() async
    {
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways("hello world")
            {
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        Threw error: TestError()
        
        hello world
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAlwaysSingleFailureAndThrownError() async
    {
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways
            {
                TKAssertTrue(false)
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        XCTKAssertTrue failed
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAlwaysMultipleFailuresShowsOnlyFirst() async
    {
        let options: TestOptions = .temporalOptions(showAllFailures: false)
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways(options: options)
            {
                TKAssertTrue(false)
                TKAssertFalse(true)
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAlwaysMultipleFailuresShowsAll() async
    {
        let options: TestOptions = .temporalOptions(showAllFailures: true)
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways(options: options)
            {
                TKAssertTrue(false)
                TKAssertFalse(true)
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAlwaysFailsOnLaterPoll() async
    {
        let count = Mutex<Int>(0)
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKAlways(
                timeout:    .milliseconds(200),
                interval:   .milliseconds(10),
                context:    context
            )
            {
                let n: Int = count.withLock
                {
                    $0 += 1
                    return $0
                }
                
                TKAssertLessThan(n, 3)
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        XCTKAssertLessThan failed: ("3") is not less than ("3")
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testShowAllIndentsMultilineFailure() async
    {
        struct User: Equatable
        {
            let name: String
        }
        
        let options: TestOptions = .temporalOptions(showAllFailures: true)
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKAlways(options: options)
            {
                TKAssertEqual(User(name: "a"), User(name: "b"))
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>

        Failure 1:
            XCTKAssertEqual failed
            
            User differs at:
            
                .name, character 1
                    Expected:   "a"
                    Actual:     "b"

        Failure 2:
            XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    // MARK: - Eventually
    
    func testEventuallySingleFailure() async
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
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 50 ms
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEventuallySingleFailureWithMessage() async
    {
        let options: TestOptions = .temporalOptions(
            timeout:    .milliseconds(50),
            interval:   .milliseconds(10)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKEventually(
                "hello world",
                options:    options,
                context:    context
            )
            {
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 50 ms
        
        XCTKAssertTrue failed
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEventuallyThrownError() async
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
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 50 ms
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEventuallyThrownErrorWithMessage() async
    {
        let options: TestOptions = .temporalOptions(
            timeout:    .milliseconds(50),
            interval:   .milliseconds(10)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKEventually(
                "hello world",
                options:    options,
                context:    context
            )
            {
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 50 ms
        
        Threw error: TestError()
        
        hello world
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEventuallySingleFailureAndThrownError() async
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
                TKAssertTrue(false)
                throw TestError()
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 50 ms
        
        XCTKAssertTrue failed
        
        Threw error: TestError()
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEventuallyMultipleFailuresShowsOnlyFirst() async
    {
        let options: TestOptions = .temporalOptions(
            timeout:            .milliseconds(50),
            interval:           .milliseconds(10),
            showAllFailures:    false
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKEventually(
                options:    options,
                context:    context
            )
            {
                TKAssertTrue(false)
                TKAssertFalse(true)
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 50 ms
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEventuallyMultipleFailuresShowsAll() async
    {
        let options: TestOptions = .temporalOptions(
            timeout:            .milliseconds(50),
            interval:           .milliseconds(10),
            showAllFailures:    true
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKEventually(
                options:    options,
                context:    context
            )
            {
                TKAssertTrue(false)
                TKAssertFalse(true)
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 50 ms
        
        Failure 1:
            XCTKAssertTrue failed
        
        Failure 2:
            XCTKAssertFalse failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testEventuallyPerCallTimeoutOverridesDefault() async
    {
        let options: TestOptions = .temporalOptions(
            timeout:    .milliseconds(50),
            interval:   .milliseconds(10)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKEventually(
                timeout:    .seconds(2),
                options:    options,
                context:    context
            )
            {
                TKAssertTrue(false)
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after 2 sec
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    // MARK: - Nested
    
    func testAlwaysInsideEventually() async
    {
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKEventually(
                timeout:    .milliseconds(100),
                interval:   .milliseconds(10),
                context:    context
            )
            {
                await TKAlways
                {
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKEventually failed after <T>
        
        XCTKAlways failed after <T>
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testEventuallyInsideAlways() async
    {
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKAlways(
                timeout:    .milliseconds(200),
                context:    context
            )
            {
                await TKEventually(
                    timeout:    .milliseconds(50),
                    interval:   .milliseconds(10)
                )
                {
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKAlways failed after <T>
        
        XCTKEventually failed after <T>
        
        XCTKAssertTrue failed
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAlwaysInsideForAll() async
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
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration
        
        Counterexample:
            Int = 0
        
        XCTKAlways failed after <T>
        
        XCTKAssertTrue failed
        
        Seed: 12345 (XCTKForAll)
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testEventuallyInsideForAll() async
    {
        let propertyOptions: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let temporalOptions: TestOptions = .temporalOptions(
            timeout:    .milliseconds(50),
            interval:   .milliseconds(10)
        )
        
        let actual: String? = await withCapturedFailure
        {
            context in
            
            await TKForAll(
                options:    propertyOptions,
                context:    context
            )
            {
                (_: Int) async in
                
                await TKEventually(options: temporalOptions)
                {
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration

        Counterexample:
            Int = 0

        XCTKEventually failed after 50 ms

        XCTKAssertTrue failed

        Seed: 12345 (XCTKForAll)
        """
        
        XCTAssertEqual(expected, actual)
    }
    
    
    
    func testAlwaysInsideStateful() async
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
                
                await TKAlways
                {
                    TKAssertTrue(false)
                }
            }
        }
        
        let expected: String =
        """
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKAlways failed after <T>
        
        XCTKAssertTrue failed
        
        Seed: 12345 (XCTKStateful)
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
    
    
    
    func testAlwaysInsideStatefulInsideForAll() async
    {
        let options1: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           12345
        )
        
        let options2: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           54321
        )
        
        let actual: String? = await withOneExpectedFailure
        {
            await TKForAll(options: options1)
            {
                (_: Int) async in
                
                await TKStateful(
                    model:      { 0 },
                    system:     { 0 },
                    command:    IncrementCommand.self,
                    options:    options2
                )
                {
                    _, _ in
                    
                    await TKAlways
                    {
                        TKAssertTrue(false)
                    }
                }
            }
        }
        
        let expected: String =
        """
        XCTKForAll failed after 1 iteration

        Counterexample:
            Int = 0
        
        XCTKStateful failed after 1 iteration
        
        Command sequence:
            1. increment ←
        
        XCTKAlways failed after <T>
        
        XCTKAssertTrue failed
        
        Seed: 54321 (XCTKStateful)
        
        Seed: 12345 (XCTKForAll)
        """
        
        XCTAssertEqual(expected, actual?.timeless)
    }
}



// MARK: - Support

private extension String
{
    /// Replaces the non-deterministic time portion of an `always` failure
    /// message with `<T>`.
    var timeless: String
    {
        return replacing(
            /failed after \d+(\.\d+)?\s*(ms|sec)/,
            with: "failed after <T>"
        )
    }
}
