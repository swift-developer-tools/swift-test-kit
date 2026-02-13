//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import TestKitCore



internal final class DateArbitraryTests: XCTestCaseStopOnFail
{
    // MARK: - Generation
    
    func testGenerationDeterminism()
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                Date.arbitrary(using: context1),
                Date.arbitrary(using: context2)
            )
        }
    }
    
    
    
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
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let date: Date = .arbitrary(using: context)
            
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
}
