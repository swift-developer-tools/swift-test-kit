//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTestKit
import XCTest



internal final class ForAllIntegrationTests: XCTestKitCase
{
    // MARK: - Arbitrary
    
    func testArbitrarySuccess()
    {
        XCTKForAll
        {
            (n: Int) in
            
            XCTKAssertEqual(n + 0, n)
        }
    }
    
    
    
    func testArbitraryFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (_: Int) in
            
            XCTKAssertTrue(false)
        }
    }
    
    
    
    func testArbitraryOneParameterSuccess()
    {
        XCTKForAll
        {
            (s: String) in
            
            XCTKAssertEqual(s + "", s)
        }
    }
    
    
    
    func testArbitraryTwoParameterSuccess()
    {
        XCTKForAll
        {
            (a: Int, b: Int) in
            
            XCTKAssertEqual(a + b, b + a)
        }
    }
    
    
    
    func testArbitraryThreeParameterSuccess()
    {
        XCTKForAll
        {
            (a: Int, b: Int, c: Int) in
            
            XCTKAssertEqual((a + b) + c, a + (b + c))
        }
    }
    
    
    
    func testArbitraryTwoParameterFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (a: Int, b: Int) in
            
            XCTKAssertEqual(a - b, b - a)
        }
    }
    
    
    
    func testArbitraryThreeParameterFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (_: Int, _: String, _: Bool) in
            
            XCTKAssertTrue(false)
        }
    }
    
    
    
    // MARK: - Generator
    
    func testGeneratorSuccess()
    {
        XCTKForAll(using: Generator<Int>.integer(in: 1...100))
        {
            (n: Int) in
            
            XCTKAssertGreaterThan(n, 0)
        }
    }
    
    
    
    func testGeneratorFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll(using: Generator<Int>.integer(in: 1...100))
        {
            (n: Int) in
            
            XCTKAssertGreaterThan(n, 200)
        }
    }
    
    
    
    func testMultiParameterGeneratorSuccess()
    {
        XCTKForAll(
            using:  Generator<Int>.integer(in: 1...100),
                    Generator<Int>.integer(in: 1...100)
        )
        {
            (a: Int, b: Int) in
            
            XCTKAssertGreaterThan(a + b, 0)
        }
    }
    
    
    
    // MARK: - Precondition
    
    func testPreconditionSuccess()
    {
        XCTKForAll(where: { $0 % 2 == 0 })
        {
            (n: Int) in
            
            XCTKAssertEqual(n % 2, 0)
        }
    }
    
    
    
    func testPreconditionFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll(where: { $0 >= 0 })
        {
            (n: Int) in
            
            XCTKAssertGreaterThan(n, 50)
        }
    }
    
    
    
    func testPreconditionMultiParameterSuccess()
    {
        XCTKForAll(where: { (a: Int, b: Int) in (a % 2 == 0) && (b % 2 == 0) })
        {
            (a: Int, b: Int) in
            
            XCTKAssertEqual(a % 2, 0)
            XCTKAssertEqual(b % 2, 0)
        }
    }
    
    
    
    func testPreconditionMultiParameterFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll(where: { $0 >= 0 && $1 >= 0 })
        {
            (a: Int, b: Int) in
            
            XCTKAssertEqual(a, b)
        }
    }
    
    
    
    // MARK: - Precondition generator
    
    func testPreconditionGeneratorSuccess()
    {
        XCTKForAll(
            using:  Generator<Int>.integer(in: 0...100),
            where:  { $0 > 10 }
        )
        {
            (n: Int) in
            
            XCTKAssertGreaterThan(n, 10)
        }
    }
    
    
    
    func testPreconditionGeneratorFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll(
            using:  Generator<Int>.integer(in: 0...100),
            where:  { $0 > 10 }
        )
        {
            (n: Int) in
            
            XCTKAssertGreaterThan(n, 200)
        }
    }
    
    
    
    func testMultiParameterPreconditionGeneratorSuccess()
    {
        XCTKForAll(
            using:  Generator<Int>.integer(in: 0...100),
                    Generator<Int>.integer(in: 0...100),
            where:  { $0 <= $1 }
        )
        {
            (a: Int, b: Int) in
            
            XCTKAssertLessThanOrEqual(a, b)
        }
    }
    
    
    
    func testMultiParameterPreconditionGeneratorFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll(
            using:  Generator<Int>.integer(in: 0...100),
                    Generator<Int>.integer(in: 0...100),
            where:  { $0 <= $1 }
        )
        {
            (a: Int, b: Int) in
            
            XCTKAssertEqual(a, b)
        }
    }
    
    
    
    // MARK: - Throwing
    
    func testThrowingPropertyTreatedAsFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (_: Int) in
            
            throw TestError()
        }
    }
    
    
    
    func testUnwrapSuccessInsideBody()
    {
        XCTKForAll
        {
            (n: Int) in
            
            let value: Int = try XCTKUnwrap(Optional(n))
            
            XCTKAssertEqual(value, n)
        }
    }
    
    
    
    func testUnwrapNilInsideBodyTreatedAsFailure()
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (_: Int) in
            
            _ = try XCTKUnwrap(Optional<Int>(nil))
        }
    }
    
    
    
    // MARK: - Seed replay
    
    func testSeedReplayProducesSameOutput()
    {
        let seed: UInt64 = 12345
        
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           seed
        )
        
        let output1: String? = withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (n: Int) in
                
                XCTKAssertEqual(n, 0)
            }
        }
        
        let output2: String? = withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (n: Int) in
                
                XCTKAssertEqual(n, 0)
            }
        }
        
        XCTAssertNotNil(output1)
        XCTAssertNotNil(output2)
        XCTAssertEqual(output1, output2)
    }
    
    
    
    // MARK: - Interception
    
    func testAssertionInsideBodyDoesNotLeakAsSeparateFailure()
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           1
        )
        
        /// If assertion failures are not intercepted, the assertion will
        /// report its failure directly to XCTest, producing more than one
        /// expected failure.
        withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (_: Int) in
                
                XCTKAssertEqual(1, 2)
            }
        }
    }
    
    
    
    // MARK: - Iteration count
    
    func testIterationCount()
    {
        let iterations  : Int   = 0
        var count       : Int   = 0
        
        XCTKForAll(options: .propertyOptions(iterations: iterations))
        {
            (_: Int) in
            
            count += 1
        }
        
        XCTAssertEqual(count, iterations)
    }
    
    
    
    func testZeroIterationsVacuouslyPasses()
    {
        var count: Int = 0
        
        XCTKForAll(options: .propertyOptions(iterations: 0))
        {
            (_: Int) in
            
            count += 1
        }
        
        XCTAssertEqual(count, 0)
    }
    
    
    
    // MARK: - Exhaustion
    
    func testExhaustionTreatedAsFailure()
    {
        XCTExpectFailure()
        
        let options: TestOptions = .propertyOptions(
            iterations:     1,
            seed:           1
        )
        
        XCTKForAll(
            where:      { (_: Int) in false },
            options:    options
        )
        {
            (_: Int) in
        }
    }
    
    
    
    // MARK: - No assertion
    
    func testArbitraryBodyWithNoAssertionVacuouslyPasses()
    {
        XCTKForAll
        {
            (n: Int) in
            
            _ = n * 2
        }
    }
    
    
    
    // MARK: - Nested
    
    func testNestedProducesOneFailure()
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
        withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (_: Int) in
                
                XCTKForAll(options: options)
                {
                    (_: Int) in
                    
                    XCTKAssertTrue(false)
                }
            }
        }
    }
    
    
    
    // MARK: - Sequential
    
    func testSequentialNoLeakFromPriorFailure()
    {
        let options: TestOptions = .propertyOptions(
            iterations:     10,
            seed:           1
        )
        
        /// The first evaluator fails on the first assertion. The second
        /// evaluator succeeds on all assertions. The interceptor state must
        /// not leak into subsequent calls.
        withOneExpectedFailure
        {
            XCTKForAll(options: options)
            {
                (_: Int) in
                
                XCTKAssertTrue(false)
            }
        }
        
        XCTKForAll(options: options)
        {
            (n: Int) in
            
            XCTKAssertEqual(n + 0, n)
        }
    }
}
