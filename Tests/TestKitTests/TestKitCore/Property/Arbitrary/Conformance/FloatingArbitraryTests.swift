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



internal final class FloatingArbitraryTests: TestKitCase
{
    // MARK: - Generation
    
    func testDoubleGeneration()
    {
        validateGeneration(of: Double.self)
    }
    
    
    
    func testFloatGeneration()
    {
        validateGeneration(of: Float.self)
    }
    
    
    
    func testFloat16Generation()
    {
        validateGeneration(of: Float16.self)
    }
    
    
    
    // MARK: - Shrinking
    
    func testDoubleShrinking()
    {
        validateShrinking(of: Double.self)
    }
    
    
    
    func testFloatShrinking()
    {
        validateShrinking(of: Float.self)
    }
    
    
    
    func testFloat16Shrinking()
    {
        validateShrinking(of: Float16.self)
    }
    
    
    
    // MARK: - Mutation
    
    func testDoubleMutation()
    {
        validateMutation(of: Double.self)
    }
    
    
    
    func testFloatMutation()
    {
        validateMutation(of: Float.self)
    }
    
    
    
    func testFloat16Mutation()
    {
        validateMutation(of: Float16.self)
    }
}



// MARK: - Support

extension FloatingArbitraryTests
{
    // MARK: Generation support
    
    /// Validates arbitrary value generation of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateGeneration<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        assertArbitraryDeterminism(of: type)
        validateSizeZeroBounds(of: type)
        validateSizeBounds(of: type)
        validateSignedValueProduction(of: type)
        validateValueBounds(of: type)
        validateSpecialValueProduction(of: type)
        validateFractionalValueProduction(of: type)
    }
    
    
    
    /// Validates that at size zero, non-special values are bounded by only
    /// the fractional component (`-1...1`).
    /// - Parameter type: The type to evaluate.
    private func validateSizeZeroBounds<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .randomZeroSize)
            
            guard
                !value.isNaN,
                !value.isInfinite
            else
            {
                continue
            }
            
            /// At size zero, the integer component is zero. The fraction
            /// component is in the range `-1...1`. The total must also be in
            /// that range.
            XCTAssertGreaterThanOrEqual(value, -1)
            XCTAssertLessThanOrEqual(value, 1)
        }
    }
    
    
    
    /// Validates that non-special values respect the expected size bounds.
    /// - Parameter type: The type to evaluate.
    private func validateSizeBounds<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        let size    : Int   = 10
        let bound   : T     = T(size) + 1
        
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .randomSeed(size: size))
            
            guard
                !value.isNaN,
                !value.isInfinite
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
    
    
    
    /// Validates that arbitrary values of the given type produce both
    /// positive and negative values.
    /// - Parameter type: The type to evaluate.
    private func validateSignedValueProduction<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        var hasNegative : Bool  = false
        var hasPositive : Bool  = false
        
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .random)
            
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
    
    
    
    /// Validates that arbitrary values of the given type remain within the
    /// type's representable range when the size exceeds that range.
    /// - Parameter type: The type to evaluate.
    private func validateValueBounds<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        guard T.greatestFiniteMagnitude < T(Int.max)
        else
        {
            return
        }
        
        let typeMax = Int(T.greatestFiniteMagnitude)
        
        var hasLargeValue: Bool = false
        
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .randomSeed(size: typeMax * 2))
            
            guard
                !value.isNaN,
                !value.isInfinite
            else
            {
                continue
            }
            
            XCTAssertLessThanOrEqual(abs(value), T.greatestFiniteMagnitude)
            
            if abs(value) > T(typeMax / 2)
            {
                hasLargeValue = true
            }
        }
        
        /// The clamped size must still produce large values.
        XCTAssertTrue(hasLargeValue)
    }
    
    
    
    /// Validates that special values are generated over many iterations.
    /// - Parameter type: The type to evaluate.
    private func validateSpecialValueProduction<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        var hasNaN          : Bool  = false
        var hasInfinity     : Bool  = false
        var hasNegativeZero : Bool  = false
        
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .random)
            
            if value.isNaN
            {
                hasNaN = true
            }
            
            if value.isInfinite
            {
                hasInfinity = true
            }
            
            if
                value.isZero,
                value.sign == .minus
            {
                hasNegativeZero = true
            }
            
            if
                hasNaN,
                hasInfinity,
                hasNegativeZero
            {
                break
            }
        }
        
        XCTAssertTrue(hasNaN)
        XCTAssertTrue(hasInfinity)
        XCTAssertTrue(hasNegativeZero)
    }
    
    
    
    /// Validates that arbitrary values of the given type include non-integer
    /// (fractional) values.
    /// - Parameter type: The type to evaluate.
    private func validateFractionalValueProduction<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        var hasFractional: Bool = false
        
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .random)
            
            guard
                !value.isNaN,
                !value.isInfinite
            else
            {
                continue
            }
            
            if value != value.rounded(.towardZero)
            {
                hasFractional = true
                break
            }
        }
        
        XCTAssertTrue(hasFractional)
    }
    
    
    
    // MARK: Shrinking support
    
    /// Validates the shrink candidates of the given type.
    /// - Parameter type: The type to test.
    private func validateShrinking<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        validateZeroShrinking(of: type)
        validateSpecialValueShrinking(of: type)
        validateFractionalTruncation(of: type)
        validateShrinkCandidates(of: T(37.5))
        validateShrinkCandidates(of: T(1))
        validateShrinkCandidates(of: T(-1))
        validateShrinkCandidates(of: T(-7.5))
    }
    
    
    
    /// Validates that zero does not shrink.
    /// - Parameter type: The type to evaluate.
    private func validateZeroShrinking<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        let zero = T(0)
        
        XCTAssertEqual(zero.shrink(), [])
    }
    
    
    
    /// Validates that special values shrink to `[0]`.
    /// - Parameter type: The type to evaluate.
    private func validateSpecialValueShrinking<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        for special in T.specialValues
        {
            let candidates: [T] = special.shrink()
            
            if
                special.isZero,
                special.sign == .minus
            {
                XCTAssertEqual(candidates, [])
            }
            else
            {
                XCTAssertEqual(candidates, [0])
            }
        }
    }
    
    
    
    /// Validates that a fraction value's shrink candidates include the
    /// truncated (integer) form as the second candidate.
    /// - Parameter type: The type to evaluate.
    private func validateFractionalTruncation<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        /// 24.75 is representable in all three floating-point types as
        /// the sum of powers of 2: 0.25 + 0.50 + 2 + 4 + 8 + 10.
        /// This avoids any precision ambiguity.
        let value       : T     = T(24.75)
        let truncated   : T     = T(24)
        let candidates  : [T]   = value.shrink()
        
        XCTAssertTrue(candidates.count >= 2)
        XCTAssertEqual(candidates[0], 0)
        XCTAssertEqual(candidates[1], truncated)
    }
    
    
    
    /// Validates the correctness of the shrink candidates of the given value.
    ///
    /// - Precondition: `value` must must be finite, non-NaN, and non-zero.
    ///
    /// - Parameter value: The value to evaluate.
    private func validateShrinkCandidates<T>(
        of value: T
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        precondition(
            value.isFinite && !value.isNaN && !value.isZero,
            "value must be finite, non-NaN, and non-zero"
        )
        
        let candidates: [T] = value.shrink()
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, 0)
        
        for candidate in candidates
        {
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
    
    
    
    // MARK: Mutation support
    
    /// Validates mutation of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateMutation<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        validateMutateFiniteInputProducesFiniteOutput(of: type)
        validateMutateNonFiniteInputFallback(of: type)
        validateMutateProducesDifferentValues(of: type)
        validateMutateSizeScaling(of: type)
    }
    
    
    
    /// Validates that mutating a finite value always produces a finite value.
    /// - Parameter type: The type to evaluate.
    private func validateMutateFiniteInputProducesFiniteOutput<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        let values: [T] =
        [
            0,
            1,
            -1,
            T(52.5),
            T(-52.5)
        ]
        
        for value in values
        {
            for _ in 0..<1000
            {
                let mutated: T = value.mutate(using: .random)
                
                XCTAssertTrue(mutated.isFinite)
                XCTAssertFalse(mutated.isNaN)
            }
        }
    }
    
    
    
    /// Validates that mutating a non-finite value produces finite values at
    /// least some of the time.
    /// - Parameter type: The type to evaluate.
    private func validateMutateNonFiniteInputFallback<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        let values: [T] =
        [
            .infinity,
            -.infinity,
            .nan
        ]
        
        for value in values
        {
            var hasFinite: Bool = false
            
            for _ in 0..<1000
            {
                let mutated: T = value.mutate(using: .random)
                
                if
                    mutated.isFinite,
                    !mutated.isNaN
                {
                    hasFinite = true
                    break
                }
            }
            
            XCTAssertTrue(hasFinite)
        }
    }
    
    
    
    /// Validates that mutation produces values different from the input.
    /// - Parameter type: The type to evaluate.
    private func validateMutateProducesDifferentValues<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        let value           : T     = T(10)
        var hasDifferent    : Bool  = false
        
        for _ in 0..<1000
        {
            let context : GenerationContext     = .randomSeed(size: 10)
            let mutated : T                     = value.mutate(using: context)
            
            if mutated != value
            {
                hasDifferent = true
                break
            }
        }
        
        XCTAssertTrue(hasDifferent)
    }
    
    
    
    /// Validates that mutation magnitude scales with context size.
    ///
    /// The average absolute deviation from the input at a large size must
    /// exceed the average at a small size.
    ///
    /// - Parameter type: The type to evaluate.
    private func validateMutateSizeScaling<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        let value       : T         = T(10)
        var smallTotal  : Double    = 0
        var largeTotal  : Double    = 0
        
        for _ in 0..<1000
        {
            let smallContext = GenerationContext.randomSeed(size: 1)
            let largeContext = GenerationContext.randomSeed(size: 50)
            
            let smallMutated    : T     = value.mutate(using: smallContext)
            let largeMutated    : T     = value.mutate(using: largeContext)
            
            smallTotal += abs(Double(smallMutated) - Double(value))
            largeTotal += abs(Double(largeMutated) - Double(value))
        }
        
        XCTAssertGreaterThan(largeTotal, smallTotal)
    }
}
