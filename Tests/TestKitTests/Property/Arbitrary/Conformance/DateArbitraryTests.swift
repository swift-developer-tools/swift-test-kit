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



internal final class DateArbitraryTests: TestKitCase
{
    // MARK: - Determinism
    
    func testArbitraryDeterminism()
    {
        assertArbitraryDeterminism(of: Date.self)
    }
    
    
    
    // MARK: - Generation
    
    func testGenerationSizeZeroBounds()
    {
        let oneDay: TimeInterval = 60 * 60 * 24
        
        for _ in 0..<1000
        {
            let date: Date = .arbitrary(using: .randomZeroSize)
            
            let interval: TimeInterval = date.timeIntervalSinceReferenceDate
            
            /// At size zero, days is zero. The fractional component is in the
            /// range `-1...1`, so the total interval is within one day.
            XCTAssertGreaterThanOrEqual(interval, -oneDay)
            XCTAssertLessThanOrEqual(interval, oneDay)
        }
    }
    
    
    
    func testGenerationSizeBounds()
    {
        let size    : Int           = 10
        let oneDay  : TimeInterval  = 60 * 60 * 24
        let bound   : TimeInterval  = Double(size + 1) * oneDay
        
        for _ in 0..<1000
        {
            let date: Date = .arbitrary(using: .randomSeed(size: size))
            
            let interval: TimeInterval = date.timeIntervalSinceReferenceDate
            
            /// The days component is in the range `-size...size`, and the
            /// fractional component is in the range `-1...1`, so the total
            /// bound is within `size + 1` days.
            XCTAssertGreaterThanOrEqual(interval, -bound)
            XCTAssertLessThanOrEqual(interval, bound)
        }
    }
    
    
    
    func testGenerationProducesEmptyAndNonEmpty()
    {
        let referenceDate   : Date  = .init(timeIntervalSinceReferenceDate: 0)
        var hasBefore       : Bool  = false
        var hasAfter        : Bool  = false
        
        for _ in 0..<1000
        {
            let data = Date.arbitrary(using: .random)
            
            if data < referenceDate
            {
                hasBefore = true
            }
            else
            {
                hasAfter = true
            }
            
            if
                hasBefore,
                hasAfter
            {
                break
            }
        }
        
        XCTAssertTrue(hasBefore)
        XCTAssertTrue(hasAfter)
    }
    
    
    
    func testGenerationProducesSubSecondPrecision()
    {
        var hasFractionalSecond: Bool = false
        
        for _ in 0..<1000
        {
            let date: Date = .arbitrary(using: .randomZeroSize)
            
            let interval: TimeInterval = date.timeIntervalSinceReferenceDate
            
            if interval != interval.rounded(.towardZero)
            {
                hasFractionalSecond = true
                break
            }
        }
        
        XCTAssertTrue(hasFractionalSecond)
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkingReferenceDateProducesNoCandidates()
    {
        let referenceDate = Date(timeIntervalSinceReferenceDate: 0)
        
        XCTAssertEqual(referenceDate.shrink(), [])
    }
    
    
    
    func testShrinkingFirstCandidateIsReferenceDate()
    {
        for _ in 0..<1000
        {
            let date = Date.arbitrary(using: .random)
            
            guard date.timeIntervalSinceReferenceDate != 0
            else
            {
                continue
            }
            
            let candidates: [Date] = date.shrink()
            
            XCTAssertFalse(candidates.isEmpty)
            XCTAssertEqual(candidates.first!.timeIntervalSinceReferenceDate, 0)
        }
    }
    
    
    
    func testShrinkingCandidatesConvergeTowardReferenceDate()
    {
        for _ in 0..<1000
        {
            let date: Date = .arbitrary(using: .randomZeroSize)
            
            let interval: TimeInterval = date.timeIntervalSinceReferenceDate
            
            guard interval != 0
            else
            {
                continue
            }
            
            for candidate in date.shrink()
            {
                let candidateInterval: TimeInterval
                    = candidate.timeIntervalSinceReferenceDate
                
                XCTAssertLessThanOrEqual(
                    abs(candidateInterval),
                    abs(interval)
                )
            }
        }
    }
    
    
    
    func testShrinkingCandidatesPreserveSign()
    {
        for _ in 0..<1000
        {
            let date: Date = .arbitrary(using: .randomZeroSize)
            
            let interval: TimeInterval = date.timeIntervalSinceReferenceDate
            
            guard interval != 0
            else
            {
                continue
            }
            
            for candidate in date.shrink()
            {
                let candidateInterval: TimeInterval
                    = candidate.timeIntervalSinceReferenceDate
                
                if interval > 0
                {
                    XCTAssertGreaterThanOrEqual(candidateInterval, 0)
                }
                else
                {
                    XCTAssertLessThanOrEqual(candidateInterval, 0)
                }
            }
        }
    }
    
    
    
    func testShrinkingCandidatesDistinctFromOriginal()
    {
        for _ in 0..<1000
        {
            let date: Date = .arbitrary(using: .randomZeroSize)
            
            for candidate in date.shrink()
            {
                XCTAssertNotEqual(candidate, date)
            }
        }
    }
    
    
    
    func testShrinkingNearReferenceDateValue()
    {
        let intervals: [TimeInterval] =
        [
            0.1,
            0.01,
            0.001,
            0.0001,
            -0.0001,
            -0.001,
            -0.01,
            -0.1
        ]
        
        for interval in intervals
        {
            let date = Date(timeIntervalSinceReferenceDate: interval)
            
            let candidates: [Date] = date.shrink()
            
            XCTAssertFalse(candidates.isEmpty)
            XCTAssertEqual(candidates.first!.timeIntervalSinceReferenceDate, 0)
            
            for candidate in candidates
            {
                XCTAssertNotEqual(candidate, date)
                
                XCTAssertLessThanOrEqual(
                    abs(candidate.timeIntervalSinceReferenceDate),
                    abs(date.timeIntervalSinceReferenceDate)
                )
            }
        }
    }
    
    
    
    // MARK: - Mutation
    
    func testMutateSizeZeroOffsetBounded()
    {
        let oneDay: TimeInterval = 60 * 60 * 24
        
        for _ in 0..<1000
        {
            let date    : Date  = Date.arbitrary(using: .random)
            let mutated : Date  = date.mutate(using: .randomZeroSize)
            
            let offset: TimeInterval = abs(
                mutated.timeIntervalSinceReferenceDate
                - date.timeIntervalSinceReferenceDate
            )
            
            /// At size `0`, `maxDays` is `1`, so `offset` is at most `1`.
            XCTAssertLessThanOrEqual(offset, oneDay)
        }
    }
    
    
    
    func testMutationOffsetScalesWithSize()
    {
        let smallSize       : Int           = 1
        let largeSize       : Int           = 100
        let oneDay          : TimeInterval  = 60 * 60 * 24
        var maxSmallOffset  : TimeInterval  = 0
        var maxLargeOffset  : TimeInterval  = 0
        
        let date = Date(timeIntervalSinceReferenceDate: 0)
        
        for _ in 0..<1000
        {
            let smallMutated: Date
                = date.mutate(using: .randomSeed(size: smallSize))
            
            let largeMutated: Date
                = date.mutate(using: .randomSeed(size: largeSize))
            
            maxSmallOffset = max(
                maxSmallOffset,
                abs(smallMutated.timeIntervalSinceReferenceDate)
            )
            
            maxLargeOffset = max(
                maxLargeOffset,
                abs(largeMutated.timeIntervalSinceReferenceDate)
            )
        }
        
        /// Small size offsets must be bounded by `smallSize` days, and large
        /// size offsets must reach beyond `smallSize` days.
        XCTAssertLessThanOrEqual(maxSmallOffset, Double(smallSize) * oneDay)
        XCTAssertGreaterThan(maxLargeOffset, Double(smallSize) * oneDay)
    }
    
    
    
    func testMutationIsRelativeToOriginal()
    {
        let oneDay  : TimeInterval  = 60 * 60 * 24
        let size    : Int           = 5
        let bound   : TimeInterval  = Double(size) * oneDay
        
        for _ in 0..<1000
        {
            let date    : Date  = Date.arbitrary(using: .random)
            let mutated : Date  = date.mutate(using: .randomSeed(size: size))
            
            let offset: TimeInterval = abs(
                mutated.timeIntervalSinceReferenceDate
                - date.timeIntervalSinceReferenceDate
            )
            
            XCTAssertLessThanOrEqual(offset, bound)
        }
    }
    
    
    
    func testMutateProducesBothDirections()
    {
        let date        : Date  = Date(timeIntervalSinceReferenceDate: 0)
        var hasBefore   : Bool  = false
        var hasAfter    : Bool  = false
        
        for _ in 0..<1000
        {
            let mutated: Date = date.mutate(using: .random)
            
            if mutated < date
            {
                hasBefore = true
            }
            else if mutated > date
            {
                hasAfter = true
            }
            
            if
                hasBefore,
                hasAfter
            {
                break
            }
        }
        
        XCTAssertTrue(hasBefore)
        XCTAssertTrue(hasAfter)
    }
}
