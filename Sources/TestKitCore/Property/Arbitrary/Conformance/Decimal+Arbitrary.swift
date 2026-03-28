//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-test-kit open source project.
//
// Copyright (c) Margins Technologies LLC.
// Licensed under the Apache License, Version 2.0.
//
//===----------------------------------------------------------------------===//

import Foundation



extension Decimal: Arbitrary
{
    /// Generates an arbitrary value using the given generation context.
    /// - Parameter context: The generation context.
    /// - Returns: An arbitrary value in the range
    /// `-context.size...context.size`, with a fractional component.
    /// Occassionally generates `NaN`.
    public static func arbitrary(
        using context: GenerationContext
    ) -> Decimal
    {
        if context.random(in: 1...20) == 1
        {
            return .nan
        }
        
        let integer = Decimal(context.random(in: -context.size...context.size))
        let fraction = Decimal(context.random(in: -1000...1000)) / 1000
        
        return integer + fraction
    }
    
    
    
    /// Generates candidate values that are smaller than the receiver value.
    ///
    /// `NaN` shrink to zero. Finite values shrink toward zero by
    /// truncating the fractional component, then repeatedly halving the
    /// distance.
    ///
    /// - Returns: An array of smaller candidate values, or an empty array
    /// to indicate that no shrinking should occur.
    public func shrink() -> [Decimal]
    {
        return Self.shrink(self, toward: 0)
    }
    
    
    
    /// Produces a value that is a small perturbation of the receiver value.
    /// - Parameter context: The generation context.
    /// - Returns: A mutated value.
    public func mutate(
        using context: GenerationContext
    ) -> Decimal
    {
        if isNaN
        {
            return Decimal.arbitrary(using: context)
        }
        
        let maxDelta    = Decimal(max(1, context.size))
        let scale       = Decimal(context.random(in: -1000...1000)) / 1000
        
        return self + (scale * maxDelta)
    }
    
    
    
    // MARK: - Support
    
    private static func shrink(
        _       value   : Decimal,
        toward  target  : Decimal
    ) -> [Decimal]
    {
        guard !value.isNaN
        else
        {
            return [target]
        }
        
        guard value != target
        else
        {
            return []
        }
        
        
        
        var candidates      : [Decimal]     = [target]
        var truncated       : Decimal       = .init()
        var mutableValue    : Decimal       = value
        
        let roundingMode: NSDecimalNumber.RoundingMode =
            value > target ? .down : .up
        
        NSDecimalRound(
            &truncated,
            &mutableValue,
            0,
            roundingMode
        )
        
        if
            truncated != value,
            truncated != target
        {
            candidates.append(truncated)
        }
        
        
        
        var distance: Decimal = truncated != target
            ? truncated
            : value
        
        while true
        {
            let gap: Decimal = distance - target
            
            guard
                gap > 0.5
                || gap < -0.5
            else
            {
                break
            }
            
            distance = target + gap / 2
            
            /// Round toward the target to ensure integer steps.
            var rounded         : Decimal       = .init()
            var mutableValue    : Decimal       = distance
            
            NSDecimalRound(
                &rounded,
                &mutableValue,
                0,
                roundingMode
            )
            
            distance = rounded
            
            if
                distance != value,
                distance != target
            {
                candidates.append(distance)
            }
        }
        
        return candidates
    }
}
