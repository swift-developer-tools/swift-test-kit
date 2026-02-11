//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension BinaryFloatingPoint
{
    /// Shrinks the value toward zero or the nearest bound by repeatedly
    /// halving the distance.
    ///
    /// Shrink candidates converage toward zero if zero is within the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The range in which to generate floating-point
    /// numbers.
    /// - Returns: The shrink candidates.
    internal func shrinkTowardZero(
        in range: ClosedRange<Self>? = nil
    ) -> [Self]
    {
        guard
            let range,
            !range.isEmpty
        else
        {
            return Self.shrink(self, toward: 0.0)
        }
        
        let target: Self
        
        if range.contains(0.0)
        {
            target = 0.0
        }
        else if 0.0 < range.lowerBound
        {
            target = range.lowerBound
        }
        else
        {
            target = range.upperBound
        }
        
        return Self.shrink(self, toward: target)
            .filter { range.contains($0) }
    }
    
    
    
    /// Shrinks the given value toward the given target by repeatedly halving
    /// the distance.
    /// - Parameters:
    ///   - value: The value to shrink.
    ///   - target: The value toward which shrink candidates converge.
    /// - Returns: The shrink candidates.
    private static func shrink(
        _       value   : Self,
        toward  target  : Self
    ) -> [Self]
    {
        guard
            value.isFinite,
            !value.isNaN
        else
        {
            return [target]
        }
        
        guard value != target
        else
        {
            return []
        }
        
        
        
        var candidates: [Self] = [target]
        
        /// Truncate the fractional part toward the target.
        let truncated: Self = value.rounded(value > target ? .down : .up)
        
        if
            truncated != value,
            truncated != target
        {
            candidates.append(truncated)
        }
        
        
        
        var distance: Self = truncated != target
            ? truncated
            : value
        
        while abs(distance - target) > 0.5
        {
            distance = target + (distance - target) / 2
            
            distance.round(value > target ? .down : .up)
            
            if
                distance != target,
                distance != value
            {
                candidates.append(distance)
            }
        }
        
        return candidates
    }
    
    
    
    /// Returns the maximum magnitude for generation, based on the type's
    /// representable range.
    ///
    /// If `greatestFiniteMagnitude` is less than `Int.max`, this returns the
    /// lesser of ``GenerationContext/size`` and the greatest finite magnitude.
    /// Otherwise, it returns ``GenerationContext/size``.
    ///
    /// - Parameter context: The generation context.
    /// - Returns: The generation bound.
    internal static func bound(
        from context: GenerationContext
    ) -> Int
    {
        if Self.greatestFiniteMagnitude < Self(Int.max)
        {
            return Swift.min(context.size, Int(Self.greatestFiniteMagnitude))
        }
        
        return context.size
    }
    
    
    
    /// Special values to occasionally generate.
    internal static var specialValues: [Self]
    {
        return [
            -0.0,
            .infinity,
            -.infinity,
            .nan
        ]
    }
    
    
    
    /// Generates a special value 5% of the time.
    /// - Parameter context: The generation context.
    /// - Returns: A special value or `nil`.
    internal static func specialValue(
        using context: GenerationContext
    ) -> Self?
    {
        if context.random(in: 1...20) == 1
        {
            return context.randomElement(of: specialValues) ?? 0.0
        }
        
        return nil
    }
}
