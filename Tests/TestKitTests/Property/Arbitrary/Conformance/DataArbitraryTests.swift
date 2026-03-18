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



internal final class DataArbitraryTests: TestKitCase
{
    // MARK: - Determinism
    
    func testArbitraryDeterminism()
    {
        assertArbitraryDeterminism(of: Data.self)
    }
    
    
    
    // MARK: - Generation
    
    func testGenerationSizeZeroProducesEmpty()
    {
        for _ in 0..<1000
        {
            XCTAssertEqual(Data.arbitrary(using: .randomZeroSize), Data())
        }
    }
    
    
    
    func testGenerationCountRespectsSizeBounds()
    {
        let size: Int = 10
        
        for _ in 0..<1000
        {
            let data = Data.arbitrary(using: .randomSeed(size: size))
            
            XCTAssertLessThanOrEqual(data.count, size)
        }
    }
    
    
    
    func testGenerationProducesEmptyAndNonEmpty()
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
    
    
    
    func testGenerationProducesVariousCounts()
    {
        let size    : Int       = 20
        var counts  : Set<Int>  = []
        
        for _ in 0..<1000
        {
            let data = Data.arbitrary(using: .randomSeed(size: size))
            
            counts.insert(data.count)
        }
        
        XCTAssertGreaterThan(counts.count, size / 2)
    }
    
    
    
    func testGenerationProducesVariety()
    {
        var uniqueBytes: Set<UInt8> = []
        
        for _ in 0..<10_000
        {
            let data = Data.arbitrary(using: .randomSeed(size: Int(UInt8.max)))
            
            for byte in data
            {
                uniqueBytes.insert(byte)
            }
        }
        
        let expected = Int(Double(Int(UInt8.max) + 1) * 0.85)
        
        XCTAssertGreaterThan(uniqueBytes.count, expected)
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkingEmptyData()
    {
        XCTAssertEqual(Data().shrink(), [])
    }
    
    
    
    func testShrinkingSingleByte()
    {
        let candidates: [Data] = Data([50]).shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, Data())
    }
    
    
    
    func testShrinkingFirstCandidateEmpty()
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
    
    
    
    func testShrinkingCandidatesSmaller()
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
    
    
    
    func testShrinkingCandidatesDistinctFromOriginal()
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
    
    
    
    func testShrinkingIncludesElementShrinking()
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
    
    
    
    func testShrinkingIncludesStructuralCandidates()
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
    
    
    
    // MARK: - Mutation
    
    func testMutateEmptyProducesNonEmpty()
    {
        for _ in 0..<1000
        {
            let mutated = Data().mutate(using: .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
    
    
    
    func testMutationCountChangesByAtMostOne()
    {
        for _ in 0..<1000
        {
            let value = Data.arbitrary(using: .randomSeed(size: 20))
            
            guard !value.isEmpty
            else
            {
                continue
            }
            
            let mutated     = value.mutate(using: .random)
            let delta       = mutated.count - value.count
            
            XCTAssertTrue((-1...1).contains(delta))
        }
    }
    
    
    
    func testMutateProducesAllOperationTypes()
    {
        var hasSameCount    : Bool  = false
        var hasMoreCount    : Bool  = false
        var hasFewerCount   : Bool  = false
        
        for _ in 0..<10_000
        {
            let value = Data.arbitrary(using: .randomSeed(size: 20))
            
            guard !value.isEmpty
            else
            {
                continue
            }
            
            let mutated : Data  = value.mutate(using: .random)
            let delta   : Int   = mutated.count - value.count
            
            switch delta
            {
                case 0  : hasSameCount      = true
                case 1  : hasMoreCount      = true
                case -1 : hasFewerCount     = true
                default : break
            }
            
            if
                hasSameCount,
                hasMoreCount,
                hasFewerCount
            {
                break
            }
        }
        
        XCTAssertTrue(hasSameCount)
        XCTAssertTrue(hasMoreCount)
        XCTAssertTrue(hasFewerCount)
    }
    
    
    
    func testMutateInPlaceChangesByteContent()
    {
        var verified: Int = 0
        
        for _ in 0..<10_000
        {
            let value   : Data  = Data([10, 20, 30, 40, 50])
            let mutated : Data  = value.mutate(using: .random)
            
            guard mutated.count == value.count
            else
            {
                continue
            }
            
            let differences = zip(value, mutated)
                .filter { $0 != $1 }
                .count
            
            XCTAssertLessThanOrEqual(differences, 1)
            
            verified += 1
        }
        
        XCTAssertGreaterThan(verified, 0)
    }
}
