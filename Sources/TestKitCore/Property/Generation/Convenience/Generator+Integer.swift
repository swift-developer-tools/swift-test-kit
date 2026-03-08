//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator where V : FixedWidthInteger
{
    /// Creates a generator that produces integers in the given range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The range in which to generate integers.
    /// - Returns: A generator that produces integers in the given range.
    public static func integer(
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
                
                let maxDelta    : V     = V(clamping: max(1, context.size))
                let delta       : V     = context.random(in: 0...maxDelta)
                
                if context.randomBool()
                {
                    let (result, overflow)
                        = value.addingReportingOverflow(delta)
                    
                    return overflow
                        ? range.upperBound
                        : min(range.upperBound, result)
                }
                else
                {
                    let (result, overflow)
                        = value.subtractingReportingOverflow(delta)
                    
                    return overflow
                        ? range.lowerBound
                        : max(range.lowerBound, result)
                }
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
    public static func integer(
        in range: Range<V>
    ) -> Generator<V>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        return integer(in: range.lowerBound...(range.upperBound - 1))
    }
}
