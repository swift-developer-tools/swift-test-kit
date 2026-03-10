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



internal final class ResultArbitraryTests: TestKitCase
{
    // MARK: - Determinism
    
    func testArbitraryDeterminism()
    {
        assertArbitraryDeterminism(of: TestResult.self)
    }
    
    
    
    // MARK: - Generation
    
    func testArbitraryProducesBothCases()
    {
        var hasSuccess  : Bool  = false
        var hasFailure  : Bool  = false
        
        for _ in 0..<1000
        {
            let value = TestResult.arbitrary(using: .random)
            
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
    
    
    
    func testArbitraryCaseRatio()
    {
        var successCount    : Int   = 0
        let iterations      : Int   = 10_000
        
        for _ in 0..<iterations
        {
            let value = TestResult.arbitrary(using: .random)
            
            if case .success = value
            {
                successCount += 1
            }
        }
        
        let ratio = Double(successCount) / Double(iterations)
        
        assertApproximateRatio(ratio, 0.5, n: iterations)
    }
    
    
    
    func testArbitrarySuccessValuesRespectSizeBounds()
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let value = TestResult.arbitrary(using: .randomSeed(size: size))
            
            guard case let .success(n) = value
            else
            {
                continue
            }
            
            XCTAssertGreaterThanOrEqual(n, -size)
            XCTAssertLessThanOrEqual(n, size)
        }
    }
    
    
    
    func testArbitraryFailureValuesRespectSizeBounds()
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let value = TestResult.arbitrary(using: .randomSeed(size: size))
            
            guard case let .failure(error) = value
            else
            {
                continue
            }
            
            XCTAssertGreaterThanOrEqual(error.code, -size)
            XCTAssertLessThanOrEqual(error.code, size)
        }
    }
    
    
    
    func testArbitrarySizeZeroProducesZeroAssociatedValues()
    {
        for _ in 0..<1000
        {
            let value = TestResult.arbitrary(using: .randomZeroSize)
            
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
    
    func testShrinkSuccessPreservesCaseAndShrinksValue()
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
    
    
    
    func testShrinkFailurePreservesCaseAndShrinksValue()
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
    
    
    
    func testShrinkSuccessNegativePreservesCaseAndShrinksValue()
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
    
    
    
    func testShrinkFailureNegativePreservesCaseAndShrinksValue()
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
    
    
    
    func testShrinkSuccessZeroReturnsEmpty()
    {
        let value       : TestResult    = .success(0)
        let candidates  : [TestResult]  = value.shrink()
        
        XCTAssertEqual(candidates, [])
    }
    
    
    
    func testShrinkFailureZeroReturnsEmpty()
    {
        let value       : TestResult    = .failure(ArbitraryError(code: 0))
        let candidates  : [TestResult]  = value.shrink()
        
        XCTAssertEqual(candidates, [])
    }
    
    
    
    func testShrinkSuccessOneReturnsSuccessZero()
    {
        let value       : TestResult    = .success(1)
        let candidates  : [TestResult]  = value.shrink()
        
        XCTAssertEqual(candidates, [.success(0)])
    }
    
    
    
    func testShrinkFailureOneReturnsSuccessZero()
    {
        let value       : TestResult    = .failure(ArbitraryError(code: 1))
        let candidates  : [TestResult]  = value.shrink()
        
        XCTAssertEqual(candidates, [.failure(ArbitraryError(code: 0))])
    }
    
    
    
    // MARK: - Mutation
    
    func testMutateSuccessPreservesCase()
    {
        for _ in 0..<1000
        {
            let value   : TestResult    = .success(50)
            let mutated : TestResult    = value.mutate(using: .random)
            
            guard case .success = mutated
            else
            {
                XCTFail("Expected .success, got \(mutated)")
                return
            }
        }
    }
    
    
    
    func testMutateFailurePreservesCase()
    {
        for _ in 0..<1000
        {
            let value   : TestResult    = .failure(ArbitraryError(code: 50))
            let mutated : TestResult    = value.mutate(using: .random)
            
            guard case .failure = mutated
            else
            {
                XCTFail("Expected .failure, got \(mutated)")
                return
            }
        }
    }
    
    
    
    func testMutateDelegatesToAssociatedValue()
    {
        var successChanged  : Bool  = false
        var failureChanged  : Bool  = false
        
        for _ in 0..<1000
        {
            let s           : TestResult    = .success(50)
            let sMutated    : TestResult    = s.mutate(using: .random)
            
            if
                case let .success(v) = sMutated,
                v != 50
            {
                successChanged = true
            }
            
            let f           : TestResult    = .failure(ArbitraryError(code: 50))
            let fMutated    : TestResult    = f.mutate(using: .random)
            
            if
                case let .failure(e) = fMutated,
                e.code != 50
            {
                failureChanged = true
            }
            
            if
                successChanged,
                failureChanged
            {
                break
            }
        }
        
        XCTAssertTrue(successChanged)
        XCTAssertTrue(failureChanged)
    }
}



// MARK: - Support

extension ResultArbitraryTests
{
    private typealias TestResult = Result<Int, ArbitraryError>
    
    
    
    private struct ArbitraryError: Error, Arbitrary, Equatable
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
