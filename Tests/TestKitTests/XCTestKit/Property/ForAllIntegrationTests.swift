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



internal final class ForAllIntegrationTests: XCTestKitCase
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
        await XCTKForAll
        {
            (n: Int) async in
            
            XCTKAssertEqual(n + 0, n)
        }
    }
    
    
    
    @Reasync
    func testArbitraryFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
    }
    
    
    
    @Reasync
    func testArbitraryOneParameterSuccess() async
    {
        await XCTKForAll
        {
            (s: String) async in
            
            XCTKAssertEqual(s + "", s)
        }
    }
    
    
    
    @Reasync
    func testArbitraryTwoParameterSuccess() async
    {
        await XCTKForAll
        {
            (a: Int, b: Int) async in
            
            XCTKAssertEqual(a + b, b + a)
        }
    }
    
    
    
    @Reasync
    func testArbitraryThreeParameterSuccess() async
    {
        await XCTKForAll
        {
            (a: Int, b: Int, c: Int) async in
            
            XCTKAssertEqual((a + b) + c, a + (b + c))
        }
    }
    
    
    
    @Reasync
    func testArbitraryTwoParameterFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll
            {
                (a: Int, b: Int) async in
                
                XCTKAssertEqual(a - b, b - a)
            }
        }
    }
    
    
    
    @Reasync
    func testArbitraryThreeParameterFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll
            {
                (_: Int, _: String, _: Bool) async in
                
                XCTKAssertTrue(false)
            }
        }
    }
    
    
    
    // MARK: - Generator
    
    @Reasync
    func testGeneratorSuccess() async
    {
        await XCTKForAll(using: Generator<Int>.integer(in: 1...100))
        {
            (n: Int) async in
            
            XCTKAssertGreaterThan(n, 0)
        }
    }
    
    
    
    @Reasync
    func testGeneratorFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll(using: Generator<Int>.integer(in: 1...100))
            {
                (n: Int) async in
                
                XCTKAssertGreaterThan(n, 200)
            }
        }
    }
    
    
    
    @Reasync
    func testMultiParameterGeneratorSuccess() async
    {
        await XCTKForAll(
            using:  Generator<Int>.integer(in: 1...100),
                    Generator<Int>.integer(in: 1...100)
        )
        {
            (a: Int, b: Int) async in
            
            XCTKAssertGreaterThan(a + b, 0)
        }
    }
    
    
    
    // MARK: - Precondition
    
    @Reasync
    func testPreconditionSuccess() async
    {
        await XCTKForAll(where: { $0 % 2 == 0 })
        {
            (n: Int) async in
            
            XCTKAssertEqual(n % 2, 0)
        }
    }
    
    
    
    @Reasync
    func testPreconditionFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll(where: { $0 >= 0 })
            {
                (n: Int) async in
                
                XCTKAssertGreaterThan(n, 50)
            }
        }
    }
    
    
    
    @Reasync
    func testPreconditionMultiParameterSuccess() async
    {
        await XCTKForAll(
            where: { (a: Int, b: Int) in (a % 2 == 0) && (b % 2 == 0) }
        )
        {
            (a: Int, b: Int) async in
            
            XCTKAssertEqual(a % 2, 0)
            XCTKAssertEqual(b % 2, 0)
        }
    }
    
    
    
    @Reasync
    func testPreconditionMultiParameterFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll(where: { $0 >= 0 && $1 >= 0 })
            {
                (a: Int, b: Int) async in
                
                XCTKAssertEqual(a, b)
            }
        }
    }
    
    
    
    // MARK: - Precondition generator
    
    @Reasync
    func testPreconditionGeneratorSuccess() async
    {
        await XCTKForAll(
            using:  Generator<Int>.integer(in: 0...100),
            where:  { $0 > 10 }
        )
        {
            (n: Int) async in
            
            XCTKAssertGreaterThan(n, 10)
        }
    }
    
    
    
    @Reasync
    func testPreconditionGeneratorFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:  Generator<Int>.integer(in: 0...100),
                where:  { $0 > 10 }
            )
            {
                (n: Int) async in
                
                XCTKAssertGreaterThan(n, 200)
            }
        }
    }
    
    
    
    @Reasync
    func testMultiParameterPreconditionGeneratorSuccess() async
    {
        await XCTKForAll(
            using:  Generator<Int>.integer(in: 0...100),
                    Generator<Int>.integer(in: 0...100),
            where:  { $0 <= $1 }
        )
        {
            (a: Int, b: Int) async in
            
            XCTKAssertLessThanOrEqual(a, b)
        }
    }
    
    
    
    @Reasync
    func testMultiParameterPreconditionGeneratorFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll(
                using:  Generator<Int>.integer(in: 0...100),
                        Generator<Int>.integer(in: 0...100),
                where:  { $0 <= $1 }
            )
            {
                (a: Int, b: Int) async in
                
                XCTKAssertEqual(a, b)
            }
        }
    }
    
    
    
    // MARK: - Throwing
    
    @Reasync
    func testThrowingPropertyTreatedAsFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll
            {
                (_: Int) async throws in
                
                throw TestError()
            }
        }
    }
    
    
    
    @Reasync
    func testUnwrapSuccessInsideBody() async
    {
        await XCTKForAll
        {
            (n: Int) async throws in
            
            let value: Int = try XCTKUnwrap(Optional(n))
            
            XCTKAssertEqual(value, n)
        }
    }
    
    
    
    @Reasync
    func testUnwrapNilInsideBodyTreatedAsFailure() async
    {
        await withOneExpectedFailure
        {
            await XCTKForAll
            {
                (_: Int) async throws in
                
                _ = try XCTKUnwrap(Optional<Int>(nil))
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
            await XCTKForAll(options: options)
            {
                (n: Int) async in
                
                XCTKAssertEqual(n, 0)
            }
        }
        
        let output2: String? = await withOneExpectedFailure
        {
            await XCTKForAll(options: options)
            {
                (n: Int) async in
                
                XCTKAssertEqual(n, 0)
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
            await XCTKForAll(options: options)
            {
                (_: Int) async in
                
                XCTKAssertEqual(1, 2)
            }
        }
    }
    
    
    
    // MARK: - Iteration count
    
    @Reasync
    func testIterationCount() async
    {
        let iterations  : Int   = 1000
        var count       : Int   = 0
        
        await XCTKForAll(options: .propertyOptions(iterations: iterations))
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
        
        await XCTKForAll(options: .propertyOptions(iterations: 0))
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
            await XCTKForAll(
                where:      { (_: Int) in false },
                options:    options
            )
            {
                (_: Int) async in
            }
        }
    }
    
    
    
    // MARK: - No assertion
    
    @Reasync
    func testArbitraryBodyWithNoAssertionVacuouslyPasses() async
    {
        await XCTKForAll
        {
            (n: Int) async in
            
            _ = n * 2
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
            await XCTKForAll(options: options)
            {
                (_: Int) async in
                
                await XCTKForAll(options: options)
                {
                    (_: Int) async in
                    
                    XCTKAssertTrue(false)
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
            await XCTKForAll(options: options)
            {
                (_: Int) async in
                
                XCTKAssertTrue(false)
            }
        }
        
        await XCTKForAll(options: options)
        {
            (n: Int) async in
            
            XCTKAssertEqual(n + 0, n)
        }
    }
}
