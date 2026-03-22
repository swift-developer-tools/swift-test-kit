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



internal final class DictionaryGeneratorTests: TestKitCase
{
    // MARK: - Exact count generation
    
    func testExactCountDeterminism()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      5
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testExactCountProducesCorrectCount()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      7
        )
        
        generator.assertCount(in: 7...7)
    }
    
    
    
    func testExactCountZeroProducesEmpty()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      0
        )
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            XCTAssertTrue(dictionary.isEmpty)
        }
    }
    
    
    
    func testExactCountUsesGenerator()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...500).map { $0 * 2 },
            values:     .integer(in: 0...500).map { $0 * 2 + 1 },
            count:      5
        )
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            for (key, value) in dictionary
            {
                XCTAssertEqual(key % 2, 0)
                XCTAssertEqual(value % 2, 1)
            }
        }
    }
    
    
    
    func testExactCountKeysAreUnique()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      10
        )
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            XCTAssertEqual(dictionary.count, 10)
        }
    }
    
    
    
    func testArbitraryExactCountDeterminism()
    {
        let generator: Generator<[Int : Int]> = .dictionary(count: 5)
        
        generator.assertDeterministic(size: 100)
    }
    
    
    
    func testArbitraryExactCountProducesCorrectCount()
    {
        let generator: Generator<[Int : Int]> = .dictionary(count: 7)
        
        generator.assertCount(
            in:     7...7,
            size:   100
        )
    }
    
    
    
    // MARK: - Exact count shrinking
    
    func testExactCountShrinkPreservesCount()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      5
        )
        
        let dictionary  : [Int : Int]       = generator.generate(.random)
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, dictionary.count)
        }
    }
    
    
    
    func testExactCountShrinkElementsConvergeTowardZero()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      2
        )
        
        let dictionary  : [Int : Int]       = [10: 70, 20: 80]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertNotEqual(candidate, dictionary)
        }
    }
    
    
    
    func testExactCountShrinkAtTargetProducesEmpty()
    {
        let elementGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] }
        )
        
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       elementGenerator,
            values:     elementGenerator,
            count:      3
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2, 30: 3]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testExactCountShrinkUsesGenerators()
    {
        let keySentinel     : Int   = 777
        let valueSentinel   : Int   = 999
        
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [keySentinel] }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [valueSentinel] }
        )
        
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       keyGenerator,
            values:     valueGenerator,
            count:      2
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsKeySentinel: Bool = candidates.contains
        {
            return $0.keys.contains(keySentinel)
        }
        
        let containsValueSentinel: Bool = candidates.contains
        {
            return $0.values.contains(valueSentinel)
        }
        
        XCTAssertTrue(containsKeySentinel)
        XCTAssertTrue(containsValueSentinel)
    }
    
    
    
    func testExactCountShrinkSkipsKeyCollisions()
    {
        /// The generator always shrinks to a fixed array `[0]`. Since `0` is
        /// already a key in the dictionary, the duplicate must be filtered.
        
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [0] }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] }
        )
        
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       keyGenerator,
            values:     valueGenerator,
            count:      3
        )
        
        let dictionary  : [Int : Int]       = [0: 1, 20: 2, 30: 3]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testExactCountShrinkKeysAndValuesIndependently()
    {
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { value in [value / 2] }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { value in [value / 2] }
        )
        
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       keyGenerator,
            values:     valueGenerator,
            count:      1
        )
        
        let dictionary  : [Int : Int]       = [10: 20]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        /// One candidate must shrink only the key, another only the value.
        let keyShrunk   : Bool  = candidates.contains { $0[5] == 20 }
        let valueShrunk : Bool  = candidates.contains { $0[10] == 10 }
        
        XCTAssertTrue(keyShrunk)
        XCTAssertTrue(valueShrunk)
    }
    
    
    
    // MARK: - Exact count mutation
    
    func testExactCountMutationPreservesCount()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...100),
            values:     .integer(in: 0...100),
            count:      5
        )
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertEqual(mutated.count, 5)
        }
    }
    
    
    
    func testExactCountMutationChangesValues()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...100),
            values:     .integer(in: 0...100),
            count:      5
        )
        
        var changed: Bool = false
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int]
                = generator.generate(.randomSeed(size: 50))
            
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            if mutated != dictionary
            {
                changed = true
                break
            }
        }
        
        XCTAssertTrue(changed)
    }
    
    
    
    func testExactCountMutationOnlyMutatesValues()
    {
        var keyMutateCallCount      : Int   = 0
        var valueMutateCallCount    : Int   = 0
        
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                keyMutateCallCount += 1
                return value + context.random(in: 1...100)
            }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                valueMutateCallCount += 1
                return value + 1
            }
        )
        
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       keyGenerator,
            values:     valueGenerator,
            count:      3
        )
        
        let dictionary  : [Int : Int]   = [100: 1, 200: 2, 300: 3]
        let iterations  : Int           = 1000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(dictionary, .random)
        }
        
        XCTAssertEqual(keyMutateCallCount, 0)
        XCTAssertEqual(valueMutateCallCount, iterations)
    }
    
    
    
    func testExactCountMutationFallbackOnExhaustion()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...2),
            values:     .integer(in: 0...100),
            count:      3
        )
        
        let dictionary: [Int : Int] = [0: 10, 1: 20, 2: 30]
        
        for _ in 0..<1000
        {
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertEqual(mutated.count, 3)
        }
    }
    
    
    
    func testExactCountMutationReturnsEmpty()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      0
        )
        
        let mutated: [Int : Int] = generator.mutate([:], .random)
        
        XCTAssertTrue(mutated.isEmpty)
    }
    
    
    
    // MARK: - Closed range generation
    
    func testClosedRangeDeterminism()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      2...8
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testClosedRangeCountRespectsBounds()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      3...7
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testClosedRangeProducesVariousCount()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      0...10
        )
        
        var counts: Set<Int> = []
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            counts.insert(dictionary.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    func testArbitraryClosedRangeDeterminism()
    {
        let generator: Generator<[Int : Int]> = .dictionary(count: 2...8)
        
        generator.assertDeterministic(size: 100)
    }
    
    
    
    func testArbitraryClosedRangeCountRespectsBounds()
    {
        let generator: Generator<[Int : Int]> = .dictionary(count: 3...7)
        
        generator.assertCount(
            in:     3...7,
            size:   100
        )
    }
    
    
    
    // MARK: - Closed range shrinking
    
    func testClosedRangeShrinkReducesCount()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      2...8
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2, 30: 3, 40: 4]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        let isShorter: Bool
            = candidates.contains { $0.count < dictionary.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testClosedRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      3...8
        )
        
        let dictionary  : [Int : Int]       = [1: 1, 2: 2, 3: 3, 4: 4, 5: 5]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkAtLowerBoundOnlyShrinksEntries()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      3...8
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2, 30: 3]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      0...5
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2, 30: 3]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        let containsEmpty: Bool = candidates.contains { $0.isEmpty }
        
        XCTAssertTrue(containsEmpty)
    }
    
    
    
    func testClosedRangeShrinkUsesGenerators()
    {
        let keySentinel     : Int   = 777
        let valueSentinel   : Int   = 999
        
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [keySentinel] }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [valueSentinel] }
        )
        
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       keyGenerator,
            values:     valueGenerator,
            count:      2...8
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsKeySentinel: Bool = candidates.contains
        {
            return $0.keys.contains(keySentinel)
        }
        
        let containsValueSentinel: Bool = candidates.contains
        {
            return $0.values.contains(valueSentinel)
        }
        
        XCTAssertTrue(containsKeySentinel)
        XCTAssertTrue(containsValueSentinel)
    }
    
    
    
    // MARK: - Closed range mutation
    
    func testClosedRangeMutationRespectsBounds()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...100),
            count:      3...7
        )
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testClosedRangeMutationAtLowerBoundCannotRemove()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...100),
            count:      3...7
        )
        
        let dictionary: [Int : Int] = [10: 1, 20: 2, 30: 3]
        
        for _ in 0..<1000
        {
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testClosedRangeMutationAtUpperBoundCannotInsert()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...100),
            count:      3...5
        )
        
        let dictionary: [Int : Int] = [1: 1, 2: 2, 3: 3, 4: 4, 5: 5]
        
        for _ in 0..<1000
        {
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 5)
        }
    }
    
    
    
    func testClosedRangeMutationEmptyDictionaryInserts()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...100),
            count:      0...5
        )
        
        for _ in 0..<1000
        {
            let mutated: [Int : Int] = generator.mutate([:], .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
    
    
    
    func testClosedRangeMutationOnlyMutatesValues()
    {
        var keyMutateCallCount      : Int   = 0
        var valueMutateCallCount    : Int   = 0
        
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                keyMutateCallCount += 1
                return value + context.random(in: 1...100)
            }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                valueMutateCallCount += 1
                return value + 1
            }
        )
        
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       keyGenerator,
            values:     valueGenerator,
            count:      3...7
        )
        
        let dictionary  : [Int : Int]   = [100: 1, 200: 2, 300: 3, 400: 4]
        let iterations  : Int           = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(dictionary, .random)
        }
        
        XCTAssertEqual(keyMutateCallCount, 0)
        
        XCTAssertGreaterThan(
            valueMutateCallCount,
            Int(Double(iterations) * 0.7 * 0.85)
        )
    }
    
    
    
    // MARK: - Range generation
    
    func testRangeDeterminism()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      2..<9
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testRangeCountRespectsBounds()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      3..<8
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testRangeProducesVariousCount()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      0..<11
        )
        
        var counts: Set<Int> = []
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            counts.insert(dictionary.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    func testArbitraryRangeDeterminism()
    {
        let generator: Generator<[Int : Int]> = .dictionary(count: 2..<9)
        
        generator.assertDeterministic(size: 100)
    }
    
    
    
    func testArbitraryRangeCountRespectsBounds()
    {
        let generator: Generator<[Int : Int]> = .dictionary(count: 3..<8)
        
        generator.assertCount(
            in:     3...7,
            size:   100
        )
    }
    
    
    
    // MARK: - Range shrinking
    
    func testRangeShrinkReducesCount()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      2..<9
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2, 30: 3, 40: 4]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        let isShorter: Bool
            = candidates.contains { $0.count < dictionary.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      3..<9
        )
        
        let dictionary  : [Int : Int]       = [1: 1, 2: 2, 3: 3, 4: 4, 5: 5]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkAtLowerBoundOnlyShrinksEntries()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      3..<9
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2, 30: 3]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000),
            count:      0..<6
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2, 30: 3]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        let containsEmpty: Bool = candidates.contains { $0.isEmpty }
        
        XCTAssertTrue(containsEmpty)
    }
    
    
    
    func testRangeShrinkUsesGenerators()
    {
        let keySentinel     : Int   = 777
        let valueSentinel   : Int   = 999
        
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [keySentinel] }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [valueSentinel] }
        )
        
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       keyGenerator,
            values:     valueGenerator,
            count:      2..<9
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsKeySentinel: Bool = candidates.contains
        {
            return $0.keys.contains(keySentinel)
        }
        
        let containsValueSentinel: Bool = candidates.contains
        {
            return $0.values.contains(valueSentinel)
        }
        
        XCTAssertTrue(containsKeySentinel)
        XCTAssertTrue(containsValueSentinel)
    }
    
    
    
    // MARK: - Range mutation
    
    func testRangeMutationRespectsBounds()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...100),
            count:      3..<8
        )
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testRangeMutationAtLowerBoundCannotRemove()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...100),
            count:      3..<8
        )
        
        let dictionary: [Int : Int] = [10: 1, 20: 2, 30: 3]
        
        for _ in 0..<1000
        {
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testRangeMutationAtUpperBoundCannotInsert()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...100),
            count:      3..<6
        )
        
        let dictionary: [Int : Int] = [1: 1, 2: 2, 3: 3, 4: 4, 5: 5]
        
        for _ in 0..<1000
        {
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 5)
        }
    }
    
    
    
    func testRangeMutationEmptyDictionaryInserts()
    {
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...100),
            count:      0..<4
        )
        
        for _ in 0..<1000
        {
            let mutated: [Int : Int] = generator.mutate([:], .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
    
    
    
    func testRangeMutationOnlyMutatesValues()
    {
        var keyMutateCallCount      : Int   = 0
        var valueMutateCallCount    : Int   = 0
        
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                keyMutateCallCount += 1
                return value + context.random(in: 1...100)
            }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                valueMutateCallCount += 1
                return value + 1
            }
        )
        
        let generator: Generator<[Int : Int]> = .dictionary(
            keys:       keyGenerator,
            values:     valueGenerator,
            count:      3..<8
        )
        
        let dictionary  : [Int : Int]   = [100: 1, 200: 2, 300: 3, 400: 4]
        let iterations  : Int           = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(dictionary, .random)
        }
        
        XCTAssertEqual(keyMutateCallCount, 0)
        
        XCTAssertGreaterThan(
            valueMutateCallCount,
            Int(Double(iterations) * 0.7 * 0.85)
        )
    }
    
    
    
    // MARK: - Non-empty generation
    
    func testNonEmptyDictionaryDeterminism()
    {
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000)
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testNonEmptyDictionaryNeverProducesEmpty()
    {
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000)
        )
        
        generator.assertCount(in: 1...Int.max)
    }
    
    
    
    func testArbitraryNonEmptyDictionaryDeterminism()
    {
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary()
        
        generator.assertDeterministic(size: 100)
    }
    
    
    
    func testArbitraryNonEmptyDictionaryNeverProducesEmpty()
    {
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary()
        
        generator.assertCount(
            in:     1...Int.max,
            size:   100
        )
    }
    
    
    func testNonEmptyDictionaryUsesGenerators()
    {
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary(
            keys:       .integer(in: 0...500).map { $0 * 2 },
            values:     .integer(in: 0...500).map { $0 * 2 + 1 }
        )
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            for (key, value) in dictionary
            {
                XCTAssertEqual(key % 2, 0)
                XCTAssertEqual(value % 2, 1)
            }
        }
    }
    
    
    
    // MARK: - Non-empty shrinking
    
    func testNonEmptyDictionaryShrinkNeverProducesEmpty()
    {
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000))
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2, 30: 3]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertFalse(candidate.isEmpty)
        }
    }
    
    
    
    func testNonEmptyDictionaryShrinkSingleEntryOnlyShrinksEntry()
    {
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000))
        
        let dictionary  : [Int : Int]       = [10: 20]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 1)
        }
    }
    
    
    
    func testNonEmptyShrinkUsesGenerators()
    {
        let keySentinel     : Int   = 777
        let valueSentinel   : Int   = 999
        
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [keySentinel] }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [valueSentinel] }
        )
        
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary(
            keys:       keyGenerator,
            values:     valueGenerator
        )
        
        let dictionary  : [Int : Int]       = [10: 1, 20: 2]
        let candidates  : [[Int : Int]]     = generator.shrink(dictionary)
        
        XCTAssertFalse(candidates.isEmpty)
        
        let containsKeySentinel: Bool = candidates.contains
        {
            return $0.keys.contains(keySentinel)
        }
        
        let containsValueSentinel: Bool = candidates.contains
        {
            return $0.values.contains(valueSentinel)
        }
        
        XCTAssertTrue(containsKeySentinel)
        XCTAssertTrue(containsValueSentinel)
    }
    
    
    
    // MARK: - Non-empty mutation
    
    func testNonEmptyDictionaryMutationNeverProducesEmpty()
    {
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...1000))
        
        for _ in 0..<1000
        {
            let dictionary: [Int : Int] = generator.generate(.random)
            
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertFalse(mutated.isEmpty)
        }
    }
    
    
    
    func testNonEmptyDictionaryMutationSingleEntryCannotRemove()
    {
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary(
            keys:       .integer(in: 0...1000),
            values:     .integer(in: 0...100)
        )
        
        let dictionary: [Int : Int] = [10: 1]
        
        for _ in 0..<1000
        {
            let mutated: [Int : Int] = generator.mutate(dictionary, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 1)
        }
    }
    
    
    
    func testNonEmptyDictionaryMutationOnlyMutatesValues()
    {
        var keyMutateCallCount      : Int   = 0
        var valueMutateCallCount    : Int   = 0
        
        let keyGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                keyMutateCallCount += 1
                return value + context.random(in: 1...100)
            }
        )
        
        let valueGenerator = Generator<Int>(
            generate:   { context in context.random(in: 0...1000) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                valueMutateCallCount += 1
                return value + 1
            }
        )
        
        let generator: Generator<[Int : Int]> = .nonEmptyDictionary(
            keys:       keyGenerator,
            values:     valueGenerator
        )
        
        let dictionary  : [Int : Int]   = [100: 1, 200: 2, 300: 3, 400: 4]
        let iterations  : Int           = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(dictionary, .random)
        }
        
        XCTAssertEqual(keyMutateCallCount, 0)
        
        XCTAssertGreaterThan(
            valueMutateCallCount,
            Int(Double(iterations) * 0.7 * 0.85)
        )
    }
}
