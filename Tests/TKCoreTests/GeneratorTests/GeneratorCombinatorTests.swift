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



internal final class GeneratorCombinatorTests: XCTestCaseStopOnFail
{
    // MARK: - map
    
    func testMapDeterminism() throws
    {
        let generator: Generator<String> = Generator<Int>
            .integer(in: 0...100)
            .map { String($0) }
        
        generator.validateDeterminism()
    }
    
    
    
    func testMapDoesNotShrink() throws
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 0...100)
            .map { $0 * 2 }
        
        XCTAssertTrue(generator.shrink(50).isEmpty)
    }
    
    
    
    func testMapTransformsValues() throws
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
    
    
    
    // MARK: - flatMap
    
    func testFlatMapDeterminism() throws
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 1...10)
            .flatMap { .integer(in: 0...$0) }
        
        generator.validateDeterminism()
    }
    
    
    
    func testFlatMapDoesNotShrink() throws
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 1...10)
            .flatMap { .integer(in: 0...$0) }
        
        XCTAssertTrue(generator.shrink(5).isEmpty)
    }
    
    
    
    func testFlatMapChainsGenerators() throws
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
    
    
    
    // MARK: - filter
    
    func testFilterDeterminism() throws
    {
        let generator: Generator<Int> = Generator<Int>
            .integer(in: 1...100)
            .filter { $0 > 50 }
        
        generator.validateDeterminism()
    }
    
    
    
    func testFilterProducesOnlyMatchingValues() throws
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
    
    
    
    func testFilterShrinkCandidatesAlsoSatisfyPredicate() throws
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
    
    
    
    func testFilterPreservesUnderlyingBounds() throws
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
    
    
    
    // MARK: - constant
    
    func testConstantDeterminism() throws
    {
        let generator: Generator<Character> = .constant("a")
        
        generator.validateDeterminism()
    }
    
    
    
    func testConstantDoesNotShrink() throws
    {
        let generator: Generator<Int> = .constant(35)
        
        XCTAssertTrue(generator.shrink(35).isEmpty)
    }
    
    
    
    func testConstantAlwaysProducesSameValue() throws
    {
        let generator: Generator<String> = .constant("hello")
        
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), "hello")
        }
    }
    
    
    
    func testConstantIgnoresSize() throws
    {
        let generator: Generator<Int> = .constant(25)
        
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), 25)
        }
    }
    
    
    
    // MARK: - oneOf
    
    func testOneOfDeterminism() throws
    {
        let generator: Generator<Int> = .oneOf(
            .constant(1),
            .constant(2),
            .constant(3)
        )
        
        generator.validateDeterminism()
    }
    
    
    
    func testOneOfDoesNotShrink() throws
    {
        let generator: Generator<Int> = .oneOf(
            .integer(in: 0...10),
            .integer(in: 20...30)
        )
        
        XCTAssertTrue(generator.shrink(5).isEmpty)
    }
    
    
    
    func testOneOfSelectsFromAllGenerators() throws
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
    
    
    
    func testOneOfSingleGeneratorAlwaysSelectsIt() throws
    {
        let generator: Generator<Int> = .oneOf(.constant(30))
        
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), 30)
        }
    }
    
    
    
    // MARK: - frequency
    
    func tesFrequencyDeterminism() throws
    {
        let generator: Generator<Int> = .frequency(
            (3, .constant(1)),
            (2, .constant(2)),
            (1, .constant(3))
        )
        
        generator.validateDeterminism()
    }
    
    
    
    func testFrequencyDoesNotShrink() throws
    {
        let generator: Generator<Int> = .frequency(
            (1, .integer(in: 0...10)),
            (1, .integer(in: 20...30))
        )
        
        XCTAssertTrue(generator.shrink(5).isEmpty)
    }
    
    
    
    func testFrequencyRespectsWeights() throws
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
        
        XCTAssertNil(counts[0])
        XCTAssertGreaterThan(counts[1]!, Int(Double(iterations) * 0.95))
        XCTAssertLessThan(counts[2]!, Int(Double(iterations) * 0.05))
    }
    
    
    
    func testFrequencySelectsFromAllGenerators() throws
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
    
    
    
    func testFrequencyEqualWeightsDistributesEvenly() throws
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
        XCTAssertGreaterThan(counts[1]!, Int(Double(iterations) * 0.5 * 0.95))
        XCTAssertGreaterThan(counts[2]!, Int(Double(iterations) * 0.5 * 0.95))
    }
    
    
    
    // MARK: - elements
    
    func testElementsDeterminism() throws
    {
        let generator: Generator<Int> = .elements(of: [10, 20, 30, 40, 50])
        
        generator.validateDeterminism()
    }
    
    
    
    func testElementsDoesNotShrink() throws
    {
        let generator: Generator<Int> = .elements(of: [1, 2, 3])
        
        XCTAssertTrue(generator.shrink(2).isEmpty)
    }
    
    
    
    func testElementsSelectsFromCollection() throws
    {
        let options     : [String]              = ["red", "green", "blue"]
        let generator   : Generator<String>     = .elements(of: options)
        
        var seen: Set<String> = []
        
        for _ in 0..<1000
        {
            let value: String = generator.generate(.random)
            
            XCTAssertTrue(options.contains(value))
            
            seen.insert(value)
        }
        
        XCTAssertEqual(seen, Set(options))
    }
    
    
    
    func testElementsSingleELementAlwaysProducesIt() throws
    {
        let generator: Generator<Int> = .elements(of: [30])
        
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), 30)
        }
    }
    
    
    
    // MARK: - sized
    
    func testSizedDeterminism() throws
    {
        let generator: Generator<Int> = .sized { .integer(in: 0...max(1, $0)) }
        
        generator.validateDeterminism()
    }
    
    
    
    func testSizedDoesNotShrink() throws
    {
        let generator: Generator<Int> = .sized { .integer(in: 0...max(1, $0)) }
        
        XCTAssertTrue(generator.shrink(5).isEmpty)
    }
    
    
    
    func testSizedReceivesCurrentSize() throws
    {
        let generator: Generator<Int> = .sized { .constant($0) }
        
        for _ in 0..<1000
        {
            let randomSize: Int = GenerationContext.randomSize
            
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   randomSize
            )
            
            XCTAssertEqual(generator.generate(context), randomSize)
        }
    }
    
    
    
    // MARK: - zip
    
    func testZipOneDeterminism() throws
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
    
    
    
    func testZipTwoDeterminism() throws
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
    
    
    
    func testZipThreeDeterminism() throws
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
    
    
    
    func testZipFourDeterminism() throws
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
    
    
    
    func testZipMixedTypesDeterminism() throws
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
    
    
    
    func testZipOneGenerate() throws
    {
        let generator: Generator<Int> = .zip(.integer(in: 0...10))
        
        for _ in 0..<1000
        {
            let value: Int = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(value, 0)
            XCTAssertLessThanOrEqual(value, 10)
        }
    }
    
    
    
    func testZipOneShrink() throws
    {
        let generator: Generator<Int> = .zip(.integer(in: 0...100))
        
        let candidates: [Int] = generator.shrink(50)
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, 0)
    }
    
    
    
    func testZipTwoGenerate() throws
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
    
    
    
    func testZipTwoShrink() throws
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
    
    
    
    func testZipThreeGenerate() throws
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
    
    
    
    func testZipThreeShrink() throws
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
    
    
    
    func testZipFourShrink() throws
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
    
    
    
    func testZipSixGenerate() throws
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
    
    
    
    func testZipSixShrink() throws
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
    
    
    
    func testZipOverloadResolution() throws
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
    
    
    
    func testZipMixedTypesGenerate() throws
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
    
    
    
    func testZipMixedTypesShrink() throws
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
    
    
    
    func testZipShrinkCandidateValuesContainTargets() throws
    {
        let generator: Generator<(Int, Int)> = .zip(
            .integer(in: 0...100),
            .integer(in: 0...100)
        )
        
        let candidates: [(Int, Int)] = generator.shrink((50, 80))
        
        XCTAssertTrue(candidates.contains { $0.0 == 0   && $0.1 == 80 })
        XCTAssertTrue(candidates.contains { $0.0 == 50  && $0.1 == 0 })
    }
    
    
    
    func testZipShrinkCandidateCountMatchesSum() throws
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
    
    
    
    func testZipAllConstantProducesNoShrinkCandidates() throws
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
}
