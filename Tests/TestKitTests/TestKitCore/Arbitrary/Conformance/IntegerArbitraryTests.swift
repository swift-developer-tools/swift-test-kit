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



internal final class IntegerArbitraryTests: XCTestCaseStopOnFail
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
}
