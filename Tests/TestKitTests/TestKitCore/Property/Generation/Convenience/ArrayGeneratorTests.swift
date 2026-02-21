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



internal final class ArrayGeneratorTests: TestKitCase
{
    // MARK: - Exact count generation
    
    func testExactCountDeterminism()
    {
        let generator: Generator<[Int]> = .array(count: 5)
        
        generator.assertDeterministic()
    }
    
    
    
    func testExactCountProducesCorrectCount()
    {
        let generator: Generator<[Int]> = .array(count: 7)
        
        validateCount(
            of:         generator,
            expected:   7...7
        )
    }
    
    
    
    func testExactCountZeroProducesEmpty()
    {
        let generator: Generator<[Int]> = .array(count: 0)
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            XCTAssertTrue(array.isEmpty)
        }
    }
    
    
    
    // MARK: - Exact count shrinking
    
    func testExactCountShrinkPreservesCount()
    {
        let generator   : Generator<[Int]>  = .array(count: 3)
        let array       : [Int]             = [10, -7, 99]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, array.count)
        }
    }
    
    
    
    func testExactCountShrinkElementsConvergeTowardZero()
    {
        let generator   : Generator<[Int]>  = .array(count: 2)
        let array       : [Int]             = [10, -7]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertNotEqual(candidate, array)
        }
        
        let onlyFirstShrunk: Bool = candidates.contains
        {
            return $0[0] != array[0]
                && $0[1] == array[1]
        }
        
        XCTAssertTrue(onlyFirstShrunk)
        
        let onlySecondShrunk: Bool = candidates.contains
        {
            return $0[0] == array[0]
                && $0[1] != array[1]
        }
        
        XCTAssertTrue(onlySecondShrunk)
    }
    
    
    
    func testExactCountShrinkAllZerosProducesEmpty()
    {
        let generator   : Generator<[Int]>  = .array(count: 3)
        let array       : [Int]             = [0, 0, 0]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    // MARK: - Closed range generation
    
    func testClosedRangeDeterminism()
    {
        let generator: Generator<[Int]> = .array(count: 2...8)
        
        generator.assertDeterministic()
    }
    
    
    
    func testClosedRangeCountRespectsBounds()
    {
        let generator: Generator<[Int]> = .array(count: 3...7)
        
        validateCount(
            of:         generator,
            expected:   3...7
        )
    }
    
    
    
    func testClosedRangeProducesVariousCounts()
    {
        let generator   : Generator<[Int]>  = .array(count: 0...10)
        var counts      : Set<Int>          = []
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            counts.insert(array.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    // MARK: - Closed range shrinking
    
    func testClosedRangeShrinkReducesCount()
    {
        let generator   : Generator<[Int]>  = .array(count: 2...8)
        let array       : [Int]             = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        let isShorter: Bool = candidates.contains { $0.count < array.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testClosedRangeShrinkRespectsLowerBound()
    {
        let generator   : Generator<[Int]>  = .array(count: 3...8)
        let array       : [Int]             = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkAtLowerBoundOnlyShrinkElements()
    {
        let generator   : Generator<[Int]>  = .array(count: 3...8)
        let array       : [Int]             = [10, 20, 30]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator   : Generator<[Int]>  = .array(count: 0...5)
        let array       : [Int]             = [10, 20, 30]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    // MARK: - Range generation
    
    func testRangeDeterminism()
    {
        let generator: Generator<[Int]> = .array(count: 2..<9)
        
        generator.assertDeterministic()
    }
    
    
    
    func testRangeCountRespectsBounds()
    {
        let generator: Generator<[Int]> = .array(count: 3..<8)
        
        validateCount(
            of:         generator,
            expected:   3...7
        )
    }
    
    
    
    func testRangeProducesVariousCounts()
    {
        let generator   : Generator<[Int]>  = .array(count: 0..<11)
        var counts      : Set<Int>          = []
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            counts.insert(array.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    // MARK: - Range shrinking
    
    func testRangeShrinkReducesCount()
    {
        let generator   : Generator<[Int]>  = .array(count: 2..<9)
        let array       : [Int]             = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        let isShorter: Bool = candidates.contains { $0.count < array.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testRangeShrinkRespectsLowerBound()
    {
        let generator   : Generator<[Int]>  = .array(count: 3..<9)
        let array       : [Int]             = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkAtLowerBoundOnlyShrinkElements()
    {
        let generator   : Generator<[Int]>  = .array(count: 3..<9)
        let array       : [Int]             = [10, 20, 30]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator   : Generator<[Int]>  = .array(count: 0..<6)
        let array       : [Int]             = [10, 20, 30]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    // MARK: - Non-empty array generation
    
    func testNonEmptyArrayDeterminism()
    {
        let generator: Generator<[Int]> = .nonEmptyArray()
        
        generator.assertDeterministic()
    }
    
    
    
    func testNonEmptyArrayNeverProducesEmpty()
    {
        let generator: Generator<[Int]> = .nonEmptyArray()
        
        validateCount(
            of:         generator,
            expected:   1...Int.max
        )
    }
    
    
    
    // MARK: - Non-empty array shrinking
    
    func testNonEmptyArrayShrinkNeverProducesEmpty()
    {
        let generator   : Generator<[Int]>  = .nonEmptyArray()
        let array       : [Int]             = [10, 20, 30]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertFalse(candidate.isEmpty)
        }
    }
    
    
    
    func testNonEmptyArrayShrinkSingleElementOnlyShrinkElement()
    {
        let generator   : Generator<[Int]>  = .nonEmptyArray()
        let array       : [Int]             = [10]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 1)
        }
    }
}



// MARK: - Support

extension ArrayGeneratorTests
{
    /// Validates that the given generator produces arrays with counts within
    /// the given range.
    /// - Parameters:
    ///   - generator: The generator to evaluate.
    ///   - expected: The expected range of counts.
    private func validateCount(
        of generator    : Generator<[Int]>,
        expected        : ClosedRange<Int>
    )
    {
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(array.count, expected.lowerBound)
            XCTAssertLessThanOrEqual(array.count, expected.upperBound)
        }
    }
}
