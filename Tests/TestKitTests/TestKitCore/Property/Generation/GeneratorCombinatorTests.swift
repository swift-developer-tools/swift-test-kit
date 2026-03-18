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



internal final class GeneratorCombinatorTests: TestKitCase
{
    // MARK: - map
    
    func testMapDeterminism()
    {
        let generator: Generator<String> = Generator<Int>
            .integer(in: 0...100)
            .map { String($0) }
        
        generator.assertDeterministic()
    }
    
    
    
    func testMapDoesNotShrink()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 0...100)
            .map { $0 * 2 }
        
        XCTAssertTrue(generator.shrink(50).isEmpty)
    }
    
    
    
    func testMapTransformsValues()
    {
        let base    : Generator<Int>    = .integer(in: 0...50)
        let doubled : Generator<Int>    = base.map { $0 * 2 }
        
        for _ in 0..<1000
        {
            let value: Int = doubled.generate(.random)
            
            XCTAssertEqual(value % 2, 0)
            XCTAssertGreaterThanOrEqual(value, 0)
            XCTAssertLessThanOrEqual(value, 100)
        }
    }
    
    
    
    func testMapMutationProducesTransformedValues()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 0...50)
            .map { $0 * 2 }
        
        for _ in 0..<1000
        {
            let value: Int = generator.mutate(25, .random)
            
            XCTAssertEqual(value % 2, 0)
            XCTAssertGreaterThanOrEqual(value, 0)
            XCTAssertLessThanOrEqual(value, 100)
        }
    }
    
    
    
    // MARK: - flatMap
    
    func testFlatMapDeterminism()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 1...10)
            .flatMap { .integer(in: 0...$0) }
        
        generator.assertDeterministic()
    }
    
    
    
    func testFlatMapDoesNotShrink()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 1...10)
            .flatMap { .integer(in: 0...$0) }
        
        XCTAssertTrue(generator.shrink(5).isEmpty)
    }
    
    
    
    func testFlatMapChainsGenerators()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 10...20)
            .flatMap { .integer(in: 0...$0) }
        
        for _ in 0..<1000
        {
            let value: Int = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(value, 0)
            XCTAssertLessThanOrEqual(value, 20)
        }
    }
    
    
    
    func testFlatMapMutationProducesValidValues()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 10...20)
            .flatMap { .integer(in: 0...$0) }
        
        for _ in 0..<1000
        {
            let value: Int = generator.mutate(5, .random)
            
            XCTAssertGreaterThanOrEqual(value, 0)
            XCTAssertLessThanOrEqual(value, 20)
        }
    }
    
    
    
    // MARK: - filter
    
    func testFilterDeterminism()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 1...100)
            .filter { $0 > 50 }
        
        generator.assertDeterministic()
    }
    
    
    
    func testFilterProducesOnlyMatchingValues()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 1...100)
            .filter { $0 % 3 == 0 }
        
        for _ in 0..<1000
        {
            let value: Int = generator.generate(.random)
            
            XCTAssertEqual(value % 3, 0)
        }
    }
    
    
    
    func testFilterShrinkCandidatesAlsoSatisfyPredicate()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 1...100)
            .filter { $0 % 2 == 0 }
        
        let candidates: [Int] = generator.shrink(50)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate % 2, 0)
        }
    }
    
    
    
    func testFilterPreservesUnderlyingBounds()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 10...20)
            .filter { $0 != 15 }
        
        for _ in 0..<1000
        {
            let value: Int = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(value, 10)
            XCTAssertLessThanOrEqual(value, 20)
            XCTAssertNotEqual(value, 15)
        }
    }
    
    
    
    func testFilterMutationSatisfiesPredicate()
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 1...100)
            .filter { $0 % 3 == 0 }
        
        for _ in 0..<1000
        {
            let value: Int = generator.mutate(33, .random)
            
            XCTAssertEqual(value % 3, 0)
            XCTAssertGreaterThanOrEqual(value, 1)
            XCTAssertLessThanOrEqual(value, 100)
        }
    }
    
    
    
    func testFilterMutationDelegatesToUnderlyingMutate()
    {
        /// Integer mutation adds small deltas scaled by context size. With a
        /// small size, mutating from `90` must produce values clustered near
        /// `90` (generation would average around `50`). With a size of `3`,
        /// integer mutation adds deltas in the range `-3...3`.
        
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 0...100)
            .filter { $0 % 2 == 0 }
        
        var sum         : Int   = 0
        let iterations  : Int   = 1000
        
        for _ in 0..<iterations
        {
            let value: Int = generator.mutate(90, .randomSeed(size: 3))
            
            sum += value
        }
        
        let average = Double(sum) / Double(iterations)
        
        XCTAssertGreaterThan(average, 75.0)
    }
    
    
    
    func testFilterMutationFallsBackOnMutationFailure()
    {
        let base = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { _, _ in -1 }
        )
        
        let generator: Generator<Int> = base.filter { $0 >= 0 }
        
        for _ in 0..<1000
        {
            let mutated: Int = generator.mutate(50, .random)
            
            XCTAssertGreaterThanOrEqual(mutated, 0)
            XCTAssertLessThanOrEqual(mutated, 100)
        }
    }
    
    
    
    // MARK: - constant
    
    func testConstantDeterminism()
    {
        let generator: Generator<Character> = .constant("a")
        
        generator.assertDeterministic()
    }
    
    
    
    func testConstantDoesNotShrink()
    {
        let generator: Generator<Int> = .constant(35)
        
        XCTAssertTrue(generator.shrink(35).isEmpty)
    }
    
    
    
    func testConstantAlwaysProducesSameValue()
    {
        let generator: Generator<String> = .constant("hello")
        
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), "hello")
        }
    }
    
    
    
    func testConstantIgnoresSize()
    {
        let generator: Generator<Int> = .constant(25)
        
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), 25)
        }
    }
    
    
    
    func testConstantMutationAlwaysReturnsConstant()
    {
        let generator: Generator<Int> = .constant(25)
        
        for _ in 0..<1000
        {
            let value: Int = generator.mutate(99, .random)
            
            XCTAssertEqual(value, 25)
        }
    }
    
    
    
    // MARK: - oneOf
    
    func testOneOfDeterminism()
    {
        let generator: Generator<Int> = .oneOf(
            .constant(1),
            .constant(2),
            .constant(3)
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testOneOfDoesNotShrink()
    {
        let generator: Generator<Int> = .oneOf(
            .integer(in: 0...10),
            .integer(in: 20...30)
        )
        
        XCTAssertTrue(generator.shrink(5).isEmpty)
    }
    
    
    
    func testOneOfSelectsFromAllGenerators()
    {
        let generator: Generator<Int> = .oneOf(
            .constant(1),
            .constant(2),
            .constant(3)
        )
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            seen.insert(generator.generate(.random))
        }
        
        XCTAssertEqual(seen, [1, 2, 3])
    }
    
    
    
    func testOneOfSingleGeneratorAlwaysSelectsIt()
    {
        let generator: Generator<Int> = .oneOf(.constant(30))
        
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), 30)
        }
    }
    
    
    
    func testOneOfMutationProducesValidValues()
    {
        let generator: Generator<Int> = .oneOf(
            .constant(1),
            .constant(2),
            .constant(3)
        )
        
        var seen: Set<Int> = []
        
        for _ in 0..<1000
        {
            let value: Int = generator.mutate(1, .random)
            
            seen.insert(value)
        }
        
        XCTAssertEqual(seen, [1, 2, 3])
    }
    
    
    
    // MARK: - frequency
    
    func tesFrequencyDeterminism() throws
    {
        let generator: Generator<Int> = .frequency(
            (3, .constant(1)),
            (2, .constant(2)),
            (1, .constant(3))
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testFrequencyDoesNotShrink()
    {
        let generator: Generator<Int> = .frequency(
            (1, .integer(in: 0...10)),
            (1, .integer(in: 20...30))
        )
        
        XCTAssertTrue(generator.shrink(5).isEmpty)
    }
    
    
    
    func testFrequencyRespectsWeights()
    {
        let generator: Generator<Int> = .frequency(
            (99, .constant(1)),
            (1, .constant(2))
        )
        
        var counts      : [Int : Int]   = [1: 0, 2: 0]
        let iterations  : Int           = 10_000
        
        for _ in 0..<iterations
        {
            let value: Int = generator.generate(.random)
            
            counts[value, default: 0] += 1
        }
        
        XCTAssertGreaterThan(counts[1]!, Int(Double(iterations) * 0.85))
        XCTAssertLessThan(counts[2]!, Int(Double(iterations) * 0.05))
    }
    
    
    
    func testFrequencySelectsFromAllGenerators()
    {
        let generator: Generator<Int> = .frequency(
            (10, .constant(1)),
            (1, .constant(2)),
            (1, .constant(3))
        )
        
        var seen: Set<Int> = []
        
        for _ in 0..<10_000
        {
            seen.insert(generator.generate(.random))
        }
        
        XCTAssertEqual(seen, [1, 2, 3])
    }
    
    
    
    func testFrequencyEqualWeightsDistributesEvenly()
    {
        let generator: Generator<Int> = .frequency(
            (1, .constant(1)),
            (1, .constant(2))
        )
        
        var counts      : [Int : Int]   = [1: 0, 2: 0]
        let iterations  : Int           = 10_000
        
        for _ in 0..<iterations
        {
            let value: Int = generator.generate(.random)
            
            counts[value, default: 0] += 1
        }
        
        XCTAssertNil(counts[0])
        XCTAssertGreaterThan(counts[1]!, Int(Double(iterations) * 0.5 * 0.85))
        XCTAssertGreaterThan(counts[2]!, Int(Double(iterations) * 0.5 * 0.85))
    }
    
    
    
    func testFrequencyMutationProducesValidValues()
    {
        let generator: Generator<Int> = .frequency(
            (9, .constant(1)),
            (1, .constant(2))
        )
        
        var seen: Set<Int> = []
        
        for _ in 0..<10_000
        {
            let value: Int = generator.mutate(1, .random)
            
            seen.insert(value)
        }
        
        XCTAssertEqual(seen, [1, 2])
    }
    
    
    
    // MARK: - elements
    
    func testElementsDeterminism()
    {
        let generator: Generator<Int> = .elements(of: [10, 20, 30, 40, 50])
        
        generator.assertDeterministic()
    }
    
    
    
    func testElementsDoesNotShrink()
    {
        let generator: Generator<Int> = .elements(of: [1, 2, 3])
        
        XCTAssertTrue(generator.shrink(2).isEmpty)
    }
    
    
    
    func testElementsSelectsFromCollection()
    {
        let options     : [String]              = ["red", "green", "blue"]
        let generator   : Generator<String>     = .elements(of: options)
        var seen        : Set<String>           = []
        
        for _ in 0..<1000
        {
            let value: String = generator.generate(.random)
            
            XCTAssertTrue(options.contains(value))
            
            seen.insert(value)
        }
        
        XCTAssertEqual(seen, Set(options))
    }
    
    
    
    func testElementsSingleELementAlwaysProducesIt()
    {
        let generator: Generator<Int> = .elements(of: [30])
        
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), 30)
        }
    }
    
    
    
    func testElementsMutationProducesCollectionElements()
    {
        let options     : [String]              = ["red", "green", "blue"]
        let generator   : Generator<String>     = .elements(of: options)
        var seen        : Set<String>           = []
        
        for _ in 0..<1000
        {
            let value: String = generator.mutate(options[0], .random)
            
            XCTAssertTrue(options.contains(value))
            
            seen.insert(value)
        }
        
        XCTAssertEqual(seen, Set(options))
    }
    
    
    
    // MARK: - sized
    
    func testSizedDeterminism()
    {
        let generator: Generator<Int> = .sized { .integer(in: 0...max(1, $0)) }
        
        generator.assertDeterministic()
    }
    
    
    
    func testSizedDoesNotShrink()
    {
        let generator: Generator<Int> = .sized { .integer(in: 0...max(1, $0)) }
        
        XCTAssertTrue(generator.shrink(5).isEmpty)
    }
    
    
    
    func testSizedReceivesCurrentSize()
    {
        let generator: Generator<Int> = .sized { .constant($0) }
        
        for _ in 0..<1000
        {
            let size    : Int   = GenerationContext.randomSize
            let value   : Int   = generator.generate(.randomSeed(size: size))
            
            XCTAssertEqual(value, size)
        }
    }
    
    
    
    func testSizedMutationProducesValidValues()
    {
        let generator: Generator<Int> = .sized { .constant($0) }
        
        for _ in 0..<1000
        {
            let size    : Int   = GenerationContext.randomSize
            let value   : Int   = generator.mutate(99, .randomSeed(size: size))
            
            XCTAssertEqual(value, size)
        }
    }
    
    
    
    // MARK: - zip
    
    func testZipOneDeterminism()
    {
        let generator: Generator<String> = .zip(.nonEmptyString())
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let a   : String    = generator.generate(context1)
            let b   : String    = generator.generate(context2)
            
            XCTAssertEqual(a, b)
        }
    }
    
    
    
    func testZipTwoDeterminism()
    {
        let generator: Generator<(Int, String)> = .zip(
            .integer(in: 0...100),
            .nonEmptyString()
        )
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let a   : (Int, String)     = generator.generate(context1)
            let b   : (Int, String)     = generator.generate(context2)
            
            XCTAssertEqual(a.0, b.0)
            XCTAssertEqual(a.1, b.1)
        }
    }
    
    
    
    func testZipThreeDeterminism()
    {
        let generator: Generator<(Int, Int, Int)> = .zip(
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100)
        )
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let a   : (Int, Int, Int)   = generator.generate(context1)
            let b   : (Int, Int, Int)   = generator.generate(context2)
            
            XCTAssertEqual(a.0, b.0)
            XCTAssertEqual(a.1, b.1)
            XCTAssertEqual(a.2, b.2)
        }
    }
    
    
    
    func testZipFourDeterminism()
    {
        let generator = Generator.zip(
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100)
        )
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let a   = generator.generate(context1)
            let b   = generator.generate(context2)
            
            XCTAssertEqual(a.0, b.0)
            XCTAssertEqual(a.1, b.1)
            XCTAssertEqual(a.2, b.2)
            XCTAssertEqual(a.3, b.3)
        }
    }
    
    
    
    func testZipMixedTypesDeterminism()
    {
        let generator: Generator<(Int, String, Bool, Double)> = .zip(
            .integer(in: 0...100),
            .nonEmptyString(),
            .constant(true),
            .floatingPoint(in: -10...10)
        )
        
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let a   = generator.generate(context1)
            let b   = generator.generate(context2)
            
            XCTAssertEqual(a.0, b.0)
            XCTAssertEqual(a.1, b.1)
            XCTAssertEqual(a.2, b.2)
            XCTAssertEqual(a.3, b.3)
        }
    }
    
    
    
    func testZipOneGenerate()
    {
        let generator: Generator<Int> = .zip(.integer(in: 0...10))
        
        for _ in 0..<1000
        {
            let value: Int = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(value, 0)
            XCTAssertLessThanOrEqual(value, 10)
        }
    }
    
    
    
    func testZipOneShrink()
    {
        let generator: Generator<Int> = .zip(.integer(in: 0...100))
        
        let candidates: [Int] = generator.shrink(50)
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, 0)
    }
    
    
    
    func testZipTwoGenerate()
    {
        let generator: Generator<(Int, String)> = .zip(
            .integer(in: 0...10),
            .constant("hello")
        )
        
        for _ in 0..<1000
        {
            let pair: (Int, String) = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(pair.0, 0)
            XCTAssertLessThanOrEqual(pair.0, 10)
            XCTAssertEqual(pair.1, "hello")
        }
    }
    
    
    
    func testZipTwoShrink()
    {
        let generator: Generator<(Int, Int)> = .zip(
            .integer(in: 0...100),
            .integer(in: 0...100)
        )
        
        let candidates: [(Int, Int)] = generator.shrink((50, 80))
        
        let onlyFirstShrunk: Bool = candidates.contains
        {
            return $0.0 != 50
                && $0.1 == 80
        }
        
        XCTAssertTrue(onlyFirstShrunk)
        
        let onlySecondShrunk: Bool = candidates.contains
        {
            return $0.0 == 50
                && $0.1 != 80
        }
        
        XCTAssertTrue(onlySecondShrunk)
    }
    
    
    
    func testZipThreeGenerate()
    {
        let generator: Generator<(Int, Int, Int)> = .zip(
            .constant(1),
            .constant(2),
            .constant(3)
        )
        
        for _ in 0..<1000
        {
            let triple: (Int, Int, Int) = generator.generate(.random)
            
            XCTAssertEqual(triple.0, 1)
            XCTAssertEqual(triple.1, 2)
            XCTAssertEqual(triple.2, 3)
        }
    }
    
    
    
    func testZipThreeShrink()
    {
        let generator: Generator<(Int, Int, Int)> = .zip(
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100)
        )
        
        let candidates: [(Int, Int, Int)] = generator.shrink((50, 60, 70))
        
        let onlyFirstShrunk: Bool = candidates.contains
        {
            return $0.0 != 50
                && $0.1 == 60
                && $0.2 == 70
        }
        
        XCTAssertTrue(onlyFirstShrunk)
        
        let onlySecondShrunk: Bool = candidates.contains
        {
            return $0.0 == 50
                && $0.1 != 60
                && $0.2 == 70
        }
        
        XCTAssertTrue(onlySecondShrunk)
        
        let onlyThirdShrunk: Bool = candidates.contains
        {
            return $0.0 == 50
                && $0.1 == 60
                && $0.2 != 70
        }
        
        XCTAssertTrue(onlyThirdShrunk)
    }
    
    
    
    func testZipFourShrink()
    {
        let generator: Generator<(Int, Int, Int, Int)> = .zip(
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100)
        )
        
        let candidates: [(Int, Int, Int, Int)]
            = generator.shrink((40, 50, 60, 70))
        
        let onlyFirstShrunk: Bool = candidates.contains
        {
            return $0.0 != 40
                && $0.1 == 50
                && $0.2 == 60
                && $0.3 == 70
        }
        
        XCTAssertTrue(onlyFirstShrunk)
        
        let onlySecondShrunk: Bool = candidates.contains
        {
            return $0.0 == 40
                && $0.1 != 50
                && $0.2 == 60
                && $0.3 == 70
        }
        
        XCTAssertTrue(onlySecondShrunk)
        
        let onlyThirdShrunk: Bool = candidates.contains
        {
            return $0.0 == 40
                && $0.1 == 50
                && $0.2 != 60
                && $0.3 == 70
        }
        
        XCTAssertTrue(onlyThirdShrunk)
        
        let onlyFourthShrunk: Bool = candidates.contains
        {
            return $0.0 == 40
                && $0.1 == 50
                && $0.2 == 60
                && $0.3 != 70
        }
        
        XCTAssertTrue(onlyFourthShrunk)
    }
    
    
    
    func testZipSixGenerate()
    {
        let generator = Generator.zip(
            .constant(1),
            .constant(2),
            .constant(3),
            .constant(4),
            .constant(5),
            .constant(6)
        )
        
        for _ in 0..<1000
        {
            let sextuple = generator.generate(.random)
            
            XCTAssertEqual(sextuple.0, 1)
            XCTAssertEqual(sextuple.1, 2)
            XCTAssertEqual(sextuple.2, 3)
            XCTAssertEqual(sextuple.3, 4)
            XCTAssertEqual(sextuple.4, 5)
            XCTAssertEqual(sextuple.5, 6)
        }
    }
    
    
    
    func testZipSixShrink()
    {
        let generator = Generator.zip(
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100)
        )
        
        let original: [Int] = [10, 20, 30, 40, 50, 60]
        
        let candidates = generator.shrink((10, 20, 30, 40, 50, 60))
        
        XCTAssertFalse(candidates.isEmpty)
        
        for i in 0..<6
        {
            let found: Bool = candidates.contains
            {
                candidate in
                
                let values: [Int] =
                [
                    candidate.0,
                    candidate.1,
                    candidate.2,
                    candidate.3,
                    candidate.4,
                    candidate.5
                ]
                
                for j in 0..<6
                {
                    if j == i
                    {
                        if values[j] == original[j]
                        {
                            return false
                        }
                    }
                    else
                    {
                        if values[j] != original[j]
                        {
                            return false
                        }
                    }
                }
                
                return true
            }
            
            XCTAssertTrue(found)
        }
    }
    
    
    
    func testZipOverloadResolution()
    {
        let genA = Generator<Int>(
            generate:   { _ in 1 },
            shrink:     { _ in [0] }
        )
        
        let genB = Generator<Int>(
            generate:   { _ in 2 },
            shrink:     { _ in [0] }
        )
        
        let genC = Generator<Int>(
            generate:   { _ in 3 },
            shrink:     { _ in [0] }
        )
        
        let pairGenerator       = Generator.zip(genA, genB)
        let tripleGenerator     = Generator.zip(genA, genB, genC)
        let quadrupleGenerator  = Generator.zip(genA, genB, genC, genA)
        
        for _ in 0..<1000
        {
            let pairValue   = pairGenerator.generate(.random)
            let pairShrunk  = pairGenerator.shrink(pairValue)
            
            XCTAssertEqual(pairValue.0, 1)
            XCTAssertEqual(pairValue.1, 2)
            XCTAssertFalse(pairShrunk.isEmpty)
            
            let tripleValue     = tripleGenerator.generate(.random)
            let tripleShrunk    = tripleGenerator.shrink(tripleValue)
            
            XCTAssertEqual(tripleValue.0, 1)
            XCTAssertEqual(tripleValue.1, 2)
            XCTAssertEqual(tripleValue.2, 3)
            XCTAssertFalse(tripleShrunk.isEmpty)
            
            let quadrupleValue      = quadrupleGenerator.generate(.random)
            let quadrupleShrunk     = quadrupleGenerator.shrink(quadrupleValue)
            
            XCTAssertEqual(quadrupleValue.0, 1)
            XCTAssertEqual(quadrupleValue.1, 2)
            XCTAssertEqual(quadrupleValue.2, 3)
            XCTAssertEqual(quadrupleValue.3, 1)
            XCTAssertFalse(quadrupleShrunk.isEmpty)
        }
    }
    
    
    
    func testZipMixedTypesGenerate()
    {
        let generator: Generator<(Int, String, Bool)> = .zip(
            .integer(in: 0...10),
            .nonEmptyString(),
            .constant(true)
        )
        
        for _ in 0..<1000
        {
            let value: (Int, String, Bool) = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(value.0, 0)
            XCTAssertLessThanOrEqual(value.0, 10)
            XCTAssertFalse(value.1.isEmpty)
            XCTAssertTrue(value.2)
        }
    }
    
    
    
    func testZipMixedTypesShrink()
    {
        let generator: Generator<(Int, String, Bool, Double)> = .zip(
            .integer(in: 0...100),
            .nonEmptyString(),
            .constant(true),
            .floatingPoint(in: 0...10)
        )
        
        let value       = (50, "hello", true, 5.0)
        let candidates  = generator.shrink(value)
        
        let onlyIntShrunk: Bool = candidates.contains
        {
            return $0.0 != 50
                && $0.1 == "hello"
                && $0.2 == true
                && $0.3 == 5.0
        }
        
        XCTAssertTrue(onlyIntShrunk)
        
        let onlyStringShrunk: Bool = candidates.contains
        {
            return $0.0 == 50
                && $0.1 != "hello"
                && $0.2 == true
                && $0.3 == 5.0
        }
        
        XCTAssertTrue(onlyStringShrunk)
        
        let onlyBoolShrunk: Bool = candidates.contains
        {
            return $0.0 == 50
                && $0.1 == "hello"
                && $0.2 != true
                && $0.3 == 5.0
        }
        
        /// ``Generator/constant(_:)`` does not shrink.
        XCTAssertFalse(onlyBoolShrunk)
        
        let onlyDoubleShrunk: Bool = candidates.contains
        {
            return $0.0 == 50
                && $0.1 == "hello"
                && $0.2 == true
                && $0.3 != 5.0
        }
        
        XCTAssertTrue(onlyDoubleShrunk)
    }
    
    
    
    func testZipShrinkCandidateValuesContainTargets()
    {
        let generator: Generator<(Int, Int)> = .zip(
            .integer(in: 0...100),
            .integer(in: 0...100)
        )
        
        let candidates: [(Int, Int)] = generator.shrink((50, 80))
        
        XCTAssertTrue(candidates.contains { $0.0 == 0   && $0.1 == 80 })
        XCTAssertTrue(candidates.contains { $0.0 == 50  && $0.1 == 0 })
    }
    
    
    
    func testZipShrinkCandidateCountMatchesSum()
    {
        let intGen      : Generator<Int>        = .integer(in: 0...100)
        let stringGen   : Generator<String>     = .nonEmptyString()
        
        let zipGen: Generator<(Int, String)> = .zip(
            intGen,
            stringGen
        )
        
        let value               : (Int, String)     = (50, "hello")
        let intCandidates       : [Int]             = intGen.shrink(value.0)
        let stringCandidates    : [String]          = stringGen.shrink(value.1)
        let zipCandidates       : [(Int, String)]   = zipGen.shrink(value)
        
        XCTAssertEqual(
            zipCandidates.count,
            intCandidates.count + stringCandidates.count
        )
    }
    
    
    
    func testZipAllConstantProducesNoShrinkCandidates()
    {
        let generator: Generator<(Int, String, Bool)> = .zip(
            .constant(1),
            .constant("a"),
            .constant(true)
        )
        
        let candidates: [(Int, String, Bool)]
            = generator.shrink((1, "a", true))
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testZipMutationChangesAtMostOneElement()
    {
        let generator: Generator<(Int, Int, Int)> = .zip(
            .integer(in: 0...100),
            .integer(in: 0...100),
            .integer(in: 0...100)
        )
        
        let original    : (Int, Int, Int)   = (50, 60, 70)
        var changed     : Set<Int>          = []
        
        for _ in 0..<1000
        {
            let mutated: (Int, Int, Int) = generator.mutate(original, .random)
            
            var diffCount: Int = 0
            
            if mutated.0 != original.0
            {
                diffCount += 1
                changed.insert(0)
            }
            
            if mutated.1 != original.1
            {
                diffCount += 1
                changed.insert(1)
            }
            
            if mutated.2 != original.2
            {
                diffCount += 1
                changed.insert(2)
            }
            
            XCTAssertLessThanOrEqual(diffCount, 1)
        }
        
        XCTAssertEqual(changed, [0, 1, 2])
    }
    
    
    
    func testZipSingleElementMutationDelegatesToUnderlyingMutate()
    {
        /// Integer mutation adds small deltas scaled by context size. With a
        /// small size, mutating from `90` must produce values clustered near
        /// `90` (generation would average around `50`). With a size of `3`,
        /// integer mutation adds deltas in the range `-3...3`.
        
        let generator   : Generator<Int>    = .zip(.integer(in: 0...100))
        var sum         : Int               = 0
        let iterations  : Int               = 1000
        
        for _ in 0..<iterations
        {
            let mutated: Int = generator.mutate(90, .randomSeed(size: 3))
            
            XCTAssertGreaterThanOrEqual(mutated, 0)
            XCTAssertLessThanOrEqual(mutated, 100)
            
            sum += mutated
        }
        
        let average = Double(sum) / Double(iterations)
        
        XCTAssertGreaterThan(average, 75.0)
    }
    
    
    
    func testZipAllConstantMutationReturnsConstants()
    {
        let generator: Generator<(Int, String, Bool)> = .zip(
            .constant(1),
            .constant("a"),
            .constant(true)
        )
        
        for _ in 0..<1000
        {
            let mutated: (Int, String, Bool)
                = generator.mutate((1, "a", true), .random)
            
            XCTAssertEqual(mutated.0, 1)
            XCTAssertEqual(mutated.1, "a")
            XCTAssertEqual(mutated.2, true)
        }
    }
    
    
    
    func testZipMutationDelegatesToUnderlyingMutate()
    {
        let addOne = Generator<Int>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:     { value, _ in value + 1}
        )
        
        let generator   : Generator<(Int, Int)>     = .zip(addOne, addOne)
        let original    : (Int, Int)                = (10, 20)
        
        for _ in 0..<1000
        {
            let mutated: (Int, Int) = generator.mutate(original, .random)
            
            let firstMutated    : Bool  = mutated.0 == 11 && mutated.1 == 20
            let secondMutated   : Bool  = mutated.0 == 10 && mutated.1 == 21
            
            XCTAssertTrue(firstMutated || secondMutated)
        }
    }
}
