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



internal final class FloatingGeneratorTests: XCTestCaseStopOnFail
{
    // MARK: - Closed range
    
    func testDoubleClosedRange()
    {
        testClosedRange(of: Double.self)
    }
    
    
    
    func testFloatClosedRange()
    {
        testClosedRange(of: Float.self)
    }
    
    
    
    func testFloat16ClosedRange()
    {
        testClosedRange(of: Float16.self)
    }
    
    
    
    // MARK: - Range
    
    func testDoubleRange()
    {
        testRange(of: Double.self)
    }
    
    
    
    func testFloatRange()
    {
        testRange(of: Float.self)
    }
    
    
    
    func testFloat16Range()
    {
        testRange(of: Float16.self)
    }
}



// MARK: - Support

extension FloatingGeneratorTests
{
    // MARK: - Closed range support
    
    /// Validates closed ranges of the given type.
    /// - Parameter type: The type to evaluate.
    private func testClosedRange<T>(
        of type: T.Type
    ) where T : Arbitrary & BinaryFloatingPoint,
            T.RawSignificand : FixedWidthInteger
    {
        let ranges: [ClosedRange<T>] =
        [
            T(10)...T(50),
            T(-10)...T(50),
            T(-50)...T(-10),
            T(0)...T(20),
            T(-20)...T(0),
            T(5)...T(5),
            T(5)...T(6),
            T(3.0)...T(3.5)
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
    ) where T : Arbitrary & BinaryFloatingPoint,
            T.RawSignificand : FixedWidthInteger
    {
        let generator: Generator<T> = .floatingPoint(in: range)
        
        validateDeterminism(of: generator)
        
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
    ) where T : Arbitrary & BinaryFloatingPoint,
            T.RawSignificand : FixedWidthInteger
    {
        let ranges: [Range<T>] =
        [
            T(10)..<T(50),
            T(-10)..<T(50),
            T(-50)..<T(-10),
            T(0)..<T(20),
            T(-20)..<T(0),
            T(5)..<T(6),
            T(3.0)..<T(3.5)
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
    ) where T : Arbitrary & BinaryFloatingPoint,
            T.RawSignificand : FixedWidthInteger
    {
        let generator: Generator<T> = .floatingPoint(in: range)
        
        validateDeterminism(of: generator)
        
        validateBounds(
            of:     generator,
            in:     range
        )
        
        validateVariety(of: generator)
        
        validateShrinkCandidateBounds(
            of:     generator,
            in:     range
        )
    }
    
    
    
    // MARK: - Generation support
    
    /// Validates that the output of the given generator is deterministic.
    /// - Parameter generator: The generator to evaluate.
    private func validateDeterminism<T>(
        of generator: Generator<T>
    ) where T : BinaryFloatingPoint
    {
        let (context1, context2) = GenerationContext.sameRandomContexts
        
        for _ in 0..<1000
        {
            let value1  : T     = generator.generate(context1)
            let value2  : T     = generator.generate(context2)
            
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
    
    
    
    /// Validates that the given generator generates values within the
    /// given range.
    /// - Parameters:
    ///   - generator: The generator to use.
    ///   - range: The range to use.
    private func validateBounds<T>(
        of  generator   : Generator<T>,
        in  range       : ClosedRange<T>
    ) where T : BinaryFloatingPoint
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
    ) where T : BinaryFloatingPoint
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
    ) where T : BinaryFloatingPoint
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
    ) where T : BinaryFloatingPoint
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
    ) where T : Arbitrary & BinaryFloatingPoint
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
    ) where T : Arbitrary & BinaryFloatingPoint
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
    
    
    
    /// Validates the given range contains the shrink candidates produced by
    /// the given generator.
    /// - Parameters:
    ///   - generator: The generator to use.
    ///   - range: The range to use.
    private func validateShrinkCandidateBounds<T>(
        of  generator   : Generator<T>,
        in  range       : Range<T>
    ) where T : Arbitrary & BinaryFloatingPoint
    {
        let values: [T] =
        [
            range.lowerBound,
            range.upperBound - .ulpOfOne
        ]
        
        for value in values
        {
            for candidate in generator.shrink(value)
            {
                XCTAssertTrue(range.contains(candidate))
            }
        }
    }
    
    
    
    /// Returns the shrink target for the given range.
    /// - Parameter range: The range to use.
    /// - Returns: The shrink target for the given range.
    private func shrinkTarget<T>(
        for range: ClosedRange<T>
    ) -> T where T : BinaryFloatingPoint
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

