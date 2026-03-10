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



internal final class FloatingGeneratorTests: TestKitCase
{
    // MARK: - Closed range
    
    func testDoubleClosedRange()
    {
        validateClosedRange(of: Double.self)
    }
    
    
    
    func testFloatClosedRange()
    {
        validateClosedRange(of: Float.self)
    }
    
    
    
    func testFloat16ClosedRange()
    {
        validateClosedRange(of: Float16.self)
    }
    
    
    
    // MARK: - Range
    
    func testDoubleRange()
    {
        validateRange(of: Double.self)
    }
    
    
    
    func testFloatRange()
    {
        validateRange(of: Float.self)
    }
    
    
    
    func testFloat16Range()
    {
        validateRange(of: Float16.self)
    }
}



// MARK: - Support

extension FloatingGeneratorTests
{
    // MARK: - Closed range support
    
    /// Validates closed ranges of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateClosedRange<T>(
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
        
        generator.assertDeterministic()
        
        validateBounds(
            of:     generator,
            in:     range
        )
        
        if range.lowerBound != range.upperBound
        {
            validateGenerationVariety(of: generator)
            validateMutationVariety(of: generator)
        }
        else
        {
            validateConstantGeneration(
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
        
        validateMutationBounds(
            of:     generator,
            in:     range
        )
        
        validateMutationNonFinite(
            of:     generator,
            in:     range
        )
    }
    
    
    
    // MARK: - Range support
    
    /// Validates ranges of the given type.
    /// - Parameter type: The type to evaluate.
    private func validateRange<T>(
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
        
        generator.assertDeterministic()
        
        validateBounds(
            of:     generator,
            in:     range
        )
        
        validateGenerationVariety(of: generator)
        validateMutationVariety(of: generator)
        
        /// The half-open range implementation delegates to the closed range
        /// implementation, so validate against the equivalent closed range.
        let closed: ClosedRange<T>
            = range.lowerBound...range.upperBound.nextDown
        
        validateShrinkCandidateBounds(
            of:     generator,
            in:     closed
        )
        
        validateMutationBounds(
            of:     generator,
            in:     closed
        )
        
        validateMutationNonFinite(
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
    private func validateGenerationVariety<T>(
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
    private func validateConstantGeneration<T>(
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
    
    
    
    // MARK: - Mutation support
    
    /// Validates that mutation of the given generator produces values within
    /// the given range.
    /// - Parameters:
    ///   - generator: The generator to use.
    ///   - range: The range to use.
    func validateMutationBounds<T>(
        of  generator   : Generator<T>,
        in  range       : ClosedRange<T>
    ) where T : BinaryFloatingPoint, T.RawSignificand : FixedWidthInteger
    {
        for _ in 0..<1000
        {
            let context: GenerationContext = .random
            
            let value   : T     = generator.generate(context)
            let mutated : T     = generator.mutate(value, context)
            
            XCTAssertGreaterThanOrEqual(mutated, range.lowerBound)
            XCTAssertLessThanOrEqual(mutated, range.upperBound)
        }
        
        for value in [range.lowerBound, range.upperBound]
        {
            for _ in 0..<1000
            {
                let mutated: T = generator.mutate(value, .random)
                
                XCTAssertGreaterThanOrEqual(mutated, range.lowerBound)
                XCTAssertLessThanOrEqual(mutated, range.upperBound)
            }
        }
    }
    
    
    
    /// Validates that mutation of the given generator produces a variety of
    /// values.
    /// - Parameter generator: The generator to use.
    func validateMutationVariety<T>(
        of generator: Generator<T>
    ) where T : BinaryFloatingPoint, T.RawSignificand : FixedWidthInteger
    {
        let value   : T         = generator.generate(.random)
        var unique  : Set<T>    = []
        
        for _ in 0..<1000
        {
            unique.insert(generator.mutate(value, .random))
        }
        
        XCTAssertGreaterThan(unique.count, 1)
    }
    
    
    
    /// Validates that mutation of non-finite values produces finite, in-range
    /// values.
    /// - Parameters:
    ///   - generator: The generator to use.
    ///   - range: The range to use.
    func validateMutationNonFinite<T>(
        of  generator   : Generator<T>,
        in  range       : ClosedRange<T>
    ) where T : BinaryFloatingPoint, T.RawSignificand : FixedWidthInteger
    {
        for value in [T.nan, T.infinity, -T.infinity]
        {
            for _ in 0..<1000
            {
                let mutated: T = generator.mutate(value, .random)
                
                XCTAssertTrue(mutated.isFinite)
                XCTAssertGreaterThanOrEqual(mutated, range.lowerBound)
                XCTAssertLessThanOrEqual(mutated, range.upperBound)
            }
        }
    }
}
