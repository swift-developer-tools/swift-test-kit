//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import XCTestKit



internal final class ForAllIntegrationTests: XCTestKitCase
{
    // MARK: - Arbitrary
    
    func testArbitrarySuccess() throws
    {
        XCTKForAll
        {
            (n: Int) in
            
            XCTKAssertEqual(n + 0, n)
        }
    }
    
    
    
    func testArbitraryFailure() throws
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (_: Int) in
            
            XCTKAssertTrue(false)
        }
    }
    
    
    
    func testArbitraryOneParameterSuccess() throws
    {
        XCTKForAll
        {
            (s: String) in
            
            XCTKAssertEqual(s + "", s)
        }
    }
    
    
    
    func testArbitraryTwoParameterSuccess() throws
    {
        XCTKForAll
        {
            (a: Int, b: Int) in
            
            XCTKAssertEqual(a + b, b + a)
        }
    }
    
    
    
    func testArbitraryThreeParameterSuccess() throws
    {
        XCTKForAll
        {
            (a: Int, b: Int, c: Int) in
            
            XCTKAssertEqual((a + b) + c, a + (b + c))
        }
    }
    
    
    
    func testArbitraryTwoParameterFailure() throws
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (a: Int, b: Int) in
            
            XCTKAssertEqual(a - b, b - a)
        }
    }
    
    
    
    func testArbitraryThreeParameterFailure() throws
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (_: Int, _: String, _: Bool) in
            
            XCTKAssertTrue(false)
        }
    }
    
    
    
    // MARK: - Generator
    
    func testGeneratorSuccess() throws
    {
        XCTKForAll(using: Generator<Int>.integer(in: 1...100))
        {
            (n: Int) in
            
            XCTKAssertGreaterThan(n, 0)
        }
    }
    
    
    
    func testGeneratorFailure() throws
    {
        XCTExpectFailure()
        
        XCTKForAll(using: Generator<Int>.integer(in: 1...100))
        {
            (n: Int) in
            
            XCTKAssertGreaterThan(n, 200)
        }
    }
    
    
    
    func testMultiParameterGeneratorSuccess() throws
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
    
    func testPreconditionSuccess() throws
    {
        XCTKForAll(where: { $0 % 2 == 0 })
        {
            (n: Int) in
            
            XCTKAssertEqual(n % 2, 0)
        }
    }
    
    
    
    func testPreconditionFailure() throws
    {
        XCTExpectFailure()
        
        XCTKForAll(where: { $0 >= 0 })
        {
            (n: Int) in
            
            XCTKAssertGreaterThan(n, 50)
        }
    }
    
    
    
    func testPreconditionMultiParameterSuccess() throws
    {
        XCTKForAll(where: { (a: Int, b: Int) in (a % 2 == 0) && (b % 2 == 0) })
        {
            (a: Int, b: Int) in
            
            XCTKAssertEqual(a % 2, 0)
            XCTKAssertEqual(b % 2, 0)
        }
    }
    
    
    
    func testPreconditionMultiParameterFailure() throws
    {
        XCTExpectFailure()
        
        XCTKForAll(where: { $0 >= 0 && $1 >= 0 })
        {
            (a: Int, b: Int) in
            
            XCTKAssertEqual(a, b)
        }
    }
    
    
    
    // MARK: - Precondition generator
    
    func testPreconditionGeneratorSuccess() throws
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
    
    
    
    func testPreconditionGeneratorFailure() throws
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
    
    
    
    func testMultiParameterPreconditionGeneratorSuccess() throws
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
    
    
    
    func testMultiParameterPreconditionGeneratorFailure() throws
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
    
    func testThrowingPropertyTreatedAsFailure() throws
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (_: Int) in
            
            throw TestError()
        }
    }
    
    
    
    func testUnwrapSuccessInsideBody() throws
    {
        XCTKForAll
        {
            (n: Int) in
            
            let value: Int = try XCTKUnwrap(Optional(n))
            
            XCTKAssertEqual(value, n)
        }
    }
    
    
    
    func testUnwrapNilInsideBodyTreatedAsFailure() throws
    {
        XCTExpectFailure()
        
        XCTKForAll
        {
            (_: Int) in
            
            _ = try XCTKUnwrap(Optional<Int>(nil))
        }
    }
    
    
    
    // MARK: - Seed replay
    
    func testSeedReplayProducesSameOutput() throws
    {
        let seed: UInt64 = 12345
        
        let propertyOptions = TKPropertyOptions(
            iterations:     10,
            seed:           seed
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        
        
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
    
    func testAssertionInsideBodyDoesNotLeakAsSeparateFailure() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     10,
            seed:           1
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
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
    
    func testIterationCount() throws
    {
        let iterations  : Int   = 0
        var count       : Int   = 0
        
        let propertyOptions     = TKPropertyOptions(iterations: iterations)
        let options             = TKOptions(propertyOptions: propertyOptions)
        
        XCTKForAll(options: options)
        {
            (_: Int) in
            
            count += 1
        }
        
        XCTAssertEqual(count, iterations)
    }
    
    
    
    func testZeroIterationsVacuouslyPasses() throws
    {
        var count: Int = 0
        
        let propertyOptions     = TKPropertyOptions(iterations: 0)
        let options             = TKOptions(propertyOptions: propertyOptions)
        
        XCTKForAll(options: options)
        {
            (_: Int) in
            
            count += 1
        }
        
        XCTAssertEqual(count, 0)
    }
    
    
    
    // MARK: - Exhaustion
    
    func testExhaustionTreatedAsFailure() throws
    {
        XCTExpectFailure()
        
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           1
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
        XCTKForAll(
            where:      { (_: Int) in false },
            options:    options
        )
        {
            (_: Int) in
        }
    }
    
    
    
    // MARK: - No assertion
    
    func testArbitraryBodyWithNoAssertionVacuouslyPasses() throws
    {
        XCTKForAll
        {
            (n: Int) in
            
            _ = n * 2
        }
    }
    
    
    
    // MARK: - Nested
    
    func testNestedProducesOneFailure() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     1,
            seed:           1
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
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
    
    func testSequentialNoLeakFromPriorFailure() throws
    {
        let propertyOptions = TKPropertyOptions(
            iterations:     10,
            seed:           1
        )
        
        let options = TKOptions(propertyOptions: propertyOptions)
        
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
