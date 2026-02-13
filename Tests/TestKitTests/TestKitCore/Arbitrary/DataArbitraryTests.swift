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



internal final class DataArbitraryTests: XCTestCaseStopOnFail
{
    // MARK: - Generation
    
    func testGenerationDeterminism() throws
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                Data.arbitrary(using: context1),
                Data.arbitrary(using: context2)
            )
        }
    }
    
    
    
    func testGenerationSizeZeroProducesEmpty() throws
    {
        for _ in 0..<1000
        {
            XCTAssertEqual(Data.arbitrary(using: .randomZeroSize), Data())
        }
    }
    
    
    
    func testGenerationCountRespectsSizeBounds() throws
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let data = Data.arbitrary(using: context)
            
            XCTAssertLessThanOrEqual(data.count, size)
        }
    }
    
    
    
    func testGenerationProducesEmptyAndNonEmpty() throws
    {
        var hasEmpty    : Bool  = false
        var hasNonEmpty : Bool  = false
        
        for _ in 0..<1000
        {
            let data = Data.arbitrary(using: .random)
            
            if data.isEmpty
            {
                hasEmpty = true
            }
            else
            {
                hasNonEmpty = true
            }
            
            if
                hasEmpty,
                hasNonEmpty
            {
                break
            }
        }
        
        XCTAssertTrue(hasEmpty)
        XCTAssertTrue(hasNonEmpty)
    }
    
    
    
    func testGenerationProducesVariousCounts() throws
    {
        let size    : Int       = 20
        var counts  : Set<Int>  = []
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let data = Data.arbitrary(using: context)
            
            counts.insert(data.count)
        }
        
        XCTAssertGreaterThan(counts.count, size / 2)
    }
    
    
    
    func testGenerationProducesVariety() throws
    {
        var uniqueBytes: Set<UInt8> = []
        
        for _ in 0..<10_000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   Int(UInt8.max)
            )
            
            let data = Data.arbitrary(using: context)
            
            for byte in data
            {
                uniqueBytes.insert(byte)
            }
        }
        
        let expected = Int(Double(Int(UInt8.max) + 1) * 0.95)
        
        XCTAssertGreaterThan(uniqueBytes.count, expected)
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkingEmptyData() throws
    {
        XCTAssertEqual(Data().shrink(), [])
    }
    
    
    
    func testShrinkingSingleByte() throws
    {
        let candidates: [Data] = Data([50]).shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, Data())
    }
    
    
    
    func testShrinkingFirstCandidateEmpty() throws
    {
        for _ in 0..<1000
        {
            let data = Data.arbitrary(using: .random)
            
            guard !data.isEmpty
            else
            {
                continue
            }
            
            let candidates: [Data] = data.shrink()
            
            XCTAssertFalse(candidates.isEmpty)
            XCTAssertEqual(candidates.first, Data())
        }
    }
    
    
    
    func testShrinkingCandidatesSmaller() throws
    {
        for _ in 0..<1000
        {
            let data = Data.arbitrary(using: .random)
            
            guard !data.isEmpty
            else
            {
                continue
            }
            
            let candidates: [Data] = data.shrink()
            
            for candidate in candidates
            {
                XCTAssertLessThanOrEqual(candidate.count, data.count)
            }
        }
    }
    
    
    
    func testShrinkingCandidatesDistinctFromOriginal() throws
    {
        for _ in 0..<1000
        {
            let data = Data.arbitrary(using: .random)
            
            for candidate in data.shrink()
            {
                XCTAssertNotEqual(candidate, data)
            }
        }
    }
    
    
    
    func testShrinkingIncludesElementShrinking() throws
    {
        let data        : Data      = .init([255, 128])
        let candidates  : [Data]    = data.shrink()
        
        let sameCountCandidates: [Data]
            = candidates.filter { $0.count == data.count }
        
        /// Element-level shrinking must produces at least one candidate
        /// with the same count, but smaller byte values.
        XCTAssertFalse(sameCountCandidates.isEmpty)
        
        for candidate in sameCountCandidates
        {
            XCTAssertNotEqual(candidate, data)
        }
    }
    
    
    
    func testShrinkingIncludesStructuralCandidates() throws
    {
        let data        : Data      = .init([1, 2, 3, 4])
        let candidates  : [Data]    = data.shrink()
        
        /// Halves.
        XCTAssertTrue(candidates.contains(Data([1, 2])))
        XCTAssertTrue(candidates.contains(Data([3, 4])))
        
        /// Individual removals.
        XCTAssertTrue(candidates.contains(Data([2, 3, 4])))
        XCTAssertTrue(candidates.contains(Data([1, 3, 4])))
        XCTAssertTrue(candidates.contains(Data([1, 2, 4])))
        XCTAssertTrue(candidates.contains(Data([1, 2, 3])))
    }
}
