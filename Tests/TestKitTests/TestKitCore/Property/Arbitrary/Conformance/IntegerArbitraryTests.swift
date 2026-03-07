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



internal final class IntegerArbitraryTests: TestKitCase
{
    // MARK: - Generation
    
    func testIntGeneration()
    {
        validateGeneration(of: Int.self)
    }
    
    
    
    func testInt8Generation()
    {
        validateGeneration(of: Int8.self)
    }
    
    
    
    func testInt16Generation()
    {
        validateGeneration(of: Int16.self)
    }
    
    
    
    func testInt32Generation()
    {
        validateGeneration(of: Int32.self)
    }
    
    
    
    func testInt64Generation()
    {
        validateGeneration(of: Int64.self)
    }
    
    
    
    func testUIntGeneration()
    {
        validateGeneration(of: UInt.self)
    }
    
    
    
    func testUInt8Generation()
    {
        validateGeneration(of: UInt8.self)
    }
    
    
    
    func testUInt16Generation()
    {
        validateGeneration(of: UInt16.self)
    }
    
    
    
    func testUInt32Generation()
    {
        validateGeneration(of: UInt32.self)
    }
    
    
    
    func testUInt64Generation()
    {
        validateGeneration(of: UInt64.self)
    }
    
    
    
    // MARK: - Shrinking
    
    func testIntShrinking()
    {
        validateShrinking(of: Int.self)
    }
    
    
    
    func testInt8Shrinking()
    {
        validateShrinking(of: Int8.self)
    }
    
    
    
    func testInt16Shrinking()
    {
        validateShrinking(of: Int16.self)
    }
    
    
    
    func testInt32Shrinking()
    {
        validateShrinking(of: Int32.self)
    }
    
    
    
    func testInt64Shrinking()
    {
        validateShrinking(of: Int64.self)
    }
    
    
    
    func testUIntShrinking()
    {
        validateShrinking(of: UInt.self)
    }
    
    
    
    func testUInt8Shrinking()
    {
        validateShrinking(of: UInt8.self)
    }
    
    
    
    func testUInt16Shrinking()
    {
        validateShrinking(of: UInt16.self)
    }
    
    
    
    func testUInt32Shrinking()
    {
        validateShrinking(of: UInt32.self)
    }
    
    
    
    func testUInt64Shrinking()
    {
        validateShrinking(of: UInt64.self)
    }
    
    
    
    // MARK: - Mutation
    
    func testIntMutation()
    {
        validateMutation(of: Int.self)
    }
    
    
    
    func testInt8Mutation()
    {
        validateMutation(of: Int8.self)
    }
    
    
    
    func testInt16Mutation()
    {
        validateMutation(of: Int16.self)
    }
    
    
    
    func testInt32Mutation()
    {
        validateMutation(of: Int32.self)
    }
    
    
    
    func testInt64Mutation()
    {
        validateMutation(of: Int64.self)
    }
    
    
    
    func testUIntMutation()
    {
        validateMutation(of: UInt.self)
    }
    
    
    
    func testUInt8Mutation()
    {
        validateMutation(of: UInt8.self)
    }
    
    
    
    func testUInt16Mutation()
    {
        validateMutation(of: UInt16.self)
    }
    
    
    
    func testUInt32Mutation()
    {
        validateMutation(of: UInt32.self)
    }
    
    
    
    func testUInt64Mutation()
    {
        validateMutation(of: UInt64.self)
    }
}



// MARK: - Support

extension IntegerArbitraryTests
{
    // MARK: Generation support
    
    /// Validates arbitrary value generation of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateGeneration<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        assertArbitraryDeterminism(of: type)
        validateSizeZeroProduction(of: type)
        validateSizeBounds(of: type)
        validateSignedValueProduction(of: type)
        validateValueBounds(of: type)
    }
    
    
    
    /// Validates that a size of zero produces arbitrary values of zero.
    /// - Parameter type: The type to evaluate.
    private func validateSizeZeroProduction<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        for _ in 0..<1000
        {
            XCTAssertEqual(T.arbitrary(using: .randomZeroSize), 0)
        }
    }
    
    
    
    /// Validates that arbitrary values of the given type respect the expected
    /// size bounds.
    /// - Parameter type: The type to evaluate.
    private func validateSizeBounds<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .randomSeed(size: 10))
            
            XCTAssertGreaterThanOrEqual(value, T.isSigned ? -10 : 0)
            XCTAssertLessThanOrEqual(value, 10)
        }
    }
    
    
    
    /// Validates that arbitrary values of the given type produce values of
    /// the appropriate sign.
    /// - Parameter type: The type to evaluate.
    private func validateSignedValueProduction<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
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
        
        XCTAssertTrue(hasPositive)
        
        if T.isSigned
        {
            XCTAssertTrue(hasNegative)
        }
        else
        {
            XCTAssertFalse(hasNegative)
        }
    }
    
    
    
    /// Validates that arbitrary values of the given type remain within the
    /// type's representable range when the size exceeds that range.
    /// - Parameter type: The type to evaluate.
    private func validateValueBounds<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        let typeMax = Int(clamping: T.max)
        
        guard typeMax < Int.max
        else
        {
            return
        }
        
        let lowerBound  : T     = T.isSigned ? T(clamping: -typeMax) : 0
        let upperBound  : T     = T(clamping: typeMax)
        
        for _ in 0..<1000
        {
            let value = T.arbitrary(using: .randomSeed(size: typeMax * 2))
            
            XCTAssertGreaterThanOrEqual(value, lowerBound)
            XCTAssertLessThanOrEqual(value, upperBound)
        }
    }
    
    
    
    // MARK: Shrinking support
    
    /// Validates the shrink candidates of the given type.
    /// - Parameter type: The type to test.
    private func validateShrinking<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        validateZeroOneShrinking(of: type)
        validateMinValueShrinking(of: type)
        validateMaxValueShrinking(of: type)
        
        validateShrinkCandidates(of: T(1))
        validateShrinkCandidates(of: T(50))
        
        if T.isSigned
        {
            validateShrinkCandidates(of: T(-1))
            validateShrinkCandidates(of: T(-7))
        }
    }
    
    
    
    /// Validates the shrink candidates of `0` and `1` as the given type.
    /// - Parameter type: The type to evaluate.
    private func validateZeroOneShrinking<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        /// 0 always shrinks to the empty array.
        /// ±1 shrinks to `[0]`, since halving ±1 yields 0.
        var expected: [T : [T]] =
        [
            (0 as T)    : [],
            (1 as T)    : [0]
        ]
        
        if T.isSigned
        {
            expected[(-1 as T)] = [0]
        }
        
        for (value, candidates) in expected
        {
            XCTAssertEqual(value.shrink(), candidates)
        }
    }
    
    
    
    /// Validates the correctness of the shrink candidates of the minimum
    /// representable value of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateMinValueShrinking<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        guard T.min != 0
        else
        {
            return
        }
        
        let candidates: [T] = T.min.shrink()
        
        XCTAssertTrue(candidates.count > 1)
        XCTAssertEqual(candidates.first, 0)
        
        for candidate in candidates
        {
            XCTAssertGreaterThan(candidate, T.min)
        }
    }
    
    
    
    /// Validates the correctness of the shrink candidates of the maximum
    /// representable value of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateMaxValueShrinking<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        let candidates: [T] = T.max.shrink()
        
        XCTAssertTrue(candidates.count > 1)
        XCTAssertEqual(candidates.first, 0)
        XCTAssertEqual(candidates.last, T.max - 1)
    }
    
    
    
    /// Validates the correctness of the shrink candidates of the given value.
    ///
    /// - Precondition: `value` must not be `T.min` for signed types, since
    /// `T.min` has no positive counterpart and the attempted validation of the
    /// last candidate would not apply. Use ``validateMinValueShrinking(of:)``
    /// to test `T.min`.
    ///
    /// - Parameter value: The value to evaluate.
    private func validateShrinkCandidates<T>(
        of value: T
    ) where T : Arbitrary & FixedWidthInteger
    {
        precondition(
            !(T.isSigned && value == T.min),
            "value must not be T.min for signed types"
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
        
        if value > 0
        {
            XCTAssertEqual(candidates.last, value - 1)
        }
        else
        {
            XCTAssertEqual(candidates.last, value + 1)
        }
    }
    
    
    
    // MARK: Mutation support
    
    /// Validates mutation of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateMutation<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        validateMutateSizeZeroBounds(of: type)
        validateMutateProducesDifferentValues(of: type)
        validateMutateOverflowClamping(of: type)
        validateMutateSizeScaling(of: type)
    }
    
    
    
    /// Validates that at size `0`, mutation perturbs by at most `±1`.
    ///
    /// At size `0`, `maxDelta` is `max(1, 0) = 1`, so the delta is in the
    /// range `-1...1`. The mutated value must be within one step of the input.
    ///
    /// - Parameter type: The type to evaluate.
    private func validateMutateSizeZeroBounds<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        let value = T(clamping: 10)
        
        for _ in 0..<1000
        {
            let context : GenerationContext     = .randomSeed(size: 0)
            let mutated : T                     = value.mutate(using: context)
            
            let distance: Int64 = abs(Int64(mutated) - Int64(value))
            
            XCTAssertLessThanOrEqual(distance, 1)
        }
    }
    
    
    
    /// Validates that mutation produces values different from the input.
    /// - Parameter type: The type to evaluate.
    private func validateMutateProducesDifferentValues<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        let value           : T     = T(clamping: 50)
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
    
    
    
    /// Validates that mutation at type boundaries produces clamped values.
    ///
    /// For all types, this verifies that `T.max` and `T.min` at large sizes
    /// produce clamped values. For amsll types where `T.max` is at most
    /// `Int16.max`, this also verifies that the clamped boundary value is
    /// produced, confirming that the overflow is handled by clamping rather
    /// than by wrapping.
    ///
    /// - Parameter type: The type to evaluate.
    private func validateMutateOverflowClamping<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let context     = GenerationContext.randomSeed(size: 10)
            let maxMutated  = T.max.mutate(using: context)
            let minMutated  = T.min.mutate(using: context)
            
            XCTAssertGreaterThanOrEqual(maxMutated, T.min)
            XCTAssertLessThanOrEqual(maxMutated, T.max)
            XCTAssertGreaterThanOrEqual(minMutated, T.min)
            XCTAssertLessThanOrEqual(minMutated, T.max)
        }
        
        guard T.max <= T(clamping: Int16.max)
        else
        {
            return
        }
        
        var hasMaxClamp : Bool  = false
        var hasMinClamp : Bool  = false
        
        for _ in 0..<1000
        {
            let maxContext  = GenerationContext.randomSeed(size: 100)
            let minContext  = GenerationContext.randomSeed(size: 100)
            
            if T.max.mutate(using: maxContext) == .max
            {
                hasMaxClamp = true
            }
            
            if T.min.mutate(using: minContext) == .min
            {
                hasMinClamp = true
            }
            
            if
                hasMaxClamp,
                hasMinClamp
            {
                break
            }
        }
        
        XCTAssertTrue(hasMaxClamp)
        XCTAssertTrue(hasMinClamp)
    }
    
    
    
    /// Validates that mutation magnitude scales with context size.
    ///
    /// The average absolute deviation from the input at a large size must
    /// exceed the average at a small size.
    ///
    /// - Parameter type: The type to evaluate.
    private func validateMutateSizeScaling<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        let value       : T         = T(clamping: 50)
        var smallTotal  : Double    = 0
        var largeTotal  : Double    = 0
        
        for _ in 0..<1000
        {
            let smallContext    = GenerationContext.randomSeed(size: 1)
            let largeContext    = GenerationContext.randomSeed(size: 50)
            
            let smallMutated    : T     = value.mutate(using: smallContext)
            let largeMutated    : T     = value.mutate(using: largeContext)
            
            smallTotal += abs(Double(Int64(smallMutated) - Int64(value)))
            largeTotal += abs(Double(Int64(largeMutated) - Int64(value)))
        }
        
        XCTAssertGreaterThan(largeTotal, smallTotal)
    }
}
