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



internal final class OptionalArbitraryTests: TestKitCase
{
    // MARK: - Generation
    
    func testArbitraryDeterminism()
    {
        assertArbitraryDeterminism(of: Optional<Int>.self)
    }
    
    
    
    func testArbitraryProducesBothNilAndNonNil()
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
    
    
    
    func testArbitraryNilRatio()
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
        
        assertApproximateRatio(ratio, 0.2, n: iterations)
    }
    
    
    
    func testArbitraryNonNilValuesRespectSizeBounds()
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let value = Optional<Int>.arbitrary(using: .randomSeed(size: size))
            
            guard let unwrapped: Int = value
            else
            {
                continue
            }
            
            XCTAssertGreaterThanOrEqual(unwrapped, -size)
            XCTAssertLessThanOrEqual(unwrapped, size)
        }
    }
    
    
    
    func testArbitrarySizeZeroProducesZeroOrNil()
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
    
    
    
    func testNestedOptionalGenerationProducesAllCases()
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
    
    func testShrinkNilReturnsEmpty()
    {
        let value: Optional<Int> = nil
        
        XCTAssertEqual(value.shrink(), [])
    }
    
    
    
    func testShrinkSomeIncludesNilAsFirstCandidate()
    {
        let value       : Optional<Int>     = 10
        let candidates  : [Optional<Int>]   = value.shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first!, nil)
    }
    
    
    
    func testShrinkSomeIncludesWrappedShrinkCandidates()
    {
        let value       : Optional<Int>     = 10
        let candidates  : [Optional<Int>]   = value.shrink()
        
        let wrappedCandidates: [Optional<Int>]
            = (10 as Int).shrink().map { .some($0) }
        
        let expected: [Optional<Int>] = [nil] + wrappedCandidates
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testShrinkSomeNegativeIncludesWrappedShrinkCandidates()
    {
        let value       : Optional<Int>     = -7
        let candidates  : [Optional<Int>]   = value.shrink()
        
        let wrappedCandidates: [Optional<Int>]
            = (-7 as Int).shrink().map { .some($0) }
        
        let expected: [Optional<Int>] = [nil] + wrappedCandidates
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testShrinkSomeZeroReturnsOnlyNil()
    {
        let value       : Optional<Int>     = 0
        let candidates  : [Optional<Int>]   = value.shrink()
        
        XCTAssertEqual(candidates, [nil])
    }
    
    
    
    func testShrinkSomeBoolTrue()
    {
        let value       : Optional<Bool>    = true
        let candidates  : [Optional<Bool>]  = value.shrink()
        
        XCTAssertEqual(candidates, [nil, false])
    }
    
    
    
    func testShrinkSomeBoolFalse()
    {
        let value       : Optional<Bool>    = false
        let candidates  : [Optional<Bool>]  = value.shrink()
        
        XCTAssertEqual(candidates, [nil])
    }
    
    
    
    func testShrinkSomeStringIncludesWrappedShrinkCandidates()
    {
        let value       : Optional<String>      = "ab"
        let candidates  : [Optional<String>]    = value.shrink()
        
        let wrappedCandidates: [Optional<String>]
            = ("ab" as String).shrink().map { .some($0) }
        
        let expected: [Optional<String>] = [nil] + wrappedCandidates
        
        XCTAssertEqual(candidates, expected)
    }
    
    
    
    func testShrinkSomeEmptyStringReturnsOnlyNil()
    {
        let value       : Optional<String>      = ""
        let candidates  : [Optional<String>]    = value.shrink()
        
        XCTAssertEqual(candidates, [nil])
    }
    
    
    
    func testNestedOptionalShrinkOuterNil()
    {
        let value       : Optional<Optional<Int>>       = nil
        let candidates  : [Optional<Optional<Int>>]     = value.shrink()
        
        XCTAssertEqual(candidates, [])
    }
    
    
    
    func testNestedOptionalShrinkInnerNil()
    {
        let value       : Optional<Optional<Int>>       = .some(nil)
        let candidates  : [Optional<Optional<Int>>]     = value.shrink()
        
        /// `.some(nil).shrink()` produces `[nil]`, plus
        /// `nil.shrink().map { .some($0) }`. Since `nil.shrink()` produces
        /// the empty array, the expectation is only `[nil]`.
        XCTAssertEqual(candidates, [nil])
    }
    
    
    
    func testNestedOptionalShrinkSomeValue()
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
    
    
    
    // MARK: - Mutation
    
    func testMutateNilAlwaysProducesSome()
    {
        for _ in 0..<1000
        {
            let value   : Optional<Int>     = nil
            let mutated : Optional<Int>     = value.mutate(using: .random)
            
            XCTAssertNotNil(mutated)
        }
    }
    
    
    
    func testMutateSomeProducesBothNilAndNonNil()
    {
        var hasNil      : Bool  = false
        var hasNonNil   : Bool  = false
        
        for _ in 0..<1000
        {
            let value   : Optional<Int>     = 50
            let mutated : Optional<Int>     = value.mutate(using: .random)
            
            if mutated == nil
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
    
    
    
    func testMutateSomeNilRatio()
    {
        var nilCount    : Int   = 0
        let iterations  : Int   = 10_000
        
        for _ in 0..<iterations
        {
            let value   : Optional<Int>     = 50
            let mutated : Optional<Int>     = value.mutate(using: .random)
            
            if mutated == nil
            {
                nilCount += 1
            }
        }
        
        let ratio = Double(nilCount) / Double(iterations)
        
        assertApproximateRatio(ratio, 0.1, n: iterations)
    }
    
    
    
    func testMutateSomeDelegatesToWrappedMutate()
    {
        var changed: Int = 0
        
        for _ in 0..<1000
        {
            let value   : Optional<Int>     = 50
            let mutated : Optional<Int>     = value.mutate(using: .random)
            
            guard let unwrapped: Int = mutated
            else
            {
                continue
            }
            
            if unwrapped != 50
            {
                changed += 1
            }
        }
        
        /// Most non-`nil` mutations should change the wrapped value.
        XCTAssertGreaterThan(changed, 0)
    }
    
    
    
    func testMutateNestedOptional()
    {
        var nilToSome       : Bool  = false
        var someNilToSome   : Bool  = false
        var someToNil       : Bool  = false
        var someToMutated   : Bool  = false
        
        for _ in 0..<10_000
        {
            let outerNil    : Optional<Optional<Int>>   = nil
            let innerNil    : Optional<Optional<Int>>   = .some(nil)
            let someValue   : Optional<Optional<Int>>   = .some(50)
            
            let m1: Optional<Optional<Int>> = outerNil.mutate(using: .random)
            let m2: Optional<Optional<Int>> = innerNil.mutate(using: .random)
            let m3: Optional<Optional<Int>> = someValue.mutate(using: .random)
            
            if m1 != nil
            {
                nilToSome = true
            }
            
            if case .some(.some) = m2
            {
                someNilToSome = true
            }
            
            if m3 == nil
            {
                someToNil = true
            }
            else if
                case let .some(.some(v)) = m3,
                v != 50
            {
                someToMutated = true
            }
            
            if
                nilToSome,
                someNilToSome,
                someToNil,
                someToMutated
            {
                break
            }
        }
        
        XCTAssertTrue(nilToSome)
        XCTAssertTrue(someNilToSome)
        XCTAssertTrue(someToNil)
        XCTAssertTrue(someToMutated)
    }
}
