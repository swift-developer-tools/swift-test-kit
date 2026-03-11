//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension Generator where G : FixedWidthInteger
{
    /// Creates a generator that produces integers in the given range.
    ///
    /// Shrink candidates converge toward zero if zero is in the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The range in which to generate integers.
    /// - Returns: A generator that produces integers in the given range.
    public static func integer(
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
                
                let maxDelta    : G     = G(clamping: max(1, context.size))
                let delta       : G     = context.random(in: 0...maxDelta)
                
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
        in range: Range<G>
    ) -> Generator<G>
    {
        precondition(
            !range.isEmpty,
            "range must not be empty"
        )
        
        return integer(in: range.lowerBound...(range.upperBound - 1))
    }
}
