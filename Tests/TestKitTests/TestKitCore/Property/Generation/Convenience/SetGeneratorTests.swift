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



internal final class SetGeneratorTests: TestKitCase
{
    // MARK: - Exact count generation
    
    func testExactCountDeterminism()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  5
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testExactCountProducesCorrectCount()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  7
        )
        
        generator.assertCount(in: 7...7)
    }
    
    
    
    func testExactCountZeroProducesEmpty()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  0
        )
        
        for _ in 0..<1000
        {
            let set: Set<Int> = generator.generate(.random)
            
            XCTAssertTrue(set.isEmpty)
        }
    }
    
    
    
    func testExactCountUsesGenerator()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000).map { $0 * 2 },
            count:  5
        )
        
        for _ in 0..<1000
        {
            let set: Set<Int> = generator.generate(.random)
            
            for element in set
            {
                XCTAssertEqual(element % 2, 0)
            }
        }
    }
    
    
    
    func testArbitraryExactCountDeterminism()
    {
        let generator: Generator<Set<Int>> = .set(count: 5)
        
        generator.assertDeterministic(size: 100)
    }
    
    
    
    func testArbitraryExactCountProducesCorrectCount()
    {
        let generator: Generator<Set<Int>> = .set(count: 7)
        
        generator.assertCount(
            in:     7...7,
            size:   100
        )
    }
    
    
    
    // MARK: - Exact count shrinking
    
    func testExactCountShrinkPreservesCount()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  5
        )
        
        let set         : Set<Int>      = generator.generate(.random)
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, set.count)
        }
    }
    
    
    
    func testExactCountShrinkElementsConvergeTowardZero()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  2
        )
        
        let set         : Set<Int>      = [10, 70]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertNotEqual(candidate, set)
        }
        
        /// At least one candidate must differ in exactly one element.
        let differsByOne: Bool = candidates.contains
        {
            return $0.intersection(set).count == 1
        }
        
        XCTAssertTrue(differsByOne)
    }
    
    
    
    func testExactCountShrinkAtTargetProducesEmpty()
    {
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] }
        )
        
        let generator: Generator<Set<Int>> = .set(
            using:  elementGenerator,
            count:  3
        )
        
        let set         : Set<Int>      = [10, 20, 30]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testExactCountShrinkUsesGenerator()
    {
        let sentinel: Int = 999
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<Set<Int>> = .set(
            using:  elementGenerator,
            count:  2
        )
        
        let set         : Set<Int>      = [10, 20]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    func testExactCountShrinkSkipsDuplicates()
    {
        /// The generator always shrinks to a fixed set, including `0`, which
        /// is already present in the set. The duplicate must be filtered.
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { value in [0, value / 2] }
        )
        
        let generator: Generator<Set<Int>> = .set(
            using:  elementGenerator,
            count:  3
        )
        
        let set         : Set<Int>      = [0, 20, 30]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    // MARK: - Exact count mutation
    
    func testExactCountMutationPreservesCount()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...100),
            count:  5
        )
        
        for _ in 0..<1000
        {
            let set     : Set<Int>  = generator.generate(.random)
            let mutated : Set<Int>  = generator.mutate(set, .random)
            
            XCTAssertEqual(mutated.count, 5)
        }
    }
    
    
    
    func testExactCountMutationChangesElements()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...100),
            count:  5
        )
        
        var changed: Bool = false
        
        for _ in 0..<1000
        {
            let set     : Set<Int>  = generator.generate(.randomSeed(size: 50))
            let mutated : Set<Int>  = generator.mutate(set, .random)
            
            if mutated != set
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
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value + context.random(in: 1...100)
            }
        )
        
        let generator: Generator<Set<Int>> = .set(
            using:  elementGenerator,
            count:  3
        )
        
        let set         : Set<Int>  = [100, 200, 300]
        let iterations  : Int       = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(set, .random)
        }
        
        XCTAssertGreaterThan(
            mutateCallCount,
            Int(Double(iterations) * 0.7 * 0.95)
        )
    }
    
    
    
    func testExactCountMutationFallbackOnExhaustion()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...2),
            count:  3
        )
        
        let set: Set<Int> = [0, 1, 2]
        
        for _ in 0..<1000
        {
            let mutated: Set<Int> = generator.mutate(set, .random)
            
            XCTAssertEqual(mutated.count, 3)
        }
    }
    
    
    
    func testExactCountMutationReturnsEmpty()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  0
        )
        
        let mutated: Set<Int> = generator.mutate([], .random)
        
        XCTAssertTrue(mutated.isEmpty)
    }
    
    
    
    // MARK: - Closed range generation
    
    func testClosedRangeDeterminism()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  2...8
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testClosedRangeCountRespectsBounds()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  3...7
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testClosedRangeProducesVariousCounts()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  0...10
        )
        
        var counts: Set<Int> = []
        
        for _ in 0..<1000
        {
            let set: Set<Int> = generator.generate(.random)
            
            counts.insert(set.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    func testArbitraryClosedRangeCountRespectsBounds()
    {
        let generator: Generator<Set<Int>> = .set(count: 3...10)
        
        for _ in 0..<1000
        {
            let set: Set<Int> = generator.generate(.randomSeed(size: 100))
            
            XCTAssertGreaterThanOrEqual(set.count, 3)
            XCTAssertLessThanOrEqual(set.count, 10)
        }
    }
    
    
    
    // MARK: - Closed range shrinking
    
    func testClosedRangeShrinkReducesCount()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  2...8
        )
        
        let set         : Set<Int>      = [10, 20, 30, 40, 50]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        let isShorter: Bool = candidates.contains { $0.count < set.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testClosedRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  3...8
        )
        
        let set         : Set<Int>      = [10, 20, 30, 40, 50]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkAtLowerBoundOnlyShrinksElements()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  3...8
        )
        
        let set         : Set<Int>      = [10, 20, 30]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  0...5
        )
        
        let set         : Set<Int>      = [10, 20, 30]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        let containsEmpty: Bool = candidates.contains { $0.isEmpty }
        
        XCTAssertTrue(containsEmpty)
    }
    
    
    
    func testClosedRangeShrinkUsesGenerator()
    {
        let sentinel: Int = 999
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<Set<Int>> = .set(
            using:  elementGenerator,
            count:  2...8
        )
        
        let set         : Set<Int>      = [10, 20, 30]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    // MARK: - Closed range mutation
    
    func testClosedRangeMutationRespectsBounds()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...100),
            count:  3...7
        )
        
        for _ in 0..<1000
        {
            let set     : Set<Int>  = generator.generate(.random)
            let mutated : Set<Int>  = generator.mutate(set, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testClosedRangeMutationAtLowerBoundCannotRemove()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...100),
            count:  3...7
        )
        
        let set: Set<Int> = [10, 20, 30]
        
        for _ in 0..<1000
        {
            let mutated: Set<Int> = generator.mutate(set, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testClosedRangeMutationAtUpperBoundCannotInsert()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...100),
            count:  3...5
        )
        
        let set: Set<Int> = [10, 20, 30, 40, 50]
        
        for _ in 0..<1000
        {
            let mutated: Set<Int> = generator.mutate(set, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 5)
        }
    }
    
    
    
    func testClosedRangeMutationEmptySetInserts()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...100),
            count:  0...5
        )
        
        for _ in 0..<1000
        {
            let mutated: Set<Int> = generator.mutate([], .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
    
    
    
    func testClosedRangeMutationUsesGenerator()
    {
        var mutateCallCount: Int = 0
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value + context.random(in: 1...100)
            }
        )
        
        let generator: Generator<Set<Int>> = .set(
            using:  elementGenerator,
            count:  3...7
        )
        
        let set         : Set<Int>  = [100, 200, 300, 400, 500]
        let iterations  : Int       = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(set, .random)
        }
        
        XCTAssertGreaterThan(
            mutateCallCount,
            Int(Double(iterations) * 0.7 * 0.95)
        )
    }
    
    
    
    // MARK: - Range generation
    
    func testRangeDeterminism()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  2..<9
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testRangeCountRespectsBounds()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  3..<8
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testRangeProducesVariousCounts()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  0..<11
        )
        
        var counts: Set<Int> = []
        
        for _ in 0..<1000
        {
            let set: Set<Int> = generator.generate(.random)
            
            counts.insert(set.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    func testArbitraryRangeCountRespectsBounds()
    {
        let generator: Generator<Set<Int>> = .set(count: 3..<11)
        
        for _ in 0..<1000
        {
            let set: Set<Int> = generator.generate(.randomSeed(size: 100))
            
            XCTAssertGreaterThanOrEqual(set.count, 3)
            XCTAssertLessThanOrEqual(set.count, 10)
        }
    }
    
    
    
    // MARK: - Range shrinking
    
    func testRangeShrinkReducesCount()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  2..<9
        )
        
        let set         : Set<Int>      = [10, 20, 30, 40, 50]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        let isShorter: Bool = candidates.contains { $0.count < set.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  3..<9
        )
        
        let set         : Set<Int>      = [10, 20, 30, 40, 50]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkAtLowerBoundOnlyShrinksElements()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  3..<9
        )
        
        let set         : Set<Int>      = [10, 20, 30]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...1000),
            count:  0..<6
        )
        
        let set         : Set<Int>      = [10, 20, 30]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        let containsEmpty: Bool = candidates.contains { $0.isEmpty }
        
        XCTAssertTrue(containsEmpty)
    }
    
    
    
    // MARK: - Range mutation
    
    func testRangeMutationRespectsBounds()
    {
        let generator: Generator<Set<Int>> = .set(
            using:  .integer(in: 0...100),
            count:  3..<8
        )
        
        for _ in 0..<1000
        {
            let set     : Set<Int>  = generator.generate(.random)
            let mutated : Set<Int>  = generator.mutate(set, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    // MARK: - Non-empty generation
    
    func testNonEmptySetDeterminism()
    {
        let generator: Generator<Set<Int>>
            = .nonEmptySet(using: .integer(in: 0...1000))
        
        generator.assertDeterministic()
    }
    
    
    
    func testNonEmptySetNeverProducesEmpty()
    {
        let generator: Generator<Set<Int>>
            = .nonEmptySet(using: .integer(in: 0...1000))
        
        generator.assertCount(in: 1...Int.max)
    }
    
    
    
    func testArbitraryNonEmptySetDeterminism()
    {
        let generator: Generator<Set<Int>> = .nonEmptySet()
        
        generator.assertDeterministic(size: 100)
    }
    
    
    
    func testNonEmptySetUsesGenerator()
    {
        let generator: Generator<Set<Int>>
            = .nonEmptySet(using: .integer(in: 0...1000).map { $0 * 2 })
        
        for _ in 0..<1000
        {
            let set: Set<Int> = generator.generate(.random)
            
            for element in set
            {
                XCTAssertEqual(element % 2, 0)
            }
        }
    }
    
    
    
    // MARK: - Non-empty shrinking
    
    func testNonEmptySetShrinkNeverProducesEmpty()
    {
        let generator: Generator<Set<Int>>
            = .nonEmptySet(using: .integer(in: 0...1000))
        
        let set         : Set<Int>      = [10, 20, 30]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertFalse(candidate.isEmpty)
        }
    }
    
    
    
    func testNonEmptySetShrinkSingleElementOnlyShrinksElement()
    {
        let generator: Generator<Set<Int>>
            = .nonEmptySet(using: .integer(in: 0...1000))
        
        let set         : Set<Int>      = [10]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 1)
        }
    }
    
    
    
    func testNonEmptySetShrinkUsesGenerator()
    {
        let sentinel: Int = 999
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<Set<Int>>
            = .nonEmptySet(using: elementGenerator)
        
        let set         : Set<Int>      = [10, 20, 30]
        let candidates  : [Set<Int>]    = generator.shrink(set)
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    // MARK: - Non-empty mutation
    
    func testNonEmptySetMutationNeverProducesEmpty()
    {
        let generator: Generator<Set<Int>>
            = .nonEmptySet(using: .integer(in: 0...1000))
        
        for _ in 0..<1000
        {
            let set     : Set<Int>  = generator.generate(.random)
            let mutated : Set<Int>  = generator.mutate(set, .random)
            
            XCTAssertFalse(mutated.isEmpty)
        }
    }
    
    
    
    func testNonEmptySetMutationSingleElementCannotRemove()
    {
        let generator: Generator<Set<Int>>
            = .nonEmptySet(using: .integer(in: 0...1000))
        
        for _ in 0..<1000
        {
            let mutated: Set<Int> = generator.mutate([50], .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 1)
        }
    }
    
    
    
    func testNonEmptySetMutationUsesGenerator()
    {
        var mutateCallCount: Int = 0
        
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value + context.random(in: 1...100)
            }
        )
        
        let generator: Generator<Set<Int>>
            = .nonEmptySet(using: elementGenerator)
        
        let set         : Set<Int>  = [100, 200, 300]
        let iterations  : Int       = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(set, .random)
        }
        
        XCTAssertGreaterThan(
            mutateCallCount,
            Int(Double(iterations) * 0.7 * 0.95)
        )
    }
}
