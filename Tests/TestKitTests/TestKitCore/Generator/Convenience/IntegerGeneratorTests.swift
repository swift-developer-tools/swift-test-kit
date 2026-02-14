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



internal final class IntegerGeneratorTests: XCTestCaseStopOnFail
{
    // MARK: - Closed range
    
    func testIntClosedRange()
    {
        testClosedRange(of: Int.self)
    }
    
    
    
    func testInt8ClosedRange()
    {
        testClosedRange(of: Int8.self)
    }
    
    
    
    func testInt16ClosedRange()
    {
        testClosedRange(of: Int16.self)
    }
    
    
    
    func testInt32ClosedRange()
    {
        testClosedRange(of: Int32.self)
    }
    
    
    
    func testInt64ClosedRange()
    {
        testClosedRange(of: Int64.self)
    }
    
    
    
    func testUIntClosedRange()
    {
        testClosedRange(of: UInt.self)
    }
    
    
    
    func testUInt8ClosedRange()
    {
        testClosedRange(of: UInt8.self)
    }
    
    
    
    func testUInt16ClosedRange()
    {
        testClosedRange(of: UInt16.self)
    }
    
    
    
    func testUInt32ClosedRange()
    {
        testClosedRange(of: UInt32.self)
    }
    
    
    
    func testUInt64ClosedRange()
    {
        testClosedRange(of: UInt64.self)
    }
    
    
    
    // MARK: - Range
    
    func testIntRange()
    {
        testRange(of: Int.self)
    }
    
    
    
    func testInt8Range()
    {
        testRange(of: Int8.self)
    }
    
    
    
    func testInt16Range()
    {
        testRange(of: Int16.self)
    }
    
    
    
    func testInt32Range()
    {
        testRange(of: Int32.self)
    }
    
    
    
    func testInt64Range()
    {
        testRange(of: Int64.self)
    }
    
    
    
    func testUIntRange()
    {
        testRange(of: UInt.self)
    }
    
    
    
    func testUInt8Range()
    {
        testRange(of: UInt8.self)
    }
    
    
    
    func testUInt16Range()
    {
        testRange(of: UInt16.self)
    }
    
    
    
    func testUInt32Range()
    {
        testRange(of: UInt32.self)
    }
    
    
    
    func testUInt64Range()
    {
        testRange(of: UInt64.self)
    }
}



// MARK: - Support

extension IntegerGeneratorTests
{
    // MARK: - Closed range support
    
    /// Validates closed ranges of the given type.
    /// - Parameter type: The type to evaluate.
    private func testClosedRange<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        if T.isSigned
        {
            validateClosedRange(T(-10)...T(10))
            validateClosedRange(T(-50)...T(-25))
            validateClosedRange(T(-20)...T(0))
        }
        
        let ranges: [ClosedRange<T>] =
        [
            T(10)...T(50),
            T(0)...T(20),
            T(0)...T(0),
            T(5)...T(5),
            T(5)...T(6),
            T(20)...T(30)
        ]
        
        for range in ranges
        {
            validateClosedRange(range)
        }
    }
    
    
    
    /// Validates closed ranges of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateClosedRange<T>(
        _ range: ClosedRange<T>
    ) where T : Arbitrary & FixedWidthInteger
    {
        let generator: Generator<T> = .integer(in: range)
        
        generator.validateDeterminism()
        
        validateBounds(
            of:     generator,
            in:     range
        )
        
        if range.lowerBound != range.upperBound
        {
            validateVariety(of: generator)
        }
        else
        {
            validateConstant(
                of:         generator,
                expected:   range.lowerBound
            )
        }
        
        validateShrinkTarget(
            of:     generator,
            in:     range
        )
        
        validateShrinkCandidateBounds(
            of:     generator,
            in:     range
        )
    }
    
    
    
    // MARK: - Range support
    
    /// Validates ranges of the given type.
    /// - Parameter type: The type to evaluate.
    private func testRange<T>(
        of type: T.Type
    ) where T : Arbitrary & FixedWidthInteger
    {
        if T.isSigned
        {
            validateRange(T(-10)..<T(11))
            validateRange(T(-50)..<T(-24))
        }
        
        let ranges: [Range<T>] =
        [
            T(10)..<T(51),
            T(0)..<T(21),
            T(0)..<T(1),
            T(5)..<T(6),
            T(5)..<T(7),
            T(20)..<T(31)
        ]
        
        for range in ranges
        {
            validateRange(range)
        }
    }
    
    
    
    /// Validates ranges of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateRange<T>(
        _ range: Range<T>
    ) where T : Arbitrary & FixedWidthInteger
    {
        let generator: Generator<T> = .integer(in: range)
        
        generator.validateDeterminism()
        
        validateBounds(
            of:     generator,
            in:     range
        )
        
        if range.lowerBound + 1 != range.upperBound
        {
            validateVariety(of: generator)
        }
        else
        {
            validateConstant(
                of:         generator,
                expected:   range.lowerBound
            )
        }
        
        /// The half-open range implementation delegates to the closed range
        /// implementation, so validate against the equivalent closed range.
        let closed: ClosedRange<T> = range.lowerBound...(range.upperBound - 1)
        
        validateShrinkTarget(
            of:     generator,
            in:     closed
        )
        
        validateShrinkCandidateBounds(
            of:     generator,
            in:     closed
        )
    }
    
    
    
    // MARK: - Generation support
    
    /// Validates that the given generator generates values within the
    /// given range.
    /// - Parameters:
    ///   - generator: The generator to use.
    ///   - range: The range to use.
    private func validateBounds<T>(
        of  generator   : Generator<T>,
        in  range       : ClosedRange<T>
    ) where T : FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let value: T = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(value, range.lowerBound)
            XCTAssertLessThanOrEqual(value, range.upperBound)
        }
    }
    
    
    
    /// Validates that the given generator generates values within the
    /// given range.
    /// - Parameters:
    ///   - generator: The generator to use.
    ///   - range: The range to use.
    private func validateBounds<T>(
        of  generator   : Generator<T>,
        in  range       : Range<T>
    ) where T : FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let value: T = generator.generate(.random)
            
            XCTAssertGreaterThanOrEqual(value, range.lowerBound)
            XCTAssertLessThanOrEqual(value, range.upperBound)
        }
    }
    
    
    
    /// Validates that the given generator generates a variety of values.
    /// - Parameter generator: The generator to use.
    private func validateVariety<T>(
        of generator: Generator<T>
    ) where T : FixedWidthInteger
    {
        var unique: Set<T> = []
        
        for _ in 0..<1000
        {
            unique.insert(generator.generate(.random))
        }
        
        XCTAssertGreaterThan(unique.count, 1)
    }
    
    
    
    /// Validates that the given generator generates the given value.
    /// - Parameters:
    ///   - generator: The generator to use.
    ///   - expected: The expected value.
    private func validateConstant<T>(
        of generator    : Generator<T>,
        expected        : T
    ) where T : FixedWidthInteger
    {
        for _ in 0..<1000
        {
            XCTAssertEqual(generator.generate(.random), expected)
        }
    }
    
    
    
    // MARK: - Shrinking support
    
    /// Validates the shrink candidates produced by the given generator.
    /// - Parameters:
    ///   - generator: The generator to use.
    ///   - range: The range to use.
    private func validateShrinkTarget<T>(
        of  generator   : Generator<T>,
        in  range       : ClosedRange<T>
    ) where T : Arbitrary & FixedWidthInteger
    {
        let target: T = shrinkTarget(for: range)
        
        /// Value at `target` produces no shrink candidates.
        XCTAssertTrue(generator.shrink(target).isEmpty)
        
        /// Value at the far end from `target` has `target` as its first
        /// shrink candidate.
        let far: T = target == range.upperBound
            ? range.lowerBound
            : range.upperBound
        
        guard far != target
        else
        {
            /// Single-value target.
            return
        }
        
        let candidates: [T] = generator.shrink(far)
        
        XCTAssertFalse(candidates.isEmpty)
        XCTAssertEqual(candidates.first, target)
    }
    
    
    
    /// Validates the given range contains the shrink candidates produced by
    /// the given generator.
    /// - Parameters:
    ///   - generator: The generator to use.
    ///   - range: The range to use.
    private func validateShrinkCandidateBounds<T>(
        of  generator   : Generator<T>,
        in  range       : ClosedRange<T>
    ) where T : Arbitrary & FixedWidthInteger
    {
        let target: T = shrinkTarget(for: range)
        
        let far: T = target == range.upperBound
            ? range.lowerBound
            : range.upperBound
        
        for candidate in generator.shrink(far)
        {
            XCTAssertTrue(range.contains(candidate))
        }
    }
    
    
    
    /// Returns the shrink target for the given range.
    /// - Parameter range: The range to use.
    /// - Returns: The shrink target for the given range.
    private func shrinkTarget<T>(
        for range: ClosedRange<T>
    ) -> T where T : FixedWidthInteger
    {
        if range.contains(0)
        {
            return 0
        }
        
        if 0 < range.lowerBound
        {
            return range.lowerBound
        }
        
        return range.upperBound
    }
}
