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



internal final class RangeFloatingArbitraryTests: XCTestCaseStopOnFail
{
    // MARK: - Generation
    
    func testClosedRangeDoubleGeneration() throws
    {
        testGeneration(of: ClosedRange<Double>.self)
    }
    
    
    
    func testClosedRangeFloatGeneration() throws
    {
        testGeneration(of: ClosedRange<Float>.self)
    }
    
    
    
    func testClosedRangeFloat16Generation() throws
    {
        testGeneration(of: ClosedRange<Float16>.self)
    }
    
    
    
    // MARK: - Shrinking
    
    func testRangeDoubleShrinking() throws
    {
        testShrinking(of: Range<Double>.self)
    }
    
    
    
    func testRangeFloatShrinking() throws
    {
        testShrinking(of: Range<Float>.self)
    }
    
    
    
    func testRangeFloat16Shrinking() throws
    {
        testShrinking(of: Range<Float16>.self)
    }
}



// MARK: - Extensions

extension RangeFloatingArbitraryTests
{
    // MARK: - Generation support
    
    /// Validates arbitrary value generation of the given type.
    /// - Parameter type: The type to evaluate.
    private func testGeneration<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        validateDeterminism(of: type)
        validateSizeZeroProduction(of: type)
        validateSizeBounds(of: type)
        validateBoundInvariant(of: type)
        validateNoNaNBounds(of: type)
        validateSignedValueProduction(of: type)
        validateValueBounds(of: type)
    }
    
    
    
    /// Validates that arbitrary value generation of the given type is
    /// deterministic.
    /// - Parameter type: The type to evaluate.
    private func validateDeterminism<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let (context1, context2) = GenerationContext.sameRandomContexts
            
            XCTAssertEqual(
                R.arbitrary(using: context1),
                R.arbitrary(using: context2)
            )
        }
    }
    
    
    
    /// Validates that a size of zero produces arbitrary values of zero.
    /// - Parameter type: The type to evaluate.
    private func validateSizeZeroProduction<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let range = R.arbitrary(using: .randomZeroSize)
            
            if range.lowerBound.isFinite
            {
                XCTAssertEqual(range.lowerBound, 0.0)
            }
            
            if range.upperBound.isFinite
            {
                XCTAssertEqual(range.upperBound, 0.0)
            }
        }
    }
    
    
    
    /// Validates that arbitrary values of the given type respect the expected
    /// size bounds.
    /// - Parameter type: The type to evaluate.
    private func validateSizeBounds<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        let size    : Int       = 10
        let bound   : R.Bound   = .init(size + 1)
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   size
            )
            
            let range = R.arbitrary(using: context)
            
            if range.lowerBound.isFinite
            {
                XCTAssertGreaterThanOrEqual(range.lowerBound, -bound)
            }
            
            if range.upperBound.isFinite
            {
                XCTAssertLessThanOrEqual(range.lowerBound, bound)
            }
        }
    }
    
    
    
    /// Validates the bounds of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateBoundInvariant<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let range = R.arbitrary(using: .random)
            
            XCTAssertLessThanOrEqual(range.lowerBound, range.upperBound)
        }
    }
    
    
    
    /// Validates that neither bound of the generated range is NaN.
    /// - Parameter type: The type to evaluate.
    private func validateNoNaNBounds<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let range = R.arbitrary(using: .random)
            
            XCTAssertFalse(range.lowerBound.isNaN)
            XCTAssertFalse(range.upperBound.isNaN)
        }
    }
    
    
    
    /// Validates that arbitrary values of the given type produce values of
    /// the appropriate sign.
    /// - Parameter type: The type to evaluate.
    private func validateSignedValueProduction<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
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
        
        XCTAssertTrue(hasNegativeLower)
        XCTAssertTrue(hasPositiveUpper)
    }
    
    
    
    /// Validates that arbitrary values of the given type remain within the
    /// type's representable range when the size exceeds that range.
    /// - Parameter type: The type to evaluate.
    private func validateValueBounds<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        let typeMax = R.Bound.greatestFiniteMagnitude
        
        guard typeMax < R.Bound(Int.max)
        else
        {
            return
        }
        
        for _ in 0..<1000
        {
            let context = GenerationContext(
                seed:   GenerationContext.randomSeed,
                size:   Int(typeMax) * 2
            )
            
            let range = R.arbitrary(using: context)
            
            if range.lowerBound.isFinite
            {
                XCTAssertGreaterThanOrEqual(range.lowerBound, -typeMax)
            }
            
            if range.upperBound.isFinite
            {
                XCTAssertLessThanOrEqual(range.lowerBound, typeMax)
            }
        }
    }
    
    
    
    // MARK: - Shrinking support
    
    /// Validates the shrink candidates of the given type.
    /// - Parameter type: The type to test.
    private func testShrinking<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        validateZeroBoundsShrinking(of: type)
        validateCuratedCandidates(of: type)
        
        let bounds: [[R.Bound]] =
        [
            [0, 5],
            [1, 1],
            [2.5, 7.5],
            [3, 3],
            [-5, 10],
            [-3, -1],
            [-1, 1],
            [-0.5, 0.5]
        ]
        
        for bound in bounds
        {
            validateShrinkCandidates(of: R(lower: bound[0], upper: bound[1]))
        }
    }
    
    
    
    /// Validates that a range with both bounds equal to zero produces no
    /// shrink candidates.
    /// - Parameter type: The type to test.
    private func validateZeroBoundsShrinking<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        let range = R(lower: 0, upper: 0)
        
        XCTAssertEqual(range.shrink(), [])
    }
    
    
    
    /// Validates the expected shrink candidates of specific ranges.
    /// - Parameter type: The type to test.
    private func validateCuratedCandidates<R>(
        of type: R.Type
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        XCTAssertEqual(
            R(lower: 1, upper: 1).shrink(),
            [
                R(lower: 0, upper: 1),
                R(lower: 0, upper: 0)
            ]
        )
    }
    
    
    
    /// Validates the correctness of the shrink candidates of the given range.
    /// - Parameter range: The range to evaluate.
    private func validateShrinkCandidates<R>(
        of range: R
    ) where R : Arbitrary & ArbitraryRange & Equatable,
            R.Bound : Arbitrary & BinaryFloatingPoint,
            R.Bound.RawSignificand : FixedWidthInteger
    {
        let candidates: [R] = range.shrink()
        
        for candidate in candidates
        {
            XCTAssertLessThanOrEqual(
                candidate.lowerBound,
                candidate.upperBound
            )
            
            XCTAssertFalse(candidate.lowerBound.isNaN)
            XCTAssertFalse(candidate.upperBound.isNaN)
            
            XCTAssertNotEqual(candidate, range)
            
            let lowerCloser: Bool
                = candidate.lowerBound.magnitude <= range.lowerBound.magnitude
            
            let upperCloser: Bool
                = candidate.upperBound.magnitude <= range.upperBound.magnitude
            
            /// At least one bound must be closer to zero (or equal).
            XCTAssertTrue(lowerCloser || upperCloser)
        }
    }
}
