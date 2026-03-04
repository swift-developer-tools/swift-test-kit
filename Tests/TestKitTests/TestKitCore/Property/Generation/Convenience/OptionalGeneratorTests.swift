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



internal final class OptionalGeneratorTests: TestKitCase
{
    // MARK: - Determinism
    
    func testDefaultProbabilityDeterminism()
    {
        let generator: Generator<Int?> = Generator<Int>
            .integer(in: 0...100)
            .optional()
        
        generator.assertDeterministic()
    }
    
    
    
    func testCustomProbabilityDeterminism()
    {
        let generator: Generator<Int?> = Generator<Int>
            .integer(in: 0...100)
            .optional(probability: 0.5)
        
        generator.assertDeterministic()
    }
    
    
    
    // MARK: - Generation
    
    func testDefaultProbabilityProducesOneFifthNil()
    {
        let generator: Generator<Int?> = Generator<Int>
            .integer(in: 0...100)
            .optional()
        
        var nilCount    : Int   = 0
        let iterations  : Int   = 10_000
        
        for _ in 0..<iterations
        {
            if generator.generate(.random) == nil
            {
                nilCount += 1
            }
        }
        
        XCTAssertGreaterThan(nilCount, Int(Double(iterations) * 0.2 * 0.95))
    }
    
    
    
    func testCustomProbabilityProducesNilAsExpected()
    {
        let probability: Double = 0.5
        
        let generator: Generator<Int?> = Generator<Int>
            .integer(in: 0...100)
            .optional(probability: probability)
        
        var nilCount    : Int   = 0
        let iterations  : Int   = 10_000
        
        for _ in 0..<iterations
        {
            if generator.generate(.random) == nil
            {
                nilCount += 1
            }
        }
        
        XCTAssertGreaterThan(
            nilCount,
            Int(Double(iterations) * probability * 0.95)
        )
    }
    
    
    
    func testProbabilityZeroNeverProducesNil()
    {
        let generator: Generator<Int?> = Generator<Int>
            .integer(in: 0...100)
            .optional(probability: 0.0)
        
        for _ in 0..<10_000
        {
            XCTAssertNotNil(generator.generate(.random))
        }
    }
    
    
    
    func testProbabilityOneAlwaysProducesNil()
    {
        let generator: Generator<Int?> = Generator<Int>
            .integer(in: 0...100)
            .optional(probability: 1.0)
        
        for _ in 0..<10_000
        {
            XCTAssertNil(generator.generate(.random))
        }
    }
    
    
    
    func testNonNilValuesRespectUnderlyingGenerator()
    {
        let generator: Generator<Int?> = Generator<Int>
            .integer(in: 10...20)
            .optional(probability: 0.0)
        
        for _ in 0..<10_000
        {
            let value: Int? = generator.generate(.random)
            
            guard let unwrapped: Int = value
            else
            {
                XCTFail("Expected non-nil value")
                return
            }
            
            XCTAssertGreaterThanOrEqual(unwrapped, 10)
            XCTAssertLessThanOrEqual(unwrapped, 20)
        }
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkNilProducesEmpty()
    {
        let generator: Generator<Int?> = Generator<Int>
            .integer(in: 0...100)
            .optional()
        
        let candidates: [Int?] = generator.shrink(nil)
        
        XCTAssertTrue(candidates.isEmpty)
    }
    
    
    
    func testShrinkNonNilProducesNilFirst()
    {
        let generator: Generator<Int?> = Generator<Int>
            .integer(in: 0...100)
            .optional()
        
        let candidates: [Int?] = generator.shrink(50)
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertNil(candidates.first!)
    }
    
    
    
    func testShrinkNonNilIncludesWrappedShrinkCandidates()
    {
        let base        : Generator<Int>    = .integer(in: 0...100)
        let generator   : Generator<Int?>   = base.optional()
        
        let baseCandidates      : [Int]     = base.shrink(50)
        let optionalCandidates  : [Int?]    = generator.shrink(50)
        
        /// The first optional candidate must be `nil`, and the rest must
        /// match the base candidates.
        XCTAssertFalse(baseCandidates.isEmpty)
        XCTAssertEqual(optionalCandidates.count, baseCandidates.count + 1)
        
        let wrappedCandidates: [Int?] = Array(optionalCandidates.dropFirst())
        
        for (wrapped, base) in zip(wrappedCandidates, baseCandidates)
        {
            XCTAssertEqual(wrapped, base)
        }
    }
}
