//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator
    where V : BinaryFloatingPoint,
          V.RawSignificand : FixedWidthInteger
{
    /// Creates a generator that produces floating-point numbers in the given
    /// range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The range in which to generate floating-point
    /// numbers.
    /// - Returns: A generator that produces floating-point numbers in the
    /// given range.
    public static func floatingPoint(
        in range: ClosedRange<V>
    ) -> Generator<V>
    {
        return Generator<V>(
            generate:
            {
                context in
                
                return context.random(in: range)
            },
            shrink:
            {
                value in
                
                return value.shrinkTowardZero(in: range)
            },
            mutate:
            {
                value, context in
                
                return mutateFloatingPoint(
                    value,
                    lowerBound:     range.lowerBound,
                    upperBound:     range.upperBound,
                    using:          context,
                    generate:       { context.random(in: range) }
                )
            }
        )
    }
    
    
    
    /// Creates a generator that produces integers in the given range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Precondition: `range` must not be empty.
    ///
    /// - Parameter range: The range in which to generate integers.
    /// - Returns: A generator that produces integers in the given range.
    public static func floatingPoint(
        in range: Range<V>
    ) -> Generator<V>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        return Generator<V>(
            generate:
            {
                context in
                
                return context.random(in: range)
            },
            shrink:
            {
                value in
                
                /// Shrink with a closed range and filter out the upper bound.
                let closed: ClosedRange<V>
                    = range.lowerBound...range.upperBound
                
                return value.shrinkTowardZero(in: closed)
                    .filter { range.contains($0) }
            },
            mutate:
            {
                value, context in
                
                return mutateFloatingPoint(
                    value,
                    lowerBound:     range.lowerBound,
                    upperBound:     range.upperBound.nextDown,
                    using:          context,
                    generate:   {    context.random(in: range) }
                )
            }
        )
    }
    
    
    
    // MARK: - Support
    
    /// Mutates the given floating-point number.
    /// - Parameters:
    ///   - value: The floating-point number to mutate.
    ///   - lowerBound: The lower bound of the range.
    ///   - upperBound: The upper bound of the range.
    ///   - context: The generation context.
    ///   - generate: The function to generate a value.
    /// - Returns: The mutated floating-point number.
    private static func mutateFloatingPoint(
        _ value         : V,
        lowerBound      : V,
        upperBound      : V,
        using context   : GenerationContext,
        generate        : () -> V
    ) -> V
    {
        guard value.isFinite
        else
        {
            return generate()
        }
        
        if context.random(in: 1...5) == 1
        {
            let factor  : V     = context.random(in: 0.5...1.5)
            let scaled  : V     = value * factor
            
            let clamped: V = min(
                upperBound,
                max(lowerBound, scaled)
            )
            
            return clamped.isFinite
                ? clamped
                : generate()
        }
        else
        {
            let magnitude   : V     = max(1.0, abs(value) * 0.1)
            let delta       : V     = context.random(in: -magnitude...magnitude)
            
            let result: V = min(
                upperBound,
                max(lowerBound, value + delta)
            )
            
            return result.isFinite
                ? result
                : generate()
        }
    }
}
