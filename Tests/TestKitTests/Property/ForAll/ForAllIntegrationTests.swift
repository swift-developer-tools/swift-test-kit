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



internal final class ForAllIntegrationTests: TestKitCase
{
    override func setUp()
    {
        super.setUp()
        
        /// Must be true when expecting errors in an async context. XCTest bug.
        continueAfterFailure = true
    }
    
    
    
    // MARK: - Arbitrary
    
    @Reasync
    func testArbitrarySuccess() async
    {
        await TKForAll
        {
            (n: Int) async in
            
            TKAssertEqual(n + 0, n)
        }
    }
    
    
    
    @Reasync
    func testArbitraryFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll
            {
                (_: Int) async in
                
                TKAssertTrue(false)
            }
        }
    }
    
    
    
    @Reasync
    func testArbitraryOneParameterSuccess() async
    {
        await TKForAll
        {
            (s: String) async in
            
            TKAssertEqual(s + "", s)
        }
    }
    
    
    
    @Reasync
    func testArbitraryTwoParameterSuccess() async
    {
        await TKForAll
        {
            (a: Int, b: Int) async in
            
            TKAssertTrue(true)
        }
    }
    
    
    
    @Reasync
    func testArbitraryThreeParameterSuccess() async
    {
        await TKForAll
        {
            (a: Int, b: Int, c: Int) async in
            
            TKAssertTrue(true)
        }
    }
    
    
    
    @Reasync
    func testArbitraryTwoParameterFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll
            {
                (a: Int, b: Int) async in
                
                TKAssertTrue(false)
            }
        }
    }
    
    
    
    @Reasync
    func testArbitraryThreeParameterFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll
            {
                (_: Int, _: String, _: Bool) async in
                
                TKAssertTrue(false)
            }
        }
    }
    
    
    
    // MARK: - Generator
    
    @Reasync
    func testGeneratorSuccess() async
    {
        await TKForAll(using: Generator<Int>.integer(in: 1...100))
        {
            (n: Int) async in
            
            TKAssertGreaterThan(n, 0)
        }
    }
    
    
    
    @Reasync
    func testGeneratorFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll(using: Generator<Int>.integer(in: 1...100))
            {
                (n: Int) async in
                
                TKAssertGreaterThan(n, 200)
            }
        }
    }
    
    
    
    @Reasync
    func testMultiParameterGeneratorSuccess() async
    {
        await TKForAll(
            using:  Generator<Int>.integer(in: 1...100),
                    Generator<Int>.integer(in: 1...100)
        )
        {
            (a: Int, b: Int) async in
            
            TKAssertGreaterThan(a, 0)
            TKAssertGreaterThan(b, 0)
        }
    }
    
    
    
    // MARK: - Precondition
    
    @Reasync
    func testPreconditionSuccess() async
    {
        await TKForAll(where: { $0 % 2 == 0 })
        {
            (n: Int) async in
            
            TKAssertEqual(n % 2, 0)
        }
    }
    
    
    
    @Reasync
    func testPreconditionFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll(where: { $0 >= 0 })
            {
                (n: Int) async in
                
                TKAssertGreaterThan(n, 50)
            }
        }
    }
    
    
    
    @Reasync
    func testPreconditionMultiParameterSuccess() async
    {
        await TKForAll(
            where: { (a: Int, b: Int) in (a % 2 == 0) && (b % 2 == 0) }
        )
        {
            (a: Int, b: Int) async in
            
            TKAssertEqual(a % 2, 0)
            TKAssertEqual(b % 2, 0)
        }
    }
    
    
    
    @Reasync
    func testPreconditionMultiParameterFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll(where: { $0 >= 0 && $1 >= 0 })
            {
                (a: Int, b: Int) async in
                
                TKAssertEqual(a, b)
            }
        }
    }
    
    
    
    // MARK: - Precondition generator
    
    @Reasync
    func testPreconditionGeneratorSuccess() async
    {
        await TKForAll(
            using:  Generator<Int>.integer(in: 0...100),
            where:  { $0 > 10 }
        )
        {
            (n: Int) async in
            
            TKAssertGreaterThan(n, 10)
        }
    }
    
    
    
    @Reasync
    func testPreconditionGeneratorFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll(
                using:  Generator<Int>.integer(in: 0...100),
                where:  { $0 > 10 }
            )
            {
                (n: Int) async in
                
                TKAssertGreaterThan(n, 200)
            }
        }
    }
    
    
    
    @Reasync
    func testMultiParameterPreconditionGeneratorSuccess() async
    {
        await TKForAll(
            using:  Generator<Int>.integer(in: 0...100),
                    Generator<Int>.integer(in: 0...100),
            where:  { $0 <= $1 }
        )
        {
            (a: Int, b: Int) async in
            
            TKAssertLessThanOrEqual(a, b)
        }
    }
    
    
    
    @Reasync
    func testMultiParameterPreconditionGeneratorFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll(
                using:  Generator<Int>.integer(in: 0...100),
                        Generator<Int>.integer(in: 0...100),
                where:  { $0 <= $1 }
            )
            {
                (a: Int, b: Int) async in
                
                TKAssertEqual(a, b)
            }
        }
    }
    
    
    
    // MARK: - Throwing
    
    @Reasync
    func testThrowingPropertyTreatedAsFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll
            {
                (_: Int) async throws in
                
                throw TestError()
            }
        }
    }
    
    
    
    @Reasync
    func testUnwrapSuccessInsideBody() async
    {
        await TKForAll
        {
            (n: Int) async throws in
            
            let value: Int = try TKUnwrap(Optional(n))
            
            TKAssertEqual(value, n)
        }
    }
    
    
    
    @Reasync
    func testUnwrapNilInsideBodyTreatedAsFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll
            {
                (_: Int) async throws in
                
                _ = try TKUnwrap(Optional<Int>(nil))
            }
        }
    }
    
    
    
    // MARK: - Seed replay
    
    @Reasync
    func testSeedReplayProducesSameOutput() async
    {
        let seed: UInt64 = 12345
        
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           seed
        )
        
        let output1: String? = await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (n: Int) async in
                
                TKAssertEqual(n, 0)
            }
        }
        
        let output2: String? = await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (n: Int) async in
                
                TKAssertEqual(n, 0)
            }
        }
        
        XCTAssertNotNil(output1)
        XCTAssertNotNil(output2)
        XCTAssertEqual(output1, output2)
    }
    
    
    
    // MARK: - Interception
    
    @Reasync
    func testAssertionInsideBodyDoesNotLeakAsSeparateFailure() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           1
        )
        
        /// If assertion failures are not intercepted, the assertion will
        /// report its failure directly to XCTest, producing more than one
        /// expected failure.
        await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (_: Int) async in
                
                TKAssertEqual(1, 2)
            }
        }
    }
    
    
    
    // MARK: - Iteration count
    
    @Reasync
    func testIterationCount() async
    {
        let iterations  : Int   = 1000
        var count       : Int   = 0
        
        await TKForAll(options: .propertyOptions(iterations: iterations))
        {
            (_: Int) async in
            
            count += 1
        }
        
        XCTAssertEqual(count, iterations)
    }
    
    
    
    @Reasync
    func testZeroIterationsVacuouslyPasses() async
    {
        var count: Int = 0
        
        await TKForAll(options: .propertyOptions(iterations: 0))
        {
            (_: Int) async in
            
            count += 1
        }
        
        XCTAssertEqual(count, 0)
    }
    
    
    
    // MARK: - Exhaustion
    
    @Reasync
    func testExhaustionTreatedAsFailure() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           1
        )
        
        await withOneExpectedFailure
        {
            await TKForAll(
                where:      { (_: Int) in false },
                options:    options
            )
            {
                (_: Int) async in
            }
        }
    }
    
    
    
    // MARK: - Example pinning
    
    @Reasync
    func testPinnedExampleSuccess() async
    {
        await TKForAll(examples: [0, 1, Int.max])
        {
            (n: Int) async in
            
            TKAssertEqual(n + 0, n)
        }
    }
    
    
    
    @Reasync
    func testPinnedExampleFailure() async
    {
        await withOneExpectedFailure
        {
            await TKForAll(examples: [0])
            {
                (n: Int) async in
                
                TKAssertNotEqual(n, 0)
            }
        }
    }
    
    
    
    // MARK: - No assertion
    
    @Reasync
    func testArbitraryBodyWithNoAssertionVacuouslyPasses() async
    {
        await TKForAll
        {
            (n: Int) async in
            
            _ = n % 2
        }
    }
    
    
    
    // MARK: - Nested
    
    @Reasync
    func testNestedProducesOneFailure() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           1
        )
        
        /// The inner evaluator fails on every iteration. Its assertion
        /// failures must be captured by the inner interceptor during
        /// shrinking, and the inner's final emit must be captured by the outer
        /// interceptor.Only the outer evaluator should report to XCTest.
        /// If `@TaskLocal` scoping is broken, the inner's assertion failures
        /// would leak as separate XCTest failures.
        await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (_: Int) async in
                
                await TKForAll(options: options)
                {
                    (_: Int) async in
                    
                    TKAssertTrue(false)
                }
            }
        }
    }
    
    
    
    // MARK: - Sequential
    
    @Reasync
    func testSequentialNoLeakFromPriorFailure() async
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           1
        )
        
        /// The first evaluator fails on the first assertion. The second
        /// evaluator succeeds on all assertions. The interceptor state must
        /// not leak into subsequent calls.
        await withOneExpectedFailure
        {
            await TKForAll(options: options)
            {
                (_: Int) async in
                
                TKAssertTrue(false)
            }
        }
        
        await TKForAll(options: options)
        {
            (n: Int) async in
            
            TKAssertEqual(n + 0, n)
        }
    }
}
