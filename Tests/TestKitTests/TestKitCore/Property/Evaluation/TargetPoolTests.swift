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



internal final class TargetPoolTests: TestKitCase
{
    func testNewPoolEmpty()
    {
        let pool = TargetPool<Int>(capacity: 5)
        
        XCTAssertTrue(pool.isEmpty)
    }
    
    
    
    func testSingleInsert()
    {
        var pool = TargetPool<Int>(capacity: 5)
        
        pool.insert(value: 10, target: 1.0)
        
        XCTAssertFalse(pool.isEmpty)
    }
    
    
    
    func testInsertAcceptsAllEntriesWhenBelowCapacity()
    {
        var pool = TargetPool<Int>(capacity: 5)
        
        pool.insert(value: 10, target: 1.0)
        pool.insert(value: 20, target: 2.0)
        pool.insert(value: 30, target: 3.0)
        pool.insert(value: 40, target: 4.0)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [10, 20, 30, 40])
    }
    
    
    
    func testInsertEvictsLowestWhenAtCapacity()
    {
        var pool = TargetPool<Int>(capacity: 3)
        
        pool.insert(value: 10, target: 1.0)
        pool.insert(value: 20, target: 2.0)
        pool.insert(value: 30, target: 3.0)
        pool.insert(value: 40, target: 4.0)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [20, 30, 40])
    }
    
    
    
    func testInsertRejectsEntryWhenTargetEqualsMinimum()
    {
        var pool = TargetPool<Int>(capacity: 3)
        
        pool.insert(value: 10, target: 1.0)
        pool.insert(value: 20, target: 2.0)
        pool.insert(value: 30, target: 3.0)
        pool.insert(value: 40, target: 1.0)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [10, 20, 30])
    }
    
    
    
    func testInsertRejectsEntryWhenTargetBelowMinimum()
    {
        var pool = TargetPool<Int>(capacity: 3)
        
        pool.insert(value: 10, target: 1.0)
        pool.insert(value: 20, target: 2.0)
        pool.insert(value: 30, target: 3.0)
        pool.insert(value: 40, target: 0.5)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [10, 20, 30])
    }
    
    
    
    func testInsertRetainsOnlyHighestWhenCapacityIsOne()
    {
        var pool = TargetPool<Int>(capacity: 1)
        
        pool.insert(value: 30, target: 3.0)
        pool.insert(value: 10, target: 1.0)
        pool.insert(value: 50, target: 5.0)
        pool.insert(value: 20, target: 2.0)
        
        for _ in 0..<1000
        {
            XCTAssertEqual(pool.select(using: .random), 50)
        }
    }
    
    
    
    func testInsertOrdersNegativeTargetValues()
    {
        var pool = TargetPool<Int>(capacity: 3)
        
        pool.insert(value: 10, target: -10.0)
        pool.insert(value: 20, target: -5.0)
        pool.insert(value: 30, target: -1.0)
        pool.insert(value: 40, target: -3.0)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [20, 30, 40])
    }
    
    
    
    func testInsertOrderDoesNotAffectPoolContents()
    {
        var pool = TargetPool<Int>(capacity: 4)
        
        pool.insert(value: 30, target: 3.0)
        pool.insert(value: 10, target: 1.0)
        pool.insert(value: 40, target: 4.0)
        pool.insert(value: 20, target: 2.0)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [10, 20, 30, 40])
    }
    
    
    
    func testMultipleSequentialEvictions()
    {
        var pool = TargetPool<Int>(capacity: 3)
        
        pool.insert(value: 10, target: 1.0)
        pool.insert(value: 20, target: 2.0)
        pool.insert(value: 30, target: 3.0)
        pool.insert(value: 40, target: 4.0)
        pool.insert(value: 50, target: 5.0)
        pool.insert(value: 60, target: 6.0)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [40, 50, 60])
    }
    
    
    
    func testDuplicateTargetsBelowCapacity()
    {
        var pool = TargetPool<Int>(capacity: 5)
        
        pool.insert(value: 10, target: 5.0)
        pool.insert(value: 20, target: 5.0)
        pool.insert(value: 30, target: 5.0)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [10, 20, 30])
    }
    
    
    
    func testDuplicateTargetsAtCapacityRejectsNewEntry()
    {
        var pool = TargetPool<Int>(capacity: 3)
        
        pool.insert(value: 10, target: 5.0)
        pool.insert(value: 20, target: 5.0)
        pool.insert(value: 30, target: 5.0)
        pool.insert(value: 40, target: 5.0)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [10, 20, 30])
    }
    
    
    
    func testMixedPositiveNegativeAndZeroTargets()
    {
        var pool = TargetPool<Int>(capacity: 5)
        
        pool.insert(value: 1, target: -10.0)
        pool.insert(value: 2, target: -1.0)
        pool.insert(value: 3, target: 0.0)
        pool.insert(value: 4, target: 1.0)
        pool.insert(value: 5, target: 10.0)
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(pool.select(using: .random))
        }
        
        XCTAssertEqual(seen, [1, 2, 3, 4, 5])
    }
    
    
    
    func testSelectBiasesTowardHigherScores()
    {
        var pool = TargetPool<Int>(capacity: 5)
        
        pool.insert(value: 10, target: 1.0)
        pool.insert(value: 20, target: 100.0)
        pool.insert(value: 30, target: 200.0)
        
        var counts      : [Int : Int]   = [10: 0, 20: 0, 30: 0]
        let iterations  : Int           = 10_000
        
        for _ in 0..<iterations
        {
            let value: Int = pool.select(using: .random)
            
            counts[value, default: 0] += 1
        }
        
        /// `30`, `20`, and `10`, have weights of `3`, `2`, and `1`,
        /// respectively, since entries are weighted by rank, not magnitude.
        XCTAssertGreaterThan(
            counts[10]!,
            Int(Double(iterations) * (1 / 6) * 0.95)
        )
        
        XCTAssertGreaterThan(
            counts[20]!,
            Int(Double(iterations) * (2 / 6) * 0.95)
        )
        
        XCTAssertGreaterThan(
            counts[30]!,
            Int(Double(iterations) * (3 / 6) * 0.95)
        )
    }
}
