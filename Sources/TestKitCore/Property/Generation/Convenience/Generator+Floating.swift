//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator
    where G : BinaryFloatingPoint,
          G.RawSignificand : FixedWidthInteger
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
        in range: ClosedRange<G>
    ) -> Generator<G>
    {
        return Generator<G>(
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
                    generate:       { context.random(in: range) },
                    using:          context
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
        in range: Range<G>
    ) -> Generator<G>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        return Generator<G>(
            generate:
            {
                context in
                
                return context.random(in: range)
            },
            shrink:
            {
                value in
                
                /// Shrink with a closed range and filter out the upper bound.
                let closed: ClosedRange<G>
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
                    generate:       { context.random(in: range) },
                    using:          context
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
    ///   - generate: The function to generate a value.
    ///   - context: The generation context.
    /// - Returns: The mutated floating-point number.
    private static func mutateFloatingPoint(
        _ value         : G,
        lowerBound      : G,
        upperBound      : G,
        generate        : () -> G,
        using context   : GenerationContext
    ) -> G
    {
        guard value.isFinite
        else
        {
            return generate()
        }
        
        if context.random(in: 1...5) == 1
        {
            let factor  : G     = context.random(in: 0.5...1.5)
            let scaled  : G     = value * factor
            
            let clamped: G = min(
                upperBound,
                max(lowerBound, scaled)
            )
            
            return clamped.isFinite
                ? clamped
                : generate()
        }
        else
        {
            let magnitude   : G     = max(1.0, abs(value) * 0.1)
            let delta       : G     = context.random(in: -magnitude...magnitude)
            
            let result: G = min(
                upperBound,
                max(lowerBound, value + delta)
            )
            
            return result.isFinite
                ? result
                : generate()
        }
    }
}
