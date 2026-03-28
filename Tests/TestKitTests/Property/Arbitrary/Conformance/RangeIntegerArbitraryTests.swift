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



internal final class RangeIntegerArbitraryTests: TestKitCase
{
    // MARK: - Determinism
    
    func testClosedRangeIntDeterminism()
    {
        assertArbitraryDeterminism(of: ClosedRange<Int>.self)
    }
    
    
    
    func testClosedRangeInt8Determinism()
    {
        assertArbitraryDeterminism(of: ClosedRange<Int8>.self)
    }
    
    
    
    func testClosedRangeInt16Determinism()
    {
        assertArbitraryDeterminism(of: ClosedRange<Int16>.self)
    }
    
    
    
    func testClosedRangeInt32Determinism()
    {
        assertArbitraryDeterminism(of: ClosedRange<Int32>.self)
    }
    
    
    
    func testClosedRangeInt64Determinism()
    {
        assertArbitraryDeterminism(of: ClosedRange<Int64>.self)
    }
    
    
    
    func testClosedRangeUIntDeterminism()
    {
        assertArbitraryDeterminism(of: ClosedRange<UInt>.self)
    }
    
    
    
    func testClosedRangeUInt8Determinism()
    {
        assertArbitraryDeterminism(of: ClosedRange<UInt8>.self)
    }
    
    
    
    func testClosedRangeUInt16Determinism()
    {
        assertArbitraryDeterminism(of: ClosedRange<UInt16>.self)
    }
    
    
    
    func testClosedRangeUInt32Determinism()
    {
        assertArbitraryDeterminism(of: ClosedRange<UInt32>.self)
    }
    
    
    
    func testClosedRangeUInt64Determinism()
    {
        assertArbitraryDeterminism(of: ClosedRange<UInt64>.self)
    }
    
    
    
    func testRangeIntDeterminism()
    {
        assertArbitraryDeterminism(of: Range<Int>.self)
    }
    
    
    
    func testRangeInt8Determinism()
    {
        assertArbitraryDeterminism(of: Range<Int8>.self)
    }
    
    
    
    func testRangeInt16Determinism()
    {
        assertArbitraryDeterminism(of: Range<Int16>.self)
    }
    
    
    
    func testRangeInt32Determinism()
    {
        assertArbitraryDeterminism(of: Range<Int32>.self)
    }
    
    
    
    func testRangeInt64Determinism()
    {
        assertArbitraryDeterminism(of: Range<Int64>.self)
    }
    
    
    
    func testRangeUIntDeterminism()
    {
        assertArbitraryDeterminism(of: Range<UInt>.self)
    }
    
    
    
    func testRangeUInt8Determinism()
    {
        assertArbitraryDeterminism(of: Range<UInt8>.self)
    }
    
    
    
    func testRangeUInt16Determinism()
    {
        assertArbitraryDeterminism(of: Range<UInt16>.self)
    }
    
    
    
    func testRangeUInt32Determinism()
    {
        assertArbitraryDeterminism(of: Range<UInt32>.self)
    }
    
    
    
    func testRangeUInt64Determinism()
    {
        assertArbitraryDeterminism(of: Range<UInt64>.self)
    }
    
    
    
    // MARK: - Generation
    
    func testClosedRangeIntGeneration()
    {
        validateGeneration(of: ClosedRange<Int>.self)
    }
    
    
    
    func testClosedRangeInt8Generation()
    {
        validateGeneration(of: ClosedRange<Int8>.self)
    }
    
    
    
    func testClosedRangeInt16Generation()
    {
        validateGeneration(of: ClosedRange<Int16>.self)
    }
    
    
    
    func testClosedRangeInt32Generation()
    {
        validateGeneration(of: ClosedRange<Int32>.self)
    }
    
    
    
    func testClosedRangeInt64Generation()
    {
        validateGeneration(of: ClosedRange<Int64>.self)
    }
    
    
    
    func testClosedRangeUIntGeneration()
    {
        validateGeneration(of: ClosedRange<UInt>.self)
    }
    
    
    
    func testClosedRangeUInt8Generation()
    {
        validateGeneration(of: ClosedRange<UInt8>.self)
    }
    
    
    
    func testClosedRangeUInt16Generation()
    {
        validateGeneration(of: ClosedRange<UInt16>.self)
    }
    
    
    
    func testClosedRangeUInt32Generation()
    {
        validateGeneration(of: ClosedRange<UInt32>.self)
    }
    
    
    
    func testClosedRangeUInt64Generation()
    {
        validateGeneration(of: ClosedRange<UInt64>.self)
    }
    
    
    
    func testRangeIntGeneration()
    {
        validateGeneration(of: Range<Int>.self)
    }
    
    
    
    func testRangeInt8Generation()
    {
        validateGeneration(of: Range<Int8>.self)
    }
    
    
    
    func testRangeInt16Generation()
    {
        validateGeneration(of: Range<Int16>.self)
    }
    
    
    
    func testRangeInt32Generation()
    {
        validateGeneration(of: Range<Int32>.self)
    }
    
    
    
    func testRangeInt64Generation()
    {
        validateGeneration(of: Range<Int64>.self)
    }
    
    
    
    func testRangeUIntGeneration()
    {
        validateGeneration(of: Range<UInt>.self)
    }
    
    
    
    func testRangeUInt8Generation()
    {
        validateGeneration(of: Range<UInt8>.self)
    }
    
    
    
    func testRangeUInt16Generation()
    {
        validateGeneration(of: Range<UInt16>.self)
    }
    
    
    
    func testRangeUInt32Generation()
    {
        validateGeneration(of: Range<UInt32>.self)
    }
    
    
    
    func testRangeUInt64Generation()
    {
        validateGeneration(of: Range<UInt64>.self)
    }
    
    
    
    // MARK: - Shrinking
    
    func testClosedRangeIntShrinking()
    {
        validateShrinking(of: ClosedRange<Int>.self)
    }
    
    
    
    func testClosedRangeInt8Shrinking()
    {
        validateShrinking(of: ClosedRange<Int8>.self)
    }
    
    
    
    func testClosedRangeInt16Shrinking()
    {
        validateShrinking(of: ClosedRange<Int16>.self)
    }
    
    
    
    func testClosedRangeInt32Shrinking()
    {
        validateShrinking(of: ClosedRange<Int32>.self)
    }
    
    
    
    func testClosedRangeInt64Shrinking()
    {
        validateShrinking(of: ClosedRange<Int64>.self)
    }
    
    
    
    func testClosedRangeUIntShrinking()
    {
        validateShrinking(of: ClosedRange<UInt>.self)
    }
    
    
    
    func testClosedRangeUInt8Shrinking()
    {
        validateShrinking(of: ClosedRange<UInt8>.self)
    }
    
    
    
    func testClosedRangeUInt16Shrinking()
    {
        validateShrinking(of: ClosedRange<UInt16>.self)
    }
    
    
    
    func testClosedRangeUInt32Shrinking()
    {
        validateShrinking(of: ClosedRange<UInt32>.self)
    }
    
    
    
    func testClosedRangeUInt64Shrinking()
    {
        validateShrinking(of: ClosedRange<UInt64>.self)
    }
    
    
    
    func testRangeIntShrinking()
    {
        validateShrinking(of: Range<Int>.self)
    }
    
    
    
    func testRangeInt8Shrinking()
    {
        validateShrinking(of: Range<Int8>.self)
    }
    
    
    
    func testRangeInt16Shrinking()
    {
        validateShrinking(of: Range<Int16>.self)
    }
    
    
    
    func testRangeInt32Shrinking()
    {
        validateShrinking(of: Range<Int32>.self)
    }
    
    
    
    func testRangeInt64Shrinking()
    {
        validateShrinking(of: Range<Int64>.self)
    }
    
    
    
    func testRangeUIntShrinking()
    {
        validateShrinking(of: Range<UInt>.self)
    }
    
    
    
    func testRangeUInt8Shrinking()
    {
        validateShrinking(of: Range<UInt8>.self)
    }
    
    
    
    func testRangeUInt16Shrinking()
    {
        validateShrinking(of: Range<UInt16>.self)
    }
    
    
    
    func testRangeUInt32Shrinking()
    {
        validateShrinking(of: Range<UInt32>.self)
    }
    
    
    
    func testRangeUInt64Shrinking()
    {
        validateShrinking(of: Range<UInt64>.self)
    }
    
    
    
    // MARK: - Mutation
    
    func testClosedRangeIntMutation()
    {
        validateMutation(of: ClosedRange<Int>.self)
    }
    
    
    
    func testClosedRangeInt8Mutation()
    {
        validateMutation(of: ClosedRange<Int8>.self)
    }
    
    
    
    func testClosedRangeInt16Mutation()
    {
        validateMutation(of: ClosedRange<Int16>.self)
    }
    
    
    
    func testClosedRangeInt32Mutation()
    {
        validateMutation(of: ClosedRange<Int32>.self)
    }
    
    
    
    func testClosedRangeInt64Mutation()
    {
        validateMutation(of: ClosedRange<Int64>.self)
    }
    
    
    
    func testClosedRangeUIntMutation()
    {
        validateMutation(of: ClosedRange<UInt>.self)
    }
    
    
    
    func testClosedRangeUInt8Mutation()
    {
        validateMutation(of: ClosedRange<UInt8>.self)
    }
    
    
    
    func testClosedRangeUInt16Mutation()
    {
        validateMutation(of: ClosedRange<UInt16>.self)
    }
    
    
    
    func testClosedRangeUInt32Mutation()
    {
        validateMutation(of: ClosedRange<UInt32>.self)
    }
    
    
    
    func testClosedRangeUInt64Mutation()
    {
        validateMutation(of: ClosedRange<UInt64>.self)
    }
    
    
    
    func testRangeIntMutation()
    {
        validateMutation(of: Range<Int>.self)
    }
    
    
    
    func testRangeInt8Mutation()
    {
        validateMutation(of: Range<Int8>.self)
    }
    
    
    
    func testRangeInt16Mutation()
    {
        validateMutation(of: Range<Int16>.self)
    }
    
    
    
    func testRangeInt32Mutation()
    {
        validateMutation(of: Range<Int32>.self)
    }
    
    
    
    func testRangeInt64Mutation()
    {
        validateMutation(of: Range<Int64>.self)
    }
    
    
    
    func testRangeUIntMutation()
    {
        validateMutation(of: Range<UInt>.self)
    }
    
    
    
    func testRangeUInt8Mutation()
    {
        validateMutation(of: Range<UInt8>.self)
    }
    
    
    
    func testRangeUInt16Mutation()
    {
        validateMutation(of: Range<UInt16>.self)
    }
    
    
    
    func testRangeUInt32Mutation()
    {
        validateMutation(of: Range<UInt32>.self)
    }
    
    
    
    func testRangeUInt64Mutation()
    {
        validateMutation(of: Range<UInt64>.self)
    }
}



// MARK: - Support

extension RangeIntegerArbitraryTests
{
    // MARK: - Generation support
    
    /// Validates arbitrary value generation of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateGeneration<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        validateSizeZeroProduction(of: type)
        validateSizeBounds(of: type)
        validateBoundInvariant(of: type)
        validateSignedValueProduction(of: type)
        validateValueBounds(of: type)
    }
    
    
    
    /// Validates that a size of zero produces arbitrary values of zero.
    /// - Parameter type: The type to evaluate.
    private func validateSizeZeroProduction<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        let iterations  : Int   = 10_000
        var count       : Int   = 0
        
        for _ in 0..<iterations
        {
            let range = R.arbitrary(using: .randomZeroSize)
            
            if
                range.lowerBound == 0,
                range.upperBound == 0
            {
                count += 1
            }
        }
        
        /// 5% chance of special values for each bound.
        XCTAssertGreaterThan(count, Int(Double(iterations) * 0.90 * 0.85))
    }
    
    
    
    /// Validates that arbitrary values of the given type respect the expected
    /// size bounds.
    /// - Parameter type: The type to evaluate.
    private func validateSizeBounds<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        let iterations  : Int       = 10_000
        var count       : Int       = 0
        let size        : Int       = 10
        let bound       : R.Bound   = R.Bound(clamping: size)
        
        for _ in 0..<iterations
        {
            let range = R.arbitrary(using: .randomSeed(size: size))
            
            let lowerInBounds: Bool = R.Bound.isSigned
                ? range.lowerBound >= bound * -1
                : range.lowerBound >= 0
            
            let upperInBounds: Bool = range.upperBound <= bound
            
            if
                lowerInBounds,
                upperInBounds
            {
                count += 1
            }
        }
        
        /// 5% chance of special values for each bound.
        XCTAssertGreaterThan(count, Int(Double(iterations) * 0.90 * 0.85))
    }
    
    
    
    /// Validates the bounds of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateBoundInvariant<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let range = R.arbitrary(using: .random)
            
            XCTAssertLessThanOrEqual(range.lowerBound, range.upperBound)
        }
    }
    
    
    
    /// Validates that arbitrary values of the given type produce values of
    /// the appropriate sign.
    /// - Parameter type: The type to evaluate.
    private func validateSignedValueProduction<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        var hasNegativeLower    : Bool  = false
        var hasPositiveUpper    : Bool  = false
        
        for _ in 0..<1000
        {
            let range = R.arbitrary(using: .random)
            
            if range.lowerBound < 0
            {
                hasNegativeLower = true
            }
            
            if range.upperBound > 0
            {
                hasPositiveUpper = true
            }
            
            if
                hasNegativeLower,
                hasPositiveUpper
            {
                break
            }
        }
        
        XCTAssertTrue(hasPositiveUpper)
        
        if R.Bound.isSigned
        {
            XCTAssertTrue(hasNegativeLower)
        }
        else
        {
            XCTAssertFalse(hasNegativeLower)
        }
    }
    
    
    
    /// Validates that arbitrary values of the given type remain within the
    /// type's representable range when the size exceeds that range.
    /// - Parameter type: The type to evaluate.
    private func validateValueBounds<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        let typeMax = Int(clamping: R.Bound.max)
        
        guard typeMax < Int.max
        else
        {
            return
        }
        
        let lowerBound: R.Bound = R.Bound.isSigned
            ? R.Bound(clamping: -typeMax)
            : 0
        
        let upperBound: R.Bound = R.Bound(clamping: typeMax)
        
        let iterations  : Int   = 10_000
        var count       : Int   = 0
        
        for _ in 0..<iterations
        {
            let range = R.arbitrary(using: .randomSeed(size: typeMax * 2))
            
            if
                range.lowerBound >= lowerBound,
                range.upperBound <= upperBound
            {
                count += 1
            }
        }
        
        /// 5% chance of special values for each bound.
        XCTAssertGreaterThan(count, Int(Double(iterations) * 0.90 * 0.85))
    }
    
    
    
    // MARK: - Shrinking support
    
    /// Validates the shrink candidates of the given type.
    /// - Parameter type: The type to test.
    private func validateShrinking<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        validateZeroBoundsShrinking(of: type)
        validateCuratedCandidates(of: type)
        validateShrinkCandidates(of: R(lower: 0, upper: 5))
        validateShrinkCandidates(of: R(lower: 1, upper: 1))
        validateShrinkCandidates(of: R(lower: 2, upper: 7))
        validateShrinkCandidates(of: R(lower: 3, upper: 3))
        
        if R.Bound.isSigned
        {
            validateShrinkCandidates(of: R(lower: -5, upper: 10))
            validateShrinkCandidates(of: R(lower: -3, upper: -1))
            validateShrinkCandidates(of: R(lower: -1, upper: 1))
        }
    }
    
    
    
    /// Validates that a range with both bounds equal to zero produces no
    /// shrink candidates.
    /// - Parameter type: The type to test.
    private func validateZeroBoundsShrinking<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        let range = R(lower: 0, upper: 0)
        
        XCTAssertEqual(range.shrink(), [])
    }
    
    
    
    /// Validates the expected shrink candidates of specific ranges.
    /// - Parameter type: The type to test.
    private func validateCuratedCandidates<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        XCTAssertEqual(
            R(lower: 1, upper: 1).shrink(),
            [
                R(lower: 0, upper: 1),
                R(lower: 0, upper: 0)
            ]
        )
        
        
        
        XCTAssertEqual(
            R(lower: 2, upper: 7).shrink(),
            [
                R(lower: 0, upper: 7),
                R(lower: 1, upper: 7),
                R(lower: 2, upper: 4),
                R(lower: 2, upper: 6),
                R(lower: 0, upper: 0),
                R(lower: 0, upper: 4),
                R(lower: 0, upper: 6),
                R(lower: 1, upper: 4),
                R(lower: 1, upper: 6)
            ]
        )
        
        
        
        guard R.Bound.isSigned
        else
        {
            return
        }
        
        XCTAssertEqual(
            R(lower: -3, upper: -1).shrink(),
            [
                R(lower: -2, upper: -1),
                R(lower: -3, upper: 0),
                R(lower:  0, upper: 0),
                R(lower: -2, upper: 0)
            ]
        )
    }
    
    
    
    /// Validates the correctness of the shrink candidates of the given range.
    /// - Parameter range: The range to evaluate.
    private func validateShrinkCandidates<R>(
        of range: R
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        let candidates: [R] = range.shrink()
        
        for candidate in candidates
        {
            XCTAssertLessThanOrEqual(
                candidate.lowerBound,
                candidate.upperBound
            )
            
            XCTAssertNotEqual(candidate, range)
            
            let lowerCloser: Bool
                = abs(Int(candidate.lowerBound)) <= abs(Int(range.lowerBound))
            
            let upperCloser: Bool
                = abs(Int(candidate.upperBound)) <= abs(Int(range.upperBound))
            
            /// At least one bound must be closer to zero (or equal).
            XCTAssertTrue(lowerCloser || upperCloser)
        }
    }
    
    
    
    // MARK: - Mutation support
    
    /// Validates arbitrary mutation of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateMutation<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        let range = R(lower: 2, upper: 7)
        
        validateMutateBoundInvariant(of: range)
        validateMutateProducesDifferentValues(for: range)
        validateMutateSingleBoundChange(of: range)
        validateMutatePointRangeInvariant(of: R(lower: 5, upper: 5))
        validateMutateSizeScaling(of: range)
        validateMutateSizeZeroBounds(for: range)
        validateMutateBoundInvariant(of: R(lower: 0, upper: 0))
        validateMutateBoundInvariant(of: R(lower: 0, upper: 1))
        
        if R.Bound.isSigned
        {
            validateMutateBoundInvariant(of: R(lower: -3, upper: 3))
            validateMutatePointRangeInvariant(of: R(lower: -1, upper: -1))
        }
        else
        {
            validateMutatePointRangeInvariant(of: R(lower: 0, upper: 0))
        }
    }
    
    
    
    /// Validates the post-mutation bounds of the given range.
    /// - Parameter range: The range to evaluate.
    private func validateMutateBoundInvariant<R>(
        of range: R
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let mutated: R = range.mutate(using: .random)
            
            XCTAssertLessThanOrEqual(mutated.lowerBound, mutated.upperBound)
        }
    }
    
    
    
    /// Validates that mutation of the given range produces values different
    /// from the receiver.
    /// - Parameter range: The range to evaluate.
    private func validateMutateProducesDifferentValues<R>(
        for range: R
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        var hasDifferent: Bool = false
        
        for _ in 0..<1000
        {
            let mutated: R = range.mutate(using: .randomSeed(size: 10))
            
            if mutated != range
            {
                hasDifferent = true
                break
            }
        }
        
        XCTAssertTrue(hasDifferent)
    }
    
    
    
    /// Validates that at least one mutation of the given range changes only
    /// the lower bound and at least one mutation changes only the upper bound.
    /// - Parameter range: The range to evaluate.
    private func validateMutateSingleBoundChange<R>(
        of range: R
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        var hasUpperOnly    : Bool  = false
        var hasLowerOnly    : Bool  = false
        
        for _ in 0..<1000
        {
            let mutated: R = range.mutate(using: .randomSeed(size: 10))
            
            let upperChanged: Bool = mutated.upperBound != range.upperBound
            let lowerChanged: Bool = mutated.lowerBound != range.lowerBound
            
            if
                upperChanged,
                !lowerChanged
            {
                hasUpperOnly = true
            }
            
            if
                lowerChanged,
                !upperChanged
            {
                hasLowerOnly = true
            }
            
            if
                hasUpperOnly,
                hasLowerOnly
            {
                break
            }
        }
        
        XCTAssertTrue(hasUpperOnly)
        XCTAssertTrue(hasLowerOnly)
    }
    
    
    
    /// Validates that mutating the given point range maintains bound
    /// invariants.
    /// - Parameter range: The range to evaluate.
    private func validateMutatePointRangeInvariant<R>(
        of range: R
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        XCTAssertEqual(range.lowerBound, range.upperBound)
        
        for _ in 0..<1000
        {
            let mutated: R = range.mutate(using: .randomSeed(size: 10))
            
            XCTAssertLessThanOrEqual(mutated.lowerBound, mutated.upperBound)
        }
    }
    
    
    
    /// Validates that mutation magnitude scales with context size.
    ///
    /// The average total bound delta at a large size must exceed the average
    /// at a small size.
    ///
    /// - Parameter range: The range to evaluate.
    private func validateMutateSizeScaling<R>(
        of range: R
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        var smallTotal  : Double    = 0
        var largeTotal  : Double    = 0
        
        for _ in 0..<1000
        {
            let smallContext    = GenerationContext.randomSeed(size: 1)
            let largeContext    = GenerationContext.randomSeed(size: 50)
            
            let smallMutated    : R     = range.mutate(using: smallContext)
            let largeMutated    : R     = range.mutate(using: largeContext)
            
            smallTotal += abs(Double(
                Int64(smallMutated.lowerBound) - Int64(range.lowerBound)
            ))
            
            smallTotal += abs(Double(
                Int64(smallMutated.upperBound) - Int64(range.upperBound)
            ))
            
            largeTotal += abs(Double(
                Int64(largeMutated.lowerBound) - Int64(range.lowerBound)
            ))
            
            largeTotal += abs(Double(
                Int64(largeMutated.upperBound) - Int64(range.upperBound)
            ))
        }
        
        XCTAssertGreaterThan(largeTotal, smallTotal)
    }
    
    
    
    /// Validates that at size zero, each bound changes by at most `±1`.
    /// - Parameter range: The range to evaluate.
    private func validateMutateSizeZeroBounds<R>(
        for range: R
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let mutated: R = range.mutate(using: .randomZeroSize)
            
            let lowerDistance: Int64 = abs(
                Int64(mutated.lowerBound) - Int64(range.lowerBound)
            )
            
            let upperDistance: Int64 = abs(
                Int64(mutated.upperBound) - Int64(range.upperBound)
            )
            
            XCTAssertLessThanOrEqual(lowerDistance, 1)
            XCTAssertLessThanOrEqual(upperDistance, 1)
        }
    }
}
