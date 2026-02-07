//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitBase



internal final class ResultArbitraryTests: XCTestCase
{
    // MARK: - Generation
    
    func testArbitraryDeterminism() throws
    {
        let context1    = GenerationContext(seed: 40, size: 50)
        let context2    = GenerationContext(seed: 40, size: 50)
        
        for _ in 0..<1000
        {
            XCTAssertEqual(
                TestResult.arbitrary(using: context1),
                TestResult.arbitrary(using: context2)
            )
        }
    }
    
    
    
    func testArbitraryProducesBothCases() throws
    {
        let context     : GenerationContext     = .init(seed: 50, size: 50)
        var hasSuccess  : Bool                  = false
        var hasFailure  : Bool                  = false
        
        for _ in 0..<1000
        {
            let value = TestResult.arbitrary(using: context)
            
            switch value
            {
                case .success   : hasSuccess    = true
                case .failure   : hasFailure    = true
            }
            
            if
                hasSuccess,
                hasFailure
            {
                break
            }
        }
        
        XCTAssertTrue(hasSuccess)
        XCTAssertTrue(hasFailure)
    }
    
    
    
    func testArbitraryCaseRatio() throws
    {
        let context         : GenerationContext     = .init(seed: 50, size: 50)
        var successCount    : Int                   = 0
        let iterations      : Int                   = 10_000
        
        for _ in 0..<iterations
        {
            let value = TestResult.arbitrary(using: context)
            
            if case .success = value
            {
                successCount += 1
            }
        }
        
        let ratio = Double(successCount) / Double(iterations)
        
        XCTAssertGreaterThan(ratio, 0.5 * 0.95)
        XCTAssertLessThan(ratio, 0.5 * 1.05)
    }
    
    
    
    func testArbitrarySuccessValuesRespectSizeBounds() throws
    {
        let size    : Int                   = 10
        let context : GenerationContext     = .init(seed: 50, size: size)
        
        for _ in 0..<1000
        {
            let value = TestResult.arbitrary(using: context)
            
            guard case let .success(n) = value
            else
            {
                continue
            }
            
            XCTAssertGreaterThanOrEqual(n, -size)
            XCTAssertLessThanOrEqual(n, size)
        }
    }
    
    
    
    func testArbitraryFailureValuesRespectSizeBounds() throws
    {
        let size    : Int                   = 10
        let context : GenerationContext     = .init(seed: 50, size: size)
        
        for _ in 0..<1000
        {
            let value = TestResult.arbitrary(using: context)
            
            guard case let .failure(error) = value
            else
            {
                continue
            }
            
            XCTAssertGreaterThanOrEqual(error.code, -size)
            XCTAssertLessThanOrEqual(error.code, size)
        }
    }
    
    
    
    func testArbitrarySizeZeroProducesZeroAssociatedValues() throws
    {
        let context = GenerationContext(seed: 50, size: 0)
        
        for _ in 0..<1000
        {
            let value = TestResult.arbitrary(using: context)
            
            switch value
            {
                case let .success(n):
                    
                    XCTAssertEqual(n, 0)
                    
                case let .failure(error):
                    
                    XCTAssertEqual(error.code, 0)
            }
        }
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkSuccessPreservesCaseAndShrinksValue() throws
    {
        let value       : TestResult    = .success(10)
        let candidates  : [TestResult]  = value.shrink()
        
        let expected: [TestResult] = (10 as Int).shrink().map { .success($0) }
        
        XCTAssertEqual(candidates, expected)
        
        for candidate in candidates
        {
            guard case .success = candidate
            else
            {
                XCTFail("Expected .success, got \(candidate)")
                return
            }
        }
    }
    
    
    
    func testShrinkFailurePreservesCaseAndShrinksValue() throws
    {
        let value       : TestResult    = .failure(ArbitraryError(code: 10))
        let candidates  : [TestResult]  = value.shrink()
        
        let expected: [TestResult]
            = ArbitraryError(code: 10).shrink().map { .failure($0) }
        
        XCTAssertEqual(candidates, expected)
        
        for candidate in candidates
        {
            guard case .failure = candidate
            else
            {
                XCTFail("Expected .failure, got \(candidate)")
                return
            }
        }
    }
    
    
    
    func testShrinkSuccessNegativePreservesCaseAndShrinksValue() throws
    {
        let value       : TestResult    = .success(-7)
        let candidates  : [TestResult]  = value.shrink()
        
        let expected: [TestResult] = (-7 as Int).shrink().map { .success($0) }
        
        XCTAssertEqual(candidates, expected)
        
        for candidate in candidates
        {
            guard case .success = candidate
            else
            {
                XCTFail("Expected .success, got \(candidate)")
                return
            }
        }
    }
    
    
    
    func testShrinkFailureNegativePreservesCaseAndShrinksValue() throws
    {
        let value       : TestResult    = .failure(ArbitraryError(code: -7))
        let candidates  : [TestResult]  = value.shrink()
        
        let expected: [TestResult]
            = ArbitraryError(code: -7).shrink().map { .failure($0) }
        
        XCTAssertEqual(candidates, expected)
        
        for candidate in candidates
        {
            guard case .failure = candidate
            else
            {
                XCTFail("Expected .failure, got \(candidate)")
                return
            }
        }
    }
    
    
    
    func testShrinkSuccessZeroReturnsEmpty() throws
    {
        let value       : TestResult    = .success(0)
        let candidates  : [TestResult]  = value.shrink()
        
        XCTAssertEqual(candidates, [])
    }
    
    
    
    func testShrinkFailureZeroReturnsEmpty() throws
    {
        let value       : TestResult    = .failure(ArbitraryError(code: 0))
        let candidates  : [TestResult]  = value.shrink()
        
        XCTAssertEqual(candidates, [])
    }
    
    
    
    func testShrinkSuccessOneReturnsSuccessZero() throws
    {
        let value       : TestResult    = .success(1)
        let candidates  : [TestResult]  = value.shrink()
        
        XCTAssertEqual(candidates, [.success(0)])
    }
    
    
    
    func testShrinkFailureOneReturnsSuccessZero() throws
    {
        let value       : TestResult    = .failure(ArbitraryError(code: 1))
        let candidates  : [TestResult]  = value.shrink()
        
        XCTAssertEqual(candidates, [.failure(ArbitraryError(code: 0))])
    }
}



// MARK: - Extensions

private extension ResultArbitraryTests
{
    typealias TestResult = Result<Int, ArbitraryError>
    
    
    
    struct ArbitraryError: Error, Arbitrary, Equatable
    {
        let code: Int
        
        static func arbitrary(
            using context: GenerationContext
        ) -> ArbitraryError
        {
            return .init(code: Int.arbitrary(using: context))
        }
        
        func shrink() -> [ArbitraryError]
        {
            return code.shrink().map { .init(code: $0) }
        }
    }
}
