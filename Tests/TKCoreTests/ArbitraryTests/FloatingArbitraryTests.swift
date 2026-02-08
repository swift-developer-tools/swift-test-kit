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



internal final class FloatingArbitraryTests: XCTestCaseStopOnFail
{
    // MARK: - Generation
    
    func testDoubleGeneration() throws
    {
        testGeneration(of: Double.self)
    }
    
    
    
    func testFloatGeneration() throws
    {
        testGeneration(of: Float.self)
    }
    
    
    
    func testFloat16Generation() throws
    {
        testGeneration(of: Float16.self)
    }
    
    
    
    // MARK: - Shrinking
    
    func testDoubleShrinking() throws
    {
        testShrinking(of: Double.self)
    }
    
    
    
    func testFloatShrinking() throws
    {
        testShrinking(of: Float.self)
    }
    
    
    
    func testFloat16Shrinking() throws
    {
        testShrinking(of: Float16.self)
    }
}



// MARK: - Extensions

private extension FloatingArbitraryTests
{
    // MARK: Generation support
    
    /// Validates arbitrary value generation of the given type.
    /// - Parameter type: The type to evaluate.
    func testGeneration<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        validateDeterminism(of: type)
        validateSizeZeroBounds(of: type)
        validateSizeBounds(of: type)
        validateSignedValueProduction(of: type)
        validateValueBounds(of: type)
        validateSpecialValueProduction(of: type)
        validateFractionalValueProduction(of: type)
    }
    
    
    
    /// Validates that arbitrary value generation of the given type is
    /// deterministic.
    /// - Parameter type: The type to evaluate.
    func validateDeterminism<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            let value1  = T.arbitrary(using: context1)
            let value2  = T.arbitrary(using: context2)
            
            if value1.isNaN
            {
                XCTAssertTrue(value2.isNaN)
            }
            else
            {
                XCTAssertEqual(value1, value2)
            }
        }
    }
    
    
    
    /// Validates that at size zero, non-special values are bounded by only
    /// the fractional component (`-1...1`).
    /// - Parameter type: The type to evaluate.
    func validateSizeZeroBounds<T>(
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
            
            /// At size zero, the integer part is zero. The fraction part is
            /// in the range `-1...1`. The total must also be in that range.
            XCTAssertGreaterThanOrEqual(value, -1)
            XCTAssertLessThanOrEqual(value, 1)
        }
    }
    
    
    
    /// Validates that non-special values respect the expected size bounds.
    /// - Parameter type: The type to evaluate.
    func validateSizeBounds<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        let size    : Int   = 10
        let bound   : T     = T(size) + 1
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let value = T.arbitrary(using: context)
            
            guard
                !value.isNaN,
                !value.isInfinite
            else
            {
                continue
            }
            
            /// The integer part is in the range `-size...size`, and the
            /// fractional part is in the range `-1...1`. The total bound
            /// must be `size + 1`.
            XCTAssertGreaterThanOrEqual(value, -bound)
            XCTAssertLessThanOrEqual(value, bound)
        }
    }
    
    
    
    /// Validates that arbitrary values of the given type produce both
    /// positive and negative values.
    /// - Parameter type: The type to evaluate.
    func validateSignedValueProduction<T>(
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
    func validateValueBounds<T>(
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
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   typeMax * 2
            )
            
            let value = T.arbitrary(using: context)
            
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
    func validateSpecialValueProduction<T>(
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
    func validateFractionalValueProduction<T>(
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
    func testShrinking<T>(
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
    func validateZeroShrinking<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        let zero = T(0)
        
        XCTAssertEqual(zero.shrink(), [])
    }
    
    
    
    /// Validates that special values shrink to `[0]`.
    /// - Parameter type: The type to evaluate.
    func validateSpecialValueShrinking<T>(
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
    func validateFractionalTruncation<T>(
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
    func validateShrinkCandidates<T>(
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
}
