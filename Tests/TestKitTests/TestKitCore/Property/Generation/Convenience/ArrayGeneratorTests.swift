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
        
        generator.assertCount(in: 7...7)
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
    
    
    
    func testGeneratorExactCountDeterminism()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  5
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testGeneratorExactCountProducesCorrectCount()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  7
        )
        
        generator.assertCount(in: 7...7)
    }
    
    
    
    func testGeneratorExactCountZeroProducesEmpty()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  0
        )
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            XCTAssertTrue(array.isEmpty)
        }
    }
    
    
    
    func testGeneratorExactCountUsesGenerator()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50).map { $0 * 2 },
            count:  5
        )
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            for element in array
            {
                XCTAssertEqual(element % 2, 0)
            }
        }
    }
    
    
    
    func testUniqueExactCountDeterminism()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  5
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testUniqueExactCountProducesCorrectCount()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  7
        )
        
        generator.assertCount(in: 7...7)
    }
    
    
    
    func testUniqueExactCountZeroProducesEmpty()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  0
        )
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            XCTAssertTrue(array.isEmpty)
        }
    }
    
    
    
    func testUniqueExactCountUsesGenerator()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...500).map { $0 * 2 },
            count:  5
        )
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            for element in array
            {
                XCTAssertEqual(element % 2, 0)
            }
        }
    }
    
    
    
    func testUniqueExactCountElementsAreUnique()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  10
        )
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            XCTAssertEqual(Set(array).count, array.count)
        }
    }
    
    
    
    func testUniqueArbitraryExactCountDeterminism()
    {
        let generator: Generator<[Int]> = .uniqueArray(count: 5)
        
        generator.assertDeterministic(size: 100)
    }
    
    
    
    func testUniqueArbitraryExactCountElementsAreUnique()
    {
        let generator: Generator<[Int]> = .uniqueArray(count: 10)
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.randomSeed(size: 100))
            
            XCTAssertEqual(array.count, 10)
            XCTAssertEqual(Set(array).count, array.count)
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
    
    
    
    func testGeneratorExactCountShrinkUsesGenerator()
    {
        let sentinel: Int = 999
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<[Int]> = .array(
            using:  elementGenerator,
            count:  2
        )
        
        let candidates: [[Int]] = generator.shrink([10, 20, 30])
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    func testGeneratorExactCountShrinkPreservesCount()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  3
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testGeneratorExactCountShrinkAtTargetProducesEmpty()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  3
        )
        
        let candidates: [[Int]] = generator.shrink([0, 0, 0])
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testUniqueExactCountShrinkUsesGenerator()
    {
        let sentinel: Int = 999
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<[Int]> = .uniqueArray(
            using:  elementGenerator,
            count:  2
        )
        
        let candidates: [[Int]] = generator.shrink([10, 20])
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    func testUniqueExactCountShrinkPreservesCount()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testUniqueExactCountShrinkPreservesUniqueness()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(Set(candidate).count, candidate.count)
        }
    }
    
    
    
    func testUniqueExactCountShrinkAtTargetProducesEmpty()
    {
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] }
        )
        
        let generator: Generator<[Int]> = .uniqueArray(
            using:  elementGenerator,
            count:  3
        )
        
        let candidates: [[Int]] = generator.shrink([10, 20, 30])
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testUniqueExactCountShrinkSkipsDuplicates()
    {
        /// The generator always shrinks to a fixed set, including `0`, which
        /// is already present in the array. The duplicate must be filtered.
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { value in [0, value / 2] }
        )
        
        let generator: Generator<[Int]> = .uniqueArray(
            using:  elementGenerator,
            count:  3
        )
        
        let array       : [Int]     = [0, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(Set(candidate).count, candidate.count)
        }
    }
    
    
    
    // MARK: - Exact count mutation
    
    func testExactCountMutationPreservesCount()
    {
        let generator: Generator<[Int]> = .array(count: 5)
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertEqual(mutated.count, 5)
        }
    }
    
    
    
    func testExactCountMutationChangesElements()
    {
        let generator   : Generator<[Int]>  = .array(count: 5)
        var changed     : Bool              = false
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.randomSeed(size: 50))
            let mutated : [Int]     = generator.mutate(array, .random)
            
            if mutated != array
            {
                changed = true
                break
            }
        }
        
        XCTAssertTrue(changed)
    }
    
    
    
    func testExactCountMutationUsesGenerator()
    {
        var mutateCallCount: Int = 0
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100 ) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value + 1
            }
        )
        
        let generator: Generator<[Int]> = .array(
            using:  elementGenerator,
            count:  3
        )
        
        let array       : [Int]     = [10, 20, 30]
        let iterations  : Int       = 1000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(array, .random)
        }
        
        XCTAssertEqual(mutateCallCount, iterations)
    }
    
    
    
    func testUniqueExactCountMutationPreservesUniqueness()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...100),
            count:  5
        )
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertEqual(Set(mutated).count, mutated.count)
        }
    }
    
    
    
    func testUniqueExactCountMutationPreservesCount()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...100),
            count:  5
        )
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertEqual(mutated.count, 5)
        }
    }
    
    
    
    func testUniqueExactCountMutationFallbackOnExhaustion()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...2),
            count:  3
        )
        
        let array: [Int] = [0, 1, 2]
        
        for _ in 0..<1000
        {
            let mutated: [Int] = generator.mutate(array, .random)
            
            XCTAssertEqual(Set(mutated).count, mutated.count)
        }
    }
    
    
    
    func testUniqueExactCountZeroMutationReturnsEmpty()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  0
        )
        
        let mutated: [Int] = generator.mutate([], .random)
        
        XCTAssertTrue(mutated.isEmpty)
    }
    
    
    
    func testExactCountZeroMutationReturnsEmpty()
    {
        let generator   : Generator<[Int]>  = .array(count: 0)
        let mutated     : [Int]             = generator.mutate([], .random)
        
        XCTAssertTrue(mutated.isEmpty)
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
        
        generator.assertCount(in: 3...7)
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
    
    
    
    func testGeneratorClosedRangeDeterminism()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  2...8
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testGeneratorClosedRangeCountRespectsBounds()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  3...7
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testUniqueClosedRangeDeterminism()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  2...8
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testUniqueClosedRangeCountRespectsBounds()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3...7
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testUniqueClosedRangeElementsAreUnique()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3...10
        )
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            XCTAssertEqual(Set(array).count, array.count)
        }
    }
    
    
    
    func testUniqueArbitraryClosedRangeElementsAreUnique()
    {
        let generator: Generator<[Int]> = .uniqueArray(count: 3...10)
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.randomSeed(size: 100))
            
            XCTAssertGreaterThanOrEqual(array.count, 3)
            XCTAssertLessThanOrEqual(array.count, 10)
            XCTAssertEqual(Set(array).count, array.count)
        }
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
        
        XCTAssertFalse(candidates.isEmpty)
        
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
        
        XCTAssertFalse(candidates.isEmpty)
        
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
    
    
    
    func testGeneratorClosedRangeShrinkReducesCount()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  2...8
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        let isShorter: Bool = candidates.contains { $0.count < array.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testGeneratorClosedRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  3...8
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testGeneratorClosedRangeShrinkAtLowerBoundOnlyShrinkElements()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  3...8
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testGeneratorClosedRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  0...5
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    func testGeneratorClosedRangeShrinkUsesGenerator()
    {
        let sentinel: Int = 999
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<[Int]> = .array(
            using:  elementGenerator,
            count:  2...8
        )
        
        let candidates: [[Int]] = generator.shrink([10, 20, 30])
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    func testUniqueClosedRangeShrinkReducesCount()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  2...8
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        let isShorter: Bool = candidates.contains { $0.count < array.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testUniqueClosedRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3...8
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testUniqueClosedRangeShrinkPreservesUniqueness()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  2...8
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(Set(candidate).count, candidate.count)
        }
    }
    
    
    
    func testUniqueClosedRangeShrinkAtLowerBoundOnlyShrinksElements()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3...8
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testUniqueClosedRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  0...5
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    // MARK: - Closed range mutation
    
    func testClosedRangeMutationRespectsBounds()
    {
        let generator: Generator<[Int]> = .array(count: 3...7)
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testClosedRangeMutationAtLowerBoundCannotRemove()
    {
        let generator   : Generator<[Int]>  = .array(count: 3...7)
        let array       : [Int]             = [10, 20, 30]
        
        for _ in 0..<1000
        {
            let mutated: [Int] = generator.mutate(array, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testClosedRangeMutationAtLowerBoundCannotInsert()
    {
        let generator   : Generator<[Int]>  = .array(count: 3...5)
        let array       : [Int]             = [10, 20, 30, 40, 50]
        
        for _ in 0..<1000
        {
            let mutated: [Int] = generator.mutate(array, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 5)
        }
    }
    
    
    
    func testUniqueClosedRangeMutationPreservesUniqueness()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3...8
        )
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertEqual(Set(mutated).count, mutated.count)
        }
    }
    
    
    
    func testUniqueClosedRangeMutationRespectsBounds()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3...7
        )
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testClosedRangeMutationEmptyArrayInserts()
    {
        let generator: Generator<[Int]> = .array(count: 0...5)
        
        for _ in 0..<1000
        {
            let mutated: [Int] = generator.mutate([], .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
    
    
    
    func testUniqueClosedRangeMutationEmptyArrayInserts()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  0...5
        )
        
        for _ in 0..<1000
        {
            let mutated: [Int] = generator.mutate([], .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
    
    
    
    func testClosedRangeMutationUsesGenerator()
    {
        var mutateCallCount: Int = 0
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100 ) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value + 1
            }
        )
        
        let generator: Generator<[Int]> = .array(
            using:  elementGenerator,
            count:  3...7
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let iterations  : Int       = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(array, .random)
        }
        
        XCTAssertGreaterThan(
            mutateCallCount,
            Int(Double(iterations) * 0.7 * 0.95)
        )
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
        
        generator.assertCount(in: 3...7)
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
    
    
    
    func testGeneratorRangeDeterminism()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  2..<9
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testGeneratorRangeCountRespectsBounds()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  3..<8
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testUniqueRangeDeterminism()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  2..<9
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testUniqueRangeCountRespectsBounds()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3..<8
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testUniqueRangeElementsAreUnique()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3..<11
        )
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            XCTAssertEqual(Set(array).count, array.count)
        }
    }
    
    
    
    func testUniqueArbitraryRangeElementsAreUnique()
    {
        let generator: Generator<[Int]> = .uniqueArray(count: 3..<11)
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.randomSeed(size: 100))
            
            XCTAssertGreaterThanOrEqual(array.count, 3)
            XCTAssertLessThanOrEqual(array.count, 10)
            XCTAssertEqual(Set(array).count, array.count)
        }
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
        
        XCTAssertFalse(candidates.isEmpty)
        
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
        
        XCTAssertFalse(candidates.isEmpty)
        
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
    
    
    
    func testGeneratorRangeShrinkReducesCount()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  2..<9
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        let isShorter: Bool = candidates.contains { $0.count < array.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testGeneratorRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  3..<9
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testGeneratorRangeShrinkAtLowerBoundOnlyShrinkElements()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  3..<9
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testGeneratorRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<[Int]> = .array(
            using:  .integer(in: 0...50),
            count:  0..<6
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    func testUniqueRangeShrinkReducesCount()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  2..<9
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        let isShorter: Bool = candidates.contains { $0.count < array.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testUniqueRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3..<9
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testUniqueRangeShrinkPreservesUniqueness()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  2..<9
        )
        
        let array       : [Int]     = [10, 20, 30, 40, 50]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(Set(candidate).count, candidate.count)
        }
    }
    
    
    
    func testUniqueRangeShrinkAtLowerBoundOnlyShrinksElements()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3..<9
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testUniqueRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  0..<6
        )
        
        let array       : [Int]     = [10, 20, 30]
        let candidates  : [[Int]]   = generator.shrink(array)
        
        XCTAssertTrue(candidates.contains([]))
    }
    
    
    
    // MARK: - Range mutation
    
    func testRangeMutationRespectsBounds()
    {
        let generator: Generator<[Int]> = .array(count: 3..<8)
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testUniqueRangeMutationPreservesUniqueness()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3..<9
        )
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertEqual(Set(mutated).count, mutated.count)
        }
    }
    
    
    
    func testUniqueRangeMutationRespectsBounds()
    {
        let generator: Generator<[Int]> = .uniqueArray(
            using:  .integer(in: 0...1000),
            count:  3..<8
        )
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    // MARK: - Non-empty generation
    
    func testNonEmptyArrayDeterminism()
    {
        let generator: Generator<[Int]> = .nonEmptyArray()
        
        generator.assertDeterministic()
    }
    
    
    
    func testNonEmptyArrayNeverProducesEmpty()
    {
        let generator: Generator<[Int]> = .nonEmptyArray()
        
        generator.assertCount(in: 1...Int.max)
    }
    
    
    
    func testGeneratorNonEmptyArrayDeterminism()
    {
        let generator: Generator<[Int]>
            = .nonEmptyArray(using: .integer(in: 0...50))
        
        generator.assertDeterministic()
    }
    
    
    
    func testGeneratorNonEmptyArrayUsesGenerator()
    {
        let generator: Generator<[Int]>
            = .nonEmptyArray(using: .integer(in: 0...50).map { $0 * 2 })
        
        for _ in 0..<1000
        {
            let array: [Int] = generator.generate(.random)
            
            for element in array
            {
                XCTAssertEqual(element % 2, 0)
            }
        }
    }
    
    
    
    // MARK: - Non-empty shrinking
    
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
    
    
    
    func testGeneratorNonEmptyArrayShrinkUsesGenerator()
    {
        let sentinel: Int = 999
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<[Int]>
            = .nonEmptyArray(using: elementGenerator)
        
        let candidates: [[Int]] = generator.shrink([10, 20, 30])
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    // MARK: - Non-empty mutation
    
    func testNonEmptyArrayMutationNeverProducesEmpty()
    {
        let generator: Generator<[Int]> = .nonEmptyArray()
        
        for _ in 0..<1000
        {
            let array   : [Int]     = generator.generate(.random)
            let mutated : [Int]     = generator.mutate(array, .random)
            
            XCTAssertFalse(mutated.isEmpty)
        }
    }
    
    
    
    func testNonEmptyArrayMutationSingleElementCannotRemove()
    {
        let generator: Generator<[Int]> = .nonEmptyArray()
        
        for _ in 0..<1000
        {
            let mutated: [Int] = generator.mutate([50], .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 1)
        }
    }
    
    
    
    func testGeneratorNonEmptyArrayMutationUsesGenerator()
    {
        var mutateCallCount: Int = 0
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value + 1
            }
        )
        
        let generator: Generator<[Int]>
            = .nonEmptyArray(using: elementGenerator)
        
        let array       : [Int]     = [10, 20, 30]
        let iterations  : Int       = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(array, .random)
        }
        
        XCTAssertGreaterThan(
            mutateCallCount,
            Int(Double(iterations) * 0.7 * 0.95)
        )
    }
}
