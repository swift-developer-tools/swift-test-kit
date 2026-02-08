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



internal final class ArrayGeneratorTests: XCTestCase
{
    // MARK: - Exact count generation
    
    func testExactCountDeterminism() throws
    {
        let generator: Generator<[Int]> = .array(count: 5)
        
        generator.validateDeterminism()
    }
    
    
    
    func testExactCountProducesCorrectCount() throws
    {
        let generator: Generator<[Int]> = .array(count: 7)
        
        validateCount(
            of:         generator,
            expected:   7...7
        )
    }
    
    
    
    func testExactCountZeroProducesEmpty() throws
    {
        let generator: Generator<[Int]> = .array(count: 0)
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            XCTAssertTrue(array.isEmpty)
        }
    }
    
    
    
    // MARK: - Exact count shrinking
    
    func testExactCountShrinkPreservesCount() throws
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
    
    
    
    func testExactCountShrinkElementsConvergeTowardZero() throws
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
    
    
    
    func testExactCountShrinkAllZerosProducesEmpty() throws
    {
        let generator   : Generator<[Int]>  = .array(count: 3)
        let array       : [Int]             = [0, 0, 0]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    // MARK: - Closed range generation
    
    func testClosedRangeDeterminism() throws
    {
        let generator: Generator<[Int]> = .array(count: 2...8)
        
        generator.validateDeterminism()
    }
    
    
    
    func testClosedRangeCountRespectsBounds() throws
    {
        let generator: Generator<[Int]> = .array(count: 3...7)
        
        validateCount(
            of:         generator,
            expected:   3...7
        )
    }
    
    
    
    func testClosedRangeProducesVariousCounts() throws
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
    
    func testClosedRangeShrinkReducesCount() throws
    {
        let generator   : Generator<[Int]>  = .array(count: 2...8)
        let array       : [Int]             = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        let isShorter: Bool = candidates.contains { $0.count < array.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testClosedRangeShrinkRespectsLowerBound() throws
    {
        let generator   : Generator<[Int]>  = .array(count: 3...8)
        let array       : [Int]             = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkAtLowerBoundOnlyShrinkElements() throws
    {
        let generator   : Generator<[Int]>  = .array(count: 3...8)
        let array       : [Int]             = [10, 20, 30]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkZeroLowerBoundIncludesEmpty() throws
    {
        let generator   : Generator<[Int]>  = .array(count: 0...5)
        let array       : [Int]             = [10, 20, 30]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    // MARK: - Range generation
    
    func testRangeDeterminism() throws
    {
        let generator: Generator<[Int]> = .array(count: 2..<9)
        
        generator.validateDeterminism()
    }
    
    
    
    func testRangeCountRespectsBounds() throws
    {
        let generator: Generator<[Int]> = .array(count: 3..<8)
        
        validateCount(
            of:         generator,
            expected:   3...7
        )
    }
    
    
    
    func testRangeProducesVariousCounts() throws
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
    
    func testRangeShrinkReducesCount() throws
    {
        let generator   : Generator<[Int]>  = .array(count: 2..<9)
        let array       : [Int]             = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        let isShorter: Bool = candidates.contains { $0.count < array.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testRangeShrinkRespectsLowerBound() throws
    {
        let generator   : Generator<[Int]>  = .array(count: 3..<9)
        let array       : [Int]             = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkAtLowerBoundOnlyShrinkElements() throws
    {
        let generator   : Generator<[Int]>  = .array(count: 3..<9)
        let array       : [Int]             = [10, 20, 30]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkZeroLowerBoundIncludesEmpty() throws
    {
        let generator   : Generator<[Int]>  = .array(count: 0..<6)
        let array       : [Int]             = [10, 20, 30]
        let candidates  : [[Int]]           = generator.shrink(array)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    // MARK: - Non-empty array generation
    
    func testNonEmptyArrayDeterminism() throws
    {
        let generator: Generator<[Int]> = .nonEmptyArray()
        
        generator.validateDeterminism()
    }
    
    
    
    func testNonEmptyArrayNeverProducesEmpty() throws
    {
        let generator: Generator<[Int]> = .nonEmptyArray()
        
        validateCount(
            of:         generator,
            expected:   1...Int.max
        )
    }
    
    
    
    // MARK: - Non-empty array shrinking
    
    func testNonEmptyArrayShrinkNeverProducesEmpty() throws
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
    
    
    
    func testNonEmptyArrayShrinkSingleElementOnlyShrinkElement() throws
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



// MARK: - Extensions

private extension ArrayGeneratorTests
{
    /// Validates that the given generator produces arrays with counts within
    /// the given range.
    /// - Parameters:
    ///   - generator: The generator to evaluate.
    ///   - expected: The expected range of counts.
    func validateCount(
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
