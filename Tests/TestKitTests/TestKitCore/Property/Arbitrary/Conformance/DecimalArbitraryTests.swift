//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import TestKitCore
import XCTest



internal final class DecimalArbitraryTests: TestKitCase
{
    // MARK: - Determinism
    
    func testArbitraryDeterminism()
    {
        assertArbitraryDeterminism(of: Decimal.self)
    }
    
    
    
    // MARK: - Generation
    
    func testGenerationSizeZeroBounds()
    {
        for _ in 0..<1000
        {
            let value = Decimal.arbitrary(using: .randomZeroSize)
            
            guard !value.isNaN
            else
            {
                continue
            }
            
            /// At size zero, the integer component is zero. The fractional
            /// component is in the range `-1...1`. The total must also be in
            /// that range.
            XCTAssertGreaterThanOrEqual(value, -1)
            XCTAssertLessThanOrEqual(value, 1)
        }
    }
    
    
    
    func testGenerationSizeBounds()
    {
        let size    : Int       = 10
        let bound   : Decimal   = .init(size) + 1
        
        for _ in 0..<1000
        {
            let value = Decimal.arbitrary(using: .randomSeed(size: size))
            
            guard !value.isNaN
            else
            {
                continue
            }
            
            /// The integer component is in the range `-size...size`, and the
            /// fractional component is in the range `-1...1`. The total bound
            /// must be `size + 1`.
            XCTAssertGreaterThanOrEqual(value, -bound)
            XCTAssertLessThanOrEqual(value, bound)
        }
    }
    
    
    
    func testGenerationSignedValueProduction()
    {
        var hasNegative : Bool  = false
        var hasPositive : Bool  = false
        
        for _ in 0..<1000
        {
            let value = Decimal.arbitrary(using: .random)
            
            if value < 0
            {
                hasNegative = true
            }
            
            if value > 0
            {
                hasPositive = true
            }
            
            if
                hasNegative,
                hasPositive
            {
                break
            }
        }
        
        XCTAssertTrue(hasNegative)
        XCTAssertTrue(hasPositive)
    }
    
    
    
    func testGenerationNaNProduction()
    {
        var hasNaN: Bool = false
        
        for _ in 0..<1000
        {
            let value = Decimal.arbitrary(using: .random)
            
            if value.isNaN
            {
                hasNaN = true
                break
            }
        }
        
        XCTAssertTrue(hasNaN)
    }
    
    
    
    func testGenerationFractionalProduction()
    {
        var hasFractional: Bool = false
        
        for _ in 0..<1000
        {
            let value = Decimal.arbitrary(using: .random)
            
            guard !value.isNaN
            else
            {
                continue
            }
            
            if value != truncateTowardZero(value)
            {
                hasFractional = true
                break
            }
        }
        
        XCTAssertTrue(hasFractional)
    }
    
    
    
    // MARK: - Shrinking
    
    func testShrinkingZero()
    {
        XCTAssertEqual(Decimal.zero.shrink(), [])
    }
    
    
    
    func testShrinkingNaN()
    {
        XCTAssertEqual(Decimal.nan.shrink(), [0])
    }
    
    
    
    func testShrinkingPositiveFractionalTruncation()
    {
        let value       : Decimal       = .init(string: "99.75")!
        let truncated   : Decimal       = 99
        let candidates  : [Decimal]     = value.shrink()
        
        XCTAssertTrue(candidates.count >= 2)
        XCTAssertEqual(candidates[0], 0)
        XCTAssertEqual(candidates[1], truncated)
    }
    
    
    
    func testShrinkingNegativeFractionalTruncation()
    {
        let value       : Decimal       = .init(string: "-99.75")!
        let truncated   : Decimal       = -99
        let candidates  : [Decimal]     = value.shrink()
        
        XCTAssertTrue(candidates.count >= 2)
        XCTAssertEqual(candidates[0], 0)
        XCTAssertEqual(candidates[1], truncated)
    }
    
    
    
    func testShrinkingCuratedValues()
    {
        let values: [Decimal] =
        [
            1,
            -1,
            Decimal(string: "0.75")!,
            Decimal(string: "99.99")!,
            1001,
            Decimal(string: "0.5")!,
            -0.5
        ]
        
        for value in values
        {
            validateShrinkCandidates(of: value)
        }
    }
    
    
    
    func testShrinkingCandidatesDistinctFromOriginal()
    {
        for _ in 0..<1000
        {
            let value = Decimal.arbitrary(using: .random)
            
            for candidate in value.shrink()
            {
                XCTAssertNotEqual(candidate, value)
            }
        }
    }
    
    
    
    func testShrinkingHalvingProducesIntermediateSteps()
    {
        let value       : Decimal       = 1001
        let candidates  : [Decimal]     = value.shrink()
        
        XCTAssertTrue(candidates.contains(500))
    }
    
    
    
    func testShrinkingHalfProducesOnlyTarget()
    {
        /// The halving loop termiantes when the gap is not greater than
        /// `0.5`. For a value of exactly `0.5`, the truncated value (`0`)
        /// is the same as the target, so halving starts from `0.5` itself.
        /// Since the gap is exactly `0.5`, no intermediate values are produced.
        
        let positive: [Decimal] = Decimal(string: "0.5")!.shrink()
        
        XCTAssertEqual(positive, [0])
        
        let negative: [Decimal] = Decimal(string: "-0.5")!.shrink()
        
        XCTAssertEqual(negative, [0])
    }
}



// MARK: - Support

extension DecimalArbitraryTests
{
    /// Truncates the given value toward zero.
    /// - Parameter value: The value to truncate.
    /// - Returns: The truncated value.
    private func truncateTowardZero(
        _ value: Decimal
    ) -> Decimal
    {
        var rounded : Decimal   = .init()
        var mutable : Decimal   = value
        
        let roundingMode: NSDecimalNumber.RoundingMode
            = value >= 0 ? .down : .up
        
        NSDecimalRound(
            &rounded,
            &mutable,
            0,
            roundingMode
        )
        
        return rounded
    }
    
    
    
    /// Validates the correctness of the shrink candidates of the given value.
    ///
    /// - Precondition: `value` must must be non-NaN and non-zero.
    ///
    /// - Parameter value: The value to evaluate.
    private func validateShrinkCandidates(
        of value: Decimal
    )
    {
        precondition(
            !value.isNaN && value != 0,
            "value is must be non-NaN and non-zero"
        )
        
        let candidates: [Decimal] = value.shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, 0)
        
        for candidate in candidates
        {
            XCTAssertFalse(candidate.isNaN)
            
            if value > 0
            {
                XCTAssertGreaterThanOrEqual(candidate, 0)
                XCTAssertLessThan(candidate, value)
            }
            else
            {
                XCTAssertLessThanOrEqual(candidate, 0)
                XCTAssertGreaterThan(candidate, value)
            }
        }
    }
    
    
    
    // MARK: - Decimal
    
    func testMutateNaNFallsBackToArbitrary()
    {
        var hasNaN      : Bool  = false
        var hasFinite   : Bool  = false
        
        for _ in 0..<1000
        {
            let mutated = Decimal.nan.mutate(using: .random)
            
            if mutated.isNaN
            {
                hasNaN = true
            }
            else
            {
                hasFinite = true
            }
            
            if
                hasNaN,
                hasFinite
            {
                break
            }
        }
        
        XCTAssertTrue(hasNaN)
        XCTAssertTrue(hasFinite)
    }
    
    
    
    func testMutateFiniteProducesFinite()
    {
        for _ in 0..<1000
        {
            let value   : Decimal   = Decimal(42)
            let mutated : Decimal   = value.mutate(using: .random)
            
            XCTAssertFalse(mutated.isNaN)
        }
    }
    
    
    
    func testMutateOffsetBoundedBySize()
    {
        let size: Int = 5
        
        for _ in 0..<1000
        {
            let value = Decimal.arbitrary(using: .random)
            
            guard !value.isNaN
            else
            {
                continue
            }
            
            let mutated: Decimal = value.mutate(using: .randomSeed(size: size))
            
            let maxDelta    : Decimal   = Decimal(max(1, size))
            let offset      : Decimal   = abs(mutated - value)
            
            XCTAssertLessThanOrEqual(offset, maxDelta)
        }
    }
    
    
    
    func testMutateProducesBothDirections()
    {
        let value       : Decimal   = Decimal(50)
        var hasSmaller  : Bool      = false
        var hasLarger   : Bool      = false
        
        for _ in 0..<1000
        {
            let mutated = Decimal.nan.mutate(using: .random)
            
            if mutated < value
            {
                hasSmaller = true
            }
            else if mutated > value
            {
                hasLarger = true
            }
            
            if
                hasSmaller,
                hasLarger
            {
                break
            }
        }
        
        XCTAssertTrue(hasSmaller)
        XCTAssertTrue(hasLarger)
    }
}
