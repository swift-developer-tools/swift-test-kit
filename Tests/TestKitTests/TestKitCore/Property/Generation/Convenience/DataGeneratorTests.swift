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



internal final class DataGeneratorTests: TestKitCase
{
    // MARK: - Exact count generation
    
    func testExactCountDeterminism()
    {
        let generator: Generator<Data> = .data(count: 5)
        
        generator.assertDeterministic()
    }
    
    
    
    func testExactCountProducesCorrectCount()
    {
        let generator: Generator<Data> = .data(count: 7)
        
        generator.assertCount(in: 7...7)
    }
    
    
    
    func testExactCountZeroProducesEmpty()
    {
        let generator: Generator<Data> = .data(count: 0)
        
        for _ in 0..<1000
        {
            let data: Data = generator.generate(.random)
            
            XCTAssertTrue(data.isEmpty)
        }
    }
    
    
    
    func testGeneratorExactCountDeterminism()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  5
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testGeneratorExactCountProducesCorrectCount()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  7
        )
        
        generator.assertCount(in: 7...7)
    }
    
    
    
    func testGeneratorExactCountZeroProducesEmpty()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  0
        )
        
        for _ in 0..<1000
        {
            let data: Data = generator.generate(.random)
            
            XCTAssertTrue(data.isEmpty)
        }
    }
    
    
    
    func testExactCountUsesGenerator()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50).map { $0 * 2 },
            count:  0
        )
        
        for _ in 0..<1000
        {
            let data: Data = generator.generate(.random)
            
            for byte in data
            {
                XCTAssertEqual(byte % 2, 0)
            }
        }
    }
    
    
    
    // MARK: - Exact count shrinking
    
    func testExactCountShrinkPreservesCount()
    {
        let generator   : Generator<Data>   = .data(count: 3)
        let data        : Data              = Data([10, 20, 30])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, data.count)
        }
    }
    
    
    
    func testExactCountShrinkBytesConvergeTowardZero()
    {
        let generator   : Generator<Data>   = .data(count: 2)
        let data        : Data              = Data([10, 20])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, data.count)
        }
        
        let onlyFirstShrunk: Bool = candidates.contains
        {
            candidate in
            
            let bytes: [UInt8] = Array(candidate)
            
            return bytes[0] != 10
                && bytes[1] == 20
        }
        
        let onlySecondShrunk: Bool = candidates.contains
        {
            candidate in
            
            let bytes: [UInt8] = Array(candidate)
            
            return bytes[0] == 10
                && bytes[1] != 20
        }
        
        XCTAssertTrue(onlyFirstShrunk)
        XCTAssertTrue(onlySecondShrunk)
    }
    
    
    
    func testExactCountShrinkAllZerosProducesEmpty()
    {
        let generator   : Generator<Data>   = .data(count: 3)
        let data        : Data              = Data([0, 0, 0])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testExactCountShrinkUsesGenerator()
    {
        let sentinel: UInt8 = 255
        
        let byteGenerator = Generator<UInt8>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<Data> = .data(
            using:  byteGenerator,
            count:  2
        )
        
        let data        : Data      = Data([10, 20])
        let candidates  : [Data]    = generator.shrink(data)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    func testGeneratorExactCountShrinkPreservesCount()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  3
        )
        
        let data        : Data      = Data([10, 20, 30])
        let candidates  : [Data]    = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testExactCountShrinkAtTargetProducesEmpty()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  3
        )
        
        let data        : Data      = Data([0, 0, 0])
        let candidates  : [Data]    = generator.shrink(data)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    // MARK: - Exact count mutation
    
    func testExactCountMutationPreservesCount()
    {
        let generator: Generator<Data> = .data(count: 5)
        
        for _ in 0..<1000
        {
            let data    : Data  = generator.generate(.random)
            let mutated : Data  = generator.mutate(data, .random)
            
            XCTAssertEqual(mutated.count, 5)
        }
    }
    
    
    
    func testExactCountMutationChangesElements()
    {
        let generator   : Generator<Data>   = .data(count: 5)
        var changed     : Bool              = false
        
        for _ in 0..<1000
        {
            let data    : Data  = generator.generate(.randomSeed(size: 50))
            let mutated : Data  = generator.mutate(data, .random)
            
            if mutated != data
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
        
        let byteGenerator = Generator<UInt8>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value
            }
        )
        
        let generator: Generator<Data> = .data(
            using:  byteGenerator,
            count:  3
        )
        
        let data        : Data  = Data([10, 20, 30])
        let iterations  : Int   = 1000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(data, .random)
        }
        
        XCTAssertEqual(mutateCallCount, iterations)
    }
    
    
    
    func testExactCountZeroMutationReturnsEmpty()
    {
        let generator   : Generator<Data>   = .data(count: 0)
        let mutated     : Data              = generator.mutate(Data(), .random)
        
        XCTAssertTrue(mutated.isEmpty)
    }
    
    
    
    // MARK: - Closed range generation
    
    func testClosedRangeDeterminism()
    {
        let generator: Generator<Data> = .data(count: 2...8)
        
        generator.assertDeterministic()
    }
    
    
    
    func testClosedRangeRespectsBounds()
    {
        let generator: Generator<Data> = .data(count: 3...7)
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testClosedRangeProducesVariousCounts()
    {
        let generator   : Generator<Data>   = .data(count: 0...10)
        var counts      : Set<Int>          = []
        
        for _ in 0..<1000
        {
            let data: Data = generator.generate(.random)
            
            counts.insert(data.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    func testGeneratorClosedRangeDeterminism()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  2...8
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testGeneratorClosedRangeRespectsBounds()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  3...7
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    // MARK: - Closed range shrinking
    
    func testClosedRangeShrinkReducesCount()
    {
        let generator   : Generator<Data>   = .data(count: 2...8)
        let data        : Data              = Data([10, 20, 30, 40, 50])
        let candidates  : [Data]            = generator.shrink(data)
        
        let isShorter: Bool = candidates.contains { $0.count < data.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testClosedRangeShrinkRespectsLowerBound()
    {
        let generator   : Generator<Data>   = .data(count: 3...8)
        let data        : Data              = Data([10, 20, 30, 40, 50])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkAtLowerBoundOnlyShrinksBytes()
    {
        let generator   : Generator<Data>   = .data(count: 3...8)
        let data        : Data              = Data([10, 20, 30])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testClosedRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator   : Generator<Data>   = .data(count: 0...5)
        let data        : Data              = Data([10, 20, 30])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertTrue(candidates.contains(Data()))
    }
    
    
    
    func testGeneratorClosedRangeShrinkReducesCount()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  2...8
        )
        
        let data        : Data      = Data([10, 20, 30, 40, 50])
        let candidates  : [Data]    = generator.shrink(data)
        
        let isShorter: Bool = candidates.contains { $0.count < data.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testGeneratorClosedRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  3...8
        )
        
        let data        : Data      = Data([10, 20, 30, 40, 50])
        let candidates  : [Data]    = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testGeneratorClosedRangeShrinkAtLowerBoundOnlyShrinksBytes()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  3...8
        )
        
        let data        : Data      = Data([10, 20, 30])
        let candidates  : [Data]    = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testGeneratorClosedRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  0...5
        )
        
        let data        : Data      = Data([10, 20, 30])
        let candidates  : [Data]    = generator.shrink(data)
        
        XCTAssertTrue(candidates.contains(Data()))
    }
    
    
    
    func testGeneratorClosedRangeShrinkUsesGenerator()
    {
        let sentinel: UInt8 = 255
        
        let byteGenerator = Generator<UInt8>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<Data> = .data(
            using:  byteGenerator,
            count:  2...8
        )
        
        let data        : Data      = Data([10, 20, 30])
        let candidates  : [Data]    = generator.shrink(data)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    // MARK: - Closed range mutation
    
    func testClosedRangeMutationRespectsBounds()
    {
        let generator: Generator<Data> = .data(count: 3...7)
        
        for _ in 0..<1000
        {
            let data    : Data  = generator.generate(.random)
            let mutated : Data  = generator.mutate(data, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testClosedRangeMutationAtLowerBoundCannotRemove()
    {
        let generator   : Generator<Data>   = .data(count: 3...7)
        let data        : Data              = Data([10, 20, 30])
        
        for _ in 0..<1000
        {
            let mutated: Data = generator.mutate(data, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testClosedRangeMutationAtUpperBoundCannotInsert()
    {
        let generator   : Generator<Data>   = .data(count: 3...5)
        let data        : Data              = Data([10, 20, 30, 40, 50])
        
        for _ in 0..<1000
        {
            let mutated: Data = generator.mutate(data, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 5)
        }
    }
    
    
    
    func testClosedRangeMutationEmptyDataInserts()
    {
        let generator: Generator<Data> = .data(count: 0...5)
        
        for _ in 0..<1000
        {
            let mutated: Data = generator.mutate(Data(), .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
    
    
    
    func testClosedRangeMutationUsesGenerator()
    {
        var mutateCallCount: Int = 0
        
        let byteGenerator = Generator<UInt8>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value
            }
        )
        
        let generator: Generator<Data> = .data(
            using:  byteGenerator,
            count:  3...7
        )
        
        let data        : Data  = Data([10, 20, 30, 40, 50])
        let iterations  : Int   = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(data, .random)
        }
        
        XCTAssertGreaterThanOrEqual(
            mutateCallCount,
            Int(Double(iterations) * 0.7 * 0.95)
        )
    }
    
    
    
    // MARK: - Range generation
    
    func testRangeDeterminism()
    {
        let generator: Generator<Data> = .data(count: 2..<9)
        
        generator.assertDeterministic()
    }
    
    
    
    func testRangeRespectsBounds()
    {
        let generator: Generator<Data> = .data(count: 3..<8)
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    func testRangeProducesVariousCounts()
    {
        let generator   : Generator<Data>   = .data(count: 0..<11)
        var counts      : Set<Int>          = []
        
        for _ in 0..<1000
        {
            let data: Data = generator.generate(.random)
            
            counts.insert(data.count)
        }
        
        XCTAssertGreaterThanOrEqual(counts.count, 9)
    }
    
    
    
    func testGeneratorRangeDeterminism()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  2..<9
        )
        
        generator.assertDeterministic()
    }
    
    
    
    func testGeneratorRangeRespectsBounds()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  3..<8
        )
        
        generator.assertCount(in: 3...7)
    }
    
    
    
    // MARK: - Range shrinking
    
    func testRangeShrinkReducesCount()
    {
        let generator   : Generator<Data>   = .data(count: 2..<9)
        let data        : Data              = Data([10, 20, 30, 40, 50])
        let candidates  : [Data]            = generator.shrink(data)
        
        let isShorter: Bool = candidates.contains { $0.count < data.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testRangeShrinkRespectsLowerBound()
    {
        let generator   : Generator<Data>   = .data(count: 3..<9)
        let data        : Data              = Data([10, 20, 30, 40, 50])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkAtLowerBoundOnlyShrinksBytes()
    {
        let generator   : Generator<Data>   = .data(count: 3..<9)
        let data        : Data              = Data([10, 20, 30])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator   : Generator<Data>   = .data(count: 0..<6)
        let data        : Data              = Data([10, 20, 30])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertTrue(candidates.contains(Data()))
    }
    
    
    
    func testGeneratorRangeShrinkReducesCount()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  2..<9
        )
        
        let data        : Data      = Data([10, 20, 30, 40, 50])
        let candidates  : [Data]    = generator.shrink(data)
        
        let isShorter: Bool = candidates.contains { $0.count < data.count }
        
        XCTAssertTrue(isShorter)
    }
    
    
    
    func testGeneratorRangeShrinkRespectsLowerBound()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  3..<9
        )
        
        let data        : Data      = Data([10, 20, 30, 40, 50])
        let candidates  : [Data]    = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertGreaterThanOrEqual(candidate.count, 3)
        }
    }
    
    
    
    func testGeneratorRangeShrinkAtLowerBoundOnlyShrinksBytes()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  3..<9
        )
        
        let data        : Data      = Data([10, 20, 30])
        let candidates  : [Data]    = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 3)
        }
    }
    
    
    
    func testGeneratorRangeShrinkZeroLowerBoundIncludesEmpty()
    {
        let generator: Generator<Data> = .data(
            using:  .integer(in: 0...50),
            count:  0..<6
        )
        
        let data        : Data      = Data([10, 20, 30])
        let candidates  : [Data]    = generator.shrink(data)
        
        XCTAssertTrue(candidates.contains(Data()))
    }
    
    
    
    func testGeneratorRangeShrinkUsesGenerator()
    {
        let sentinel: UInt8 = 255
        
        let byteGenerator = Generator<UInt8>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<Data> = .data(
            using:  byteGenerator,
            count:  2..<9
        )
        
        let data        : Data      = Data([10, 20, 30])
        let candidates  : [Data]    = generator.shrink(data)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    // MARK: - Range mutation
    
    func testRangeMutationRespectsBounds()
    {
        let generator: Generator<Data> = .data(count: 3..<8)
        
        for _ in 0..<1000
        {
            let data    : Data  = generator.generate(.random)
            let mutated : Data  = generator.mutate(data, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testRangeMutationAtLowerBoundCannotRemove()
    {
        let generator   : Generator<Data>   = .data(count: 3..<8)
        let data        : Data              = Data([10, 20, 30])
        
        for _ in 0..<1000
        {
            let mutated: Data = generator.mutate(data, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 7)
        }
    }
    
    
    
    func testRangeMutationAtUpperBoundCannotInsert()
    {
        let generator   : Generator<Data>   = .data(count: 3..<6)
        let data        : Data              = Data([10, 20, 30, 40, 50])
        
        for _ in 0..<1000
        {
            let mutated: Data = generator.mutate(data, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 3)
            XCTAssertLessThanOrEqual(mutated.count, 5)
        }
    }
    
    
    
    func testRangeMutationEmptyDataInserts()
    {
        let generator: Generator<Data> = .data(count: 0..<6)
        
        for _ in 0..<1000
        {
            let mutated: Data = generator.mutate(Data(), .random)
            
            XCTAssertEqual(mutated.count, 1)
        }
    }
    
    
    
    func testRangeMutationUsesGenerator()
    {
        var mutateCallCount: Int = 0
        
        let byteGenerator = Generator<UInt8>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value
            }
        )
        
        let generator: Generator<Data> = .data(
            using:  byteGenerator,
            count:  3..<8
        )
        
        let data        : Data  = Data([10, 20, 30, 40, 50])
        let iterations  : Int   = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(data, .random)
        }
        
        XCTAssertGreaterThanOrEqual(
            mutateCallCount,
            Int(Double(iterations) * 0.7 * 0.95)
        )
    }
    
    
    
    // MARK: - Non-empty generation
    
    func testNonEmptyDataDeterminism()
    {
        let generator: Generator<Data> = .nonEmptyData()
        
        generator.assertDeterministic()
    }
    
    
    
    func testNonEmptyDataNeverProducesEmpty()
    {
        let generator: Generator<Data> = .nonEmptyData()
        
        generator.assertCount(in: 1...Int.max)
    }
    
    
    
    func testGeneratorNonEmptyDataDeterminism()
    {
        let generator: Generator<Data>
            = .nonEmptyData(using: .integer(in: 0...50))
        
        generator.assertDeterministic()
    }
    
    
    
    func testGeneratorNonEmptyDataNeverProducesEmpty()
    {
        let generator: Generator<Data>
            = .nonEmptyData(using: .integer(in: 0...50))
        
        generator.assertCount(in: 1...Int.max)
    }
    
    
    
    func testGeneratorNonEmptyDataUsesGenerator()
    {
        let generator: Generator<Data>
            = .nonEmptyData(using: .integer(in: 0...50).map { $0 * 2 })
        
        for _ in 0..<1000
        {
            let data: Data = generator.generate(.random)
            
            for byte in data
            {
                XCTAssertEqual(byte % 2, 0)
            }
        }
    }
    
    
    
    // MARK: - Non-empty shrinking
    
    func testNonEmptyDataShrinkNeverProducesEmpty()
    {
        let generator   : Generator<Data>   = .nonEmptyData()
        let data        : Data              = Data([10, 20, 30])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertFalse(candidate.isEmpty)
        }
    }
    
    
    
    func testNonEmptyDataShrinkSingleByteOnlyShrinksByte()
    {
        let generator   : Generator<Data>   = .nonEmptyData()
        let data        : Data              = Data([10])
        let candidates  : [Data]            = generator.shrink(data)
        
        XCTAssertFalse(candidates.isEmpty)
        
        for candidate in candidates
        {
            XCTAssertEqual(candidate.count, 1)
        }
    }
    
    
    
    func testNonEmptyDataShrinkUsesGenerator()
    {
        let sentinel: UInt8 = 255
        
        let byteGenerator = Generator<UInt8>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [sentinel] }
        )
        
        let generator: Generator<Data> = .nonEmptyData(using: byteGenerator)

        let data        : Data      = Data([10, 20, 30])
        let candidates  : [Data]    = generator.shrink(data)
        
        let containsSentinel: Bool
            = candidates.contains { $0.contains(sentinel) }
        
        XCTAssertTrue(containsSentinel)
    }
    
    
    
    // MARK: - Non-empty mutation
    
    func testNonEmptyDataMutationNeverProducesEmpty()
    {
        let generator: Generator<Data> = .nonEmptyData()
        
        for _ in 0..<1000
        {
            let data    : Data  = generator.generate(.random)
            let mutated : Data  = generator.mutate(data, .random)
            
            XCTAssertFalse(mutated.isEmpty)
        }
    }
    
    
    
    func testNonEmptyDataMutationSingleByteCannotRemove()
    {
        let generator: Generator<Data> = .nonEmptyData()
        
        for _ in 0..<1000
        {
            let data    : Data  = Data([10])
            let mutated : Data  = generator.mutate(data, .random)
            
            XCTAssertGreaterThanOrEqual(mutated.count, 1)
        }
    }
    
    
    
    func testNonEmptyDataMutationUsesGenerator()
    {
        var mutateCallCount: Int = 0
        
        let byteGenerator = Generator<UInt8>(
            generate:   { context in context.random(in: 0...100) },
            shrink:     { _ in [] },
            mutate:
            {
                value, context in
                
                mutateCallCount += 1
                return value
            }
        )
        
        let generator: Generator<Data> = .nonEmptyData(using: byteGenerator)
        
        let data        : Data  = Data([10, 20, 30])
        let iterations  : Int   = 10_000
        
        for _ in 0..<iterations
        {
            _ = generator.mutate(data, .random)
        }
        
        XCTAssertGreaterThanOrEqual(
            mutateCallCount,
            Int(Double(iterations) * 0.7 * 0.95)
        )
    }
}
