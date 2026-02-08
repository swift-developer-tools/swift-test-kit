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



internal final class OptionalArbitraryTests: XCTestCaseStopOnFail
{
    // MARK: - Generation
    
    func testArbitraryDeterminism() throws
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                Optional<Int>.arbitrary(using: context1),
                Optional<Int>.arbitrary(using: context2)
            )
        }
    }
    
    
    
    func testArbitraryProducesBothNilAndNonNil() throws
    {
        var hasNil      : Bool  = false
        var hasNonNil   : Bool  = false
        
        for _ in 0..<1000
        {
            let value = Optional<Int>.arbitrary(using: .random)
            
            if value == nil
            {
                hasNil = true
            }
            else
            {
                hasNonNil = true
            }
            
            if
                hasNil,
                hasNonNil
            {
                break
            }
        }
        
        XCTAssertTrue(hasNil)
        XCTAssertTrue(hasNonNil)
    }
    
    
    
    func testArbitraryNilRatio() throws
    {
        var nilCount    : Int   = 0
        let iterations  : Int   = 10_000
        
        for _ in 0..<iterations
        {
            let value = Optional<Int>.arbitrary(using: .random)
            
            if value == nil
            {
                nilCount += 1
            }
        }
        
        let ratio = Double(nilCount) / Double(iterations)
        
        XCTAssertGreaterThan(ratio, 0.2 * 0.95)
        XCTAssertLessThan(ratio, 0.2 * 1.05)
    }
    
    
    
    func testArbitraryNonNilValuesRespectSizeBounds() throws
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let value = Optional<Int>.arbitrary(using: context)
            
            guard let unwrapped: Int = value
            else
            {
                continue
            }
            
            XCTAssertGreaterThanOrEqual(unwrapped, -size)
            XCTAssertLessThanOrEqual(unwrapped, size)
        }
    }
    
    
    
    func testArbitrarySizeZeroProducesZeroOrNil() throws
    {
        for _ in 0..<1000
        {
            let value = Optional<Int>.arbitrary(using: .randomZeroSize)
            
            if let unwrapped: Int = value
            {
                XCTAssertEqual(unwrapped, 0)
            }
        }
    }
    
    
    
    func testNestedOptionalGenerationProducesAllCases() throws
    {
        var hasOuterNil : Bool  = false
        var hasInnerNil : Bool  = false
        var hasValue    : Bool  = false
        
        for _ in 0..<10_000
        {
            let value = Optional<Optional<Int>>.arbitrary(using: .random)
            
            switch value
            {
                case .none:
                    
                    hasOuterNil = true
                    
                case .some(.none):
                    
                    hasInnerNil = true
                    
                case .some(.some):
                    
                    hasValue = true
            }
            
            if
                hasOuterNil,
                hasInnerNil,
                hasValue
            {
                break
            }
        }
        
        XCTAssertTrue(hasOuterNil)
        XCTAssertTrue(hasInnerNil)
        XCTAssertTrue(hasValue)
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkNilReturnsEmpty() throws
    {
        let value: Optional<Int> = nil
        
        XCTAssertEqual(value.shrink(), [])
    }
    
    
    
    func testShrinkSomeIncludesNilAsFirstCandidate() throws
    {
        let value       : Optional<Int>     = 10
        let candidates  : [Optional<Int>]   = value.shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first!, nil)
    }
    
    
    
    func testShrinkSomeIncludesWrappedShrinkCandidates() throws
    {
        let value       : Optional<Int>     = 10
        let candidates  : [Optional<Int>]   = value.shrink()
        
        let wrappedCandidates: [Optional<Int>]
            = (10 as Int).shrink().map { .some($0) }
        
        let expected: [Optional<Int>] = [nil] + wrappedCandidates
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testShrinkSomeNegativeIncludesWrappedShrinkCandidates() throws
    {
        let value       : Optional<Int>     = -7
        let candidates  : [Optional<Int>]   = value.shrink()
        
        let wrappedCandidates: [Optional<Int>]
            = (-7 as Int).shrink().map { .some($0) }
        
        let expected: [Optional<Int>] = [nil] + wrappedCandidates
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testShrinkSomeZeroReturnsOnlyNil() throws
    {
        let value       : Optional<Int>     = 0
        let candidates  : [Optional<Int>]   = value.shrink()
        
        XCTAssertEqual(candidates, [nil])
    }
    
    
    
    func testShrinkSomeBoolTrue() throws
    {
        let value       : Optional<Bool>    = true
        let candidates  : [Optional<Bool>]  = value.shrink()
        
        XCTAssertEqual(candidates, [nil, false])
    }
    
    
    
    func testShrinkSomeBoolFalse() throws
    {
        let value       : Optional<Bool>    = false
        let candidates  : [Optional<Bool>]  = value.shrink()
        
        XCTAssertEqual(candidates, [nil])
    }
    
    
    
    func testShrinkSomeStringIncludesWrappedShrinkCandidates() throws
    {
        let value       : Optional<String>      = "ab"
        let candidates  : [Optional<String>]    = value.shrink()
        
        let wrappedCandidates: [Optional<String>]
            = ("ab" as String).shrink().map { .some($0) }
        
        let expected: [Optional<String>] = [nil] + wrappedCandidates
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testShrinkSomeEmptyStringReturnsOnlyNil() throws
    {
        let value       : Optional<String>      = ""
        let candidates  : [Optional<String>]    = value.shrink()
        
        XCTAssertEqual(candidates, [nil])
    }
    
    
    
    func testNestedOptionalShrinkOuterNil() throws
    {
        let value       : Optional<Optional<Int>>       = nil
        let candidates  : [Optional<Optional<Int>>]     = value.shrink()
        
        XCTAssertEqual(candidates, [])
    }
    
    
    
    func testNestedOptionalShrinkInnerNil() throws
    {
        let value       : Optional<Optional<Int>>       = .some(nil)
        let candidates  : [Optional<Optional<Int>>]     = value.shrink()
        
        /// `.some(nil).shrink()` produces `[nil]`, plus
        /// `nil.shrink().map { .some($0) }`. Since `nil.shrink()` produces
        /// the empty array, the expectation is only `[nil]`.
        XCTAssertEqual(candidates, [nil])
    }
    
    
    
    func testNestedOptionalShrinkSomeValue() throws
    {
        let value       : Optional<Optional<Int>>       = .some(20)
        let candidates  : [Optional<Optional<Int>>]     = value.shrink()
        
        XCTAssertEqual(
            candidates,
            [
                nil,
                .some(nil),
                .some(0),
                .some(10),
                .some(15),
                .some(18),
                .some(19)
            ]
        )
    }
}
