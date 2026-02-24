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
@testable import struct TestKitCore.SeededRNG



internal final class SeededRNGTests: TestKitCase
{
    // MARK: - Determinism
    
    func testSameSeedProducesSameSequence()
    {
        var rng1    = SeededRNG(seed: 1)
        var rng2    = SeededRNG(seed: 1)
        
        for _ in 0..<1000
        {
            XCTAssertEqual(rng1.next(), rng2.next())
        }
    }
    
    
    
    func testDifferentSeedsProduceDifferentSequences()
    {
        var rng1    = SeededRNG(seed: 1)
        var rng2    = SeededRNG(seed: 2)
        
        /// Collect values and verify that at least one differs.
        let values1 : [UInt64]  = (0..<1000).map { _ in rng1.next() }
        let values2 : [UInt64]  = (0..<1000).map { _ in rng2.next() }
        
        XCTAssertNotEqual(values1, values2)
    }
    
    
    
    // MARK: - Storage
    
    func testSeedIsStored()
    {
        let rng = SeededRNG(seed: 12345)
        
        XCTAssertEqual(rng.seed, 12345)
    }
    
    
    
    func testSeedZero()
    {
        var rng = SeededRNG(seed: 0)
        
        XCTAssertEqual(rng.seed, 0)
        
        let first: UInt64 = rng.next()
        
        /// Output should be non-zero since SplitMix64 adds a constant
        /// before mixing.
        XCTAssertNotEqual(first, 0)
    }
    
    
    
    func testSeedMax()
    {
        var rng = SeededRNG(seed: .max)
        
        XCTAssertEqual(rng.seed, .max)
        
        let first   : UInt64    = rng.next()
        let second  : UInt64    = rng.next()
        
        XCTAssertNotEqual(first, second)
    }
    
    
    
    // MARK: - Sequence progression
    
    func testConsecutiveValuesAreDifferent()
    {
        var rng         : SeededRNG     = .random
        var previous    : UInt64        = rng.next()
        
        for _ in 0..<1000
        {
            let current: UInt64 = rng.next()
            
            XCTAssertNotEqual(current, previous)
            
            previous = current
        }
    }
    
    
    
    func testGenerationDoesNotAffectSeed()
    {
        let randomSeed  : UInt64        = GenerationContext.randomSeed
        var rng         : SeededRNG     = .init(seed: randomSeed)
        
        for _ in 0..<1000
        {
            _ = rng.next()
        }
        
        XCTAssertEqual(rng.seed, randomSeed)
    }
    
    
    
    // MARK: - Distribution
    
    func testOutputSpansBothHalves()
    {
        var rng         : SeededRNG     = .random
        let midpoint    : UInt64        = .max / 2
        var hasLower    : Bool          = false
        var hasUpper    : Bool          = false
        
        for _ in 0..<1000
        {
            let value: UInt64 = rng.next()
            
            if value <= midpoint
            {
                hasLower = true
            }
            else
            {
                hasUpper = true
            }
            
            if
                hasLower,
                hasUpper
            {
                break
            }
        }
        
        XCTAssertTrue(hasLower)
        XCTAssertTrue(hasUpper)
    }
}
