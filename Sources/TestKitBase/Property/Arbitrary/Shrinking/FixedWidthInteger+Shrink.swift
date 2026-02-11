//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

extension FixedWidthInteger
{
    /// Shrinks the value toward zero or the nearest bound by repeatedly
    /// halving the distance.
    ///
    /// Shrink candidates converage toward zero if zero is within the range,
    /// otherwise toward the nearest bound.
    ///
    /// - Parameter range: The range in which to generate integers.
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
            return Self.shrink(self, toward: 0)
        }
        
        let target: Self
        
        if range.contains(0)
        {
            target = 0
        }
        else if 0 < range.lowerBound
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
        guard value != target
        else
        {
            return []
        }
        
        var candidates  : [Self]    = [target]
        var distance    : Self      = value - target
        
        while true
        {
            distance /= 2
            
            if distance == 0
            {
                break
            }
            
            candidates.append(value - distance)
        }
        
        return candidates
    }
}
