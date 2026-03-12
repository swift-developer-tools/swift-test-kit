//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

@testable import TestKitCore
import XCTest



internal final class DateGeneratorTests: TestKitCase
{
    // MARK: - Closed range generation
    
    func testClosedRangeDeterminism()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        
        generator.assertDeterministic()
    }
    
    
    
    func testClosedRangeProducesValuesWithinBounds()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        
        for _ in 0..<1000
        {
            let date: Date = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(date, lower)
            XCTAssertLessThanOrEqual(date, upper)
        }
    }
    
    
    
    func testClosedRangeSinglePointProducesExactDate()
    {
        let date        : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: date...date)
        
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), date)
        }
    }
    
    
    
    // MARK: - Closed range shrinking
    
    func testClosedRangeShrinkTowardReferenceDateWhenInRange()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        let date        : Date              = Self.oneYearAfter
        let candidates  : [Date]            = generator.shrink(date)
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertTrue(candidates.contains(Self.referenceDate))
    }
    
    
    
    func testClosedRangeShrinksTowardLowerBoundWhenRangeEntirelyAfter()
    {
        let lower       : Date              = Self.oneYearAfter
        let upper       : Date              = Self.twoYearsAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        let candidates  : [Date]            = generator.shrink(upper)
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertTrue(candidates.contains(lower))
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate, lower)
            XCTAssertLessThanOrEqual(candidate, upper)
        }
    }
    
    
    
    func testClosedRangeShrinksTowardLowerBoundWhenRangeEntirelyBefore()
    {
        let lower       : Date              = Self.twoYearsBefore
        let upper       : Date              = Self.oneYearBefore
        let generator   : Generator<Date>   = .date(in: lower...upper)
        let candidates  : [Date]            = generator.shrink(lower)
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertTrue(candidates.contains(upper))
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate, lower)
            XCTAssertLessThanOrEqual(candidate, upper)
        }
    }
    
    
    
    func testClosedRangeShrinkAtTargetProducesEmpty()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        
        let candidates: [Date] = generator.shrink(Self.referenceDate)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testClosedRangeShrinkSinglePointProducesEmpty()
    {
        let date        : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: date...date)
        let candidates  : [Date]            = generator.shrink(date)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testClosedRangeShrinkCandidatesAreCloserToTarget()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        let candidates  : [Date]            = generator.shrink(upper)
        
        let originalDistance: TimeInterval
            = abs(upper.timeIntervalSinceReferenceDate)
        
        for candidate in candidates
        {
            let candidateDistance: TimeInterval
                = abs(candidate.timeIntervalSinceReferenceDate)
            
            XCTAssertLessThanOrEqual(candidateDistance, originalDistance)
        }
    }
    
    
    
    // MARK: - Closed range mutation
    
    func testClosedRangeMutationRespectsBounds()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        
        for _ in 0..<1000
        {
            let date    : Date  = generator.generate(.random)
            let mutated : Date  = generator.mutate(date, .random)
            
            XCTAssertGreaterThanOrEqual(mutated, lower)
            XCTAssertLessThanOrEqual(mutated, upper)
        }
    }
    
    
    
    func testClosedRangeMutationChangesValue()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        var changed     : Bool              = false
        
        for _ in 0..<1000
        {
            let date    : Date  = generator.generate(.randomSeed(size: 50))
            let mutated : Date  = generator.mutate(date, .random)
            
            if mutated != date
            {
                changed = true
                break
            }
        }
        
        XCTAssertTrue(changed)
    }
    
    
    
    func testClosedRangeMutationAtLowerBoundStaysWithinRange()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        
        for _ in 0..<1000
        {
            let mutated: Date = generator.mutate(lower, .random)
            
            XCTAssertGreaterThanOrEqual(mutated, lower)
            XCTAssertLessThanOrEqual(mutated, upper)
        }
    }
    
    
    
    func testClosedRangeMutationAtUpperBoundStaysWithinRange()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower...upper)
        
        for _ in 0..<1000
        {
            let mutated: Date = generator.mutate(upper, .random)
            
            XCTAssertGreaterThanOrEqual(mutated, lower)
            XCTAssertLessThanOrEqual(mutated, upper)
        }
    }
    
    
    
    // MARK: - Range generation
    
    func testRangeDeterminism()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        
        generator.assertDeterministic()
    }
    
    
    
    func testRangeProducesValuesWithinBounds()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        
        for _ in 0..<1000
        {
            let date: Date = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(date, lower)
            XCTAssertLessThan(date, upper)
        }
    }
    
    
    
    // MARK: - Range shrinking
    
    func testRangeShrinkTowardReferenceDateWhenInRange()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        let date        : Date              = Self.oneYearAfter
        let candidates  : [Date]            = generator.shrink(date)
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertTrue(candidates.contains(Self.referenceDate))
    }
    
    
    
    func testRangeShrinksTowardLowerBoundWhenRangeEntirelyAfter()
    {
        let lower       : Date              = Self.oneYearAfter
        let upper       : Date              = Self.twoYearsAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        let candidates  : [Date]            = generator.shrink(upper)
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertTrue(candidates.contains(lower))
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate, lower)
            XCTAssertLessThan(candidate, upper)
        }
    }
    
    
    
    func testRangeShrinksExcludesUpperBound()
    {
        let lower       : Date              = Self.oneYearAfter
        let upper       : Date              = Self.twoYearsAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        
        let date = Date(timeIntervalSinceReferenceDate:
            upper.timeIntervalSinceReferenceDate - 1
        )
        
        let candidates: [Date] = generator.shrink(date)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate, lower)
            XCTAssertLessThan(candidate, upper)
        }
    }
    
    
    
    func testRangeShrinksTowardLowerBoundWhenRangeEntirelyBefore()
    {
        let lower       : Date              = Self.twoYearsBefore
        let upper       : Date              = Self.oneYearBefore
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        let candidates  : [Date]            = generator.shrink(lower)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate, lower)
            XCTAssertLessThan(candidate, upper)
        }
    }
    
    
    
    func testRangeShrinkAtTargetProducesEmpty()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        
        let candidates: [Date] = generator.shrink(Self.referenceDate)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testRangeShrinkCandidatesAreCloserToTarget()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        let candidates  : [Date]            = generator.shrink(upper)
        
        let originalDistance: TimeInterval
            = abs(upper.timeIntervalSinceReferenceDate)
        
        for candidate in candidates
        {
            let candidateDistance: TimeInterval
                = abs(candidate.timeIntervalSinceReferenceDate)
            
            XCTAssertLessThan(candidateDistance, originalDistance)
        }
    }
    
    
    
    // MARK: - Range mutation
    
    func testRangeMutationRespectsBounds()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        
        for _ in 0..<1000
        {
            let date    : Date  = generator.generate(.random)
            let mutated : Date  = generator.mutate(date, .random)
            
            XCTAssertGreaterThanOrEqual(mutated, lower)
            XCTAssertLessThan(mutated, upper)
        }
    }
    
    
    
    func testRangeMutationChangesValue()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        var changed     : Bool              = false
        
        for _ in 0..<1000
        {
            let date    : Date  = generator.generate(.randomSeed(size: 50))
            let mutated : Date  = generator.mutate(date, .random)
            
            if mutated != date
            {
                changed = true
                break
            }
        }
        
        XCTAssertTrue(changed)
    }
    
    
    
    func testRangeMutationAtLowerBoundStaysWithinRange()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        
        for _ in 0..<1000
        {
            let mutated: Date = generator.mutate(lower, .random)
            
            XCTAssertGreaterThanOrEqual(mutated, lower)
            XCTAssertLessThan(mutated, upper)
        }
    }
    
    
    
    func testRangeMutationAtUpperBoundStaysWithinRange()
    {
        let lower       : Date              = Self.oneYearBefore
        let upper       : Date              = Self.oneYearAfter
        let generator   : Generator<Date>   = .date(in: lower..<upper)
        
        for _ in 0..<1000
        {
            let mutated: Date = generator.mutate(upper, .random)
            
            XCTAssertGreaterThanOrEqual(mutated, lower)
            XCTAssertLessThan(mutated, upper)
        }
    }
}



// MARK: - Support

extension DateGeneratorTests
{
    private static let referenceDate: Date
        = Date(timeIntervalSinceReferenceDate: 0)
    
    private static let oneYearBefore: Date
        = Date(timeIntervalSinceReferenceDate: -365.25 * 24 * 60 * 60)
    
    private static let oneYearAfter: Date
        = Date(timeIntervalSinceReferenceDate: 365.25 * 24 * 60 * 60)
    
    private static let twoYearsBefore: Date
        = Date(timeIntervalSinceReferenceDate: 2 * -365.25 * 24 * 60 * 60)
    
    private static let twoYearsAfter: Date
        = Date(timeIntervalSinceReferenceDate: 2 * 365.25 * 24 * 60 * 60)
}
