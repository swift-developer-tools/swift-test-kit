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



internal final class RangeIntegerArbitraryTests: XCTestCaseStopOnFail
{
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
        assertArbitraryDeterminism(of: type)
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
        for _ in 0..<1000
        {
            let range = R.arbitrary(using: .randomZeroSize)
            
            XCTAssertEqual(range.lowerBound, 0)
            XCTAssertEqual(range.upperBound, 0)
        }
    }
    
    
    
    /// Validates that arbitrary values of the given type respect the expected
    /// size bounds.
    /// - Parameter type: The type to evaluate.
    private func validateSizeBounds<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & FixedWidthInteger
    {
        let size    : Int       = 10
        let bound   : R.Bound   = R.Bound(clamping: size)
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let range = R.arbitrary(using: context)
            
            if R.Bound.isSigned
            {
                XCTAssertGreaterThanOrEqual(range.lowerBound, bound * -1)
            }
            else
            {
                XCTAssertGreaterThanOrEqual(range.lowerBound, 0)
            }
            
            XCTAssertLessThanOrEqual(range.upperBound, bound)
        }
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
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   typeMax * 2
            )
            
            let range = R.arbitrary(using: context)
            
            XCTAssertGreaterThanOrEqual(range.lowerBound, lowerBound)
            XCTAssertLessThanOrEqual(range.upperBound, upperBound)
        }
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
}
